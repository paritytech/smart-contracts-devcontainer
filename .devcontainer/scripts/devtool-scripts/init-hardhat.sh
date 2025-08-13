# Check if the mounted directory is empty or needs initialization
if ! compgen -G "$PROJECT_DIR/hardhat.config.*" > /dev/null; then
    echo -e "${YELLOW}📦 Initializing new Polkadot Hardhat project...${STYLE_END}"
    echo -e "${GREEN}✓ Copying project template files...${STYLE_END}"

    # Change to project directory
    cd $PROJECT_DIR

    # Install dependencies
    echo -e "${GREEN}✓ Initializing npm project ...${STYLE_END}"
    npm init -y

    # Install the latest version of @parity/hardhat-polkadot and solc@0.8.28
    echo -e "${GREEN}✓ Installing @parity/hardhat-polkadot@latest and solc@0.8.28...${STYLE_END}"
    npm install --save-dev @parity/hardhat-polkadot@latest solc@0.8.28

    echo -e "${GREEN}✓ Initializing default hardhat-polkadot typescript project...${STYLE_END}"
    npx hardhat-polkadot init -y

    echo -e "${GREEN}✓ Copying dev-node and eth-rpc binaries...${STYLE_END}"
    cp /usr/local/bin/dev-node /usr/local/bin/eth-rpc $PROJECT_DIR/bin/
    chmod +x $PROJECT_DIR/bin/*

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
