# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains the infrastructure-as-code and configuration for a comprehensive enterprise-grade Kubernetes homelab platform. It's designed to transform from basic containerization to a full-featured, production-ready Kubernetes cluster with enterprise capabilities. The repository includes:

- **3-Step Base Setup**: Simple bash scripts for initial platform deployment
- **Enterprise Components**: Advanced Kubernetes services and infrastructure
- **Multi-Node Support**: Scalable from single-node to HA cluster configurations
- **Comprehensive Automation**: Ansible playbooks for all infrastructure components
- **Professional Management**: Enterprise-grade tools and monitoring capabilities

## Architecture Overview

### Base Platform (Required)
1. **k3s Kubernetes**: Lightweight, production-ready Kubernetes distribution
2. **Longhorn Storage**: Distributed block storage for persistent volumes
3. **Docker Runtime**: Container runtime and management
4. **System Hardening**: SSH security, user management, and system optimization

### Enterprise Components (Optional)
1. **GitOps Platform**: ArgoCD for continuous delivery and application management
2. **Observability Stack**: Grafana + Prometheus + Alloy for comprehensive monitoring
3. **Service Mesh**: Linkerd for traffic management, security, and observability
4. **Security Policies**: Network policies, Pod Security Standards, and mTLS automation
5. **Management Tools**: Skooner, Kubevious, K9s, and Lens integration
6. **Ingress & DNS**: NGINX Ingress Controller with external DNS automation
7. **Backup & Recovery**: Automated backup schedules and disaster recovery testing

## Common Commands

### Quick Setup (3-Step Process)
```bash
# Step 1: Copy SSH keys to target systems
./setup_ssh.sh [-i inventory_file]

# Step 2: Bootstrap fresh systems with basic packages
./bootstrap.sh [-i inventory_file]

# Step 3: Deploy complete platform
./setup_homelab.sh [-i inventory_file]

# Optional Step 4: Add enterprise components
./setup_enterprise.sh [-i inventory_file]
```

### Kubernetes Operations
```bash
# Cluster management
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info

# Storage management
kubectl get pv,pvc -A
kubectl get storageclass

# Service inspection
kubectl get svc -A
kubectl get ingress -A
```

### Management Tools Access
```bash
# Interactive cluster management
~/cluster-management.sh

# Ingress and networking
~/manage-ingress.sh

# Security and mTLS
~/manage-mtls.sh

# Backup and disaster recovery
~/backup-recovery.sh
```

### Monitoring and Observability
```bash
# Grafana Dashboard
kubectl port-forward -n monitoring svc/grafana 3000:80
# Visit: http://localhost:3000 (admin/homelab-admin)

# Prometheus Metrics
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
# Visit: http://localhost:9090

# Linkerd Service Mesh Dashboard
linkerd viz dashboard &
```

## Architecture & Structure

### Directory Layout
```
ansible-lab/
├── setup_ssh.sh              # Step 1: SSH key deployment
├── bootstrap.sh               # Step 2: System bootstrapping
├── setup_homelab.sh          # Step 3: Base platform deployment  
├── setup_enterprise.sh       # Step 4: Enterprise components
├── site.yml                  # Main Ansible playbook
├── group_vars/all.yml        # Global configuration variables
├── inventories/              # Cluster inventory configurations
│   ├── homelab.ini           # Default single-node setup
│   ├── multi-node.ini.example # HA cluster example
│   ├── edge-cluster.ini.example # Edge computing example
│   └── README.md             # Inventory configuration guide
├── playbooks/                # Individual component playbooks
│   ├── bootstrap_fresh_install.yml
│   ├── install_kubernetes.yml
│   ├── install_longhorn_storage.yml
│   ├── install_argocd_gitops.yml
│   ├── install_monitoring_stack.yml
│   ├── install_linkerd_service_mesh.yml
│   ├── install_security_policies.yml
│   ├── configure_mtls_automation.yml
│   ├── install_cluster_management_tools.yml
│   ├── install_ingress_dns.yml
│   └── install_backup_disaster_recovery.yml
└── applications/             # GitOps application definitions
    ├── infrastructure/       # Core platform apps
    ├── monitoring/          # Observability stack
    └── workloads/           # User applications
```

### Key Infrastructure Components

#### Core Platform
- **k3s Cluster**: HA-capable Kubernetes with etcd clustering support
- **Longhorn Storage**: Replicated block storage with backup capabilities
- **Container Runtime**: Docker with security hardening and optimization
- **Network CNI**: Flannel for pod networking with Linkerd service mesh overlay

#### GitOps & Automation
- **ArgoCD**: GitOps continuous delivery with app-of-apps pattern
- **Helm Charts**: Package management for all enterprise components
- **Ansible Automation**: Infrastructure-as-code with role-based playbooks
- **Configuration Management**: Centralized configuration with environment separation

#### Observability & Monitoring
- **Grafana Stack**: Dashboards, alerting, and visualization
- **Prometheus**: Metrics collection with long-term storage
- **Alloy**: Log and metric collection agent
- **ServiceMonitors**: Automatic service discovery and monitoring

#### Security & Compliance
- **Network Policies**: Micro-segmentation and traffic control
- **Pod Security Standards**: Restricted, baseline, and privileged enforcement
- **Service Mesh mTLS**: Automatic mutual TLS with identity-based authorization
- **RBAC**: Role-based access control with least privilege principle

#### Management & Operations
- **Web Dashboards**: Skooner and Kubevious for visual cluster management
- **CLI Tools**: K9s for terminal-based cluster interaction
- **Ingress Management**: NGINX with SSL/TLS termination and external DNS
- **Backup Systems**: Automated backup schedules with disaster recovery testing

### Networking Configuration

