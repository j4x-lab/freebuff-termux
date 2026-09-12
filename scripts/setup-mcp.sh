#!/usr/bin/env bash
# setup-mcp.sh — write freebuff MCP config (engram + graphify) and smoke-test it.
# Freebuff 0.0.173 merges mcpServers from ./​.agents/mcp.json, ../.agents/mcp.json
# and ~/.agents/mcp.json, so one global file covers every project.
# Idempotent: safe to re-run (make mcp). No secrets are written — ENGRAM_TOKEN
# is inherited from the shell (exported in ~/.bashrc).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

ENGRAM_CMD="$HOME/engram/engram-wrapper.sh"
GRAPHIFY_PY="$HOME/h4xor-webui/venv/bin/python"
MCP_JSON="$HOME/.agents/mcp.json"

[[ -x "$ENGRAM_CMD" ]] || { echo "setup-mcp: $ENGRAM_CMD not found/executable" >&2; exit 1; }
if [[ ! -x "$GRAPHIFY_PY" ]] || ! "$GRAPHIFY_PY" -c "import graphify.serve" 2>/dev/null; then
  echo "setup-mcp: graphify python missing ($GRAPHIFY_PY) — engram only" >&2
  GRAPHIFY_PY=""
fi

mkdir -p "$(dirname "$MCP_JSON")"
if [[ -z "$GRAPHIFY_PY" ]]; then
  cat >"$MCP_JSON" <<EOF
{
  "mcpServers": {
    "engram": {
      "command": "$ENGRAM_CMD",
      "args": ["mcp"]
    }
  }
}
EOF
else
  cat >"$MCP_JSON" <<EOF
{
  "mcpServers": {
    "engram": {
      "command": "$ENGRAM_CMD",
      "args": ["mcp"]
    },
    "graphify": {
      "command": "$GRAPHIFY_PY",
      "args": ["-u", "-m", "graphify.serve"]
    }
  }
}
EOF
fi
chmod 600 "$MCP_JSON"
python3 -c "import json; json.load(open('$MCP_JSON'))" \
  || { echo "setup-mcp: wrote invalid JSON" >&2; exit 1; }
log "wrote $MCP_JSON"

# Smoke-test each configured server with a real MCP handshake (stdio).
# Graphify cold-start (venv import) can take 10-30s, so retry once on failure.
smoke() { # smoke <name> <cmd...>
  local name="$1" attempt out rc=1
  shift
  for attempt in 1 2; do
    # Head -n 3 (not tail -1): stdio servers idle after responding instead of
    # exiting, so waiting for EOF races the flush. Three lines = both
    # responses. The notifications/initialized message is required — some
    # servers (graphify) stall tools/list without the full handshake.
    out="$(printf '%s\n' \
      '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"setup-mcp","version":"0"}}}' \
      '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
      '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
      | timeout 90 "$@" 2>/dev/null | head -n 3 | tail -1)"
    if [[ -n "$out" ]] && python3 -c "import json,sys; print('$name tools:', len(json.loads(sys.argv[1])['result']['tools']))" "$out" 2>/dev/null; then
      rc=0; break
    fi
    log "$name smoke attempt $attempt failed, retrying…"
    sleep 2
  done
  if [[ "$rc" != "0" ]]; then echo "setup-mcp: $name smoke FAILED" >&2; return 1; fi
}
smoke engram "$ENGRAM_CMD" mcp
[[ -n "$GRAPHIFY_PY" ]] && smoke graphify "$GRAPHIFY_PY" -u -m graphify.serve

command -v rtk >/dev/null 2>&1 && log "rtk $(rtk --version 2>/dev/null) on PATH (shell tool, no MCP entry needed)" \
  || echo "setup-mcp: rtk not on PATH" >&2
echo "setup-mcp: done — restart freebuff threads to pick up MCP servers (/mcp to inspect)"
