# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e598d81-false}" && return 0; sourced_e598d81=true

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
