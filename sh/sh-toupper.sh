#!/bin/sh
test "${guard_65e8959+set}" = set && return 0; guard_65e8959=x
set -o nounset -o errexit

is_bsd() {
  if stat -f "%z" . > /dev/null 2>&1
  then
    return 0
  fi
  return 1
}

# Left/Right-Word-Boundary incompatible with BSD sed // re_format(7) https://man.freebsd.org/cgi/man.cgi?query=re_format&sektion=7
lwb='\<'
rwb='\>'
# shellcheck disable=SC2034
if is_bsd
then
  lwb='[[:<:]]'
  rwb='[[:>:]]'
fi

s="foo toupper(bar) baz toupper(qux)"
# shellcheck disable=SC2016
# shellcheck disable=SC2101
s="$(echo "$s" | sed -E -e 's/'"${lwb}"'toupper\(([[:alpha:]]+)\)/"$(echo "\1" | tr '[:lower:]' '[:upper:]')"/g')"
s="$(eval echo \""$s"\")"
echo "d0: $s"

# echo "foo toupper(bar) baz toupper(qux)" | gsed -E -e 's/\btoupper\(([[:alpha:]]+)\)/\U\1/g'
# echo "foo toupper(bar) baz toupper(qux)" | awk '{ while(match($0, /toupper\(([[:alpha:]]+)\)/, m)) { $0 = substr($0, 1, RSTART-1) toupper(m[1]) substr($0, RSTART+RLENGTH) } print }'

# shellcheck disable=SC2016
echo d1
eval echo \""$(echo "foo toupper(bar) baz toupper(qux)" | sed -E -e 's/'"${lwb}"'toupper\(([[:alpha:]]+)\)/"$(echo "\1" | tr "[:lower:]" "[:upper:]")"/g')"\"

toupper() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

eval_with_subst() {
  eval echo \""$(echo "$1" | sed -E -e 's/\$/@dollar_0b81358@/g' -e 's/`/@bq_cf8588@/g' -e "$2")"\" | sed -E -e 's/@bq_cf8588@/`/g' -e 's/@dollar_0b81358@/\$/g'
}

echo d2
# shellcheck disable=SC2016
eval_with_subst '  foo toupper(bar) $baz ` $$ toupper(qux)' 's/'"$lwb"'toupper\(([[:alpha:]]+)\)/"$(toupper "\1")"/g'
