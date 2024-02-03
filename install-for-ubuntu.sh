#!/bin/bash

echo "Starting Installation..."

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
crontab -l > backup_crontab.txt
new_cron_line="* * * * * DISPLAY=:0 $(pwd)/move-mouse.sh"
(crontab -l 2>/dev/null; echo "$new_cron_line") | crontab -

# Check for the desktop environment
desktop_environment="unknown"

# Check for GNOME
if command -v gnome-shell &> /dev/null && [ -x "$(command -v gnome-shell)" ]; then
    desktop_environment="GNOME"
fi

# Check for KDE
if command -v kwin &> /dev/null && [ -x "$(command -v kwin)" ]; then
    desktop_environment="KDE"
fi

# Check for XFCE
if command -v xfce4-session &> /dev/null && [ -x "$(command -v xfce4-session)" ]; then
    desktop_environment="XFCE"
fi

# Convert to lowercase for case-insensitive check
desktop_environment=$(echo "$desktop_environment" | tr '[:upper:]' '[:lower:]')

# Echo the detected desktop environment
echo "Detected Desktop Environment: $desktop_environment"
custom_key_binding="ALT+SHIFT+F"
toggle_script="$(pwd)/toggle-cron.sh"

# Configure key binding based on desktop environment
case $desktop_environment in
    "gnome")
        chmod +x "$(pwd)/gnome-add-shortcut.sh"
	./gnome-add-shortcut.sh 
        ;;
    "kde")
        kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "$custom_key_binding=script:$toggle_script"
        ;;
    "xfce")
        xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt><Shift>F" -n -t string -s "$toggle_script"
        ;;
    *)
        echo "Desktop environment not supported"
        ;;
esac > keybinding_config.log 2>&1

echo "Added Key binding of $custom_key_binding to toggle the script on and off"
