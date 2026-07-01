#!/usr/bin/env python3
"""PostToolUse hook: trace-footer enforcement for owners_inbox deliverables.

Fires after Write or Edit on any file under owners_inbox/ (excluding archive/).
If the file contains factual-claim signals (numbers, dates, URLs, markdown links)
but has no "Sources:" footer and no [Unverified] marker, emits a warning to
stderr and exits 2 so the agent sees the feedback and can add the footer.

Non-blocking on internal error: any exception causes silent exit 0 (fail-open).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Factual-claim signal patterns
# ---------------------------------------------------------------------------
CLAIM_PATTERNS: list[tuple[str, re.Pattern[str]]] = [
    ("percentage", re.compile(r"\d+\s*%")),
    ("currency amount", re.compile(r"\$\s*\d")),
    ("year", re.compile(r"\b(19|20)\d{2}\b")),
    ("URL", re.compile(r"https?://")),
    ("markdown link", re.compile(r"\[[^\]]+\]\([^)]+\)")),
]

# ---------------------------------------------------------------------------
# Grounding patterns
# ---------------------------------------------------------------------------
SOURCES_PATTERN = re.compile(r"\*{0,2}sources:\*{0,2}", re.IGNORECASE)
UNVERIFIED_TOKEN = "[Unverified]"

# Minimum body length to bother checking (skip stubs / short notes)
MIN_BODY_LEN = 400


def is_owners_inbox_target(path: Path) -> bool:
    """Return True only for .md files under owners_inbox/ but not archive/."""
    parts = path.parts
    try:
        idx = next(i for i, p in enumerate(parts) if p == "owners_inbox")
    except StopIteration:
        return False
    remaining = parts[idx + 1 :]
    if "archive" in remaining:
        return False
    if not path.name.endswith(".md"):
        return False
    return True


def matched_signals(text: str) -> list[str]:
    """Return list of signal labels that fire in text."""
    hits = []
    for label, pat in CLAIM_PATTERNS:
        if pat.search(text):
            hits.append(label)
    return hits


def is_grounded(text: str) -> bool:
    """Return True if the file has a Sources: footer or [Unverified] marker."""
    if SOURCES_PATTERN.search(text):
        return True
    if UNVERIFIED_TOKEN in text:
        return True
    return False


def main() -> int:
    try:
        raw = sys.stdin.read()
        if not raw.strip():
            return 0
        payload = json.loads(raw)
    except Exception:
        return 0

    try:
        tool_input = payload.get("tool_input", {})
        file_path_str = tool_input.get("file_path", "")
        if not file_path_str:
            return 0

        path = Path(file_path_str)

        if not is_owners_inbox_target(path):
            return 0

        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            return 0

        if len(text) < MIN_BODY_LEN:
            return 0

        signals = matched_signals(text)
        if not signals:
            return 0

        if is_grounded(text):
            return 0

        signal_list = ", ".join(signals)
        sys.stderr.write(
            f"[trace-footer check] {path.name} landed in owners_inbox/ with factual claims "
            f"({signal_list}) but no \"Sources:\" footer and no [Unverified] marker. "
            f"Add a trace footer listing sources and marking any unverifiable claim "
            f"[Unverified] before this is delivered.\n"
        )
        return 2

    except Exception:
        return 0


if __name__ == "__main__":
    sys.exit(main())
