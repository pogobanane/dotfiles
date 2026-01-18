#!/usr/bin/env python3
import subprocess
import json
from datetime import datetime
from pathlib import Path

CACHE_DIR = Path(__file__).parent / "history"


def main():
    # Run main.py
    script_dir = Path(__file__).parent
    subprocess.run(["python3", script_dir / "main.py"], check=True)

    # Load new JSON
    with open("/tmp/deadlines.json") as f:
        new_data = json.load(f)

    # Save with date filename
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    today = datetime.now().strftime("%Y-%m-%d")
    new_path = CACHE_DIR / f"{today}.json"
    with open(new_path, "w") as f:
        json.dump(new_data, f, indent=2)

    # Find previous JSON
    jsons = sorted(CACHE_DIR.glob("*.json"))
    if len(jsons) < 2:
        print("No previous data to compare")
        return

    prev_path = jsons[-2]  # second to last
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
