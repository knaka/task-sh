#!/bin/sh
set -o nounset -o errexit

test "${guard_73cfd45+set}" = set && return 0; guard_73cfd45=x

# ⁠ - ワードジョイナー, U+2060, 一般句読点 (◕‿◕) SYMBL https://symbl.cc/jp/2060/
printf "⁠" 
