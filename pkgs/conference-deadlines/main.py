#!/usr/bin/env python3
import subprocess
import json
import shlex
import sys
from datetime import datetime
from urllib.parse import urlparse

def CONFERENCES(year: int):
    return {
        "SIGCOMM": f"https://conferences.sigcomm.org/sigcomm/{year}/cfp/",
        "EuroSys": f"https://{year}.eurosys.org/cfp.html#calls",
    }

SINGLE_DEADLINE_SCHEMA = json.dumps({
    "type": "object",
    "properties": {
        "date": {
            "type": "string",
            "description": "ISO 8601 date, e.g. 2026-01-30"
        },
        "time": {
            "type": "string",
            "description": "Time as HH:MM:SS, e.g. 23:59:59"
        },
        "timezone": {
            "type": "string",
            "description": "Timezone as stated on website, e.g. AoE, PST, UTC"
        },
        "utc_offset": {
            "type": "integer",
            "description": "Timezone offset from UTC in hours, e.g. -12 for AoE, -8 for PST, 0 for UTC"
        },
        "raw_string": {
            "type": "string",
            "description": "Exact quote from website containing the deadline type and date, e.g. 'Abstract registration: Friday, January 30, 2026 AoE'"
        }
    },
    "required": ["date", "time", "timezone", "utc_offset", "raw_string"]
})

OTHER_DEADLINES_SCHEMA = json.dumps({
    "type": "object",
    "properties": {
        "deadlines": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "date": {
                        "type": "string",
                        "description": "ISO 8601 date, e.g. 2026-01-30"
                    },
                    "time": {
                        "type": "string",
                        "description": "Time as HH:MM:SS, e.g. 23:59:59"
                    },
                    "timezone": {
                        "type": "string",
                        "description": "Timezone as stated on website, e.g. AoE, PST, UTC"
                    },
                    "utc_offset": {
                        "type": "integer",
                        "description": "Timezone offset from UTC in hours, e.g. -12 for AoE, -8 for PST, 0 for UTC"
                    },
                    "raw_string": {
                        "type": "string",
                        "description": "Exact quote from website containing the deadline type and date, e.g. 'Abstract registration: Friday, January 30, 2026 AoE'"
                    }
                },
                "required": ["date", "time", "timezone", "utc_offset", "raw_string"]
            }
        }
    },
    "required": ["deadlines"]
})


class ClaudeQueryError(Exception):
    """Raised when a Claude query fails to return expected output."""
    pass


def validate_deadline(item: dict) -> str | None:
    """Validate a deadline item. Returns error message or None if valid."""
    # Validate date (ISO 8601: YYYY-MM-DD)
    try:
        datetime.strptime(item["date"], "%Y-%m-%d")
    except (ValueError, KeyError) as e:
        return f"Invalid date '{item.get('date')}': {e}"

    # Validate time (HH:MM:SS)
    try:
        datetime.strptime(item["time"], "%H:%M:%S")
    except (ValueError, KeyError) as e:
        return f"Invalid time '{item.get('time')}': {e}"

    # Validate utc_offset (-12 to +14)
    utc_offset = item.get("utc_offset")
    if not isinstance(utc_offset, int):
        return f"utc_offset must be int, got {type(utc_offset).__name__}"
    if not (-12 <= utc_offset <= 14):
        return f"utc_offset {utc_offset} out of range [-12, +14]"

    return None


def run_claude(
    prompt: str,
    schema: str = None,
    allowed_tools: str = None,
    session_id: str = None,
) -> dict:
    """Run claude and return parsed JSON output."""
    cmd = [
        "claude",
        "-p", prompt,
        "--output-format", "json",
    ]
    if schema:
        cmd.extend(["--json-schema", schema])
    if allowed_tools:
        cmd.extend(["--allowedTools", allowed_tools])
    if session_id:
        cmd.extend(["--resume", session_id])

    # print(shlex.join(cmd), file=sys.stderr)
    # print(file=sys.stderr)

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True,
    )

    return json.loads(result.stdout)


