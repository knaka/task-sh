#!/bin/sh
test "${guard_54039c5+set}" = set && return 0; guard_54039c5=-

. ./task.sh

subcmd_update__embedded() {
  first_call 902b3c5 || return 0

  task_bootstrap__go__gen

  sh_src=./embedded-go
  sh_dst=./embedded-go
  url_to_fetch="https://raw.githubusercontent.com/knaka/gobin/main/$sh_dst"

  if ! newer "$sh_src" "$bootstrap_go" --than "$sh_dst"
  then
    return 0
  fi

  # shellcheck disable=SC2046
  line_num_start_marker="$(IFS=:; printf "%s\n" $(grep -E -n "^.+EMBED_FAA58B3" "$sh_src") | head -n 1)"
  # shellcheck disable=SC2046
  line_num_end_marker="$(IFS=:; printf "%s\n" $(grep -E -n "^EMBED_FAA58B3" "$sh_src") | head -n 1)"

  head -n "$line_num_start_marker" < "$sh_src" | sed -E -e "s@https://raw.githubusercontent.com/.*@${url_to_fetch}@" > "$sh_dst"
  cat "$bootstrap_go" >> "$sh_dst"
  tail -n +"$line_num_end_marker" < "$sh_src" >> "$sh_dst"

  chmod 0755 "$sh_dst"
}
