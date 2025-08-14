# Homelab Infrastructure Specification

## Project Overview

This repository contains a comprehensive Infrastructure-as-Code (IaC) solution for deploying enterprise-grade Kubernetes homelab environments. It transforms bare Ubuntu servers into a fully functional, production-ready Kubernetes cluster with distributed storage, monitoring, and management capabilities.

## Purpose & Scope

**Primary Goal**: Automate the deployment of a scalable, enterprise-grade Kubernetes homelab platform that can grow from a single development node to a multi-node production cluster.

**Target Users**: 
- DevOps engineers building home labs
- Developers needing local Kubernetes environments
- System administrators learning enterprise containerization
- Anyone wanting a production-like Kubernetes setup at home

## Architecture Overview

### Deployment Patterns

#### 1. Single-Node Development
- **Use Case**: Development, testing, learning
- **Resources**: 4GB+ RAM, 2+ CPU cores, 50GB+ storage
- **Topology**: All components on one node
- **Inventory**: `inventories/homelab.ini`

#### 2. Multi-Node Production  
- **Use Case**: Production homelab, high availability
- **Resources**: 3+ nodes, 8GB+ RAM per node
- **Topology**: Distributed control plane and workloads
- **Inventory**: `inventories/multi-node.ini.example`

#### 3. Edge Computing
- **Use Case**: IoT, remote locations, resource constraints
- **Resources**: Raspberry Pi compatible, ARM64 support
- **Topology**: Lightweight configuration
- **Inventory**: `inventories/edge-cluster.ini.example`

### Core Infrastructure Stack

#### Base Platform (Required)
- **k3s Kubernetes**: Lightweight, production-ready Kubernetes distribution
- **Longhorn Storage**: Distributed block storage with replication and backups
- **Docker Runtime**: Container runtime with security hardening
- **System Hardening**: SSH security, user management, system optimization

#### Enterprise Components (Optional)
- **GitOps Platform**: ArgoCD for continuous delivery and application management
- **Observability Stack**: Grafana + Prometheus + Alloy for comprehensive monitoring
- **Service Mesh**: Linkerd for traffic management, security, and observability
- **Security Policies**: Network policies, Pod Security Standards, mTLS automation
- **Management Tools**: Skooner, Kubevious, K9s, Lens integration
- **Ingress & DNS**: NGINX Ingress Controller with external DNS automation
- **Backup & Recovery**: Automated backup schedules and disaster recovery testing

## Technical Specifications

### Supported Platforms
- **Operating System**: Ubuntu 24.04 LTS (primary), Ubuntu 22.04 LTS
- **Architecture**: x86_64, ARM64 (Raspberry Pi compatible)
- **Cloud Support**: Bare metal, VMs, cloud instances
- **Container Runtime**: containerd via k3s, Docker for development

### Networking Requirements
- **Pod Network**: 10.42.0.0/16 (k3s default)
- **Service Network**: 10.43.0.0/16 (k3s default)
- **Ingress Ports**: HTTP 30080, HTTPS 30443 (NodePort)
- **Management Access**: SSH (22), Kubernetes API (6443)
- **Inter-node Communication**: Various ports for k3s, Longhorn, service mesh

### Storage Configuration
- **Local Storage**: k3s local-path provisioner (default)
- **Distributed Storage**: Longhorn with configurable replication
- **Backup Support**: Local NFS + S3-compatible object storage
- **Volume Types**: RWO (ReadWriteOnce), RWX (ReadWriteMany) via Longhorn

## Directory Structure

```
ansible-lab/
├── setup_ssh.sh              # Step 1: SSH key deployment automation
├── bootstrap.sh               # Step 2: System preparation and hardening
├── setup_homelab.sh          # Step 3: Base platform deployment  
├── setup_enterprise.sh       # Step 4: Enterprise components (optional)
├── site.yml                  # Main Ansible playbook orchestrator
├── group_vars/
│   └── all.yml               # Global configuration variables
├── inventories/              # Environment-specific configurations
│   ├── homelab.ini           # Single/dual-node development setup
│   ├── multi-node.ini.example # HA cluster configuration template
│   ├── edge-cluster.ini.example # Edge/IoT deployment template
│   └── README.md             # Inventory configuration guide
├── playbooks/                # Modular component installation
│   ├── bootstrap_fresh_install.yml      # System preparation
│   ├── install_kubernetes.yml           # k3s cluster deployment
│   ├── install_longhorn_storage.yml     # Distributed storage
│   ├── install_argocd_gitops.yml        # GitOps platform
│   ├── install_monitoring_stack.yml     # Observability (Grafana/Prometheus)
│   ├── install_linkerd_service_mesh.yml # Service mesh
│   ├── install_security_policies.yml    # Security hardening
│   ├── configure_mtls_automation.yml    # Mutual TLS automation
│   ├── install_cluster_management_tools.yml # Web dashboards & CLI tools
│   ├── install_ingress_dns.yml          # NGINX Ingress + DNS automation
│   └── install_backup_disaster_recovery.yml # Backup & DR systems
├── applications/             # GitOps application definitions
│   ├── infrastructure/       # Core platform applications
│   ├── monitoring/          # Observability stack configurations
│   └── workloads/           # User application templates
├── CLAUDE.md                # Project-specific AI assistant instructions
├── PROJECT-SPEC.md          # This specification document
└── README.md                # User documentation and quick start
```

