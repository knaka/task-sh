#!/bin/sh
set -o nounset -o errexit

test "${guard_a24f1b4+set}" = set && return 0; guard_a24f1b4=x

. task.sh
. task-rs.lib.sh

subcmd_build() (
  chdir_script
  force=false
  while getopts f:-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      f|force) force=true;;
      \?) usage; exit 2;;
      *) echo "Unexpected option: $OPT" >&2; exit 2;;
    esac
  done
  shift $((OPTIND-1))

  if ! $force && ! newer Cargo.toml build.rs src/ --than target/debug/rsmain"$(exe_ext)"
  then
    return 0
  fi
  if ! subcmd_rustc --version | grep -q nightly
  then
    # compiler errors - Unable to compile Rust hello world on Windows: linker link.exe not found - Stack Overflow https://stackoverflow.com/questions/55603111/unable-to-compile-rust-hello-world-on-windows-linker-link-exe-not-found
    # subcmd_rustup toolchain install stable-x86_64-pc-windows-gnu
    # subcmd_rustup default stable-x86_64-pc-windows-gnu
    subcmd_rustup toolchain install nightly-x86_64-pc-windows-gnu
    subcmd_rustup default nightly-x86_64-pc-windows-gnu
  fi
  subcmd_cargo build
)

subcmd_run() {
  "$SCRIPT_DIR"/target/debug/rsmain "$@"
}

subcmd_cargo_in_original() { # Run cargo in the original working directory.
  chdir_original 
  subcmd_cargo "$@"
  chdir_script
}