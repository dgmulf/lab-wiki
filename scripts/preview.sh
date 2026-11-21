#!/bin/sh
set -eu
socat TCP-LISTEN:8080,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:3000 &
exec typst watch --features html,bundle --format bundle --root /work /work/wiki.typ /work/_site --port 3000
