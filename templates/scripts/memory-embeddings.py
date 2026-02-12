#!/usr/bin/env python3
"""
memory-embeddings.py - Vector Embedding Service for Memory System
Version: 1.0

Uses ChromaDB for persistent vector storage and sentence-transformers for embeddings.
"""

import sys
import os
import glob
import hashlib
import json
from datetime import datetime
from pathlib import Path

# Configuration - auto-detect install location
SCRIPT_PATH = os.path.abspath(__file__)
INSTALL_DIR = os.path.dirname(os.path.dirname(SCRIPT_PATH))
MEMORY_DIR = os.path.join(INSTALL_DIR, "memory")
DB_PATH = os.path.join(MEMORY_DIR, "cache", "chroma")
CACHE_DIR = os.path.join(MEMORY_DIR, "cache")

# Venv support
VENV_PATH = os.path.join(INSTALL_DIR, "venv")
if os.path.exists(VENV_PATH):
    site_packages = os.path.join(
        VENV_PATH,
        "lib",
        f"python{sys.version_info.major}.{sys.version_info.minor}",
        "site-packages",
    )
    if os.path.exists(site_packages):
        sys.path.insert(0, site_packages)

# Lazy-loaded components
_model = None
_client = None
_collection = None


def get_model():
    global _model
    if _model is None:
        print("Loading embedding model (all-MiniLM-L6-v2)...", file=sys.stderr)
        from sentence_transformers import SentenceTransformer

        _model = SentenceTransformer("all-MiniLM-L6-v2")
    return _model


def get_client():
    global _client
    if _client is None:
        import chromadb
        from chromadb.config import Settings

        os.makedirs(DB_PATH, exist_ok=True)
        _client = chromadb.PersistentClient(path=DB_PATH)
    return _client


def get_collection():
    global _collection
    if _collection is None:
        client = get_client()
        _collection = client.get_or_create_collection(
            name="memory", metadata={"description": "Agent memory embeddings"}
        )
    return _collection


def chunk_content(content: str, max_size: int = 500) -> list:
    chunks = []
    current_chunk = []
    current_size = 0

    for line in content.split("\n"):
        if not current_chunk and not line.strip():
            continue
        if current_size + len(line) > max_size and current_chunk:
            chunks.append("\n".join(current_chunk))
            current_chunk = []
            current_size = 0
        current_chunk.append(line)
        current_size += len(line)

    if current_chunk:
        chunks.append("\n".join(current_chunk))

    return chunks if chunks else [""]


def extract_tags(content: str) -> list:
    tags = []
    if content.startswith("---"):
        parts = content.split("---", 2)
        if len(parts) >= 3:
            frontmatter = parts[1]
            for line in frontmatter.split("\n"):
                if line.startswith("tags:"):
                    tag_str = line.replace("tags:", "").strip()
                    tags = [t.strip().strip("[]") for t in tag_str.split(",")]
                    break
    return tags


def embed_file(filepath: str) -> int:
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    filename = os.path.basename(filepath)
    file_id = hashlib.md5(filepath.encode()).hexdigest()[:16]
    tags = extract_tags(content)
    chunks = chunk_content(content)

    model = get_model()
    collection = get_collection()

    # Delete existing chunks
    existing_ids = [f"{file_id}_{i}" for i in range(100)]
    try:
        collection.delete(ids=existing_ids)
    except:
        pass

    # Embed and store
    for i, chunk in enumerate(chunks):
        if not chunk.strip():
            continue
        chunk_id = f"{file_id}_{i}"
        embedding = model.encode(chunk).tolist()
        collection.upsert(
            ids=[chunk_id],
            embeddings=[embedding],
            metadatas=[
                {
                    "source": filepath,
                    "filename": filename,
                    "chunk_index": i,
                    "tags": ",".join(tags),
                    "total_chunks": len(chunks),
                    "embedded_at": datetime.now().isoformat(),
                }
            ],
            documents=[chunk],
        )

    return len([c for c in chunks if c.strip()])


