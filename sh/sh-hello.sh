#!/bin/sh

if test "${ARGV0+SET}" = "SET"
then
  echo "ARGV0 is “${ARGV0}”."
else
  echo "ARGV0 is not set."
fi
printf "hello\n"
