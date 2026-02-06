# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_09e936b-false}" && return 0; sourced_09e936b=true

. ./utils.lib.sh

# This is foo:bar.
#MISE tools={jq="latest"}
task_foo__bar() {
  push_dir "$ORIGINAL_CWD"
  pwd
  echo "foo bar test" "$@" "ef846c7"
  pop_dir
}

# This is bar:baz.
task_bar__baz() {
  echo bar:baz
}
