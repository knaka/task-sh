#!/bin/sh
set -o nounset -o errexit

set_dir_sync_ignored "$(dirname "$0")"/gradle/wrapper
set_dir_sync_ignored "$(dirname "$0")"/.gradle
set_dir_sync_ignored "$(dirname "$0")"/app/build
set_dir_sync_ignored "$(dirname "$0")"/.kotlin

set_file_sync_ignored "$(dirname "$0")"/gradlew
set_file_sync_ignored "$(dirname "$0")"/gradlew.bat

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
    MINGW* | CYGWIN* | MSYS*) echo "windows" ;;
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

  cd "$(dirname "$0")"
  if test -r .java-version
  then
    ver=$(cat .java-version)
  fi

  major="${ver%%.*}"
  ver_="$(echo "$ver" | tr + _)"
  ver_url="$ver"
  ver_url="$(echo "$ver_url" | sed 's/+/%2B/')"

  bin_dir_path="$HOME"/.bin

  dir_name="jdk-${ver}${jre_postfix}"
  for dir_path in "$HOME"/.gradle/jdks/*/"$dir_name" "$bin_dir_path"/"$dir_name"
  do
    JAVA_HOME="$dir_path/Contents/Home"
    if test -d "$JAVA_HOME"
    then
      echo "$JAVA_HOME"
      return
    fi
  done
  if ! test -d "$JAVA_HOME"
  then
    mkdir -p "$bin_dir_path"
    curl --location -o - "https://github.com/adoptium/temurin${major}-binaries/releases/download/jdk-${ver_url}/OpenJDK${major}U-${postfix}_$(java_arch)_$(java_os)_hotspot_${ver_}.tar.gz" |
      tar -xz -C "$bin_dir_path"
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
  exec "$JAVA_HOME"/bin/java "$@"
}

subcmd_javac() { # Runs javac command.
  set_java_env
  exec "$JAVA_HOME"/bin/javac "$@"
}

gradle_home() (
  # Gradle | Releases https://gradle.org/releases/
  ver="8.10"

  cd "$(dirname "$0")"
  bin_dir_path="$HOME/.bin"

  GRADLE_HOME=${GRADLE_HOME:-$bin_dir_path/gradle-${ver}}
  if ! test -d "$GRADLE_HOME"
  then
    mkdir -p "$bin_dir_path"
    temp_dir_path=$(mktemp -d)
    zip_path="$temp_dir_path"/temp.zip
    curl --location -o "$zip_path" "https://services.gradle.org/distributions/gradle-${ver}-bin.zip"
    (
      cd "$bin_dir_path" || exit 1
      unzip -q "$zip_path"
    )
    chmod +x "$GRADLE_HOME/bin/gradle"
  fi

  echo "$GRADLE_HOME"
)

set_gradle_env() {
  set_java_env
  GRADLE_HOME="$(gradle_home)"
  export GRADLE_HOME
  PATH="$GRADLE_HOME"/bin:"$PATH"
  export PATH
}

subcmd_gradle() { # Runs gradle command.
  set_gradle_env
  exec "$GRADLE_HOME"/bin/gradle"$(exe_ext)" "$@"
}

subcmd_run() {
  sh "$(dirname "$0")"/task.sh java -cp ./app/build/libs/app.jar org.example.AppKt
}
