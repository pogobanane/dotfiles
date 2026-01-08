#!/usr/bin/env python3
import subprocess
import json
import shlex
import sys
from urllib.parse import urlparse

CONFERENCES = {
    "SIGCOMM": "https://conferences.sigcomm.org/sigcomm/2026/cfp/",
    "EuroSys": "https://2026.eurosys.org/cfp.html#calls",
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


def fetch_deadlines(conference: str) -> dict:
    url = CONFERENCES.get(conference)
    if not url:
        raise ValueError(f"Unknown conference: {conference}. Available: {list(CONFERENCES.keys())}")

    domain = urlparse(url).netloc

    print(f"Checking {conference}")

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

    return {
        "submission_deadline": submission_deadline,
        "other_deadlines": [d for d in all_deadlines if not matches(d)],
    }


def main():
    results = {conf: fetch_deadlines(conf) for conf in CONFERENCES}
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
