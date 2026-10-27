#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Destroy all user-installed components from EKS cluster
# Leaves AWS-managed add-ons untouched (aws-node, coredns,
# ebs-csi, kube-proxy, metrics-server, eks-pod-identity-agent)
# ============================================================
echo "========================================"
echo "  Destroying all user-installed add-ons"
echo "========================================"

# 1. Helm releases
echo ">>> Removing Helm releases..."
helm uninstall cluster-autoscaler -n kube-system 2>/dev/null || true
helm uninstall karpenter -n kube-system 2>/dev/null || true

# 2. Traefik
echo ">>> Removing Traefik..."
kubectl delete -f /home/ubuntu/K8S/traefik-ingress-controller/ 2>/dev/null || true
kubectl delete namespace ingress-control 2>/dev/null || true
kubectl delete -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml 2>/dev/null || true

# 3. cert-manager
echo ">>> Removing cert-manager..."
kubectl delete clusterissuer letsencrypt-production 2>/dev/null || true
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml 2>/dev/null || true

# 4. VPA
echo ">>> Removing VPA..."
if [ -d ~/autoscaler/vertical-pod-autoscaler ]; then
  cd ~/autoscaler/vertical-pod-autoscaler
  ./hack/vpa-down.sh 2>/dev/null || true
  cd ~
fi

# 5. Karpenter CRDs (NodeClass, NodePools)
echo ">>> Removing Karpenter CRDs..."
kubectl delete ec2nodeclass --all 2>/dev/null || true
kubectl delete nodepool --all 2>/dev/null || true

# 6. ArgoCD Ingress
echo ">>> Removing ArgoCD ingress..."
kubectl delete -f /home/ubuntu/K8S/argocd/argocd-ingress.yaml 2>/dev/null || true

# 7. ServiceAccounts with IRSA annotations
echo ">>> Removing ServiceAccounts..."
kubectl delete sa cluster-autoscaler -n kube-system 2>/dev/null || true
kubectl delete sa karpenter -n kube-system 2>/dev/null || true

echo ""
echo "========================================"
echo "  Destroy complete!"
echo "  Only AWS-managed add-ons remain."
echo "========================================"
kubectl get pods -A
