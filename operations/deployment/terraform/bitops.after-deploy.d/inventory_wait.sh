#!/bin/bash
# shellcheck disable=SC2086,1091

# check the generated inventory.yaml for the vm ips
# if it is 'None', then start a loop to wait for the vm to be provisioned

# TODO: add a timeout

source "$BITOPS_TEMPDIR/_scripts/deploy/deploy_helpers.sh"

if isDestroyMode; then
  echo "Destroy mode. Skipping inventory wait."
else
  inventory_yaml=$BITOPS_TEMPDIR/deployment/terraform/inventory.yaml

  yaml_vm_ip=$(cat $inventory_yaml | shyaml get-value bitops_servers.hosts)

  if [ $yaml_vm_ip == 'None' ] || [ -z $yaml_vm_ip ]; then
    echo "IP address not provisioned yet. Waiting..."

    while true; do
      terraform refresh -target azurerm_public_ip.test > /dev/null
      PROVISIONED=$(terraform output -raw vm_url)
      [[ -n $PROVISIONED ]] && break
      echo "Waiting for IP to be provisioned..."
    done

    echo "updating inventory file..."
    terraform apply -auto-approve -target=local_file.ansible_inventory > /dev/null
  fi
fi
