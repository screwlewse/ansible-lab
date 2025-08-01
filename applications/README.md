# ArgoCD Applications Directory

This directory contains ArgoCD Application manifests for managing infrastructure and workloads via GitOps.

## Directory Structure

```
applications/
├── infrastructure/     # Core platform components
│   └── longhorn-app.yaml
├── monitoring/        # Observability and monitoring
│   └── grafana-monitoring-app.yaml
└── workloads/         # Application workloads
```

## Usage

### Deploy Applications via ArgoCD

1. **Apply individual applications:**
   ```bash
   kubectl apply -f applications/infrastructure/longhorn-app.yaml
   kubectl apply -f applications/monitoring/grafana-monitoring-app.yaml
   ```

2. **Deploy all infrastructure components:**
   ```bash
   kubectl apply -f applications/infrastructure/
   ```

3. **Deploy complete monitoring stack:**
   ```bash
   kubectl apply -f applications/monitoring/
   ```

### Monitor via ArgoCD UI

Access ArgoCD UI to monitor application status:
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:80
```
Then visit: http://localhost:8080

## Application Templates

### Infrastructure Applications
- **Longhorn**: Distributed storage system with homelab-optimized settings
- Ready for: Linkerd service mesh, cert-manager, ingress controllers

### Monitoring Applications  
- **Grafana k8s Monitoring**: Complete observability stack with Alloy, Prometheus, and dashboards
- Ready for: Custom dashboards, alerting, log aggregation

### Workload Applications
- Template available for custom application deployments
- Supports: Helm charts, Kustomize, raw manifests

## GitOps Workflow

1. **Commit changes** to your Git repository
2. **ArgoCD automatically syncs** applications from Git
3. **Monitor deployments** via ArgoCD UI
4. **Rollback if needed** using ArgoCD controls

## Best Practices

- Use separate Git repositories for different environments
- Implement proper RBAC for production deployments  
- Enable notifications for deployment status
- Use ArgoCD Projects to organize applications
- Implement proper secret management (sealed-secrets, external-secrets)