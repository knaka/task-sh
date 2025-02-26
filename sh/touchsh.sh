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
func_name=
base_name=
if test "$1" = "-"
then
  base_name="x${unique_id}.sh"
else
  base_name="${1##*/}"
fi
base_name_wo_sh="${base_name%.sh}"
func_name="$(echo "$base_name_wo_sh" | tr '-' '_')"
pattern="$base_name"
if test "$base_name" != "$base_name_wo_sh"
then
  pattern="$pattern|$base_name_wo_sh"
fi

# echo 75ca5dc: "${base_name%.lib.sh}" >&2
# $(test "${base_name%.lib.sh}" = "${base_name}" && printf '#!/usr/bin/env sh\n')

if test "$1" = "-"
then
  exec 3>&1
else
  exec 3>"$1"
fi

is_lib_sh=false
if test "${base_name%.lib.sh}" != "${base_name}"
then
  is_lib_sh=true
fi

if ! "$is_lib_sh"
then
  echo '#!/usr/bin/env sh' >&3
fi

cat >&3 <<EOF
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"\${sourced_${unique_id}-false}" && return 0; sourced_${unique_id}=true

set -- "\$PWD" "\${0%/*}" "\$@"; if test "\$2" != "\$0"; then cd "\$2" 2>/dev/null || :; fi
cd "\$1"; shift 2
EOF

if ! "$is_lib_sh"
then
  cat >&3 <<EOF

${func_name}() {
  :
}

case "\${0##*/}" in
  (${pattern})
    set -o nounset -o errexit
    ${func_name} "\$@"
    ;;
esac
EOF
fi

# Other options:
#   set -o monitor # For job control
#   set -o xtrace # For debugging
#   set -o pipefail # For error handling in pipelines in Bash
