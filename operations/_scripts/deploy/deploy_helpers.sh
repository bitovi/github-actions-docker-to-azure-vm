#!/bin/bash

function isDebugMode() {
  if [[ -n $DEBUG_MODE && $DEBUG_MODE == 'true' ]]; then
    return 0
  else
    return 1
  fi
}
