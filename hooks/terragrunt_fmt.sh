#!/usr/bin/env bash
set -eo pipefail

# shellcheck disable=SC2155 # No way to assign to readonly variable in separate lines
readonly SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
# shellcheck source=_common.sh
. "$SCRIPT_DIR/_common.sh"

#######################################################################
# Unique part of `common::per_dir_hook`. The function is executed in loop
# on each provided dir path. Run wrapped tool with specified arguments
# Arguments:
#   args (string with array) arguments that configure wrapped tool behavior
#   dir_path (string) PATH to dir relative to git repo root.
#     Can be used in error logging
# Outputs:
#   If failed - print out hook checks status
#######################################################################
function per_dir_hook_unique_part() {
  local -r args="$1"
  # shellcheck disable=SC2034 # Unused var.
  local -r dir_path="$2"

  # pass the arguments to hook
  # shellcheck disable=SC2068 # hook fails when quoting is used ("$arg[@]")
  terragrunt hclfmt ${args[@]}

  # return exit code to common::per_dir_hook
  local exit_code=$?
  return $exit_code
}

#######################################
# main function
# Globals:
#   ARGS
#   FILES
#   SCRIPT_DIR
# Arguments:
#  None
#######################################
function main() {
  common::initialize "$SCRIPT_DIR"
  common::parse_cmdline "$@"
  # shellcheck disable=SC2153 # False positive
  common::per_dir_hook "${ARGS[*]}" "${FILES[@]}"
}

[ "${BASH_SOURCE[0]}" != "$0" ] || main "$@"
