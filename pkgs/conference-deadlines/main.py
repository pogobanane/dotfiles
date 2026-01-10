#!/usr/bin/env python3
import subprocess
import json
import shlex
import sys
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timedelta
from urllib.parse import urlparse

# Optional tqdm for progress bar
try:
    from tqdm import tqdm
    def progress_write(msg):
        tqdm.write(msg, file=sys.stderr)
except ImportError:
    tqdm = None
    def progress_write(msg):
        print(msg, file=sys.stderr)

# Global cost and call tracking
_total_cost = 0.0
_total_calls = 0
_stats_lock = threading.Lock()

# TODO ctrl c doesn't stop it on first try
# TODO ATC has a wrong 2026 entry that breaks the prediction hint
# TODO check correctness of conext eurosy and fast
# TODO add a menu to select and deselect conferences
# TODO remove javascript for hover or improve it.
# TODO understand other deadlines types as well and add gnatt charts [submission, notification]

# Manual predictions from private intelligence, keyed by (name, year, cycle)
# These override automatic predictions
PREDICTION_HINTS = {
    # ("SIGCOMM", 2027, ""): "2027-01-30",
    ("ATC", 2026, "Based on user submitted information"): "2026-06-10"
}

FROM_YEAR=2020
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

    output = json.loads(result.stdout)

    # Track cost and calls
    global _total_cost, _total_calls
    cost = output.get("total_cost_usd", 0.0)

    with _stats_lock:
        _total_cost += cost
        _total_calls += 1

    return output


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

    progress_write(f"  {name}: {url}")

    # Step 1: Fetch the URL content
    progress_write(f"  {name}: Fetching website content...")
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
    progress_write(f"  {name}: Extracting submission cycles...")
    cycles_output = run_claude(
        prompt="What submission/review cycles does this conference have? E.g. Spring/Fall, Round 1/2/3, or just a single cycle. Return cycle labels as array.",
        schema=CYCLES_SCHEMA,
        session_id=session_id,
    )
    cycles = cycles_output.get("structured_output", {}).get("cycles", [""])
    if not cycles:
        cycles = [""]

    # Step 2: Extract submission deadline for each cycle
    progress_write(f"  {name}: Extracting submission deadlines...")
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
    progress_write(f"  {name}: Extracting all deadlines...")
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
    progress_write(f"  {name}: Validating results...")
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


