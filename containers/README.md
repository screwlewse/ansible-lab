# Containerized Development Environment

This directory contains the Docker-based development environment for the homelab platform, providing a unified container with Node.js, Deno 2, Go, and Python.

## Structure

```
containers/
├── devenv/                    # Development environment container
│   ├── Dockerfile            # Multi-stage Dockerfile
│   ├── docker-compose.yml    # Local testing with Docker Compose
│   ├── build.sh             # Build script
│   ├── dev.sh               # Local development launcher
│   ├── deploy-k8s.sh        # Kubernetes deployment script
│   └── scripts/
│       └── entrypoint.sh    # Container entrypoint
└── helm/
    └── devenv-chart/         # Helm chart for Kubernetes deployment
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
```

## Quick Start

### Local Development with Docker

```bash
# Build the image
./devenv/build.sh

# Run with current directory as workspace
./devenv/dev.sh

# Run with specific project directory
./devenv/dev.sh ~/my-project
```

### Deploy to Kubernetes

```bash
# Deploy using Helm
./devenv/deploy-k8s.sh

# Deploy with custom release name
./devenv/deploy-k8s.sh my-devenv

# Deploy to specific namespace
NAMESPACE=development ./devenv/deploy-k8s.sh
```

### Access Development Environment in Kubernetes

```bash
# Get pod name
kubectl get pods -l app.kubernetes.io/name=devenv

# Access the container
kubectl exec -it <pod-name> -- /bin/bash

# Port forward for web development
kubectl port-forward <pod-name> 3000:3000 5000:5000 8000:8000 8080:8080
```

## Available Tools

The development container includes:

- **Node.js 20** - JavaScript runtime with npm, yarn, and pnpm
- **Deno 2.0** - Secure runtime for JavaScript and TypeScript
- **Go 1.22** - Go programming language
- **Python 3** - Python with pip, venv, and common tools

### Pre-installed Development Tools

- **Go**: gopls, delve debugger
- **Python**: ipython, black, flake8, mypy, pytest
- **General**: git, vim, nano, jq, htop, tmux, screen

## Customization

### Environment Variables

Add custom environment variables in:
- **Docker Compose**: Edit `docker-compose.yml`
- **Kubernetes**: Edit `helm/devenv-chart/values.yaml`

### Persistent Storage

- **Local**: Uses Docker volume `devenv-workspace`
- **Kubernetes**: Creates PVC for `/workspace` directory

### Adding Tools

To add more tools, edit the Dockerfile and rebuild:

```dockerfile
# Add to the final stage
RUN apt-get update && apt-get install -y \
    your-tool-here \
    && rm -rf /var/lib/apt/lists/*
```

## Helm Chart Configuration

Key values you can override:

```yaml
# Custom resource limits
resources:
  limits:
    cpu: 4000m
    memory: 8Gi

# Enable ingress
ingress:
  enabled: true
  hosts:
    - host: devenv.yourdomain.com

# Use existing PVC
persistence:
  existingClaim: my-workspace-pvc
```

Deploy with custom values:

```bash
helm install devenv ./helm/devenv-chart -f my-values.yaml
```

## Development Workflow

1. **Start container** with your project mounted
2. **Develop** using any of the included languages
3. **Test** with exposed ports (3000, 5000, 8000, 8080)
4. **Commit** code from inside or outside container

## Tips

- Mount your SSH keys and git config for seamless git operations
- Use tmux/screen for multiple terminal sessions
- The workspace persists between container restarts
- All language package managers work normally (npm, pip, go get)

## Troubleshooting

### Container won't start
- Check Docker daemon is running
- Ensure image is built: `./devenv/build.sh`

### Permission issues
- Container runs as user `developer` (UID 1000)
- Ensure your files have appropriate permissions

### Kubernetes deployment fails
- Check kubeconfig: `kubectl cluster-info`
- Verify helm is installed: `helm version`
- Check namespace permissions