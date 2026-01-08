#!/usr/bin/env python3
import subprocess
import json
import shlex
import sys
from urllib.parse import urlparse

CONFERENCES = {
    "sigcomm": "https://conferences.sigcomm.org/sigcomm/2026/cfp/",
}

DEADLINE_SCHEMA = json.dumps({
    "type": "object",
    "properties": {
        "deadlines": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "datetime": {
                        "type": "string",
                        "description": "ISO 8601 date, e.g. 2026-01-30"
                    },
                    "timezone": {
                        "type": "string",
                        "description": "Timezone as stated, e.g. AoE"
                    },
                    "raw_string": {
                        "type": "string",
                        "description": "Full deadline text as on website"
                    }
                },
                "required": ["datetime", "timezone", "raw_string"]
            }
        }
    },
    "required": ["deadlines"]
})


class ClaudeQueryError(Exception):
    """Raised when a Claude query fails to return expected output."""
    pass


def fetch_deadlines(conference: str) -> dict:
    url = CONFERENCES.get(conference)
    if not url:
        raise ValueError(f"Unknown conference: {conference}. Available: {list(CONFERENCES.keys())}")

    prompt = f"Fetch {url} and extract all deadlines"

    domain = urlparse(url).netloc

    cmd = [
        "claude",
        "-p", prompt,
        "--output-format", "json",
        "--json-schema", DEADLINE_SCHEMA,
        "--allowedTools", f"WebFetch(domain:{domain})",
    ]
    print(shlex.join(cmd), file=sys.stderr)

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        check=True,
    )

    output = json.loads(result.stdout)

    structured = output.get("structured_output")
    if not structured:
        text_result = output.get("result", "No response")
        raise ClaudeQueryError(
            f"No structured output returned. Claude response: {text_result[:500]}"
        )

    deadlines = structured.get("deadlines")
    if not deadlines:
        raise ClaudeQueryError("structured_output contains no deadlines")

    return structured


def main():
    conference = sys.argv[1] if len(sys.argv) > 1 else "sigcomm"

    deadlines = fetch_deadlines(conference)
    print(json.dumps(deadlines, indent=2))


if __name__ == "__main__":
    main()
