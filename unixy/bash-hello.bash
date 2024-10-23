#!/bin/bash
set -o nounset -o errexit -o pipefail

echo My name is "${BASH_SOURCE[0]}".
for arg in "$@"
do
  echo Arg: "$arg"
done

perl -e 'printf("Hello, %s from Perl.\n", "MSYS")'
