# Changelog

All notable changes to this project will be documented here.

## [1.2.0] — 2026-07-01

Bundled .claude infrastructure: hooks, skills, and safe-move script.

### Added
- `.claude/settings.json` — registers the trace-footer PostToolUse hook out of the box. Uses `$CLAUDE_PROJECT_DIR` for portability across machines.
- `.claude/hooks/check-trace-footer.py` — enforcement hook that warns when a deliverable lands in `owners_inbox/` with factual claims but no Sources: footer or [Unverified] marker.
- `.claude/skills/intake/SKILL.md` — delegation intake interview skill. Runs a 6-question brief before delegating significant tasks, then compresses answers into the specialist's spawn prompt.
- `.claude/skills/safe-mv/SKILL.md` — safe-move skill for cloud-synced paths (OneDrive, Google Drive). Prevents silent data loss from zero-byte offline stubs.
- `.claude/scripts/safe-mv.sh` — the underlying safe-move wrapper script (bash 3.2+, macOS/Linux).

## [1.1.2] — 2026-07-01

First-run welcome and session greeting.

### Fixed
- Assistant now introduces itself at the start of every session: name, role, and current team roster.
- First-run detection: when both inboxes are empty and no prior work is visible, the assistant explains how to use the system and invites the first task, instead of sitting silent.

## [1.1.1] — 2026-06-30

Attribution.

### Added
- Credit to Chris Gagné's [grounded-forge](https://github.com/chrisgagne/grounded-forge) for the fact-checker's evidence-class markers, in the Fact-Checker template and a new README Acknowledgments section. The trace footer and `[Unverified]` marker are the kit's own convention; only the evidence-class taxonomy is adapted from grounded-forge.

## [1.1.0] — 2026-06-30

Grounding discipline.

### Added
- **Trace footer convention** in the `CLAUDE.md` operating manual and the Researcher template: any deliverable with factual claims ends with a `Sources:` / `Claims marked [Unverified]:` footer, making delivery review mechanical rather than a matter of trust.
- **`[Unverified]` marker** convention for any claim that cannot be traced to a source.
- **Evidence-class markers** (`[V]/[P]/[A]/[E]/[B]`) in the Fact-Checker template, a second dimension alongside the Confirmed/Unverified/Disputed status that catches an example being promoted to a fact or a borrowed citation being misattributed.
- Guidance in the Writer template to preserve trace footers and `[Unverified]` markers when editing another member's factual work.
- Note in the operating manual pointing to an optional `PostToolUse` hook for teams that want the footer enforced automatically rather than by convention.

## [1.0.0] — 2026-06-30

Initial public release.

### Added
- Four founding agent templates: Researcher, HR Director, Writer/Editor, Fact-Checker
- `CLAUDE.md` operating manual template with placeholder system (13 customizable slots)
- `setup.sh` for Mac/Linux interactive setup (bash 3.2+, no external dependencies)
- `setup.ps1` for Windows interactive setup (PowerShell 5.1+)
- `setup.bat` Windows double-click launcher for `setup.ps1`
- `getting-started-scenarios.md` with three first-use demo scenarios and tips
- `README.md` with Quick Start, manual setup instructions, and worked example
- MIT license
