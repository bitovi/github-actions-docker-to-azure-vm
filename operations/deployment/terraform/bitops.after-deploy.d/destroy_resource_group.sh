#!/bin/bash
# shellcheck disable=SC1091,SC2086

# TODO: support not destroying the resource group

set -e

source $BITOPS_TEMPDIR/_scripts/deploy/deploy_helpers.sh

account=$AZURE_STORAGE_ACCOUNT
group=$azure_resource_identifier
spacer='================='

if isDestroyMode; then
  echo
  echo $spacer
  echo "Running $(basename $0) to destroy the resource group $group"
  source "$BITOPS_TEMPDIR/deployment/_scripts/az_cli_helpers.sh"
  destroyResourceGroup $group

  echo "Just in case... checking status of storage account $account"
  if [ "$(storageAccountExists $account)" == "true" ]; then
    echo "Storage account $account exists. Destroying..."
    destroyStorageAccount $account $group
  else
    echo "Storage account $account does not exist."
  fi
  echo $spacer
else
  echo
  echo $spacer
  echo "Terraform Action is '${BITOPS_TERRAFORM_COMMAND:-$TERRAFORM_DESTROY}'. Skipping $(basename $0)."
  echo $spacer
  exit 0
fi
