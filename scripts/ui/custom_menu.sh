function detect_pack() {
    for pkg in "${dep_pkg[@]}"
    do
        if [[ ! $(dpkg-query -f'${Status}' --show $pkg 2>/dev/null) = *\ installed ]]; then
            # echo "$pkg Uninstalled!"
            inst_pkg+=($pkg)
        fi
    done
}

function WhetherInstall(){
    if [ "${#inst_pkg[@]}" != "0" ]; then
        echo -e "\nChecking for the following dependencies:\n"
        for pkg in "${inst_pkg[@]}"
        do
            echo -e "${cyan}● $pkg ${default}"
        done
        echo -e "\n"

        read -p "${cyan}###### Installing the above packages? (Y/n):${default} " yn
        case "$yn" in
            Y|y|Yes|yes|"")
                echo
                sudo apt-get update --allow-releaseinfo-change && sudo apt install ${inst_pkg[@]} -y
                echo -e "\nDependencies installed!"
                ;;

            N|n|No|no)
                exit 0;;
        esac
    fi
    unset inst_pkg
}

#-----------------------------------------------------------------------------------

function custom_function_ui(){
    top_border
    echo -e "|     ${green}~~~~~~~~~ [ Custom Function Menu ] ~~~~~~~~~~${white}     | "
    hr
    echo -e "|                          |                            |"
    echo -e "| Function Fix:            | Add-on Features:           |"
    echo -e "|  1) [fix KlipperScreen]  |  3) [Host MCU]             |"
    echo -e "|  2) [klipper cfg]        |  4) [Measuring Resonances] |"
    echo -e "|                          |                            |"
    hr
    echo -e "|  c) Custom klipper with lodge                         |"
    back_footer
}

function custom_function_menu(){
    dep_pkg=(git tofrodos)
    detect_pack
    WhetherInstall
    unset dep_pkg

    do_action "" "custom_function_ui"
    while true; do
        read -p "${cyan}Perform action:${white} " action; echo
        case "$action" in
            C|c)
                do_action "klipper_lodge_repo" "custom_function_ui";;
            1) 
                do_action "fix_klipperscreen" "custom_function_ui";;
            2) 
                do_action "klipper_cfg_menu" "";;
            3) 
                do_action "config_klipper_host_MCU" "custom_function_ui";;
            4) 
                do_action "config_shaper_auto_calibration" "custom_function_ui";;
            B|b)
                clear; main_menu; break;;
            *)
                deny_action "custom_function_ui";;
        esac
    done
    custom_function_ui
}

#-----------------------------------------------------------------------------------

function klipper_cfg_ui(){
    top_border
    echo -e "|     ${green}~~~~~~~~~ [ klipper_cfg_files Menu ] ~~~~~~~~${white}     | "
    hr
    echo -e "|  1) bigtree-skr3           |  3) stm32mp157           |"
    echo -e "|                            |                          |"
    echo -e "|  2) Hurakan                |                          |"

    back_footer
}

function klipper_cfg_menu(){
    dep_pkg=(git tofrodos)
    detect_pack
    WhetherInstall
    unset dep_pkg

    do_action "" "klipper_cfg_ui"
    while true; do
        read -p "${cyan}Perform action:${white} " action; echo
        case "$action" in
            1)
                do_action "config_klipper_cfgfile skr3" "klipper_cfg_ui";;
            2) 
                do_action "config_klipper_cfgfile Hurakan" "klipper_cfg_ui";;
            3) 
                do_action "config_klipper_cfgfile stm32mp157" "klipper_cfg_ui";;
            B|b)
                clear; custom_function_menu; break;;
            *)
                deny_action "klipper_cfg_ui";;
        esac
    done
    klipper_cfg_ui
}
