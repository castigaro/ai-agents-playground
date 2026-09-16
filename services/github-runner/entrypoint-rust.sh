#!/bin/bash
set -euo pipefail

# rustup without a toolchain; the jobs install the pinned one from rust-toolchain.toml.
if ! command -v rustup >/dev/null 2>&1; then
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain none
fi

exec /entrypoint.sh "$@"
