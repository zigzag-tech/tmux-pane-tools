#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
layout_script="${repo_root}/bin/layout"

if grep -Eq 'EVEN_PANES="(/home|/Users)/[^"]+/even-panes"' "$layout_script"; then
  echo "layout hard-codes an even-panes path" >&2
  exit 1
fi

if ! grep -Fq 'EVEN_PANES="${script_dir}/even-panes"' "$layout_script"; then
  echo "layout should resolve even-panes next to itself" >&2
  exit 1
fi

bash -n "$layout_script" "${repo_root}/bin/even-panes" "${repo_root}/bin/rename"
