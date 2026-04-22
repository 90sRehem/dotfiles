#!/bin/bash
# run_onchange_install-deps.sh — reruns when package.json changes
set -euo pipefail

cd ~/.config/opencode

if command -v bun &>/dev/null; then
	bun install
elif command -v npm &>/dev/null; then
	npm install
else
	echo "ERROR: Neither bun nor npm found" >&2
	exit 1
fi

echo "✓ OpenCode dependencies installed"
