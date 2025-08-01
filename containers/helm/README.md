# Helm Charts for Ansible Lab

This directory contains Helm charts copied from the homek8s repository for deploying enterprise-grade infrastructure components.

## Available Charts

### Core Infrastructure
- **`argo-cd/`** - GitOps continuous delivery platform
  - Complete ArgoCD installation with UI, ApplicationSet controller
  - Pre-configured for k3s environments
  - Includes Redis HA setup

- **`longhorn/`** - Distributed block storage system
  - Enterprise-grade persistent storage
  - Volume snapshots and backups
  - Web-based management interface

### Service Mesh & Networking
- **`linkerd-crds/`** - Linkerd Custom Resource Definitions
  - Must be installed first before other Linkerd components
  
- **`linkerd-control-plane/`** - Linkerd service mesh control plane
  - Automatic mTLS between services
  - Traffic metrics and observability
  - Load balancing and circuit breaking

- **`linkerd-viz/`** - Linkerd observability stack
  - Web dashboard for service mesh metrics
  - Grafana and Prometheus integration
  - Traffic analysis and debugging tools

### Monitoring & Observability
- **`grafana-k8s-monitoring/`** - Comprehensive monitoring stack
  - Grafana dashboards and Alloy collector
  - Prometheus metrics collection
  - Node exporter for system metrics
  - Pre-configured for k3s environments

### Security & Certificates
- **`cert-manager/`** - Automated certificate management
  - Automatic TLS certificate provisioning
  - Support for multiple certificate authorities
  - Integration with DNS providers

## Usage

These charts are optimized for homelab k3s environments and can be deployed using:

1. **Via Ansible playbooks** (recommended):
   ```bash
   ansible-playbook playbooks/install_<component>.yml
   ```

2. **Direct Helm installation**:
   ```bash
   helm install <release-name> ./containers/helm/<chart-name> -n <namespace>
   ```

## Chart Sources

These charts are maintained copies from the homek8s repository, ensuring compatibility and consistent configuration across both projects.

## Notes

- All charts are pre-configured for single-node or small-cluster deployments
- Resource limits are set appropriately for homelab environments
- Some charts may require specific prerequisites (documented in individual playbooks)