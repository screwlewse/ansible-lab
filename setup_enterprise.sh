#!/bin/bash

# Enterprise Platform Setup - Advanced Components
# Run this AFTER setup_homelab.sh completes successfully
# Supports custom inventory files for multi-node setups

set -e

echo "========================================="
echo "🏢 Enterprise Platform Setup"
echo "========================================="
echo "Using inventory: $INVENTORY_FILE"
echo ""

# Check prerequisites
if [ ! -f "site.yml" ]; then
    echo "❌ Error: site.yml not found"
    echo "Please ensure you're running this from the ansible project root"
    exit 1
fi

# Parse command line arguments
INVENTORY_FILE="inventories/homelab.ini"
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--inventory)
            INVENTORY_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-i|--inventory INVENTORY_FILE]"
            echo "  -i, --inventory: Specify inventory file (default: inventories/homelab.ini)"
            echo "  -h, --help: Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

if [ ! -f "$INVENTORY_FILE" ]; then
    echo "❌ Error: $INVENTORY_FILE not found"
    exit 1
fi

# Check if basic setup is complete
TARGET_IPS=()
while IFS= read -r line; do
    # Skip comments and empty lines
    [[ $line =~ ^[[:space:]]*# ]] && continue
    [[ -z "$(echo "$line" | tr -d '[:space:]')" ]] && continue
    # Skip section headers
    [[ $line =~ ^\[.*\]$ ]] && continue
    # Extract IP addresses (handle both IP and hostname formats)
    if [[ $line =~ ansible_host=([0-9.]+) ]]; then
        TARGET_IPS+=("${BASH_REMATCH[1]}")
    elif [[ $line =~ ^([0-9.]+) ]]; then
        TARGET_IPS+=("${BASH_REMATCH[1]}")
    fi
done < "$INVENTORY_FILE"

if [ ${#TARGET_IPS[@]} -eq 0 ]; then
    echo "❌ Error: Could not find any target IPs in $INVENTORY_FILE"
    exit 1
fi

TARGET_IP="${TARGET_IPS[0]}"  # Use first IP for connection test

echo "🔍 Verifying base platform readiness..."
if ! ansible all -i "$INVENTORY_FILE" -m shell -a "kubectl get nodes" >/dev/null 2>&1; then
    echo "❌ Error: Base Kubernetes platform not ready"
    echo ""
    echo "Please run the base setup first:"
    echo "  1. ./setup_ssh.sh"
    echo "  2. ./bootstrap.sh" 
    echo "  3. ./setup_homelab.sh"
    echo ""
    echo "Then run this enterprise setup."
    exit 1
fi

echo "✅ Base platform verified"
echo ""

echo "⏱️  Enterprise setup will take approximately 15-20 minutes"
echo "🚀 The following enterprise components will be added:"
echo ""
echo "   🔄 GitOps Platform:"
echo "     • ArgoCD for continuous delivery"
echo "     • Application management structure"
echo "     • Automated deployment workflows"
echo ""
echo "   📊 Observability Stack:"
echo "     • Grafana k8s monitoring"
echo "     • Prometheus metrics collection"
echo "     • Alloy log and metric collection"
echo "     • Pre-configured dashboards"
echo ""
echo "   🌐 Service Mesh:"
echo "     • Linkerd for traffic management"
echo "     • Automatic mTLS between services"
echo "     • Advanced observability"
echo ""
echo "   🎛️  Management Tools:"
echo "     • Cluster visualization tools"
echo "     • Enhanced administrative interfaces"
echo ""

read -p "🚀 Ready to install enterprise components? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "📋 Available enterprise components:"
echo "   1. GitOps (ArgoCD) - Recommended first"
echo "   2. Monitoring Stack (Grafana + Prometheus)"
echo "   3. Service Mesh (Linkerd)"
echo "   4. All Components"
echo ""

read -p "Select installation option (1-4): " -n 1 -r OPTION
echo
echo

# Record start time
START_TIME=$(date +%s)

case $OPTION in
    1)
        echo "🔄 Installing GitOps Platform (ArgoCD)..."
        ansible-playbook -i "$INVENTORY_FILE" playbooks/install_argocd_gitops.yml
        ;;
    2)
        echo "📊 Installing Monitoring Stack..."
        ansible-playbook -i "$INVENTORY_FILE" playbooks/install_monitoring_stack.yml
        ;;
    3)
        echo "🌐 Installing Service Mesh..."
        ansible-playbook -i "$INVENTORY_FILE" playbooks/install_linkerd_service_mesh.yml
        ;;
    4)
        echo "🚀 Installing All Enterprise Components..."
        echo ""
        echo "Phase 1: GitOps Platform"
        ansible-playbook -i "$INVENTORY_FILE" playbooks/install_argocd_gitops.yml
        
        echo ""
        echo "Phase 2: Monitoring Stack"
        ansible-playbook -i "$INVENTORY_FILE" playbooks/install_monitoring_stack.yml
        
        echo ""
        echo "Phase 3: Service Mesh"
        ansible-playbook -i "$INVENTORY_FILE" playbooks/install_linkerd_service_mesh.yml
        
        echo ""
        echo "Phase 4: Additional components can be deployed via ArgoCD"
        echo "See ~/applications/ directory for available components"
        ;;
    *)
        echo "❌ Invalid option selected"
        exit 1
        ;;
