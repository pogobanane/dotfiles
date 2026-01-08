#!/usr/bin/env python3
import subprocess
import json
import shlex
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
from urllib.parse import urlparse

FROM_YEAR=2025
NOW=2026

# List of (name, year, url) tuples
CONFERENCES = [
    *[("SIGCOMM", y, f"https://conferences.sigcomm.org/sigcomm/{y}/cfp/") for y in range(2024, NOW+1)],
    *[("EuroSys", y, f"https://{y}.eurosys.org/cfp.html#calls") for y in range(2025, NOW+1)],
    *[("NSDI", y, f"https://www.usenix.org/conference/nsdi{y % 100:02d}/call-for-papers") for y in range(2012, NOW+1)],
    *[("CoNEXT", y, f"https://conferences2.sigcomm.org/co-next/{y}/#!/cfp") for y in range(2012, NOW+1)],
    *[("SoCC", y, f"https://acmsocc.org/{y}/papers.html") for y in range(2015, NOW+1)],
    *[("SOSP", y, f"https://sigops.org/s/conferences/sosp/{y}/cfp.html") for y in range(2024, NOW+1)],
    *[("HotOS", y, f"https://sigops.org/s/conferences/hotos/{y}/cfp.html") for y in range(2023, NOW+1)],
    *[("ASPLOS", y, f"https://www.asplos-conference.org/asplos{y}/cfp/") for y in range(2024, NOW+1)],
    *[("FAST", y, f"https://www.usenix.org/conference/fast{y % 100:02d}/call-for-papers") for y in range(2013, NOW+1)],
    *[("NDSS", y, f"https://www.ndss-symposium.org/ndss{y}/submissions/call-for-papers/") for y in range(2017, NOW+1)],
    *[("Middleware", y, f"https://middleware-conf.github.io/{y}/calls/call-for-research-papers/") for y in range(2023, NOW+1)],
    *[("APSys", y, f"https://apsys{y}.github.io/call_for_papers.html") for y in [2025]],
    # APSys needs new links
    *[("HotNets", y, f"https://conferences.sigcomm.org/hotnets/{y}/cfp.html") for y in range(2005, NOW+1)],
    *[("ATC", y, f"https://www.usenix.org/conference/atc{y % 100:02d}/call-for-papers") for y in range(2013, NOW+1)],
    *[("OSDI", y, f"https://www.usenix.org/conference/osdi{y % 100:02d}/call-for-papers") for y in range(2018, NOW+1)],
]


def conf_label(name: str, year: int) -> str:
    """Generate display label like SIGCOMM'26."""
    return f"{name}'{year % 100:02d}"

CYCLES_SCHEMA = json.dumps({
    "type": "object",
    "properties": {
        "cycles": {
            "type": "array",
            "items": {"type": "string"},
            "description": "List of submission cycle labels, e.g. ['Spring', 'Fall'] or [''] for single cycle"
        }
    },
    "required": ["cycles"]
})

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


