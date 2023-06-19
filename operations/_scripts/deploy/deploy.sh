#!/bin/bash
# shellcheck disable=SC2086,SC1091

echo "::group::Deploy"

echo "deploy script running in: $(pwd)"

BITOPS_TEMP_DIR="$GITHUB_ACTION_PATH/operations"
SCRIPTS_PATH="$BITOPS_TEMP_DIR/_scripts"
DEPLOY_SCRIPTS_PATH="$BITOPS_TEMP_DIR/deploy"
GENERATE_SCRIPTS_PATH="$BITOPS_TEMP_DIR/generate"

source "$DEPLOY_SCRIPTS_PATH/deploy_helpers.sh"
source "$GENERATE_SCRIPTS_PATH/generate_helpers.sh"
isDebugMode && set -x
set -e

OPS_REPO_ENV_NAME="deployment"
OPS_ENV_PATH="$BITOPS_TEMP_DIR/$OPS_REPO_ENV_NAME"
OPS_REPO_ANSIBLE_PATH="$OPS_ENV_PATH/ansible"
OPS_REPO_TERRAFORM_PATH="$OPS_ENV_PATH/terraform"

GITHUB_REPO_NAME=$(echo "$GITHUB_REPOSITORY" | sed 's/^.*\///')
export GITHUB_REPO_NAME

# Generate buckets identifiers and check them agains Azure Rules 
TF_STATE_BUCKET="$($GENERATE_SCRIPTS_PATH/generate_buckets_identifiers.sh tf | xargs)"
export TF_STATE_BUCKET

source "$DEPLOY_SCRIPTS_PATH/check_bucket_name.sh"
checkStorageName $AZURE_STORAGE_ACCOUNT azure
checkContainerName $TF_STATE_BUCKET azure

LB_LOGS_BUCKET="$($GENERATE_SCRIPTS_PATH/generate_buckets_identifiers.sh lb | xargs)"
export LB_LOGS_BUCKET

$DEPLOY_SCRIPTS_PATH/check_bucket_name.sh $LB_LOGS_BUCKET

# Generate subdomain
$GENERATE_SCRIPTS_PATH/generate_subdomain.sh

# Generate the provider.tf file
$GENERATE_SCRIPTS_PATH/generate_provider.sh

# Generate terraform variables
$GENERATE_SCRIPTS_PATH/generate_tf_vars.sh

# Generate dot_env
$GENERATE_SCRIPTS_PATH/generate_dot_env.sh

# Generate app repo
$GENERATE_SCRIPTS_PATH/generate_app_repo.sh

# Generate bitops config
$GENERATE_SCRIPTS_PATH/generate_bitops_config.sh

# Generate Ansible playbook
$GENERATE_SCRIPTS_PATH/generate_ansible_playbook.sh

if isDebugMode; then
  cmd="ls -al $OPS_REPO_TERRAFORM_PATH/" && echo $cmd && $cmd
  cmd="cat $OPS_REPO_TERRAFORM_PATH/provider.tf" && echo $cmd && $cmd
  cmd="cat $OPS_REPO_TERRAFORM_PATH/bitops.config.yaml" && echo $cmd && $cmd
  cmd="ls $OPS_REPO_ANSIBLE_PATH/app/$GITHUB_REPO_NAME" && echo $cmd && $cmd
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



  docker run --name bitops \
  --env-file $DEPLOY_SCRIPTS_PATH/.docker_env \
  -v "$BITOPS_TEMP_DIR:/opt/bitops_deployment" \
  bitovi/bitops:latest

  BITOPS_RESULT=$?
  echo "::endgroup::"
fi

exit $BITOPS_RESULT

# TODO: support incoming image tag from workflow
