# ------------------------------------------------------------------------------
# Purpose:       Scaffold a personalized AI assistant kit from the starter
#                templates. Copies the kit, substitutes all <CUSTOMIZE: ...>
#                slots, and renames the seed team-member files.
#                Windows counterpart to setup.sh (Mac/Linux).
# Usage:         .\setup.ps1 [-DryRun] [-Force] [-Help]
# Prerequisites: PowerShell 5.1+ (ships with Windows 10/11). No other
#                dependencies. Internet access not required.
# Dry-run:       Pass -DryRun to preview every action without touching disk.
# Idempotency:   Refuses to overwrite an existing target directory unless
#                -Force is passed. Safe to re-run from scratch with -Force.
#
# EXECUTION POLICY NOTE
# ---------------------
# Windows may block script execution by default. If you see an error like
# "running scripts is disabled on this system", use this one-liner instead
# of double-clicking the script (it bypasses the policy for this run only,
# no system-wide changes required):
#
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
#
# ------------------------------------------------------------------------------

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Preview all actions without writing anything to disk.")]
    [switch]$DryRun,

    [Parameter(HelpMessage = "Overwrite the target directory if it already exists.")]
    [switch]$Force,

    [Parameter(HelpMessage = "Show usage and exit.")]
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Constants ──────────────────────────────────────────────────────────────────

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptName = Split-Path -Leaf  $MyInvocation.MyCommand.Path

$RequiredFiles = @(
    "CLAUDE.md",
    "README.md",
    "team\researcher_template.md",
    "team\hr_template.md",
    "team\writer_template.md",
    "team\fact_checker_template.md"
)

# ── Helpers ────────────────────────────────────────────────────────────────────

function Die {
    param([string]$Message, [string]$Detail = "")
    Write-Host ""
    Write-Host "[error] $Message" -ForegroundColor Red
    if ($Detail -ne "") {
        Write-Host "        $Detail" -ForegroundColor Red
    }
    Write-Host ""
    exit 1
}

function Info {
    param([string]$Message)
    Write-Host "  $Message"
}

function Preview {
    # In DryRun mode: print what would happen. Otherwise: run the script block.
    param([string]$Description, [scriptblock]$Action)
    if ($DryRun) {
        Write-Host "  [dry-run] $Description"
    } else {
        try {
            & $Action
        } catch {
            Die "Operation failed: $Description" $_.Exception.Message
        }
    }
}

function ToLower {
    param([string]$Value)
    return $Value.ToLower()
}

function PromptValue {
    # Prompts the user for a value. Loops until non-empty. Returns the value.
    param(
        [string]$PromptText,
        [string]$Default = ""
    )
    while ($true) {
        if ($Default -ne "") {
            Write-Host -NoNewline "  $PromptText [$Default]: "
        } else {
            Write-Host -NoNewline "  ${PromptText}: "
        }
        $raw = Read-Host
        if ($raw -eq "") { $raw = $Default }
        if ($raw -ne "") {
            return $raw
        }
        Write-Host "  This field cannot be empty. Please enter a value."
    }
}

function EscapeRegex {
    # Escapes a literal string so it is safe to use in -replace's left side.
    param([string]$Value)
    return [regex]::Escape($Value)
}

function EscapeReplacement {
    # Escapes a string for use as the replacement side of PowerShell's -replace.
    # The only special character in the replacement is $.
    param([string]$Value)
    return $Value -replace '\$', '$$$$'
}

# ── Usage ──────────────────────────────────────────────────────────────────────

function ShowUsage {
    Write-Host ""
    Write-Host "Usage: .\$ScriptName [-DryRun] [-Force] [-Help]"
    Write-Host ""
    Write-Host "Sets up a personalized AI assistant folder from the starter kit templates."
    Write-Host "Run it once, answer the prompts, and you are ready to open Claude Code."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -DryRun   Show what would happen without writing anything to disk."
    Write-Host "  -Force    Overwrite the target directory if it already exists."
    Write-Host "  -Help     Show this message and exit."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\setup.ps1                   # Interactive setup"
    Write-Host "  .\setup.ps1 -DryRun           # Preview without touching disk"
    Write-Host "  .\setup.ps1 -Force            # Re-run and overwrite an existing target"
    Write-Host ""
    Write-Host "If Windows blocks script execution with 'running scripts is disabled':"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\setup.ps1"
    Write-Host ""
}

