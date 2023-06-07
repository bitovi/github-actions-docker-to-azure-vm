#!/bin/bash
# shellcheck disable=SC1091,SC2086

# TODO: support not destroying the resource group

set -e

account=$AZURE_STORAGE_ACCOUNT
spacer='================='

if { [ "${BITOPS_TERRAFORM_COMMAND}" != "destroy" ] && [ "${TERRAFORM_DESTROY}" != "true" ]; }; then
  echo
  echo $spacer
  echo "Terraform Action is '${BITOPS_TERRAFORM_COMMAND:-$TERRAFORM_DESTROY}'. Skipping $(basename $0)."
  echo $spacer
  exit 0
else
  echo
  echo $spacer
  echo "Running $(basename $0) to destroy the resource group $azure_resource_identifier"
  source "$BITOPS_TEMPDIR/deployment/_scripts/az_cli_helpers.sh"
  destroyResourceGroup $azure_resource_identifier

  echo "Just in case... checking status of storage account $account"
  if [ "$(storageAccountExists $account)" == "true" ]; then
    echo "Storage account $account exists. Destroying..."
    destroyStorageAccount $account $azure_resource_identifier
  else
    echo "Storage account $account does not exist."
  fi
  echo $spacer
fi
