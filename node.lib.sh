# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e6646fd-false}" && return 0; sourced_e6646fd=true

. ./task.sh

# Releases · volta-cli/volta https://github.com/volta-cli/volta/releases
volta_version_c919009=2.0.2

set_volta_version() {
  volta_version_c919009="$1"
}

volta_dir_path() {
  local saved_ifs="$IFS"; IFS=","
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="volta" \
    --ver="$volta_version_c919009" \
    --os-map="Linux,linux,Darwin,macos,Windows,windows," \
    --arch-map="x86_64,,aarch64,-arm," \
    --ext-map="Linux,.tar.gz,Darwin,.tar.gz,Windows,.zip," \
    --url-template='https://github.com/volta-cli/volta/releases/download/v${ver}/volta-${ver}-${os}${arch}${ext}' \
    --print-dir
  IFS="$saved_ifs"
}

set_volta_env() {
  first_call 80498e1 || return 0
  PATH="$(volta_dir_path):$PATH"
  export PATH
}

volta() {
  set_volta_env
  invoke volta "$@"
}

# Run Volta.
subcmd_volta() {
  volta "$@"
}

set_node_env() {
  first_call ae97cdf || return 0
  set_volta_env
  PATH="$(dirname "$(volta which node)"):$PATH"
  export PATH
}

# ----------------------------------------------------------------------------

export PATH="$PROJECT_DIR/node_modules/.bin:$PATH"

# Run npm.
subcmd_npm() {
  set_node_env
  invoke npm "$@"
}

# Run npx.
subcmd_npx() {
  set_node_env
  invoke npx "$@"
}

node() {
  set_node_env
  invoke node "$@"
}

# Run Node.js.
subcmd_node() {
  node "$@"
}

last_check_path="$PROJECT_DIR"/node_modules/.npm_last_check

npm_depinstall() {
  push_dir "$PROJECT_DIR" || exit 1
  ! test -f "$PROJECT_DIR"/package.json && return 1
  while true
  do
    test "$#" -gt 0 && break
    first_call ac87fe4 || return 0
    ! test -d "$PROJECT_DIR"/node_modules/ && break
    ! test -f "$PROJECT_DIR"/package-lock.json && break
    ! test -f "$last_check_path" && break
    newer "$PROJECT_DIR"/package.json --than "$last_check_path" && break
    newer "$PROJECT_DIR"/package-lock.json --than "$last_check_path" && break
    pop_dir || exit 1
    return 0
  done
  subcmd_npm install "$@"
  touch "$last_check_path"
  pop_dir || exit 1
}

# Install the npm packages if the package.json is modified.
subcmd_npm__install() {
  npm_depinstall "$@"
}

# Run the bin file in the node_modules/.bin.
run_node_modules_cmd() {
  npm_depinstall
  "$@"
}

# Run the bin file in the node_modules.
run_node_modules_bin() {
  local pkg="$1"
  shift
  local bin_path="$1"
  shift
  subcmd_npm__install
  local p="$PROJECT_DIR"/node_modules/"$pkg"/"$bin_path"
  if test -f "$p" && head -1 "$p" | grep -q '^#!.*node'
  then
    subcmd_node "$p" "$@"
    return $?
  fi
  if is_windows
  then
    for ext in .exe .cmd .bat
    do
      if test -f "$p$ext"
      then
        p="$p$ext"
        break
      fi
    done
  fi
  invoke "$p" "$@"
}

# Install the npm packages for development.
subcmd_npm__dev__install() {
  subcmd_npm install --save-dev "$@"
  touch "$last_check_path"
}

# Ensure the npm packages are installed.
subcmd_npm__ensure() {
  local package
  for package in "$@"
  do
    if ! subcmd_node -e "require.resolve('${package}')" >/dev/null 2>&1
    then
      subcmd_npm install --save-dev "${package}"
    fi
  done
  touch "$last_check_path"
}

set_local_node_env() {
  first_call 76e8009 || return 0
  push_dir "$PROJECT_DIR" || exit 1
  local node_cmd_path="$(volta which node)"
  local node_bin_dir_path="${node_cmd_path%/*}"
  export PATH="$node_bin_dir_path:$PROJECT_DIR/node_modules/.bin:$PATH"
  npm_depinstall
  pop_dir || exit 1
}

print_sub_help_0f6c9a3() {
  cat <<EOF
Subcommand "npm":
  Usage:
    ${ARG0BASE} npm <lifecycle_command> [-- <args>]
    ${ARG0BASE} npm run <custom_command> [-- <args>]

  Commands:
EOF
  IFS=
  npm run | sed "s/^/    /"
}

# Add sub-help for "npm" sub-command
add_sub_help_for_npm() {
  add_sub_help print_sub_help_0f6c9a3
}

node_version_default_23ecb49=24

run_npm_pkg() {
  # Releases · nodejs/node https://github.com/nodejs/node/releases
  local node_version="$node_version_default_23ecb49"
  OPTIND=1; while getopts hvsi-: OPT
  do
    if test "$OPT" = "-"
    then
      # Extract long option name.
      # shellcheck disable=SC2031
      OPT="${OPTARG%%=*}"
      # Extract long option argument.
      # shellcheck disable=SC2031
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (node-version) node_version="$OPTARG";;
      (\?) tasksh_help; exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  test -z "$node_version" && node_version="$node_version_default_23ecb49"
  local package_spec="$1"
  shift
  test "$#" -ge 1 && test "$1" = "--" && shift

  volta run --quiet --node="$node_version" npm --progress=false exec --yes --prefer-offline "$package_spec" -- "$@"
}

# [package_spec [--] [cmd_opt...]] Run NPM package
subcmd_npm__pkg__run() {
  run_npm_pkg "$@"
}
