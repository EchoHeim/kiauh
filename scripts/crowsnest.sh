#!/usr/bin/env bash

#=======================================================================#
# Copyright (C) 2020 - 2022 Dominik Willner <shilong.native@gmail.com>  #
#                                                                       #
# This file is part of KIAUH - Klipper Installation And Update Helper   #
# https://github.com/EchoHeim/kiauh                                     #
#                                                                       #
# This file may be distributed under the terms of the GNU GPLv3 license #
#=======================================================================#

set -e

#=================================================#
#=============== INSTALL Crowsnest ===============#
#=================================================#

function install_Crowsnest() {
  local repo="https://github.com/mainsail-crew/crowsnest.git"

  ### return early if webcamd.service already exists
  if [[ -d "${HOME}/crowsnest" ]]; then
    print_error "Looks like Crowsnest is already installed!\n Please remove it first before you try to re-install it!"
    return
  fi

  status_msg "Initializing Crowsnest ..."

  ### check and install dependencies if missing
#   local dep=(git cmake build-essential imagemagick libv4l-dev ffmpeg)
#   if apt-cache search libjpeg62-turbo-dev | grep -Eq "^libjpeg62-turbo-dev "; then
#     dep+=(libjpeg62-turbo-dev)
#   elif apt-cache search libjpeg8-dev | grep -Eq "^libjpeg8-dev "; then
#     dep+=(libjpeg8-dev)
#   fi

#   dependency_check "${dep[@]}"

  ### step 1: clone Crowsnest
  status_msg "Cloning Crowsnest from ${repo} ..."
  [[ -d "${HOME}/crowsnest" ]] && rm -rf "${HOME}/crowsnest"

  cd "${HOME}" || exit 1
  if ! git clone --depth 1 "${repo}" ; then
    print_error "Cloning Crowsnest from\n ${repo}\n failed!"
    exit 1
  fi
  ok_msg "Cloning complete!"

  ### step 2: compiling Crowsnest
  status_msg "Compiling Crowsnest ..."
  cd "${HOME}/crowsnest"
  if ! make install; then
    print_error "Compiling Crowsnest failed!"
    exit 1
  fi
  ok_msg "Compiling complete!"

  ### step 3: check if user is in group "video"
  local usergroup_changed="false"
  if ! groups "${USER}" | grep -q "video"; then
    status_msg "Adding user '${USER}' to group 'video' ..."
    sudo usermod -a -G video "${USER}" && ok_msg "Done!"
    usergroup_changed="true"
  fi

  ### print webcam ip adress/url
  local ip
  ip=$(hostname -I | cut -d" " -f1)
  local cam_url="http://${ip}:8080/?action=stream"
  local cam_url_alt="http://${ip}/webcam/?action=stream"
  echo -e " ${cyan}● Webcam URL:${white} ${cam_url}"
  echo -e " ${cyan}● Webcam URL:${white} ${cam_url_alt}"
  echo
}

#=================================================#
#================ REMOVE Crowsnest ===============#
#=================================================#

function remove_Crowsnest() {
    cd ~/crowsnest
    make uninstall
    [[ -d "${HOME}/crowsnest" ]] && rm -rf "${HOME}/crowsnest"
    print_confirm "Crowsnest successfully removed!"
}