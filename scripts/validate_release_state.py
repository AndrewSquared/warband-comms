from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from zipfile import ZipFile


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate WarbandComms release state and packaged zip structure."
    )
    parser.add_argument(
        "--repo-root",
        default=str(Path(__file__).resolve().parent.parent),
        help="Repository root path. Defaults to project root.",
    )
    parser.add_argument(
        "--tag",
        default=None,
        help="Optional release tag to validate against (for example: v3.6.1).",
    )
    parser.add_argument(
        "--build",
        choices=["release", "test"],
        default=None,
        help="Build type associated with --zip for content validation rules.",
    )
    parser.add_argument(
        "--zip",
        dest="zip_path",
        default=None,
        help="Optional path to a built zip artifact to validate.",
    )
    return parser.parse_args()


def load_mod_metadata(mod_path: Path) -> tuple[str, str]:
    tree = ET.parse(mod_path)
    root = tree.getroot()
    ui_mod = root.find("UiMod")
    if ui_mod is None:
        raise RuntimeError("Unable to find UiMod in WarbandComms.mod")

    addon_name = (ui_mod.get("name") or "").strip()
    addon_version = (ui_mod.get("version") or "").strip()
    if not addon_name:
        raise RuntimeError("UiMod name missing in WarbandComms.mod")
    if not addon_version:
        raise RuntimeError("UiMod version missing in WarbandComms.mod")
    return addon_name, addon_version


def load_lua_version(lua_path: Path) -> str:
    content = lua_path.read_text(encoding="utf-8")
    match = re.search(r'local\s+version\s*=\s*"([^"]+)"', content)
    if not match:
        raise RuntimeError("Could not find local version declaration in WarbandComms.lua")
    return match.group(1).strip()


def validate_tag_matches_version(tag: str | None, version: str) -> None:
    if tag is None:
        return
    normalized = tag.strip()
    if normalized.startswith("refs/tags/"):
        normalized = normalized.split("/", 2)[-1]
    if normalized.startswith("v"):
        normalized = normalized[1:]
    if normalized != version:
        raise RuntimeError(f"Tag version mismatch: tag={tag}, WarbandComms.mod={version}")


def validate_changelog_has_version(changelog_path: Path, version: str) -> None:
    content = changelog_path.read_text(encoding="utf-8")
    lines = [line.strip() for line in content.splitlines() if line.strip()]
    if not lines:
        raise RuntimeError("changelog.md is empty")

    expected_prefix = f"{version} ("
    if not lines[0].startswith(expected_prefix):
        raise RuntimeError(
            f"changelog.md top entry must start with '{expected_prefix}' but was '{lines[0]}'"
        )


def validate_zip_contents(zip_path: Path, addon_name: str, build: str) -> None:
    if not zip_path.exists():
        raise RuntimeError(f"Zip file not found: {zip_path}")

    with ZipFile(zip_path, "r") as archive:
        names = archive.namelist()
        if not names:
            raise RuntimeError("Zip file is empty")

        prefixes = {name.split("/", 1)[0] for name in names if "/" in name}
        if prefixes != {addon_name}:
            raise RuntimeError(
                f"Zip must contain one top-level folder named '{addon_name}', found: {sorted(prefixes)}"
            )

        required = {
            f"{addon_name}/WarbandComms.mod",
            f"{addon_name}/WarbandComms.lua",
            f"{addon_name}/README.md",
            f"{addon_name}/LICENSE",
        }
        missing = sorted(required.difference(names))
        if missing:
            raise RuntimeError(f"Zip missing required files: {missing}")

        tests_path = f"{addon_name}/tests.lua"
        slash_path = f"{addon_name}/slash.lua"

        slash_content = archive.read(slash_path).decode("utf-8")
        test_markers = [
            'command == "testboxes"',
            'command == "testcenter"',
            'command == "selftest"',
        ]

        if build == "release":
            if tests_path in names:
                raise RuntimeError("Release zip must not include tests.lua")
            if any(marker in slash_content for marker in test_markers):
                raise RuntimeError("Release zip slash.lua still contains test-only command handlers")
        else:
            if tests_path not in names:
                raise RuntimeError("Test zip must include tests.lua")
            if not any(marker in slash_content for marker in test_markers):
                raise RuntimeError("Test zip slash.lua must include test command handlers")


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()

    mod_path = repo_root / "WarbandComms.mod"
    lua_path = repo_root / "WarbandComms.lua"
    changelog_path = repo_root / "changelog.md"

    try:
        addon_name, mod_version = load_mod_metadata(mod_path)
        lua_version = load_lua_version(lua_path)
        if lua_version != mod_version:
            raise RuntimeError(
                f"Version mismatch: WarbandComms.mod={mod_version}, WarbandComms.lua={lua_version}"
            )

        validate_tag_matches_version(args.tag, mod_version)
        validate_changelog_has_version(changelog_path, mod_version)

        if args.zip_path:
            if not args.build:
                raise RuntimeError("--build is required when --zip is provided")
            validate_zip_contents(Path(args.zip_path), addon_name, args.build)

    except Exception as exc:
        print(f"Validation failed: {exc}", file=sys.stderr)
        return 1

    print("Validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())