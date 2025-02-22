#!/bin/sh

hello="Hello, world!"

hello() {
  echo "${hello}"
}

if test "${ARG0+SET}" = "SET"
then
  echo "ARGV0 is “${ARG0}”."
else
  echo "ARGV0 is not set."
fi
hello
