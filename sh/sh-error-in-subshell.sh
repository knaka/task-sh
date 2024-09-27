#!/bin/sh
set -o nounset -o errexit

f() (
  if true
  then
    false
    return $?
  fi
  true
  # return $?
  # echo "NO!!"
)
# f
f && echo "f succeeded" || echo "f failed"
# f || { echo "f failed" >&2; exit 1; }

# foo() (
#   false
#   return $?
# )

# bar() {
#   false
#   return $?
# }

# echo ed95b20 >&2
# # (
# #   false
# # )
# if foo
# then
#   echo success
# else
#   echo failure
# fi
# echo 69274a9 >&2
