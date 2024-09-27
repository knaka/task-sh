#!/bin/bash
set -o nounset -o errexit -o pipefail

set_dir_sync_ignored "$(dirname "$0")"/gradle/wrapper
set_dir_sync_ignored "$(dirname "$0")"/.gradle
set_dir_sync_ignored "$(dirname "$0")"/app/build
set_dir_sync_ignored "$(dirname "$0")"/.kotlin

# set_file_sync_ignored "$(dirname "$0")"/gradlew
# set_file_sync_ignored "$(dirname "$0")"/gradlew.bat

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
    chmod +x "$GRADLE_HOME"/bin/gradle"$(exe_ext)"
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
  cross_exec "$GRADLE_HOME"/bin/gradle "$@"
}

subcmd_build() {
  subcmd_gradle build "$@"
}
