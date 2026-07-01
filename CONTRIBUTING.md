# Contributing

Contributions are welcome. The kit is deliberately minimal — no build step, no dependencies, pure markdown and shell scripts. Keep it that way.

## What belongs here

- New agent templates (`team/*.md`) that would be useful to most users
- Improvements to `setup.sh` or `setup.ps1` (bug fixes, portability, new slots)
- Corrections to `CLAUDE.md`, `README.md`, or `getting-started-scenarios.md`

## What does not belong here

- Platform-specific setup flows (npm packages, Docker images, etc.)
- Hardcoded content that assumes a specific profession, company, or tool

## How to propose a new agent template

1. Open an issue describing the agent's role and why it belongs in the founding set.
2. If the role is agreed on, submit a PR with:
   - `team/<role>_template.md` following the existing template structure
   - Updated slot entries in `CLAUDE.template.md`, `CLAUDE.md`, and `README.md`
   - Updated `REQUIRED_FILES` and substitution logic in `setup.sh` and `setup.ps1`
   - A new prompt in the setup scripts to let users name the agent

## Testing

No test suite. Verify changes by running the setup script in dry-run mode:

```bash
bash setup.sh --dry-run
```

Then run a full setup with `--force` and confirm:
1. The output directory contains the correct team files with all placeholders substituted.
2. No `<CUSTOMIZE:>` tokens remain: `grep -r '<CUSTOMIZE:' /path/to/output/`

## Style

- Markdown only. No code beyond the setup scripts.
- Template files use `<CUSTOMIZE: slot_name>` tokens, never hardcoded names.
- Shell script changes must work on bash 3.2+ (macOS ships an old bash).
- PowerShell changes must work on PowerShell 5.1+ (Windows 10/11 default).
