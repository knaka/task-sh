#!/usr/bin/env sh
# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_723152a:+}" = true && return 0; sourced_723152a=true
set -o nounset -o errexit

set -- "$PWD" "$@"; test "${0%/*}" != "$0" && cd "${0%/*}"
. ./rand7.sh 
cd "$1"; shift

force=false
OPTIND=1; while getopts f-: OPT
do
  if test "$OPT" = "-"
  then
    OPT="${OPTARG%%=*}"
    # shellcheck disable=SC2030
    OPTARG="${OPTARG#"$OPT"}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    (f|force) force=true;;
    (\?) usage; exit 2;;
    (*) echo "Unexpected option: $OPT" >&2; exit 2;;
  esac
done
shift $((OPTIND-1))

if test -r "$1" && ! $force
then
  echo "File $1 already exists. Only touching it." >&2
  touch "$1"
  exit 0
fi

unique_id="$(rand7)"
if test "$1" = "-"
then
  cat
else
  cat >"$1"
fi <<EOF
#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "\${sourced_${unique_id}-}" = true && return 0; sourced_${unique_id}=true
set -o nounset -o errexit

set -- "\$PWD" "\${0%/*}" "\$@"; test "\$2" != "\$0" && cd "\$2"
cd "\$1"; shift 2

x${unique_id}() {
  :
}

case "\${0##*/}" in
  (x${unique_id}|x${unique_id}.sh)
    set -o nounset -o errexit
    x${unique_id} "\$@"
    ;;
esac
EOF

# set -o monitor # For job control
# set -o xtrace # For debugging
# set -o pipefail # For error handling in pipelines in Bash
