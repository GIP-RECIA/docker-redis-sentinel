#!/usr/bin/env bash

set -e

: ${MEMORY:=64mb}

args=("--maxmemory $MEMORY")
args+=("--maxmemory-policy allkeys-lru")

echo "*** Running $@ ${args[@]}"

exec "$@" "${args[@]}"