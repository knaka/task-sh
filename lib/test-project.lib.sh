#!/bin/sh
test "${guard_e5f9b82+set}" = set && return 0; guard_e5f9b82=x
set -o nounset -o errexit

test_my_ip_addr() {
  sh task.sh my_ip_addr
}
