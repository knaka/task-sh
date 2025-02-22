# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_a642529-}" = true && return 0; sourced_a642529=true

readonly dyn_priv_begin=49152
readonly dyn_priv_end=65535

subcmd_ip_port_in_use() {
  local port="$1"
  if is_windows
  then
    if netstat.exe -a -n -p TCP | awk '{ print $2 }' | sed -e 's/^.*://' -e 's/[^0-9]*$//' | grep -q "^${port}$"
    then
      echo "Port ${port} is in use." >&2
      return 0
    fi
    echo "Port ${port} is not in use." >&2
    return 1
  fi
}

subcmd_ip_port_search_free() { # Search for a free port in the dynamic/private range
  local port="${1:-$dyn_priv_begin}"
  while test "${port}" -le "${dyn_priv_end}"
  do
    if subcmd_ip_port_in_use "${port}"
    then
      port=$((port + 1))
    else
      echo "${port}"
      return 0
    fi
  done
}

subcmd_ip__ports_in_use() { # List all ports in use
  if is_windows
  then
    netstat.exe -a -n -p TCP | grep TCP | awk '{ print $2 }' | sed -n -e 's/^.*://p' | sort -n | uniq
  elif is_macos
  then
    netstat -anvp tcp | grep ^tcp4 | awk '{ print $4 }' | sed 's/.*\.//' | sort -n | uniq
  else
    echo "Not implemented" >&2
    exit 1
  fi
}
