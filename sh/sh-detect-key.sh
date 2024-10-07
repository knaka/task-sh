#!/bin/sh
set -o nounset -o errexit

test "${guard_f7a3db2+set}" = set && return 0; guard_f7a3db2=x

# Some "/bin/sh" provides `-s` option.
# shellcheck disable=SC3045
while read -rsn1 key
do
  case "$key" in
    b) echo "Open a Browser" ;;
    c) clear ;;
    x) break ;;
    *)
      echo "[b] Open a Browser"
      echo "[c] Clear console"
      echo "[x] to exit"
  esac
done
