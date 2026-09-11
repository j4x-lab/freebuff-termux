#!/usr/bin/env bash
# install.sh — Freebuff unified installer (Termux + Linux).
# Thin conductor: banner, then one line per step, then the summary.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
export VER="${VER:-latest}"
export REFRESH="${REFRESH:-0}"

source "$ROOT_DIR/scripts/lib/common.sh"

banner

TOTAL_STEPS=6
for s in \
  01-requirements \
  02-version \
  03-wrapper \
  04-patches \
  05-verify \
  06-done; do
  source "$ROOT_DIR/scripts/steps/$s.sh"
done
