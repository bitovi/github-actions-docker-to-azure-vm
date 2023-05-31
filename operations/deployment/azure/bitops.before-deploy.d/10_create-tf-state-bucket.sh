#!/bin/bash
# shellcheck disable=SC2046,SC2086,SC1091

# create a bucket with the azure cli
# https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create

# exit on any error
set -e
set -x

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

account=$AZURE_STORAGE_ACCOUNT
group=$azure_resource_identifier
container=$AZURE_TF_STATE_CONTAINER

# check if accounts already exist
check_storage=$(az storage account check-name --name $account) # json
storage_available=$(echo $check_storage | jq -r .nameAvailable) # 'true' or 'false
storage_reason=$(echo $check_storage | jq -r .reason) # 'AlreadyExists' or 'Invalid'

# we might not have a group yet, ie on first run. create it if not.
group_exists=$(az group exists --name $group) # 'true' or 'false
if [ $group_exists == 'false' ]; then
  echo "Resource Group '$group' does not exist. Creating..."
  createResourceGroup
else
  echo "Using Resource Group '$group'."
fi

# if the storage account name is available, create it
# if it already exists, skip
# if some other error, exit
if [ $storage_available == 'true' ]; then
  echo "Storage Account '$account' is available. Creating..."
  storage_result=$(createStorageAccount | jq -r .provisioningState)
  if [ $storage_result != 'Succeeded' ]; then
    success=false
  fi
elif [ $storage_reason == 'AlreadyExists' ]; then
  echo "Storage Account $account already exists."
else
  success=false
fi

if [ $success == 'true' ]; then
  msg_tail="in Storage Account '$account'"
  if [ $(storageContainerExists) == 'true' ]; then
    echo -n "Container '$container' already exists $msg_tail."
    echo " Skipping container creation."
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
