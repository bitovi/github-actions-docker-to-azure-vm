#!/bin/bash
# shellcheck disable=SC1091

# """
# What
#   This bash script uses Terraform to output the values of environment 
#   variables and store them in a file called bo-out.env. 
#   The script checks if Terraform is being used to destroy the environment, and if not, 
#   it runs Terraform output and removes the quotation marks from the output before storing 
#   it in the bo-out.env file.
# Why
#   The bo-out.env file is used by Ansible to populate variables passed on by Terraform
# """

# set -e
set -x

source "$BITOPS_TEMPDIR/_scripts/deploy/deploy_helpers.sh"
isDebugMode && set -x

BO_OUT_PATH=/opt/bitops_deployment/bo-out.env

if [ "$TERRAFORM_DESTROY" != "true" ]; then
    echo "In after hook - $(basename $0)"
    # The sed command removes spaces, double quotes, and spaces before/after brackets
    terraform output -json | jq -r 'to_entries[] | .key + "=" + (.value.value | tostring)' \
    | sed -e 's/ //g' -e 's/"//g' -e 's/\[\ */\[/g' -e 's/\ *\]/\]/g' > $BO_OUT_PATH

    isDebugMode && echo 'bo-out file:' && cat $BO_OUT_PATH
fi
