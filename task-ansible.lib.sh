# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_090d237-false}" && return 0; sourced_090d237=true

. ./task-python.lib.sh

# ansible-core · PyPI https://pypi.org/project/ansible-core/#history
ansible_version_c431280=2.19.0

set_ansibler_version() {
  ansible_version_c431280="$1"
}

ansible() {
  # Using tools | uv https://docs.astral.sh/uv/guides/tools/
  uv --quiet tool run --from "ansible-core==$ansible_version_c431280" ansible "$@"
}

subcmd_ansible() { # Run Ansible command.
  ansible "$@"
}
