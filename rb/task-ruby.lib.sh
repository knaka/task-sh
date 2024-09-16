#!/bin/sh
set -o nounset -o errexit

is_windows=false
if test "$(uname -s)" = Windows_NT
then
  is_windows=true
  # # todo: Fix
  # # shellcheck disable=SC2125
  # for path in "$HOME"/.bin/msys*
  # do
  #   if ! test -d "$path"
  #   then
  #     continue
  #   fi
  #   PATH="$path:$PATH"
  #   PATH="$path/usr/bin/:$PATH"
  #   MSYS2_PATH="$path"
  # done
  # export PATH
  # export MSYS2_PATH
fi

subcmd_irb() { # Launches an interactive Ruby shell.
  exec "$(dirname "$0")"/rb-cmds run irb "$@"
}

subcmd_bundle() { # Runs the `bundle` command.
  exec "$(dirname "$0")"/rb-cmds run bundle "$@"
}

subcmd_run() { # Runs a Ruby script.
  exec "$(dirname "$0")"/rb-cmds run ruby -C"$(pwd)" "$@"
}

subcmd_gem() { # Runs the `gem` command.
  exec "$(dirname "$0")"/rb-cmds run gem "$@"
}

excluded_scrs=",invalid.rb,"

task_install() { # Installs Ruby scripts.
  bin_dir_path="$HOME/rb-bin"
  mkdir -p "$bin_dir_path"
  rm -f "$bin_dir_path"/*
  for script in *.rb
  do
    if ! test -r "$script"
    then
      continue
    fi
    if echo "$excluded_scrs" | grep -q ",$script,"
    then
      continue
    fi
    name="${script%.*}"
    if $is_windows
    then
      bin_file_path="$bin_dir_path"/"$name".cmd
      cat <<EOF > "$bin_file_path"
@echo off
"$PWD"\task.cmd run "$PWD"\\${script} %*
EOF
    else 
      bin_file_path="$bin_dir_path"/"$name"
      cat <<EOF > "$bin_file_path"
#!/bin/sh
exec "$PWD"/task run "$PWD/${script}" "\$@"
EOF
      chmod +x "$bin_file_path"
    fi
  done
}

task_dep() { # Shows the dependency tree of gem packages.
  exec "$(dirname "$0")"/rb-cmds run bundle exec gem dependency
}
