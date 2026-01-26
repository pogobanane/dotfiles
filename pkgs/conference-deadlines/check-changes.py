#!/usr/bin/env python3
import subprocess
import json
from datetime import datetime
from pathlib import Path

CACHE_DIR = Path(__file__).parent / "history"


def unique_path(path: Path) -> Path:
    """Return path with number suffix if it already exists."""
    if not path.exists():
        return path
    counter = 1
    stem = path.stem
    while (path.parent / f"{stem}-{counter}{path.suffix}").exists():
        counter += 1
    return path.parent / f"{stem}-{counter}{path.suffix}"


def main():
    # Run main.py
    script_dir = Path(__file__).parent
    subprocess.run(["python3", script_dir / "main.py"], check=True)

    # Load new JSON
    with open("/tmp/deadlines.json") as f:
        new_data = json.load(f)

    # Find previous JSON before saving new one
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    jsons = sorted(CACHE_DIR.glob("*.json"))
    prev_path = jsons[-1] if jsons else None

    # Save with date filename
    today = datetime.now().strftime("%Y-%m-%d")
    new_path = unique_path(CACHE_DIR / f"{today}.json")
    with open(new_path, "w") as f:
        json.dump(new_data, f, indent=2)

    if not prev_path:
        print("No previous data to compare")
        return
    with open(prev_path) as f:
        old_data = json.load(f)

    # Compare submission deadlines
    changes = []
    for conf, data in new_data.items():
        old_conf = old_data.get(conf)
        new_subs = [d for d in data["deadlines"] if d["deadline_type"] == "submission"]

        if not old_conf:
            changes.append(f"NEW: {conf}")
            continue

        old_subs = [d for d in old_conf["deadlines"] if d["deadline_type"] == "submission"]

        # Compare dates
        new_dates = {d["date"] for d in new_subs}
        old_dates = {d["date"] for d in old_subs}

        if new_dates != old_dates:
            changes.append(f"CHANGED: {conf}: {old_dates} -> {new_dates}")

    # Check for lost conferences
    for conf in old_data:
        if conf not in new_data:
            changes.append(f"LOST: {conf}")

    if changes:
        print("Submission deadline changes detected:")
        for c in changes:
            print(f"  {c}")
        print("sendtelegram Conference deadlines changed. Updating the list.")
        print("scp to server (set up minimal privilege key")
    else:
        print("No changes")


if __name__ == "__main__":
    main()
