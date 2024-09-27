#!/bin/sh
set -o nounset -o errexit

# bash - Using getopts to process long and short command line options - Stack Overflow https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options

needs_arg() {
  if test -z "$OPTARG"
  then
    echo "No argument for --$OPT option" >&2
    usage
    exit 2
  fi
}

alpha=false
bravo="$HOME/Downloads"
charlie=
charlie_default="brown"

usage() {
  cat <<'EOF' >&2
Usage: $0 [options] <subcommand>

Options:
  -a, --alpha            Alpha (boolean).
  -b, --bravo <arg>      Bravo. Default is "$HOME/Downloads".
  -c, --charlie [<arg>]  Specify charlie. If argumet is omitted, default is "brown".
  -h, --help             Display this help and exit.

Subcommands:
  ...
EOF
}

while getopts h-:ab:c OPT
do
  if test "$OPT" = "-"
  then
    OPT="${OPTARG%%=*}"
    OPTARG="${OPTARG#"$OPT"}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    a | alpha) alpha=true ;;
    b | bravo) needs_arg; bravo="$OPTARG" ;;
    c | charlie) charlie="${OPTARG:-$charlie_default}" ;;
    h | help) usage; exit 0;;
    \?) usage; exit 2 ;;
    *) echo "Unexpected option: $OPT" >&2; usage; exit 2 ;;
  esac
done
shift $((OPTIND-1))

echo "119409b | alpha: $alpha, bravo: $bravo, charlie: $charlie | $*"
