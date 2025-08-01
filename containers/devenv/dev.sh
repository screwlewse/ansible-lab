#!/bin/bash

# Developer helper script for running the development container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="homelab/devenv"
IMAGE_TAG="latest"
CONTAINER_NAME="devenv-$(date +%s)"

# Parse command line arguments
WORKSPACE_DIR="${1:-.}"
WORKSPACE_DIR="$(cd "$WORKSPACE_DIR" && pwd)"

# Function to print usage
usage() {
    echo "Usage: $0 [workspace_directory]"
    echo ""
    echo "Launches the development environment container with the specified workspace."
    echo "If no directory is specified, uses the current directory."
    echo ""
    echo "Examples:"
    echo "  $0                    # Use current directory as workspace"
    echo "  $0 ~/my-project       # Use ~/my-project as workspace"
    exit 1
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

echo "🚀 Starting development environment..."
echo "   Workspace: $WORKSPACE_DIR"
echo "   Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""

# Check if image exists
if ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" >/dev/null 2>&1; then
    echo "⚠️  Image not found. Building it first..."
    "${SCRIPT_DIR}/build.sh"
fi

# Run the container
docker run -it --rm \
    --name "${CONTAINER_NAME}" \
    --hostname devenv \
    -v "${WORKSPACE_DIR}:/workspace" \
    -v "${HOME}/.ssh:/home/developer/.ssh:ro" \
    -v "${HOME}/.gitconfig:/home/developer/.gitconfig:ro" \
    -p 3000:3000 \
    -p 5000:5000 \
    -p 8000:8000 \
    -p 8080:8080 \
    -e TERM=xterm-256color \
    "${IMAGE_NAME}:${IMAGE_TAG}"