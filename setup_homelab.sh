#!/bin/bash

# Complete container platform setup script
# Runs the full site.yml playbook to configure a minimal Kubernetes platform

set -e

echo "========================================="
echo "🏠 Complete Homelab Setup"
echo "========================================="
echo ""

# Check prerequisites
if [ ! -f "site.yml" ]; then
    echo "❌ Error: site.yml not found"
    echo "Please ensure you're running this from the ansible project root"
    exit 1
fi

if [ ! -f "inventories/homelab.ini" ]; then
    echo "❌ Error: inventories/homelab.ini not found"
    exit 1
fi

if [ ! -f "group_vars/all.yml" ]; then
    echo "❌ Error: group_vars/all.yml not found"
    exit 1
fi

# Get target info
TARGET_IP=$(grep -E "^[0-9]" inventories/homelab.ini | awk '{print $1}' | head -1)
TARGET_COUNT=$(grep -E "^[0-9]" inventories/homelab.ini | wc -l)

echo "📋 Pre-flight checks passed"
echo ""
echo "🎯 Target system(s): $TARGET_COUNT host(s)"
echo "   Primary: $TARGET_IP"
echo ""

# Test connectivity
echo "🔐 Testing connectivity..."
echo "   (You may be prompted for your SSH key passphrase)"
if ! ansible all -i inventories/homelab.ini -m ping; then
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

echo "⏱️  This complete setup will take approximately 15-20 minutes"
echo "🔧 The following will be installed and configured:"
echo "   • System updates and essential packages"
echo "   • SSH security hardening"
echo "   • Docker container runtime"
echo "   • Kubernetes (MicroK8s) platform"
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
ansible-playbook -i inventories/homelab.ini site.yml

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
    echo "   k3s status"
    echo ""
    echo "3. 🎛️  Optional - Access Kubernetes dashboard:"
    echo "   k3s dashboard-proxy"
    echo ""
    echo "4. 📁 Platform directories ready:"
    echo "   ~/manifests/ - Kubernetes manifests"
    echo "   ~/charts/ - Helm charts"
    echo ""
    echo "🏠 Your container platform is ready for workloads!"
else
    echo ""
    echo "❌ Setup failed. Check the output above for errors."
    echo "💡 You can re-run this script to continue from where it failed."
    exit 1
fi