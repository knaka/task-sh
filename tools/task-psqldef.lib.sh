#!/bin/sh
set -o nounset -o errexit

# psqldef --export -U user -h host.docker.internal -p 52030 --password=password hoge

test "${guard_c78c581+set}" = set && return 0; guard_c78c581=-

. ./task.sh
. ./task-docker.lib.sh
. ./task-go.lib.sh

subcmd_psqldef() (
  # sqldef/sqldef: Idempotent schema management for MySQL, PostgreSQL, and more https://github.com/sqldef/sqldef
  package=github.com/sqldef/sqldef/cmd/psqldef
  name="$(basename "$package")"
  version=v0.17.19

  if ! is_windows
  then
    gopath="$(subcmd_go env GOPATH)"
    bin_dir_path="$gopath"/bin
    bin_path="$bin_dir_path"/"$name"@"$version""$(exe_ext)"
    if ! type "$bin_path" > /dev/null 2>&1
    then
      subcmd_go install "$package"@"$version"
      mv "$bin_dir_path"/"$name""$(exe_ext)" "$bin_path"
    fi
    "$bin_path" "$@"
    return $?
  fi

  tag="$name:$version"
  image_id="$(subcmd_docker images --format="{{.ID}}" "$tag")"
  if test -z "$image_id"
  then
    (
      chdir_script_dir
      subcmd_docker build --progress plain -t "$tag" -f "$name".Dockerfile --build-arg "version=$version" .
    )
  fi
  for arg in "$@"
  do
    arg="$(echo "$arg" | sed -e 's/\blocalhost\b/host.docker.internal/g')"
    arg="$(echo "$arg" | sed -e 's/127.0.0.1/host.docker.internal/g')"
    set -- "$@" "$arg"
    shift
  done
  subcmd_docker run -v "$PWD":/work --rm --interactive --tty "$tag" "$@"
)
