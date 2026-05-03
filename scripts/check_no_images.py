#!/usr/bin/env python3
"""Block image files from source control.

This repository policy keeps development/process screenshots out of git history.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys


IMAGE_PATTERN = re.compile(r"\.(png|jpe?g|gif|webp|bmp|tiff?|ico|svg)$", re.IGNORECASE)


def run_git(args: list[str]) -> list[str]:
    result = subprocess.run(
        ["git", *args],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def main() -> int:
    if os.environ.get("WBC_ALLOW_IMAGE_COMMITS") == "1":
        print("WBC_ALLOW_IMAGE_COMMITS=1 set: image policy check skipped.")
        return 0

    staged = "--staged" in sys.argv[1:]
    mode = "staged" if staged else "tracked"

    git_args = ["diff", "--cached", "--name-only", "--diff-filter=ACMR"] if staged else ["ls-files"]
    files = run_git(git_args)
    matches = [path for path in files if IMAGE_PATTERN.search(path)]

    if matches:
        print("Image files are blocked by repository policy:")
        for path in matches:
            print(path)
        print()
        print("Move development images to .dev-artifacts/ or screenshots/ (ignored).")
        print("If an exception is truly needed, set WBC_ALLOW_IMAGE_COMMITS=1 for that command.")
        return 1

    print(f"Image policy check passed ({mode}).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
