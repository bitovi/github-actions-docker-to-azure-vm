#!/bin/bash
# shellcheck disable=SC2086,SC1091

SCRIPTS_PATH="$GITHUB_ACTION_PATH/operations/_scripts"
OPS_ENV_PATH="$GITHUB_ACTION_PATH/operations/deployment"

source "$SCRIPTS_PATH/deploy/deploy_helpers.sh"
source "$SCRIPTS_PATH/generate/generate_helpers.sh"

isDebugMode && set -x
set -e

echo "::group::Deploy"
GITHUB_REPO_NAME=$(echo "$GITHUB_REPOSITORY" | sed 's/^.*\///')
export GITHUB_REPO_NAME

# Generate buckets identifiers and check them agains Azure Rules 
TF_STATE_BUCKET="$($SCRIPTS_PATH/generate/generate_buckets_identifiers.sh tf | xargs)"
export TF_STATE_BUCKET

source "$SCRIPTS_PATH/deploy/check_bucket_name.sh"
checkStorageName $AZURE_STORAGE_ACCOUNT azure
checkContainerName $TF_STATE_BUCKET azure

LB_LOGS_BUCKET="$($SCRIPTS_PATH/generate/generate_buckets_identifiers.sh lb | xargs)"
export LB_LOGS_BUCKET

$SCRIPTS_PATH/deploy/check_bucket_name.sh $LB_LOGS_BUCKET

# Generate subdomain
$SCRIPTS_PATH/generate/generate_subdomain.sh

# Generate the provider.tf file
$SCRIPTS_PATH/generate/generate_provider.sh

# Generate terraform variables
$SCRIPTS_PATH/generate/generate_tf_vars.sh

# Generate dot_env
$SCRIPTS_PATH/generate/generate_dot_env.sh

# Generate app repo
$SCRIPTS_PATH/generate/generate_app_repo.sh

# Generate bitops config
$SCRIPTS_PATH/generate/generate_bitops_config.sh

# Generate Ansible playbook
$SCRIPTS_PATH/generate/generate_ansible_playbook.sh

if isDebugMode; then
  cmd="ls -al $OPS_ENV_PATH/terraform/" && echo $cmd && $cmd
  cmd="cat $OPS_ENV_PATH/terraform/provider.tf" && echo $cmd && $cmd
  cmd="cat $OPS_ENV_PATH/terraform/bitops.config.yaml" && echo $cmd && $cmd
  cmd="ls $OPS_ENV_PATH/ansible/app/${GITHUB_REPO_NAME}" && echo $cmd && $cmd
fi

TERRAFORM_COMMAND=""
TERRAFORM_DESTROY=""
if [ "$STACK_DESTROY" == "true" ]; then
  TERRAFORM_COMMAND="destroy"
  TERRAFORM_DESTROY="true"
  ANSIBLE_SKIP_DEPLOY="true"
fi
echo "::endgroup::"

if [[ $SKIP_BITOPS_RUN == "true" ]]; then
  echo "SKIP_BITOPS_RUN is true, skipping BitOps execution"
else
  echo "::group::BitOps Execution"  
  echo "Running BitOps for env: $BITOPS_ENVIRONMENT"

  docker run --rm --name bitops \
  -e SCRIPTS_PATH="$SCRIPTS_PATH" \
  -e OPS_ENV_PATH="$OPS_ENV_PATH" \
  -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
  -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
  -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
  -e ARM_TENANT_ID=$ARM_TENANT_ID \
  -e azure_resource_identifier=$azure_resource_identifier \
  -e azure_vm_admin_username=$azure_vm_admin_username \
  -e azure_vm_admin_password=$azure_vm_admin_password \
  -e BITOPS_ENVIRONMENT="$BITOPS_ENVIRONMENT" \
  -e SKIP_DEPLOY_TERRAFORM="$SKIP_DEPLOY_TERRAFORM" \
  -e SKIP_DEPLOY_HELM="$SKIP_DEPLOY_HELM" \
  -e BITOPS_TERRAFORM_COMMAND="$TERRAFORM_COMMAND" \
  -e TERRAFORM_DESTROY="$TERRAFORM_DESTROY" \
  -e ANSIBLE_SKIP_DEPLOY="$ANSIBLE_SKIP_DEPLOY" \
  -e TF_STATE_BUCKET="$TF_STATE_BUCKET" \
  -e TF_STATE_BUCKET_DESTROY="$TF_STATE_BUCKET_DESTROY" \
  -e DEFAULT_FOLDER_NAME="_default" \
  -e BITOPS_FAST_FAIL="$BITOPS_FAST_FAIL" \
  -e AZURE_STORAGE_ACCOUNT="$AZURE_STORAGE_ACCOUNT" \
  -e AZURE_STORAGE_SKU="$AZURE_STORAGE_SKU" \
  -e AZURE_DEFAULT_REGION="$AZURE_DEFAULT_REGION" \
  -e DEBUG_MODE="$DEBUG_MODE" \
  -v "$GITHUB_ACTION_PATH/operations:/opt/bitops_deployment" \
  bitovi/bitops:dev

  BITOPS_RESULT=$?
  echo "::endgroup::"
fi

exit $BITOPS_RESULT

# TODO: support incoming image tag from workflow
