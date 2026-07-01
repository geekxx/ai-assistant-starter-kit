#!/usr/bin/env bash
# Purpose:       Safe-move wrapper for OneDrive and Google Drive paths.
#                Refuses to move zero-byte cloud stubs (offline placeholders)
#                that have not yet been downloaded from the cloud.
# Usage:         safe-mv.sh [--dry-run] [--force] [--help] SOURCE... DEST
# Prerequisites: bash 3.2+, macOS (uses stat -f %z for file size)
# Dry-run:       Pass --dry-run to show what would move without touching anything.
# Idempotency:   Safe to re-run; if destination already exists the move will
#                fail (mv default) unless the shell's mv handles it naturally.

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

SCRIPT_NAME="$(basename "$0")"

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------

usage() {
    cat <<EOF

Usage:
  ${SCRIPT_NAME} [OPTIONS] SOURCE [SOURCE...] DEST

Move one or more files or directories to DEST, with a preflight check that
refuses to move zero-byte cloud stubs from OneDrive or Google Drive that
have not yet been downloaded locally.

Options:
  --dry-run     Show what would be moved without moving anything.
  --force       Skip the stub check (still prompts for confirmation).
  --help        Show this message and exit.

Arguments:
  SOURCE        One or more source paths (files or directories).
  DEST          Destination path (file or directory).
                If multiple sources are given, DEST must be a directory.

Examples:
  # Move a single file
  ${SCRIPT_NAME} ~/Downloads/report.pdf \\
    "/Users/jeff/OneDrive/01_Personal & Admin/reports/"

  # Move multiple files
  ${SCRIPT_NAME} file1.md file2.md \\
    "/Users/jeff/OneDrive/01_Personal & Admin/notes/"

  # Preview without moving
  ${SCRIPT_NAME} --dry-run report.pdf /some/destination/

  # Bypass stub check (use with care — confirm prompt still fires)
  ${SCRIPT_NAME} --force suspicious-zero-byte-file.docx /destination/

EOF
    exit 0
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

err() {
    echo "Error: $*" >&2
}

warn() {
    echo "Warning: $*" >&2
}

# Returns file size in bytes. Works on macOS (stat -f %z).
# Falls back to wc -c for portability, but macOS stat is preferred.
file_size_bytes() {
    local path="$1"
    if stat -f "%z" -- "$path" 2>/dev/null; then
        return
    fi
    # Fallback: wc -c (slower but portable)
    wc -c < "$path" | tr -d ' '
}

# Returns 0 (true) if path looks like it lives under a cloud sync folder
# that might produce offline stubs.
is_cloud_path() {
    local path="$1"
    case "$path" in
        */OneDrive*|*/Google\ Drive*|*/GoogleDrive*|*CloudStorage*)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# Returns 0 (true) if the path appears to be an offline cloud stub:
# exists, is a regular file, and has zero bytes.
is_stub() {
    local path="$1"
    # Directories are never stubs
    if [[ -d "$path" ]]; then
        return 1
    fi
    if [[ ! -f "$path" ]]; then
        return 1
    fi
    local size
    size="$(file_size_bytes "$path")"
    if [[ "$size" -eq 0 ]]; then
        return 0
    fi
    return 1
}

# Prompt user for yes/no. Defaults to "no".
# Returns 0 for yes, 1 for no.
confirm() {
    local message="$1"
    local reply
    printf "%s [y/N] " "$message" >&2
    read -r reply </dev/tty
    case "$reply" in
        [yY]|[yY][eE][sS])
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

DRY_RUN=0
FORCE=0
SOURCES=()
DEST=""

if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            usage ;;
        --dry-run|-n)
            DRY_RUN=1
            shift ;;
        --force|-f)
            FORCE=1
            shift ;;
        --)
            shift
            # Everything remaining is positional
            while [[ $# -gt 0 ]]; do
                SOURCES+=("$1")
                shift
            done
            break ;;
        -*)
            err "Unknown option: $1"
            echo "Run '${SCRIPT_NAME} --help' for usage." >&2
            exit 1 ;;
        *)
            SOURCES+=("$1")
            shift ;;
    esac
