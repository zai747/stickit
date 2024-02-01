#!/bin/bash

echo "Starting Installation..."

echo "Installing dependencies..."
# Install xdotool
sudo apt-get update
sudo apt-get install -y xdotool

# Check if the "cron" service is enabled and active
if systemctl is-enabled --quiet cron && systemctl is-active --quiet cron; then
    echo "Cron is enabled and active"
else
    echo "Cron is not enabled and/or not active. Everything may not work correctly."
fi 

# Set script permissions
chmod +x "$(pwd)/move-mouse.sh"
chmod +x "$(pwd)/toggle-cron.sh"

# Set up cron job
new_cron_line="* * * * * DISPLAY=:0 $(pwd)/move-mouse.sh"
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
toggle_script="$(pwd)/toggle-cron.sh"

# Configure key binding based on desktop environment
case $desktop_environment in
    "GNOME")
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'toggle cron'
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "$toggle_script"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "$custom_key_binding"
        ;;
    "KDE")
        kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "$custom_key_binding=script:$toggle_script"
        ;;
    "XFCE")
        xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt><Shift>F" -n -t string -s "$toggle_script"
        ;;
    *)
        echo "Desktop environment not supported"
        ;;
esac

echo "Added Key binding of $custom_key_binding to toggle the script on and off"
