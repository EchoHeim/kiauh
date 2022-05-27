custom_function_ui(){
    top_border
    echo -e "|     ${green}~~~~~~~~~~ [ Custom Function Menu ] ~~~~~~~~~~${default}    | "
    hr
    echo -e "|  1) usb device auto mount                             |"
        
    back_footer
}

custom_function_menu(){
  do_action "" "custom_function_ui"
  while true; do
    read -p "${cyan}Perform action:${default} " action; echo
    case "$action" in
      1) 
        do_action "usb_device_mount" "custom_function_ui";;
      B|b)
        clear; main_menu; break;;
      *)
        deny_action "custom_function_ui";;
    esac
  done
  custom_function_ui
}
