LCF_SRC_DIR="${SRCDIR}/kiauh/resources/lodge_custom"
SYS_UDEV_RULE_DIR=/etc/udev/rules.d

udisk_auto_mount() {
    USB_RULES_SRC="${LCF_SRC_DIR}/10-usb.rules"
    USB_UDEV_SRC="${LCF_SRC_DIR}/usb_udev.sh"

    cp $USB_UDEV_SRC ${HOME}/scripts
    sudo cp $USB_RULES_SRC $SYS_UDEV_RULE_DIR
    fromdos ${HOME}/scripts/usb_udev.sh

    sudo sed -i 's/%user%/'''`whoami`'''/' $SYS_UDEV_RULE_DIR/10-usb.rules
    sudo sed -i 's/%user%/'''`whoami`'''/' ${HOME}/scripts/usb_udev.sh

    if [ `grep -c "PrivateMounts=yes" "/usr/lib/systemd/system/systemd-udevd.service"` -ne '0' ];then
        sudo sed -i 's/PrivateMounts=yes/PrivateMounts=no/' /usr/lib/systemd/system/systemd-udevd.service
    elif [ `grep -c "PrivateMounts=no" "/usr/lib/systemd/system/systemd-udevd.service"` -ne '0' ];then
        echo "is exist"
    else
        sudo bash -c 'echo "PrivateMounts=no" >> /usr/lib/systemd/system/systemd-udevd.service'
    fi

    if [ `grep -c "MountFlags=shared" "/usr/lib/systemd/system/systemd-udevd.service"` -ne '0' ];then
        echo "is exist"
    else
        sudo bash -c 'echo "MountFlags=shared" >> /usr/lib/systemd/system/systemd-udevd.service'
    fi

    sudo systemctl daemon-reload
    sudo service systemd-udevd --full-restart
}

usb_camera_auto_play(){    
    WEB_CAMERA_LAUNCH="${LCF_SRC_DIR}/web_camera.sh"
    SYNC_SRC="${LCF_SRC_DIR}/sync.sh"

    if [ -d "${HOME}/mjpg-streamer" ]; then
        [ ! -d "${HOME}/scripts" ] && mkdir ${HOME}/scripts
        cp $SYNC_SRC ${HOME}/scripts
        cp $WEB_CAMERA_LAUNCH ${HOME}/scripts
        fromdos ${HOME}/scripts/sync.sh
        fromdos ${HOME}/scripts/web_camera.sh

        sudo sed -i 's/%user%/'''`whoami`'''/' ${HOME}/scripts/web_camera.sh
        sudo sed -i 's/%user%/'''`whoami`'''/' ${HOME}/scripts/sync.sh

        crontab -l > conf
        if [ `grep -c "scripts/sync.sh" "conf"` -ne '0' ];then
            echo "sync.sh is exist!"
        else
            echo "*/1 * * * * /home/`whoami`/scripts/sync.sh" >> conf && crontab conf && rm -f conf
        fi

        do_action_OK
    else
        deny_mjpg_action
    fi
}

usb_device_mount() {
    udisk_auto_mount
    usb_camera_auto_play
}
