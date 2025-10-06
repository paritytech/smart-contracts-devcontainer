TARGET_DIR="$2"
if [[ -z "$TARGET_DIR" ]]; then
    echo "Usage: $0 $1 <dir>"
    exit 1
fi

# Check if the mounted directory is empty or needs initialization
if ! compgen -G "$TARGET_DIR/hardhat.config.*" > /dev/null; then
    echo -e "${YELLOW}📦 Initializing new Polkadot Hardhat project...${STYLE_END}"
    echo -e "${GREEN}✓ Copying project template files...${STYLE_END}"

    # Change to project directory
    cd $TARGET_DIR

    # Install dependencies
    echo -e "${GREEN}✓ Initializing npm project ...${STYLE_END}"
    npm init -y

    # Install the latest version of @parity/hardhat-polkadot and solc@0.8.28
    echo -e "${GREEN}✓ Installing @parity/hardhat-polkadot@latest and solc@0.8.28...${STYLE_END}"
    npm install --save-dev @parity/hardhat-polkadot@latest solc@0.8.28

    echo -e "${GREEN}✓ Initializing default hardhat-polkadot typescript project...${STYLE_END}"
    npx hardhat-polkadot init -y

    echo -e "${GREEN}✓ Downloading dev-node and eth-rpc binaries...${STYLE_END}"

    # Create bin directory if it doesn't exist
    mkdir -p $TARGET_DIR/bin/

    # Download dev-node binary
    wget -q --show-progress -O $TARGET_DIR/bin/dev-node \
        https://github.com/paritytech/hardhat-polkadot/releases/download/nodes-latest/revive-dev-node-linux-x64

    # Download eth-rpc binary
    wget -q --show-progress -O $TARGET_DIR/bin/eth-rpc \
        https://github.com/paritytech/hardhat-polkadot/releases/download/nodes-latest/eth-rpc-linux-x64

    # Make them executable
    chmod +x $TARGET_DIR/bin/*

    echo -e "${GREEN}✓ Binaries downloaded successfully!${STYLE_END}"

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
    cd $TARGET_DIR
    
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
