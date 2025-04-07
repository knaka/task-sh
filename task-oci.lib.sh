# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2583e35-false}" && return 0; sourced_2583e35=true

. ./task.sh

register_cmd oci \
  --brew-id=oci-cli \
  --fallback="Refer to the following page for installation instructions. // Quickstart https://docs.oracle.com/iaas/Content/API/SDKDocs/cliinstall.htm"

oci() {
  run_cmd oci "$@"
}

subcmd_oci() { # Run OCI CLI command.
  oci "$@"
}
