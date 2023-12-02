entries="Logout Suspend Reboot Shutdown"

selected=$(printf '%s\n' $entries | wofi --normal-window --width 100 --height 140 --dmenu | awk '{print tolower($1)}')

case $selected in
  logout)
    hyprctl dispatch exit;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
