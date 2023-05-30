#!/bin/bash

# set -x
set -e

echo "::group::In Deploy"
GITHUB_REPO_NAME=$(echo "$GITHUB_REPOSITORY" | sed 's/^.*\///')

# Generate buckets identifiers and check them agains AWS Rules 
TF_STATE_BUCKET="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_buckets_identifiers.sh tf | xargs)"
export TF_STATE_BUCKET

$GITHUB_ACTION_PATH/operations/_scripts/deploy/check_bucket_name.sh $TF_STATE_BUCKET
LB_LOGS_BUCKET="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_buckets_identifiers.sh lb | xargs)"
export LB_LOGS_BUCKET

$GITHUB_ACTION_PATH/operations/_scripts/deploy/check_bucket_name.sh $LB_LOGS_BUCKET

# Generate subdomain
$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_subdomain.sh

# Generate the provider.tf file
$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_provider.sh

# Generate terraform variables
$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_tf_vars.sh

# Generate dot_env
$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_dot_env.sh

# Generate app repo
$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_app_repo.sh

# Generate bitops config
$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_bitops_config.sh

# Generate Ansible playbook
$GITHUB_ACTION_PATH/operations/_scripts/generate/generate_ansible_playbook.sh

# List terraform folder
echo "ls -al $GITHUB_ACTION_PATH/operations/deployment/terraform/"
ls -al "$GITHUB_ACTION_PATH/operations/deployment/terraform/"
# Prints out bitops.config.yaml
echo "cat $GITHUB_ACTION_PATH/operations/deployment/terraform/bitops.config.yaml"
cat "$GITHUB_ACTION_PATH/operations/deployment/terraform/bitops.config.yaml"


echo "cat GITHUB_ACTION_PATH/operations/deployment/terraform/provider.tf"
cat "$GITHUB_ACTION_PATH/operations/deployment/terraform/provider.tf"
echo "ls GITHUB_ACTION_PATH/operations/deployment/ansible/app/${GITHUB_REPO_NAME}"
ls "$GITHUB_ACTION_PATH/operations/deployment/ansible/app/${GITHUB_REPO_NAME}"

TERRAFORM_COMMAND=""
TERRAFORM_DESTROY=""
if [ "$STACK_DESTROY" == "true" ]; then
  TERRAFORM_COMMAND="destroy"
  TERRAFORM_DESTROY="true"
  ANSIBLE_SKIP_DEPLOY="true"
fi
echo "::endgroup::"

if [[ $SKIP_BITOPS_RUN == "true" ]]; then
  exit 1
fi

echo "::group::BitOps Excecution"  
echo "Running BitOps for env: $BITOPS_ENVIRONMENT"
docker run --rm --name bitops \
-e ARM_CLIENT_ID=$ARM_CLIENT_ID \
-e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
-e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
-e ARM_TENANT_ID=$ARM_TENANT_ID \
-e azure_resource_identifier=$azure_resource_identifier \
-e BITOPS_ENVIRONMENT="${BITOPS_ENVIRONMENT}" \
-e SKIP_DEPLOY_TERRAFORM="${SKIP_DEPLOY_TERRAFORM}" \
-e SKIP_DEPLOY_HELM="${SKIP_DEPLOY_HELM}" \
-e BITOPS_TERRAFORM_COMMAND="${TERRAFORM_COMMAND}" \
-e TERRAFORM_DESTROY="${TERRAFORM_DESTROY}" \
-e ANSIBLE_SKIP_DEPLOY="${ANSIBLE_SKIP_DEPLOY}" \
-e TF_STATE_BUCKET="${TF_STATE_BUCKET}" \
-e TF_STATE_BUCKET_DESTROY="${TF_STATE_BUCKET_DESTROY}" \
-e DEFAULT_FOLDER_NAME="_default" \
-e BITOPS_FAST_FAIL="${BITOPS_FAST_FAIL}" \
-v "$GITHUB_ACTION_PATH/operations:/opt/bitops_deployment" \
bitovi/bitops:dev
BITOPS_RESULT=$?
echo "::endgroup::"

exit $BITOPS_RESULT
