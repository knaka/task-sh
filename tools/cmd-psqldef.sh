#!/bin/sh
set -o nounset -o errexit

#  --export -U user -h host.docker.internal -p 52030 --password=password hoge

cleanup() {
  if test "${temp_dir_path+set}" = set
  then
    rm -rf "$temp_dir_path"
  fi
}

trap cleanup EXIT

. "$(dirname "$0")"/task.sh

if ! docker version > /dev/null 2>&1
then
  echo "Docker is not availabe. Exiting." >&2
  exit 1
fi

tag="psqldef:latest"

should_build=false
while true
do
  break
  created_at="$(docker images --format="{{.CreatedAt}}" "$tag")"
  if test -z "$created_at"
  then
    echo "No image found. Building the image." >&2
    should_build=true
    break
  fi
  # If the file `psqldef.Dockerfile` is newer than the image, rebuild the image.
  temp_dir_path="$(mktemp -d)"
  touched_file_path="$temp_dir_path"/touched
  created_at_wo_tz="$(echo "$created_at" | sed -E -e 's/^([^ ]+) ([^ ]+) .*$/\1 \2/')"
  touch --date="$created_at_wo_tz" "$touched_file_path"
  ls -l "$touched_file_path"

  if is_newer_than psqldef.Dockerfile "$touched_file_path"
  then
    should_build=true
    break
  fi
  break
done

if $should_build
then
  docker build -t "$tag" -f psqldef.Dockerfile .
fi

docker run --rm -it "$tag" "$@"
