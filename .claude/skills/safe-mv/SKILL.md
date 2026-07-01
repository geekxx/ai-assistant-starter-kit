---
name: safe-mv
description: Use whenever moving or relocating files on cloud-synced paths (OneDrive, Google Drive, or any CloudStorage path). Enforces the safe-mv.sh wrapper — never use raw mv or cp on cloud paths.
---

# Safe Move

Enforces the `safe-mv.sh` wrapper for all file moves on cloud-synced paths. The wrapper refuses to move zero-byte offline stubs (files that appear present but have not been downloaded from the cloud), preventing silent data loss.

## When to run this

Any move or relocation of files where the source or destination is under OneDrive, Google Drive, or any CloudStorage path. For local-only paths this wrapper is optional but harmless.

Do not use raw `mv` or `cp` on cloud paths. This skill exists to make that deterministic.

## Steps

1. Confirm source(s) and destination before executing.
2. Run `--dry-run` first to preview the move without touching anything.
3. If the output looks correct, run without `--dry-run` to execute.

## Tools

- `$CLAUDE_PROJECT_DIR/.claude/scripts/safe-mv.sh` — safe-move wrapper.

**Usage:**
```
safe-mv.sh [OPTIONS] SOURCE [SOURCE...] DEST
```

**Flags:**
- `--dry-run` / `-n` — show what would move, no filesystem changes
- `--force` / `-f` — skip the stub check (confirmation prompt still fires if stubs are detected)
- `--help` / `-h` — show usage

**Rules:**
- Single source: DEST can be a file path or a directory.
- Multiple sources: DEST must be a directory.
- Zero-byte file on a cloud path → rejected unless `--force` is passed.
- `--force` with stubs detected → prompts for explicit confirmation before proceeding.
- Paths with spaces are handled correctly (all variables quoted internally).

## Output

For each source: prints `Moving: <src>` / `To: <dest>` / `Done.` on success. Exits non-zero on any failure with a plain-English error message.
