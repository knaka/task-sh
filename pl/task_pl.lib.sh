#!/bin/sh

# Strawberry Perl for Windows - Releases https://strawberryperl.com/releases.html
pl_ver=5.38.2.2
# https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_53822_64bit/strawberry-perl-5.38.2.2-64bit-portable.zip

pl_bin_result=""

pl_bin() {
  if test "pl_bin_result" != ""
  then
    echo "$pl_bin_result"
    return
  fi
  if which perl > /dev/null 2>&1
  then
    pl_bin_result=$(which perl)
    echo "$pl_bin_result"
    return
  fi
  if is_windows
  then
    pl_bin_result="C:/Strawberry/perl/bin/perl.exe"
    echo "$pl_bin_result"
    return
  fi
}

is_windows() {
  test "$(uname -s)" = "Windows_NT" && return 0 || return 1
}

task_pl() { # Perl.
  if is_windows
  then
    echo Windows!
  else
    echo Not Windows!
  fi
}
