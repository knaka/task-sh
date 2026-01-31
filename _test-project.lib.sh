# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_15029b0-false}" && return 0; sourced_15029b0=true

. ./_assert.lib.sh
. ./task.sh

is_ci() {
  test "${CI+set}" = set
}

is_ci_macos() {
  is_ci && is_macos
}

toupper_4c7e44e() {
  printf "%s" "$1" | tr '[:lower:]' '[:upper:]'
}

tolower_542075d() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

test_abs2rel() {
  base="$TEMP_DIR"/foo/bar
  target="$TEMP_DIR"/foo/baz/qux.txt
  assert_eq "$(abs2rel "$target" "$base")" "../baz/qux.txt"

  base2="$TEMP_DIR"/foo/quux/quuux
  mkdir -p "$base2"
  cd "$base2"
  assert_eq "$(abs2rel "$target")" "../../baz/qux.txt"
}

test_version_comparison() {
  assert_true version_gt 1.0 0.9
  assert_true version_gt 1.1 1.0
  assert_true version_gt 1.1 1.0.9
  assert_true version_gt 1.1.1 1.1
  assert_true version_gt 1.1.1 1.1.0
  assert_true version_gt 1.1.1 1.1.1-alpha1
  assert_true version_gt v1.5.0-patch v1.5.0
  assert_true version_gt go1.23.2 go1.20.0
  assert_false version_gt 1.0 1.0
  assert_true version_ge 1.0 1.0

  assert_eq "v1,v1.4.3,v1.5.0," "$(IFS=, ifsv_sort "v1.5.0,v1,v1.4.3," sort_version)"
  assert_eq "v1.5.0,v1.4.3,v1," "$(IFS=, ifsv_sort "v1.5.0,v1,v1.4.3," sort_version -r)"

  cat <<EOF > "$TEMP_DIR"/versions.txt
v1.4.0-alpha
v1.4.0-alpha1
v1.4.0-beta
v1.4.0-patch
v1.4.0-patch2
v1.4.0-patch9
v1.4.0-patch10
v1.4.0-rc1
v1.4.0
v1.5
v1.4
v1
v1.5.0-alpha
v1.5.0-alpha2
v1.5.0-alpha1
v1.5.0-beta
v1.5.0-patch
v1.5.0-patch1
v1.5.0-beta2
v1.5.0
EOF
  cat <<EOF > "$TEMP_DIR"/expected.txt
v1
v1.4
v1.4.0-alpha
v1.4.0-alpha1
v1.4.0-beta
v1.4.0-rc1
v1.4.0
v1.4.0-patch
v1.4.0-patch2
v1.4.0-patch9
v1.4.0-patch10
v1.5
v1.5.0-alpha
v1.5.0-alpha1
v1.5.0-alpha2
v1.5.0-beta
v1.5.0-beta2
v1.5.0
v1.5.0-patch
v1.5.0-patch1
EOF
  sort_version <"$TEMP_DIR"/versions.txt >"$TEMP_DIR"/actual.txt
  assert_eq "$(cat "$TEMP_DIR"/expected.txt)" "$(cat "$TEMP_DIR"/actual.txt)"
}

test_menu_item() {
  assert_match ".+S.+ave" "$(menu_item "&Save")"
  assert_match "E.+x.+it" "$(menu_item "E&xit")"
  assert_match "Save & E.+x.+it" "$(menu_item "Save && E&xit")"
  assert_match "   Hello .+I.+ am" "$(menu_item "   Hello &I am")"
  assert_eq "" "$(menu_item "")"
  assert_eq "Exit" "$(menu_item "Exit")"
  # shellcheck disable=SC2016
  assert_match '.+A.+dd \$100' "$(menu_item '&Add $100')"
}

test_field() {
  assert_eq "foo" "$(echo "foo bar baz" | field 1)"
  assert_eq "bar" "$(echo "   foo      bar   baz  " | field 2)"
  assert_eq "baz" "$(printf "foo bar\nbaz qux\n" | field 3)"
}

test_split() {
  assert_eq "foo,bar,baz" "$(echo "foo, bar,  baz" | sed -E -e "s/, *"/,/g)"
  assert_eq "foo${us}bar${us}baz" "$(echo "foo, bar,  baz" | sed -E -e "s/, */${us}/g")"
}

