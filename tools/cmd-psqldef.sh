#!/bin/sh
set -o nounset -o errexit

# sqldef/sqldef: Idempotent schema management for MySQL, PostgreSQL, and more https://github.com/sqldef/sqldef
package=github.com/psqldef/psqldef
name="$(basename "$package")"
version=v0.17.19

# --------------------------------------------------------------------------

. "$(dirname "$0")"/task.sh

if ! is_windows
then
  sh "$(dirname "$0")"/../go/cmd-go.sh install "$package"@"$version"
  cross_exec "$HOME"/go/bin/sqldef "$@"
fi

tag="$name:$version"
image_id="$(sh "$(dirname "$0")"/cmd-docker.sh images --format="{{.ID}}" "$tag")"
if test -z "$image_id"
then
  (
    cd "$(dirname "$0")"
    sh ./cmd-docker.sh build --progress plain -t "$tag" -f "$name".Dockerfile --build-arg "version=$version" .
  )
fi
for arg in "$@"
do
  arg="$(echo "$arg" | sed -e 's/\blocalhost\b/host.docker.internal/g')"
  arg="$(echo "$arg" | sed -e 's/127.0.0.1/host.docker.internal/g')"
  set -- "$@" "$arg"
  shift
done
sh "$(dirname "$0")"/cmd-docker.sh run -v "$PWD":/work --rm --interactive --tty "$tag" "$@"
