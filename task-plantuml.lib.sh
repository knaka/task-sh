#!/bin/sh
set -o nounset -o errexit

test "${guard_75b2210+set}" = set && return 0; guard_75b2210=x

subcmd_plantuml() (
  # Releases · plantuml/plantuml https://github.com/plantuml/plantuml/releases
  ver="1.2024.7"

  bin_dir_path="$HOME"/.bin
  jar_path="$bin_dir_path"/plantuml-"$ver".jar
  if ! test -r "$jar_path"
  then
    url="https://github.com/plantuml/plantuml/releases/download/v$ver/plantuml-$ver.jar"
    mkdir -p "$bin_dir_path"
    curl"$(exe_path)" --fail --location --output "$jar_path" "$url"
  fi
  subcmd_java -jar "$jar_path" "$@"
)

task_image__build() (
  cd "$TASKS_DIR"
  cd ./img
  for infile in *.in.puml
  do
    if ! test -r "$infile"
    then
      continue
    fi
    outfile="${infile%.in.puml}.svg"
    if ! newer "$infile" --than "$outfile"
    then
      echo 3f94be7 >&2
      continue
    fi
    file_hash="$(sha1sum "$infile" | sed -E -e 's/^(.......).*$/\1/')"
    echo "Generating $outfile" >&2
    subcmd_plantuml \
      -pipe \
      -svg \
      --charset UTF-8 \
      -Dfilehash="$file_hash" \
      --nometadata < "$infile" > "${infile%.in.puml}.svg"
  done
)
