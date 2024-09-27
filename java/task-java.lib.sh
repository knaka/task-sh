#!/bin/sh
set -o nounset -o errexit

test "${guard_473dd0b+set}" = set && return 0; guard_473dd0b=-

. task.sh

java_arch() {
  case "$(uname -m)" in
    arm64) echo "aarch64" ;;
    x86_64) echo "x64" ;;
    *) echo "Unsupported architecture" >&2; exit 1 ;;
  esac
}

java_os() {
  case "$(uname -s)" in
    Linux) echo "linux" ;;
    Darwin) echo "mac" ;;
    MINGW* | CYGWIN* | MSYS* | Windows_NT) echo "windows" ;;
    *) echo "Unsupported platform" >&2; exit 1 ;;
  esac
}

java_home() (
  # Releases · adoptium/temurin24-binaries https://github.com/adoptium/temurin24-binaries/releases
  # Releases · adoptium/temurin23-binaries https://github.com/adoptium/temurin23-binaries/releases
  # Releases · adoptium/temurin22-binaries https://github.com/adoptium/temurin22-binaries/releases
  # Releases · adoptium/temurin21-binaries https://github.com/adoptium/temurin21-binaries/releases
  ver="21.0.4+7"

  postfix=jdk
  jre_postfix=
  # postfix="jre"
  # jre_postfix="-jre"

  if test "${JAVA_HOME+SET}" = "SET"
  then
    echo "$JAVA_HOME"
    return
  fi

  if test -r "$script_dir_path"/.java-version
  then
    ver=$(cat "$script_dir_path"/.java-version)
  fi

  major="${ver%%.*}"
  ver_="$(echo "$ver" | tr + _)"
  ver_url="$ver"
  ver_url="$(echo "$ver_url" | sed 's/+/%2B/')"

  bin_dir_path="$HOME"/.bin

  dir_name="jdk-${ver}${jre_postfix}"
  for dir_path in "$HOME"/.gradle/jdks/*/"$dir_name" "$bin_dir_path"/"$dir_name"
  # for dir_path in "$bin_dir_path"/"$dir_name"
  do
    JAVA_HOME="$dir_path"
    if test "$(uname -s)" = "Darwin"
    then
      JAVA_HOME="$JAVA_HOME/Contents/Home"
    fi
    if test -d "$JAVA_HOME"
    then
      echo "$JAVA_HOME"
      return
    fi
  done
  if ! test -d "$JAVA_HOME"
  then
    arc_ext=.tar.gz
    if is_windows
    then
      arc_ext=.zip
    fi
    mkdir -p "$bin_dir_path"
    temp_dir_path=$(mktemp -d)
    arc_path="$temp_dir_path"/temp"$arc_ext"
    curl --location -o "$arc_path" "https://github.com/adoptium/temurin${major}-binaries/releases/download/jdk-${ver_url}/OpenJDK${major}U-${postfix}_$(java_arch)_$(java_os)_hotspot_${ver_}${arc_ext}"
    ls -l "$arc_path" >&2
    (
      cd "$bin_dir_path" || exit 1
      if is_windows
      then
        unzip -q "$arc_path"
      else
        tar -xzvf "$arc_path"
      fi
    )
    rm -fr "$temp_dir_path"
  fi
  echo "$JAVA_HOME"
)

set_java_env() {
  JAVA_HOME="$(java_home)"
  export JAVA_HOME
  PATH="$JAVA_HOME"/bin:"$PATH"
  export PATH 
}

subcmd_java() { # Runs java command.
  set_java_env
  "$JAVA_HOME"/bin/java "$@"
}

subcmd_javac() { # Runs javac command.
  set_java_env
  "$JAVA_HOME"/bin/javac "$@"
}
