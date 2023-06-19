#!/bin/bash
# shellcheck disable=SC1091

# Export variables to GHA

source "$BITOPS_TEMPDIR/_scripts/deploy/deploy_helpers.sh"

BO_OUT="$GITHUB_ACTION_PATH/operations/bo-out.env"

echo "Check for $BO_OUT"
if [ -f $BO_OUT ]; then
  echo "Outputting bo-out.env to GITHUB_OUTPUT"
  cat $BO_OUT >> $GITHUB_OUTPUT
  if isDebugMode; then cat $GITHUB_OUTPUT; fi
else
  echo "BO_OUT is not a file"
fi
