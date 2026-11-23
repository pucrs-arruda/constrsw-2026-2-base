#!/usr/bin/env python3
"""Extract BFF + domain OpenAPI inventory for UX spines."""
from __future__ import annotations

import re
from pathlib import Path

try:
    import yaml
except ImportError:
    raise SystemExit("PyYAML required")

ROOT = Path("docs/open-api")


def load(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def ops(doc: dict):
    for path, methods in sorted((doc.get("paths") or {}).items()):
        for method, op in (methods or {}).items():
            if method.startswith("x-") or not isinstance(op, dict):
                continue
            yield method.upper(), path, op


def main() -> None:
    bff = load(ROOT / "bff.yaml")
    print("=== BFF ===")
    print("title:", (bff.get("info") or {}).get("title"))
    print("tags:", [t.get("name") for t in bff.get("tags") or []])
    for method, path, op in ops(bff):
        tags = op.get("tags") or []
        summary = op.get("summary") or op.get("operationId") or ""
        print(f"{method:6} {path}  tags={tags}  :: {summary}")

    text = (ROOT / "bff.yaml").read_text(encoding="utf-8")
    refs = sorted(set(re.findall(r"\$ref:\s*['\"]?([^'\"\s]+)", text)))
    print("\n=== EXTERNAL REFS IN BFF ===")
    for r in refs:
        if ".yaml" in r or "open-api" in r or r.startswith("./") or r.startswith("../"):
            print(r)

    print("\n=== DOMAIN SECONDARIES (1-N) ===")
    for yaml_path in sorted(ROOT.glob("*.yaml")):
        if yaml_path.name == "bff.yaml":
            continue
        doc = load(yaml_path)
        print(f"\n--- {yaml_path.name} ---")
        for method, path, op in ops(doc):
            tags = op.get("tags") or []
            summary = op.get("summary") or op.get("operationId") or ""
            print(f"{method:6} {path}  tags={tags}  :: {summary}")


if __name__ == "__main__":
    main()
