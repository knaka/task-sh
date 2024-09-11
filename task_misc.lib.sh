#!/bin/sh

: "${script_dir_path:=}"

task_install() { # Install in each directory.
  cd "$script_dir_path" || exit 1
  for dir in "$script_dir_path"/*
  do
    if test -d "$dir"
    then
      echo "Installing in $dir" >&2
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

task_home_link() { # Link this directory to home.
  _script_dir_path="$(realpath "$(dirname "$0")")"
  _script_dir_name="$(basename "$_script_dir_path")"
  ln -sf "$_script_dir_path" "$HOME"/"$_script_dir_name"
}

delegate_tasks() {
  # Mock for test of hekp.
  (
    cd "$script_dir_path" || exit 1
    case "$1" in
      tasks)
        echo "exclient:build     Build client."
        echo "exclient:deploy    Deploy client."
        ;;
      subcmds)
        echo "exgit       Run git command."
        echo "exdocker    Run docker command."
        ;;
      extra:install)
        echo Installing extra commands...
        echo Done
        ;;
      *)
        return 1
        ;;
    esac
  )
}
