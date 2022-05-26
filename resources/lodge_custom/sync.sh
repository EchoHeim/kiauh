#!/bin/bash

for((i=1;i<=20;i++));do
	sync
    if [ -e "/dev/video0" ];then
        /home/%user%/scripts/web_camera.sh
    fi
    echo "sync"
	sleep 3
done
