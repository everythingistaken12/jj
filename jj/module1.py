from __future__ import annotations

from collections import Counter
from pathlib import Path
from zipfile import ZipFile, BadZipFile
import shutil

ROOT = Path(r"C:\Users\techn\source\repos\jj")
APK_DIR = ROOT / "original" / "apks"
NATIVE_DIR = ROOT / "original" / "native" / "x86_64"
REPORT_DIR = ROOT / "reports"
ASSET_ZIP_OUT = ROOT / "original" / "assets.zip"
REPORT_PATH = REPORT_DIR / "asset_inventory.txt"

INSTALL_APK = APK_DIR / "split_InstallPack.apk"
ABI_APK = APK_DIR / "split_config.x86_64.apk"
ASSET_MEMBER = "assets/assets.zip"


def human_size(size: int) -> str:
    value = float(size)
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if value < 1024 or unit == "TB":
            return f"{value:.2f} {unit}"
        value /= 1024
    return f"{value:.2f} TB"


def extract_member(zip_path: Path, member: str, destination: Path) -> None:
    with ZipFile(zip_path) as zf:
        try:
            info = zf.getinfo(member)
        except KeyError as exc:
            raise SystemExit(f"Missing {member!r} inside {zip_path}") from exc
        destination.parent.mkdir(parents=True, exist_ok=True)
        with zf.open(info) as src, destination.open("wb") as dst:
            shutil.copyfileobj(src, dst, length=1024 * 1024)
        print(f"Extracted {member} -> {destination} ({human_size(info.file_size)})")


def extract_native_libraries(apk_path: Path, destination: Path) -> list[Path]:
    destination.mkdir(parents=True, exist_ok=True)
    output: list[Path] = []
    with ZipFile(apk_path) as zf:
        members = [n for n in zf.namelist() if n.startswith("lib/x86_64/") and n.endswith(".so")]
        if not members:
            print(f"WARNING: no x86_64 .so files found in {apk_path.name}")
        for member in members:
            info = zf.getinfo(member)
            target = destination / Path(member).name
            with zf.open(info) as src, target.open("wb") as dst:
                shutil.copyfileobj(src, dst, length=1024 * 1024)
            output.append(target)
            print(f"Extracted {member} -> {target} ({human_size(info.file_size)})")
    return output


def report_archive(archive_path: Path) -> str:
    lines: list[str] = []
    lines.append(f"ARCHIVE: {archive_path}")
    lines.append(f"Compressed file size: {human_size(archive_path.stat().st_size)}")
    try:
        with ZipFile(archive_path) as zf:
            files = [i for i in zf.infolist() if not i.is_dir()]
            lines.append(f"File entries: {len(files)}")
            lines.append(f"Directories: {sum(i.is_dir() for i in zf.infolist())}")
            lines.append(f"Total uncompressed size: {human_size(sum(i.file_size for i in files))}")
            lines.append("")

            top = Counter(
                i.filename.split("/")[0] if "/" in i.filename else "(root)"
                for i in files
            )
            lines.append("TOP-LEVEL PATHS:")
            for name, count in top.most_common():
                lines.append(f"  {name}: {count}")
            lines.append("")

            ext_counts: Counter[str] = Counter()
            ext_bytes: Counter[str] = Counter()
            for i in files:
                suffix = Path(i.filename).suffix.lower() or "(no extension)"
                ext_counts[suffix] += 1
                ext_bytes[suffix] += i.file_size

            lines.append("FILE TYPES (count, total unpacked size):")
            for ext, count in ext_counts.most_common():
                lines.append(f"  {ext}: {count} files, {human_size(ext_bytes[ext])}")
            lines.append("")

            lines.append("LARGEST 100 FILES (unpacked size):")
            for i in sorted(files, key=lambda x: x.file_size, reverse=True)[:100]:
                ratio = (i.compress_size / i.file_size * 100) if i.file_size else 0.0
                lines.append(
                    f"  {human_size(i.file_size):>12} | {ratio:6.1f}% of original compressed | {i.filename}"
                )
            lines.append("")

            lines.append("FIRST 250 PATHS:")
            for i in sorted(files, key=lambda x: x.filename.lower())[:250]:
                lines.append(f"  {human_size(i.file_size):>12} | {i.filename}")
            lines.append("")

            markers = (
                "vehicle", "power", "coin", "barry", "player", "mission",
                "enemy", "obstacle", "hazard", "animation", "texture",
                "sound", "music", "font", "json", "xml", "plist",
                "sprite", "atlas", "skeleton", "particle", "localization",
            )
            interesting = [
                i for i in files
                if any(m in i.filename.lower() for m in markers)
            ]
            lines.append("PATHS WITH GAME-RELATED WORDS (may include false positives):")
            for i in interesting[:500]:
                lines.append(f"  {human_size(i.file_size):>12} | {i.filename}")
            if len(interesting) > 500:
                lines.append(f"  ... {len(interesting) - 500} additional matching paths omitted")

    except BadZipFile:
        lines.append("ERROR: this file could not be read as a ZIP archive.")

    return "\n".join(lines)


def main() -> None:
    for p in (INSTALL_APK, ABI_APK):
        if not p.exists():
            raise SystemExit(f"Required file not found: {p}\nPut all five APKs in {APK_DIR}")

    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    if not ASSET_ZIP_OUT.exists():
        extract_member(INSTALL_APK, ASSET_MEMBER, ASSET_ZIP_OUT)
    else:
        print(f"Using existing extracted archive: {ASSET_ZIP_OUT}")

    extracted_libs = extract_native_libraries(ABI_APK, NATIVE_DIR)
    print(f"\nNative libraries extracted: {len(extracted_libs)}")

    report = report_archive(ASSET_ZIP_OUT)
    REPORT_PATH.write_text(report, encoding="utf-8")
    print(f"\nAsset inventory written to: {REPORT_PATH}")
    print("\n--- SUMMARY ---")
    print("\n".join(report.splitlines()[:65]))
    print("\nNext: share asset_inventory.txt and, if possible, the filenames in original\\native\\x86_64.")


if __name__ == "__main__":
    main()

