# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a5dd01a-false}" && return 0; sourced_a5dd01a=true

. ./task.sh
. ./jq.lib.sh

json2sh() {
  # shellcheck disable=SC2016
  jq -r '
    def to_sh(prefix):
      to_entries[] |
        (.key | gsub("[-\\.]"; "_")) as $shell_key |
        if (.value | type == "object") then
          .value | to_sh("\(prefix)\($shell_key)__")
        else
          "\(prefix)\($shell_key)=\"\(.value)\""
        end
    ;
    to_sh("json__")
  '
}

# Convert JSON object to shell variable assignment expressions.
subcmd_json2sh() {
  json2sh
}
