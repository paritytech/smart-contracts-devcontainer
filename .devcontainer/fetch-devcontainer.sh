#!/usr/bin/env bash

set -euo pipefail

# Configuration
REPO_URL="https://github.com/paritytech/smart-contracts-devcontainer.git"
BRANCH="${1:-main}"  # Use first argument as branch, default to 'main'
TARGET_DIR=".devcontainer"

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required but not installed" >&2
    exit 1
fi

# Create temp directory with cleanup
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Clone with sparse checkout
echo "Fetching .devcontainer from branch '$BRANCH'..."
git clone --depth=1 --branch="$BRANCH" --filter=blob:none --sparse "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
git -C "$TMP_DIR" sparse-checkout set .devcontainer >/dev/null 2>&1

# Copy to current directory (overwrite if exists)
rm -rf "$TARGET_DIR"
cp -a "$TMP_DIR/.devcontainer" "$TARGET_DIR"

echo "✓ Successfully fetched .devcontainer from $BRANCH branch"
echo "  Next: Reopen this folder in VS Code with Dev Containers"