done

# Last element of SOURCES is DEST
if [[ ${#SOURCES[@]} -lt 2 ]]; then
    err "You must provide at least one SOURCE and one DEST."
    echo "Run '${SCRIPT_NAME} --help' for usage." >&2
    exit 1
fi

# Split SOURCES into actual sources + destination
DEST="${SOURCES[${#SOURCES[@]}-1]}"
unset "SOURCES[${#SOURCES[@]}-1]"

# If multiple sources, dest must be a directory (or not exist yet — mv handles it)
if [[ ${#SOURCES[@]} -gt 1 ]] && [[ -e "$DEST" ]] && [[ ! -d "$DEST" ]]; then
    err "DEST '${DEST}' must be a directory when moving multiple sources."
    exit 1
fi

# ---------------------------------------------------------------------------
# Preflight: validate sources exist
# ---------------------------------------------------------------------------

for src in "${SOURCES[@]}"; do
    if [[ ! -e "$src" ]]; then
        err "Source path does not exist: ${src}"
        exit 1
    fi
done

# ---------------------------------------------------------------------------
# Stub check
# ---------------------------------------------------------------------------

STUB_FOUND=0

if [[ "${FORCE}" -eq 0 ]]; then
    for src in "${SOURCES[@]}"; do
        if is_stub "$src"; then
            STUB_FOUND=1
            warn "Zero-byte file detected (possible offline cloud stub): ${src}"
        fi
    done

    if [[ "${STUB_FOUND}" -eq 1 ]]; then
        echo >&2
        echo "These files appear to be offline cloud stubs that have not been" >&2
        echo "downloaded yet. Moving them may destroy your data." >&2
        echo >&2
        echo "To fix: open the file in Finder to force a download, wait for the" >&2
        echo "sync icon to clear, then re-run this command." >&2
        echo >&2
        echo "To skip this check anyway, pass --force (a confirmation prompt will" >&2
        echo "still appear)." >&2
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Dry-run output
# ---------------------------------------------------------------------------

if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo
    echo "[DRY RUN] No files will be moved."
    echo
    for src in "${SOURCES[@]}"; do
        local_stub_warning=""
        if is_stub "$src"; then
            local_stub_warning="  *** WARNING: zero-byte stub ***"
        fi
        echo "  WOULD MOVE: ${src}"
        echo "       TO:    ${DEST}"
        if [[ -n "${local_stub_warning}" ]]; then
            echo "              ${local_stub_warning}"
        fi
    done
    echo
    if [[ "${FORCE}" -eq 1 ]]; then
        echo "  (--force active: stub check would be skipped)"
    fi
    echo
    exit 0
fi

# ---------------------------------------------------------------------------
# Force-mode confirmation
# ---------------------------------------------------------------------------

if [[ "${FORCE}" -eq 1 ]] && [[ "${STUB_FOUND}" -eq 0 ]]; then
    # FORCE was passed; do a final check here so we can prompt if stubs exist
    for src in "${SOURCES[@]}"; do
        if is_stub "$src"; then
            STUB_FOUND=1
            break
        fi
    done
fi

if [[ "${FORCE}" -eq 1 ]] && [[ "${STUB_FOUND}" -eq 1 ]]; then
    echo >&2
    warn "One or more sources appear to be offline cloud stubs."
    warn "--force bypasses the stub check, but this is risky."
    echo >&2
    if ! confirm "Proceed with the move anyway?"; then
        echo "Aborted." >&2
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Execute move
# ---------------------------------------------------------------------------

for src in "${SOURCES[@]}"; do
    echo "Moving: ${src}"
    echo "    To: ${DEST}"
    if ! mv -- "$src" "$DEST"; then
        err "mv failed for: ${src} -> ${DEST}"
        exit 1
    fi
    echo "  Done."
done

echo
echo "All moves complete."
