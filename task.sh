#!/bin/sh
set -o nounset -o errexit

script_dir_path="$(dirname "$0")"

args="$(getopt "vhd:" "$@")"

# shellcheck disable=SC2086
set -- $args

verbose=false
shows_help=false
directory=""
while test $# -gt 0
do
  case "$1" in
    -v) verbose=true;;
    -h) shows_help=true;;
    -d) directory="$2"; shift;;
    --) shift; break;;
  esac
  shift
done

if $verbose
then
  set -o xtrace
fi

if test -n "$directory"
then
  cd "$directory"
fi

_set_path_attr() {
  __path="$1"
  __attribute="$2"
  __value="$3"
  if which xattr > /dev/null 2>&1
  then
    xattr -w "$__attribute" "$__value" "$__path"
  elif which attr > /dev/null 2>&1
  then
    attr -s "$__attribute" -V "$__value" "$__path"
  elif which PowerShell > /dev/null 2>&1
  then
    PowerShell -Command "Set-Content -Path '$__path' -Stream '$__attribute' -Value '$__value'"
  fi
}

attributes="com.dropbox.ignored com.apple.fileprovider.ignore#P"

set_path_sync_ignored() {
  for _path in "$@"
  do
    for _attribute in $attributes
    do
      _set_path_attr "$_path" "$_attribute" 1
    done
  done
}

task_install() { # Install in each directory.
  cd "$script_dir_path"
  for dir in "$script_dir_path"/*
  do
    if test -d "$dir"
    then
      (cd "$dir" && sh ./task.sh install)
    fi
  done
}

task_task_cmd__copy() { # Copy task.cmd to each directory.
  cd "$script_dir_path"
  for dir in *
  do
    if ! test -d "$dir"
    then
      continue
    fi
    cp -f task.cmd "$dir"/task.cmd
  done
}

task_help() { # Show help message.
  cat <<EOF
Usage: $0 <task[arg1,arg2,...]> [other_tasks...]

Tasks:
EOF
  max_len="$(grep -E -e "^task_" "$0" | sed -r -e 's/^task_//' -e 's/^([^ ()]+)__/\1:/g' -e 's/\(.*//' | awk '{ if (length($1) > max_len) max_len = length($1) } END { print max_len }')"
  grep -E -e "^task_" "$0" | sed -r -e 's/^task_//' -e 's/^([^ ()]+)__/\1:/g' -e 's/\(\) *\{ *(# *)?/ e8d2cce /' | sort | awk -F' e8d2cce ' "{ printf \"  %-${max_len}s  %s\n\", \$1, \$2 }"
}

task_nop() { # Do nothing.
  echo NOP
}

task_pwd() {
  echo "pwd: $(pwd)"
  exit 0
}

task_client__build() { # [args...] Build client.
  printf "Building client: "
  delim=""
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
}

task_client__deploy() { # [args...] Deploy client.
  printf "Deploying client: "
  delim=""
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
}

task_fail() { # Fails.
  echo FAIL
  exit 1
}

task_git() { # [args...] Run git command.
  cd "$script_dir_path"
  if ! test -d .git
  then
    git init
    set_path_sync_ignored .git/
    git remote add origin git@github.com:knaka/scr.git
    git branch --set-upstream-to=origin/main main
    git fetch origin
  fi
  exec git "$@"
}

if test ${#} -eq 0 || $shows_help
then
  task_help
  exit 0
fi

for task_with_args in "$@"
do
  task="$task_with_args"
  args=""
  case "$task_with_args" in
    *\[*)
      task="${task_with_args%%\[*}"
      args="$(echo "$task_with_args" | sed -r -e 's/^.*\[//' -e 's/\]$//' -e 's/,/ /')"
      ;;
  esac
  task="$(echo "$task" | sed -r -e 's/:/__/g')"
  if ! type task_"$task" > /dev/null 2>&1
  then
    echo "Unknown task: $task" >&2
    exit 1
  fi
  # shellcheck disable=SC2086
  task_"$task" $args
done
