echo -e "${BLUE}🚀 Polkadot Smart Contract DevContainer${STYLE_END}"
echo -e "${BLUE}============================================${STYLE_END}"

# Exit early if not first setup
if [ -d "$HOME/.devtools" ]; then
  exit 0
fi
mkdir -p "$HOME/.devtools"

# Find & initialize all existing projects
hardhat_projects=$(devtools detect-projects hardhat)
foundry_projects=$(devtools detect-projects foundry)
n_projects=$(echo $hardhat_projects $foundry_projects | wc -w)

# Hardhat: Find which projects need migration & present UI
needs_migration=()
if [ $(echo $hardhat_projects | wc -w) -gt 0 ]; then
    echo -e "${PINK}┌${STYLE_END} \033[48;2;208;75;208m Hardhat ${STYLE_END} Projects Detected"
    echo -e "${PINK}│${STYLE_END}"
    while read -r directory; do
        if ! jq -e --arg name "@parity/hardhat-polkadot" \
        '(.dependencies?[$name] // .devDependencies?[$name])' $directory/package.json >/dev/null
        then
            echo -e "${PINK}├${STYLE_END} $YELLOW▲$STYLE_END $directory"
            needs_migration+=("$directory")
        else
            echo -e "${PINK}├${STYLE_END} $GREEN●$STYLE_END $directory"
        fi
    done <<< "$hardhat_projects"
    echo ""
fi

# Foundry: present UI
if [ $(echo $foundry_projects | wc -w) -gt 0 ]; then
    echo -e "${PINK}┌${STYLE_END} \033[48;2;208;75;208m Foundry ${STYLE_END} Projects Detected"
    echo -e "${PINK}│${STYLE_END}"
    while read -r directory; do
        echo -e "${PINK}├${STYLE_END} $GREEN●$STYLE_END $directory"
    done <<< "$foundry_projects"
    echo ""
fi

# Apply migrations if needed
if [ ${#needs_migration[@]} -gt 0 ]; then
    while true; do
        echo -e "$YELLOW$BOLD${#needs_migration[@]}$STYLE_END detected hardhat project(s) are incompatible with the Polkadot Ecosystem."
        read -n 1 -r -p "Would you like to  apply auto-migrations to these projects? [y/n] " ans
        echo ""
        case "$ans" in
        [Yy]) DO_MIGRATION="y"; break ;;
        [Nn]) DO_MIGRATION="n"; break ;;
        *) echo "Please type 'y' or 'n'." ;;
        esac
    done
    if [ "$DO_MIGRATION" = "y" ]; then
        for dir in "${needs_migration[@]}"; do
            source devtools init-hardhat "$dir"
            echo -e "${YELLOW}⚙️  Migrating project at $dir ...${STYLE_END}"
            npx @parity/hardhat-polkadot port "$dir" -y
            echo -e "${GREEN}✓ Migration complete for $dir${STYLE_END}"
        done
        echo ""
    else
        echo -e "${YELLOW}⚠️  Skipping migrations. You may need to manually update these projects later.${STYLE_END}"
        echo ""
    fi
fi

# If no existing projects found, create new project
if [ "$n_projects" -eq 0 ]; then
    while true; do
      read -n 1 -r -p "Initialize (h)ardhat, (f)oundry, or (N)one? [h/f/n] " ans
      echo ""
      case "$ans" in
        [Hh]) PROJECT_TYPE="hardhat"; break ;;
        [Ff]) PROJECT_TYPE="foundry"; break ;;
        [Nn]) break ;;
        *) echo "Please type 'h', 'f', or 'n'." ;;
      esac
    done

    # Initialize based on selected project type
    if [ "$PROJECT_TYPE" = "hardhat" ]; then
        source devtools init-hardhat $PROJECT_DIR
    elif [ "$PROJECT_TYPE" = "foundry" ]; then
        source devtools init-foundry
    fi
fi

# Check if running under emulation
echo -e "${BLUE}🔧 Checking runtime environment...${STYLE_END}"

# Detect architecture
ARCH=$(uname -m)
EXPECTED_ARCH="x86_64"

# Check for QEMU/Rosetta emulation
if [ -f /proc/sys/fs/binfmt_misc/qemu-x86_64 ] || [ -f /proc/sys/fs/binfmt_misc/rosetta ]; then
    echo -e "${YELLOW}⚠️  Running under emulation (QEMU/Rosetta detected)${STYLE_END}"
    EMULATION_MODE="true"
elif [ "$ARCH" != "$EXPECTED_ARCH" ]; then
    echo -e "${YELLOW}⚠️  Architecture mismatch detected:${STYLE_END}"
    echo -e "${YELLOW}   - Current arch: $ARCH${STYLE_END}"
    echo -e "${YELLOW}   - Expected arch: $EXPECTED_ARCH${STYLE_END}"
    echo -e "${YELLOW}   - Likely running under emulation${STYLE_END}"
    EMULATION_MODE="true"
else
    echo -e "${GREEN}✓ Running on native $ARCH architecture${STYLE_END}"
    EMULATION_MODE="false"
fi

# Additional emulation checks
if [ -n "$DOCKER_DEFAULT_PLATFORM" ]; then
    echo -e "${BLUE}ℹ️  DOCKER_DEFAULT_PLATFORM is set to: $DOCKER_DEFAULT_PLATFORM${STYLE_END}"
fi

# Check Docker platform info
if command -v docker >/dev/null 2>&1; then
    DOCKER_INFO=$(docker version --format '{{.Server.Arch}}' 2>/dev/null || echo "unknown")
    echo -e "${BLUE}ℹ️  Docker server architecture: $DOCKER_INFO${STYLE_END}"
fi

# Log performance warning if under emulation
if [ "$EMULATION_MODE" = "true" ]; then
    echo -e "${YELLOW}⚠️  Performance Warning: Running x86_64 binaries under emulation may be slower${STYLE_END}"
    echo -e "${YELLOW}   Consider using native ARM64 binaries for better performance${STYLE_END}"
fi
echo ""

# Additional debugging for emulation mode
if [ "$EMULATION_MODE" = "true" ]; then
    echo -e "${YELLOW}⚠️  Note: x86_64 binaries will be executed under emulation${STYLE_END}"
    echo -e "${YELLOW}   If you encounter 'rosetta error', the binaries may not be compatible${STYLE_END}"
fi