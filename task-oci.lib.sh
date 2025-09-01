# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2583e35-false}" && return 0; sourced_2583e35=true

. ./task.sh
. ./task-python.lib.sh
. ./task-jq.lib.sh

# oci-cli · PyPI https://pypi.org/project/oci-cli/#history
oci_cli_version_9a020e5=3.63.2

set_oci_cli_version() {
  oci_cli_version_9a020e5="$1"
}

oci() {
  uv --quiet tool run --from "oci-cli==$oci_cli_version_9a020e5" oci "$@"
}

# oci · PyPI https://pypi.org/project/oci/#history
oci_version_6eea079=2.157.0

# Print the OCI client config as JSON considering OCI_PROFILE env var.
oci_config() {
  uv --quiet tool run --from "oci==$oci_version_6eea079" python3 -c 'import os, oci, json; print(json.dumps(oci.config.from_file(profile_name=os.environ.get("OCI_PROFILE", "DEFAULT")), indent=2))'
}

# Get a specific OCI config value.
oci_config_get() {
  memoize oci_config | jq -r ".\"$1\""
}

# Run OCI CLI command.
subcmd_oci() {
  oci "$@"
}

# Print OCI client config considering OCI_PROFILE env var.
task_oci__config() {
  memoize oci_config
}

# Get a specific OCI config value.
subcmd_oci__config__get() {
  oci_config_get "$1"
}
