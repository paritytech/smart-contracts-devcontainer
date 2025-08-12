PROJECT_TYPE="$1"
if [[ -z "$PROJECT_TYPE" || ! "$PROJECT_TYPE" =~ ^(hardhat|foundry)$ ]]; then
    echo "Usage: $0 <hardhat|foundry>"
    exit 1
fi

marker='foundry.toml'
[[ "$PROJECT_TYPE" == "hardhat" ]] && marker='hardhat.config.*'


ROOT="${PROJECT_DIR:-$PWD}"
abspath_dir() { (cd "$1" >/dev/null 2>&1 && pwd -P) || return 1; }

# Ignore key directories
PRUNE_DIRS=(.git node_modules target dist out build .next .turbo .cache .devcontainer forge-std)
prune_name_args=()
for d in "${PRUNE_DIRS[@]}"; do
  prune_name_args+=(-name "$d" -o)
done
unset 'prune_name_args[${#prune_name_args[@]}-1]'



declare -A seen

while IFS= read -r -d '' f; do
  dir="$(abspath_dir "$(dirname "$f")")"
  seen["$dir"]=1
done < <(find "$ROOT" \( -type d \( "${prune_name_args[@]}" \) -prune \) -o \
         -type f -name "$marker" -print0)

for dir in "${!seen[@]}"; do
  printf '%s\n' "$dir"
done | sort