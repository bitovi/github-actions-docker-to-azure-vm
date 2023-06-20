#!/bin/bash

set -e

echo "In $(basename $0)"
[[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]] && set -x

GITHUB_REPO_NAME=$(echo "$GITHUB_REPOSITORY" | sed 's/^.*\///')

ANSIBLE_DEPLOYMENT_PATH="$GITHUB_ACTION_PATH/operations/deployment/ansible/app/$GITHUB_REPO_NAME"

echo "Copying files from GITHUB_WORKSPACE:  '$GITHUB_WORKSPACE'"
echo "to ops repo's Ansible deployment dir: '$ANSIBLE_DEPLOYMENT_PATH'"
mkdir -p "$ANSIBLE_DEPLOYMENT_PATH"

TARGET_PATH="$GITHUB_WORKSPACE"
if [ -n "$APP_DIRECTORY" ]; then
  echo "APP_DIRECTORY: $APP_DIRECTORY"
  TARGET_PATH="$TARGET_PATH/$APP_DIRECTORY"
fi

if [ -f "$TARGET_PATH/.gha-ignore" ]; then
  rsync -a --exclude-from="$TARGET_PATH/.gha-gnore" "$TARGET_PATH/" "$ANSIBLE_DEPLOYMENT_PATH/"
else
  rsync -a "$TARGET_PATH/" "$ANSIBLE_DEPLOYMENT_PATH/"
fi

# # check if the dir exists and has a size greater than zero.
# if [ -s "$TARGET_PATH/$REPO_ENV" ]; then
#   echo "Copying checked in env file from repo to Ansible deployment path"
#   cp "$TARGET_PATH/$REPO_ENV" "$GITHUB_ACTION_PATH/operations/deployment/ansible/repo.env"
# else
#   echo "Checked in env file from repo is empty or couldn't be found"
# fi
