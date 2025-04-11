# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2583e35-false}" && return 0; sourced_2583e35=true

. ./task.sh
. ./task-uv.lib.sh

ensure_oci_installed() {
  if ! test -d .venv/
  then
    uv venv
  fi
  if ! uv run python3 -c 'import sys, importlib.util; sys.exit(0 if importlib.util.find_spec("oci") else 1)'
  then
    echo "OCI CLI not found. Installing..." >&2
    uv pip install oci-cli
  fi
}

oci() {
  ensure_oci_installed
  uv run oci "$@"
}

oci_config() {
  ensure_oci_installed
  uv run python3 -c 'import os, oci, json; print(json.dumps(oci.config.from_file(profile_name=os.environ.get("OCI_PROFILE", "DEFAULT")), indent=2))'
}

subcmd_oci() { # Run OCI CLI command.
  oci "$@"
}

subcmd_oci__config() { # Print OCI client config considering OCI_PROFILE env var.
  oci_config
}
