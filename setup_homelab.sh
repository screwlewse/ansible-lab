#!/bin/bash

# Complete container platform setup script
# Runs the full site.yml playbook to configure a minimal Kubernetes platform
# Supports custom inventory files for multi-node setups

set -e

echo "========================================="
echo "🏠 Complete Homelab Setup"
echo "========================================="
echo "Using inventory: $INVENTORY_FILE"
echo ""

# Check prerequisites
if [ ! -f "site.yml" ]; then
    echo "❌ Error: site.yml not found"
    echo "Please ensure you're running this from the ansible project root"
    exit 1
fi

# Parse command line arguments
INVENTORY_FILE="inventories/homelab.ini"
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--inventory)
            INVENTORY_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-i|--inventory INVENTORY_FILE]"
            echo "  -i, --inventory: Specify inventory file (default: inventories/homelab.ini)"
            echo "  -h, --help: Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

if [ ! -f "$INVENTORY_FILE" ]; then
    echo "❌ Error: $INVENTORY_FILE not found"
    exit 1
fi

if [ ! -f "group_vars/all.yml" ]; then
    echo "❌ Error: group_vars/all.yml not found"
    exit 1
fi

# Get target info from inventory
TARGET_IPS=()
while IFS= read -r line; do
    # Skip comments and empty lines
    [[ $line =~ ^[[:space:]]*# ]] && continue
    [[ -z "$(echo "$line" | tr -d '[:space:]')" ]] && continue
    # Skip section headers
    [[ $line =~ ^\[.*\]$ ]] && continue
    # Extract IP addresses (handle both IP and hostname formats)
    if [[ $line =~ ansible_host=([0-9.]+) ]]; then
        TARGET_IPS+=("${BASH_REMATCH[1]}")
    elif [[ $line =~ ^([0-9.]+) ]]; then
        TARGET_IPS+=("${BASH_REMATCH[1]}")
    fi
done < "$INVENTORY_FILE"

if [ ${#TARGET_IPS[@]} -eq 0 ]; then
    echo "❌ Error: Could not find any target IPs in $INVENTORY_FILE"
    exit 1
fi

TARGET_IP="${TARGET_IPS[0]}"  # Primary node for display
TARGET_COUNT=${#TARGET_IPS[@]}

echo "📋 Pre-flight checks passed"
echo ""
echo "🎯 Target system(s): $TARGET_COUNT host(s)"
echo "   Primary: $TARGET_IP"
echo ""

# Test connectivity
echo "🔐 Testing connectivity..."
echo "   (You may be prompted for your SSH key passphrase)"
if ! ansible all -i "$INVENTORY_FILE" -m ping; then
    echo ""
    echo "❌ Error: Cannot connect to target systems"
    echo ""
    echo "Please ensure:"
    echo "  1. Target systems are powered on and accessible"
    echo "  2. SSH keys are properly configured (run ./setup_ssh.sh if needed)"
    echo "  3. Bootstrap has been completed (run ./bootstrap.sh if needed)"
    exit 1
fi

echo "✅ All systems reachable"
echo ""

echo "⏱️  This complete setup will take approximately 20-25 minutes"
echo "🔧 The following will be installed and configured:"
echo "   • System updates and essential packages"
echo "   • SSH security hardening"
echo "   • Docker container runtime"
echo "   • Kubernetes (k3s) platform"
echo "   • Longhorn distributed storage"
echo "   • Platform management tools (kubectl, helm)"
echo "   • User accounts (davidg, labuser)"
echo "   • System optimizations for containers"
echo ""

read -p "🚀 Ready to begin complete setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "🏗️  Starting complete homelab setup..."
echo "📊 Progress will be shown for each phase"
echo ""

# Record start time
START_TIME=$(date +%s)

# Run the master playbook
ansible-playbook -i "$INVENTORY_FILE" site.yml

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "🎉 HOMELAB SETUP COMPLETED!"
    echo "========================================="
    echo ""
    echo "⏱️  Total time: ${DURATION_MIN}m ${DURATION_SEC}s"
    echo ""
    echo "🚀 Your container platform is ready! Key next steps:"
    echo ""
    echo "1. 🔄 Log out and back in to activate group memberships:"
    echo "   logout && ssh davidg@$TARGET_IP"
    echo ""
    echo "2. 🧪 Test your installation:"
    echo "   docker run hello-world"
    echo "   kubectl get nodes"
    echo "   kubectl get nodes"
    echo ""
    echo "3. 🗄️  Access Longhorn storage UI:"
    echo "   kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80"
    echo ""
    echo "4. 📁 Platform directories ready:"
    echo "   ~/manifests/ - Kubernetes manifests"
    echo "   ~/charts/ - Helm charts"
    echo ""
    echo "🏠 Your container platform is ready for workloads!"
    echo ""
    echo "🚀 For enterprise components (GitOps, Monitoring, Service Mesh):"
    if [ "$INVENTORY_FILE" != "inventories/homelab.ini" ]; then
        echo "   ./setup_enterprise.sh -i $INVENTORY_FILE"
    else
        echo "   ./setup_enterprise.sh"
    fi
else
    echo ""
    echo "❌ Setup failed. Check the output above for errors."
    echo "💡 You can re-run this script to continue from where it failed."
    exit 1
fi