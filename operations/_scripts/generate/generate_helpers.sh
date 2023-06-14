#!/bin/bash

# TODO: wrap the generate scripts in functions in here

# # convert 'a,b,c'
# # to '["a","b","c"]'
# comma_str_to_tf_array () {
#   local IFS=','
#   local str=$1

#   local out=""
#   local first_item_flag="1"
#   for item in $str; do
#     if [ -z $first_item_flag ]; then
#       out="${out},"
#     fi
#     first_item_flag=""

#     item="$(echo $item | xargs)"
#     out="${out}\"${item}\""
#   done
#   echo "[${out}]"
# }

# -------------------------------------------------- #
# Generator # 
# Function to generate the variable content based on the fact that it could be empty. 
# This way, we only pass terraform variables that are defined, hence not overwriting terraform defaults. 

function alpha_only() {
    echo "$1" | tr -cd '[:alpha:]' | tr '[:upper:]' '[:lower:]'
}

function generate_var () {
  if [[ -n "$2" ]];then
    if [[ $(alpha_only "$2") == "true" ]] || [[ $(alpha_only "$2") == "false" ]]; then
      echo "$1 = $(alpha_only $2)"
    else
      echo "$1 = \"$2\""
    fi
  fi
}
