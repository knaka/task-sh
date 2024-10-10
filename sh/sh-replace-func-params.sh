#!/bin/sh
set -o nounset -o errexit

test "${guard_be96874+set}" = set && return 0; guard_be96874=x

while read -r line
do
  if echo "$line" | grep -q -E -e '[[:<:]]foo\('
  then
    params="$(
      echo "$line" |
        sed -E -n -e 's/.*[[:<:]]foo\((.*)\).*/\1/p'
    )"
    params= "$(
      echo "$params" |
        sed -e "s/, */\n/g" |
        sed -E -e 's/(.+)/cast(\1)/' |
        paste -sd , -
        # xargs -I {} echo "{}, " |
        # xargs |
        # sed -E -e 's/,$//'
    )"
    line="$(echo "$line" | sed -E -e "s/[[:<:]]foo\(.*\)/foo($params)/")"
  fi
  echo "$line"
done <<EOF > /dev/stdout
a = foo(aaa,   b b b,ccc, ddd)
foo(xxx, yyy, zzz)
aaa foo() bbb
hoge fuga foo bar; foo bar
z = foo(000, 111)
EOF
