#!/bin/bash

# Step 1: Copy SSH key to fresh install
# This script manually copies your SSH key to enable passwordless access
# Supports custom inventory files for multi-node setups

set -e

echo "========================================="
echo "SSH Key Setup for Cluster Install"
echo "========================================="
echo ""

# Check if we have the required files
if [ ! -f "group_vars/all.yml" ]; then
    echo "❌ Error: group_vars/all.yml not found"
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

# Extract target IPs from inventory
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "❌ Error: $INVENTORY_FILE not found"
    exit 1
fi

# Get all server and agent nodes from inventory
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

echo "🎯 Target systems found: ${#TARGET_IPS[@]}"
for ip in "${TARGET_IPS[@]}"; do
    echo "  - $ip"
done
echo "👤 User: davidg"
echo ""
echo "This will copy your SSH public key to all target systems."
echo "You'll be prompted for the davidg password for each system."
echo ""

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "🔑 Copying SSH keys to all target systems..."
echo ""

FAILED_HOSTS=()
SUCCESS_COUNT=0

for TARGET_IP in "${TARGET_IPS[@]}"; do
    echo "📡 Processing $TARGET_IP..."
    
    # Use ssh-copy-id to copy the key
    if ssh-copy-id -i ~/.ssh/id_ed25519.pub davidg@$TARGET_IP 2>/dev/null; then
        echo "✅ SSH key copied to $TARGET_IP"
        
        # Test the connection
        if ssh -o ConnectTimeout=5 -o BatchMode=yes davidg@$TARGET_IP 'echo "Connection test successful"' >/dev/null 2>&1; then
            echo "✅ SSH connection verified for $TARGET_IP"
            ((SUCCESS_COUNT++))
        else
            echo "⚠️  SSH key copied but connection test failed for $TARGET_IP"
            FAILED_HOSTS+=("$TARGET_IP")
        fi
    else
        echo "❌ Failed to copy SSH key to $TARGET_IP"
        FAILED_HOSTS+=("$TARGET_IP")
    fi
    echo ""
done

echo "========================================="
echo "📊 SSH Key Setup Summary"
echo "========================================="
echo "✅ Successful: $SUCCESS_COUNT/${#TARGET_IPS[@]} systems"

if [ ${#FAILED_HOSTS[@]} -gt 0 ]; then
    echo "❌ Failed systems:"
    for host in "${FAILED_HOSTS[@]}"; do
        echo "  - $host"
    done
    echo ""
    echo "💡 Please check failed systems and retry if needed"
fi

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo ""
    echo "🚀 Ready to run bootstrap playbook:"
    if [ "$INVENTORY_FILE" != "inventories/homelab.ini" ]; then
        echo "   ./bootstrap.sh -i $INVENTORY_FILE"
    else
        echo "   ./bootstrap.sh"
    fi
else
    echo ""
    echo "❌ No systems were configured successfully. Please check your setup."
    exit 1
fi