#!/bin/bash

# Bootstrap script for fresh Ubuntu installs
# NOTE: Run setup_ssh.sh FIRST to copy SSH keys

set -e

echo "========================================="
echo "Ansible Fresh Install Bootstrap"
echo "========================================="
echo ""

# Check if inventory file exists
if [ ! -f "inventories/homelab.ini" ]; then
    echo "❌ Error: inventories/homelab.ini not found"
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

# Get target IP for connection test
TARGET_IP=$(grep -E "^[0-9]" inventories/homelab.ini | awk '{print $1}' | head -1)

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
    -i inventories/homelab.ini \
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
    echo "   ./setup_homelab.sh"
    echo ""
    echo "This will run the complete platform setup (15-20 minutes)"
    echo "All future playbook runs will be passwordless! 🎉"
else
    echo ""
    echo "❌ Bootstrap failed. Please check the output above for errors."
    exit 1
fi