def predict_deadlines(rows: list, target_year: int) -> list:
    """Predict deadlines for target_year based on historical patterns.

    Uses cycle-aware prediction: only considers the consecutive block of years
    (going backwards from latest) that have the same cycle setup as the latest year.

    Args:
        rows: list of (name, year, cycle, date, predicted, json_data, url) tuples
        target_year: year to predict for

    Returns list of (name, year, cycle, date, predicted=True, json_data=None, url="") tuples.
    """
    from collections import defaultdict

    # Group by conference name -> year -> list of (cycle, date)
    by_conf = defaultdict(lambda: defaultdict(list))
    for name, year, cycle, date, _, *_ in rows:
        by_conf[name][year].append((cycle, date))

    predictions = []
    for name, year_data in by_conf.items():
        years_present = set(year_data.keys())
        if target_year in years_present:
            continue  # Already have data for target year

        # Filter to years with valid submission deadlines only
        # A valid deadline should be within 2 years before the conference year
        def is_valid_entry(conf_year, date_str):
            if not date_str:
                return False
            try:
                deadline_year = int(date_str[:4])
                return conf_year - 2 <= deadline_year <= conf_year
            except (ValueError, IndexError):
                return False

        valid_year_data = {
            y: [(c, d) for c, d in entries if is_valid_entry(y, d)]
            for y, entries in year_data.items()
        }
        valid_year_data = {y: entries for y, entries in valid_year_data.items() if entries}

        if not valid_year_data:
            continue

        # Get latest valid year and its cycle setup
        latest_year = max(valid_year_data.keys())
        latest_cycles = frozenset(c for c, _ in valid_year_data[latest_year])

        # Find block of years with same cycle setup (going backwards, ignoring gaps)
        valid_years = []
        other_cycle_years = []  # Years with different cycle setup
        found_mismatch = False
        for y in sorted(valid_year_data.keys(), reverse=True):
            year_cycles = frozenset(c for c, _ in valid_year_data[y])
            if year_cycles != latest_cycles:
                found_mismatch = True
            if found_mismatch:
                other_cycle_years.append(y)
            else:
                valid_years.append(y)

        if not valid_years:
            continue

        # Collect other cycle deadlines for tooltip
        other_cycle_history = []
        for y in other_cycle_years:
            for c, d in valid_year_data[y]:
                label = f"{conf_label(name, y)}"
                if c:
                    label += f" ({c})"
                other_cycle_history.append(f"{label}: {d}")

        # For each cycle in latest setup, predict using most recent valid year
        for cycle in latest_cycles:
            # Check for manual hint first
            hint_key = (name, target_year, cycle)
            if hint_key in PREDICTION_HINTS:
                predictions.append((name, target_year, cycle, PREDICTION_HINTS[hint_key], True, {"user_provided": True}, ""))
                continue

            # Collect all dates for this cycle from valid years
            cycle_dates = []
            history = []
            for y in valid_years:
                for c, d in valid_year_data[y]:
                    if c == cycle:
                        try:
                            dt = datetime.strptime(d, "%Y-%m-%d")
                            # Calculate days from start of conference year
                            conf_year_start = datetime(y, 1, 1)
                            days_offset = (dt - conf_year_start).days
                            cycle_dates.append(days_offset)
                            history.append(f"{conf_label(name, y)}: {d}")
                        except ValueError:
                            pass

            if not cycle_dates:
                continue

            # Average the day offsets and apply to target year
            avg_days = sum(cycle_dates) // len(cycle_dates)
            max_dev = max(abs(d - avg_days) for d in cycle_dates)
            try:
                predicted_dt = datetime(target_year, 1, 1) + timedelta(days=avg_days)
                predicted_date = predicted_dt.strftime("%Y-%m-%d")
                pred_info = {
                    "history": "\n".join(sorted(history)),
                    "other_cycles": "\n".join(sorted(other_cycle_history)) if other_cycle_history else "",
                    "max_dev": max_dev,
                    "count": len(cycle_dates),
                }
                predictions.append((name, target_year, cycle, predicted_date, True, pred_info, ""))
            except ValueError:
                pass  # Skip if date is invalid

    return predictions