#### Default Network Layout
- **Pod Network**: 10.42.0.0/16 (k3s default)
- **Service Network**: 10.43.0.0/16 (k3s default)
- **Ingress Ports**: HTTP 30080, HTTPS 30443 (NodePort)
- **Management Ports**: Various services exposed via port-forward or NodePort

#### Multi-Node Networking
- **Control Plane**: Port 6443 for Kubernetes API
- **etcd**: Ports 2379-2380 for cluster consensus
- **Longhorn**: Ports 9500-9502 for storage replication
- **Service Mesh**: Linkerd proxy ports 4140, 4143 for traffic management

#### External Access
- **Ingress Controller**: NGINX with custom domain support
- **External DNS**: Automated DNS record creation (CloudFlare, AWS, etc.)
- **Load Balancing**: Built-in k3s load balancer or external solutions
- **TLS Termination**: Automatic certificate management ready

### Backup & Disaster Recovery

#### Backup Strategy
- **Volume Backups**: Longhorn automated snapshots and backups
- **Cluster Backups**: Velero for Kubernetes resource protection  
- **Storage Tiers**: Local NFS + S3-compatible object storage
- **Retention Policies**: Configurable retention with automated cleanup

#### Recovery Capabilities
- **Point-in-Time Recovery**: Restore from any backup or snapshot
- **Cross-Cluster Migration**: Export/import between different clusters
- **Selective Restore**: Namespace or resource-specific recovery
- **Disaster Recovery Testing**: Automated DR testing with verification

## Deployment Patterns

### Single-Node Development
- **Use Case**: Development, testing, learning
- **Resources**: 4GB+ RAM, 2+ CPU cores, 50GB+ storage
- **Inventory**: `inventories/homelab.ini`
- **Components**: All components can run on single node

### Multi-Node Production
- **Use Case**: Production homelab, high availability
- **Resources**: 3+ nodes for HA, 8GB+ RAM per node
- **Inventory**: `inventories/multi-node.ini.example`
- **Components**: Control plane distribution, workload isolation

### Edge Computing
- **Use Case**: IoT, remote locations, resource constraints
- **Resources**: Raspberry Pi compatible, ARM64 support
- **Inventory**: `inventories/edge-cluster.ini.example`
- **Components**: Lightweight configuration, minimal resource usage

## Security Configuration

### Authentication & Authorization
- **Service Accounts**: Dedicated accounts for each component
- **RBAC Policies**: Fine-grained permissions with namespace isolation
- **Pod Security**: Enforced security contexts and capabilities
- **Network Policies**: Default-deny with explicit allow rules

### Encryption & Privacy
- **TLS Everywhere**: End-to-end encryption for all communications
- **Secret Management**: Kubernetes secrets with rotation capabilities
- **Certificate Authority**: Self-signed CA with automated rotation
- **Service Mesh mTLS**: Automatic mutual TLS between services

### Compliance & Hardening
- **CIS Benchmarks**: Following Kubernetes security best practices
- **Pod Security Standards**: NSA/CISA hardening guidelines
- **Network Segmentation**: Micro-segmentation with service mesh
- **Audit Logging**: Comprehensive audit trail for compliance

## Troubleshooting

### Common Issues

#### Cluster Not Ready
```bash
# Check node status
kubectl get nodes
kubectl describe node NODE_NAME

# Check system pods
kubectl get pods -n kube-system

# Restart k3s if needed
sudo systemctl restart k3s
```

#### Storage Issues
```bash
# Check Longhorn status
kubectl get pods -n longhorn-system
kubectl get volumes -n longhorn-system

# Access Longhorn UI
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
```

#### Network Problems
```bash
# Check ingress controller
kubectl get pods -n ingress-system
kubectl logs -n ingress-system deployment/ingress-nginx-controller

# Test service mesh
linkerd check
linkerd viz stat deployments -A
```

#### Backup Failures
```bash
# Check backup status
~/backup-recovery.sh  # Option 1: Check status
velero backup get
kubectl get backups -n longhorn-system
```

### Performance Optimization

#### Resource Allocation
- **CPU**: Reserve 0.5-1 cores for system processes
- **Memory**: Reserve 1-2GB for OS and Kubernetes overhead
- **Storage**: Use fast SSDs for etcd and container storage
- **Network**: Ensure 1Gbps+ for multi-node clusters

#### Component Tuning
- **k3s**: Adjust `--max-pods` based on node capacity
- **Longhorn**: Configure replica count based on node count
- **Monitoring**: Adjust retention periods based on storage capacity
- **Service Mesh**: Tune proxy resource limits for workload requirements

## Enterprise Features

### GitOps Workflow
1. **Application Definitions**: Store app configs in Git repositories
2. **ArgoCD Sync**: Automatic deployment from Git changes
3. **Progressive Delivery**: Canary and blue-green deployments with Linkerd
4. **Rollback Capabilities**: Easy rollback to previous application versions

### Monitoring & Alerting
1. **Infrastructure Monitoring**: Node, pod, and service metrics
2. **Application Monitoring**: Custom metrics and business KPIs
3. **Log Aggregation**: Centralized logging with search capabilities
4. **Alert Management**: PagerDuty/Slack integration ready

### Security Operations
1. **Policy Enforcement**: Automated security policy application
2. **Vulnerability Scanning**: Integration-ready for security tools
3. **Compliance Reporting**: Audit logs and compliance dashboards
4. **Incident Response**: Security event monitoring and alerting

### Business Continuity
1. **Automated Backups**: Scheduled backups with retention policies
2. **Disaster Recovery**: Tested recovery procedures and automation
3. **High Availability**: Multi-node clustering with automatic failover
4. **Capacity Planning**: Resource monitoring and scaling recommendations

This homelab platform provides enterprise-grade capabilities while maintaining simplicity and cost-effectiveness for home and small business use cases.