# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8155a51-false}" && return 0; sourced_8155a51=true

# The Rust Release Announcements https://blog.rust-lang.org/releases/
version_5270c6c=1.89.0

. ./task.sh

require_pkg_cmd \
  --brew-id=rustup \
  --winget-id=Rustlang.Rustup \
  rustup

rustup() {
  run_pkg_cmd rustup "$@"
}

# Rust toolchain installer
subcmd_rustup() {
  rustup "$@"
}

setup_5e1fdfc() {
  first_call 312dd04 || return 0
  if ! test -r "$PROJECT_DIR"/rust-toolchain.toml
  then
    : "${RUSTUP_TOOLCHAIN:="$version_5270c6c"}"
    export RUSTUP_TOOLCHAIN
  fi
  # When listing, the toolchain version specified in `rust-toolchain.toml` is installed automatically and the activity is output to stderr while the toolchain list is printed to stdout.
  rustup toolchain list >/dev/null
  local cargo_path="$(rustup which cargo)"
  export PATH="${cargo_path%/*}:$PATH"
}

cargo() {
  setup_5e1fdfc
  # Pipe to cat(1) because not all color is disabled with `--color=never`.
  command cargo --color=never "$@" | cat
}

# Rust's package manager
subcmd_cargo() {
  cargo "$@"
}
