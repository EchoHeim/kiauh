#!/bin/bash

MNT_PATH=/home/%user%/gcode_files/         # mount menu
DEV_PRE=$1              
DEV_NAME=$2       

if [ $ACTION == "add" ]; then
    sudo mkdir -p $MNT_PATH$DEV_PRE-$DEV_NAME
    sudo mount /dev/$DEV_NAME $MNT_PATH$DEV_PRE-$DEV_NAME
    if [[ $? -ne 0 ]]; then
        sudo rmdir $MNT_PATH$DEV_PRE-$DEV_NAME
    fi
    if [[ $DEV_NAME == "video0" ]]; then
        source /home/%user%/scripts/web_camera.sh
    fi
elif [ $ACTION == "remove" ]; then
    if [[ -e  $MNT_PATH$DEV_PRE-$DEV_NAME ]] ; then
        sudo umount $MNT_PATH$DEV_PRE-$DEV_NAME
        /usr/bin/rmdir  $MNT_PATH$DEV_PRE-$DEV_NAME
    fi
    if [[ $DEV_NAME == "video0" ]]; then
        sudo kill -9 $(pidof mjpg_streamer)
    fi
fi

exit 0
