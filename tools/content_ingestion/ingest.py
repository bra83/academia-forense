#!/usr/bin/env python3
"""
Academia Forense — Content Ingestion CLI (Python).
Ingests, deduplicates with authentic SHA-256, and validates educational packages.
"""

import argparse
import glob
import hashlib
import json
import os
import sys
import jsonschema

DEFAULT_SCHEMA_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "content", "schemas", "section_19_schema.json"
)

def compute_sha256(file_path: str) -> str:
    hasher = hashlib.sha256()
    with open(file_path, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()

def ingest_file(file_path: str, validator: jsonschema.Draft202012Validator) -> dict:
    if not os.path.exists(file_path):
        return {"status": "ERROR", "file": file_path, "error": "File not found"}
    
    sha256_hash = compute_sha256(file_path)
    with open(file_path, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
        except Exception as e:
            return {"status": "ERROR", "file": file_path, "sha256": sha256_hash, "error": f"JSON parse error: {e}"}
    
    errors = [e.message for e in validator.iter_errors(data)]
    if errors:
        return {"status": "INVALID", "file": file_path, "sha256": sha256_hash, "errors": errors}
    
    return {
        "status": "SUCCESS",
        "file": file_path,
        "sha256": sha256_hash,
        "contentId": data.get("contentId"),
        "title": data.get("title"),
        "edition": data.get("edition"),
        "editorialStatus": data.get("editorialStatus")
    }

def main():
    parser = argparse.ArgumentParser(description="Academia Forense Content Ingestion CLI")
    parser.add_argument("--input", "-i", help="Path to package JSON file or directory")
    parser.add_argument("--all-vol1", action="store_true", help="Ingest all Vol 1 seed packages")
    parser.add_argument("--schema", default=DEFAULT_SCHEMA_PATH, help="Path to Section 19 schema")
    args = parser.parse_args()

    if not os.path.exists(args.schema):
        print(f"Error: Schema not found at {args.schema}", file=sys.stderr)
        sys.exit(1)

    with open(args.schema, "r", encoding="utf-8") as f:
        schema = json.load(f)
    validator = jsonschema.Draft202012Validator(schema)

    targets = []
    if args.all_vol1:
        root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        targets = sorted(glob.glob(os.path.join(root_dir, "content", "fixtures", "volume_01", "vol01_ch*.json")))
    elif args.input:
        if os.path.isdir(args.input):
            targets = sorted(glob.glob(os.path.join(args.input, "*.json")))
        else:
            targets = [args.input]
    else:
        parser.print_help()
        sys.exit(1)

    print(f"Starting ingestion for {len(targets)} package(s)...")
    success_count = 0
    for target in targets:
        res = ingest_file(target, validator)
        if res["status"] == "SUCCESS":
            success_count += 1
            print(f"  ✓ {res['contentId']}: {res['title']} (SHA-256: {res['sha256'][:16]}...)")
        else:
            print(f"  ✗ {res['file']}: {res.get('error') or res.get('errors')}")

    print(f"Ingestion complete: {success_count}/{len(targets)} passed.")
    sys.exit(0 if success_count == len(targets) else 1)

if __name__ == "__main__":
    main()
