#!/bin/bash

# Step 1: Copy SSH key to fresh install
# This script manually copies your SSH key to enable passwordless access

set -e

echo "========================================="
echo "SSH Key Setup for Fresh Install"
echo "========================================="
echo ""

# Check if we have the required files
if [ ! -f "group_vars/all.yml" ]; then
    echo "❌ Error: group_vars/all.yml not found"
    exit 1
fi

# Extract target IP from inventory
if [ ! -f "inventories/homelab.ini" ]; then
    echo "❌ Error: inventories/homelab.ini not found"
    exit 1
fi

TARGET_IP=$(grep -E "^[0-9]" inventories/homelab.ini | awk '{print $1}' | head -1)
if [ -z "$TARGET_IP" ]; then
    echo "❌ Error: Could not find target IP in inventory file"
    exit 1
fi

echo "🎯 Target system: $TARGET_IP"
echo "👤 User: davidg"
echo ""
echo "This will copy your SSH public key to the fresh install."
echo "You'll be prompted for the davidg password once."
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "🔑 Copying SSH key..."

# Use ssh-copy-id to copy the key
ssh-copy-id -i ~/.ssh/id_ed25519.pub davidg@$TARGET_IP

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SSH key copied successfully!"
    echo ""
    echo "Testing passwordless connection..."

    # Test the connection
    if ssh -o BatchMode=yes -o ConnectTimeout=5 davidg@$TARGET_IP 'echo "SSH key authentication working!"' 2>/dev/null; then
        echo "✅ Passwordless SSH is working!"
        echo ""
        echo "🚀 Now run the bootstrap playbook:"
        echo "   ./bootstrap.sh"
    else
        echo "❌ SSH key test failed. Please check the setup."
        exit 1
    fi
else
    echo "❌ Failed to copy SSH key."
    exit 1
fi