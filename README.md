# Freebuff-Termux

Tailored packaging of [Freebuff](https://freebuff.com) (free CLI coding agent)
for Android via Termux — same idea as `opencode-termux`: stock upstream +
a tiny patch set that makes the glibc binary run under bionic.

## Why not plain `npm install -g freebuff`?

Three Termux walls, all handled here (details in `docs/PLATFORM.md`):

1. **npm refuses to install** — npm sees `os=android`, the package wants
   `darwin,linux,win32`. Fix: `npm install -g freebuff --force` (bin entry is
   pure JS, installs fine).
2. **Bad shebang** — `#!/usr/bin/env node` doesn't exist on Termux.
   Fix: `termux-fix-shebang`.
3. **Launcher rejects the platform + the binary can't exec** — node reports
   `android-arm64`, no matching download; the glibc binary has no `/lib`
   loader. Fix: `patches/0001-android-glibc-loader.patch` aliases android→
   `linux-arm64` and spawns the binary through the explicit glibc loader.
   No root needed. (patchelf is NOT used — it corrupts Bun single-file
   payloads and segfaults.)

## Quick start (Termux)

```bash
# one-time deps
apt install -y glibc-repo && apt update && apt install -y glibc glibc-runner nodejs

make install              # full install (auto-detects platform)
make install VER=0.0.173  # pin wrapper version
make update               # refresh wrapper to latest + re-patch + verify

cd ~/my-project
freebuff
```

Plain Linux: `make install` works too — the patch self-disables off Android.

## Repo layout (mirrors opencode-termux)

```
install.sh                 thin conductor: banner + one line per step
Makefile                   install | update | patch | verify | status | selfcheck
scripts/lib/common.sh      palette, platform detect, step/log/die/spinner helpers
scripts/steps/             01-requirements … 06-done (sourced by install.sh)
scripts/                   apply-patches.sh, update-freebuff.sh, status.sh
patches/                   0001-android-glibc-loader.patch + ANDROID-PATCHES.md
docs/                      PLATFORM.md — the full technical story
```

## Maintenance

npm overwrites `node_modules` on every update, wiping the patch. After any
`npm install -g freebuff`, re-apply:

```bash
make patch        # or ./scripts/apply-patches.sh
make selfcheck    # confirm patches present
make update V=latest   # update wrapper + re-patch + verify, in one step
```

## Env overrides (all optional)

| Var | Default | Purpose |
|---|---|---|
| `FREEBUFF_VERSION` | `0.0.173` | pin wrapper version in install/update |
| `FREEBUFF_GLIBC_LIB` | `$PREFIX/glibc/lib` | glibc lib dir for `--library-path` |
| `FREEBUFF_GLIBC_LOADER` | `$FREEBUFF_GLIBC_LIB/ld-linux-aarch64.so.1` | explicit loader binary |
| `FREEBUFF_BINARY_TARGET` / `CODEBUFF_BINARY_TARGET` / `CLI_BINARY_TARGET` | auto (`linux-arm64` on android) | upstream target override (explicit env wins) |
