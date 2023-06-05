#!/bin/bash
# shellcheck disable=SC1091,SC2086

set -e

if { [ "${BITOPS_TERRAFORM_COMMAND}" != "destroy" ] && [ "${TERRAFORM_DESTROY}" != "true" ]; }; then
  echo
  echo '================='
  echo "Terraform Action is '${BITOPS_TERRAFORM_COMMAND:-$TERRAFORM_DESTROY}'. Skipping $(basename $0)."
  echo '================='
  exit 0
fi

echo
echo '================='
echo "Running $(basename $0) to destroy the resource group $azure_resource_identifier"
source "$BITOPS_TEMPDIR/deployment/_scripts/az_cli_helpers.sh"
destroyResourceGroup $azure_resource_identifier

echo "Just in case... checking status of storage account $AZURE_STORAGE_ACCOUNT"
storage_exists=$(storageAccountExists $AZURE_STORAGE_ACCOUNT)
if [ "$storage_exists" == "true" ]; then
  echo "Storage account $AZURE_STORAGE_ACCOUNT exists. Destroying..."
  destroyStorageAccount $AZURE_STORAGE_ACCOUNT $azure_resource_identifier
else
  echo "Storage account $AZURE_STORAGE_ACCOUNT does not exist."
fi
echo '================='
