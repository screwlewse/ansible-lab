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

# Define homelab SSH key paths
HOMELAB_KEY="$HOME/.ssh/homelab"
HOMELAB_KEY_PUB="$HOME/.ssh/homelab.pub"

# Check if homelab SSH key exists, create if missing
if [ ! -f "$HOMELAB_KEY" ] || [ ! -f "$HOMELAB_KEY_PUB" ]; then
    echo "🔑 Homelab SSH key not found, generating new key..."
    echo "   Key will be saved as: $HOMELAB_KEY"
    echo "   This key has no passphrase for automation"
    echo ""
    
    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate new SSH key with no passphrase
    if ssh-keygen -t ed25519 -f "$HOMELAB_KEY" -N "" -C "homelab-ansible-key" >/dev/null 2>&1; then
        echo "✅ Homelab SSH key generated successfully"
        echo "   Public key: $HOMELAB_KEY_PUB"
        echo "   Private key: $HOMELAB_KEY"
    else
        echo "❌ Error: Failed to generate SSH key"
        exit 1
    fi
    echo ""
else
    echo "✅ Using existing homelab SSH key: $HOMELAB_KEY"
    echo ""
fi

# Update group_vars/all.yml with the homelab key information
echo "🔧 Updating Ansible configuration..."
HOMELAB_KEY_CONTENT=$(cat "$HOMELAB_KEY_PUB")

# Create or update group_vars/all.yml
cat > group_vars/all.yml << EOF
ansible_user: "davidg"
ansible_ssh_private_key_file: "$HOMELAB_KEY"
ssh_public_key: "$HOMELAB_KEY_CONTENT"
EOF

echo "✅ Ansible configuration updated with homelab key"
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
    
    # Use ssh-copy-id to copy the homelab key
    if ssh-copy-id -i "$HOMELAB_KEY_PUB" davidg@$TARGET_IP 2>/dev/null; then
        echo "✅ SSH key copied to $TARGET_IP"
        
        # Test the connection
        if ssh -o ConnectTimeout=5 -o BatchMode=yes -i "$HOMELAB_KEY" davidg@$TARGET_IP 'echo "Connection test successful"' >/dev/null 2>&1; then
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