# Inventory Configuration Guide

This directory contains different inventory configurations for various k3s cluster deployments.

## Available Configurations

### 1. homelab.ini (Default)
- **Use case**: Single node development/testing
- **Setup**: One node acting as both server and worker
- **Resources**: Minimal requirements
- **HA**: No (single point of failure)

### 2. multi-node.ini.example
- **Use case**: Production homelab with high availability
- **Setup**: 3+ server nodes, multiple worker nodes
- **Resources**: Higher resource requirements
- **HA**: Yes (etcd quorum with odd number of servers)

### 3. edge-cluster.ini.example  
- **Use case**: Edge computing, IoT, resource-constrained environments
- **Setup**: Single server, lightweight workers (Raspberry Pi, etc.)
- **Resources**: Minimal (optimized for ARM/low-power devices)
- **HA**: No (optimized for edge use cases)

## Quick Start

### Single Node (Default)
```bash
# Use existing homelab.ini
./setup_ssh.sh
./bootstrap.sh
./setup_homelab.sh
```

### Multi-Node HA Cluster
```bash
# Copy example and customize
cp inventories/multi-node.ini.example inventories/production.ini
# Edit production.ini with your server IPs and credentials
./setup_ssh.sh -i inventories/production.ini
./bootstrap.sh -i inventories/production.ini  
./setup_homelab.sh -i inventories/production.ini
```

### Edge Cluster
```bash
# Copy example and customize for your edge devices
cp inventories/edge-cluster.ini.example inventories/edge.ini
# Edit edge.ini with your device IPs (Raspberry Pi, etc.)
./setup_ssh.sh -i inventories/edge.ini
./bootstrap.sh -i inventories/edge.ini
./setup_homelab.sh -i inventories/edge.ini
```

## Inventory Structure

All inventory files follow this structure:

```ini
[servers]
# Control plane nodes (etcd + API server + scheduler + controller-manager)
# For HA: Use odd numbers (3, 5, 7, etc.) for etcd quorum

[agents]  
# Worker nodes (kubelet + kube-proxy + container runtime)
# Can be any number

[homelab:children]
# Backward compatibility group
servers
agents

[all:children]
# All nodes in the cluster
servers
agents
```

## Node Roles

### Server Nodes (`[servers]`)
- Run k3s control plane components
- Host etcd database
- Schedule workloads (unless tainted)
- Minimum 1 required, odd numbers for HA

### Agent Nodes (`[agents]`)
- Worker-only nodes
- Run application workloads
- Connect to server nodes
- Optional (servers can also run workloads)

## Variables

Common variables you can set in inventory:

```ini
[all:vars]
k3s_version=v1.29.1+k3s1                    # k3s version to install
k3s_token=your-secure-token                 # Cluster join token  
k3s_cluster_cidr=10.42.0.0/16               # Pod network CIDR
k3s_service_cidr=10.43.0.0/16               # Service network CIDR
k3s_server_args="--disable=traefik"         # Additional server arguments
k3s_agent_args=""                           # Additional agent arguments
```

## Network Requirements

- All nodes must be able to communicate on port 6443 (Kubernetes API)
- Server nodes need port 2379-2380 for etcd (HA clusters only)
- Agents connect to servers on port 6443
- Ensure firewall allows cluster traffic

## Hardware Recommendations

### Single Node
- **CPU**: 2+ cores
- **RAM**: 4GB+ 
- **Storage**: 20GB+
- **Network**: 100Mbps+

### Multi-Node HA
- **Servers**: 2+ cores, 4GB+ RAM each
- **Agents**: 1+ cores, 2GB+ RAM each  
- **Storage**: 20GB+ per node
- **Network**: 1Gbps+ for cluster communication

### Edge Cluster
- **Server**: 2+ cores, 2GB+ RAM
- **Agents**: 1+ cores, 1GB+ RAM
- **Storage**: 16GB+ (SD card compatible)
- **Network**: 100Mbps+ (WiFi acceptable for edge)

## Security Notes

1. **Change default tokens**: Always use unique, secure cluster tokens
2. **SSH key authentication**: Recommended over passwords
3. **Network isolation**: Consider VLANs for cluster networks
4. **Node hardening**: Follow CIS benchmarks for production

## Troubleshooting

### Common Issues

1. **Token mismatch**: Ensure all nodes use the same `k3s_token`
2. **Network connectivity**: Verify nodes can reach each other
3. **Etcd quorum**: HA clusters need odd number of servers
4. **Resource constraints**: Check CPU/memory on small devices

### Verification Commands

```bash
# Check cluster status
kubectl get nodes -o wide

# Verify all nodes are Ready
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# View cluster info  
kubectl cluster-info
```