## Deployment Process

### Prerequisites
- Ubuntu 24.04 servers with SSH access
- User account with sudo privileges
- Network connectivity between nodes
- Minimum 4GB RAM, 2 CPU cores, 50GB storage per node

### 4-Step Deployment Process

#### Step 1: SSH Key Deployment
```bash
./setup_ssh.sh [-i inventory_file]
```
- Deploys SSH public keys to target servers
- Enables passwordless authentication
- Validates connectivity

#### Step 2: System Bootstrap
```bash
./bootstrap.sh [-i inventory_file]
```
- Updates operating system packages
- Installs essential utilities
- Configures passwordless sudo
- Hardens SSH security

#### Step 3: Base Platform
```bash
./setup_homelab.sh [-i inventory_file]
```
- Deploys k3s Kubernetes cluster
- Installs Longhorn distributed storage
- Configures container runtime
- Sets up platform management tools

#### Step 4: Enterprise Components (Optional)
```bash
./setup_enterprise.sh [-i inventory_file]
```
- Deploys GitOps platform (ArgoCD)
- Installs monitoring stack (Grafana/Prometheus)
- Configures service mesh (Linkerd)
- Implements security policies
- Sets up backup and disaster recovery

## Key Features

### Automation & IaC
- **Full Automation**: Complete cluster deployment with minimal user input
- **Idempotent Operations**: Safe to run multiple times
- **Modular Design**: Individual components can be deployed separately
- **Environment Management**: Support for dev, staging, production configurations

### Security & Hardening
- **SSH Security**: Key-only authentication, disabled root login
- **Pod Security Standards**: NSA/CISA hardening guidelines
- **Network Policies**: Micro-segmentation with default-deny rules
- **mTLS Everywhere**: Automatic mutual TLS with service mesh
- **RBAC**: Role-based access control with least privilege

### High Availability & Scaling
- **Multi-node Support**: Horizontal scaling from 1 to N nodes
- **Control Plane HA**: etcd clustering for production deployments
- **Storage Replication**: Configurable replica counts with Longhorn
- **Workload Distribution**: Automatic pod scheduling across nodes

### Observability & Management
- **Comprehensive Monitoring**: Metrics, logs, and tracing
- **Web Dashboards**: Grafana, Skooner, Kubevious interfaces
- **CLI Tools**: kubectl, helm, k9s, linkerd CLI
- **Alerting**: Configurable alerts for infrastructure and applications

### Backup & Disaster Recovery
- **Automated Backups**: Scheduled volume and cluster backups
- **Multiple Storage Tiers**: Local NFS + cloud object storage
- **Point-in-time Recovery**: Restore from any backup snapshot
- **DR Testing**: Automated disaster recovery validation

## Configuration Management

### Inventory Structure
Each environment is defined by an inventory file specifying:
- Node roles (servers, agents)
- IP addresses and hostnames
- SSH connection parameters
- Environment-specific variables

### Global Variables (`group_vars/all.yml`)
- SSH key configuration
- User account settings
- Component version specifications
- Feature toggles

### Environment-specific Overrides
- Resource allocation (CPU, memory)
- Storage configuration
- Network settings
- Security policies

## Component Integration

### GitOps Workflow
1. **Application Definitions**: Store configurations in Git repositories
2. **ArgoCD Sync**: Automatic deployment from Git changes
3. **Progressive Delivery**: Canary and blue-green deployments
4. **Rollback Capabilities**: Easy reversion to previous versions

### Monitoring & Alerting
1. **Infrastructure Monitoring**: Node, pod, and service metrics
2. **Application Monitoring**: Custom metrics and business KPIs
3. **Log Aggregation**: Centralized logging with search capabilities
4. **Alert Management**: Integration-ready for PagerDuty/Slack

