LCF_SRC_DIR="${KIAUH_SRCDIR}/resources/lodge_custom"

function udisk_auto_mount() {
    sudo cp ${LCF_SRC_DIR}/usb/usb_udev.sh /etc/scripts
    sudo cp ${LCF_SRC_DIR}/usb/15-udev.rules /etc/udev/rules.d

    sudo sed -i 's/%user%/'''`whoami`'''/' /etc/scripts/usb_udev.sh

    if [ `grep -c "PrivateMounts=yes" "/usr/lib/systemd/system/systemd-udevd.service"` -eq '1' ];then
        sudo sed -i 's/PrivateMounts=yes/PrivateMounts=no/' /usr/lib/systemd/system/systemd-udevd.service
    elif [ `grep -c "PrivateMounts=no" "/usr/lib/systemd/system/systemd-udevd.service"` -eq '0' ];then
        sudo bash -c 'echo "PrivateMounts=no" >> /usr/lib/systemd/system/systemd-udevd.service'
    fi

    if [ `grep -c "MountFlags=shared" "/usr/lib/systemd/system/systemd-udevd.service"` -ne '1' ];then
        sudo bash -c 'echo "MountFlags=shared" >> /usr/lib/systemd/system/systemd-udevd.service'
    fi

    sync
    sudo systemctl daemon-reload
    sudo service systemd-udevd --full-restart
}

function usb_camera_auto_play(){
    if [ -d "${HOME}/mjpg-streamer" ]; then
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
        print_confirm "enable mjpg_streamer complete!"
    else
        print_error "MJPG not installed!"
    fi
    sync
}


function fix_klipperscreen() {
    if [[ -e "/etc/X11/Xwrapper.config" && $(get_klipperscreen_status) == "Installed!" ]]; then
        
        # KlipperScreen display
        if [ `grep -c "allowed_users=anybody" "/etc/X11/Xwrapper.config"` -ne '1' ];then
            sudo bash -c 'echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config'
        fi
        if [ `grep -c "needs_root_rights=yes" "/etc/X11/Xwrapper.config"` -ne '1' ];then
            sudo bash -c 'echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config'
        fi

        # KlipperScreen USB-HID touch
        if [[ ! $(dpkg-query -f'${Status}' --show xserver-xorg-input-libinput 2>/dev/null) = *\ installed ]]; then
            status_msg "Installing xserver-xorg-input-libinput..."
            sudo apt install xserver-xorg-input-libinput -y
        fi
        if [[ ! -e "/usr/share/X11/xorg.conf.d/40-libinput.conf" ]]; then
            status_msg "Copy xserver input cfg file..."
            sudo mkdir -p /usr/share/X11/xorg.conf.d
            sudo cp ${LCF_SRC_DIR}/40-libinput.conf /usr/share/X11/xorg.conf.d/40-libinput.conf -fr
        fi

        print_confirm "KlipperScreen restoration complete!"
    else
        print_error "KlipperScreen not installed correctly!"
    fi
    sync
}

function klipper_lodge_repo() {
    if [ ! -e "${HOME}/kiauh/klipper_repos.txt" ]; then
        cp ${LCF_SRC_DIR}/lodge_repos.txt ${HOME}/kiauh/klipper_repos.txt
    else
        if [ `grep -c "https://github.com/EchoHeim/klipper,lodge" "${HOME}/kiauh/klipper_repos.txt"` -ne '1' ];then
            echo "https://github.com/EchoHeim/klipper,lodge" >> ${HOME}/kiauh/klipper_repos.txt
        fi
    fi
    sync
    print_confirm "lodge custom klipper added successfully!"
}

function mDNS_DependencyPackages() {
# Many people prefer to access their machines using the name.
# local addressing scheme available via mDNS (zeroconf, bonjour) instead of an IP address. 
# This is simple to enable on the hurakan but requires the installation of 
# the following packages which should be installed from the factory:

    sudo apt update

    sudo apt install avahi-daemon bind9-host geoip-database -y
    sudo apt install libavahi-common-data libavahi-common3 libavahi-core7 -y
    sudo apt install libdaemon0 libgeoip1 libnss-mdns libnss-mymachines -y

    sync
}

function config_klipper_cfgfile() {
    if [[ -d "${KLIPPER_CONFIG}" ]]; then
        case "$1" in
            "skr3")
                cp ${KIAUH_SRCDIR}/resources/lodge_custom/skr-3/* ${KLIPPER_CONFIG} -f 
                ;;
            "Hurakan")
                cp ${KIAUH_SRCDIR}/resources/lodge_custom/Hurakan/*.cfg ${KLIPPER_CONFIG} -f
                [[ ! -d ${KLIPPER_CONFIG}/.theme ]] && mkdir -p ${KLIPPER_CONFIG}/.theme
                cp ${KIAUH_SRCDIR}/resources/lodge_custom/Hurakan/theme/* ${KLIPPER_CONFIG}/.theme -f 
                ;;
            "stm32mp157")
                cp ${KIAUH_SRCDIR}/resources/lodge_custom/stm32mp157/* ${KLIPPER_CONFIG} -f 
                ;;
        esac
        sync
        ok_msg "config_klipper_cfgfile OK"
    else
        warn_msg "No config directory found! Skipping Configure ..."
    fi
}

function config_klipper_host_MCU() {
    if [[ -d "${HOME}/klipper" && $(get_klipper_status) != "Not installed!" && $(get_klipper_status) != "Incomplete!" ]]; then
        cd ~/klipper/
        sudo cp "./scripts/klipper-mcu-start.sh" /etc/init.d/klipper_mcu
        sudo update-rc.d klipper_mcu defaults

        cp ${KIAUH_SRCDIR}/resources/lodge_custom/.config ~/klipper/
        make

        sudo service klipper stop
        make flash
        sudo service klipper start

        sudo usermod -a -G tty `whoami`

        ok_msg "config_klipper_host_MCU OK"
    else
        print_error "Klipper not installed correctly!"
    fi
    sync
}

function config_shaper_auto_calibration() {
    status_msg "Installing dependency packages..."

    sudo apt update
    sudo apt install python3-numpy python3-matplotlib libatlas-base-dev -y

    status_msg "Installing NumPy..."

    ~/klippy-env/bin/pip install -v numpy

    sync
    ok_msg "config_shaper_auto_calibration OK"
}
