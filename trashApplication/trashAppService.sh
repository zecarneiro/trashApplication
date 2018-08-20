#!/bin/bash
# Autor: José M. C. Noronha
# Data: 17/03/2018

# Global directory variable
declare home="$(echo $HOME)"
declare appDir="/opt/trashApplication"
declare appConfigDir="$home/.config/trashApplication"
declare autostartDir="$home/.config/autostart"
declare execAppDir="$home/.local/share/applications"

# Kernel files
declare functionsFile="$appDir/functions.sh"

# Config File
declare configFile="$appConfigDir/trashApplication.conf"

# Desktop Files
declare execAppFile="trashApplication.desktop"
declare autostartAppFile="trashApplication.desktop"

# Icons
declare iconDefault="user-trash"
declare iconFull="user-trash-full"

# change icon
function changeIcon(){
	local -i trashStatus="$1"
	local -i isIconFull

	# command to check if full icon exists
	isIconFull=$(grep -c "Icon=$iconFull" "$execAppDir/$execAppFile")

	# verify trash is not empty and icon is not full
	if [ $trashStatus -gt 0 ]&&[ $isIconFull -eq 0 ]; then

		# change to icon full
		sed -i "s#Icon=.*#Icon=$iconFull#g" "$execAppDir/$execAppFile"

	# verify trash is empty and icon is full
	elif [ $trashStatus -le 0 ]&&[ $isIconFull -ne 0 ]; then

		# change to normal icon
		sed -i "s#Icon=.*#Icon=$iconDefault#g" "$execAppDir/$execAppFile"

	fi
}

# Save PID
function savePID(){
	local -i pid=$$
	local -i existPID=0

	if [ $(eval "$functionsFile -existFD \"$configFile\"") -eq 1 ]; then
		existPID="$(cat "$configFile" | grep -c "PID=")"
	fi

	if [ $existPID -gt 0 ]; then
		sed -i "s#PID=.*#PID=$pid#g" $configFile
	else
		echo "PID=$pid" | tee -a $configFile > /dev/null
	fi
}

# Main
function main(){
	local getTrashStatus
	local -i timeSleep=1

	savePID
	while [ 1 ]; do

		# command to check if trash is full or not
		getTrashStatus=$(trash-list | grep -c .)

		# Change icon
		changeIcon getTrashStatus

		# sleep
		sleep $timeSleep
	done
}
main