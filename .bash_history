clear
ls
pwd
sudo apt update
clear
ls
pwd
exit
clear
vi setup.sh
chomod +x setup.sh 
chmod +x setup.sh 
ls
sudo apt install btop
clear
ls
./setup.sh 
sudo ./setup.sh 
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
ls
rm setup.sh 
vi setup.sh
chmod +x setup.sh 
./setup.sh 
clear
ls
clear
aws-cli
awscli
aws-cli
sudo aws-cli
./setup.sh 
terraform
aws
kubectl
helm
clear
ls
clear
unzip project.zip 
curl -fsSL https://opencode.ai/install | bash
opencode
npm install -g opencode-ai
source ~/.bashrc
opencode
clear
ls
aws configure
aws s3 ls
aws sts get-caller-identity
clear
ls
cd project/
ls
cd BACKEND/
ls
rm -rf terraform.tfstate .terraform .terraform.lock.hcl terraform.tfstate.backup 
terraform init
terraform fmt
terraform validate
terraform plan
terraform plan -auto-approve
terraform apply -auto-approve
ls
cd ..
ls
cd VPC/
ls
ls -lart
rm -rf .terraform .terraform.lock.hcl 
terraform init
terraform init -reconfigure
terraform fmt
terraform validate
terraform plan 
terraform apply -auto-approve
cd ../NAT
ls
ls -lart
rm -rf .terraform .terraform.lock.hcl 
terraform init
terraform fmt
terraform valide
terraform validate
terraform plan
terraform apply -auto-approve
cd ../NAT_LAMBDA/
ls
ls -lart
rm -rf .terraform .terraform.lock.hcl 
terraform fmt
terraform validate
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
cd ../
ls
cd VPC/
ls
ls -lart
rm -rf .terraform .terraform.lock.hcl 
terrraform init
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
cd ../
ls
cd EKS/
ls
ls -lart
rm -rf .terraform .terraform.lock.hcl 
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
cd ../NAT_LAMBDA/
terraform init -reconfigure && terraform destroy -auto-approve
cd ../NAT/
ls
terraform init -reconfigure && terraform destroy -auto-approve
cd ../VPC/
ls
terraform init -reconfigure && terraform destroy -auto-approve
cd ../
ls
cd BACKEND/
ls
terraform init -reconfigure && terraform destroy -auto-approve
aws s3api delete-objects --bucket apurv-demo-tfstate-dev2 --delete "$(aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2 --query '{Objects: [].{Key:Key,VersionId:VersionId}}' 2>/dev/null)" 2>/dev/null || true
terraform destroy -auto-approve
aws s3api delete-objects --bucket apurv-demo-tfstate-dev2 --delete "$(aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2 --output json --query '{Objects: [].{Key:Key,VersionId:VersionId}}')"
aws s3api delete-objects --bucket apurv-demo-tfstate-dev2 --delete "$(aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2 --output json --query '{Objects: [].{Key:Key,VersionId:VersionId}}' --no-sign-request 2>/dev/null)" 2>/dev/null || true
ws s3api list-object-versions --bucket apurv-demo-tfstate-dev2
aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2
aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2fdfexit
aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2fdexit
aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2fdfexit
exit
ls
cd project/
ls
cd BACKEND/
ls
aws s3api delete-objects --bucket apurv-demo-tfstate-dev2 --delete "$(aws s3api list-object-versions --bucket apurv-demo-tfstate-dev2 --output json | jq '{Objects: [.Versions[]? | {Key, VersionId}] + [.DeleteMarkers[]? | {Key, VersionId}]}')"
exit
ls
cd project/
ls
cd BACKEND/
ls
terraform destroy -auto-approve
ls
cd ..
ls
chmod +x deploy.sh 
ls
ls
cd project/
ls
./destroy.sh 
clear
ls
opencode
clear
ls
cd project/
ls
./destroy.sh 
clear
ls
./deploy.sh 
ls
kubectl
aws eks update-kubeconfig --region us-east-1 --name apurv-eks
kubectl get nodes
exit
ls
rm -rf project.zip 
unzip K8S.zip 
ls
cd K8S/
ls
clear
ls
cd ..
ls
cd project/
ls
./destroy.sh 
clear
ls
clear
ls
clear
ls
./destroy.sh 
cd project/
ls
opencode
cd ..
opencode
clear
ls
clear
ls
cd project/
ls
clear
ls
./deploy.sh 
ls
cd ..
ls
./seteks.sh 
kubectl get pods
kubectl get nodes
ls
opencode
ls
cd K8S/
ls
./setup-eks.sh 
ls
cd ..
ks
ls
cd project/
ls
./destroy.sh 
clear
opencode
ls
opencode
ls
vi seteks.sh
ls
chmod +x seteks.sh 
ls
cat seteks.sh 
clear
ls
opencode
ls
cd K8S/
ls
sudo kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
ls
cd autoscaler/
ls
cd ..
ls
git clone https://github.com/kubernetes/autoscaler.git
cd ..
ls
git clone https://github.com/kubernetes/autoscaler.git
ls
cd autoscaler/
ls
./hack/vpa-up.sh
cd hack/
ls
./vpa-up.sh
cd ..
ls
cd vertical-pod-autoscaler/
ls
./hack/vpa-up.sh
kubectl get pods -n kube-system
ls
cd ..
ls
cd ..
ls
cd K8S/
ls
cd autoscaler/
ls
vi cluster-autoscaler-sa.yaml 
ls
kubectl apply -f cluster-autoscaler-sa.yaml 
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update
sudo kubectl get pods -n kube-system | grep cluster-autoscaler
kubectl get pods -n kube-system | grep cluster-autoscaler
kubectl -n kube-system logs -f deploy/cluster-autoscaler
kubectl -n kube-system logs -f deploy/cluster-autoscaler-aws-cluster-autoscaler
helm install karpenter oci://public.ecr.aws/karpenter/karpenter   --version 0.37.0   -n kube-system   -f /home/ubuntu/K8S/karpenter/karpenter-values.yaml   --create-namespace
kubectl get pods -A
ls
cat cluster-autoscaler-sa.yaml 
cd
ls
ls -lart
kubectl get pods -A
opencode
ls
cd project/
ks
ls
./destroy.sh 
clear
opencode
clear
ls
unzip microservices-demo.zip 
ls
clear
ls
cd microservices-demo/
ls
opencode
cd ..
ls
opencode
clear
ls
cd project/
ls
celar
clear
ls
./destroy.sh 
clear
ls
./deploy.sh 
ls
cd ..
ls
cd microservices-demo/
aws eks update-kubeconfig --region us-east-1 --name apurv-eks
kubectl get nodes
ls
cd base/
ls
kubectl create namespace ecommerce
kubectl get namespace -A
cd ..
kubectl apply -k base/ -n ecommerce
kubectl get pods -n ecommerce
watch kubectl get pods -n ecommerce
kubectl delete -k base/ -n ecommerce
watch kubectl get pods -n ecommerce
clear
ls
cd ../
lw
ls
cd microservices-demo/
ls
kubectl apply -k base/ -n ecommerce
watch kubectl get pods -n ecommerce
kubectl get events -n ecommerce
pwd
watch kubectl get pods -n ecommerce
ls
cd ..
ls
zip -r bkp.zip project/
kubectl get nodes
kubectl get ns -A
kubectl get pods -n kube-system
kubectl top node
watch kubectl get pods -n ecommerce
kubectl get logs shippingservice-5bd58cf887-zvj5r
kubectl get opods
kubectl get pods
kubectl get pods -n ecommerce
kubectl describe pod productcatalogservice-7cc6fd9b6c-rqz9d -n ecommerce
ls
cd project/
ls
cd EKS/
ls
cat variables.tf 
vi variables.tf 
ls
terraform plan
terraform apply -auto-approve
kubectl get pods -n ecommerce
kubectl describe pod loadgenerator-58b8f76586-9klfc -n ecommerce
kubectl get pods -n ecommerce
kubectl get events -n ecommerce
kubectl get pods -n ecommerce
ls
cd ..
ls
cd ..
ls
cd microservices-demo/
ls
kubectl delete -f base/
ls
cd base/
ls
kubectl get ns
kubectl delete -f . -n ecommerce
kubectl delete ns ecommerce
kubectl get pods -n ecommerce
kubectl get ns -A
kubectl delete ns ecommerce
kubectl get ns -A
kubectl get pods -n ecommerce
watch kubectl get ns -A
ls
cd ..
kubectl delete -f base/
kubectl create ns ecom
kubectl apply -k base/ -n ecom
kubectl get pods -n ecom
watch kubectl get pods -n ecom
kubectl get ns
kubectl get nodes
watch kubectl get pods -n ecom
kubectl get nodes
clear
ls
cd microservices-demo/
opencode
kubectl get context
clear
ls
cd ..
opencode
cd microservices-demo/
opencode
cd ..
ls
opencode
cd microservices-demo/
opencode
ls
cd ..
ls
opencode
clear
ls
kubectl get node
kubectl top nod
kubectl top node
opencode
ls
cd project/
ls
./destroy.sh 
nohup
cd ..
ls
cd project/
ls
nohup
nohup ./destroy.sh
kubectl get pods -n ecom
opencode
ls
cd project/
ls
cat nohup.out 
cat nohup.out | tail -fn100
cat nohup.out 
clear
tail -fn100 nohup.out 
clear
ls
cd project/
ls
clear
aws configure list
clear
ls
./deploy.sh 
kubectl get nodes
cd
kubectl
kubectl get nodes
kubectl get context
opencode
aws eks update-kubeconfig --region us-east-2 --name apurv-eks
aws s3 ls
aws eks update-kubeconfig --region us-east-1 --name apurv-eks
kubectl get nodes
clear
ls
clear
helm upgrade --install kubeintel-agent ./helm/kubeintel-agent   --namespace kubeintel --create-namespace   --set clusterId=40d4ef0c-a445-477b-ab0d-9d28992ba181   --set registrationToken=eda763da…   --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev   --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')   --set tlsVerify=false
helm
clear
ls
opencode
ls
opencode
ls
cd microservices-demo/
ls
opencode
ls
du -sh .
zip bkp.zip *
sudo apt install zip
zip bkp.zip *
ls
clear
ls
opencode
cd ..
kubectl get ns -A
kubectl create ns ecommerce
kubectl get ns -A
ls
kubectl apply -k microservices-demo/base/
kubectl get pods -n ecommerce
kubectl get pods -n ecommarce
kubectl get ns
kubectl get pods -n ecommerce
kubectl delete -k microservices-demo/base/
kubectl delete -k microservices-demo/base/ -n ecommerce
kubectl apply -k microservices-demo/base/ -n ecommerce
kubectl get pods -n ecommerce
watch kubectl get pods -n ecommerce
kubectl get svc -n ecommerce
ls
cd project/
ls
cd ..
ls
cd project/
ls
kubectl get ns -A
ls
cd ..
ls
cd microservices-demo/
ls
kubectl create ns monitoring
kubectl apply -k monitoring/ -n monitoring
kubectl get pods -n monitoring
kubectl get svc -n monitoring
clear
opencode
kubectl get pods -n monitoring
opencode
clear
ls
cd
clear
sls
clear
ls
helm upgrade --install kubeintel-agent https://eternal-numeral-fragment.ngrok-free.dev/api/onboarding/agent-chart.tgz   --namespace kubeintel --create-namespace   --set clusterId=ae67f44b-e83b-48f6-b385-2db5b34f77f2   --set registrationToken=0321eb9b…   --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev   --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')   --set tlsVerify=false
kubectl get ns -A
kubectl get pods -n kubeintel
kubectl describe pod kubeintel-agent-6d6cd499c9-zsh94 
kubectl describe pod kubeintel-agent-6d6cd499c9-zsh94 -n kubeintel 
kubectl get logs kubeintel-agent-6d6cd499c9-zsh94 -n kubeintel 
kubectl get pods -n kubeintel
kubectl logs kubeintel-agent-6d6cd499c9-zsh94  -n kubeintel
kubectl delete ns kubeintel
kubectl get ns -A
helm upgrade --install kubeintel-agent https://eternal-numeral-fragment.ngrok-free.dev/api/onboarding/agent-chart.tgz   --namespace kubeintel --create-namespace   --set clusterId=a7cd0ead-97b4-4cc9-80b7-13c8d9b00509   --set registrationToken=5fc47cc95f01fce5271c43ad8bf08679a78883ecfa3a5434d648f829b68b473822c676439635e093c72d3d7be865c2823f9692a2b9d53f8e31a5ed74f3a9e79e   --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev   --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')   --set tlsVerify=false
kubectl logs helm upgrade --install kubeintel-agent https://eternal-numeral-fragment.ngrok-free.dev/api/onboarding/agent-chart.tgz \
  --namespace kubeintel --create-namespace \
  --set clusterId=a7cd0ead-97b4-4cc9-80b7-13c8d9b00509 \
  --set registrationToken=5fc47cc95f01fce5271c43ad8bf08679a78883ecfa3a5434d648f829b68b473822c676439635e093c72d3d7be865c2823f9692a2b9d53f8e31a5ed74f3a9e79e \
  --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev \
  --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}') \
  --set tlsVerify=false
