#!/usr/bin/env bash
set -euo pipefail

git submodule sync --recursive
git submodule update --init --recursive
