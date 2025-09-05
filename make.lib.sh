# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a3b1bd0-false}" && return 0; sourced_a3b1bd0=true

. ./task.sh

require_pkg_cmd \
  --deb-id=make \
  make

make() {
  run_pkg_cmd make "$@"
}

# Run make(1)
subcmd_make() {
  make "$@"
}

# Print make(1) sub-help
# Add this in user's project-specific task file like this:
#   add_sub_help show_make_help
show_make_help() {
  cat <<EOF
Subcommand "make":
  Usage: ${ARG0BASE} make [options] [targets...]

  Targets:
EOF
  sed -Ene 's/(^[[:alpha:]_-][[:alnum:]_-]+):.*/\1/p' Makefile | while read -r target
  do
    printf "    %s\n" "$target"
  done
}
