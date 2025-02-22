# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_9076e97-}" = true && return 0; sourced_9076e97=true

. ./task.sh
. ./task-node.lib.sh

subcmd_install() ( # Install JS scripts.
  excluded_scrs=",invalid.js,"

  js_bin_dir_path="$HOME"/js-bin
  mkdir -p "$js_bin_dir_path"
  rm -f "$js_bin_dir_path"/*
  for js_file in *.js *.mjs *.cjs
  do
    if ! test -r "$js_file"
    then
      continue
    fi
    if echo "$excluded_scrs" | grep -q ",$js_file,"
    then
      continue
    fi
    # Ignore task files written in JS.
    case "$js_file" in
      task.cjs|task-*.cjs) continue ;;
    esac
    js_name="${js_file%.*}"
    if is_windows
    then
      js_bin_file_path="$js_bin_dir_path"/"$js_name".cmd
      cat <<EOF > "$js_bin_file_path"
@echo off
"$PWD"\task.cmd run "$PWD\\${js_file}" %* || exit /b !ERRORLEVEL!
EOF
    else 
      js_bin_file_path="$js_bin_dir_path"/"$js_name"
      cat <<EOF > "$js_bin_file_path"
#!/bin/sh
exec "$PWD"/task run "$PWD/${js_file}" "\$@"
EOF
      chmod +x "$js_bin_file_path"
    fi
  done
)

subcmd_run() { # Run JS script in the original working directory.
  subcmd_node "$PROJECT_DIR"/scripts/launch-script.cjs "$WORKING_DIR" "$@"
}

. ./task-ip-utils.lib.sh

subcmd_httpd() { # Run a simple HTTP server.
  push_dir "$PROJECT_DIR"
  local host=127.0.0.1
  local port
  port="$(ip_random_free_port)"
  subcmd_node --invocation-mode=background "$PROJECT_DIR"/scripts/httpd-mini.mjs "$host" "$port" "$WORKING_DIR"
  pop_dir
  while true
  do
    menu \
      "&List" \
      "E&xit" \
      # nop
    case "$(get_key)" in
      (l) ls -la ;;
      (x) break ;;
    esac
  done
}
