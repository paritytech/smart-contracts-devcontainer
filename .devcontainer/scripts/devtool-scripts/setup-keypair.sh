# Check and setup private key if needed
cd /project 2>/dev/null || true

# Check if the private key is already set
if [ -s ~/.address.json ]; then
    echo -e "\033[0;32m✓ Paseo deployment keypair configured \033[0m"
else
    echo -e "\033[1;33m⚠️  No private key found for deployment\033[0m"
    read -s -p "Paseo Secret (leave blank to generate new):" SECRET_INPUT
    echo ""
    if [ -z "$SECRET_INPUT" ]; then
        subkey generate --scheme ecdsa --network polkadot --output-type json > ~/.address.json
    else
        subkey inspect --scheme ecdsa $SECRET_INPUT --network polkadot --output-type json > ~/.address.json
    fi
fi

# Capture keypair
PUBLIC_ADDRESS=$(jq -r '.ss58PublicKey' ~/.address.json)
SECRET=$(jq -r '.secretSeed' ~/.address.json)
EVM_ADDRESS=$(cast wallet address --private-key "$SECRET")

# Add keypair to hardhat config
# TODO! Checking project type should be a function in 
#       constants.sh (rename commons.sh) since we do this in multiple scripts
if compgen -G "$PROJECT_DIR/hardhat.config.*" > /dev/null; then
    npx hardhat vars set PRIVATE_KEY $SECRET
elif compgen -G "$PROJECT_DIR/foundry.toml" > /dev/null; then
    rm -rf "$HOME/.foundry/keystores/paseo"
    cast wallet import --private-key $SECRET paseo --unsafe-password ""
fi

# Output Message
LINK_START='\033]8;;https://faucet.polkadot.io/?parachain=1111\033\\'
echo -e "

EVM Address: ${BOLD}${EVM_ADDRESS}${STYLE_END}
${BOLD}${ITALIC}${RED}Note:${STYLE_END} ${ITALIC}${GREY}Do not use this address for anything of real value${STYLE_END}

$(bash devtools check-balance)
Paste the address into the ${LINK_START}${BLUE}Paseo Smart Contract faucet${LINK_END}${STYLE_END} to receive tokens for testing your contracts!

"
exec /bin/bash -c "exec /bin/bash"
