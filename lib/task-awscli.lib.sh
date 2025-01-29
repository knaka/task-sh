#!/bin/sh
set -o nounset -o errexit

test "${guard_f4297b5+set}" = set && return 0; guard_f4297b5=x

. ./task.sh

subcmd_aws() {
  run_pkg_cmd \
    --cmd=aws \
    --brew-id=awscli \
    --winget-id=Amazon.AWSCLI \
    --winget-cmd-path=C:/"Program Files"/Amazon/AWSCLIV2/aws.exe \
    -- "$@"
}

task_aws__caller() {
  subcmd_aws sts get-caller-identity
}

task_aws__account() {
  subcmd_aws iam list-account-aliases
}
