#!/bin/bash

# Bootstrap script for fresh Ubuntu installs
# NOTE: Run setup_ssh.sh FIRST to copy SSH keys
# Supports custom inventory files for multi-node setups

set -e

echo "========================================="
echo "Ansible Cluster Install Bootstrap"
echo "========================================="
echo "Using inventory: $INVENTORY_FILE"
echo ""

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

# Check if inventory file exists
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "❌ Error: $INVENTORY_FILE not found"
    echo "Please ensure you're running this from the correct directory"
    exit 1
fi

# Check if bootstrap playbook exists
if [ ! -f "playbooks/bootstrap_fresh_install.yml" ]; then
    echo "❌ Error: playbooks/bootstrap_fresh_install.yml not found"
    exit 1
fi

# Check if group_vars file exists
if [ ! -f "group_vars/all.yml" ]; then
    echo "❌ Error: group_vars/all.yml not found"
    exit 1
fi

# Get target IPs for connection test
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

TARGET_IP="${TARGET_IPS[0]}"  # Use first IP for connection test

echo "📋 Pre-flight checks passed"
echo ""

# Test SSH connection first (allow passphrase prompt)
echo "🔐 Testing SSH connection..."
echo "   (You may be prompted for your SSH key passphrase)"
if ! ssh -o ConnectTimeout=5 davidg@$TARGET_IP 'echo "SSH working"' 2>/dev/null; then
    echo "❌ Error: SSH connection failed"
    echo ""
    echo "Please run this first:"
    echo "  ./setup_ssh.sh"
    echo ""
    echo "This will copy your SSH key to the fresh install."
    exit 1
fi

echo "✅ SSH connection working"
echo ""
echo "This script will:"
echo "  1. Install essential packages"
echo "  2. Enable passwordless sudo"
echo "  3. Secure SSH service"
echo ""
echo "⚠️  You will be prompted for the sudo password"
echo "    After this completes, all future playbooks will be passwordless"
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "🚀 Starting bootstrap..."
echo ""

# Run the bootstrap playbook with sudo password prompting
ansible-playbook \
    -i "$INVENTORY_FILE" \
    playbooks/bootstrap_fresh_install.yml \
    --ask-become-pass \
    -v

# Check if bootstrap was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✅ BOOTSTRAP COMPLETED SUCCESSFULLY!"
    echo "========================================="
    echo ""
    echo "Your system is now ready for the complete setup."
    echo ""
    echo "🚀 Next step:"
    if [ "$INVENTORY_FILE" != "inventories/homelab.ini" ]; then
        echo "   ./setup_homelab.sh -i $INVENTORY_FILE"
    else
        echo "   ./setup_homelab.sh"
    fi
    echo ""
    echo "This will run the complete platform setup (15-20 minutes)"
    echo "All future playbook runs will be passwordless! 🎉"
else
    echo ""
    echo "❌ Bootstrap failed. Please check the output above for errors."
    exit 1
fi