# Parse with sed(1) and process the text.
test_sed_usv() {
  input_path="$TEMP_DIR"/input.txt
  cat <<'EOF' >"$input_path"
foo bar baz
other lines
123 456 789

hello world
hoge fuga hare
012 345 678 900
EOF
  output_path="$TEMP_DIR"/output.txt
  sed -E \
    -e "s/^([[:alpha:]]{3}) ([[:alpha:]]{3}) ([[:alpha:]]{3})$/case1${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:alpha:]]{4}) ([[:alpha:]]{4}) ([[:alpha:]]{4})$/case2${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:digit:]]{3}) ([[:digit:]]{3}) ([[:digit:]]{3})$/case3${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^(.*)$/nop${us}\1${us}/" <"$input_path" \
  | while IFS= read -r line
    do
      IFS="$us"
      # shellcheck disable=SC2086
      set -- $line
      unset IFS
      op="$1"
      shift
      case "$op" in
        (case1)
          echo "a: $1 $2 $3"
          ;;
        (case2)
          echo "b: $1 $2 $3"
          ;;
        (case3)
          echo "c: $1 $2 $3"
          ;;
        (nop)
          echo "z: $1"
          ;;
        (*)
          echo "Unhandled operation: $op" >&2
          ;;
      esac  
    done \
  >"$output_path"
  
  expected_path="$TEMP_DIR"/expected.txt
  cat <<'EOF' >"$expected_path"
a: foo bar baz
z: other lines
c: 123 456 789
z: 
z: hello world
b: hoge fuga hare
z: 012 345 678 900
EOF

  assert_eq "$(shasum "$expected_path" | field 1)" "$(shasum "$output_path" | field 1)"
}

# Parse with sed(1) and execute the commands.
test_sed_usv_global() {
  input_path="$TEMP_DIR"/input.txt
  cat <<'EOF' >"$input_path"
foo toupper(bar) baz toupper(qux) HOGE tolower(FUGA)
other lines
EOF
  output_path="$TEMP_DIR"/output.txt
  sed -E \
    -e "s/${lwb}toupper${rwb}\(([[:alpha:]]+)\)/${is1}toupper_4c7e44e${is2}\1${is1}/g" \
    -e "s/${lwb}tolower${rwb}\(([[:alpha:]]+)\)/${is1}tolower_542075d${is2}\1${is1}/g" \
    -e "s/^(.*${is1}[[:alnum:]_]+${is2}.*)$/call${is1}\1${is1}/" -e t \
    -e "s/^(.*)$/nop${is1}\1${is1}/" <"$input_path" \
  | while IFS= read -r line
    do
      IFS="$is1"
      # shellcheck disable=SC2086
      set -- $line
      unset IFS
      op="$1"
      shift
      case "$op" in
        (call)
          for arg in "$@"
          do 
            case "$arg" in
              (*${is2}*)
                echo "$arg" | (
                  IFS="$is2" read -r cmd param
                  "$cmd" "$param"
                )
                ;;
              (*)
                printf "%s" "$arg"
                ;;
            esac
          done
          echo
          ;;
        (nop)
          echo "$1"
          ;;
        (*)
          echo "Unhandled operation: $op" >&2
          ;;
      esac
    done \
  >"$output_path"
  # cat "$output_path" >&2
  expected_path="$TEMP_DIR"/expected.txt
  cat <<'EOF' >"$expected_path"
foo BAR baz QUX HOGE fuga
other lines
EOF
  assert_eq "$(shasum "$expected_path" | field 1)" "$(shasum "$output_path" | field 1)"
}

test_extra() {
  skip_unless_full

  echo "Executed extra test." >&2
}

test_not_existing_task() {
  assert_false invoke ./task not_existing_task
  invoke ./task --ignore-missing not_existing_task 2>&1 | grep "Unknown task"
  invoke ./task --skip-missing not_existing_task
}

test_dumper() {
  # Busybox Awk does not support --version option.
  # awk --version 2>&1
  result="$(echo hello | hex_dump | hex_restore)"
  assert_eq "hello" "$result"
  result="$(echo hello2 | oct_dump | oct_restore)"
  assert_eq "hello2" "$result"

  result="$(oct_restore "$(oct_dump "hello3")")"
  assert_eq "hello3" "$result"
}

# test_killing() {
#   skip_unless_full
#   invoke ./task killng_test
# }

# The path to the shell executable which is running the script.
shell_path() {
  begin_memoize d57754a "$@" || return 0

  if test "${BASH+set}" = set
  then
    echo "$BASH"
  elif is_windows && test "${SHELL+set}" = set && test "$SHELL" = "/bin/sh" && "$SHELL" --help 2>&1 | grep -q "BusyBox"
  then
    echo "$SHELL"
  else
    local path=
    if test -e /proc/$$/exe
    then
      path="$(realpath /proc/$$/exe)" || return 1
    else
      path="$(realpath "$(ps -p $$ -o comm=)")" || return 1
    fi
    echo "$path"
  fi

  end_memoize
}

