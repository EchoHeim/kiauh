#!/bin/bash

rm -rf ~/kiauh*

sync

echo -e "\n>>>>    History cmd has been cleared.      <<<<"
echo -e ">>>> you can power off the system to pack! <<<<"

history -c
history -w
