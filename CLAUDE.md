# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
This is an Ansible-based homelab automation project that transforms fresh Ubuntu installations into fully-configured CI/CD infrastructure nodes. The project **evolved from a golden image approach** to a **direct fresh install automation approach** using a streamlined bootstrap process followed by comprehensive automated configuration.

## Quick Start Commands

### Fresh Install Setup (3-step process)
```bash
# Step 1: Copy SSH keys to fresh install
./setup_ssh.sh

# Step 2: Bootstrap system (prompts for sudo password once)
./bootstrap.sh

# Step 3: Complete homelab setup (fully automated)
./setup_homelab.sh
```

### Manual Playbook Execution
```bash
# Run master orchestration playbook
ansible-playbook -i inventories/homelab.ini site.yml

# Run specific playbook against homelab inventory
ansible-playbook -i inventories/homelab.ini playbooks/<playbook_name>.yml

# Bootstrap fresh install (requires sudo password)
ansible-playbook -i inventories/homelab.ini playbooks/bootstrap_fresh_install.yml --ask-become-pass
```

### Ansible Syntax Validation
```bash
# Check playbook syntax
ansible-playbook --syntax-check -i inventories/homelab.ini <playbook>.yml

# List tasks without executing
ansible-playbook --list-tasks -i inventories/homelab.ini <playbook>.yml

# Test connectivity
ansible all -i inventories/homelab.ini -m ping
```

## Architecture

### Current Deployment Approach
**Fresh Install → Direct Automation (NEW APPROACH)**
1. Manual Ubuntu Server installation on target hardware
2. SSH key setup via `setup_ssh.sh` (uses standard ssh-copy-id)
3. Bootstrap via `bootstrap.sh` (one-time password prompt for sudo setup)
4. Complete automated setup via `setup_homelab.sh` (15-20 minutes, fully unattended)

**Previous Approach (Deprecated):** Golden image creation was abandoned due to complexity and maintenance overhead. The direct automation approach is more flexible and easier to maintain.

### Playbook Execution Order (via site.yml)
The `site.yml` master playbook orchestrates a 7-phase setup:
1. **OS Updates** (`update_os.yml`) - System packages and updates
2. **SSH Security** (`configure_ssh.yml`) - Security hardening
3. **Docker** (`install_docker.yml`) - Docker CE installation
4. **Kubernetes** (`install_kubernetes.yml`) - MicroK8s with addons
5. **Platform Tools** (`install_platform_tools.yml`) - kubectl, helm, essential utilities
6. **Users** (`setup_users.yml`) - Create labuser account with permissions
7. **System Config** (`configure_systems.yml`) - Container optimizations, lid behavior, swap disable

### Key Design Patterns
- **No Roles**: All functionality implemented directly in playbooks under `playbooks/` (consistent with original design)
- **Variable Hierarchy**: Global vars in `group_vars/all.yml` (corrected from original `vars.yml` reference)
- **Master Playbook**: `site.yml` orchestrates all phases with progress tracking and error handling
- **Bootstrap Pattern**: Separate bootstrap phase handles fresh install prerequisites
- **3-Step Process**: setup_ssh.sh → bootstrap.sh → setup_homelab.sh (no sshpass dependency)
- **Idempotent Design**: All playbooks can be safely re-run

