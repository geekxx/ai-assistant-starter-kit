#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Purpose:       Scaffold a personalized AI assistant kit from the starter
#                templates. Copies the kit, substitutes all <CUSTOMIZE: ...>
#                slots, and renames the seed team-member files.
# Usage:         ./setup.sh [--dry-run] [--force] [--help]
# Prerequisites: bash 3.2+, standard POSIX tools (cp, mv, sed, tr, find).
#                No external dependencies. macOS and Linux supported.
#                Windows users: use setup.ps1 (or double-click setup.bat).
# Dry-run:       Pass --dry-run to preview every action without touching disk.
# Idempotency:   Refuses to overwrite an existing target directory unless
#                --force is passed. Safe to re-run from scratch with --force.
# ------------------------------------------------------------------------------

set -euo pipefail

# ── Constants ──────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Expected template files (relative to SCRIPT_DIR), used in preflight check.
REQUIRED_FILES=(
  "CLAUDE.template.md"
  "README.md"
  "team/researcher_template.md"
  "team/hr_template.md"
  "team/writer_template.md"
  "team/fact_checker_template.md"
)

# ── Flags ──────────────────────────────────────────────────────────────────────

DRY_RUN=false
FORCE=false

# ── Helpers ────────────────────────────────────────────────────────────────────

die() {
  printf '\n[error] %s\n' "$1" >&2
  if [[ -n "${2:-}" ]]; then
    printf '        %s\n' "$2" >&2
  fi
  exit 1
}

info() {
  printf '  %s\n' "$*"
}

preview() {
  # Prints an action line when in dry-run mode, otherwise executes it.
  # Usage: preview "description" cmd arg arg ...
  local desc="$1"; shift
  if "$DRY_RUN"; then
    printf '  [dry-run] %s\n' "$desc"
  else
    "$@"
  fi
}

to_lower() {
  # Lowercase a string. tr is POSIX and available everywhere.
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

prompt_value() {
  # prompt_value VAR_NAME "Prompt text" "default value"
  local varname="$1"
  local prompt_text="$2"
  local default="$3"
  local value=""

  while true; do
    if [[ -n "$default" ]]; then
      printf '  %s [%s]: ' "$prompt_text" "$default"
    else
      printf '  %s: ' "$prompt_text"
    fi
    read -r value || die "Input stream closed unexpectedly." "Run interactively (not piped)."
    value="${value:-$default}"
    if [[ -z "$value" ]]; then
      printf '  This field cannot be empty. Please enter a value.\n'
    else
      break
    fi
  done

  # Assign to caller's variable via nameref-style indirect assignment.
  # Compatible with bash 3.2+ (no declare -n needed).
  printf -v "$varname" '%s' "$value"
}

sed_inplace() {
  # Portable sed -i that works on both macOS (BSD sed) and Linux (GNU sed).
  # Uses a .bak file, then removes it. Operates on a single file at a time.
  # LC_ALL=C forces byte-level processing, preventing BSD sed from throwing
  # "illegal byte sequence" errors when the input contains UTF-8 characters
  # and the shell locale is unset or set to C. Safe here because all
  # substitution patterns are pure ASCII (<CUSTOMIZE: ...> placeholders).
  local pattern="$1"
  local file="$2"
  LC_ALL=C sed -i.bak "$pattern" "$file" && rm -f "${file}.bak"
}

# ── Usage ──────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF

Usage: $SCRIPT_NAME [OPTIONS]

Sets up a personalized AI assistant folder from the starter kit templates.
Run it once, answer the prompts, and you are ready to open Claude Code.

Options:
  --dry-run   Show what would happen without writing anything to disk.
  --force     Overwrite the target directory if it already exists.
  --help      Show this message and exit.

Examples:
  ./setup.sh                  # Interactive setup
  ./setup.sh --dry-run        # Preview without touching disk
  ./setup.sh --force          # Re-run and overwrite an existing target

EOF
}

# ── Argument parsing ───────────────────────────────────────────────────────────

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force)   FORCE=true ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $arg" "Run '$SCRIPT_NAME --help' for usage." ;;
  esac
done

# ── Preflight checks ───────────────────────────────────────────────────────────

