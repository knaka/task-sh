#!/bin/sh
set -o nounset -o errexit

finalize() {
  if test "${tmp_dir_path+SET}" = SET
  then
    rm -fr "$tmp_dir_path"
  fi
}

trap finalize EXIT

file_path=
if test "${1+SET}" = SET
then
  file_path="$1"
fi
# -q: quiet
# -d: directory
tmp_dir_path=$(mktemp -qd /tmp/vwtmp.XXXXXX)
if test "$file_path" = ""
then
  title="(stdin)"
  tmp_file_path="$tmp_dir_path"/"$title"
  cat > "$tmp_file_path"
else
  if ! test -r "$file_path"
  then
    echo "$file_path: No such file" 1>&2
    exit 1
  fi
  title="$(basename "$file_path") (RO)"
  tmp_file_path="$tmp_dir_path"/"$title"
  cat "$file_path" > "$tmp_file_path"
fi
chmod 444 "$tmp_file_path"
sh "$(dirname "$0")"/ed.sh -b "$tmp_file_path"
