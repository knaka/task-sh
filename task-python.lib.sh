# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ae30849-false}" && return 0; sourced_ae30849=true

# astral-sh/uv: An extremely fast Python package and project manager, written in Rust. https://github.com/astral-sh/uv

. ./task.sh

# Releases · astral-sh/uv https://github.com/astral-sh/uv/releases
uv_version_3c621e6=0.8.4

set_uv_version() {
  uv_version_3c621e6="$1"
}

uv_run_cmd() {
  local cmd="$1"
  shift 
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="uv" \
    --ver="$uv_version_3c621e6" \
    --cmd="$cmd" \
    --os-map="Linux unknown-linux-gnu Darwin apple-darwin Windows pc-windows-msvc " \
    --arch-map="x86_64 x86_64 aarch64 aarch64 " \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/astral-sh/uv/releases/download/$ver/uv-$arch-$os$ext' \
    --rel-dir-template='uv-$arch-$os' \
    -- \
    "$@"
}

uv() {
  uv_run_cmd "uv" "$@"
}

subcmd_uv() { # Run uv(1)
  uv "$@"
}

uvx() {
  uv_run_cmd "uvx" "$@"
}

subcmd_uvx() { # Run uvx(1)
  uvx "$@"
}

python3() {
  uv run python3 "$@"
}

subcmd_python3() { # Run python3 in a UV environment
  python3 "$@"
}