# Confirm we are running in bash (not sh, zsh, etc.).
if [[ -z "${BASH_VERSION:-}" ]]; then
  die "This script must be run with bash." \
      "Try: bash $SCRIPT_NAME"
fi

# Confirm all template files are present.
missing_files=()
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$SCRIPT_DIR/$f" ]]; then
    missing_files+=("$f")
  fi
done

if [[ ${#missing_files[@]} -gt 0 ]]; then
  printf '\n[error] The following template files are missing from the kit folder:\n' >&2
  for mf in "${missing_files[@]}"; do
    printf '        %s\n' "$mf" >&2
  done
  die "The starter kit may be incomplete or corrupted." \
      "Re-download or restore the kit from its source before running setup."
fi

# ── Welcome ────────────────────────────────────────────────────────────────────

cat <<'EOF'

Personal AI Assistant Starter Kit — Setup
==========================================

This script will ask you a few questions and create a customized
assistant folder ready to open in Claude Code.

It will not modify this template folder. All output goes to a new
directory that you choose.

EOF

if "$DRY_RUN"; then
  printf '  Running in DRY-RUN mode. Nothing will be written to disk.\n\n'
fi

# ── Collect inputs ─────────────────────────────────────────────────────────────

printf 'Step 1 of 3 — Name your team\n\n'

prompt_value ASSISTANT_NAME    "Your assistant's name (e.g. Nova, Max, Alex)"          "Nova"
prompt_value OWNER_NAME        "Your own name, as the assistant should address you"    ""
prompt_value RESEARCHER_NAME   "Name for the researcher team member (e.g. Dex, Kai)"  "Dex"
prompt_value HR_NAME           "Name for the HR team member (e.g. Cleo, Sam)"         "Cleo"
prompt_value WRITER_NAME       "Name for the writer/editor team member (e.g. Mia, Jess)" "Mia"
prompt_value FACT_CHECKER_NAME "Name for the fact-checker team member (e.g. Vera, Cal)"  "Vera"

printf '\nStep 2 of 3 — Choose your models\n\n'
printf '  (These are Claude model IDs. Defaults are current Anthropic models.)\n\n'

prompt_value HIGH_CAPABILITY_MODEL \
  "High-capability model (deep research, complex reasoning)" \
  "claude-opus-4-8"
prompt_value MID_TIER_MODEL \
  "Mid-tier model (most general tasks)" \
  "claude-sonnet-4-6"
prompt_value FAST_MODEL \
  "Fast model (simple lookups, formatting, short edits)" \
  "claude-haiku-4-5-20251001"

printf '\nStep 3 of 3 — Choose a destination\n\n'

# Default target dir: current working directory + assistant name (lowercased).
ASSISTANT_NAME_LOWER="$(to_lower "$ASSISTANT_NAME")"
RESEARCHER_NAME_LOWER="$(to_lower "$RESEARCHER_NAME")"
HR_NAME_LOWER="$(to_lower "$HR_NAME")"
WRITER_NAME_LOWER="$(to_lower "$WRITER_NAME")"
FACT_CHECKER_NAME_LOWER="$(to_lower "$FACT_CHECKER_NAME")"

DEFAULT_TARGET_DIR="$(dirname "$SCRIPT_DIR")/${ASSISTANT_NAME_LOWER}"
prompt_value TARGET_DIR \
  "Where to create the folder" \
  "$DEFAULT_TARGET_DIR"

# ── Validate inputs ────────────────────────────────────────────────────────────

# Light character check: warn if names contain characters that could break
# filenames or sed patterns on common filesystems.
for name_var in ASSISTANT_NAME OWNER_NAME RESEARCHER_NAME HR_NAME WRITER_NAME FACT_CHECKER_NAME; do
  name_val="${!name_var}"
  if [[ "$name_val" =~ [/\\:*?\"\<\>\|] ]]; then
    die "\"$name_val\" contains characters that are not safe in filenames or file content." \
        "Please avoid: / \\ : * ? \" < > |"
  fi
done

# Guard: resolve both paths to canonical absolute paths so that the
# containment checks below work regardless of trailing slashes or symlinks.
# realpath is available on Linux and macOS 12.3+. Fall back to pwd -P trick
# for older macOS where realpath may not exist.
resolve_path() {
  if command -v realpath >/dev/null 2>&1; then
    # -m: don't require the path to exist yet (target may not be created yet).
    realpath -m "$1" 2>/dev/null || printf '%s' "$1"
  else
    # Best-effort: resolve the parent and append the leaf name.
    local parent leaf
    parent="$(cd "$(dirname "$1")" 2>/dev/null && pwd -P)" || parent="$(dirname "$1")"
    leaf="$(basename "$1")"
    printf '%s/%s' "$parent" "$leaf"
  fi
}

SCRIPT_DIR_REAL="$(resolve_path "$SCRIPT_DIR")"
TARGET_DIR_REAL="$(resolve_path "$TARGET_DIR")"

# Refuse if TARGET_DIR is equal to, or nested inside, SCRIPT_DIR.
# That would cause cp to copy source into itself (infinite recursion).
if [[ "$TARGET_DIR_REAL" == "$SCRIPT_DIR_REAL" ]] || \
   [[ "$TARGET_DIR_REAL" == "$SCRIPT_DIR_REAL/"* ]]; then
  die "Target directory cannot be inside the starter kit folder." \
      "Choose a path outside the kit, e.g.: $(dirname "$SCRIPT_DIR_REAL")/${ASSISTANT_NAME_LOWER}"
fi

# Refuse if SCRIPT_DIR is nested inside TARGET_DIR.
# With --force that would rm -rf the source tree before copying from it.
if [[ "$SCRIPT_DIR_REAL" == "$TARGET_DIR_REAL/"* ]]; then
  die "The starter kit folder is inside the chosen target directory." \
      "That would delete the source before copying from it. Choose a path that does not contain the kit folder."
fi

# Refuse to overwrite unless --force.
if [[ -e "$TARGET_DIR" ]] && ! "$FORCE"; then
  die "Target directory already exists: $TARGET_DIR" \
      "Pass --force to overwrite it, or choose a different directory."
fi

# ── Summary before acting ──────────────────────────────────────────────────────

cat <<EOF

What is about to happen
-----------------------
  Assistant name   : $ASSISTANT_NAME  (lower: $ASSISTANT_NAME_LOWER)
  Owner name       : $OWNER_NAME
  Researcher       : $RESEARCHER_NAME  (lower: $RESEARCHER_NAME_LOWER)
  HR director      : $HR_NAME  (lower: $HR_NAME_LOWER)
  Writer/editor    : $WRITER_NAME  (lower: $WRITER_NAME_LOWER)
  Fact-checker     : $FACT_CHECKER_NAME  (lower: $FACT_CHECKER_NAME_LOWER)
  High-cap model   : $HIGH_CAPABILITY_MODEL
  Mid-tier model   : $MID_TIER_MODEL
  Fast model       : $FAST_MODEL
  Output folder    : $TARGET_DIR
  Overwrite        : $FORCE
  Dry-run          : $DRY_RUN

EOF

if ! "$DRY_RUN"; then
  printf 'Press Enter to continue, or Ctrl-C to cancel. '
  read -r _confirm || true
  printf '\n'
fi

# ── Copy template files ────────────────────────────────────────────────────────

printf 'Copying template files...\n'

if "$FORCE" && [[ -e "$TARGET_DIR" ]] && ! "$DRY_RUN"; then
  rm -rf "$TARGET_DIR"
fi

preview "Create target directory: $TARGET_DIR" \
  mkdir -p "$TARGET_DIR"

# Copy the entire kit tree into the target directory, then remove the setup
# script from the copy (no reason to ship it with the user's kit).
# cp -Rp src/. dst/ is POSIX-portable and handles hidden files (.gitkeep).
# We check the exit code explicitly because some BSD cp implementations emit
# per-file errors without returning non-zero on the overall call.
if ! "$DRY_RUN"; then
  cp -Rp "$SCRIPT_DIR/." "$TARGET_DIR/" || \
    die "cp failed while copying kit files to $TARGET_DIR." \
        "Check available disk space and permissions, then re-run."
else
  printf '  [dry-run]   copy all kit files into %s\n' "$TARGET_DIR"
fi

if ! "$DRY_RUN"; then
  # Remove all setup scripts from the copy — they belong to the kit, not the
  # user's working folder.
  rm -f "$TARGET_DIR/setup.sh"
  rm -f "$TARGET_DIR/setup.ps1"
  rm -f "$TARGET_DIR/setup.bat"
fi

# Show what was copied (for user awareness, always list from source).
while IFS= read -r -d '' src; do
  rel="${src#"$SCRIPT_DIR/"}"
  [[ "$rel" == "$SCRIPT_NAME" ]] && continue
  info "  copied $rel"
done < <(find "$SCRIPT_DIR" -not -path "$SCRIPT_DIR" -print0 | sort -z)

# ── Substitute placeholders ────────────────────────────────────────────────────

printf 'Substituting placeholders...\n'

# We need to escape the slot values for use in sed replacement strings.
# The only characters that matter in the replacement side of s/// are & and \.
escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[&\]/\\&/g'
}

ASSISTANT_NAME_ESC="$(escape_sed_replacement "$ASSISTANT_NAME")"
OWNER_NAME_ESC="$(escape_sed_replacement "$OWNER_NAME")"
RESEARCHER_NAME_ESC="$(escape_sed_replacement "$RESEARCHER_NAME")"
RESEARCHER_NAME_LOWER_ESC="$(escape_sed_replacement "$RESEARCHER_NAME_LOWER")"
HR_NAME_ESC="$(escape_sed_replacement "$HR_NAME")"
HR_NAME_LOWER_ESC="$(escape_sed_replacement "$HR_NAME_LOWER")"
WRITER_NAME_ESC="$(escape_sed_replacement "$WRITER_NAME")"
WRITER_NAME_LOWER_ESC="$(escape_sed_replacement "$WRITER_NAME_LOWER")"
FACT_CHECKER_NAME_ESC="$(escape_sed_replacement "$FACT_CHECKER_NAME")"
FACT_CHECKER_NAME_LOWER_ESC="$(escape_sed_replacement "$FACT_CHECKER_NAME_LOWER")"
HIGH_CAPABILITY_MODEL_ESC="$(escape_sed_replacement "$HIGH_CAPABILITY_MODEL")"
MID_TIER_MODEL_ESC="$(escape_sed_replacement "$MID_TIER_MODEL")"
FAST_MODEL_ESC="$(escape_sed_replacement "$FAST_MODEL")"

# Build a chained sed expression for all thirteen slots.
# Order matters: do the _lower variants before the bare names so partial
# matches don't corrupt them.
sed_expr=""
sed_expr+="s/<CUSTOMIZE: assistant_name>/${ASSISTANT_NAME_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: owner_name>/${OWNER_NAME_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: researcher_name_lower>/${RESEARCHER_NAME_LOWER_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: researcher_name>/${RESEARCHER_NAME_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: hr_name_lower>/${HR_NAME_LOWER_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: hr_name>/${HR_NAME_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: writer_name_lower>/${WRITER_NAME_LOWER_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: writer_name>/${WRITER_NAME_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: fact_checker_name_lower>/${FACT_CHECKER_NAME_LOWER_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: fact_checker_name>/${FACT_CHECKER_NAME_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: high_capability_model>/${HIGH_CAPABILITY_MODEL_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: mid_tier_model>/${MID_TIER_MODEL_ESC}/g;"
sed_expr+="s/<CUSTOMIZE: fast_model>/${FAST_MODEL_ESC}/g;"

if "$DRY_RUN"; then
  # In dry-run mode the target directory doesn't exist, so enumerate the
  # source files instead and just show what would be substituted.
  while IFS= read -r -d '' src_file; do
    [[ "$(basename "$src_file")" == ".gitkeep" ]] && continue
    [[ "$(basename "$src_file")" == "$SCRIPT_NAME" ]] && continue
    rel="${src_file#"$SCRIPT_DIR/"}"
    preview "  substitute in $rel" true
  done < <(find "$SCRIPT_DIR" -type f -print0 | sort -z)
else
  # Process every regular file in the target (excluding .gitkeep — they're
  # empty and have no slots, but we skip them explicitly to be tidy).
  while IFS= read -r -d '' target_file; do
    [[ "$(basename "$target_file")" == ".gitkeep" ]] && continue
    [[ "$(basename "$target_file")" == "$SCRIPT_NAME" ]] && continue
    rel="${target_file#"$TARGET_DIR/"}"
    preview "  substitute in $rel" \
      sed_inplace "$sed_expr" "$target_file"
  done < <(find "$TARGET_DIR" -type f -print0 | sort -z)
fi

# ── Rename team template files ─────────────────────────────────────────────────

printf 'Renaming team files...\n'

RESEARCHER_SRC="$TARGET_DIR/team/researcher_template.md"
RESEARCHER_DST="$TARGET_DIR/team/${RESEARCHER_NAME_LOWER}.md"
if [[ -f "$RESEARCHER_SRC" ]] || "$DRY_RUN"; then
  preview "  rename team/researcher_template.md -> team/${RESEARCHER_NAME_LOWER}.md" \
    mv "$RESEARCHER_SRC" "$RESEARCHER_DST"
fi

HR_SRC="$TARGET_DIR/team/hr_template.md"
HR_DST="$TARGET_DIR/team/${HR_NAME_LOWER}.md"
if [[ -f "$HR_SRC" ]] || "$DRY_RUN"; then
  preview "  rename team/hr_template.md -> team/${HR_NAME_LOWER}.md" \
    mv "$HR_SRC" "$HR_DST"
fi

WRITER_SRC="$TARGET_DIR/team/writer_template.md"
WRITER_DST="$TARGET_DIR/team/${WRITER_NAME_LOWER}.md"
if [[ -f "$WRITER_SRC" ]] || "$DRY_RUN"; then
  preview "  rename team/writer_template.md -> team/${WRITER_NAME_LOWER}.md" \
    mv "$WRITER_SRC" "$WRITER_DST"
fi

FACT_CHECKER_SRC="$TARGET_DIR/team/fact_checker_template.md"
FACT_CHECKER_DST="$TARGET_DIR/team/${FACT_CHECKER_NAME_LOWER}.md"
if [[ -f "$FACT_CHECKER_SRC" ]] || "$DRY_RUN"; then
  preview "  rename team/fact_checker_template.md -> team/${FACT_CHECKER_NAME_LOWER}.md" \
    mv "$FACT_CHECKER_SRC" "$FACT_CHECKER_DST"
fi

# ── Finalize CLAUDE.md ─────────────────────────────────────────────────────────
# Replace the kit's CLAUDE.md (developer instructions) with the operating manual
# template. The kit's CLAUDE.md is not meant for users; CLAUDE.template.md is.

printf 'Finalizing CLAUDE.md...\n'

CLAUDE_TEMPLATE_SRC="$TARGET_DIR/CLAUDE.template.md"
CLAUDE_DST="$TARGET_DIR/CLAUDE.md"
if [[ -f "$CLAUDE_TEMPLATE_SRC" ]] || "$DRY_RUN"; then
  preview "  rename CLAUDE.template.md -> CLAUDE.md" \
    mv "$CLAUDE_TEMPLATE_SRC" "$CLAUDE_DST"
fi

# ── Done ───────────────────────────────────────────────────────────────────────

if "$DRY_RUN"; then
  printf '\nDry run complete. No files were written.\n'
  printf 'Remove --dry-run and re-run when you are ready to go.\n\n'
  exit 0
fi

cat <<EOF

Done. Your assistant is ready.
------------------------------

  Folder   : $TARGET_DIR
  Assistant: $ASSISTANT_NAME
  Team     : $RESEARCHER_NAME (researcher), $HR_NAME (HR), $WRITER_NAME (writer), $FACT_CHECKER_NAME (fact-checker)

Next steps:

  1. Open Claude Code and point it at your new folder:
       cd "$TARGET_DIR"
       claude

  2. Claude will read CLAUDE.md, introduce itself as $ASSISTANT_NAME,
     and confirm the folder scaffold is in place.

  3. Give $ASSISTANT_NAME your first task — in chat, or by dropping
     a file into team_inbox/.

That is it. No build step, no dependencies, no further configuration needed.

EOF
