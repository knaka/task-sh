#!/bin/sh
set -o nounset -o errexit

# sh ./loop.sh &
( while true; do
  echo "Hello, world"
  sleep 1
done ) &

cleanup() {
  for job in $(jobs -p); do
    kill "$job"
  done
}

trap cleanup EXIT

sleep 5

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