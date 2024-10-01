#!/bin/sh
set -o nounset -o errexit

test "${guard_a24f1b4+set}" = set && return 0; guard_a24f1b4=x

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

  if ! $force && ! newer Cargo.toml build.rs src/ --than target/debug/rsmain
  then
    return 0
  fi
  subcmd_cargo build
)

subcmd_run() {
  "$SCRIPT_DIR"/target/debug/rsmain "$@"
}
