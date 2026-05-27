# tmux-pane-tools

Small tmux utilities for repeatable pane setup:

- `layout`: rebuild the current tmux window into a supported grid.
- `even-panes`: even out panes, including explicit `ROWSxCOLS` grids.
- `rename`: rename the current tmux session, defaulting to the current directory name.

The repository root is also an Agent Skill. If you give this GitHub link to a coding agent, it should clone the repository, read `SKILL.md`, and install the utilities and skill links on its own.

## Install

```bash
git clone https://github.com/zigzag-tech/tmux-pane-tools.git
cd tmux-pane-tools
./scripts/install.sh
```

The installer links the commands into `~/.local/bin` by default, adds that directory to target shell startup files with a managed PATH block, and links this repository as a skill into known agent skill directories.

Open a new shell after install, or source the updated shell rc file, before using the commands.

## Commands

```bash
layout 2x3
layout 2 2
even-panes
even-panes 3x2
even-panes h
even-panes v
even-panes t
rename my-session
rename
```

`layout` currently supports `1x4`, `2x2`, `2x3`, `3x2`, and `3x3`.

## Agent Skill

Install as a Codex skill:

```bash
mkdir -p ~/.codex/skills
ln -sfn "$PWD" ~/.codex/skills/tmux-pane-tools
```

Install as a Claude Code skill:

```bash
mkdir -p ~/.claude/skills
ln -sfn "$PWD" ~/.claude/skills/tmux-pane-tools
```

After installing a new skill, restart the agent if it does not detect new skill directories live.

## Requirements

- Bash
- tmux
- awk
- perl
- zsh for new panes created by `layout`

## Test

```bash
./scripts/test-even-panes-grid.sh
./scripts/test-layout-path.sh
```
