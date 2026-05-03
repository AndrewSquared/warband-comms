#!/usr/bin/env python3
"""Configure repository-managed git hooks for this clone."""

from __future__ import annotations

import subprocess


def main() -> int:
    try:
        subprocess.run(
            ["git", "config", "core.hooksPath", ".githooks"],
            check=True,
        )
    except subprocess.CalledProcessError as exc:
        print(f"Failed to configure hooks: {exc}")
        return 1

    print("Configured git hooks path: .githooks")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
