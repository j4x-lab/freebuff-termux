#!/usr/bin/env bash
# apply-patches.sh — (re)apply freebuff-termux patches to the installed npm module.
# Idempotent: skips hunks already present (marker: "freebuff-termux").
# Re-run after every `npm install -g freebuff` (npm overwrites node_modules).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MOD_DIR="${PREFIX:-/data/data/com.termux/files/usr}/lib/node_modules/freebuff"
LAUNCHER="$MOD_DIR/launcher.js"
PATCH="$ROOT_DIR/patches/0001-android-glibc-loader.patch"

if [[ ! -f "$LAUNCHER" ]]; then
  echo "apply-patches: $LAUNCHER not found — run install.sh first" >&2
  exit 1
fi

if grep -q "freebuff-termux" "$LAUNCHER"; then
  echo "apply-patches: patches already applied, skipping"
  exit 0
fi

# -p1 strips the a/ b/ prefixes; launcher.js sits at the module root.
patch -p1 --directory="$MOD_DIR" < "$PATCH"
echo "apply-patches: 0001-android-glibc-loader.patch applied"
