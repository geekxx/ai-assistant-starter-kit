# Personal AI Assistant Starter Kit

## Before You Begin

This kit runs inside **Claude Code**, not the regular claude.ai web chat. The web chat cannot create folders or files on your machine, which the setup requires. Claude Code can.

Claude Code is available as a desktop app (Mac and Windows), a command-line tool, and as extensions for VS Code and JetBrains. If you are not a developer, the desktop app is the simplest choice.

Install it from: **https://claude.com/claude-code**

Once Claude Code is installed, come back here and follow the Quick Start steps below.

---

## Quick Start

Run the setup script once. It will ask you a few questions and create a
customized, ready-to-use folder.

### Mac or Linux

```bash
cd personal_ai_assistant_starter_kit
bash setup.sh
```

The script creates your assistant folder **next to** `personal_ai_assistant_starter_kit`,
not inside it. For example, if you name your assistant "Nova", the result will be a
folder called `nova/` sitting alongside the kit folder.

To preview what it will do without writing anything:

```bash
bash setup.sh --dry-run
```

To overwrite an existing target directory:

```bash
bash setup.sh --force
```

Full usage:

```bash
bash setup.sh --help
```

### Windows

**Easiest — double-click `setup.bat`.** It handles everything automatically.

If you prefer to run from a terminal (Command Prompt or PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

The `-ExecutionPolicy Bypass` flag is needed because Windows may block unsigned
scripts by default. It applies only to this single run; it does not change any
system setting.

Preview without writing anything:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -DryRun
```

Overwrite an existing target directory:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Force
```

Full usage:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Help
```

---

The script will prompt you for:

- Your assistant's name (e.g. "Nova")
- Your own name, as the assistant should address you
- Names for the four founding team members (researcher, HR, writer, fact-checker)
- Three Claude model IDs (high-capability, mid-tier, fast) — defaults are current Anthropic models

When it finishes, it prints the exact commands to open Claude Code on your new folder.

---

## What This Is

A ready-to-use scaffold for building a personal AI assistant team in Claude Code. Run the setup script (or fill in the placeholders by hand), and you have a working orchestrator with four founding team members and a self-expanding hiring process. The assistant coordinates; it never does the work directly.

## How It Works

The assistant (named by you) acts as a single point of contact: all requests go to the assistant, all output comes back through it. When a task lands outside the current team's capabilities, the researcher investigates what a real expert in that domain would know, hands the brief to the HR director, who creates a new team member profile. From that point on, the new specialist is part of the team.

## First Run

Open the folder as your Claude Code project. Claude will read `CLAUDE.md`, check whether the scaffold folders exist, create any that are missing, and introduce itself as your assistant. After that, you can start giving it tasks directly in chat or by dropping files into `team_inbox/`.

## Optional Cleanup

The bootstrap block at the bottom of `CLAUDE.md` is safe to delete once you have confirmed the scaffold is set up correctly and you understand how it works. It does nothing if the folders already exist, so leaving it in place is equally fine.

---

## If You'd Rather Do It by Hand

You can skip the script and customize the files manually. Replace every `<CUSTOMIZE: slot_name>` placeholder with your chosen value across the template files, then rename `CLAUDE.template.md` to `CLAUDE.md` in your working directory. The slots are:

| Slot | Description |
|------|-------------|
| `assistant_name` | The name you give your AI assistant (e.g., "Alex", "Max") |
| `owner_name` | Your own name, as the assistant should address or refer to you |
| `researcher_name` | The name you give the researcher team member |
| `researcher_name_lower` | Lowercase version of `researcher_name`, used for file paths (e.g., `alex` → `team/alex.md`) |
| `hr_name` | The name you give the HR team member |
| `hr_name_lower` | Lowercase version of `hr_name`, used for file paths |
| `writer_name` | The name you give the writer/editor team member |
| `writer_name_lower` | Lowercase version of `writer_name`, used for file paths |
| `fact_checker_name` | The name you give the fact-checker team member |
| `fact_checker_name_lower` | Lowercase version of `fact_checker_name`, used for file paths |
| `high_capability_model` | Model ID for complex, deep-reasoning tasks (e.g., `claude-opus-4-8`) |
| `mid_tier_model` | Model ID for most general tasks (e.g., `claude-sonnet-4-6`) |
| `fast_model` | Model ID for simple, fast tasks (e.g., `claude-haiku-4-5-20251001`) |

After substituting all slots, rename the two team template files to match your chosen names:

- `team/researcher_template.md` → `team/<researcher_name_lower>.md`
- `team/hr_template.md` → `team/<hr_name_lower>.md`

### Worked Example

A colleague named **Priya** sets up her own assistant. Here is how she fills the slots:

**Before (placeholder):**
```
You are **<CUSTOMIZE: assistant_name>**, <CUSTOMIZE: owner_name>'s personal AI assistant.
```

**After (filled):**
```
You are **Nova**, Priya's personal AI assistant.
```

She names her researcher "Dex" (`researcher_name_lower` = `dex`), her HR director "Cleo" (`hr_name_lower` = `cleo`), her writer "Mia" (`writer_name_lower` = `mia`), and her fact-checker "Vera" (`fact_checker_name_lower` = `vera`). The four team template files become `team/dex.md`, `team/cleo.md`, `team/mia.md`, and `team/vera.md` after she renames them. She also renames `CLAUDE.template.md` to `CLAUDE.md`. She uses Sonnet as her mid-tier model, Haiku as her fast model, and Opus for deep research.

---

## Acknowledgments

The fact-checker's evidence-class markers (`[V]/[P]/[A]/[E]/[B]`) are adapted from Chris Gagné's [grounded-forge](https://github.com/chrisgagne/grounded-forge), a corpus-grounding framework for source-faithful AI assistants.
