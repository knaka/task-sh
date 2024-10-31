#!/bin/sh
set -o nounset -o errexit

# test "${guard_f78f5cf+set}" = set && return 0; guard_f78f5cf=x

. ./task.sh
. ./task-git.lib.sh

task_install() ( # Install in each directory.
  chdir_script
  for dir in sh go py js
  do
    if ! test -d "$dir"
    then
      continue
    fi
    echo "Installing in $dir" >&2
    (
      cd "$dir" || exit 1
      sh ./task.sh install
    )
  done
)

task_client__foo__build() ( # [args...] Build client.
  printf "Building client: "
  delim=
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
)

task_client__deploy() ( # [args...] Deploy client.
  printf "Deploying client: "
  delim=""
  for arg in "$@"
  do
    printf "%s%s" "$delim" "$arg"
    delim=", "
  done
  echo
)

task_task_cmd__copy() ( # Copy task.cmd to each directory.
  chdir_script
  for dir in *
  do
    if ! test -d "$dir"
    then
      continue
    fi
    if ! test -r "$dir"/task.cmd
    then
      continue
    fi
    cp -f task.cmd "$dir"/task.cmd
  done
)

task_home_link() ( # Link this directory to home.
  script_dir_name="$(basename "$SCRIPT_DIR")"
  ln -sf "$SCRIPT_DIR" "$HOME"/"$script_dir_name"
)

subcmd_env() ( # Show environment.
  echo "APP_SENV:" "${APP_SENV:-}"
  echo "APP_ENV:" "${APP_ENV:-}"
)

# Mock for test of help.
delegate_tasks() (
  cd "$(dirname "$0")" || exit 1
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
      echo "Unknown task: $1" >&2
      return 1
      ;;
  esac
)

subcmd_newer() { # Check newer files.
  newer "$@"
}

subcmd_dupcheck() ( # Check duplicate files.
  # shellcheck disable=SC2140
  ignore_list=":"\
"task:"\
"package.json:"\
"package-lock.json:"\
"task-project.lib.sh:"\
"task-prj.lib.sh:"\
"tsconfig.json:"\
"page.tsx:"\
"Cargo.toml:"\
"Cargo.lock:"\
""
  # shellcheck disable=SC2140
  ignore_path=":"\
"next/app/:"\
""
  chdir_script
  base_prev=
  hash_prev=
  path_prev=
  for path in $(subcmd_git ls-files)
  do
    base=$(basename "$path")
    case "$base" in
      .*) continue;;
      README*) continue;;
      *.rs) continue;;
    esac
    if echo "$ignore_path" | grep -q ":$(dirname "$path")/:" > /dev/null 2>&1
    then
      continue
    fi
    if echo "$ignore_list" | grep -q ":$base:" > /dev/null 2>&1
    then
      continue
    fi
    echo "$base" "$(sha1sum "$path" | cut -d ' ' -f 1)" "$path"
  done | sort | while read -r base hash path
  do
    # echo aa0accc "$base" "$hash" "$path" >&2
    if test "$base" = "$base_prev" && test "$hash" != "$hash_prev"
    then
      echo "Conflict:"
      echo "  $path"
      echo "  $path_prev"
    fi
    base_prev="$base"
    hash_prev="$hash"
    path_prev="$path"
  done
)

task_task_cmd__rename_copy() (
  for dest in */*.cmd
  do
    if ! test -r "$dest"
    then
      continue
    fi
    if test "$(dirname "$dest")" = "cmd"
    then
      continue
    fi
    case "$(basename "$dest")" in
      go-embedded.cmd)
        continue
        ;;
    esac
    cp -f task.cmd "$dest"
  done
)

task_task_sh__copy() (
  chdir_script
  for dest in */task.sh
  do
    cp task.sh "$dest"
  done
)

task_hello1() {
  while true
  do
    echo hello1
    sleep 1
  done
}

task_hello2() (
  while true
  do
    echo hello2
    sleep 1
  done
)

task_daemon() {
  task_hello1 &
  # task_hello2 &
  (
    while true
    do
      echo hello3
      sleep 1
    done
  ) &
  sleep 3
  kill_children
}

task_once() {
  echo Started Once >&2
  first_call 4012815 || return 0
  echo Doing Once >&2
}

readonly psv_bb1e7fe="foo||bar|baz"

task_each() (
  set_ifs_pipe
  for arg in $psv_bb1e7fe
  do
    echo "pipe: $arg" >&2
  done

  joined="$(IFS='|' strjoin "hoge|fuga|||foo|bar" ,)"
  echo b89b426 "$joined"
  joined="$(IFS=' ' strjoin "hoge fuga   foo bar" ",")"
  echo 412b585 "$joined"
  joined="$(IFS="$(printf "\n\r ")"; strjoin "$(printf "foo\nbar\n\r\nbaz\n")" ",")"
  echo d26a238 "$joined"
  joined="$(IFS='|'; for a in $(printf "foo|bar|baz"); do echo "$a"; done | paste -sd, -)"
  echo 45726c8 "$joined"

  joined="$(IFS='|'; for a in $(printf "foo||  bar  |baz"); do echo "$a"; done | paste -sd, -)"
  echo c456a81 "$joined"

  set_ifs_newline
  for line in $(printf "123\n\n456\n789\n")
  do
    echo "newline: $line" >&2
  done

  set_ifs_tab
  for line in $(printf "abc\t   def   \t\tghi\n")
  do
    echo tab: "<$line>" >&2
  done

  restore_ifs

  for line in $(printf "xxx    yyy zzz\n")
  do
    echo "default: <$line>" >&2
  done

  set_ifs_pipe
  for attribute in $psv_file_sharing_ignorance_attributes
  do
    echo "$attribute"
  done
  restore_ifs
)