if ($Help) {
    ShowUsage
    exit 0
}

# ── Preflight checks ───────────────────────────────────────────────────────────

# Confirm PowerShell version is 5.1+.
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -lt 5 -or ($psVer.Major -eq 5 -and $psVer.Minor -lt 1)) {
    Die "PowerShell 5.1 or later is required." `
        "Your version is $($psVer.ToString()). Windows 10/11 ship with 5.1 by default."
}

# Confirm all template files are present.
$missingFiles = @()
foreach ($f in $RequiredFiles) {
    if (-not (Test-Path (Join-Path $ScriptDir $f))) {
        $missingFiles += $f
    }
}
if ($missingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "[error] The following template files are missing from the kit folder:" -ForegroundColor Red
    foreach ($mf in $missingFiles) {
        Write-Host "        $mf" -ForegroundColor Red
    }
    Die "The starter kit may be incomplete or corrupted." `
        "Re-download or restore the kit from its source before running setup."
}

# ── Welcome ────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "Personal AI Assistant Starter Kit - Setup"
Write-Host "=========================================="
Write-Host ""
Write-Host "This script will ask you a few questions and create a customized"
Write-Host "assistant folder ready to open in Claude Code."
Write-Host ""
Write-Host "It will not modify this template folder. All output goes to a new"
Write-Host "directory that you choose."
Write-Host ""

if ($DryRun) {
    Write-Host "  Running in DRY-RUN mode. Nothing will be written to disk."
    Write-Host ""
}

# ── Collect inputs ─────────────────────────────────────────────────────────────

Write-Host "Step 1 of 3 - Name your team"
Write-Host ""

$AssistantName    = PromptValue "Your assistant's name (e.g. Nova, Max, Alex)" "Nova"
$OwnerName        = PromptValue "Your own name, as the assistant should address you"
$ResearcherName   = PromptValue "Name for the researcher team member (e.g. Dex, Kai)" "Dex"
$HrName           = PromptValue "Name for the HR team member (e.g. Cleo, Sam)" "Cleo"
$WriterName       = PromptValue "Name for the writer/editor team member (e.g. Mia, Jess)" "Mia"
$FactCheckerName  = PromptValue "Name for the fact-checker team member (e.g. Vera, Cal)" "Vera"

Write-Host ""
Write-Host "Step 2 of 3 - Choose your models"
Write-Host ""
Write-Host "  (These are Claude model IDs. Defaults are current Anthropic models.)"
Write-Host ""

$HighCapabilityModel = PromptValue "High-capability model (deep research, complex reasoning)" "claude-opus-4-8"
$MidTierModel        = PromptValue "Mid-tier model (most general tasks)" "claude-sonnet-4-6"
$FastModel           = PromptValue "Fast model (simple lookups, formatting, short edits)" "claude-haiku-4-5-20251001"

Write-Host ""
Write-Host "Step 3 of 3 - Choose a destination"
Write-Host ""

# Default target dir: named after the assistant, placed outside the kit folder.
$AssistantNameLower   = ToLower $AssistantName
$ResearcherNameLower  = ToLower $ResearcherName
$HrNameLower          = ToLower $HrName
$WriterNameLower      = ToLower $WriterName
$FactCheckerNameLower = ToLower $FactCheckerName

# Determine the default output location. Normally one level up from the kit.
# When OneDrive downloads a duplicate it wraps the kit in a numbered folder
# (e.g. "personal_ai_assistant_starter_kit 4\personal_ai_assistant_starter_kit").
# In that case we skip the wrapper so the assistant lands next to the wrapper,
# not inside it.
$_kitLeaf    = Split-Path -Leaf $ScriptDir
$_parentDir  = Split-Path -Parent $ScriptDir
$_parentLeaf = Split-Path -Leaf $_parentDir
if ($_parentLeaf -match "^$([regex]::Escape($_kitLeaf))(\s+\d+)?$") {
    $DefaultTargetDir = Join-Path (Split-Path -Parent $_parentDir) $AssistantNameLower
} else {
    $DefaultTargetDir = Join-Path $_parentDir $AssistantNameLower
}
$TargetDir = PromptValue "Where to create the folder" $DefaultTargetDir

