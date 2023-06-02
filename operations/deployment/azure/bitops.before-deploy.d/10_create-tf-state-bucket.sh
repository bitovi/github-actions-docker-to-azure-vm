#!/bin/bash
# shellcheck disable=SC2046,SC2086,SC1091

# create a bucket with the azure cli
# https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create

# exit on any error
set -e
# set -x

success=true

source "$BITOPS_TEMPDIR/deployment/_scripts/az_cli_helpers.sh"

# avoid running this script if the Terraform CLI Action is `destroy`
terraform_cmd=$(cat $BITOPS_ENVROOT/terraform/bitops.config.yaml | shyaml get-value terraform.cli.stack-action)
if [ $terraform_cmd == "destroy"  ]; then
  echo '=================' && echo "Terraform Action is 'destroy'. Skipping $(basename $0)." && echo '================='
  exit 0
else 
  echo '=================' && echo "Running $(basename $0)..."
fi

# pull in vars from env
account=$AZURE_STORAGE_ACCOUNT
group=$azure_resource_identifier
container=$TF_STATE_BUCKET

### CHECK/CREATE RESOURCE GROUP
# we might not have a group yet, ie on first run. create it if not.
group_exists=$(az group exists --name $group) # 'true' or 'false
if [ $group_exists == 'false' ]; then
  echo "Resource Group '$group' does not exist. Creating..." && createResourceGroup
else
  echo "Using existing Resource Group '$group'."
fi

### CHECK/CREATE STORAGE ACCOUNT
# check if storage account already exists
# if the storage account name is available, create it in our resource group
# if it already exists - check if it exists in the resource group
# if so, skip creation
# if it exists in another resource group, exit
# if some other error, exit
check_storage=$(az storage account check-name --name $account) # json
storage_available=$(echo $check_storage | jq -r .nameAvailable) # 'true' or 'false
storage_reason=$(echo $check_storage | jq -r .reason) # 'AlreadyExists' or 'Invalid'

if [ $storage_available == 'true' ]; then
  echo "Storage Account '$account' is available. Creating..."
  if [ $(createStorageAccount | jq -r .provisioningState) != 'Succeeded' ]; then
    success=false
  fi
elif [ $storage_reason == 'AlreadyExists' ]; then
  # check if it exists in our resource group
  storage_group=$(az storage account show --name $account | jq -r .resourceGroup)
  if [ $storage_group == $group ]; then
    echo "Storage Account '$account' exists in Resource Group '$group'."
  else
    echo "Storage Account '$account' exists in another Resource Group: '$storage_group'."
    success=false
  fi
else
  echo "Error checking Storage Account '$account': $check_storage"
  success=false
fi

### CHECK/CREATE STORAGE CONTAINER
# check if storage container already exists
if [ $success == 'true' ]; then
  msg_tail="in Storage Account '$account'"
  if [ $(storageContainerExists) == 'true' ]; then
    echo "Container '$container' already exists $msg_tail."
  else
    echo "Creating container '$container' $msg_tail..."
    container_result=$(createStorageContainer)
    if [ "$container_result" == 'false' ]; then
      echo "container_result: $container_result"
      success=false
    fi
  fi
fi

end_msg="container '$container' in Storage Account '$account', in Resource Group '$group'"
if [ $success == 'true' ]; then
  echo "All done with $end_msg." && echo '================='
else
  echo "There was an error creating $end_msg: "
  echo $check_storage | jq
  echo '================='
  exit 1
fi
