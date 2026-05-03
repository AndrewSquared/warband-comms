from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


VERSION_HEADER_RE = re.compile(r"^\s*\d+\.\d+(?:\.\d+)?\s*\(.*\)\s*$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract the latest changelog section into a standalone markdown file."
    )
    parser.add_argument(
        "--input",
        default="changelog.md",
        help="Path to changelog markdown file.",
    )
    parser.add_argument(
        "--output",
        default="release_notes.md",
        help="Output markdown file path.",
    )
    return parser.parse_args()


def extract_latest_section(lines: list[str]) -> str:
    start_index = None
    for index, line in enumerate(lines):
        if line.strip():
            start_index = index
            break

    if start_index is None:
        raise RuntimeError("changelog is empty")

    end_index = len(lines)
    for index in range(start_index + 1, len(lines)):
        if VERSION_HEADER_RE.match(lines[index].strip()):
            end_index = index
            break

    extracted = "\n".join(lines[start_index:end_index]).strip()
    if not extracted:
        raise RuntimeError("failed to extract latest changelog section")
    return extracted + "\n"


def main() -> int:
    args = parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)

    try:
        lines = input_path.read_text(encoding="utf-8").splitlines()
        latest = extract_latest_section(lines)
        output_path.write_text(latest, encoding="utf-8")
    except Exception as exc:
        print(f"Extraction failed: {exc}", file=sys.stderr)
        return 1

    print(f"Wrote latest changelog section to {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())