#!/bin/bash
# shellcheck disable=SC1091,SC2086

set -e

source "$BITOPS_TEMPDIR/deployment/_scripts/az_cli_helpers.sh"

echo '=================' && echo "Running $(basename $0)..."
echo "Logging in to Azure..."
azLogin
