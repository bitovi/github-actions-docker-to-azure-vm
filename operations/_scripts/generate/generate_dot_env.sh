#!/bin/bash

set -e

echo "In $(basename $0)"

ghv_path="${GITHUB_ACTION_PATH}/operations/deployment/ansible/ghv.env"
ghs_path="${GITHUB_ACTION_PATH}/operations/deployment/ansible/ghs.env"

touch $ghv_path && cat "$GHV_ENV" > $ghv_path
touch $ghs_path && cat "$GHS_ENV" > $ghs_path
