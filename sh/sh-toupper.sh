#!/bin/sh
test "${guard_65e8959+set}" = set && return 0; guard_65e8959=x
set -o nounset -o errexit

s="foo toupper(bar) baz toupper(qux)"
# shellcheck disable=SC2016
# shellcheck disable=SC2101
s="$(echo "$s" | sed -E -e 's/[[:<:]]toupper\(([[:alpha:]]+)\)/"$(echo "\1" | tr '[:lower:]' '[:upper:]')"/g')"
s="$(eval echo \""$s"\")"
echo "$s"

# echo "foo toupper(bar) baz toupper(qux)" | gsed -E -e 's/\btoupper\(([[:alpha:]]+)\)/\U\1/g'
# echo "foo toupper(bar) baz toupper(qux)" | awk '{ while(match($0, /toupper\(([[:alpha:]]+)\)/, m)) { $0 = substr($0, 1, RSTART-1) toupper(m[1]) substr($0, RSTART+RLENGTH) } print }'

# shellcheck disable=SC2016
eval echo \""$(echo "foo toupper(bar) baz toupper(qux)" | sed -E -e 's/[[:<:]]toupper\(([[:alpha:]]+)\)/"$(echo "\1" | tr "[:lower:]" "[:upper:]")"/g')"\"
