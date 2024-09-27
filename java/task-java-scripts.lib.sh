#!/bin/bash
set -o nounset -o errexit -o pipefail

set_dir_sync_ignored "$(dirname "$0")"/.cds

subcmd_run() {
  main_class=org.example.AppKt
  class_path="$(dirname "$0")"/app/build/libs/app.jar
  class_path="$(realpath "$class_path")"
  cds_dir_path="$(dirname "$0")"/.cds
  cds_dir_path="$(realpath "$cds_dir_path")"
  shared_archive_path="$cds_dir_path"/appcds.jsa
  shared_class_list_path="$cds_dir_path"/classes.lst

  if ! test -e "$shared_archive_path" || is_newer_than "$class_path" "$shared_archive_path"
  then
    sh "$(dirname "$0")"/task.sh java -XX:DumpLoadedClassList="$shared_class_list_path" -Duser.language=en -cp "$class_path" "$main_class" nop
    sh "$(dirname "$0")"/task.sh java -Xshare:dump -XX:SharedClassListFile="$shared_class_list_path" -XX:SharedArchiveFile="$shared_archive_path" -cp "$class_path" "$main_class" nop
  fi

  subcmd_java \
    -Xss256k \
    -XX:+TieredCompilation \
    -XX:TieredStopAtLevel=1 \
    -Xshare:on \
    -XX:SharedArchiveFile="$shared_archive_path" \
    -cp "$class_path" \
    "$main_class" \
    "$@"
}
