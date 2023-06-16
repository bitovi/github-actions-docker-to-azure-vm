#!/usr/bin/env bats
load '../deploy_helpers.sh'

# this is bash so 0 = true, 1 = false

@test 'isDebugMode' {
  unset DEBUG_MODE
  run isDebugMode
  [ "$status" -eq 1 ]
  
  export DEBUG_MODE=''
  run isDebugMode
  [ "$status" -eq 1 ]

  export DEBUG_MODE='false'
  run isDebugMode
  [ "$status" -eq 1 ]
  
  export DEBUG_MODE='true'
  run isDebugMode
  [ "$status" -eq 0 ]
  
  export DEBUG_MODE='1'
  run isDebugMode
  [ "$status" -eq 0 ]
}

@test "isDestroyMode" {
  unset BITOPS_TERRAFORM_COMMAND
  unset TERRAFORM_DESTROY
  run isDestroyMode
  [ "$status" -eq 1 ]

  export BITOPS_TERRAFORM_COMMAND=''
  export TERRAFORM_DESTROY=''
  run isDestroyMode
  [ "$status" -eq 1 ]

  export BITOPS_TERRAFORM_COMMAND='destroy'
  export TERRAFORM_DESTROY=''
  run isDestroyMode
  [ "$status" -eq 0 ]

  export BITOPS_TERRAFORM_COMMAND=''
  export TERRAFORM_DESTROY='true'
  run isDestroyMode
  [ "$status" -eq 0 ]

  export BITOPS_TERRAFORM_COMMAND='destroy'
  export TERRAFORM_DESTROY='true'
  run isDestroyMode
  [ "$status" -eq 0 ]
}
