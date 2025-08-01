# Ansible Lab - Kubernetes Container Platform

Automated setup for transforming fresh Ubuntu installations into production-ready Kubernetes container platforms, optimized for hosting containerized workloads in a homelab environment.

## Overview

This Ansible-based automation project provides a streamlined 3-step process to convert bare Ubuntu Server installations into fully-configured Kubernetes nodes with Docker, k3s, and Longhorn distributed storage. The platform is designed to host containerized development environments and CI/CD workloads rather than installing tools directly on the host.

## Quick Start

```bash
# Step 1: Copy SSH keys to fresh Ubuntu install
./setup_ssh.sh

# Step 2: Bootstrap system (one-time sudo password prompt)
./bootstrap.sh

# Step 3: Complete platform setup (fully automated, ~15-20 minutes)
./setup_homelab.sh
```

## Project Structure

### Setup Scripts
- `setup_ssh.sh` - Copies SSH keys to target hosts for passwordless authentication
- `bootstrap.sh` - Initial system bootstrap with sudo configuration and prerequisites
- `setup_homelab.sh` - Complete automated platform setup orchestrator

### Ansible Files
- `site.yml` - Master playbook orchestrating the complete 7-phase setup process
- `inventories/homelab.ini` - Ansible inventory defining target hosts (default: 10.0.0.175)
- `group_vars/all.yml` - Global variables including SSH keys and user configuration

### Playbooks
- `playbooks/bootstrap_fresh_install.yml` - Initial SSH key setup and passwordless sudo configuration
- `playbooks/update_os.yml` - System updates and essential package installation
- `playbooks/configure_ssh.yml` - SSH security hardening with key-only authentication
- `playbooks/install_docker.yml` - Docker CE installation and user group configuration
- `playbooks/install_kubernetes.yml` - k3s setup with integrated DNS and storage
- `playbooks/install_longhorn_storage.yml` - Longhorn distributed storage deployment
- `playbooks/install_platform_tools.yml` - kubectl, Helm, and essential utilities installation
- `playbooks/setup_users.yml` - User account creation (davidg, labuser) with proper permissions
- `playbooks/configure_systems.yml` - System optimization for containers (swap, networking, etc.)
- `playbooks/prepare_system_for_image_creation.yml` - System cleanup for golden image creation (optional)

### Documentation
- `CLAUDE.md` - Guidance for Claude Code AI assistant when working with this codebase
- `README.md` - This file

## Usage Examples

### Run the Complete Setup
```bash
# Full automated setup from fresh Ubuntu install
./setup_homelab.sh
```

### Run Individual Playbooks
```bash
# Run specific playbook
ansible-playbook -i inventories/homelab.ini playbooks/update_os.yml

# Run with sudo password (for bootstrap only)
ansible-playbook -i inventories/homelab.ini playbooks/bootstrap_fresh_install.yml --ask-become-pass

# Check syntax without executing
ansible-playbook --syntax-check -i inventories/homelab.ini site.yml

# List tasks without executing
ansible-playbook --list-tasks -i inventories/homelab.ini site.yml
```

### Test Installation
```bash
# Test Ansible connectivity
ansible all -i inventories/homelab.ini -m ping

# After setup completion
docker run hello-world
kubectl get nodes
k3s kubectl get nodes
```

## What Gets Installed

### Container Platform
- **Docker CE** - Industry-standard container runtime
- **k3s** - Lightweight Kubernetes distribution with:
  - DNS (CoreDNS)
  - Integrated networking
- **Longhorn** - Enterprise-grade distributed storage with:
  - High availability and replication
  - Volume snapshots and backups
  - Web-based management UI

### Platform Management Tools
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager
- **Essential utilities** - git, vim, htop, tmux, jq, etc.

### System Configuration
- **Users**: `davidg` (primary), `labuser` (secondary) with full sudo/docker/k8s access
- **Security**: SSH key-only authentication, passwordless sudo for authorized users
- **Optimization**: Swap disabled, container-optimized networking, laptop lid behavior

## Requirements

### Target System
- Fresh Ubuntu Server 24.04 LTS installation
- Network connectivity (10.0.0.x subnet recommended)
- SSH access enabled

### Control Machine
- Ansible installed
- SSH key pair generated
- Network access to target hosts

## Next Steps

After successful setup:

1. **Log out and back in** to activate group memberships
2. **Deploy containerized workloads** using kubectl or Helm
3. **Access cluster resources**: Use kubectl, k9s, or deploy a dashboard
4. **Create manifests** in `~/manifests/` or Helm charts in `~/charts/`

## Architecture Philosophy

This project follows a cloud-native approach where the host system provides a minimal container platform, and all development tools run as containerized workloads. This ensures:

- Clean separation between infrastructure and applications
- Easy scaling across multiple nodes
- Consistent development environments
- Resource isolation and management
- Simplified maintenance and updates

## Contributing

Feel free to submit issues or pull requests. The project is designed to be modular and extensible for different homelab configurations.