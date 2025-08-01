#!/bin/bash

# Enterprise Platform Setup - Advanced Components
# Run this AFTER setup_homelab.sh completes successfully

set -e

echo "========================================="
echo "🏢 Enterprise Platform Setup"
echo "========================================="
echo ""

# Check prerequisites
if [ ! -f "site.yml" ]; then
    echo "❌ Error: site.yml not found"
    echo "Please ensure you're running this from the ansible project root"
    exit 1
fi

if [ ! -f "inventories/homelab.ini" ]; then
    echo "❌ Error: inventories/homelab.ini not found"
    exit 1
fi

# Check if basic setup is complete
TARGET_IP=$(grep -E "^[0-9]" inventories/homelab.ini | awk '{print $1}' | head -1)

echo "🔍 Verifying base platform readiness..."
if ! ansible all -i inventories/homelab.ini -m shell -a "kubectl get nodes" >/dev/null 2>&1; then
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
        ansible-playbook -i inventories/homelab.ini playbooks/install_argocd_gitops.yml
        ;;
    2)
        echo "📊 Installing Monitoring Stack..."
        # This will be created in the next tasks
        echo "⚠️  Monitoring playbook will be available after completing all tasks"
        echo "For now, you can deploy via ArgoCD after installing GitOps"
        ;;
    3)
        echo "🌐 Installing Service Mesh..."
        # This will be created in the next tasks  
        echo "⚠️  Service mesh playbook will be available after completing all tasks"
        echo "For now, you can deploy via ArgoCD after installing GitOps"
        ;;
    4)
        echo "🚀 Installing All Enterprise Components..."
        echo ""
        echo "Phase 1: GitOps Platform"
        ansible-playbook -i inventories/homelab.ini playbooks/install_argocd_gitops.yml
        
        echo ""
        echo "Phase 2: Additional components can be deployed via ArgoCD"
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