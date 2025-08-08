#!/usr/bin/env bash

set -euo pipefail

REPO_URL_DEFAULT="https://github.com/paritytech/smart-contracts-devcontainer.git"
BRANCH_DEFAULT="main"
TARGET_DIR_DEFAULT=".devcontainer"

print_usage() {
  cat <<'EOF'
Fetch the Parity Polkadot Smart Contracts DevContainer into the current project.

Usage:
  fetch-devcontainer.sh [--repo <url>] [--branch <name>] [--path <dir>] [--force]

Options:
  --repo <url>     Source repository URL (default: https://github.com/paritytech/smart-contracts-devcontainer.git)
  --branch <name>  Branch or ref to fetch (default: main)
  --path <dir>     Destination directory for the devcontainer (default: .devcontainer)
  --force          Overwrite existing destination directory if it exists
  -h, --help       Show this help

Examples:
  # In an existing or new repo/folder:
  curl -fsSL https://raw.githubusercontent.com/paritytech/smart-contracts-devcontainer/main/.devcontainer/fetch-devcontainer.sh | bash -s --

EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command not found: $1" >&2
    exit 1
  fi
}

main() {
  local repo_url="$REPO_URL_DEFAULT"
  local branch="$BRANCH_DEFAULT"
  local target_dir="$TARGET_DIR_DEFAULT"
  local force_overwrite="false"
  local original_pwd
  original_pwd="$(pwd -P)"
  # Initialize to avoid set -u errors in traps before assignment
  local tmp_root=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo)
        repo_url="${2:-}"; shift 2 ;;
      --branch)
        branch="${2:-}"; shift 2 ;;
      --path)
        target_dir="${2:-}"; shift 2 ;;
      --force)
        force_overwrite="true"; shift ;;
      -h|--help)
        print_usage; exit 0 ;;
      *)
        echo "Unknown argument: $1" >&2
        print_usage
        exit 1 ;;
    esac
  done

  if [[ -e "$target_dir" && "$force_overwrite" != "true" ]]; then
    echo "Error: destination '$target_dir' already exists. Use --force to overwrite." >&2
    exit 1
  fi

  # Ensure basic tools
  require_cmd "curl"
  require_cmd "tar"
  require_cmd "mktemp"

  tmp_root="$(mktemp -d 2>/dev/null || mktemp -d -t fetch-devcontainer)"
  cleanup() { if [[ -n "${tmp_root:-}" ]]; then rm -rf "$tmp_root"; fi; }
  trap cleanup EXIT

  echo "Fetching '.devcontainer' from $repo_url@$branch ..."

  if command -v git >/dev/null 2>&1; then
    if git --version >/dev/null 2>&1; then
      if git clone --depth=1 --filter=blob:none --sparse "$repo_url" "$tmp_root/repo" >/dev/null 2>&1; then
        (
          cd "$tmp_root/repo"
          # Try to checkout the requested branch; ignore if default already matches
          git checkout -q "$branch" 2>/dev/null || git fetch -q origin "$branch" && git checkout -q "$branch"
          git sparse-checkout set -q .devcontainer
        )
        # Copy preserving permissions into the user's original working directory
        rm -rf "$original_pwd/$target_dir"
        mkdir -p "$original_pwd/$(dirname -- "$target_dir")"
        # Copy contents of .devcontainer into target_dir
        mkdir -p "$original_pwd/$target_dir"
        tar -C "$tmp_root/repo/.devcontainer" -cf - . | tar -C "$original_pwd/$target_dir" -xpf -
        echo "Done. Wrote '$target_dir' from git sparse checkout."
        next_steps
        return 0
      fi
    fi
  fi

  echo "git sparse checkout not available; falling back to tarball download..."
  fetch_via_tarball "$repo_url" "$branch" "$target_dir" "$tmp_root" "$original_pwd"
  next_steps
}

fetch_via_tarball() {
  local repo_url="$1"
  local branch="$2"
  local target_dir="$3"
  local tmp_root="$4"
  local original_pwd="$5"

  # Convert https://github.com/org/repo(.git) to tarball URL
  local repo_path
  repo_path="${repo_url#https://github.com/}"
  repo_path="${repo_path%.git}"
  local tarball_url="https://codeload.github.com/${repo_path}/tar.gz/refs/heads/${branch}"

  local archive="$tmp_root/src.tgz"
  echo "Downloading tarball from ${tarball_url} ..."
  curl -fsSL "$tarball_url" -o "$archive"

  local extract_dir="$tmp_root/extract"
  mkdir -p "$extract_dir"
  tar -xzf "$archive" -C "$extract_dir"

  # Find top-level dir (e.g. repo-<ref>)
  local top
  top="$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -z "$top" || ! -d "$top/.devcontainer" ]]; then
    echo "Error: .devcontainer not found in tarball." >&2
    exit 1
  fi

  rm -rf "$original_pwd/$target_dir"
  mkdir -p "$original_pwd/$(dirname -- "$target_dir")"
  mkdir -p "$original_pwd/$target_dir"
  tar -C "$top/.devcontainer" -cf - . | tar -C "$original_pwd/$target_dir" -xpf -
  echo "Done. Wrote '$target_dir' from tarball."
}

next_steps() {
  cat <<'EOF'

Next steps:
  1) Open this folder in VS Code
  2) Use "Dev Containers: Reopen in Container"
  3) On first attach, choose Hardhat or Foundry when prompted

You can re-run with --force to overwrite, or use --branch/--repo/--path to customize.
EOF
}

main "$@"


