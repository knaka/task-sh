#!/bin/sh
test "${guard_a710579+set}" = set && return 0; guard_a710579=x
set -o nounset -o errexit

. ./task.sh

# proto - A multi-language version manager | moonrepo https://moonrepo.dev/proto

echo_proto_arc_filename() (
  IFS=:

  architectures=
  architectures="${architectures}x86_64:x86_64:"
  architectures="${architectures}arm64:aarch64:"

  oses=
  oses="${oses}Linux:unknown-linux-gnu:"
  oses="${oses}Darwin:apple-darwin:"
  oses="${oses}Windows_NT:pc-windows-msvc:"

  arc_exts=
  arc_exts="${arc_exts}Linux:.tar.xz:"
  arc_exts="${arc_exts}Darwin:.tar.xz:"
  arc_exts="${arc_exts}Windows_NT:.zip:"

  architecture="$(ifsv_get "$architectures" "$1")" || return 1
  os="$(ifsv_get "$oses" "$2")" || return 1
  arc_ext="$(ifsv_get "$arc_exts" "$2")" || return 1

  echo "proto_cli-${architecture}-${os}${arc_ext}"
)

proto_dir_path() {
  # Releases · moonrepo/proto https://github.com/moonrepo/proto/releases
  local app_name=proto
  local app_ver=0.45.1

  local bin_dir_path="$HOME"/.bin
  local app_dir_path="$bin_dir_path/${app_name}@${app_ver}"
  mkdir -p "$app_dir_path"
  app_cmd_path="$app_dir_path/$app_name$(exe_ext)"
  if ! test -x "$app_cmd_path"
  then
    local arc_filename
    arc_filename="$(echo_proto_arc_filename "$(uname -m)" "$(uname -s)")" || reutrn 1
    url=https://github.com/moonrepo/proto/releases/download/v${app_ver}/${arc_filename}
    cross_run curl --fail --location "$url" -o "$(temp_dir_path)"/"$arc_filename"
    local work_dir_path
    work_dir_path="$(temp_dir_path)"/6d763aa
    rm -fr "$work_dir_path"
    mkdir -p "$work_dir_path"
    (
      cd "$work_dir_path"
      cross_run tar -xf "$(temp_dir_path)"/"$arc_filename"
    )
    mv "$work_dir_path"/*/* "$app_dir_path"
    chmod +x "$app_dir_path"/*
  fi
  echo "$app_dir_path"
}

set_proto_env() {
  first_call 0c5cc32 || return 0
  PATH="$(proto_dir_path):$PATH"
  export PATH
}

subcmd_proto() {
  set_proto_env
  proto "$@"
}
