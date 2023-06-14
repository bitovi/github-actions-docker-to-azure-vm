#!/bin/bash

set -e

echo "In $(basename $0)"

[[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]] && set -x

ENV_FILE_PATH="${GITHUB_ACTION_PATH}/operations/deployment/ansible"

echo "$GHV_ENV" > "$ENV_FILE_PATH/ghv.env"
echo "$GHS_ENV" > "$ENV_FILE_PATH/ghs.env"
