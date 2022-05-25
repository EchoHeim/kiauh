custom_updates_ui(){
  ui_print_versions
  top_border
  echo -e "|     ${green}~~~~~~~~~~ [ Custom Updates Menu ] ~~~~~~~~~~${default}     | "
  hr
  echo -e "|  No features added yet! "

  back_footer
}

custom_updates_menu(){
  do_action "" "custom_updates_ui"
  while true; do
    read -p "${cyan}Perform action:${default} " action; echo
    case "$action" in
      1)
        if [ ! -z $klipper_cfg_loc ]; then
          do_action "change_klipper_cfg_path" "custom_updates_ui"
        else
          deny_action "custom_updates_ui"
        fi;;
      B|b)
        clear; main_menu; break;;
      *)
        deny_action "custom_updates_ui";;
    esac
  done
  custom_updates_ui
}
