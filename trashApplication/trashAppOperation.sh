#!/bin/bash
# Author: José M. C. Noronha

# Args
declare operation="$1"; shift
declare args=("$@")

# Global directory variable
declare home="$(echo $HOME)"
declare appDir="/opt/trashApplication"
declare appConfigDir="$home/.config/trashApplication"
declare autostartDir="$home/.config/autostart"
declare execAppDir="$home/.local/share/applications"

# Services Files
declare serviceFile="$appDir/trashAppService.sh"

# Kernel files
declare functionsFile="$appDir/functions.sh"
declare operationFile="$appDir/trashAppOperation.sh"
declare zenityFile="$appDir/zenity.sh"

# Config File
declare configFile="$appConfigDir/trashApplication.conf"

# Desktop Files
declare execAppFile="trashApplication.desktop"
declare autostartAppFile="trashApplication.desktop"
declare nameDesktopFile
declare actionNameEmpty
declare actionNameUninstall

# Icons
declare iconDefault="user-trash"
declare iconFull="user-trash-full"

#modal confirm definition
declare width="200"
declare okLabel="%OKLABEL%"
declare cancelLabel="%CANCELLABEL%"
declare titleEmpty="%TITLEEMPTY%"
declare textEmpty="%TEXTEMPTY%"
declare titleUninstall="%TITLEUNINSTALL%"
declare textUninstall="%TEXTUNINSTALL%"

####### FUNCTIONS #######
#define language
generateLang(){
	local setLabel="$1"

	# Get Language with encoding of Operating System
	local language="$(echo $LANG | cut -d '.' -f1)"

	if [ "$language" = "pt_PT" ]||[ "$language" = "pt_BR" ]; then
		# pt_PT or pt_BR
		titleEmpty="Esvaziar Reciclagem?"
		textEmpty="Esvaziar todos os ficheiros da reciclagem?"
		titleUninstall="Desinstalar Reciclegem App"
		textUninstall="Tem a certeza que desaja desinstalar a reciclagem app?"
		nameDesktopFile="Reciclagem"
		actionNameEmpty="Esvaziar Reciclagem"
		actionNameUninstall="Desinstalar"
		okLabel="Sim"
		cancelLabel="Não"
	else
		# en default
		titleEmpty="Empty Trash?"
		textEmpty="Empty all files on trash?"
		titleUninstall="Uninstall Trash App"
		textUninstall="Are you sure you want to uninstall trash app?"
		nameDesktopFile="Trash"
		actionNameEmpty="Empty Trash"
		actionNameUninstall="Uninstall"
		okLabel="Yes"
		cancelLabel="No"
	fi

	if [ "$setLabel" = "-s" ]; then
		# Replace name ok label and cancel label for question dialog
		sudo sed -i "s#%OKLABEL%#$okLabel#g" "$operationFile"
		sudo sed -i "s#%CANCELLABEL%#$cancelLabel#g" "$operationFile"

		# Empty
		sudo sed -i "s#%TITLEEMPTY%#$titleEmpty#g" "$operationFile"
		sudo sed -i "s#%TEXTEMPTY%#$textEmpty#g" "$operationFile"

		# Uninstall
		sudo sed -i "s#%TITLEUNINSTALL%#$titleUninstall#g" "$operationFile"
		sudo sed -i "s#%TEXTUNINSTALL%#$textUninstall#g" "$operationFile"
	fi
}

# Reset all config
function resetConfig(){
	echo "PID=" | tee "$configFile" > /dev/null
}

# Empty trash
function emptyTrash(){
	local response=$(eval "$zenityFile question -ti=\"$titleEmpty\" -te=\"$textEmpty\" -lok=\"$okLabel\" -lcancel=\"$cancelLabel\" -w=$width")

	# confirm user action
	if [ "$response" -eq "1" ]; then
	    trash-empty;
	fi
}

# Open trash directory
function openTrash(){
	xdg-open trash:///
}

# Install
function install(){
	local execute
	local extraLines

	# Get Locale System
	generateLang -s

	# Create desktop files
	execute="$operationFile openDir"
	extraLines="Actions=empty-trash;uninstall;\n"
	extraLines="$extraLines\n[Desktop Action empty-trash]\nName=$actionNameEmpty\nExec=$operationFile empty\n"
	extraLines="$extraLines\n[Desktop Action uninstall]\nName=$actionNameUninstall\nExec=$operationFile -u-shortcut\n"
	eval "$functionsFile -dFile \"$nameDesktopFile\" \"$execAppFile\" \"$execute\" \"$iconDefault\" 0 \"$extraLines\""
	eval "$functionsFile -dFile \"$nameDesktopFile\" \"$autostartAppFile\" \"$serviceFile\" \"$iconDefault\" 1"

	# Create config folder
	mkdir -p "$appConfigDir"

	# Reset Config
	resetConfig

	# Start service
	eval "$serviceFile &"
}

# Uninstall
function uninstall(){
	local response=$(eval "$zenityFile question -ti=\"$titleUninstall\" -te=\"$textUninstall\" -lok=\"$okLabel\" -lcancel=\"$cancelLabel\" -w=$width")
	local pidService

	# confirm user action
	if [ "$response" -eq "1" ]; then
		echo "Uninstall..."

		# Kill Service
		pidService="$(cat "$configFile" | grep "PID=" | cut -d '=' -f2)"
        eval "$functionsFile -kPID $pidService"

        # Delete desktop files
        eval "$functionsFile -delFD \"$execAppDir/$execAppFile\""
        eval "$functionsFile -delFD \"$autostartDir/$autostartAppFile\""

        # Remove Config Dir
        eval "$functionsFile -delFD \"$appConfigDir\""

        # Remove appDir
        eval "$functionsFile -delFD \"$appDir\" 1"

        # print message finish
		echo "Done."
	fi
}

# Main
function main(){
	case "$operation" in
		"empty" )
			emptyTrash
			;;
		"openDir")
			openTrash
			;;
		"-i")
			install
			;;
		"-u-shortcut")
			x-terminal-emulator -e "$operationFile -u"
			;;
		"-u")
			uninstall
			;;
	esac
}
main