### Service Mesh Integration
1. **Automatic mTLS**: Zero-trust networking between services
2. **Traffic Management**: Load balancing, retries, circuit breaking
3. **Observability**: Distributed tracing and service topology
4. **Security Policies**: Identity-based access control

## Operational Procedures

### Daily Operations
- Monitoring cluster health via Grafana dashboards
- Deploying applications via ArgoCD
- Managing storage with Longhorn UI
- Troubleshooting with k9s and kubectl

### Maintenance Tasks
- Regular backup verification
- Security policy updates
- Component version upgrades
- Capacity planning and scaling

### Disaster Recovery
- Backup restoration procedures
- Cluster rebuild automation
- Data migration between clusters
- Service continuity validation

## Extensibility

### Adding New Components
1. Create playbook in `playbooks/` directory
2. Add to `site.yml` or enterprise setup
3. Define application manifests in `applications/`
4. Update documentation and configuration

### Custom Applications
1. Define Kubernetes manifests
2. Create ArgoCD application
3. Configure monitoring and alerting
4. Implement backup procedures

### Integration Points
- Helm charts for package management
- Kubernetes operators for lifecycle management
- Custom Resource Definitions (CRDs)
- Admission controllers and webhooks

## Performance & Scaling

### Resource Requirements

#### Single Node (Development)
- **Minimum**: 4GB RAM, 2 CPU cores, 50GB storage
- **Recommended**: 8GB RAM, 4 CPU cores, 100GB SSD

#### Multi-Node (Production)
- **Control Plane**: 8GB RAM, 4 CPU cores, 100GB SSD
- **Worker Nodes**: 16GB RAM, 8 CPU cores, 200GB SSD
- **Network**: 1Gbps+ for multi-node clusters

#### Edge Deployment
- **Raspberry Pi 4**: 8GB RAM model recommended
- **Storage**: Fast SD card or USB 3.0 SSD
- **Network**: Stable internet for container registry access

### Performance Optimization
- CPU and memory resource limits per component
- Storage performance tuning for Longhorn
- Network optimization for service mesh
- Container image optimization and caching

## Troubleshooting & Support

### Common Issues
- SSH connectivity problems → Run `setup_ssh.sh`
- Node not joining cluster → Check networking and tokens
- Storage issues → Verify Longhorn requirements
- Performance problems → Review resource allocation

### Debugging Tools
- `kubectl` for cluster state inspection
- `k9s` for interactive cluster management
- Longhorn UI for storage troubleshooting
- Grafana dashboards for performance analysis

### Log Locations
- Kubernetes: `journalctl -u k3s`
- Longhorn: Pod logs in `longhorn-system` namespace
- Application: ArgoCD and individual pod logs

## Security Considerations

### Network Security
- Default-deny network policies
- Ingress traffic filtering
- Service mesh encryption
- External access controls

### Data Protection
- Encryption at rest (Longhorn volumes)
- Encryption in transit (TLS everywhere)
- Backup encryption
- Secret management with Kubernetes secrets

### Access Control
- SSH key-only authentication
- Kubernetes RBAC policies
- Service account limitations
- Audit logging enabled

## Compliance & Standards

### Security Frameworks
- CIS Kubernetes Benchmark compliance
- NSA/CISA Kubernetes Hardening Guide
- NIST Cybersecurity Framework alignment
- Pod Security Standards enforcement

### Operational Standards
- Infrastructure as Code principles
- GitOps deployment practices
- Observability best practices
- Disaster recovery requirements

## Future Roadmap

### Planned Enhancements
- Multi-cluster management with cluster API
- Advanced networking with Cilium
- Policy-as-code with Open Policy Agent
- Machine learning workload support

### Integration Targets
- Public cloud provider integration
- CI/CD pipeline templates
- Developer workflow automation
- Cost optimization tools

---

## Quick Reference

### Essential Commands
```bash
# Cluster status
kubectl get nodes,pods -A

# Storage management
kubectl get pv,pvc,storageclass -A

# Access Longhorn UI
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80

# Monitor cluster
k9s

# View logs
kubectl logs -f -n kube-system deployment/coredns
```

### Important Files
- `inventories/homelab.ini` - Node configuration
- `group_vars/all.yml` - Global settings
- `~/.kube/config` - Kubernetes access config
- `/etc/homelab-setup-complete` - Installation marker

### Default Credentials
- **SSH**: Key-based authentication only
- **Kubernetes**: kubeconfig file on control plane node
- **Longhorn UI**: No authentication (internal access only)
- **Grafana**: admin/homelab-admin (when monitoring enabled)

This specification serves as the definitive guide for understanding, deploying, and maintaining this homelab infrastructure platform.