# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_30f2815-false}" && return 0; sourced_30f2815=true

. ./task.sh
. ./sqlite3.lib.sh

# Convert CSV to SQLIte3 SQL.
subcmd_sqlite3__csv2sql() {
  local db_schema_file_path
  local csv_file_path
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (s|schema) db_schema_file_path="$OPTARG";;
      (c|csv) csv_file_path="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if test -z "${db_schema_file_path}" || test -z "${csv_file_path}"
  then
    echo "Usage: sqlite3:csv2sql --schema=path/to/schema.sql --csv=path/to/file.csv" >&2
    return 1
  fi
  local db_file_path
  db_file_path="$TEMP_DIR"/db.sqlite3
  local sql_file_path
  sql_file_path="${csv_file_path%.csv}.sql"
  # Load DB schema
  sqlite3 -- "$db_file_path" <"$db_schema_file_path"
  # Import the CSV
  sqlite3 -- "$db_file_path" \
    ".import --csv --skip 0 --schema main $csv_file_path ings"
  # Export resotre SQL. Removing unnecessary statements, converting multi-line SQL statements to single lines, preserving statement boundaries
  sqlite3 -- "$db_file_path" ".dump ings" \
  | awk '{ ORS = (/;$/ ? RS : " ") } 1' \
  | grep -v \
    -e '^BEGIN TRANSACTION;' \
    -e '^COMMIT;' \
    -e '^CREATE TABLE ' \
  >"$sql_file_path"
  echo "SQL file: $sql_file_path" >&2
}
