#!/bin/bash

function isDebugMode() {
  if [[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]] || [ $DEBUG_MODE -eq 1 ] ; then
    return 0
  else
    return 1
  fi
}

function isDestroyMode() {
  if [ "$BITOPS_TERRAFORM_COMMAND" == "destroy" ] || [ "$TERRAFORM_DESTROY" == "true" ]; then
    return 0
  else
    return 1
  fi
}
