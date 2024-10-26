#!/bin/bash

# This script uses rtcontrol to find torrents with the label "Imported"
# and a ratio greater than 1.0, and changes their label to "del?".

# Source .bashrc to load your environment variables
source ~/.bashrc

# Define the old label and new label
OLD_LABEL="Imported"
NEW_LABEL="delete"

# Use rtcontrol to find torrents and update the label using --exec
rtcontrol custom_1="$OLD_LABEL" 
/home19/nitrobass24/bin/rtcontrol custom_1="$OLD_LABEL" ratio=+1.0 is_private=1  --exec "d.custom1.set='$NEW_LABEL'" --yes
/home19/nitrobass24/bin/rtcontrol custom_1="$OLD_LABEL" is_private=0 --cull --yes
echo "Torrents with label '$OLD_LABEL' and ratio greater than 1.0 have been updated to label '$NEW_LABEL'."