def embed_all_memory() -> dict:
    patterns = [
        os.path.join(MEMORY_DIR, "profiles", "*.md"),
        os.path.join(MEMORY_DIR, "core", "*.md"),
        os.path.join(MEMORY_DIR, "knowledge", "*.md"),
        os.path.join(MEMORY_DIR, "sessions", "daily", "*.md"),
    ]
    exclude_patterns = ["*-summary.md", "*archive*"]

    stats = {"files_processed": 0, "total_chunks": 0, "errors": []}

    for pattern in patterns:
        for filepath in glob.glob(pattern):
            if any(ex in filepath for ex in exclude_patterns):
                continue
            try:
                chunks = embed_file(filepath)
                stats["files_processed"] += 1
                stats["total_chunks"] += chunks
                print(f"  ✅ {os.path.basename(filepath)} ({chunks} chunks)")
            except Exception as e:
                stats["errors"].append({"file": filepath, "error": str(e)})
                print(f"  ❌ {os.path.basename(filepath)}: {e}", file=sys.stderr)

    return stats


def search_memory(query: str, n_results: int = 5) -> list:
    model = get_model()
    collection = get_collection()

    query_embedding = model.encode(query).tolist()
    results = collection.query(
        query_embeddings=[query_embedding], n_results=n_results * 2
    )

    sources = {}
    if results["documents"] and results["documents"][0]:
        for i, doc in enumerate(results["documents"][0]):
            source = results["metadatas"][0][i]["source"]
            distance = results["distances"][0][i]
            if source not in sources:
                sources[source] = {
                    "chunks": [],
                    "min_distance": distance,
                    "tags": results["metadatas"][0][i].get("tags", ""),
                }
            sources[source]["chunks"].append(
                {
                    "content": doc[:200] + "..." if len(doc) > 200 else doc,
                    "distance": distance,
                }
            )

    return sorted(sources.items(), key=lambda x: x[1]["min_distance"])[:n_results]


def get_status() -> dict:
    status = {
        "chromadb_path": DB_PATH,
        "chromadb_exists": os.path.exists(DB_PATH),
        "model": "all-MiniLM-L6-v2",
        "memory_files": 0,
        "total_size_mb": 0,
    }

    for pattern in [os.path.join(MEMORY_DIR, "**", "*.md")]:
        status["memory_files"] = len(glob.glob(pattern, recursive=True))

    if os.path.exists(DB_PATH):
        total_size = 0
        for dirpath, dirnames, filenames in os.walk(DB_PATH):
            for f in filenames:
                total_size += os.path.getsize(os.path.join(dirpath, f))
        status["total_size_mb"] = round(total_size / (1024 * 1024), 2)

    try:
        collection = get_collection()
        status["collection_count"] = collection.count()
    except:
        status["collection_count"] = 0

    return status


def main():
    if len(sys.argv) < 2:
        print("memory-embeddings.py - Vector Embedding Service")
        print("\nCommands: embed, search <query>, update <file>, status, clear")
        sys.exit(1)

    command = sys.argv[1]

    if command == "embed":
        print("🔄 Embedding all memory files...")
        stats = embed_all_memory()
        print(
            f"\n✅ Complete: {stats['files_processed']} files, {stats['total_chunks']} chunks"
        )

    elif command == "search":
        if len(sys.argv) < 3:
            print("Usage: memory-embeddings.py search <query>")
            sys.exit(1)
        query = " ".join(sys.argv[2:])
        print(f"🔍 Searching for: {query}\n")
        results = search_memory(query)
        if not results:
            print("No results found.")
        else:
            for source, data in results:
                print(f"📄 {source}")
                print(f"   Distance: {data['min_distance']:.4f}")
                print(f"   Tags: {data['tags']}")
                print(f"   Preview: {data['chunks'][0]['content'][:100]}...")
                print()

    elif command == "update":
        if len(sys.argv) < 3:
            print("Usage: memory-embeddings.py update <file>")
            sys.exit(1)
        chunks = embed_file(sys.argv[2])
        print(f"✅ Updated: {sys.argv[2]} ({chunks} chunks)")

    elif command == "status":
        status = get_status()
        print("=== EMBEDDING SYSTEM STATUS ===\n")
        for key, value in status.items():
            print(f"  {key}: {value}")

    elif command == "clear":
        import shutil

        if os.path.exists(DB_PATH):
            shutil.rmtree(DB_PATH)
            print("✅ Embeddings cleared")
        else:
            print("No embeddings to clear")

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
