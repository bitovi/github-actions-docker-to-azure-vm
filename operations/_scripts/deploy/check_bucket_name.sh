#!/bin/bash 

set -e 

### S3 Buckets name must follow AWS rules. Info below.
### https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html

### Azure rules:
# the storage account name must be between 3 and 24 characters long, and can contain only lowercase letters and numbers
# https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview
####
# A container name must be a valid DNS name, conforming to the following naming rules:
# Container names must start or end with a letter or number, and can contain only letters, numbers, and the dash (-) character.
# Every dash (-) character must be immediately preceded and followed by a letter or number; consecutive dashes are not permitted in container names.
# All letters in a container name must be lowercase.
# Container names must be from 3 through 63 characters long.

function checkBucket() {
  # check length of bucket name
  if [[ ${#1} -lt 3 || ${#1} -gt 63 ]]; then
    echo "::error::Bucket name must be between 3 and 63 characters long."
    exit 1
  fi
  
  # check that bucket name consists only of lowercase letters, numbers, dots (.), and hyphens (-)
  if [[ ! $1 =~ ^[a-z0-9.-]+$ ]]; then
    echo "::error::Bucket name can only consist of lowercase letters, numbers, dots (.), and hyphens (-)."
    exit 1
  fi
  
  # check that bucket name begins and ends with a letter or number
  if [[ ! $1 =~ ^[a-zA-Z0-9] ]]; then
    echo "::error::Bucket name must begin with a letter or number."
    exit 1
  fi
  if [[ ! $1 =~ [a-zA-Z0-9]$ ]]; then
    echo "::error::Bucket name must end with a letter or number."
    exit 1
  fi
  
  # check that bucket name does not contain two adjacent periods
  if [[ $1 =~ \.\. ]]; then
    echo "::error::Bucket name cannot contain two adjacent periods."
    exit 1
  fi
  
  # check that bucket name is not formatted as an IP address
  if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "::error::Bucket name cannot be formatted as an IP address."
    exit 1
  fi
  
  # check that bucket name does not start with the prefix xn--
  if [[ $1 =~ ^xn-- ]]; then
    echo "::error::Bucket name cannot start with the prefix xn--."
    exit 1
  fi
  
  # check that bucket name does not end with the suffix -s3alias
  if [[ $1 =~ -s3alias$ ]]; then
    echo "::error::Bucket name cannot end with the suffix -s3alias."
    exit 1
  fi
}

function checkAzStorageName() {
  local name=$1
  local len
  local success

  success='false'
  len=${#name}

  if [[ $len -lt 3 || $len -gt 24 ]]; then
    echo "::error::Storage Account Name must be between 3 and 24 characters long."
  elif [[ ! $name =~ ^[a-z0-9]+$ ]]; then
    echo "::error::Storage Account Name can only consist of lowercase letters and numbers."
  else
    success='true'
  fi

  [ $success == 'true' ] || exit 1
}

function checkAzContainerName() {
  local name=$1
  local len
  local success
  
  success='false'
  len=${#name}
  
  if [[ $len -lt 3 || $len -gt 63 ]]; then
    echo "::error::Container Name must be between 3 and 63 characters long."
  elif [[ $name =~ [^a-z0-9-] ]]; then   
    echo "::error::Container Name can contain only lowercase letters, numbers, and the dash (-) character."
  elif [[ ! $name =~ ^[a-z0-9].*[a-z0-9]$ ]]; then
    echo "::error::Container Name must start and end with a letter or number."
  elif [[ $name =~ -- || ! $name =~ ^[[:alnum:]-]+$ ]]; then
    echo "::error::Invalid container name. Every dash (-) character must be immediately preceded and followed by a letter or number; consecutive dashes are not permitted."
  else
    success='true'
  fi

  [ $success == 'true' ] || exit 1
}

# check for azure, else AWS
# in the future, add additional cases here for other cloud providers
function checkStorageName() {
  case $2 in
    "azure")
      checkAzStorageName $1
      ;;

    *)
      checkBucket $1
      ;;
  esac
}

function checkContainerName() {
  case $2 in
    "azure")
      checkAzContainerName $1
      ;;

    *)
      echo '::error::something bad happened: invalid cloud provider in checkContainerName'
      exit 1
      ;;
  esac
}
