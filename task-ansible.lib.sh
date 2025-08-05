# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_090d237-false}" && return 0; sourced_090d237=true

. ./task-python.lib.sh

# ansible · PyPI https://pypi.org/project/ansible/#history
ansible_version_6e3d355=11.8.0

set_ansible_version() {
  ansible_version_6e3d355="$1"
}

ansible() {
  # While the `ansible` package is the main package and `ansible-core` is a dependency, uvx(1) calls the `ansible` command from the `ansible-core` package, so we specify `ansible-core` with `--from` and the `ansible` package with `--with`.
  uvx --quiet --from "ansible-core" --with "ansible==$ansible_version_6e3d355" ansible "$@"
}

subcmd_ansible() { # Run Ansible command.
  ansible "$@"
}

ansible_playbook() {
  uvx --quiet --from "ansible-core" --with "ansible==$ansible_version_6e3d355" ansible-playbook "$@"
}

alias ansible-playbook=ansible_playbook

subcmd_ansible_playbook() { # Run Ansible playbook command.
  ansible_playbook "$@"
}

alias subcmd_ansible-playbook=subcmd_ansible_playbook
