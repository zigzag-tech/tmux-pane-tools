#!/usr/bin/env bash
set -euo pipefail

script_path="${BASH_SOURCE[0]}"
while [[ -L "$script_path" ]]; do
  script_dir="$(cd -P "$(dirname "$script_path")" >/dev/null 2>&1 && pwd)"
  script_path="$(readlink "$script_path")"
  [[ "$script_path" != /* ]] && script_path="${script_dir}/${script_path}"
done
script_dir="$(cd -P "$(dirname "$script_path")" >/dev/null 2>&1 && pwd)"
repo_root="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd)"

bin_dir="${INSTALL_BIN_DIR:-$HOME/.local/bin}"
skill_name="tmux-pane-tools"

mkdir -p "$bin_dir"

for command in layout even-panes rename; do
  source_path="${repo_root}/bin/${command}"
  if [[ ! -x "$source_path" ]]; then
    echo "error: missing executable $source_path" >&2
    exit 1
  fi
  ln -sfn "$source_path" "${bin_dir}/${command}"
  echo "linked ${bin_dir}/${command} -> ${source_path}"
done

skill_dirs=(
  "$HOME/.codex/skills"
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
  "$HOME/.cursor/skills"
  "$HOME/.cursor/skills-cursor"
)

for skill_dir in "${skill_dirs[@]}"; do
  mkdir -p "$skill_dir"
  ln -sfn "$repo_root" "${skill_dir}/${skill_name}"
  echo "linked ${skill_dir}/${skill_name} -> ${repo_root}"
done

if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
  echo "note: add ${bin_dir} to PATH to run these commands from any shell" >&2
fi
