#!/bin/sh
set -o nounset -o errexit

f() (
  set -o errexit
  echo AAA >&2
  false
  echo BBB >&2
)

(
  set +o errexit
  f
  if test $? -eq 0 
  then
    echo "f succeeded"
  else
    echo "f failed"
  fi
)

# if f
# then
#   echo "f succeeded"
# else
#   echo "f failed"
# fi
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
