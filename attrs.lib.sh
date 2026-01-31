# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_3299e88-}" = true && return 0; sourced_3299e88=true

. ./task.sh

# Set the extra attributes of the file/directory.
set_path_attr() {
  local path="$1"
  local attribute="$2"
  local value="$3"
  if which xattr > /dev/null 2>&1
  then
    xattr -w "$attribute" "$value" "$path"
  elif which PowerShell > /dev/null 2>&1
  then
    # Run in the background because it takes much time to run.
    PowerShell -Command "Set-Content -Path '$path' -Stream '$attribute' -Value '$value'" &
  elif which attr > /dev/null 2>&1
  then
    attr -s "$attribute" -V "$value" "$path" >/dev/null 2>&1
  else
    echo "No command to set attribute: $attribute" >&2
    # exit 1
  fi
}

readonly psv_file_sharing_ignorance_attributes="com.dropbox.ignored|com.apple.fileprovider.ignore#P|"

# Set the file/directory to be ignored by file sharing such as Dropbox.
set_sync_ignored() {
  local path
  for path in "$@"
  do
    if ! test -e "$path"
    then
      continue
    fi
    local IFS='|'
    for file_sharing_ignorance_attribute in $psv_file_sharing_ignorance_attributes
    do
      set_path_attr "$path" "$file_sharing_ignorance_attribute" 1
    done
  done
}

# Create a directory and set it to be ignored by file sharing such as Dropbox.
mkdir_sync_ignored() {
  local path
  for path in "$@"
  do
    if test -d "$path"
    then
      continue
    fi
    mkdir -p "$path"
    local IFS='|'
    for attribute in $psv_file_sharing_ignorance_attributes
    do
      set_path_attr "$path" "$attribute" 1
    done
  done
}

# Set the file/directory to be ignored by file sharing such as Dropbox.
force_sync_ignored() {
  local path
  for path in "$@"
  do
    local IFS='|'
    for attribute in $psv_file_sharing_ignorance_attributes
    do
      set_path_attr "$path" "$attribute" 1
    done
  done
}
