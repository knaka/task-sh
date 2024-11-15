#!/bin/sh
test "${guard_11b0346+set}" = set && return 0; guard_11b0346=x
set -o nounset -o errexit

. ../assert.lib.sh
. ./task.sh

rewrite_args() (
  usv_args="$(array_string_split "$unit_sep" "$1" ", *")"
  delim=
  ifs_unit_sep
  for arg in $usv_args
  do
    printf '%stypeof %s === "undefined"? null: %s' "$delim" "$arg" "$arg"
    delim=", "
  done
  ifs_restore
)

test_eval() (
  set +o errexit

  assert_eq 'typeof A === "undefined"? null: A, typeof B === "undefined"? null: B' "$(rewrite_args "A, B")"
  assert_eq 'typeof args.nullableId === "undefined"? null: args.nullableId, typeof args.nullableUsername === "undefined"? null: args.nullableUsername' "$(rewrite_args 'args.nullableId, args.nullableUsername')"

  eval_with_subst_stdin \
    's/([_[:alnum:]]+)(: .* \| null;)/\1?\2/' \
    's/^(.*\.bind)\((.*)\)(.*)$/\1("$(rewrite_args "\2")")\3/' \
  < sqlcgen/querier.ts > querier.ts.real

)