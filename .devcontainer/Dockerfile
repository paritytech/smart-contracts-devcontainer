# Image w/ precompiled subkey binary
FROM --platform=linux/amd64 parity/subkey:latest AS subkey-bin
# DevContainer Image
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:bullseye

# Install Node.js 22 and required tools
RUN apt-get update && \
    apt-get install -y curl wget git && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Fetch `dev-node` and `eth-rpc` binaries.
RUN wget -q -O /usr/local/bin/dev-node \
      https://github.com/paritytech/hardhat-polkadot/releases/download/nodes-latest/revive-dev-node-linux-x64 && \
    wget -q -O /usr/local/bin/eth-rpc \
      https://github.com/paritytech/hardhat-polkadot/releases/download/nodes-latest/eth-rpc-linux-x64 && \
    chmod +x /usr/local/bin/dev-node /usr/local/bin/eth-rpc

USER vscode
ARG USER_HOME=/home/vscode
WORKDIR $USER_HOME

# Install Foundry and Polkadot tools
RUN curl -L https://raw.githubusercontent.com/paritytech/foundry-polkadot/refs/heads/master/foundryup/install | bash && \
    $USER_HOME/.foundry/bin/foundryup-polkadot

# Grab subkey binary from precompiled image
COPY --from=subkey-bin /usr/local/bin/subkey /usr/local/bin/

# Copy devtool scripts for container initialization and management
COPY --chmod=0755 ./scripts/devtool-scripts /usr/local/bin/devtool-scripts
COPY --chmod=0755 ./scripts/devtools.sh /usr/local/bin/devtools

# Expose default Hardhat port (if running a local node)
EXPOSE 8545
