#!/bin/sh
test "${guard_8d6fc89+set}" = set && return 0; guard_8d6fc89=x
set -o nounset -o errexit

# toupper() {
#   echo "$1" | tr '[:lower:]' '[:upper:]'
# }

# # begin="BEGIN"
# # end="END"

# # # regular expression - sed word boundaries, on macOS - Unix & Linux Stack Exchange https://unix.stackexchange.com/questions/190334/sed-word-boundaries-on-macos
# # cat <<'EOF' | sed -E -e "s/[[:<:]]([[:alpha:]]+)\(([[:alpha:]]+)\)/\1(${begin}\2${end})/g" | while read -r line; do
# # foo bar foo(aaa)
# # bar(hoge) foo bar(hare)
# # baz bar(fuga)
# # foo bar baz qux
# # EOF
# #   echo "d: $line"
# # done

# filter_all_string() {
#   re="$1"
#   shift
#   s="$1"
#   shift

#   echo "$s" | sed -E -e "s/($re)/\nreplace:\1\n/g" | while IFS= read -r line
#   do
#     if echo "$line" | grep -q "^replace:"
#     then
#       printf "%s" "$(echo "$line" | sed -E -e "s/^replace://" | "$@")"
#     else
#       printf "%s" "$line"
#     fi
#   done
# }

# res0="$(filter_all_string "[[:<:]][[:alpha:]]+[[:>:]]" "  foo hoge1 bar fuga2 baz  " tr '[:lower:]' '[:upper:]')"
# echo result0: "$res0"

# replace_all_string() {
#   re="$1"
#   shift
#   s="$1"
#   shift

#   echo "$s" | sed -E -e "s/($re)/\nreplace:\1\n/g" | while IFS= read -r line
#   do
#     if echo "$line" | grep -q "^replace:"
#     then
#       printf "%s" "$("$@" "$(echo "$line" | sed -E -e "s/^replace://")")"
#     else
#       printf "%s" "$line"
#     fi
#   done
# }

# res1="$(replace_all_string "[[:<:]][[:alnum:]]+[[:>:]]" "  foo hoge1 bar fuga2 baz  " toupper)"
# echo result1: "$res1"

# replace_matched() {
#   re="$1"
#   shift 1
#   s="$1"
#   shift 1

#   echo "$s" | sed -E -e "s/$re/1:\1\n2:\2\n3:\3\n4:\4/g"
# }

# replace_matched "(([[:alnum:]]+)-([[:alnum:]]+))" "foo-bar bar-baz"

s='foo bar foo(aaa)
bar(hoge) foo bar(hare)
baz bar(fuga)
foo bar baz qux'

# Replace all `name(var)` to `name(VAR)`. i.e. `foo(aaa)` to `foo(AAA)`.
# echo "$s" | awk '{ gsub(/\([[:alpha:]]+\)(\([[:alpha:]]+\))/, "xxx"); print }'
echo "$s" | awk '{ gsub(/\(([[:alpha:]]+)\)/, "(\1)"); print }'
