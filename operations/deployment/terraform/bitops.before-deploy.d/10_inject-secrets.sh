#!/bin/bash

set -e

if [ -z "${azure_vm_admin_username}" ]; then
  echo "Missing required env var: azure_vm_admin_username"
  exit 1
fi
if [ -z "${azure_vm_admin_password}" ]; then
  echo "Missing required env var: azure_vm_admin_password"
  exit 1
fi

echo "
azure_vm_admin_username = \"${azure_vm_admin_username}\"
azure_vm_admin_password = \"${azure_vm_admin_password}\"
" > "${BITOPS_OPSREPO_ENVIRONMENT_DIR}/azure-vm-admin-credentials.auto.tfvars"

# echo "ls BITOPS_OPSREPO_ENVIRONMENT_DIR ($BITOPS_OPSREPO_ENVIRONMENT_DIR)"
# ls $BITOPS_OPSREPO_ENVIRONMENT_DIR
