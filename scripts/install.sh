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

shell_path_value="$bin_dir"
if [[ "$bin_dir" == "$HOME" ]]; then
  shell_path_value='$HOME'
elif [[ "$bin_dir" == "$HOME/"* ]]; then
  shell_path_value="\$HOME/${bin_dir#"$HOME/"}"
fi

install_path_block() {
  local rc_file=$1
  local marker_start="# >>> tmux-pane-tools >>>"
  local marker_end="# <<< tmux-pane-tools <<<"
  local block
  local tmp_file

  mkdir -p "$(dirname "$rc_file")"
  touch "$rc_file"
  tmp_file="$(mktemp)"

  awk -v start="$marker_start" -v end="$marker_end" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    skip != 1 { print }
  ' "$rc_file" >"$tmp_file"

  block="${marker_start}
# Added by tmux-pane-tools. Keep this block managed by scripts/install.sh.
case \":\$PATH:\" in
  *\":${shell_path_value}:\"*) ;;
  *) export PATH=\"${shell_path_value}:\$PATH\" ;;
esac
${marker_end}"

  {
    cat "$tmp_file"
    printf '\n%s\n' "$block"
  } >"$rc_file"
  rm -f "$tmp_file"
  echo "updated PATH in $rc_file"
}

for command in layout even-panes rename; do
  source_path="${repo_root}/bin/${command}"
  if [[ ! -x "$source_path" ]]; then
    echo "error: missing executable $source_path" >&2
    exit 1
  fi
  ln -sfn "$source_path" "${bin_dir}/${command}"
  echo "linked ${bin_dir}/${command} -> ${source_path}"
done

rc_files=()
case "$(basename "${SHELL:-}")" in
  zsh) rc_files+=("$HOME/.zshrc") ;;
  bash) rc_files+=("$HOME/.bashrc") ;;
esac

for candidate in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
  if [[ -f "$candidate" ]]; then
    rc_files+=("$candidate")
  fi
done

if [[ ${#rc_files[@]} -eq 0 ]]; then
  rc_files+=("$HOME/.profile")
fi

seen_rc_files=" "
for rc_file in "${rc_files[@]}"; do
  if [[ "$seen_rc_files" == *" $rc_file "* ]]; then
    continue
  fi
  seen_rc_files="${seen_rc_files}${rc_file} "
  install_path_block "$rc_file"
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

echo "installed commands: layout, even-panes, rename"
echo "open a new shell or source the updated shell rc file before using them"
