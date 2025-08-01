# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_71191d2-false}" && return 0; sourced_71191d2=true

# Terraform by HashiCorp https://www.terraform.io/

. ./task.sh

  # Terraform Versions | HashiCorp Releases https://releases.hashicorp.com/terraform/
terraform_version_0db0d51="1.9.8"

# Set the Terraform version
set_terraform_version() {
  terraform_version_0db0d51="$1"
}

terraform_path_ca65267=.

# Set the directory path which contains Terraform configuration files (default: ".")
set_terraform_path() {
  terraform_path_ca65267="$1"
}

terraform() {
  push_dir "$terraform_path_ca65267"
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="terraform" \
    --ver="$terraform_version_0db0d51" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext-map="Linux .zip Darwin .zip Windows .zip " \
    --url-template='https://releases.hashicorp.com/terraform/${ver}/terraform_${ver}_${os}_${arch}${ext}' \
    -- \
    "$@"
  pop_dir
}

subcmd_terraform() { # Run terraform(1) command
  terraform "$@"
}
