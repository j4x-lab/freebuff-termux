# Platform notes — Freebuff on Termux/aarch64

How the three walls were found and why the fix looks the way it does.

## 1. npm EBADPLATFORM

`npm install -g freebuff` fails: `wanted {"os":"darwin,linux,win32","cpu":"x64,arm64"}`
vs actual `{"os":"android","cpu":"arm64"}`. The package `bin` is just
`index.js` (a node launcher that downloads the real binary at first run), so
`npm install -g freebuff --force` installs cleanly. Verified 0.0.173.

## 2. Shebang

`$PREFIX/bin/freebuff` → `../lib/node_modules/freebuff/index.js` starts with
`#!/usr/bin/env node`, which doesn't exist on Termux (`/usr/bin/env: bad
interpreter`). `termux-fix-shebang` on `index.js` + `launcher.js` fixes it.

## 3. Launcher platform check + unexecutable glibc binary

`launcher.js#getPlatformKey()` returns `${process.platform}-${process.arch}` =
`android-arm64`; `PLATFORM_TARGETS` only has `linux-*`/`darwin-*`/`win32-*`, so
`stageBinary()` throws `Unsupported platform: android arm64`.

The launcher has a built-in escape hatch — env `FREEBUFF_BINARY_TARGET`
(also `CODEBUFF_BINARY_TARGET`, `CLI_BINARY_TARGET`). The patch in
`patches/` defaults that override to `linux-arm64` on android, so no env
setup is needed; an explicit env var still wins.

The downloaded `~/.config/manicode/freebuff` (131.9 MB, 0.0.173) is a
glibc-linked Bun binary (`INTERP /lib/ld-linux-aarch64.so.1`, needs
libc/pthread/dl/m — all shipped by Termux's `glibc` package). Two ways to run
it were tried:

- **patchelf** (`--set-interpreter $PREFIX/glibc/lib/ld-linux-aarch64.so.1`
  `--set-rpath …`): binary execs but dies with **SIGSEGV before its first
  syscall** (strace via root: loader maps libc/pthread/dl/m, then
  `SEGV_MAPERR si_addr=0x5a7ac0b2`). Root (`su`) segfaults identically, so it
  is not the app seccomp profile. Cause: patchelf rewrites section headers the
  Bun single-file payload locator depends on. **Do not patchelf Bun binaries.**
- **Explicit loader** (works, this repo's approach): the pristine binary runs
  clean —
  `$PREFIX/glibc/lib/ld-linux-aarch64.so.1 --library-path $PREFIX/glibc/lib
  ~/.config/manicode/freebuff --help` → full help, rc=0.
  The patch makes the launcher spawn exactly that argv on android. No root,
  no `/lib` symlink, binary untouched (survives launcher integrity logic;
  only wiped by npm updates — see `make patch`).

## Kernel note

Device kernel 4.19 satisfies the binary's `NT_GNU_ABI_TAG 3.7.0`. glibc 2.44
from glibc-repo runs fine. No faccessat2-style seccomp issue observed for this
binary (unlike Engram's case).
