#!/bin/bash

cd ~
[[ -f .bash_history ]] && rm -rf .bash_history

history -c
history -w
