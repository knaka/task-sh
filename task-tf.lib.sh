# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_71191d2-false}" && return 0; sourced_71191d2=true

. ./task.sh

  # Terraform Versions | HashiCorp Releases https://releases.hashicorp.com/terraform/
terraform_version_0db0d51="1.9.8"

set_terraform_version() {
  terraform_version_0db0d51="$1"
}

terraform() {
  local app_dir_path="$(cache_dir_path)"/terraform
  mkdir -p "$app_dir_path"
  local cmd_path="$app_dir_path"/terraform@"$terraform_version_0db0d51""$exe_ext"
  if ! command -v "$cmd_path" >/dev/null 2>&1
  then
    local os_arch="$(uname -s -m)"
    local os
    case "${os_arch% *}" in
      (Linux) os="linux" ;;
      (Darwin) os="darwin" ;;
      (Windows) os="windows" ;;
      (*) return 1 ;;
    esac
    local arch
    case "${os_arch#* }" in
      (x86_64) arch="amd64" ;;
      (aarch64) arch="arm64" ;;
      (*) return 1 ;;
    esac
    local url="https://releases.hashicorp.com/terraform/${terraform_version_0db0d51}/terraform_${terraform_version_0db0d51}_${os}_${arch}.zip"
    curl --fail --location "$url" --output "$TEMP_DIR"/terraform.zip
    push_dir "$app_dir_path"
    unzip -o "$TEMP_DIR"/terraform.zip
    mv terraform"$exe_ext" "$cmd_path"
    pop_dir
    chmod +x "$cmd_path"
  fi
  "$cmd_path" "$@"
}

subcmd_terraform() { # Run terraform command
  terraform "$@"
}