def write_html_table(results: dict, filepath: str):
    """Write deadline table as HTML file."""

    # Flatten: (name, year, cycle, date, predicted, deadline_json, url) for each submission deadline
    rows = []
    for conf, data in results.items():
        name = data["name"]
        year = data["year"]
        url = data.get("url", "")

        submission_deadlines = [
            d for d in data["deadlines"]
            if d["deadline_type"] == "submission" and d["valid"]
        ]
        for d in submission_deadlines:
            rows.append((name, year, d["cycle"], d["date"], False, d, url))

    # Add predictions for NOW and NOW+1 years
    predictions = predict_deadlines(rows, NOW)
    rows.extend(predictions)
    predictions_next = predict_deadlines(rows, NOW + 1)
    # Only include next year's predictions if deadline falls in current year
    rows.extend(p for p in predictions_next if p[3].startswith(str(NOW)))

    # Apply prediction hints as overrides (replace existing rows or add new ones)
    for (hint_name, hint_year, hint_cycle), hint_date in PREDICTION_HINTS.items():
        # Remove any existing row for this (name, year, cycle)
        rows = [r for r in rows if not (r[0] == hint_name and r[1] == hint_year and r[2] == hint_cycle)]
        # Add the hint row
        rows.append((hint_name, hint_year, hint_cycle, hint_date, True, None, ""))

    rows.sort(key=lambda r: r[3])  # Sort by date

    now = datetime.now().strftime("%Y-%m-%d")
    html = f"""<!DOCTYPE html>
<html>
<head>
    <title>Conference Deadlines</title>
    <style>
        body {{ max-width: 60em; margin: 0 auto; padding: 20px; font-family: sans-serif; }}
        table {{ border-collapse: collapse; width: 100%; margin-bottom: 2em; }}
        th, td {{ border: 1px solid #ccc; padding: 8px; text-align: left; vertical-align: top; }}
        th {{ background: #f0f0f0; }}
        .predicted {{ font-style: italic; color: #666; }}
    </style>
</head>
<body>
    <h1>Conference Deadlines</h1>
    <p>
        Last updated: {now}<br>
        Deadline predictions are in gray.<br>
        Hover the conference name for more info.<br>
    </p>
"""
    # Group by deadline year (descending), then by month
    years = {}
    for row in rows:
        y = row[3][:4]  # year from deadline date
        years.setdefault(y, []).append(row)
    for year in sorted(years.keys(), reverse=True):
        year_rows = years[year]
        html += f"    <h2>{year}</h2>\n"
        html += """    <table>
        <tr><th>Month</th><th>Conference</th><th>Deadline</th></tr>
"""
        # Group rows by month
        rows_by_month = {}
        for row in year_rows:
            month = row[3][:7]
            rows_by_month.setdefault(month, []).append(row)

        # Iterate through all 12 months
        for m in range(1, 13):
            month = f"{year}-{m:02d}"
            month_name = datetime.strptime(month, "%Y-%m").strftime("%B")
            group_rows = rows_by_month.get(month, [])
            if not group_rows:
                html += f'        <tr><td>{month_name}</td><td></td><td></td></tr>\n'
                continue
            for i, (name, yr, cycle, date, predicted, json_data, url) in enumerate(group_rows):
                label = conf_label(name, yr)
                if cycle:
                    label += f" ({cycle})"
                cls = ' class="predicted"' if predicted else ""
                if url:
                    label_html = f'<a href="{url}">{label}</a>'
                else:
                    label_html = label
                if isinstance(json_data, dict) and json_data.get("user_provided"):
                    tooltip = "User provided"
                    date_display = f"{date} (user provided)"
                elif isinstance(json_data, dict) and "history" in json_data:
                    tooltip = json_data["history"]
                    if json_data.get("other_cycles"):
                        tooltip += "\n\nOlder deadlines with other submission cycle:\n" + json_data["other_cycles"]
                    warn = "⚠ " if json_data["max_dev"] > 15 or json_data["count"] == 1 else ""
                    date_display = f"{warn}{date} (±{json_data['max_dev']}d, n={json_data['count']})"
                elif isinstance(json_data, dict):
                    tooltip = json.dumps(json_data, indent=2)
                    date_display = f"{date} (predicted)" if predicted else date
                elif json_data:
                    tooltip = json.dumps(json_data, indent=2)
                    date_display = f"{date} (predicted)" if predicted else date
                else:
                    tooltip = "Predicted" if predicted else ""
                    date_display = f"{date} (predicted)" if predicted else date
                tooltip_escaped = tooltip.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;").replace("\n", "&#10;")
                if i == 0:
                    html += f'        <tr><td rowspan="{len(group_rows)}">{month_name}</td><td{cls} title="{tooltip_escaped}">{label_html}</td><td{cls}>{date_display}</td></tr>\n'
                else:
                    html += f'        <tr><td{cls} title="{tooltip_escaped}">{label_html}</td><td{cls}>{date_display}</td></tr>\n'
        html += "    </table>\n"

    html += """</body>
</html>
"""
    with open(filepath, "w") as f:
        f.write(html)

    print(f"Wrote {filepath}", file=sys.stderr)


def main():
    results = {}
    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = {
            executor.submit(fetch_deadlines, conf_label(name, year), url): (conf_label(name, year), name, year, url)
            for name, year, url in CONFERENCES
            if year >= FROM_YEAR
        }
        futures_iter = as_completed(futures)
        if tqdm:
            futures_iter = tqdm(futures_iter, total=len(futures), desc="Fetching", file=sys.stderr)

        for future in futures_iter:
            label, name, year, url = futures[future]
            try:
                result = future.result()
                result["name"] = name
                result["year"] = year
                result["url"] = url
                results[label] = result
                progress_write(f"  {label}: OK")
            except Exception as e:
                progress_write(f"  {label}: Error - {e}")

    # Write JSON cache
    with open("/tmp/deadlines.json", "w") as f:
        json.dump(results, f, indent=2)
    print("Wrote /tmp/deadlines.json", file=sys.stderr)

    print_deadline_table(results)
    write_html_table(results, "/tmp/deadlines.html")

    print(f"Total: {_total_calls} API calls, ${_total_cost:.4f}", file=sys.stderr)


def render_only():
    """Re-render HTML from cached JSON."""
    with open("/tmp/deadlines.json") as f:
        results = json.load(f)
    print_deadline_table(results)
    write_html_table(results, "/tmp/deadlines.html")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--render":
        render_only()
    else:
        main()
