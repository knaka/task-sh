# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_637608a-false}" && return 0; sourced_637608a=true

is_linux() {
  test -d /proc -o -d /sys
}

is_macos() {
  test -r /System/Library/CoreServices/SystemVersion.plist
}

is_windows() {
  test -d "c:/" -a ! -d /proc
}

is_bsd() {
  # stat -f "%z" . >/dev/null 2>&1
  is_macos || test -r /etc/rc.subr
}

is_debian() {
  test -f /etc/debian_version
}

is_alpine() {
  test -f /etc/alpine-release
}
