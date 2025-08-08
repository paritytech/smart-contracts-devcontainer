ETH_RPC_URL="https://testnet-passet-hub-eth-rpc.polkadot.io"

SECRET=$(jq -r '.secretSeed' ~/.address.json)
EVM_ADDRESS=$(cast wallet address --private-key "$SECRET")


BALANCE=$(cast balance "$EVM_ADDRESS" --rpc-url $ETH_RPC_URL --ether)

# Output message
echo -e "Balance: ${GREEN}$BALANCE PAS${STYLE_END}"