#!/bin/sh
test "${guard_54039c5+set}" = set && return 0; guard_54039c5=-

. ./task.sh

update_go_embedded_sh() {
  first_call 902b3c5 || return 0

  local go_file="$1"
  local sh_src="$2"
  local sh_dst="$3"
  local url_to_fetch="$4"

  if ! newer "$sh_src" "$sh_src" --than "$sh_dst"
  then
    return 0
  fi

  # shellcheck disable=SC2046
  line_num_start_marker="$(IFS=:; printf "%s\n" $(grep -E -n "^.+EMBED_FAA58B3" "$sh_src") | head -n 1)"
  # shellcheck disable=SC2046
  line_num_end_marker="$(IFS=:; printf "%s\n" $(grep -E -n "^EMBED_FAA58B3" "$sh_src") | head -n 1)"

  head -n "$line_num_start_marker" < "$sh_src" | sed -E -e "s@https://raw.githubusercontent.com/.*@${url_to_fetch}@" >"$sh_dst"
  cat "$go_file" >>"$sh_dst"
  tail -n +"$line_num_end_marker" < "$sh_src" >>"$sh_dst"

  chmod 0755 "$sh_dst"
}

update_go_embedded_cmd() {
  first_call 645592d || return 0

  local go_file="$1"
  local cmd_src="$2"
  local cmd_dst="$3"
  local url_to_fetch="$4"

  if ! newer "$cmd_src" "$cmd_src" --than "$cmd_dst"
  then
    return 0
  fi

  # shellcheck disable=SC2046
  line_num_marker_label="$(IFS=:; printf "%s\n" $(grep -E -n "^:embed_53c8fd5" "$cmd_src") | head -n 1)"

  head -n "$line_num_marker_label" < "$cmd_src" | sed -E -e "s@https://raw.githubusercontent.com/.*@${url_to_fetch}@" > "$cmd_dst"
  cat "$go_file" >>"$cmd_dst"
}