test_shell() {
  if is_macos
  then
    assert_eq "/bin/dash" "$(shell_path)"
  elif is_windows
  then
    assert_eq "/bin/sh" "$(shell_path)"
  elif is_linux
  then
    assert_true test "/bin/dash" = "$(shell_path)" -o "/bin/ash" = "$(shell_path)" -o "/bin/bash" = "$(shell_path)"
  else
    echo "Unsupported platform." >&2
    return 1
  fi
}

test_newer() {
  local older current future

  older="$TEMP_DIR"/older.txt
  current="$TEMP_DIR"/current.txt
  future="$TEMP_DIR"/future.txt

  touch -t 202101010000 "$older"  
  touch -t 202101020000 "$current"
  touch -t 202101030000 "$future" 

  assert_true newer "$current" "$future" --than "$older"
  assert_false newer "$current" "$older" --than "$future"
}

_test_dir_stack() {
  cd "$PROJECT_DIR"
  
  push_dir ./py
  assert_eq "$PROJECT_DIR/py" "$PWD"
  assert_eq "$psv_dirs_4c15d80" "$PROJECT_DIR|"
  pop_dir
  assert_eq "$PROJECT_DIR" "$PWD"
  assert_eq "$psv_dirs_4c15d80" ""

  push_dir ./go
  assert_eq "$psv_dirs_4c15d80" "$PROJECT_DIR|"
  push_dir ../sh
  assert_eq "$psv_dirs_4c15d80" "$PROJECT_DIR/go|$PROJECT_DIR|"
  assert_eq "$PROJECT_DIR/sh" "$PWD"
  pop_dir
  pop_dir
}

test_is_dir_empty() {
  local dir_path="$TEMP_DIR"/17f146e

  assert_false is_dir_empty "$dir_path"

  mkdir -p "$dir_path"
  assert_true is_dir_empty "$dir_path"

  touch "$dir_path"/file
  assert_false is_dir_empty "$dir_path"  
}

test_fifo() {
  if is_windows
  then
    :
  elif is_linux || is_macos
  then
    local fifo_path="$TEMP_DIR"/fifo
    mkfifo "$fifo_path"
    (
      for i in 1 2 3
      do
        sleep 0.1
        printf "hello%d" "$i"
      done
    ) >"$fifo_path" 2>&1 &
    local output_path="$TEMP_DIR"/output
    cat "$fifo_path" >"$output_path"
    assert_eq "$(cat "$output_path")" "hello1hello2hello3"
  else
    echo "Unexpected platform." >&2
    return 1
  fi
}

time_wasting_task() {
  echo foo "$@"
}

test_memoize() {
  # Just test those works, not the result.
  local result
  result="$(memoize time_wasting_task hoge fuga)"
  assert_eq "foo hoge fuga" "$result"
  result="$(memoize time_wasting_task hoge fuga)"
  assert_eq "foo hoge fuga" "$result"
}

test_task_sh_help() {
  invoke ./task | grep -q 'Run curl'
}

test_escape_sequence() {
  # Color
  assert_eq "foobarbaz" "$(printf "foo\033[01mbar\033[00mbaz" | strip_escape_sequences)"
  # Cursor move
  assert_eq "$(printf "hoge\nfuga\nhare\n")" "$(printf "hoge\n\033[1Afuga\n\033[1Ahare\n" | strip_escape_sequences)"
}

test_resubst() {
  local expected="$TEMP_DIR/1f261a6"
  cat <<EOF >"$expected"
hoge FOO fuga
hare BAR hore
EOF
  local actual="$TEMP_DIR/fde683d"
  resubst \
    foo FOO \
    bar BAR \
  <<EOF >"$actual"
hoge foo fuga
hare bar hore
EOF
  assert_eq "$(sha256sum "$expected" | field 1)" "$(sha256sum "$actual" | field 1)"
}

xc640743=0

called_only_once() {
  first_call ee68f48 || return 0
  xc640743=$((xc640743 + 1))
}

test_called_only_once() {
  assert_eq 0 "$xc640743"
  called_only_once
  assert_eq 1 "$xc640743"
  called_only_once
  assert_eq 1 "$xc640743"
}

. ./goyacc.lib.sh

test_go_install() {
  skip_unless_full
  echo "$PATH" | grep -q -v "goyacc@"
  goyacc --setup-path-only
  echo "$PATH" | grep -q "goyacc@"
}