esac

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "🎉 ENTERPRISE SETUP COMPLETED!"
    echo "========================================="
    echo ""
    echo "⏱️  Total time: ${DURATION_MIN}m ${DURATION_SEC}s"
    echo ""
    echo "🎛️  Access Your Enterprise Platform:"
    echo ""
    
    if [[ $OPTION == "1" || $OPTION == "4" ]]; then
        echo "📋 ArgoCD GitOps Dashboard:"
        echo "   kubectl port-forward -n argocd svc/argocd-server 8080:80"
        echo "   Visit: http://localhost:8080"
        echo "   Username: admin"
        echo "   Password: homelab-admin"
        echo ""
    fi
    
    if [[ $OPTION == "2" || $OPTION == "4" ]]; then
        echo "📊 Grafana Monitoring Dashboard:"
        echo "   kubectl port-forward -n monitoring svc/grafana 3000:80"
        echo "   Visit: http://localhost:3000"
        echo "   Username: admin"
        echo "   Password: homelab-admin"
        echo ""
        echo "📈 Prometheus Metrics:"
        echo "   kubectl port-forward -n monitoring svc/prometheus-server 9090:80"
        echo "   Visit: http://localhost:9090"
        echo ""
    fi
    
    if [[ $OPTION == "3" || $OPTION == "4" ]]; then
        echo "🌐 Linkerd Service Mesh Dashboard:"
        echo "   linkerd viz dashboard &"
        echo "   OR"
        echo "   kubectl port-forward -n linkerd-viz svc/web 8084:8084"
        echo "   Visit: http://localhost:8084"
        echo ""
    fi
    
    echo "🗄️  Longhorn Storage UI:"
    echo "   kubectl port-forward -n longhorn-system svc/longhorn-frontend 8081:80"
    echo "   Visit: http://localhost:8081"
    echo ""
    
    echo "📂 GitOps Applications:"
    echo "   ~/applications/infrastructure/ - Core platform"
    echo "   ~/applications/monitoring/    - Observability" 
    echo "   ~/applications/workloads/     - Your apps"
    echo ""
    
    echo "🚀 Next Steps:"
    echo "   1. Explore ArgoCD UI to manage applications"
    echo "   2. Deploy monitoring: kubectl apply -f applications/monitoring/"
    echo "   3. Add your own applications to ~/applications/workloads/"
    echo "   4. Set up Git repository for GitOps workflow"
    echo ""
    
    echo "🏢 Your enterprise-grade homelab platform is ready!"
else
    echo ""
    echo "❌ Enterprise setup failed. Check the output above for errors."
    echo "💡 You can re-run this script to retry installation."
    exit 1
fi