def fetch_deadlines(conference: str, year: int) -> dict:
    """Fetch and extract deadlines for a conference.

    Returns:
        {
            "submission_deadline": {
                "date": "YYYY-MM-DD",
                "time": "HH:MM:SS",
                "timezone": "AoE",
                "utc_offset": -12,
                "raw_string": "...",
                "valid": true
            },
            "other_deadlines": [
                { ...same structure... }
            ]
        }
    """
    url = CONFERENCES(year).get(conference)

    domain = urlparse(url).netloc

    print(f"Checking {conference}")
    print(f"  {url}")

    # Step 1: Fetch the URL content
    print("  Fetching website content...", file=sys.stderr)
    fetch_output = run_claude(
        prompt=f"Fetch {url} and summarize the page content",
        allowed_tools=f"WebFetch(domain:{domain})",
    )
    session_id = fetch_output.get("session_id")
    if not session_id:
        raise ClaudeQueryError("No session_id returned from fetch")

    page_content = fetch_output.get("result", "")
    if not page_content:
        raise ClaudeQueryError("Failed to fetch page content")

    # Step 2: Extract submission deadline (using session to maintain context)
    print("  Extracting submission deadline...", file=sys.stderr)
    submission_output = run_claude(
        prompt="Extract the paper submission deadline from the page you just fetched",
        schema=SINGLE_DEADLINE_SCHEMA,
        session_id=session_id,
    )
    submission_deadline = submission_output.get("structured_output")
    if not submission_deadline:
        raise ClaudeQueryError(
            f"No submission deadline found. Response: {submission_output.get('result', '')[:500]}"
        )

    # Step 3: Extract other deadlines (continuing session)
    print("  Extracting other deadlines...", file=sys.stderr)
    all_output = run_claude(
        prompt="Extract all deadlines from the same page",
        schema=OTHER_DEADLINES_SCHEMA,
        session_id=session_id,
    )
    all_deadlines = all_output.get("structured_output", {}).get("deadlines", [])

    # Step 4: Validate and remove submission deadline from all_deadlines
    print("  Validating results...", file=sys.stderr)
    matches = lambda d: (d["date"], d["time"]) == (submission_deadline["date"], submission_deadline["time"])

    if not any(matches(d) for d in all_deadlines):
        raise ClaudeQueryError(
            f"Submission deadline ({submission_deadline['date']}, {submission_deadline['time']}) not found in all_deadlines"
        )

    # Step 5: Validate all items and add valid flag
    def add_valid_flag(item: dict) -> dict:
        return {**item, "valid": validate_deadline(item) is None}

    return {
        "submission_deadline": add_valid_flag(submission_deadline),
        "other_deadlines": [add_valid_flag(d) for d in all_deadlines if not matches(d)],
    }


def print_deadline_table(results: dict):
    """Sort conferences by submission deadline and print as table."""
    valid = {k: v for k, v in results.items() if v["submission_deadline"]["valid"]}
    invalid = [k for k, v in results.items() if not v["submission_deadline"]["valid"]]

    if invalid:
        print(f"Invalid: {', '.join(invalid)}")
        print()

    rows = [
        (conf, data["submission_deadline"]["date"])
        for conf, data in valid.items()
    ]
    rows.sort(key=lambda r: r[1])

    # Header
    print(f"{'Month':<10} {'Conference':<15} {'Date':<12}")
    print("-" * 40)

    # Rows
    for conf, date in rows:
        month = date[:7]  # YYYY-MM
        print(f"{month:<10} {conf:<15} {date:<12}")


def main():
    results = {}
    for year in [2025, 2026]:
        year_suffix = f"'{year % 100:02d}"
        for conf in CONFERENCES(year):
            results[f"{conf}{year_suffix}"] = fetch_deadlines(conf, year)
    print_deadline_table(results)


if __name__ == "__main__":
    main()
