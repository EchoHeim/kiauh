function custom_function_ui(){
    top_border
    echo -e "|     ${green}~~~~~~~~~ [ Custom Function Menu ] ~~~~~~~~~~${white}     | "
    hr
    echo -e "|  0) Custom klipper with lodge                         |"
    echo -e "|                                                       |"
    echo -e "|  1) usb device auto mount                             |"
    echo -e "|                                                       |"
    echo -e "|  2) fix KlipperScreen                                 |"

    back_footer
}

function custom_function_menu(){
  do_action "" "custom_function_ui"
  while true; do
    read -p "${cyan}Perform action:${white} " action; echo
    case "$action" in
        0)
            do_action "klipper_lodge_repo" "custom_function_ui";;
        1) 
            do_action "usb_device_mount" "custom_function_ui";;
        2) 
            do_action "fix_klipperscreen" "custom_function_ui";;
        B|b)
            clear; main_menu; break;;
        *)
            deny_action "custom_function_ui";;
    esac
  done
  custom_function_ui
}
