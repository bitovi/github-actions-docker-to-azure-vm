#!/bin/bash
# shellcheck disable=SC2086,SC2154

function azLogin() {
  az login --service-principal -u "${ARM_CLIENT_ID}" -p "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
}

function getStorageAccountKey() {
  local result
  result=$(az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT \
    --resource-group $azure_resource_identifier \
    --query "[0].value" --output tsv)
  echo $result
}

function resourceGroupExists() {
  # returns true/false
  group_name=$1
  az group exists --name $group_name
}

function createResourceGroup() {
  az group create --name $azure_resource_identifier --location $AZURE_DEFAULT_REGION
  az group wait --name $azure_resource_identifier --created
}

function createStorageAccount() {
  local PROVISIONED
  az storage account create --name $AZURE_STORAGE_ACCOUNT \
    --resource-group $azure_resource_identifier \
    --location $AZURE_DEFAULT_REGION \
    --sku $AZURE_STORAGE_SKU

  while true; do
    PROVISIONED=$(az storage account show \
      --name $AZURE_STORAGE_ACCOUNT \
      --resource-group $azure_resource_identifier \
      --query provisioningState \
      --output tsv)

    [ $PROVISIONED == 'Succeeded' ] && break
    echo 'waiting'
  done

  sleep 10 # sanity sleep
}

function storageAccountExists() {
  acct_name=$1
  # returns true/false
  [ "$(az storage account list | jq -r '.[].name')" == $acct_name ] && echo true || echo false
}

function createStorageContainer() {
  az storage container create --name $TF_STATE_BUCKET \
    --account-name $AZURE_STORAGE_ACCOUNT \
    --auth-mode key \
    --account-key "$(getStorageAccountKey)" \
    --public-access off \
    --query created
}

function storageContainerExists() {
  # returns true/false
  az storage container exists --name $TF_STATE_BUCKET \
    --account-name $AZURE_STORAGE_ACCOUNT \
    --auth-mode key \
    --account-key "$(getStorageAccountKey)" \
    --query exists
}

function destroyResourceGroup() {
  local group_name=$1

  if [ "$(resourceGroupExists $group_name)" == 'true' ]; then
    echo "Deleting Resource Group '$group_name'..."
    az group delete --name $group_name --yes
    az group wait --name $group_name --deleted
  else
    echo "Resource Group '$group_name' does not exist. Skipping."
  fi
}

function destroyStorageAccount() {
  local acct_name=$1
  local group_name=$2
  az storage account delete --name $acct_name \
    --resource-group $group_name \
    --yes
}
