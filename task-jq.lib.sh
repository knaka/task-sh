# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f2524bb-false}" && return 0; sourced_f2524bb=true

# jqlang/jq: Command-line JSON processor https://github.com/jqlang/jq

. ./task.sh

require_cmd \
  --brew-id=jq \
  --winget-id=jqlang.jq \
  jq \
  "$LOCALAPPDATA"/Microsoft/WinGet/Links/jq.exe

jq_version_6d4ce66=1.8.1

set_jq_version() {
  jq_version_6d4ce66="$1"
}

jq_use_fetched=false

jq() {
  if "$jq_use_fetched"
  then
    # shellcheck disable=SC2016
    fetch_cmd_run \
      --name="jq" \
      --ver="$jq_version_6d4ce66" \
      --os-map="Linux linux Darwin macos Windows windows " \
      --arch-map="$goarch_map" \
      --url-template='https://github.com/jqlang/jq/releases/download/jq-$ver/jq-$os-$arch$exe_ext' \
      -- \
      "$@"
    return "$?"
  fi
  run_required_cmd jq "$@"
}

subcmd_jq() { # Run jq(1).
  jq "$@"
}
