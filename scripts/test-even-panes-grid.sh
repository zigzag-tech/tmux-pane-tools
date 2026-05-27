#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

cat >"$tmp_dir/bin/tmux" <<'TMUX'
#!/usr/bin/env bash
set -euo pipefail

case "$1" in
  set-window-option|detach-client|resize-window)
    exit 0
    ;;
  list-panes)
    for (( i = 0; i < TMUX_FAKE_PANES; i++ )); do
      printf '%%%s\n' "$i"
    done
    ;;
  display-message)
    printf '%s %s\n' "$TMUX_FAKE_WIDTH" "$TMUX_FAKE_HEIGHT"
    ;;
  select-layout)
    printf '%s\n' "$2" >"$TMUX_FAKE_LAYOUT_OUT"
    ;;
  *)
    echo "unexpected tmux command: $*" >&2
    exit 1
    ;;
esac
TMUX
chmod +x "$tmp_dir/bin/tmux"

run_even_panes() {
  local panes=$1
  local width=$2
  local height=$3
  local out="$tmp_dir/layout-${panes}-${width}x${height}"

  TMUX=1 \
  TMUX_FAKE_PANES="$panes" \
  TMUX_FAKE_WIDTH="$width" \
  TMUX_FAKE_HEIGHT="$height" \
  TMUX_FAKE_LAYOUT_OUT="$out" \
  PATH="$tmp_dir/bin:$PATH" \
    "$repo_root/bin/even-panes"

  cat "$out"
}

assert_contains() {
  local value=$1
  local expected=$2
  local message=$3

  if [[ "$value" != *"$expected"* ]]; then
    echo "$message" >&2
    echo "expected to find: $expected" >&2
    echo "actual: $value" >&2
    exit 1
  fi
}

five_panes_layout="$(run_even_panes 5 80 40)"
assert_contains "$five_panes_layout" "80x40,0,0[" "5 panes should use more than one row"
assert_contains "$five_panes_layout" "80x20,0,0{" "5 panes should create a 3-pane top row"
assert_contains "$five_panes_layout" "80x19,0,21{" "5 panes should create a 2-pane bottom row"

thirteen_panes_layout="$(run_even_panes 13 160 48)"
assert_contains "$thirteen_panes_layout" "160x48,0,0[" "13 panes should use more than one row"
