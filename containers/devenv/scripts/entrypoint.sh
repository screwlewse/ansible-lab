#!/bin/bash

# Entrypoint script for development container

# Function to print colored output
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

# Welcome message
clear
echo "================================================"
echo "       🚀 Development Environment Ready!"
echo "================================================"
echo ""
echo "Available tools:"
echo "  • Node.js $(node --version 2>/dev/null | head -1)"
echo "  • Deno $(deno --version 2>/dev/null | grep deno | awk '{print $2}')"
echo "  • Go $(go version | awk '{print $3}')"
echo "  • Python $(python --version | awk '{print $2}')"
echo ""
echo "Workspace: /workspace"
echo "================================================"
echo ""

# Check if we're running in Kubernetes
if [ -n "$KUBERNETES_SERVICE_HOST" ]; then
    print_info "Running in Kubernetes cluster"
fi

# Source any project-specific environment variables
if [ -f /workspace/.env ]; then
    print_info "Loading environment from /workspace/.env"
    set -a
    source /workspace/.env
    set +a
fi

# Execute the command passed to docker run
exec "$@"