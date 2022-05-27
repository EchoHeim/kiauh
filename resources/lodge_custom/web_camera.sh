#!/bin/bash

# open web_camera server

cd /home/%user%/mjpg-streamer

./mjpg_streamer -i "./input_uvc.so -d /dev/video0" -o "./output_http.so -w ./www" &
