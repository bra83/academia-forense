#!/usr/bin/env python3
"""
Academia Forense — Section 19 & Curriculum Manifest Package Validator CLI (Python).
Validates chapter packages and curriculum manifest against canonical Draft 2020-12 schemas.
"""

import argparse
import glob
import json
import os
import sys
import jsonschema

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEFAULT_SCHEMA_PATH = os.path.join(REPO_ROOT, "content", "schemas", "section_19_schema.json")
DEFAULT_MANIFEST_SCHEMA_PATH = os.path.join(REPO_ROOT, "content", "schemas", "curriculum_manifest_schema.json")
DEFAULT_MANIFEST_PATH = os.path.join(REPO_ROOT, "content", "manifests", "curriculum.manifest.json")

def validate_file(file_path: str, validator: jsonschema.Draft202012Validator) -> list:
    if not os.path.exists(file_path):
        return [f"File not found: {file_path}"]
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        return [f"JSON decode error: {e}"]
    return [e.message for e in validator.iter_errors(data)]

# Alias for backward compatibility
validate_package_file = validate_file

def main():
    parser = argparse.ArgumentParser(description="Section 19 & Curriculum Manifest Validator")
    parser.add_argument("--input", "-i", help="Path to JSON package file")
    parser.add_argument("--dir", "-d", help="Directory containing JSON packages")
    parser.add_argument("--manifest", "-m", nargs="?", const=DEFAULT_MANIFEST_PATH, help="Path to curriculum.manifest.json")
    parser.add_argument("--all-vol1", action="store_true", help="Validate all Vol 1 seed packages")
    parser.add_argument("--all", "-a", action="store_true", help="Validate manifest and all Vol 1 seed packages")
    parser.add_argument("--schema", default=DEFAULT_SCHEMA_PATH, help="Path to package schema file")
    parser.add_argument("--manifest-schema", default=DEFAULT_MANIFEST_SCHEMA_PATH, help="Path to manifest schema file")
    args = parser.parse_args()

    failed = 0

    # 1. Validate manifest if requested or --all
    if args.manifest or args.all:
        manifest_file = args.manifest or DEFAULT_MANIFEST_PATH
        print(f"Validating curriculum manifest: {manifest_file} against {os.path.basename(args.manifest_schema)}...")
        if not os.path.exists(args.manifest_schema):
            print(f"  ✗ Schema not found: {args.manifest_schema}")
            sys.exit(1)
        with open(args.manifest_schema, "r", encoding="utf-8") as f:
            m_schema = json.load(f)
        m_val = jsonschema.Draft202012Validator(m_schema)
        m_errors = validate_file(manifest_file, m_val)
        if m_errors:
            failed += 1
            print(f"  ✗ INVALID MANIFEST: {manifest_file}")
            for err in m_errors:
                print(f"      - {err}")
        else:
            print(f"  ✓ VALID MANIFEST: {manifest_file}")

    # 2. Validate packages
    targets = []
    if args.all_vol1 or args.all:
        targets = sorted(glob.glob(os.path.join(REPO_ROOT, "content", "fixtures", "volume_01", "vol01_ch*.json")))
    elif args.input:
        targets = [args.input]
    elif args.dir:
        targets = sorted(glob.glob(os.path.join(args.dir, "*.json")))
    elif not args.manifest:
        parser.print_help()
        sys.exit(1)

    if targets:
        if not os.path.exists(args.schema):
            print(f"Error: Schema not found at {args.schema}", file=sys.stderr)
            sys.exit(1)
        with open(args.schema, "r", encoding="utf-8") as f:
            pkg_schema = json.load(f)
        pkg_val = jsonschema.Draft202012Validator(pkg_schema)

        print(f"\nValidating {len(targets)} package file(s) against {os.path.basename(args.schema)}...")
        for target in targets:
            errors = validate_file(target, pkg_val)
            if errors:
                failed += 1
                print(f"  ✗ INVALID: {target}")
                for err in errors:
                    print(f"      - {err}")
            else:
                print(f"  ✓ VALID: {target}")

    if failed > 0:
        print(f"\nValidation failed ({failed} invalid item(s)).")
        sys.exit(1)
    else:
        print("\nAll target(s) passed validation successfully.")
        sys.exit(0)

if __name__ == "__main__":
    main()