# Strip trailing slashes to avoid Split-Path -Leaf returning empty string.
$TargetDir = $TargetDir.TrimEnd('\', '/')

# ── Validate inputs ────────────────────────────────────────────────────────────

# Light character check: warn if names contain characters unsafe in filenames.
$unsafeChars = [System.IO.Path]::GetInvalidFileNameChars() + @('\', '/')
$namesToCheck = @{
    "assistant name"   = $AssistantName
    "owner name"       = $OwnerName
    "researcher name"  = $ResearcherName
    "HR name"          = $HrName
    "writer name"      = $WriterName
    "fact-checker name"= $FactCheckerName
}
foreach ($entry in $namesToCheck.GetEnumerator()) {
    foreach ($ch in $unsafeChars) {
        if ($entry.Value.IndexOf($ch) -ge 0) {
            Die "`"$($entry.Value)`" (${entry.Key}) contains characters that are not safe in filenames." `
                'Please avoid: / \ : * ? " < > |'
        }
    }
}

# Guard: resolve both paths to their canonical full paths so that the
# containment checks below work regardless of trailing slashes or relative segments.
$ScriptDirFull = (Resolve-Path $ScriptDir).Path.TrimEnd('\')
# TargetDir may not exist yet, so we resolve its parent and append the leaf name.
$TargetDirFull = (Join-Path (Resolve-Path (Split-Path -Parent $TargetDir)).Path (Split-Path -Leaf $TargetDir)).TrimEnd('\')

# Refuse if TargetDir is equal to, or nested inside, ScriptDir.
# That would cause robocopy to copy source into itself (infinite recursion).
if ($TargetDirFull -eq $ScriptDirFull -or $TargetDirFull.StartsWith($ScriptDirFull + '\')) {
    Die "Target directory cannot be inside the starter kit folder." `
        "Choose a location outside the kit folder, e.g.: $(Split-Path -Parent $ScriptDirFull)\$AssistantNameLower"
}

# Refuse if ScriptDir is nested inside TargetDir.
# With -Force that would Remove-Item the source tree before copying from it.
if ($ScriptDirFull.StartsWith($TargetDirFull + '\')) {
    $suggestedPath = Join-Path (Split-Path -Parent $ScriptDirFull) $AssistantNameLower
    Die "The starter kit folder is inside the chosen target directory." `
        "Choose a location that does not contain the kit folder, e.g.: $suggestedPath"
}

# Refuse to overwrite unless -Force.
if ((Test-Path $TargetDir) -and -not $Force) {
    Die "Target directory already exists: $TargetDir" `
        "Pass -Force to overwrite it, or choose a different directory."
}

# ── Summary before acting ──────────────────────────────────────────────────────

Write-Host ""
Write-Host "What is about to happen"
Write-Host "-----------------------"
Write-Host "  Assistant name   : $AssistantName  (lower: $AssistantNameLower)"
Write-Host "  Owner name       : $OwnerName"
Write-Host "  Researcher       : $ResearcherName  (lower: $ResearcherNameLower)"
Write-Host "  HR director      : $HrName  (lower: $HrNameLower)"
Write-Host "  Writer/editor    : $WriterName  (lower: $WriterNameLower)"
Write-Host "  Fact-checker     : $FactCheckerName  (lower: $FactCheckerNameLower)"
Write-Host "  High-cap model   : $HighCapabilityModel"
Write-Host "  Mid-tier model   : $MidTierModel"
Write-Host "  Fast model       : $FastModel"
Write-Host "  Output folder    : $TargetDir"
Write-Host "  Overwrite        : $Force"
Write-Host "  Dry-run          : $DryRun"
Write-Host ""

if (-not $DryRun) {
    Write-Host -NoNewline "Press Enter to continue, or Ctrl-C to cancel. "
    Read-Host | Out-Null
    Write-Host ""
}

# ── Copy template files ────────────────────────────────────────────────────────

Write-Host "Copying template files..."

if ($Force -and (Test-Path $TargetDir) -and -not $DryRun) {
    try {
        Remove-Item -Recurse -Force $TargetDir
    } catch {
        Die "Could not remove existing target directory: $TargetDir" $_.Exception.Message
    }
}

Preview "Create target directory: $TargetDir" {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# Copy entire kit tree. We use robocopy on the real run because it handles
# long paths, preserves attributes, and copies hidden files (.gitkeep etc).
# /E = include subdirs including empty ones, /NFL /NDL /NJH /NJS = quiet output.
# Note: the & call operator (not Start-Process) is required so PowerShell
# properly quotes arguments that contain spaces or Unicode characters.
Preview "  copy all kit files into $TargetDir" {
    & robocopy $ScriptDir $TargetDir /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    $rc = $LASTEXITCODE
    # robocopy exit codes 0-7 are success (8+ indicate errors).
    if ($rc -ge 8) {
        throw "robocopy exited with code $rc"
    }
}

if (-not $DryRun) {
    # Remove the setup scripts from the copy -- they belong to the kit,
    # not the user's working folder.
    $scriptsToPurge = @('setup.sh', 'setup.ps1', 'setup.bat')
    foreach ($s in $scriptsToPurge) {
        $p = Join-Path $TargetDir $s
        if (Test-Path $p) { Remove-Item $p -Force }
    }
}

# Show what was copied (always list from source for user awareness).
$allSourceItems = Get-ChildItem -Path $ScriptDir -Recurse -Force | Sort-Object FullName
foreach ($item in $allSourceItems) {
    $rel = $item.FullName.Substring($ScriptDir.Length).TrimStart('\', '/')
    if ($rel -in @('setup.sh', 'setup.ps1', 'setup.bat')) { continue }
    Info "  copied $rel"
}

# ── Substitute placeholders ────────────────────────────────────────────────────

Write-Host "Substituting placeholders..."

# Build ordered list of [pattern, replacement] pairs.
# Order: _lower variants before bare names to avoid partial-match corruption.
$substitutions = [ordered]@{
    '<CUSTOMIZE: assistant_name>'          = $AssistantName
    '<CUSTOMIZE: owner_name>'              = $OwnerName
    '<CUSTOMIZE: researcher_name_lower>'   = $ResearcherNameLower
    '<CUSTOMIZE: researcher_name>'         = $ResearcherName
    '<CUSTOMIZE: hr_name_lower>'           = $HrNameLower
    '<CUSTOMIZE: hr_name>'                 = $HrName
    '<CUSTOMIZE: writer_name_lower>'       = $WriterNameLower
    '<CUSTOMIZE: writer_name>'             = $WriterName
    '<CUSTOMIZE: fact_checker_name_lower>' = $FactCheckerNameLower
    '<CUSTOMIZE: fact_checker_name>'       = $FactCheckerName
    '<CUSTOMIZE: high_capability_model>'   = $HighCapabilityModel
    '<CUSTOMIZE: mid_tier_model>'          = $MidTierModel
    '<CUSTOMIZE: fast_model>'              = $FastModel
}

if ($DryRun) {
    # Target doesn't exist in dry-run; enumerate source files instead.
    $filesToProcess = Get-ChildItem -Path $ScriptDir -Recurse -File -Force | Sort-Object FullName
    foreach ($f in $filesToProcess) {
        $rel = $f.FullName.Substring($ScriptDir.Length).TrimStart('\', '/')
        if ($f.Name -eq '.gitkeep') { continue }
        if ($rel -in @('setup.sh', 'setup.ps1', 'setup.bat')) { continue }
        Preview "  substitute in $rel" {}
    }
} else {
    $filesToProcess = Get-ChildItem -Path $TargetDir -Recurse -File -Force | Sort-Object FullName
    foreach ($f in $filesToProcess) {
        $rel = $f.FullName.Substring($TargetDir.Length).TrimStart('\', '/')
        if ($f.Name -eq '.gitkeep') { continue }
        if ($rel -in @('setup.sh', 'setup.ps1', 'setup.bat')) { continue }

        Preview "  substitute in $rel" {
            try {
                $content = Get-Content -Path $f.FullName -Raw -Encoding UTF8
                if ($null -eq $content) { return }
                foreach ($entry in $substitutions.GetEnumerator()) {
                    $escapedPattern     = EscapeRegex $entry.Key
                    $escapedReplacement = EscapeReplacement $entry.Value
                    $content = $content -replace $escapedPattern, $escapedReplacement
                }
                # Write back with UTF-8, no BOM (Set-Content -Encoding UTF8 adds BOM
                # on PS 5.1, so we use the .NET writer directly).
                [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.UTF8Encoding]::new($false))
            } catch {
                Die "Could not process file: $($f.FullName)" $_.Exception.Message
            }
        }
    }
}

# ── Rename team template files ─────────────────────────────────────────────────

Write-Host "Renaming team files..."

$ResearcherSrc = Join-Path $TargetDir "team\researcher_template.md"
$ResearcherDst = Join-Path $TargetDir "team\$ResearcherNameLower.md"
if ((Test-Path $ResearcherSrc) -or $DryRun) {
    Preview "  rename team\researcher_template.md -> team\$ResearcherNameLower.md" {
        Move-Item -Path $ResearcherSrc -Destination $ResearcherDst -Force
    }
}

$HrSrc = Join-Path $TargetDir "team\hr_template.md"
$HrDst = Join-Path $TargetDir "team\$HrNameLower.md"
if ((Test-Path $HrSrc) -or $DryRun) {
    Preview "  rename team\hr_template.md -> team\$HrNameLower.md" {
        Move-Item -Path $HrSrc -Destination $HrDst -Force
    }
}

$WriterSrc = Join-Path $TargetDir "team\writer_template.md"
$WriterDst = Join-Path $TargetDir "team\$WriterNameLower.md"
if ((Test-Path $WriterSrc) -or $DryRun) {
    Preview "  rename team\writer_template.md -> team\$WriterNameLower.md" {
        Move-Item -Path $WriterSrc -Destination $WriterDst -Force
    }
}

$FactCheckerSrc = Join-Path $TargetDir "team\fact_checker_template.md"
$FactCheckerDst = Join-Path $TargetDir "team\$FactCheckerNameLower.md"
if ((Test-Path $FactCheckerSrc) -or $DryRun) {
    Preview "  rename team\fact_checker_template.md -> team\$FactCheckerNameLower.md" {
        Move-Item -Path $FactCheckerSrc -Destination $FactCheckerDst -Force
    }
}

# ── Done ───────────────────────────────────────────────────────────────────────

if ($DryRun) {
    Write-Host ""
    Write-Host "Dry run complete. No files were written."
    Write-Host "Remove -DryRun and re-run when you are ready to go."
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "Done. Your assistant is ready."
Write-Host "------------------------------"
Write-Host ""
Write-Host "  Folder   : $TargetDir"
Write-Host "  Assistant: $AssistantName"
Write-Host "  Team     : $ResearcherName (researcher), $HrName (HR), $WriterName (writer), $FactCheckerName (fact-checker)"
Write-Host ""
Write-Host "Next steps:"
Write-Host ""
Write-Host "  1. Open Claude Code and point it at your new folder."
Write-Host "     In a terminal (Command Prompt or PowerShell), run:"
Write-Host "       cd `"$TargetDir`""
Write-Host "       claude"
Write-Host ""
Write-Host "  2. Claude will read CLAUDE.md, introduce itself as $AssistantName,"
Write-Host "     and confirm the folder scaffold is in place."
Write-Host ""
Write-Host "  3. Give $AssistantName your first task -- in chat, or by dropping"
Write-Host "     a file into team_inbox/."
Write-Host ""
Write-Host "That is it. No build step, no dependencies, no further configuration needed."
Write-Host ""
