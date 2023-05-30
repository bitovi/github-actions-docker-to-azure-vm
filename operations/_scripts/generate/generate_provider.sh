#!/bin/bash

set -e

# TODO: use templating
#    provide '.tf.tmpl' files in the 'operations/deployment' repo
#    and iterate over all of them to provide context with something like jinja
#    Example: https://github.com/mattrobenolt/jinja2-cli
#    jinja2 some_file.tmpl data.json --format=json

echo "In $(basename $0)"

# use a heredoc to avoid escaping quotes
# and write the file in one line
cat << PROVIDER_HCL > "$GITHUB_ACTION_PATH/operations/deployment/terraform/provider.tf"
terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "bitops-azure-test"
    storage_account_name = "bitops"
    container_name       = "bitopstfstate"
    key                  = "state"
  }
}

  provider "azurerm" {
    features {
      resource_group {
        prevent_deletion_if_contains_resources = false
    }
  }
}
PROVIDER_HCL
