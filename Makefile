# Freebuff for Termux — installer orchestrator (mirrors opencode-termux)

SHELL := $(if $(shell [ -x /data/data/com.termux/files/usr/bin/bash ] && echo yes),/data/data/com.termux/files/usr/bin/bash,/bin/bash)
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

IS_ANDROID := $(shell bash -c '[ -n "$${TERMUX_VERSION:-}" ] || ( [ -n "$${PREFIX:-}" ] && [ "$${PREFIX}" = "/data/data/com.termux/files/usr" ] )' && echo 1 || echo 0)

VER ?= latest
REFRESH ?= 0

.PHONY: help install update patch verify status selfcheck mcp

help:
	@echo "freebuff-termux helper"
	@echo
	@echo "Platform: $$(uname -m)  |  $(shell bash -c 'if [ -n "$${TERMUX_VERSION:-}" ] || { [ -n "$${PREFIX:-}" ] && [ "$${PREFIX}" = "/data/data/com.termux/files/usr" ]; }; then echo "Termux"; else echo "Linux"; fi')"
	@echo
	@echo "Quick start:"
	@echo "  make install              # full install (auto-detects platform)"
	@echo "  make install VER=0.0.173  # pin wrapper version"
	@echo "  make update               # refresh wrapper to latest + re-patch + verify"
	@echo
	@echo "Utilities:"
	@echo "  make patch                # (re)apply launcher patch only"
	@echo "  make verify               # smoke-test the installed binary"
	@echo "  make status               # show wrapper / binary / patch state"
	@echo "  make selfcheck            # confirm patches present + binary execs"
	@echo "  make mcp                  # write ~/.agents/mcp.json (engram+graphify) + smoke-test"

install:
	@VER="$(VER)" REFRESH="$(REFRESH)" bash ./install.sh

update:
	@$(MAKE) install VER=latest REFRESH=1

patch:
	@bash ./scripts/apply-patches.sh

verify:
	@freebuff --version && freebuff --help | head -5

status:
	@bash ./scripts/status.sh

selfcheck:
	@MOD="$(PREFIX)/lib/node_modules/freebuff/launcher.js"; \
	if [ ! -f "$$MOD" ]; then echo "selfcheck: freebuff not installed (make install)"; exit 1; fi; \
	grep -q "freebuff-termux" "$$MOD" || { echo "selfcheck: patches MISSING (make patch)"; exit 1; }; \
	freebuff --version >/dev/null 2>&1 || { echo "selfcheck: binary does not run"; exit 1; }; \
	echo "selfcheck: patches applied OK, binary runs OK"

mcp:
	@bash ./scripts/setup-mcp.sh
