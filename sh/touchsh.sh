#!/bin/sh
set -o nounset -o errexit

test "${guard_723152a+set}" = set && return 0; guard_723152a=-

force=false
while getopts f-: OPT
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

if test -r "$1" && ! $force
then
  echo "File $1 already exists. Only touching it." >&2
  touch "$1"
  exit 0
fi

unique_id="$(sh "$(dirname "$0")"/rand7.sh)"
cat <<EOF > "$1"
#!/bin/sh
set -o nounset -o errexit

test "\${guard_${unique_id}+set}" = set && return 0; guard_${unique_id}=x
EOF
