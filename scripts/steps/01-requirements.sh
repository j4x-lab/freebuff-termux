# Step 1 · Requirements — make sure this device is ready.
step 1 $TOTAL_STEPS "check your setup"

NODE_V="$(node --version 2>/dev/null || echo missing)"
NPM_V="$(npm --version 2>/dev/null || echo missing)"
log "node ${NODE_V#v} · npm $NPM_V · $PLATFORM/$ARCH"

command -v node >/dev/null 2>&1 || die "node not found — Termux: pkg install nodejs · Linux: install nodejs 18+"
node -e "process.exit(Number(process.versions.node.split('.')[0]) < 18 ? 1 : 0)" \
  || die "node 18+ required (found $NODE_V)"
command -v npm >/dev/null 2>&1 || die "npm not found — Termux: pkg install nodejs (bundles npm)"

if [[ "$IS_ANDROID" == "1" ]]; then
  GLIBC_LOADER="${PREFIX}/glibc/lib/ld-linux-aarch64.so.1"
  if [[ ! -f "$GLIBC_LOADER" ]]; then
    die "glibc loader missing — run: apt install -y glibc-repo && apt update && apt install -y glibc glibc-runner"
  fi
  log "glibc loader ok"
fi

step_done 0
