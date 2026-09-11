#!/usr/bin/env bash
# scripts/lib/common.sh — shared installer core (palette, platform, UI).
# Sourced by install.sh (conductor). Safe under `set -euo pipefail`.

# ── Palette (TTY-gated) ────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GRN=$'\033[38;5;40m'    # green (success)
  RED=$'\033[38;5;167m'   # muted brick (error)
  AMB=$'\033[38;5;179m'   # muted gold (warning)
  CYN=$'\033[38;5;81m'    # bright cyan (accent)
  GRY=$'\033[38;5;245m'   # warm gray (dim)
  WHT=$'\033[1;38;5;255m' # off-white bold
  B=$'\033[1m' D=$'\033[2m' RS=$'\033[0m'
else
  RED='' GRN='' AMB='' CYN='' GRY='' WHT='' B='' D='' RS=''
fi

# ── Platform ───────────────────────────────────────────────────────────────
IS_ANDROID=0
[[ -n "${TERMUX_VERSION:-}" || ( -n "${PREFIX:-}" && "${PREFIX}" == /data/data/com.termux* ) ]] && IS_ANDROID=1

MACHINE="$(uname -m)"
case "$MACHINE" in
  x86_64|amd64)  ARCH="amd64"   ;;
  aarch64|arm64) ARCH="aarch64"  ;;
  *)             ARCH="$MACHINE" ;;
esac

PLATFORM="Linux"; [[ "$IS_ANDROID" == "1" ]] && PLATFORM="Termux"

FB_TMPDIR="${TMPDIR:-/tmp}"
[[ "$IS_ANDROID" == "1" ]] && FB_TMPDIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"

MOD_DIR="${PREFIX:-/data/data/com.termux/files/usr}/lib/node_modules/freebuff"

# ── UI ─────────────────────────────────────────────────────────────────────
ensure() { mkdir -p "$@"; }

banner() {
  printf '\n  %sfreebuff-termux%s  %sTermux packaging for the free coding agent%s\n\n' \
    "$WHT" "$RS" "$GRY" "$RS"
}

step() { # step <n> <total> <label>
  printf '  %s[%s/%s]%s %s\n' "$CYN" "$1" "$2" "$RS" "$3"
}

step_done() { # step_done <0|1>
  if [[ "${1:-0}" == "0" ]]; then printf '    %s✓%s\n' "$GRN" "$RS"
  else printf '    %s✗%s\n' "$RED" "$RS"; fi
}

emit() { printf '%s\n' "$*"; }
log()  { printf '    %s·%s %s\n' "$GRY" "$RS" "$*"; }

die() { # fatal — mark step failed, print reason, exit
  step_done 1
  printf '  %s✗ %s%s\n' "$RED" "$*" "$RS" >&2
  exit 1
}

spinner() { # spinner <pid> <label> — wait, report ✓/✗, return child rc
  local pid="$1" label="${2:-working}" rc
  wait "$pid"; rc=$?
  if [[ "$rc" == "0" ]]; then log "$label — done"
  else log "$label — failed"; fi
  return "$rc"
}
