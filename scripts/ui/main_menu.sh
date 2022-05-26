main_ui(){
  #[ $KIAUH_UPDATE_REMIND="true" ] && kiauh_update_reminder
  top_border
  echo -e "|     $(title_msg "~~~~~~~~~~~~~~~ [ Main Menu ] ~~~~~~~~~~~~~~~")     |"
  hr
  echo -e "|  0) [Upload Log]     |       Klipper: $KLIPPER_STATUS|"
  echo -e "|                      |        Branch: ${cyan}$PRINT_BRANCH${default}|"
  echo -e "|  1) [Install]        |                                |"
  echo -e "|  2) [Update]         |     Moonraker: $MOONRAKER_STATUS|"
  echo -e "|  3) [Remove]         |                                |"
  echo -e "|  4) [Advanced]       |      Mainsail: $MAINSAIL_STATUS|"
  echo -e "|  5) [Backup]         |        Fluidd: $FLUIDD_STATUS|"
  echo -e "|                      | KlipperScreen: $KLIPPERSCREEN_STATUS|"
  echo -e "|  6) [Settings]       |  Telegram Bot: $MOONRAKER_TELEGRAM_BOT_STATUS|"
  echo -e "|                      |                                |"
  echo -e "|                      |          DWC2: $DWC2_STATUS|"
  echo -e "|  ${cyan}$KIAUH_VER${default}|     Octoprint: $OCTOPRINT_STATUS|"
  custom_function
  quit_footer
}

print_kiauh_version(){
  cd ${SRCDIR}/kiauh
  KIAUH_VER=Ver_0.0.1
  KIAUH_VER="$(printf "%-20s" "$KIAUH_VER")"
}

main_menu(){
  print_header

  #check install status
    print_kiauh_version
    klipper_status
    moonraker_status
    dwc2_status
    fluidd_status
    mainsail_status
    octoprint_status
    klipperscreen_status
    MoonrakerTelegramBot_status
    print_branch
  print_msg && clear_msg
  main_ui
  while true; do
    read -p "${cyan}Perform action:${default} " action; echo
    case "$action" in
      "start klipper") do_action_service "start" "klipper"; main_ui;;
      "stop klipper") do_action_service "stop" "klipper"; main_ui;;
      "restart klipper") do_action_service "restart" "klipper"; main_ui;;
      "start moonraker") do_action_service "start" "moonraker"; main_ui;;
      "stop moonraker") do_action_service "stop" "moonraker"; main_ui;;
      "restart moonraker")do_action_service "restart" "moonraker"; main_ui;;
      "start dwc") do_action_service "start" "dwc"; main_ui;;
      "stop dwc") do_action_service "stop" "dwc"; main_ui;;
      "restart dwc") do_action_service "restart" "dwc"; main_ui;;
      "start octoprint") do_action_service "start" "octoprint"; main_ui;;
      "stop octoprint") do_action_service "stop" "octoprint"; main_ui;;
      "restart octoprint") do_action_service "restart" "octoprint"; main_ui;;
      update) do_action "main_ui";;
      0) do_action "upload_selection" "main_ui";;
      1) clear && install_menu && break;;
      2) clear && update_menu && break;;
      3) clear && remove_menu && break;;
      4) clear && advanced_menu && break;;
      5) clear && backup_menu && break;;
      6) clear && settings_menu && break;;
      F|f) clear && custom_function_menu && break;;
      Q|q)
        echo -e "${green}###### Happy printing! ######${default}"; echo
        exit -1;;
      *)
        deny_action "main_ui";;
    esac
  done
  clear; main_menu
}
