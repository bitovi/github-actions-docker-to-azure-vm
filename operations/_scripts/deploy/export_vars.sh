#!/bin/bash
# shellcheck disable=SC1091,SC2086

# Export variables to GHA
# BitOps has finished at this point and we are out of scope of the deploy script
# We're back in action.yaml.
# So a lot of the variables are out of scope.
# Only the Github variables are available.

set -e

source "$GITHUB_ACTION_PATH/operations/_scripts/deploy/deploy_helpers.sh"

BO_OUT="$GITHUB_ACTION_PATH/operations/bo-out.env"

echo "Check for $BO_OUT"
if [ -f $BO_OUT ]; then
  echo "Outputting bo-out.env to GITHUB_OUTPUT"
  cat $BO_OUT >> $GITHUB_OUTPUT
  if isDebugMode; then cat $GITHUB_OUTPUT; fi
else
  echo "BO_OUT is not a file"
fi
