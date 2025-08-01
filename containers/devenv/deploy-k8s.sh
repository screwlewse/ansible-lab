#!/bin/bash

# Deploy development environment to Kubernetes using Helm

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELM_CHART_DIR="${SCRIPT_DIR}/../helm/devenv-chart"
NAMESPACE="${NAMESPACE:-default}"
RELEASE_NAME="${1:-devenv}"

echo "🚀 Deploying development environment to Kubernetes..."
echo "   Release: ${RELEASE_NAME}"
echo "   Namespace: ${NAMESPACE}"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ Error: helm not found. Please install helm first."
    exit 1
fi

# Check Kubernetes connectivity
echo "🔍 Checking Kubernetes cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: Cannot connect to Kubernetes cluster."
    echo "   Please ensure your kubeconfig is properly configured."
    exit 1
fi

# Build and push image if using local registry
if [[ "${USE_LOCAL_REGISTRY}" == "true" ]]; then
    echo "🏗️  Building and pushing image to local registry..."
    "${SCRIPT_DIR}/build.sh"
    # Tag and push to local registry (adjust registry URL as needed)
    docker tag homelab/devenv:latest localhost:5000/homelab/devenv:latest
    docker push localhost:5000/homelab/devenv:latest
fi

# Deploy using Helm
echo "📦 Installing Helm chart..."
helm upgrade --install \
    "${RELEASE_NAME}" \
    "${HELM_CHART_DIR}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --wait

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    
    # Get pod name
    POD_NAME=$(kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/name=devenv,app.kubernetes.io/instance=${RELEASE_NAME}" -o jsonpath="{.items[0].metadata.name}")
    
    echo "📋 Deployment details:"
    echo "   Pod: ${POD_NAME}"
    echo "   Namespace: ${NAMESPACE}"
    echo ""
    echo "🔗 To access the development environment:"
    echo "   kubectl exec -it -n ${NAMESPACE} ${POD_NAME} -- /bin/bash"
    echo ""
    echo "🔧 To port-forward services:"
    echo "   kubectl port-forward -n ${NAMESPACE} ${POD_NAME} 3000:3000 5000:5000 8000:8000 8080:8080"
    echo ""
    echo "🗑️  To uninstall:"
    echo "   helm uninstall ${RELEASE_NAME} -n ${NAMESPACE}"
else
    echo "❌ Deployment failed!"
    exit 1
fi