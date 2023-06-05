#!/bin/bash

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

set -e
#set -x

echo "In after hook - $(basename $0)"

if [ "$TERRAFORM_DESTROY" != "true" ]; then
    # The sed command removes spaces, double quotes, and spaces before/after brackets
    terraform output -json | jq -r 'to_entries[] | .key + "=" + (.value.value | tostring)' | \
        sed -e 's/ //g' -e 's/"//g' -e 's/\[\ */\[/g' -e 's/\ *\]/\]/g' \
        > /opt/bitops_deployment/bo-out.env

    [ $DEBUG_MODE == 'true' ] && echo 'bo-out file:' && cat /opt/bitops_deployment/bo-out.env
fi
