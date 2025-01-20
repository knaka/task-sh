#!/bin/sh
set -o nounset -o errexit

# shellcheck disable=SC2317
cleanup() {
  while true
  do
    # On some systems, `kill` cannot detect the process if `jobs` is not called before it.
    jobs > /dev/null 2>&1
    if ! kill %% > /dev/null 2>&1
    then
      break
    fi
  done
}

trap cleanup EXIT

./loop.cmd &
./loop.cmd &
./loop.cmd &
./loop.cmd &
./loop.cmd &
./loop.cmd &
./loop.cmd &

while true
do
  printf 'Enter "exit" to exit: '
  read -r input
  if [ "$input" = "exit" ]
  then
    break
  fi
done

# jobs

# kill %%
# sleep 1

# jobs

# kill %%
# sleep 1
# jobs

# :loop
# if test -n "$(jobs)"
# then
#   echo "killing"
#   kill %%
#   sleep 1
#   jobs
#   goto loop
# fi

# while test -n "$(jobs)"
# while true
# do
#   jobs > /dev/null 2>&1
#   # jobs
#   if ! kill %% > /dev/null 2>&1
#   then
#     break
#   fi
#   # sleep 1
#   # jobs > /dev/null 2>&1
# done

exit 0

# ./loop.cmd &
# ./loop.cmd &

# cleanup() {
#   while kill %%
#   do
#     echo "killed"
#   done
# }

# trap cleanup EXIT

sleep 5

# kill %1
# for job in $(jobs -p); do
#   kill "$job"
# done

# pkill -P $$

kill %%
echo 85ac941 $?

kill %%
echo 85ac941 $?

kill %%
echo 85ac941 $?

kill %%
echo 85ac941 $?

echo "done"

# ./loop.cmd &
# echo $! > /tmp/process1.pid
# cat /tmp/process1.pid

# sleep 5
# taskkill /f /pid "$(cat /tmp/process1.pid)"
# # kill -9 "$(cat /tmp/process1.pid)"

# echo "Done"


# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world
# エラー: 入力のリダイレクトはサポートされていません。今すぐプロセスを終了します。
# Hello, world

# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediately.
# Hello, world
# ERROR: Input redirection is not supported, exiting the process immediat   