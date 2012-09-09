#!/bin/sh
#
# raspberry pi 音楽再生サンプル
# rootユーザでのみ動作確認
#
# 使い方:
# 0. gpio1 にスイッチを接続
# 1. 第一引数にmp3を指定して起動
#    sudo ./play.sh filename.mp3
# 2. スイッチを押すと再生/停止
#
# CreativeCommons音源サンプル: http://www.lastfm.jp/music/+free-music-downloads/creative+commons

# raspberry pi gpio 設定
echo "1" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio1/direction 

# init
switch_pre_status=1

# ファイル名
filename=$1
if [ ! -f "${filename}" ]; then
  echo "Invalid file" 1>&2
  exit 1
fi

while :;
do
  switch_current_status=$(cat /sys/class/gpio/gpio1/value)

  # on => off を検出
  if [ $switch_pre_status -eq 0 ] && [ $switch_pre_status -ne $switch_current_status ]; then 
    echo "DEBUG: pushed"
    if [ -z $sound_process_pid ]; then
      # サウンド再生
      mpg123 $filename > /dev/null 2>&1 &
      sound_process_pid=$(echo $!)
      echo "DEBUG: pid=${sound_process_pid}"
      sleep 1
    else
      # サウンド停止
      kill $sound_process_pid
      echo "DEBUG: kill ${sound_process_pid}"
    fi
  fi

  if [ ! -z "$sound_process_pid" ]; then
    ps ${sound_process_pid} > /dev/null 2>&1
    if [ $? -eq "1" ]; then
      # サウンドPIDが存在しなくなったら
      echo "DEBUG: stopped"
      sound_process_pid=""
    fi
  fi

  switch_pre_status=$switch_current_status
  # sleep 1
done
  
