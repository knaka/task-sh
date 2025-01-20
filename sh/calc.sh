#!/bin/sh
test "${guard_be53e21+set}" = set && return 0; guard_be53e21=x
set -o nounset -o errexit

#echo -n "$* -> "
#echo -n $(($*))
#echo

expression=$(echo "$@" | perl -pe 's/,([[:digit:]]{3})/\1/g')
perl -e "print (\"$* -> \" . (${expression}) . \"\n\");"

#echo -n "$* -> " ; echo "$*" | bc
