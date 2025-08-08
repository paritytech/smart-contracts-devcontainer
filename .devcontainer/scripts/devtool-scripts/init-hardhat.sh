# Check if the mounted directory is empty or needs initialization
if ! compgen -G "$PROJECT_DIR/hardhat.config.*" > /dev/null; then
    echo -e "${YELLOW}📦 Initializing new Polkadot Hardhat project...${STYLE_END}"
    echo -e "${GREEN}✓ Copying project template files...${STYLE_END}"
    
    # Fetch template project
    REPO="https://github.com/paritytech/smart-contracts-devcontainer.git"
    SUBDIR=".devcontainer/init-hardhat"
    DEST="$PROJECT_DIR"
    TMP="$(mktemp -d)"
    git clone --depth=1 --filter=blob:none --sparse "$REPO" "$TMP"
    git -C "$TMP" sparse-checkout set "$SUBDIR"
    cp -a "$TMP/$SUBDIR/." "$DEST/"
    rm -rf "$TMP"

    # Change to project directory
    cd $PROJECT_DIR
    
    # Install dependencies
    echo -e "${GREEN}✓ Installing dependencies (this may take a few minutes)...${STYLE_END}"
    npm install
    
    # Update @parity/hardhat-polkadot to latest version
    echo -e "${GREEN}✓ Updating @parity/hardhat-polkadot to latest version...${STYLE_END}"
    npm install --save-dev @parity/hardhat-polkadot@latest
    
    echo -e "${GREEN}✨ Project initialized successfully!${STYLE_END}"
    echo -e "${BLUE}You can now:${STYLE_END}"
    echo -e "  - Create contracts in the ${GREEN}contracts/${STYLE_END} folder"
    echo -e "  - Write tests in the ${GREEN}test/${STYLE_END} folder"
    echo -e "  - Configure deployment in ${GREEN}ignition/modules/${STYLE_END}"
    echo -e "  - Run ${GREEN}npx hardhat compile${STYLE_END} to compile contracts"
    echo -e "  - Run ${GREEN}npx hardhat test${STYLE_END} to run tests"
    echo ""
else
    # TODO! for existing projects we should still inject PolkaVM specific configurations into hardhat.config.*
    echo -e "${GREEN}✓ Existing Hardhat project detected${STYLE_END}"
    cd $PROJECT_DIR
    
    # Check and update @parity/hardhat-polkadot if needed
    if npm list @parity/hardhat-polkadot &>/dev/null; then
        echo -e "${GREEN}✓ Checking for @parity/hardhat-polkadot updates...${STYLE_END}"
        # Get current and latest versions
        CURRENT_VERSION=$(npm list @parity/hardhat-polkadot --depth=0 --json 2>/dev/null | grep -oP '"version":\s*"\K[^"]+' | head -1)
        LATEST_VERSION=$(npm view @parity/hardhat-polkadot version 2>/dev/null)
        
        if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ] && [ -n "$LATEST_VERSION" ]; then
            echo -e "${YELLOW}📦 Updating @parity/hardhat-polkadot from v${CURRENT_VERSION} to v${LATEST_VERSION}...${STYLE_END}"
            npm install --save-dev @parity/hardhat-polkadot@latest
            echo -e "${GREEN}✓ Updated successfully!${STYLE_END}"
        else
            echo -e "${GREEN}✓ @parity/hardhat-polkadot is already at the latest version (v${CURRENT_VERSION})${STYLE_END}"
        fi
    fi
fi