kubectl logs kubeintel-agent-597bc95947-5klt8 -n kubeintel
opencode
clear
ls
cd project/
ls
opencode
cd ..
opencode
clear
opencode
ls
cd microservices-demo/
ls
opencode
ls
cd ..
ls
cd project/
ls
nohup ./destroy.sh
ls
cat nohup.out 
ls
rm -rf nohup.out 
ls
clear
cd project/
ls
./deploy.sh 
./destroy.sh 
clear
ls
./deploy.sh 
ls
cd ..
ls
cd K8S/
ls
cd ..
ls
cd microservices-demo/
ls
kubectl get contect
kubectl get context
clear
aws eks update-kubeconfig --name apurv-eks --region us-east-1
kubectl get nodes
ls
kubectl apply -k base/
cleaer
clear
kubectl delete -k base/
kubectl create ns ecommerce
kubectl delete -k base/ -n ecommerce
kubectl apply -k base/ -n ecommerce
kubectl get pods -n ecommerce
kubectl get svc -n ecommerce
ls
kubectl delete -k base/ -n ecommerce
kubectl delete ns ecommerce
kubectl get all -A
clear
ls
cd ../project/
ls
./destroy.sh 
clear
ls
./deploy.sh 
ls
cd ..
ls
cd microservices-demo/
ls
./manage.sh up
watch kubectl get pods -n ecommerce
clear
watch kubectl get pods -n ecommerce
helm upgrade --install kubeintel-agent https://eternal-numeral-fragment.ngrok-free.dev/api/onboarding/agent-chart.tgz   --namespace kubeintel --create-namespace   --set clusterId=c6165aa1-52e7-46cc-a8c0-bc8758cd25eb   --set registrationToken=8caf9a7aa2ff341c0d07896d2716a5c19ce655b71895f0754bdef66d243a6015e899f3920a6f3b4f84ffee9d786c9ede305c12f0e645bf10f001dcc40ced3c3f   --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev   --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')   --set tlsVerify=false
kubectl get ns -A
kubectl delete ns kubeintel
helm upgrade --install kubeintel-agent https://eternal-numeral-fragment.ngrok-free.dev/api/onboarding/agent-chart.tgz   --namespace kubeintel --create-namespace   --set clusterId=c2d072cf-d0af-40a0-9648-7f6cabaa5ad2   --set registrationToken=cdc1e2b3f54f96b0910f936aa242cf08f1231165d845a0907d822d3c6247ed7863498fb2e329b194d65487b5cfb273be434500c322002d0f079099406c0e7587   --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev   --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')   --set rbac=admin   --set tlsVerify=false
kubectl get pods -n kubeintel
ls
cd src/
ls
tree
cd adservice/
ls
cd ..
ls
cd ..
ls
cd ..
ls
git pull https://git.aitglobalindia.com/apurv.bidkar/kubernautics
git clone https://git.aitglobalindia.com/apurv.bidkar/kubernautics
ls
cd microservices-demo/
ls
du -sh .
cd ..
ls
cd kubernautics/
ls
git status
cp ../microservices-demo .
cp -r ../microservices-demo .
ls
cd microservices-demo/
ls
cd ..
ls
git status
git add .
git commit -m "microservice-demo added"
git push
ls
git status
ls
ls -lart
ls
mv microservices-demo/* .
ls
rm microservices-demo/
rmdir microservices-demo/
rmdir -rf microservices-demo/
rm -rf microservices-demo/
ls
git status
git add .
git commit -m "commit"
git push
opencode
k9s
clear
ls
opencode
ls
cd microservices-demo/
ls
opencode
ls
cat manage.sh 
cd ..
opencode
ls
cd microservices-demo/
ls
./manage.sh down
kubectl get all -A
clear
kubectl get ns
kubectl delete ns kubeintel
kubectl get ns
cd ..
ls
cd project/
ls
./destroy.sh 
ls
cd project/
ls
cd ..
ls
cd microservices-demo/
ls
opencode
ls
cp manage.sh bkp.sh
ls
opencode
ls
clear
ls
cd ..
ls
clear
ls
cd microservices-demo/
ls
clear
ls
clear
ls
clear
ls
clear
ls
cd ..
ls
clear
ls
cd microservices-demo/
ls
clear
ls
cd ..
ls
cd project/
ls
./deploy.sh 
ls
cd ../microservices-demo/
ls
./manage.sh up
./manage.sh mn-up
kubectl get pods -n monitoring
kubectl get pods -n ecommerce
kubectl get svc -A
kubectl get svc -n monitoring
clear
ls
./manage.sh mn-down
./manage.sh down
ls
cd ..
ls
cd project/
ls
./destroy.sh 
clear
ls
cd project/
ls
./deploy.sh 
ls
cd ..
ls
cd microservices-demo/
ls
./manage.sh up
watch kubectl get pods -n ecommerce
./manage.sh mn-up
watch kubectl get pods -A
clear
ls
kubectl get pods -n ecommerce
kubectl get pods -n monitoring
kubectl get svc -n ecommerce
kubectl get nodes
ls
kubectl get pods -A
lw
ls
cd project/
sls
ls
./destroy.sh 
kubectl get pods
kubectl get pods -A
ls
cd ..
ls
cd microservices-demo/
ls
./manage.sh down
./manage.sh mn-down
cd ..
ls
cd project/
ls
./destroy.sh 
clear
ls
btop
clear
ls
cd project/
ls
kubectl get pods
clear
ls
./deploy.sh 
ls
cd ../microservices-demo/
ls
./manage.sh up
kubectl get pods -n ecommerce
./manage.sh mn-up
kubectl get pods -n monitoring
kubectl get pods -A
cleear
clear
ls
cd project/
ls
cd ../microservices-demo/
ls
./manage.sh down
./manage.sh mn-down
ls
cd ../project/
ls
./destroy.sh 
clear
ls
clear
ls
cd project/
ls
./deploy.sh 
cd project/
./destroy.sh 
clear
ls
opencode
clear
ls
cd project/
ls
cd ..
ls
ls -lart
cd project/
ls
clear
ls
cat deploy.sh 
cd ..
ls
cat set
cat setup.sh 
clear
ls
cd kubernautics/
ls
cd ..
ls
pwd
ls
cd project/
ls -lart
cd ..
ls
cd K8S/
ls
cd ..
ls
./setup.sh 
ls
./setup.sh 
ls
cat seteks.sh 
cd project/
ls
./deploy.sh 
opencode
cd ..
opencode
ls
cd project/
ls
./deploy.sh 
ls
cd ..
ls
cd K8S/
ls
cd ..
ls
./seteks.sh 
ls
cd microservices-demo/
ls
cat manage.sh 
clear
kubectl get all
clear
exit
clear
ls
clear
ls
cd microservices-demo/
ls
./manage.sh up
kubectl get all -a
kubectl get all 
kubectl get namespaces
kubectl get all -n ecommerce
kubectl get ns
helm upgrade --install kubeintel-agent https://eternal-numeral-fragment.ngrok-free.dev/api/onboarding/agent-chart.tgz   --namespace kubeintel --create-namespace   --set clusterId=8edb59ee-d989-47fa-b9ad-1bec2d49b4c0   --set registrationToken=f2aa2f6b4a83222c29b34c1a939fa5df1ad1c176791e507682973468b3732cb85e91464332674554668721758d59dbfceec8eb1807cc741477c6c5be1a9f52b2   --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev   --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')   --set rbac=admin   --set tlsVerify=false
kubectl get ns
ls
cd microservices-demo/
ls
kubectl get ns
kubectl delete ns kubeintel
kubectl get ns
helm upgrade --install kubeintel-agent https://eternal-numeral-fragment.ngrok-free.dev/api/onboarding/agent-chart.tgz   --namespace kubeintel --create-namespace   --set clusterId=958eb733-295f-48a5-b258-938895bab52c   --set registrationToken=28511aaed11c58d71dc8ea30e018a720880c4d254d87a2f5c0c79c1fc7d9686bef1a93f6c83a49c18d3d99babcc103ac8d74b5de97611f3dd05218712e287b4f   --set apiEndpoint=https://eternal-numeral-fragment.ngrok-free.dev   --set apiServerUrl=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')   --set rbac=admin   --set tlsVerify=false
kubectl get ns
kubectl get all -n ecommerce
clear
ls
opencode
./project/destroy.sh 
opencode
clear
ls
opencode
./project/destroy.sh 
.ls
ls
cd project/
ls
cd ..
ls
opencode
ls
cd kubernautics/
ls
cd ../
ls
cd kubernautics/
cd -
ld
ls
du -sh .
rm K8S.zip 
ls
du -sh .
rm microservices-demo*
rm -rf microservices-demo*
du -sh .
ls
cd project/
ls
du -sh .
cd ../
ls
git status
git init
git status
git add .
git status
opencode
sudo apt update
opencode
ls
git commit -m "1 commit"
clear
git remote add origin https://github.com/pradipmengal/scripts.git
git push -u origin master
opencode upgrade
ls
opencode
git status
git add .
rm -rf ./local/share/opencode*
ls
du sh .
