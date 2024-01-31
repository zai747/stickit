#!/bin/bash

CRONTAB_FILE="temp_crontab"

# Get the current crontab
crontab -l > "$CRONTAB_FILE"

# Check if the first line is commented
if [[ $(sed -n '1p' "$CRONTAB_FILE") == "#"* ]]; then
    # Uncomment the first line
    sed -i '1 s/^#//' "$CRONTAB_FILE"
else
    # Comment out the first line
    sed -i '1 s/^/#/' "$CRONTAB_FILE"
fi

# Install the modified crontab
crontab "$CRONTAB_FILE"

# Remove the temporary file
rm "$CRONTAB_FILE"

