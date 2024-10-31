#!/bin/bash
set -o nounset -o errexit -o pipefail

test "${guard_ecc3b3b+set}" = set && return 0; guard_ecc3b3b=-

. ./task-java.lib.sh

mkdir -p .cds
set_sync_ignored .cds

subcmd_run() ( # Runs the program.
  main_class=org.example.AppKt
  # class_path="$SCRIPT_DIR"/app/build/libs/app.jar
  class_path="$SCRIPT_DIR"/app/build/libs/app-all.jar
  class_path="$(realpath "$class_path")"
  cds_dir_path="$SCRIPT_DIR"/.cds
  cds_dir_path="$(realpath "$cds_dir_path")"
  shared_archive_path="$cds_dir_path"/appcds.jsa
  shared_class_list_path="$cds_dir_path"/classes.lst

  if ! test -e "$shared_archive_path" || newer "$class_path" --than "$shared_archive_path"
  then
    subcmd_java -XX:DumpLoadedClassList="$shared_class_list_path" -Duser.language=en -cp "$class_path" "$main_class" nop
    subcmd_java -Xshare:dump -XX:SharedClassListFile="$shared_class_list_path" -XX:SharedArchiveFile="$shared_archive_path" -cp "$class_path" "$main_class" nop \
      | grep -v \
        -e 'warning.*cds.* Preload Warning: Cannot find .*proxy.*' \
        -e 'warning.*cds.* java.lang.ClassNotFoundException: .*proxy.*'
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
)

subcmd_install() ( # Install shims for the program subcommands.
  chdir_script
  subcmd_build
  system_subcommands=":list:nop:help:"
  for subcmd in $(subcmd_run list)
  do
    if echo "$system_subcommands" | grep -q ":$subcmd:"
    then
      continue
    fi
    java_bin_dir_path="$HOME"/java-bin
    mkdir -p "$java_bin_dir_path"
    rm -f "$java_bin_dir_path"/*
    if is_windows
    then
      java_bin_file_path="$java_bin_dir_path"/"$subcmd".cmd
      cat <<EOF > "$java_bin_file_path"
@echo off
"$SCRIPT_DIR"\task.cmd run "$subcmd" %* || exit /b !ERRORLEVEL!
EOF
    else
      java_bin_file_path="$java_bin_dir_path"/"$subcmd"
      cat <<EOF > "$java_bin_file_path"
#!/bin/sh
exec "$SCRIPT_DIR"/task run "$subcmd" "\$@"
EOF
        chmod +x "$java_bin_file_path"
    fi
  done
)
