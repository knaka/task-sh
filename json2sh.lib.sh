# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a5dd01a-false}" && return 0; sourced_a5dd01a=true

. ./jq.lib.sh

# Convert JSON object to shell variable assignment expressions.
# Usage: json2sh [--prefix=PREFIX] [--local]
# Options:
#   --prefix=PREFIX  Set variable name prefix (default: "json__")
#   --local          Add "local" declaration to variables
# Example:
#   echo '{"foo":{"bar":"baz"}}' | json2sh --prefix="config__" --local
#   # Outputs: local config__foo__bar="baz"
json2sh() {
  local prefix="json__"
  local local_decl=""
  OPTIND=1; while getopts _-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (local) local_decl="local ";;
      (prefix) prefix=$OPTARG;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # shellcheck disable=SC2016
  jq -r --arg prefix "$prefix" --arg local_decl "$local_decl" '
    def to_sh(prefix):
      to_entries[] |
        (.key | gsub("[-\\.]"; "_")) as $shell_key |
        if (.value | type == "object") then
          .value | to_sh("\(prefix)\($shell_key)__")
        else
          "\($local_decl)\(prefix)\($shell_key)=\"\(.value)\""
        end
    ;
    to_sh($prefix)
  '
}

# Convert JSON object to shell variable assignment expressions.
subcmd_json2sh() {
  json2sh
}
