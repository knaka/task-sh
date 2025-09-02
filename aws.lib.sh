#!/bin/sh
set -o nounset -o errexit

test "${guard_f4297b5+set}" = set && return 0; guard_f4297b5=x

. ./task.sh

aws() {
  run_pkg_cmd \
    --cmd=aws \
    --brew-id=awscli \
    --winget-id=Amazon.AWSCLI \
    --win-cmd-path=C:/"Program Files"/Amazon/AWSCLIV2/aws.exe \
    -- "$@"
}

subcmd_aws() {
  aws "$@"
}

task_aws__caller() {
  aws sts get-caller-identity
}

task_aws__account() {
  aws iam list-account-aliases
}

aws_config_get() {
  aws configure get "$@"
}
