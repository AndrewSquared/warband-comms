from __future__ import annotations

import argparse
import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

BUILD_RELEASE = "release"
BUILD_TEST = "test"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a distributable WarbandComms addon zip from WarbandComms.mod."
    )
    parser.add_argument(
        "--build",
        choices=[BUILD_RELEASE, BUILD_TEST],
        default=BUILD_RELEASE,
        help="Build type to package. 'release' strips test-only runtime hooks, 'test' keeps them.",
    )
    parser.add_argument(
        "--output-dir",
        default="dist",
        help="Directory for the generated zip file. Defaults to ./dist",
    )
    parser.add_argument(
        "--no-readme",
        action="store_false",
        dest="include_readme",
        help="Do not include README.md in the packaged addon folder.",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Remove the output directory before packaging.",
    )
    parser.set_defaults(include_readme=True)
    return parser.parse_args()


def load_manifest(mod_path: Path) -> tuple[str, str, list[str]]:
    tree = ET.parse(mod_path)
    root = tree.getroot()
    ui_mod = root.find("UiMod")
    if ui_mod is None:
        raise RuntimeError("Unable to find UiMod in WarbandComms.mod")

    addon_name = (ui_mod.get("name") or "").strip()
    addon_version = (ui_mod.get("version") or "dev").strip()
    if not addon_name:
        raise RuntimeError("UiMod name is missing from WarbandComms.mod")

    runtime_files = [mod_path.name]
    files_node = ui_mod.find("Files")
    if files_node is not None:
        for file_node in files_node.findall("File"):
            file_name = (file_node.get("name") or "").strip()
            if file_name:
                runtime_files.append(file_name)

    deduped_files: list[str] = []
    seen: set[str] = set()
    for file_name in runtime_files:
        if file_name not in seen:
            seen.add(file_name)
            deduped_files.append(file_name)

    return addon_name, addon_version, deduped_files


def build_release_manifest(mod_path: Path) -> str:
    tree = ET.parse(mod_path)
    root = tree.getroot()
    ui_mod = root.find("UiMod")
    if ui_mod is None:
        raise RuntimeError("Unable to find UiMod in WarbandComms.mod")

    files_node = ui_mod.find("Files")
    if files_node is not None:
        for file_node in list(files_node.findall("File")):
            if (file_node.get("name") or "").strip() == "tests.lua":
                files_node.remove(file_node)

    return ET.tostring(root, encoding="unicode", xml_declaration=True)


def build_release_slash(source_text: str) -> str:
    lines = source_text.splitlines(True)

    testboxes_head = 'elseif command == "testboxes" or command == "test" then'
    testcenter_head = 'elseif command == "testcenter" or command == "test-center" or command == "test center" then'
    selftest_head = 'elseif command == "selftest" then'
    selfcheck_head = 'elseif command == "selfcheck" then'

    def contains(haystack: str, needle: str) -> bool:
        return needle in haystack

    output: list[str] = []
    index = 0
    stripped_any = False

    while index < len(lines):
        line = lines[index]

        # Strip test command handlers
        if contains(line, testboxes_head):
            stripped_any = True
            index += 1
            while index < len(lines) and not contains(lines[index], testcenter_head):
                index += 1
            continue

        if contains(line, testcenter_head):
            stripped_any = True
            index += 1
            while index < len(lines) and not contains(lines[index], selftest_head):
                index += 1
            continue

        if contains(line, selftest_head):
            stripped_any = True
            index += 1
            while index < len(lines) and not contains(lines[index], selfcheck_head):
                index += 1
            continue

        # Strip test command help text lines
        if contains(line, "(test builds)"):
            index += 1
            continue

        output.append(line)
        index += 1

    if not stripped_any:
        raise RuntimeError("slash.lua did not match any expected test command blocks for release packaging")

    return "".join(output)


def get_runtime_files(runtime_files: list[str], build_type: str, include_readme: bool) -> list[str]:
    packaged_files = list(runtime_files)
    if build_type == BUILD_RELEASE:
        packaged_files = [file_name for file_name in packaged_files if file_name != "tests.lua"]
    if include_readme:
        packaged_files.append("README.md")

    deduped_files: list[str] = []
    seen: set[str] = set()
    for file_name in packaged_files:
        if file_name not in seen:
            seen.add(file_name)
            deduped_files.append(file_name)
    return deduped_files


def dedupe_file_list(file_names: list[str]) -> list[str]:
    deduped_files: list[str] = []
    seen: set[str] = set()
    for file_name in file_names:
        if file_name not in seen:
            seen.add(file_name)
            deduped_files.append(file_name)
    return deduped_files


def get_license_files(repo_root: Path) -> list[str]:
    license_files: list[str] = []
    for candidate in sorted(repo_root.glob("LICENSE*")):
        if candidate.is_file():
            license_files.append(candidate.name)
    return license_files


def get_zip_name(addon_name: str, addon_version: str, build_type: str) -> str:
    if build_type == BUILD_TEST:
        return f"{addon_name}-v{addon_version}-test.zip"
    return f"{addon_name}-v{addon_version}.zip"


def build_release(
    repo_root: Path,
    output_dir: Path,
    include_readme: bool,
    clean: bool,
    build_type: str,
) -> Path:
    mod_path = repo_root / "WarbandComms.mod"
    if not mod_path.exists():
        raise RuntimeError(f"WarbandComms.mod not found at {mod_path}")

    addon_name, addon_version, runtime_files = load_manifest(mod_path)
    runtime_files = get_runtime_files(runtime_files, build_type, include_readme)
    runtime_files = dedupe_file_list(runtime_files + get_license_files(repo_root))

    output_dir = output_dir if output_dir.is_absolute() else repo_root / output_dir
    if clean and output_dir.exists():
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    zip_path = output_dir / get_zip_name(addon_name, addon_version, build_type)
    if zip_path.exists():
        zip_path.unlink()

    with ZipFile(zip_path, "w", compression=ZIP_DEFLATED) as archive:
        for relative_name in runtime_files:
            source_path = repo_root / relative_name
            if not source_path.exists():
                raise RuntimeError(f"Runtime file listed for packaging was not found: {relative_name}")

            archive_name = str(Path(addon_name) / relative_name).replace("\\", "/")
            if build_type == BUILD_RELEASE and relative_name == "WarbandComms.mod":
                archive.writestr(archive_name, build_release_manifest(source_path))
            elif build_type == BUILD_RELEASE and relative_name == "slash.lua":
                archive.writestr(archive_name, build_release_slash(source_path.read_text(encoding="utf-8")))
            else:
                archive.write(source_path, archive_name)

    return zip_path


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parent.parent

    try:
        zip_path = build_release(
            repo_root=repo_root,
            output_dir=Path(args.output_dir),
            include_readme=args.include_readme,
            clean=args.clean,
            build_type=args.build,
        )
    except Exception as exc:
        print(f"Packaging failed: {exc}", file=sys.stderr)
        return 1

    print(f"Created {args.build} package: {zip_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())