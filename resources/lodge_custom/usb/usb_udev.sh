#!/bin/bash

MNT_PATH=/home/%user%/gcode_files/         # mount folder
DEV_PRE=$1
DEV_NAME=$2

if [ $DEV_PRE == "video" ]; then
    if [ $ACTION == "add" ]; then
        if [[ ! `sudo systemctl status crowsnest.service` =~ "active (running)" ]]
        then
            sudo systemctl restart crowsnest.service
            sync
            sleep 4
        fi
    fi
fi

if [ $ACTION == "add" ]; then
    sudo mkdir -p $MNT_PATH$DEV_PRE-$DEV_NAME
    sudo mount /dev/$DEV_NAME $MNT_PATH$DEV_PRE-$DEV_NAME
    if [[ $? -ne 0 ]]; then
        sudo rmdir $MNT_PATH$DEV_PRE-$DEV_NAME
    fi
elif [ $ACTION == "remove" ]; then
    if [[ -e  $MNT_PATH$DEV_PRE-$DEV_NAME ]] ; then
        sudo umount $MNT_PATH$DEV_PRE-$DEV_NAME
        /usr/bin/rmdir  $MNT_PATH$DEV_PRE-$DEV_NAME
    fi
fi

exit 0
