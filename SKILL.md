---
name: tmux-pane-tools
description: Install and use tmux pane utilities for coding agents. Use when the user asks to install, set up, publish, or operate layout, even-panes, rename, tmux grid layouts, or this GitHub repository as an agent skill.
---

# tmux-pane-tools

Use this skill when working with the `tmux-pane-tools` repository or when the user wants tmux panes arranged, rebuilt, evened, or named consistently.

## Install From GitHub

If the user provides the repository URL, clone it first:

```bash
git clone https://github.com/zigzag-tech/tmux-pane-tools.git
cd tmux-pane-tools
./scripts/install.sh
```

If the repository is already cloned, run `./scripts/install.sh` from its root.

The installer links:

- `bin/layout`, `bin/even-panes`, and `bin/rename` into `~/.local/bin`
- the repository root into known agent skill directories, including `~/.codex/skills/tmux-pane-tools` and `~/.claude/skills/tmux-pane-tools`, creating those parent directories when needed

After install, verify with:

```bash
command -v layout
command -v even-panes
command -v rename
bash -n bin/layout bin/even-panes bin/rename scripts/*.sh
```

If `~/.local/bin` is not on `PATH`, add it in the user's shell profile.

## Command Behavior

- `layout 2x3` or `layout 2 3`: rebuilds the current tmux window into a fixed grid. Supported grids are `1x4`, `2x2`, `2x3`, `3x2`, and `3x3`.
- `even-panes`: chooses a readable grid for the current pane count and tmux window size.
- `even-panes ROWSxCOLS`: applies an explicit grid without creating or killing panes.
- `even-panes h`, `even-panes v`, `even-panes t`: delegates to tmux `even-horizontal`, `even-vertical`, or `tiled`.
- `rename NAME`: renames the current tmux session.
- `rename`: renames the current tmux session to the current directory basename.

`layout`, `even-panes`, and `rename` require an active tmux session. Do not treat "not inside a tmux session" as an install failure.

## Maintenance

Keep the repository root skill-compatible:

- Preserve `SKILL.md` at the repository root.
- Keep `agents/openai.yaml` aligned with the skill's name, description, and default prompt.
- Keep scripts under `bin/` executable.
- Add behavior tests under `scripts/test-*.sh` when changing layout logic.
