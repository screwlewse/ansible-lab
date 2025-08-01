# Multi-stage Dockerfile for unified development environment
# Includes: Node.js, Deno 2, Go, Python

# Stage 1: Base image with common dependencies
FROM ubuntu:24.04 AS base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install common system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    sudo \
    locales \
    tzdata \
    unzip \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# Stage 2: Go installation
FROM base AS go-installer
ENV GO_VERSION=1.22.0
RUN ARCH=$(dpkg --print-architecture) \
    && wget -O go.tar.gz "https://golang.org/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

# Stage 3: Node.js installation
FROM base AS node-installer
ENV NODE_VERSION=20
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn pnpm \
    && rm -rf /var/lib/apt/lists/*

# Stage 4: Deno installation
FROM base AS deno-installer
ENV DENO_VERSION=2.0.0
ENV DENO_INSTALL="/usr/local"
RUN curl -fsSL https://deno.land/install.sh | sh -s v${DENO_VERSION}

# Stage 5: Final image combining all tools
FROM base AS final

# Copy Go from go-installer stage
COPY --from=go-installer /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/developer/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Copy Node.js from node-installer stage
COPY --from=node-installer /usr/bin/node /usr/bin/node
COPY --from=node-installer /usr/bin/npm /usr/bin/npm
COPY --from=node-installer /usr/bin/yarn /usr/bin/yarn
COPY --from=node-installer /usr/bin/pnpm /usr/bin/pnpm
COPY --from=node-installer /usr/lib/node_modules /usr/lib/node_modules

# Copy Deno from deno-installer stage
COPY --from=deno-installer /usr/local/bin/deno /usr/local/bin/deno
ENV DENO_DIR="/home/developer/.deno"

# Install Python in final stage (simpler approach)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-full \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3 /usr/bin/python

# Install additional development tools
RUN apt-get update && apt-get install -y \
    jq \
    htop \
    tree \
    tmux \
    screen \
    openssh-client \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for development
RUN useradd -m -s /bin/bash -u 1001 developer \
    && echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create common directories
RUN mkdir -p /workspace /home/developer/.local/bin \
    && chown -R developer:developer /workspace /home/developer

# Switch to developer user
USER developer
WORKDIR /workspace

# Set up shell environment
RUN echo 'export PATH="/home/developer/.local/bin:$PATH"' >> ~/.bashrc \
    && echo 'export PS1="\[\033[1;34m\]devenv\[\033[0m\] \w $ "' >> ~/.bashrc

# Install global development tools for each language
# Note: Go tools will be installed by users as needed to avoid build complexity

RUN pip3 install --user --break-system-packages \
    ipython \
    black \
    flake8 \
    mypy \
    pytest \
    requests

# Add entrypoint script
COPY --chown=developer:developer scripts/entrypoint.sh /home/developer/entrypoint.sh
RUN chmod +x /home/developer/entrypoint.sh

# Expose common development ports
EXPOSE 3000 5000 8000 8080

# Set entrypoint
ENTRYPOINT ["/home/developer/entrypoint.sh"]
CMD ["/bin/bash"]