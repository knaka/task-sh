# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_68dabbe-false}" && return 0; sourced_68dabbe=true

. ./task.sh

iso_date_format_590c473='%Y-%m-%dT%H:%M:%S%z'
iso_date_format_utc_590c473='%Y-%m-%dT%H:%M:%SZ'

# Output current date and time in ISO-8601 format.
# Usage: date_iso
# Example: date_iso  # => 2024-01-01T12:00:00+0900
date_iso() {
  if is_windows
  then
    # -I[SPEC]: Output ISO-8601 date / SPEC=date (default), hours, minutes, seconds or ns
    date -Iseconds
  else
    # -j: Do not try to set the date
    date -j +"$iso_date_format_590c473"
  fi
}

# Touch files with specified ISO-8601 time.
# Usage: set_last_mod_iso <file> <ISO_time>
# Example: set_last_mod_iso file.txt 2024-01-01T12:00:00Z
set_last_mod_iso() {
  local file="$1"
  local time="$2"
  if is_windows
  then
    # BusyBox date(1) does not seem to handle "%z". Use PowerShell to do this.
    pwsh.exe -NoProfile -Command "Set-ItemProperty \"$file\" -Name LastWriteTime -Value \"$time\""
    return
  fi
  if is_macos
  then
    # BSD touch(1) does not accept ISO time with timezone. Convert to UTC.
    local time_utc
    if time_utc="$(TZ=UTC0 date -j -f "$iso_date_format_590c473" "$time" +"$iso_date_format_utc_590c473" 2>/dev/null)"
    then
      time="${time_utc}"
    fi
  fi
  touch -d "$time" "$file"
}

# Output last modification time of a file in ISO-8601 format.
# Usage: last_mod_iso <file>
# Example: last_mod_iso file.txt  # => 2024-01-01T12:00:00+0900
last_mod_iso() {
  local file="$1"
  if is_macos
  then
    # S: String
    # a, m, c, B: Last accessed or modified, or when the inode was last changed, or the birth time of the inode
    stat -f "%Sm" -t "$iso_date_format_590c473" "$1"
  elif is_windows
  then
    local epoch
    epoch="$(stat -c "%Y" "$1")"
    date -d @"$epoch" -Iseconds
  else
    date --date "$(stat --format "%y" "$1")" +"$iso_date_format_590c473"
  fi
}
