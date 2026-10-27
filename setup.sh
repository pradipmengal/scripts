#!/bin/bash

set -e

echo "=========================================="
echo " DevOps Tools Installation Script"
echo "=========================================="

#-----------------------------------------------------
# Update System
#-----------------------------------------------------

echo "Updating system..."

sudo apt update

sudo apt install -y \
    curl \
    wget \
    unzip \
    jq \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    ca-certificates

#-----------------------------------------------------
# Install Terraform
#-----------------------------------------------------

echo ""
echo "Installing Terraform..."

if ! command -v terraform >/dev/null 2>&1; then

    wget -qO- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

    sudo apt update

    sudo apt install -y terraform

else
    echo "Terraform already installed."
fi

terraform version

#-----------------------------------------------------
# Install AWS CLI
#-----------------------------------------------------

echo ""
echo "Installing AWS CLI..."

if ! command -v aws >/dev/null 2>&1; then

    cd /tmp

    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o awscliv2.zip

    unzip -oq awscliv2.zip

    sudo ./aws/install

else

    sudo ./aws/install --update 2>/dev/null || true

fi

aws --version

#-----------------------------------------------------
# Install kubectl
#-----------------------------------------------------

echo ""
echo "Installing kubectl..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /
EOF

sudo apt update

sudo apt install -y kubectl

kubectl version --client

#-----------------------------------------------------
# Install Helm
#-----------------------------------------------------

echo ""
echo "Installing Helm..."

if ! command -v helm >/dev/null 2>&1; then

    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

else

    echo "Helm already installed."

fi

helm version

#-----------------------------------------------------
# Cleanup
#-----------------------------------------------------

rm -rf /tmp/aws
rm -f /tmp/awscliv2.zip

echo ""
echo "=========================================="
echo " Installation Completed Successfully"
echo "=========================================="

echo ""
echo "Installed Versions"
echo "----------------------------"

echo ""
echo "Terraform:"
terraform version

echo ""
echo "AWS CLI:"
aws --version

echo ""
echo "kubectl:"
kubectl version --client

echo ""
echo "Helm:"
helm version

echo ""
echo "jq:"
jq --version

echo ""
echo "Git:"
git --version

echo ""
echo "All tools installed successfully."