### Network Configuration
- **Current Target**: 10.0.0.175 (defined in `inventories/homelab.ini`)
- **Planned Cluster**:
  - **controlplane**: 10.0.0.135 (laptop #1)
  - **worker1**: 10.0.0.136 (laptop #2)  
  - **worker2**: 10.0.0.137 (laptop #3)
- **Network**: 10.0.0.x subnet, WiFi "Worf", Gateway 10.0.0.1

### Important Variables
- **ansible_user**: Set to "davidg" in `group_vars/all.yml`
- **ssh_public_key**: Ed25519 key for passwordless authentication
- **Users Created**: davidg (primary), labuser (secondary) - both with full sudo/docker/k8s access

### Current Technology Stack
- **Base OS**: Ubuntu Server 24.04.2 LTS
- **Container Platform**: Docker CE + MicroK8s (Kubernetes)
- **Platform Management**: kubectl, Helm (for Kubernetes operations)
- **Infrastructure as Code**: Ansible for configuration management
- **Authentication**: SSH key-based, passwordless sudo

## Completed Features ✅
- **3-step bootstrap process** for fresh Ubuntu installs (eliminates sshpass dependency)
- **Master site.yml playbook** with 7-phase automated setup and progress tracking
- **Minimal container platform** with Docker and Kubernetes ready for workloads
- **Platform management tools** kubectl and Helm for Kubernetes operations
- **Dual user setup** (davidg primary, labuser secondary) with full permissions
- **System optimization** for Kubernetes workloads (swap disable, network config, lid behavior)
- **SSH security hardening** with key-only authentication and passwordless sudo
- **Complete automation** - 15-20 minute full setup from fresh Ubuntu install
- **Error handling and recovery** - playbooks are idempotent and resumable

## Next Phase: Cloud-Native Architecture 🚀

### Current Challenge
The current approach installs development tools directly on bare metal, which doesn't align with cloud-native practices. We need to containerize and distribute development tools via Kubernetes.

### Planned Transformation
**From**: Bare metal with tools installed directly
**To**: Bare metal as infrastructure foundation + containerized development environments

### Tomorrow's Task List

#### Phase 1: Architecture Redesign ✅ COMPLETED
- [x] **Created minimal base platform**
  - [x] Removed all development tools from playbooks
  - [x] Created new `install_platform_tools.yml` with only kubectl/helm
  - [x] Kept only: OS, Docker, MicroK8s, essential system config
  - [x] Maintained user accounts and SSH security

#### Phase 2: Containerization
- [ ] **Design unified development container image**
  - [ ] Single container with all development languages:
    - [ ] Node.js development environment
    - [ ] Deno 2 runtime
    - [ ] Go development environment
    - [ ] Python development environment
  
- [ ] **Create Dockerfile for unified development environment**
  - [ ] Include all necessary development dependencies
  - [ ] Multi-stage build for optimization
  - [ ] Proper user permissions and workspace setup
  - [ ] Common development workflows and aliases

#### Phase 3: Kubernetes Integration
- [ ] **Create Kubernetes manifests**
  - [ ] Deployments for development tool containers
  - [ ] Services for accessing development environments
  - [ ] ConfigMaps for development configurations
  - [ ] PersistentVolumes for project storage
  
- [ ] **Design developer access patterns**
  - [ ] kubectl exec workflows for interactive development
  - [ ] Port-forwarding for web-based tools
  - [ ] Volume mounting for project persistence
  - [ ] Resource limits and requests

#### Phase 4: Developer Experience
- [ ] **Create helper scripts**
  - [ ] Easy commands to spawn development environments
  - [ ] Project workspace management
  - [ ] Container lifecycle management
  
- [ ] **Documentation and workflows**
  - [ ] How to use containerized development tools
  - [ ] Best practices for cloud-native development
  - [ ] Troubleshooting guide

#### Phase 5: Integration & Testing
- [ ] **Update site.yml master playbook**
  - [ ] Remove direct tool installation phases
  - [ ] Add Kubernetes deployment phases
  - [ ] Test complete workflow
  
- [ ] **Validation & refinement**
  - [ ] Ensure all development workflows work in containers
  - [ ] Performance testing and optimization
  - [ ] Documentation updates

### Benefits of New Architecture
- **Infrastructure Separation**: Clean host OS with only container runtime
- **Cloud Alignment**: Mimics production cloud environments
- **Resource Management**: Proper limits and isolation
- **Scalability**: Easy to distribute across multiple nodes
- **Flexibility**: Multiple tool versions, disposable environments
- **Consistency**: Same development environment regardless of hardware

## Repository Structure
Located at: GitHub repository (accessible in project files)
**Key Files**:
- `site.yml` - Master orchestration playbook
- `inventories/homelab.ini` - Ansible inventory
- `group_vars/all.yml` - Shared variables (SSH keys, network config)
- `playbooks/*.yml` - Individual installation playbooks
- `playbooks/install_platform_tools.yml` - Minimal platform tools (kubectl, helm)
- `setup_ssh.sh` - SSH key deployment script
- `bootstrap.sh` - Fresh install bootstrap script  
- `setup_homelab.sh` - Complete automated setup script

## Usage for New Chat Sessions
When starting a new chat with Claude, provide this context document and specify:
1. Current phase of development (currently: cloud-native transformation)
2. Specific task from tomorrow's list you're working on
3. Any issues encountered or next steps needed
4. Current system state and configuration

This project demonstrates modern DevOps practices evolving from traditional configuration management to cloud-native, containerized development environments in a homelab setting.