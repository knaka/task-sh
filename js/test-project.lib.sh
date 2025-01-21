#!/bin/sh
test "${guard_9cb8c41+set}" = set && return 0; guard_9cb8c41=x
set -o nounset -o errexit

test_my_ip_addr() {
  false
  sh task.sh my_ip_addr
}
