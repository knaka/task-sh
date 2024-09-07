#!/bin/sh

: "${script_dir_path:=}"

task_install() { # Install in each directory.
  cd "$script_dir_path" || exit 1
  for dir in "$script_dir_path"/*
  do
    if test -d "$dir"
    then
      (cd "$dir" && sh ./task.sh install)
    fi
  done
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

task_task_cmd__copy() { # Copy task.cmd to each directory.
  cd "$script_dir_path" || exit 1
  for dir in *
  do
    if ! test -d "$dir"
    then
      continue
    fi
    cp -f task.cmd "$dir"/task.cmd
  done
}
