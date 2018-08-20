#!/bin/bash
# Author: José M. C. Noronha

# print message Init
echo "Install..."

# Global variable
declare nameAppPath="trashApplication"
declare appDir="/opt/$nameAppPath"
declare functionsBashFile="$appDir/functions.sh"
declare operationBashFile="$appDir/trashAppOperation.sh"

# Copy app
sudo cp -r "$nameAppPath" /opt
sudo chmod -R 777 "$appDir"

# Zenity
eval "$functionsBashFile -i \"zenity trash-cli\""

# Install app
eval "$operationBashFile -i"

# print message finish
echo "Done."
exit 0