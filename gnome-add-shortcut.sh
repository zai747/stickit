#!/bin/bash

has_gsettings=$(command -v gsettings)
if [[ ! -z "$has_gsettings" ]]; then
  function add_keyboard_shortcut() {
    new_shortcut="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${1}/"

    # Get the current list of custom shortcuts
    current_shortcuts=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

    if [[ "${current_shortcuts}" == "@as []" ]]; then
      # If there are no existing shortcuts, start a new list
      new_shortcuts="[ '${new_shortcut}' ]"
    else
      # If there are existing shortcuts, append the new one
      new_shortcuts=$(echo "${current_shortcuts::-1}, '${new_shortcut}' ]" | sed 's/\//\\\//g')
    fi

    # Set the new list of custom shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${new_shortcuts}"

    # Assign bindings
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${new_shortcut} name "${1}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${new_shortcut} command "${2}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:${new_shortcut} binding "${3}"
  }

  # Add the "Toggle Cron" shortcut with ALT+SHIFT+F key combination
  add_keyboard_shortcut "ToggleCron" "$(pwd)/toggle-cron.sh" "<Alt><Shift>F"
fi
