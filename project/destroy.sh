#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()   { echo -e "${GREEN}[OK]${NC}    $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $1"; }

destroy_module() {
    local name="$1"
    local dir="$2"
    local extra_args="${3:-}"

    echo ""
    echo "=========================================="
    echo " Destroying: $name"
    echo " Directory: $BASE_DIR/$dir"
    echo "=========================================="

    cd "$BASE_DIR/$dir"

    rm -rf .terraform .terraform.lock.hcl

    if terraform init -reconfigure -lock=false 2>/dev/null; then
        if terraform state list &>/dev/null; then
            # shellcheck disable=SC2086
            terraform destroy -auto-approve -lock=false $extra_args
            ok "$name destroyed."
        else
            warn "$name: no resources in state."
        fi
    else
        warn "$name: init failed (backend may not exist). Skipping."
    fi
}

detect_backend_bucket() {
    grep -rh 'bucket\s*=' "$BASE_DIR" --include='backend.tf' 2>/dev/null \
        | sed 's/.*=\s*"\(.*\)"/\1/' \
        | sort -u \
        || true
}

purge_bucket() {
    local bucket="$1"

    log "Purging S3 bucket: $bucket"

    if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
        warn "Bucket $bucket does not exist. Skipping."
        return
    fi

    local total=1
    local passes=0

    while [ "$total" -gt 0 ] && [ "$passes" -lt 10 ]; do
        passes=$((passes + 1))

        local versions_json
        versions_json=$(aws s3api list-object-versions --bucket "$bucket" --output json 2>/dev/null)

        [ -z "$versions_json" ] && break

        total=$(echo "$versions_json" | jq '[.Versions[]?, .DeleteMarkers[]?] | length')

        [ "$total" -eq 0 ] && break

        echo "$versions_json" \
            | jq '{Objects: ([.Versions[]?, .DeleteMarkers[]?] | map({Key, VersionId})), Quiet: true}' \
            > /tmp/purge_bucket.json

        aws s3api delete-objects --bucket "$bucket" \
            --delete file:///tmp/purge_bucket.json > /dev/null

        log "Pass $passes: deleted $total items, checking for more..."
    done

    if [ "$total" -gt 0 ]; then
        warn "Bucket $bucket may still have objects. Try running destroy.sh again."
    else
        ok "Bucket $bucket purged."
    fi
}

echo ""
echo "============================================="
echo " Terraform Infrastructure Destroyer"
echo "============================================="
echo ""

BUCKETS=$(detect_backend_bucket)
[ -n "$BUCKETS" ] && while IFS= read -r b; do log "Target bucket: $b"; done <<< "$BUCKETS"
echo ""

log "Phase 1: EKS"
destroy_module "EKS" "EKS" "-var=key_pair_name=EKS-Master8"

log "Phase 2: NAT_LAMBDA"
destroy_module "NAT_LAMBDA" "NAT_LAMBDA"

log "Phase 3: Terminating NAT instances before destroy..."
cd "$BASE_DIR/NAT"
rm -rf .terraform .terraform.lock.hcl
terraform init -reconfigure -lock=false 2>/dev/null || true

ASG_NAMES=$(terraform output -json nat_asg_names 2>/dev/null | jq -r '.[]')
INSTANCE_IDS=""
for asg in $ASG_NAMES; do
    ids=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names "$asg" \
        --query "AutoScalingGroups[0].Instances[*].InstanceId" \
        --output text 2>/dev/null)
    INSTANCE_IDS="$INSTANCE_IDS $ids"
done

INSTANCE_IDS=$(echo "$INSTANCE_IDS" | xargs)
if [ -n "$INSTANCE_IDS" ]; then
    log "Terminating NAT instances: $INSTANCE_IDS"
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS
    log "Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
    ok "NAT instances terminated."
else
    warn "No NAT instances found."
fi

log "Phase 4: NAT"
destroy_module "NAT" "NAT"

log "Phase 5: VPC"
destroy_module "VPC" "VPC"

if [ -n "$BUCKETS" ]; then
    log "Phase 6: Emptying S3 buckets and deleting BACKEND resources"

    while IFS= read -r BUCKET; do
        [ -z "$BUCKET" ] && continue
        purge_bucket "$BUCKET"

        if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
            log "Deleting S3 bucket: $BUCKET"
            aws s3api delete-bucket --bucket "$BUCKET"
            ok "S3 bucket deleted."
        fi
    done <<< "$BUCKETS"
fi

DYNAMO_TABLE=$(grep -rh 'dynamodb_table\s*=' "$BASE_DIR" --include='backend.tf' 2>/dev/null \
    | sed 's/.*=\s*"\(.*\)"/\1/' | head -1 || true)

[ -z "$DYNAMO_TABLE" ] && DYNAMO_TABLE="demo-project2-tf-locks"

if aws dynamodb describe-table --table-name "$DYNAMO_TABLE" &>/dev/null; then
    log "Deleting DynamoDB table: $DYNAMO_TABLE"
    aws dynamodb delete-table --table-name "$DYNAMO_TABLE"
    aws dynamodb wait table-not-exists --table-name "$DYNAMO_TABLE"
    ok "DynamoDB table deleted."
fi

echo ""
echo "============================================="
echo -e "${GREEN} All infrastructure destroyed!${NC}"
echo "============================================="
