#!/bin/bash

echo "Starting Installation..."

echo "installing dependencies..."
# Install xdotool
sudo apt-get update
sudo apt-get install -y xdotool


# Check if the "cron" service is enabled and active
if systemctl is-enabled --quiet cron && systemctl is-active --quiet cron; then
    echo "Cron is enabled and active"
else
    echo "Cron is not enabled and/or not active. everything may not work correctly"
fi 


chmod +x $(pwd)/move-mouse.sh
chmod +x $(pwd)/toggle-cron.sh

new_cron_line="* * * * * DISPLAY=:0 $(pwd)/move-mouse.sh"

# Add the new line to the crontab file
{ crontab -l; echo "$new_cron_line"; } | crontab -


# Check for the desktop environment
desktop_environment="unknown"

# Check for GNOME
if [ -n "$(command -v gnome-shell)" ]; then
    desktop_environment="GNOME"
fi

# Check for KDE
if [ -n "$(command -v kwin)" ]; then
    desktop_environment="KDE"
fi

# Check for XFCE
if [ -n "$(command -v xfce4-session)" ]; then
    desktop_environment="XFCE"
fi

# Echo the detected desktop environment
echo "Detected Desktop Environment: $desktop_environment"
custom_key_binding="ALT+SHIFT+F"
toggle_script=$(pwd)/toggle-cron.sh

case $desktop_environment in
    "GNOME")
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'toggle cron'
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "$(toggle_script)"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "$custom_key_binding"
        ;;
    "KDE")
        # Adjust the KDE command based on how you configure it in KDE
        kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "$custom_key_binding=script:$(toggle_script)"
        ;;
    "XFCE")
        # Adjust the XFCE command based on how you configure it in XFCE
        xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt><Shift>F" -n -t string -s "$(toggle_script)"
        ;;
    *)
        echo "Desktop environment not supported"
        ;;
esac

echo "Added Key binding of $(custom_key_binding) to toggle the script on and off"
