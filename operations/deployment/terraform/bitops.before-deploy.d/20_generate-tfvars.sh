#!/bin/bash

set -e

if [ -z "${azure_resource_identifier}" ]; then
  echo "Missing required env var: azure_resource_identifier" && exit 1
else
  echo "
  azure_resource_identifier = \"${azure_resource_identifier}\"
  " > "${BITOPS_OPSREPO_ENVIRONMENT_DIR}/azure-resource_identifier.auto.tfvars"
fi
