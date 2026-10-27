#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# EKS Automated Setup Script
# Edit these variables to match your environment
# ============================================================
CLUSTER_NAME="apurv-eks"
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="946299734980"
CLUSTER_ENDPOINT="https://B2DCC56915107BB3359110AEE072C1D7.gr7.us-east-1.eks.amazonaws.com"

# Karpenter
KARPENTER_VERSION="0.37.0"
KARPENTER_INSTANCE_PROFILE="${CLUSTER_NAME}-karpenter-instance-profile"
KARPENTER_INTERRUPTION_QUEUE="karpenter-interruption"

# Traefik
TRAEFIK_VERSION="v3.0"
TRAEFIK_NAMESPACE="ingress-control"

# ------------------------------------------------------------
# IAM Role ARN helper
# ------------------------------------------------------------
iam_role_arn() {
  echo "arn:aws:iam::${AWS_ACCOUNT_ID}:role/$1"
}

echo "========================================"
echo "  EKS Setup: ${CLUSTER_NAME}"
echo "  Region:   ${AWS_REGION}"
echo "  Account:  ${AWS_ACCOUNT_ID}"
echo "========================================"
echo ""

# ------------------------------------------------------------
# 1. Create ServiceAccounts with correct IRSA annotations
# ------------------------------------------------------------
echo ">>> Creating ServiceAccounts with correct IAM role ARNs..."

# Cluster Autoscaler
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: $(iam_role_arn ${CLUSTER_NAME}-cluster-autoscaler-role)
EOF

# Karpenter
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: karpenter
  namespace: kube-system
  labels:
    app: karpenter
  annotations:
    eks.amazonaws.com/role-arn: $(iam_role_arn ${CLUSTER_NAME}-karpenter-controller-role)
EOF

# ------------------------------------------------------------
# 2. Install Core Components (Traefik CRDs, cert-manager)
# ------------------------------------------------------------
echo ">>> Installing Traefik CRDs..."
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/${TRAEFIK_VERSION}/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

echo ">>> Installing cert-manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl -n cert-manager rollout status deploy/cert-manager --timeout=120s
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=120s

echo ">>> Creating Let's Encrypt ClusterIssuer..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    email: apurvbidkar@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-production
    solvers:
      - http01:
          ingress:
            class: traefik
EOF

# ------------------------------------------------------------
# 3. Install cluster-autoscaler via Helm
# ------------------------------------------------------------
echo ">>> Installing cluster-autoscaler..."
helm repo add autoscaler https://kubernetes.github.io/autoscaler 2>/dev/null || true
helm repo update

# Pull chart first to work around Helm Chart.yaml cache issues
helm pull autoscaler/cluster-autoscaler --untar --destination /tmp/helm-ca 2>/dev/null || true

helm upgrade --install cluster-autoscaler /tmp/helm-ca/cluster-autoscaler \
  --namespace kube-system \
  --create-namespace \
  --set autoDiscovery.clusterName="${CLUSTER_NAME}" \
  --set awsRegion="${AWS_REGION}" \
  --set rbac.serviceAccount.create=false \
  --set rbac.serviceAccount.name=cluster-autoscaler \
  --set extraArgs.scale-down-delay-after-add=10m \
  --set extraArgs.skip-nodes-with-system-pods=false \
  --set extraArgs.skip-nodes-with-local-storage=false \
  --set cloudProvider=aws

# ------------------------------------------------------------
# 4. Install Karpenter
# ------------------------------------------------------------
echo ">>> Installing Karpenter..."
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version ${KARPENTER_VERSION} \
  -n kube-system \
  --create-namespace \
  -f - <<EOF
serviceAccount:
  create: false
  name: karpenter

settings:
  interruptionQueueName: ${KARPENTER_INTERRUPTION_QUEUE}
  clusterName: ${CLUSTER_NAME}
  clusterEndpoint: ${CLUSTER_ENDPOINT}
  aws:
    defaultInstanceProfile: ${KARPENTER_INSTANCE_PROFILE}

controller:
  replicas: 2
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1
      memory: 2Gi
EOF

# ------------------------------------------------------------
# 5. Create Karpenter NodeClass & NodePools
# ------------------------------------------------------------
echo ">>> Creating Karpenter NodeClass..."
kubectl apply -f - <<EOF
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: prod-ec2
spec:
  instanceProfile: ${KARPENTER_INSTANCE_PROFILE}
  amiFamily: AL2023
  subnetSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${CLUSTER_NAME}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 80Gi
        volumeType: gp3
        encrypted: true
  metadataOptions:
    httpEndpoint: enabled
    httpProtocolIPv6: disabled
    httpPutResponseHopLimit: 2
    httpTokens: required
  tags:
    Environment: production
    ManagedBy: karpenter
    Name: karpenter-node
    NodeType: karpenter
EOF

echo ">>> Creating Karpenter NodePools..."
kubectl apply -f - <<EOF
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: prod-nodepool
spec:
  template:
    metadata:
      labels:
        workload: application
        nodegroup: karpenter-prod
    spec:
      nodeClassRef:
        name: prod-ec2
      taints:
        - key: karpenter.sh/workload
          value: application
          effect: NoSchedule
      requirements:
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["t", "m"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["4"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot", "on-demand"]
        - key: topology.kubernetes.io/zone
          operator: In
          values:
            - ${AWS_REGION}a
            - ${AWS_REGION}b
            - ${AWS_REGION}c
  limits:
    cpu: "1000"
    memory: 2000Gi
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h
EOF

# ------------------------------------------------------------
# 6. Install VPA
# ------------------------------------------------------------
echo ">>> Installing VPA..."
if [ ! -d ~/autoscaler ]; then
  git clone https://github.com/kubernetes/autoscaler.git ~/autoscaler
fi
cd ~/autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
cd ~

# ------------------------------------------------------------
# 7. Install Traefik (if YAML manifests exist)
# ------------------------------------------------------------
if [ -d "/home/ubuntu/K8S/traefik-ingress-controller" ]; then
  echo ">>> Installing Traefik..."
  kubectl create namespace ${TRAEFIK_NAMESPACE} 2>/dev/null || true
  kubectl apply -f /home/ubuntu/K8S/traefik-ingress-controller/
fi

# ------------------------------------------------------------
# 8. Deploy ArgoCD Ingress
# ------------------------------------------------------------
if [ -f "/home/ubuntu/K8S/argocd/argocd-ingress.yaml" ]; then
  echo ">>> Deploying ArgoCD Ingress..."
  kubectl apply -f /home/ubuntu/K8S/argocd/argocd-ingress.yaml
fi

echo ""
echo "========================================"
echo "  Setup complete!"
echo "========================================"
kubectl get pods -A | grep -E "cluster-autoscaler|karpenter|cert-manager|vpa-|traefik"
