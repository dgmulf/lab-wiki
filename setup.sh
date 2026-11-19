#!/bin/sh

set -e
exec </dev/null

uv sync --locked
rv sync --locked
GIT_TERMINAL_PROMPT=0 npx --yes skills experimental_install
