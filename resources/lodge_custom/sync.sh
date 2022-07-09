#!/bin/bash

VIDEO="no"

for((i=1;i<=20;i++));do
    sync
    echo "sync"
    if [ -e "/dev/video1" ];then
        cd /home/biqu/mjpg-streamer
        [[ "$VIDEO" == "no" ]] && ./mjpg_streamer -i "./input_uvc.so -d /dev/video1 -r 320x240 -f 15 -y" -o "./output_http.so -w ./www" &
        VIDEO="yes"
    else
        sudo kill -9 $(pidof mjpg_streamer)
        VIDEO="no"
    fi
    sleep 3
done
