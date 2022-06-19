LCF_SRC_DIR="${KIAUH_SRCDIR}/resources/lodge_custom"
SYS_UDEV_RULE_DIR=/etc/udev/rules.d

function udisk_auto_mount() {
    USB_RULES_SRC="${LCF_SRC_DIR}/10-usb.rules"
    USB_UDEV_SRC="${LCF_SRC_DIR}/usb_udev.sh"

    cp $USB_UDEV_SRC ${HOME}/scripts
    sudo cp $USB_RULES_SRC $SYS_UDEV_RULE_DIR
    fromdos ${HOME}/scripts/usb_udev.sh

    sudo sed -i 's/%user%/'''`whoami`'''/' $SYS_UDEV_RULE_DIR/10-usb.rules
    sudo sed -i 's/%user%/'''`whoami`'''/' ${HOME}/scripts/usb_udev.sh

    if [ `grep -c "PrivateMounts=yes" "/usr/lib/systemd/system/systemd-udevd.service"` -eq '1' ];then
        sudo sed -i 's/PrivateMounts=yes/PrivateMounts=no/' /usr/lib/systemd/system/systemd-udevd.service
    elif [ `grep -c "PrivateMounts=no" "/usr/lib/systemd/system/systemd-udevd.service"` -eq '0' ];then
        sudo bash -c 'echo "PrivateMounts=no" >> /usr/lib/systemd/system/systemd-udevd.service'
    fi

    if [ `grep -c "MountFlags=shared" "/usr/lib/systemd/system/systemd-udevd.service"` -ne '1' ];then
        sudo bash -c 'echo "MountFlags=shared" >> /usr/lib/systemd/system/systemd-udevd.service'
    fi

    sudo systemctl daemon-reload
    sudo service systemd-udevd --full-restart
}

function usb_camera_auto_play(){
    WEB_CAMERA_LAUNCH="${LCF_SRC_DIR}/web_camera.sh"
    SYNC_SRC="${LCF_SRC_DIR}/sync.sh"

    cp $SYNC_SRC ${HOME}/scripts
    cp $WEB_CAMERA_LAUNCH ${HOME}/scripts
    fromdos ${HOME}/scripts/sync.sh
    fromdos ${HOME}/scripts/web_camera.sh

    sudo sed -i 's/%user%/'''`whoami`'''/' ${HOME}/scripts/web_camera.sh
    sudo sed -i 's/%user%/'''`whoami`'''/' ${HOME}/scripts/sync.sh

    if ! crontab -l > conf; then
        if [ `grep -c "scripts/sync.sh" "conf"` -eq '0' ];then
            echo "*/1 * * * * /home/`whoami`/scripts/sync.sh" >> conf && crontab conf
        fi
    fi
    rm -f conf
}

function usb_device_mount() {
    if [ -d "${HOME}/mjpg-streamer" ]; then
        [ ! -d "${HOME}/scripts" ] && mkdir ${HOME}/scripts

        udisk_auto_mount
        usb_camera_auto_play

        print_confirm "enable mjpg_streamer complete!"
    else
        print_error "MJPG not installed!"
    fi
}

function fix_klipperscreen() {
    if [ -e "/etc/X11/Xwrapper.config" ]; then
        if [ `grep -c "allowed_users=anybody" "/etc/X11/Xwrapper.config"` -ne '1' ];then
            sudo bash -c 'echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config'
        fi
        if [ `grep -c "needs_root_rights=yes" "/etc/X11/Xwrapper.config"` -ne '1' ];then
            sudo bash -c 'echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config'
        fi

        print_confirm "KlipperScreen restoration complete!"
    else
        print_error "KlipperScreen not installed correctly!"
    fi
}

function klipper_lodge_repo() {
    if [ ! -e "${HOME}/kiauh/klipper_repos.txt" ]; then
        cp ${LCF_SRC_DIR}/lodge_repos.txt ${HOME}/kiauh/klipper_repos.txt
    else
        if [ `grep -c "https://github.com/EchoHeim/klipper,lodge" "${HOME}/kiauh/klipper_repos.txt"` -ne '1' ];then
            echo "https://github.com/EchoHeim/klipper,lodge" >> ${HOME}/kiauh/klipper_repos.txt
        fi
    fi
    print_confirm "lodge custom klipper added successfully!"
}

function config_klipper_cfgfile() {
    case "$1" in
        "skr3")
            cp ${KIAUH_SRCDIR}/resources/lodge_custom/skr-3/* ${KLIPPER_CONFIG} -f ;;
        "Hurakan") 
            cp ${KIAUH_SRCDIR}/resources/lodge_custom/Hurakan/* ${KLIPPER_CONFIG} -f ;;
        "stm32mp157") 
            cp ${KIAUH_SRCDIR}/resources/lodge_custom/stm32mp157/* ${KLIPPER_CONFIG} -f ;;
    esac

    [ $? == 0 ] && ok_msg "config_klipper_cfgfile OK"
}

