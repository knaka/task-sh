#!/bin/sh
test "${guard_104ac71+set}" = set && return 0; guard_104ac71=x
set -o nounset -o errexit

. ./task.sh
. ./assert.lib.sh

# Evaluate strings from stdin with sed(1) substitution(s).
eval_with_subst_stdin() {
  for arg in "$@"
  do
    set -- "$@" "-e" "$arg"
    shift
  done
  eval printf \""$(sed -E -e 's/"/\\x22/g' -e 's/\$/\\x24/g' -e 's/`/\\x60/g' "$@")"\"
  echo
}

# Evaluate a string with sed(1) substitution(s).
eval_with_subst() {
  echo "$1" | (
    shift
    eval_with_subst_stdin "$@"
  )
}

toupper_4c7e44e() {
  printf "%s" "$1" | tr '[:lower:]' '[:upper:]'
}

tolower_542075d() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

# shellcheck disable=SC2016
do_eval_with_subst() (
  set -o errexit

  assert_eq '  foo BAR $baz ` $$ QUX' "$(eval_with_subst '  foo toupper(bar) $baz ` $$ toupper(qux)' 's/'"$lwb"'toupper'"$rwb"'\(([[:alpha:]]+)\)/"$(toupper_4c7e44e "\1")"/g')"
  assert_eq '$`"\; replaced:bar bar  "' "$(eval_with_subst '$`"\; foo bar  "' 's/foo/"$(echo replaced:bar)"/g')"

  input_path="$(temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo toupper(bar) baz ` $ "
toupper(hoge) fuga toupper(hare)
EOF
  expected_path="$(temp_dir_path)/expected.txt"
  cat <<'EOF' >"$expected_path"
foo BAR baz ` $ "
HOGE fuga HARE
EOF
  output_path="$(temp_dir_path)/output.txt"
  eval_with_subst_stdin 's/'"$lwb"'toupper\(([[:alpha:]]+)\)/"$(toupper_4c7e44e "\1")"/g' <"$input_path" >"$output_path"
  assert_eq "$(sha1sum "$expected_path" | field 1)" "$(sha1sum "$output_path" | field 1)"

  assert_eq 'foo BAR BAZ qux' "$(eval_with_subst 'foo toupper(bar) BAZ tolower(QUX)' \
    's/'"$lwb"'toupper'"$rwb"'\(([[:alpha:]]+)\)/"$(toupper_4c7e44e "\1")"/g' \
    's/'"$lwb"'tolower'"$rwb"'\(([[:alpha:]]+)\)/"$(tolower_542075d "\1")"/g')"
)

do_eval_with_subst
