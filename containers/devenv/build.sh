#!/bin/bash

# Build script for development container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="homelab/devenv"
IMAGE_TAG="${1:-latest}"

echo "🏗️  Building development environment container..."
echo "   Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""

# Build the Docker image
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f "${SCRIPT_DIR}/Dockerfile" "${SCRIPT_DIR}"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build completed successfully!"
    echo ""
    echo "🚀 To run locally with Docker:"
    echo "   docker run -it --rm -v \$(pwd):/workspace ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    echo "🎯 To deploy to Kubernetes:"
    echo "   helm install devenv ${SCRIPT_DIR}/../helm/devenv-chart"
else
    echo "❌ Build failed!"
    exit 1
fi