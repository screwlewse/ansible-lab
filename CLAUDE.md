# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
This is an Ansible-based homelab automation project that transforms fresh Ubuntu installations into fully-configured CI/CD infrastructure nodes. The project creates "golden image" templates that can be cloned and deployed across multiple systems.

## Common Commands

### Initial Setup (for fresh systems)
```bash
# Step 1: Copy SSH keys to fresh install
./setup_ssh.sh

# Step 2: Bootstrap system (prompts for sudo password)
./bootstrap.sh

# Step 3: Complete homelab setup
./setup_homelab.sh
```

### Running Individual Playbooks
```bash
# Run specific playbook against homelab inventory
ansible-playbook -i inventories/homelab.ini playbooks/<playbook_name>.yml

# Run with sudo password prompt (for initial bootstrap)
ansible-playbook -i inventories/homelab.ini playbooks/bootstrap_fresh_install.yml --ask-become-pass

# Run master orchestration playbook
ansible-playbook -i inventories/homelab.ini site.yml
```

### Ansible Syntax Validation
```bash
# Check playbook syntax
ansible-playbook --syntax-check -i inventories/homelab.ini <playbook>.yml

# List tasks without executing
ansible-playbook --list-tasks -i inventories/homelab.ini <playbook>.yml
```

## Architecture

### Playbook Execution Order
The `site.yml` master playbook orchestrates a 7-phase setup:
1. **Bootstrap** (`bootstrap_fresh_install.yml`) - SSH keys, passwordless sudo
2. **OS Updates** (`update_os.yml`) - System packages and updates
3. **SSH Config** (`configure_ssh.yml`) - Security hardening
4. **Docker** (`install_docker.yml`) - Docker CE installation
5. **Kubernetes** (`install_kubernetes.yml`) - MicroK8s with addons
6. **Dev Tools** (`install_development_tools.yml`) - Terraform, Node.js, Go, etc.
7. **System Config** (`configure_systems.yml`) - Container optimizations

### Key Design Patterns
- **No Roles**: All functionality implemented directly in playbooks under `playbooks/`
- **Variable Hierarchy**: Global vars in `group_vars/all.yml`, host-specific in `host_vars/`
- **Error Handling**: Consistent use of `failed_when`, `ignore_errors`, and verification tasks
- **Progress Tracking**: Debug messages throughout for operation visibility

### Golden Image Workflow
1. Fresh Ubuntu installation
2. Run complete setup via `./setup_homelab.sh`
3. Clean system with `playbooks/prepare_system_for_image_creation.yml`
4. Create image for deployment to multiple systems

### Important Variables
- **ansible_user**: Set to "davidg" in `group_vars/all.yml`
- **ssh_public_key**: Ed25519 key for passwordless authentication
- **Target Host**: 10.0.0.175 (defined in `inventories/homelab.ini`)

### Technology Stack
- **Container Platform**: Docker CE + MicroK8s (Kubernetes)
- **Development Tools**: Terraform, kubectl, Helm, Node.js, Go, Python
- **Users**: davidg (primary), labuser (secondary) - both with full sudo/docker access