#!/bin/sh
test "${guard_920f884+set}" = set && return 0; guard_920f884=-

. ./task.sh

subcmd_bun() { # Run bun(1).
  run_pkg_cmd \
    --cmd=bun \
    --brew-id=oven-sh/bun/bun \
    --winget-id=Oven-sh.Bun \
    --winget-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/bun.exe \
    -- "$@"
}

# bun_dir_path() {
#   # Releases · oven-sh/bun https://github.com/oven-sh/bun/releases
#   local cmd_base=bun
#   local ver=1.2

#   local bin_dir_path="$HOME"/.bin
#   local app_dir_path="$bin_dir_path/${cmd_base}@${ver}"
#   mkdir -p "$app_dir_path"
#   local app_cmd_path="$app_dir_path/$cmd_base$(exe_ext)"
#   if ! test -x "$app_cmd_path"
#   then
#     local os="unknown"
#     local arch="unknown"
#     case "$(uname -s)" in
#       Linux)
#         os="linux"
#         ;;
#       Darwin)
#         os="darwin"
#         ;;
#       Windows_NT)
#         os="windows"
#         ;;
#       *)
#         echo "Unsupported OS: $(uname -s)" >&2
#         exit 1
#         ;;
#     esac
#     url=https://github.com/volta-cli/volta/releases/download/v${ver}/volta-${ver}-${os_arch}${arc_ext}
#     temp_dir_path="$(mktemp -d)"
#     curl"$(exe_ext)" --fail --location "$url" -o "$temp_dir_path"/tmp"$arc_ext"
#     (cd "$app_dir_path"; tar"$(exe_ext)" -xf "$temp_dir_path"/tmp"$arc_ext")
#     chmod +x "$app_dir_path"/*
#     rm -fr "$temp_dir_path"
#   fi
#   echo "$app_dir_path"
# }

# set_volta_env() {
#   first_call 80498e1 || return 0
#   PATH="$(volta_dir_path):$PATH"
#   export PATH
# }

# set_node_env() {
#   first_call ae97cdf || return 0
#   set_volta_env
#   PATH="$(dirname "$(subcmd_volta which node)"):$PATH"
#   export PATH
# }

# subcmd_volta() { # Run Volta.
#   set_volta_env
#   volta"$(exe_ext)" "$@"
# }
