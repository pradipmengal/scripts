#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

deploy_module() {
    local name="$1"
    local dir="$2"
    local skip_plan="$3"
    local extra_args="$4"

    echo ""
    echo "=========================================="
    echo " Deploying: $name"
    echo " Directory: $dir"
    echo "=========================================="

    cd "$BASE_DIR/$dir"

    rm -rf .terraform .terraform.lock.hcl

    terraform init -reconfigure
    terraform fmt
    terraform validate

    if [ "$skip_plan" != "skip_plan" ]; then
        # shellcheck disable=SC2086
        terraform plan $extra_args
    fi

    # shellcheck disable=SC2086
    terraform apply -auto-approve $extra_args

    echo "$name completed successfully."
}

# -------------------------------------------------
# 1. BACKEND - S3 bucket + DynamoDB for state mgmt
# -------------------------------------------------
deploy_module "BACKEND" "BACKEND" "" ""

# -------------------------------------------------
# 2. VPC - Networking (VPC, subnets, IGW, RTs)
# -------------------------------------------------
deploy_module "VPC" "VPC"

# -------------------------------------------------
# 3. NAT - EC2 NAT instances in public subnets
# -------------------------------------------------
deploy_module "NAT" "NAT"

# -------------------------------------------------
# 4. NAT_LAMBDA - ENI reattachment lifecycle hooks
# -------------------------------------------------
deploy_module "NAT_LAMBDA" "NAT_LAMBDA"

# -------------------------------------------------
# 5. EKS - Kubernetes cluster
#    Terminate NAT instances before EKS to avoid
#    blackhole network condition. ASG auto-restores.
# -------------------------------------------------
echo ""
echo "Finding NAT instances to terminate..."

cd "$BASE_DIR/NAT"

ASG_NAMES=$(terraform output -json nat_asg_names 2>/dev/null | jq -r '.[]')
INSTANCE_IDS=""
for asg in $ASG_NAMES; do
    ids=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names "$asg" \
        --query "AutoScalingGroups[0].Instances[*].InstanceId" \
        --output text)
    INSTANCE_IDS="$INSTANCE_IDS $ids"
done

INSTANCE_IDS=$(echo "$INSTANCE_IDS" | xargs)
if [ -n "$INSTANCE_IDS" ]; then
    echo "Terminating NAT instances: $INSTANCE_IDS"
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    echo "Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
    echo "NAT instances terminated. Waiting for ASG to restore new instances..."

    # Wait for ASG to launch and pass status checks
    MAX_WAIT=300
    ELAPSED=0
    while [ $ELAPSED -lt $MAX_WAIT ]; do
        ALL_HEALTHY=true
        for asg in $ASG_NAMES; do
            HEALTH=$(aws autoscaling describe-auto-scaling-groups \
                --auto-scaling-group-names "$asg" \
                --query "AutoScalingGroups[0].Instances[*].HealthStatus" \
                --output text)
            for status in $HEALTH; do
                if [ "$status" != "Healthy" ]; then
                    ALL_HEALTHY=false
                    break 2
                fi
            done
        done

        if [ "$ALL_HEALTHY" = true ]; then
            echo "All NAT instances are healthy. Proceeding with EKS..."
            break
        fi

        echo "Waiting for NAT instances to become healthy... (${ELAPSED}s/${MAX_WAIT}s)"
        sleep 10
        ELAPSED=$((ELAPSED + 10))
    done

    if [ "$ALL_HEALTHY" != true ]; then
        echo "ERROR: NAT instances did not become healthy within ${MAX_WAIT}s"
        exit 1
    fi
else
    echo "No NAT instances found to terminate."
fi
echo ""

deploy_module "EKS" "EKS" "" "-var=key_pair_name=EKS-Master8"

echo ""
echo "=========================================="
echo " All modules deployed successfully!"
echo "=========================================="