def fetch_deadlines(name: str, url: str) -> dict:
    """Fetch and extract deadlines for a conference.

    Args:
        name: Display name like "SIGCOMM'26"
        url: CFP page URL

    Returns:
        {
            "cycles": ["Spring", "Fall"],
            "deadlines": [
                {
                    "cycle": "Spring",
                    "deadline_type": "submission",  # "submission" | "unknown"
                    "date": "YYYY-MM-DD",
                    "time": "HH:MM:SS",
                    "timezone": "AoE",
                    "utc_offset": -12,
                    "raw_string": "...",
                    "valid": true
                },
                ...
            ]
        }
    """
    domain = urlparse(url).netloc

    print(f"  {name}: {url}")

    # Step 1: Fetch the URL content
    print(f"  {name}: Fetching website content...", file=sys.stderr)
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

    # Step 1.5: Extract submission cycles
    print(f"  {name}: Extracting submission cycles...", file=sys.stderr)
    cycles_output = run_claude(
        prompt="What submission/review cycles does this conference have? E.g. Spring/Fall, Round 1/2/3, or just a single cycle. Return cycle labels as array.",
        schema=CYCLES_SCHEMA,
        session_id=session_id,
    )
    cycles = cycles_output.get("structured_output", {}).get("cycles", [""])
    if not cycles:
        cycles = [""]

    # Step 2: Extract submission deadline for each cycle
    print(f"  {name}: Extracting submission deadlines...", file=sys.stderr)
    submission_deadlines = []
    for cycle in cycles:
        cycle_prompt = f"Extract the paper submission deadline for the {cycle} cycle" if cycle else "Extract the paper submission deadline"
        sub_output = run_claude(
            prompt=cycle_prompt,
            schema=SINGLE_DEADLINE_SCHEMA,
            session_id=session_id,
        )
        sub_deadline = sub_output.get("structured_output")
        if sub_deadline:
            submission_deadlines.append({
                **sub_deadline,
                "cycle": cycle,
                "deadline_type": "submission",
            })

    if not submission_deadlines:
        raise ClaudeQueryError("No submission deadlines found")

    # Step 3: Extract all deadlines for each cycle
    print(f"  {name}: Extracting all deadlines...", file=sys.stderr)
    all_deadlines = []
    for cycle in cycles:
        cycle_prompt = f"Extract all deadlines for the {cycle} cycle" if cycle else "Extract all deadlines"
        all_output = run_claude(
            prompt=cycle_prompt,
            schema=OTHER_DEADLINES_SCHEMA,
            session_id=session_id,
        )
        cycle_deadlines = all_output.get("structured_output", {}).get("deadlines", [])
        for d in cycle_deadlines:
            all_deadlines.append({**d, "cycle": cycle, "deadline_type": "unknown"})

    # Step 4: Merge - replace matching entries with submission deadlines
    print(f"  {name}: Validating results...", file=sys.stderr)
    for sub in submission_deadlines:
        sub_key = (sub["date"], sub["time"])
        found = False
        for i, d in enumerate(all_deadlines):
            if (d["date"], d["time"]) == sub_key:
                all_deadlines[i] = sub
                found = True
                break
        if not found:
            raise ClaudeQueryError(
                f"Submission deadline ({sub['date']}, {sub['time']}) not found in all_deadlines"
            )

    # Step 5: Validate all items and add valid flag
    def add_valid_flag(item: dict) -> dict:
        return {**item, "valid": validate_deadline(item) is None}

    return {
        "cycles": cycles,
        "deadlines": [add_valid_flag(d) for d in all_deadlines],
    }


def print_deadline_table(results: dict):
    """Sort conferences by submission deadline and print as table."""
    # Flatten: (conf_name, cycle, deadline) for each submission deadline
    rows = []
    invalid = []

    for conf, data in results.items():
        submission_deadlines = [
            d for d in data["deadlines"]
            if d["deadline_type"] == "submission"
        ]
        for d in submission_deadlines:
            if d["valid"]:
                # Add cycle suffix if multiple cycles
                label = f"{conf} ({d['cycle']})" if d["cycle"] else conf
                rows.append((label, d["date"]))
            else:
                invalid.append(conf)

    if invalid:
        print(f"Invalid: {', '.join(set(invalid))}")
        print()

    rows.sort(key=lambda r: r[1])

    # Header
    print(f"{'Month':<10} {'Conference':<25} {'Deadline':<12}")
    print("-" * 45)

    # Rows
    for conf, date in rows:
        month = date[:7]  # YYYY-MM
        print(f"{month:<10} {conf:<25} {date:<12}")


def main():
    results = {}
    with ThreadPoolExecutor() as executor:
        futures = {
            executor.submit(fetch_deadlines, conf_label(name, year), url): conf_label(name, year)
            for name, year, url in CONFERENCES
            if year >= FROM_YEAR
        }
        for future in as_completed(futures):
            label = futures[future]
            try:
                results[label] = future.result()
            except Exception as e:
                print(f"Error fetching {label}: {e}", file=sys.stderr)

    print_deadline_table(results)


if __name__ == "__main__":
    main()
