#!/bin/bash

set -e

[[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]] && set -x

# TODO: elevate this to a shared function
# avoid running this script if the Terraform CLI Action is `destroy`
terraform_cmd=$(cat $BITOPS_ENVROOT/terraform/bitops.config.yaml | shyaml get-value terraform.cli.stack-action)
if [ $terraform_cmd == "destroy"  ]; then
  echo '=================' && echo "Terraform Action is 'destroy'. Skipping $(basename $0)." && echo '================='
  exit 0
else 
  echo '=================' && echo "Running $(basename $0)..."
fi

echo "BitOps Ansible before script: Merge Terraform Environment Variables..."

# Merging order
order=tf,postgres,repo,ghv,ghs,aws

# Ansible dotenv file -> The final destination of all
DOTENV_FILE="${BITOPS_ENVROOT}/ansible/app.env"

# TF dotenv file
TF_DOTENV_FILE="${BITOPS_ENVROOT}/terraform/tf.env"

# TF dotenv file
POSTGRES_DOTENV_FILE="${BITOPS_ENVROOT}/terraform/postgres.env"

# Repo env file
REPO_ENV_FILE="${BITOPS_ENVROOT}/ansible/repo.env"

# GH Variables env file
GHV_ENV_FILE="${BITOPS_ENVROOT}/ansible/ghv.env"

# GH Secrets  env file
GHS_ENV_FILE="${BITOPS_ENVROOT}/ansible/ghs.env"

# TF AWS dotenv file
AWS_SECRET_FILE="${BITOPS_ENVROOT}/terraform/aws.env"

# Make sure app.env is empty, if not, delete it and create one.
if [ -f $DOTENV_FILE ]; then 
  rm -rf $DOTENV_FILE
fi 
touch $DOTENV_FILE

# Function to merge to destination
function merge {
  if [ -s $1 ]; then
    echo "Merging $2 envs"
    cat $1 >> $DOTENV_FILE
  else
    echo "Nothing to merge from $2"
  fi
}

# Function to be called based on the input string
function process {
  case $1 in
    aws)
      # Code to be executed for option1
      merge $AWS_SECRET_FILE "AWS Secret"
      ;;
    repo)
      # Code to be executed for option2
      merge $REPO_ENV_FILE "checked-in"
      ;;
    ghv)
      # Code to be executed for option3
      merge $GHV_ENV_FILE "GH-Vars"
      ;;
    ghs)
      # Code to be executed for option4
      merge $GHS_ENV_FILE "GH-Secret"
      ;;
    tf)
      # Code to be executed for option5
      merge $TF_DOTENV_FILE "Terraform"
      ;;
    postgres)
      # Code to be executed for option6
      merge $POSTGRES_DOTENV_FILE "Postgres"
      ;;
    *)
      # Code to be executed if no matching option is found
      echo "Invalid option"
      ;;
  esac
}

# Read the input string and split it into an array
IFS=',' read -r -a options <<< "$order"

# Loop through the array and call the process function for each element
for option in "${options[@]}"; do
  process "$option"
done

# print the generated inventory file
if [[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]]; then 
  tf_inv_file="$BITOPS_ENVROOT/terraform/inventory.yaml"
  echo "Printing the generated inventory file: $tf_inv_file"
  cat $tf_inv_file
fi
