# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this repository.

## What This Repository Is

This is a **starter kit template**, not a live assistant. Its purpose is to be cloned by end users and customized via `setup.sh` (Mac/Linux) or `setup.ps1` (Windows). The setup script copies the kit to a sibling directory, substitutes all `<CUSTOMIZE: slot_name>` placeholders throughout every file, renames the four agent template files to match the user's chosen names, and renames `CLAUDE.template.md` to `CLAUDE.md` in the output directory.

The operating manual template that ships inside the generated assistant is in `CLAUDE.template.md`. It is not instructions for Claude Code working in this repository.

## Placeholder System

Every user-configurable value is a `<CUSTOMIZE: slot_name>` token. The full slot inventory:

| Slot | Purpose |
|------|---------|
| `assistant_name` | Name of the AI orchestrator |
| `owner_name` | Name of the human user |
| `researcher_name` | Name of the researcher agent |
| `researcher_name_lower` | Lowercase `researcher_name`, used in file paths |
| `hr_name` | Name of the HR agent |
| `hr_name_lower` | Lowercase `hr_name`, used in file paths |
| `writer_name` | Name of the writer/editor agent |
| `writer_name_lower` | Lowercase `writer_name`, used in file paths |
| `fact_checker_name` | Name of the fact-checker agent |
| `fact_checker_name_lower` | Lowercase `fact_checker_name`, used in file paths |
| `high_capability_model` | Claude model ID for deep reasoning tasks |
| `mid_tier_model` | Claude model ID for general tasks |
| `fast_model` | Claude model ID for simple/fast tasks |

`setup.sh` / `setup.ps1` collect these values interactively, then run `sed` substitution across all template files. Both scripts support `--dry-run` to preview without writing.

## Template Files

Files that contain `<CUSTOMIZE:>` tokens and get substituted during setup:

- `CLAUDE.template.md` → becomes `CLAUDE.md` in the generated directory
- `team/researcher_template.md` → renamed to `team/<researcher_name_lower>.md`
- `team/hr_template.md` → renamed to `team/<hr_name_lower>.md`
- `team/writer_template.md` → renamed to `team/<writer_name_lower>.md`
- `team/fact_checker_template.md` → renamed to `team/<fact_checker_name_lower>.md`

When editing any of these, preserve the `<CUSTOMIZE: slot_name>` tokens exactly — the setup scripts match them literally.

This kit's `CLAUDE.md` (the file you are reading) is **not** copied into the generated directory. Only `CLAUDE.template.md` is, renamed to `CLAUDE.md`.

## Running the Setup Scripts

```bash
# Mac / Linux
bash setup.sh            # interactive setup
bash setup.sh --dry-run  # preview only
bash setup.sh --force    # overwrite existing target

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File .\setup.ps1
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Force
```

The generated assistant directory is created **next to** this kit folder, not inside it.
