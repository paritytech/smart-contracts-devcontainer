### Polkadot Smart Contracts DevContainer Template

A ready-to-code DevContainer for building, testing, and deploying smart contracts for Polkadot using either Hardhat or Foundry. It includes PolkaVM tooling, a local Substrate node + ETH-RPC adapter, key management helpers, and opinionated defaults to get you productive fast.

### What’s inside
- **Hardhat preset**: `@parity/hardhat-polkadot` + `resolc` configured, sample contract/tests/ignition module, networks for local node and Polkadot Hub Testnet.
- **Foundry (Polkadot toolchain)**: Installed via `foundryup-polkadot` (includes `forge`, `cast`, `anvil`).
- **Local node tooling**: `substrate-node` and `eth-rpc` binaries available in the container for PolkaVM local development.
- **Key management**: `subkey` preinstalled; first attach auto-creates/imports a dev ECDSA key for testing and wires it into Hardhat or Foundry.
- **Dev tools**: Convenience `devtools` CLI for initializing projects, setting up the container, keypair, and checking balances.

### Prerequisites
- Docker Desktop (or compatible)
- VS Code + Dev Containers extension, GitHub Codespaces, or Gitpod

### Quick start

Option A — bring this DevContainer into any repo/folder (recommended):

```bash
curl -fsSL https://raw.githubusercontent.com/paritytech/smart-contracts-devcontainer/main/.devcontainer/fetch-devcontainer.sh | bash -s --
```

Then open the folder in VS Code and “Reopen in Container”. On first attach, choose **Hardhat** or **Foundry** when prompted.

Option B — clone this template repo and open in VS Code:
1. Open this repository in VS Code.
2. “Reopen in Container” when prompted (or use the Dev Containers command).
3. On first attach, you’ll be asked to initialize **Hardhat** or **Foundry**:
   - Hardhat: a full sample project is copied and dependencies are installed.
   - Foundry: a new `forge` project is initialized.
4. A dev ECDSA keypair is generated/imported and configured automatically:
   - For Hardhat: stored via `hardhat vars` as `TEST_ACC_PRIVATE_KEY`.
   - For Foundry: imported into the local keystore as the `paseo` account.
5. Use the workflows below to compile, test, run a local node, and deploy.

### Codespaces and Gitpod
- **GitHub Codespaces**: After adding the `.devcontainer/` to your repository (via the Quick start), open your repo on GitHub, click Code → “Create codespace on main”. Codespaces will build and start this DevContainer automatically.
- **Gitpod**: After adding the `.devcontainer/` to your repository, open `https://gitpod.io/#<your-repo-url>` (or use the Gitpod browser extension). Gitpod detects and uses the `.devcontainer` configuration out of the box.

### Hardhat workflow
Key files (created by init):
- `contracts/MyToken.sol`
- `ignition/modules/MyToken.ts`
- `hardhat.config.ts` (networks preconfigured)

Common commands (run inside the container):
```bash
npx hardhat compile
npx hardhat test
# Starts a local Substrate node + ETH-RPC adapter at 127.0.0.1:8545
npx hardhat node
```

Deploy with Ignition:
```bash
# Local node (make sure `npx hardhat node` is running in another terminal)
npx hardhat ignition deploy ./ignition/modules/MyToken.ts --network localNode

# Polkadot Hub TestNet (uses TEST_ACC_PRIVATE_KEY set for you)
npx hardhat ignition deploy ./ignition/modules/MyToken.ts --network polkadotHubTestnet
```

Notes:
- The `hardhat` network is configured to spawn a local Substrate node + ETH-RPC adapter for you. You can also target `localNode` at `http://127.0.0.1:8545`.
- Some Hardhat-only helpers (for example `time`, `loadFixture`) may not work with Polkadot nodes due to unsupported RPCs. Prefer plain ethers.js patterns for tests. See Hardhat docs for Polkadot for details.

### Foundry workflow
Project is initialized with `forge init`.

Common commands:
```bash
forge build
forge test

# Example: query your testnet balance (RPC set below in Accounts)
cast balance <your-evm-address> --rpc-url "$ETH_RPC_URL"
```

You can target the Polkadot Hub TestNet by setting:
```bash
export ETH_RPC_URL="https://testnet-passet-hub-eth-rpc.polkadot.io"
```

To use the imported key:
- The key is imported into Foundry as the `paseo` keystore with empty password.
- Example send (be careful on live networks):
```bash
cast send <contract-or-recipient> <method-or-empty> \
  --rpc-url "$ETH_RPC_URL" \
  --keystore "$HOME/.foundry/keystores/paseo" \
  --password ""
```

### Local node
- Start via Hardhat: `npx hardhat node` (spawns Substrate node on 127.0.0.1:8000 and ETH-RPC adapter on 127.0.0.1:8545).
- The Hardhat network `hardhat` uses the bundled binaries (`substrate-node`, `eth-rpc`) from the container.
- When running on Apple Silicon, the container uses amd64 binaries under emulation; expect slower performance.

### Accounts, faucet, and balances
On first attach, a keypair is prepared and wired into your toolchain:
- Hardhat: `hardhat vars get TEST_ACC_PRIVATE_KEY` to view the configured private key (do not share).
- Foundry: keystore name `paseo` with empty password.

Your EVM address is displayed after setup. Get test tokens from the Paseo Smart Contract faucet, then check balance:
```bash
# Convenience helper in this container
devtools check-balance
```

### Dev tools (inside the container)
```bash
devtools setup-devcontainer   # One-time project/container setup (runs automatically on attach)
devtools setup-keypair        # Create/import dev key, wire into Hardhat/Foundry, print faucet hint
devtools init-hardhat         # Initialize Hardhat template if not present
devtools init-foundry         # Initialize Foundry template if not present
devtools check-balance        # Prints your current PAS balance on Polkadot Hub TestNet
```

### Directory layout (high level)
- `.devcontainer/` DevContainer config and base tooling
  - `devcontainer.json` sets up extensions and runs setup scripts on attach
  - `Dockerfile` installs Node.js 22, Foundry (Polkadot), Subkey, and local node binaries
  - `scripts/devtool-scripts/*.sh` helper scripts invoked via `devtools`
  - `init-hardhat/` sample Hardhat project content used for initialization

### Documentation and references
- Hardhat on Polkadot: [docs.polkadot.com – Development Environments: Hardhat](https://docs.polkadot.com/develop/smart-contracts/dev-environments/hardhat/)
- Foundry on Polkadot: [docs.polkadot.com – Development Environments: Foundry](https://docs.polkadot.com/develop/smart-contracts/dev-environments/foundry/)
- Local development node: [docs.polkadot.com – Local Development Node](https://docs.polkadot.com/develop/smart-contracts/local-development-node/)
- JSON-RPC reference: [docs.polkadot.com – JSON-RPC APIs](https://docs.polkadot.com/develop/smart-contracts/json-rpc-apis/)

### License
GPL-3.0. See `LICENSE` for details.
