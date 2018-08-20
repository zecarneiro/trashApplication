#!/bin/bash
# Author: José M. C. Noronha

# Global variable
declare type="$1"; shift
declare -a args=("$@")
declare -a otherCmd=()

# Return all args with value
function getGeneralArgs(){
    for arg in "${args[@]}"; do
        # Get arg and value
        value="$(echo "$arg" | cut -d "=" -f2)"
        arg="$(echo "$arg" | cut -d "=" -f1)"

        # General Args
    	if [ "$arg" = "-ti" ]; then
    	    otherCmd+=("--title=\"$value\"")
        elif [ "$arg" = "-i" ]; then
            otherCmd+=("--window-icon=\"$value\"")
        elif [ "$arg" = "-w" ]; then
             otherCmd+=("--width=\"$value\"")
        elif [ "$arg" = "-h" ]; then
             otherCmd+=("--height=\"$value\"")
        elif [ "$arg" = "-to" ]; then
             otherCmd+=("--timeout=\"$value\"")

        # Info/Error/Question/Forms
        elif [ "$arg" = "-te" ]; then
            otherCmd+=("--text=\"$value\"")

        # Question
        elif [ "$arg" = "-lok" ]; then
             otherCmd+=("--ok-label=\"$value\"")
        elif [ "$arg" = "-lcancel" ]; then
             otherCmd+=("--cancel-label=\"$value\"")

        # Notification
        elif [ "$arg" = "-l" ]; then
             otherCmd+=("--listen")

        # File Select
        elif [ "$arg" = "-isdir" ]; then
             otherCmd+=("--directory")

        # File Select/Text Info
        elif [ "$arg" = "-fname" ]; then
             otherCmd+=("--filename=\"$value\"")

        # File Select/List
        elif [ "$arg" = "-ismult" ]; then
             otherCmd+=("--multiple")

        # File Select/List//Forms
        elif [ "$arg" = "-s" ]; then
             otherCmd+=("--separator=\"$value\"")

        # List
        elif [ "$arg" = "-tyLr" ]; then
             otherCmd+=("--radiolist")
        elif [ "$arg" = "-tyLc" ]; then
             otherCmd+=("--checklist")
        elif [ "$arg" = "-c" ]; then
             otherCmd+=("--column=\"$value\"")
        elif [ "$arg" = "-hHL" ]; then
             otherCmd+=("--hide-header")
        elif [ "$arg" = "-vL" ]; then
            otherCmd+=($value)

        # Forms
        elif [ "$arg" = "-addE" ]; then
             otherCmd+=("--add-entry=\"$value\"")
    	fi
    done
}

# Main
function main(){
    local cmd="zenity"
    case "$type" in
        "info")
            cmd="$cmd --info"
            ;;
        "error")
            cmd="$cmd --error"
            ;;
        "question")
            cmd="$cmd --question"
            ;;
        "notify")
            cmd="$cmd --notification"
            ;;
        "fileSelect")
            cmd="$cmd --file-selection"
            ;;
        "list")
            cmd="$cmd --list"
            ;;
        "textInfo")
            cmd="$cmd --text-info"
            ;;
        "form")
            cmd="$cmd --forms"
            ;;
        *)
            printf "General args:\n"
            echo "-ti: title"
            echo "-i: icon"
            echo "-w: width"
            echo "-h: height"
            echo "-to: timeout"

            # Info/Error/Question/Forms
            printf "\nInfo/Error/Question args:\n"
            echo "-te: text"

            # Only Question
            printf "\nOnly Question args:\n"
            echo "-lok: ok-label\n"
            echo "-lcancel: cancel-label\n"

            # Only Notification
            printf "\nOnly Notification args:\n"
            echo "-l: listen"

            # Only File Selection
            printf "\nOnly File Selection args:\n"
            echo "-isdir: directory\n"

            # File Selection/
            printf "\nFile Selection/ args:\n"
            echo "-fname: filename\n"

            # File Selection/List
            printf "\nFile Selection/List args:\n"
            echo "-ismult: multiple\n"

            # File Selection/List/Forms
            printf "\nFile Selection/List args:\n"
            echo "-s: separator\n"

            # Only List
            printf "\nOnly List args:\n"
            echo "-tyLr: radiolist\n"
            echo "-tyLc: checklist\n"
            echo "-c: column\n"
            echo "-vL: value\n"
            echo "-hHL: hide-header\n"

            # Only Forms
            printf "\nOnly Forms args:\n"
            echo "-addE: add-entry\n"

            # Example
            printf "\n* $0 info/error -te=\"value\"...\n"
            printf "\n* $0 fileSelect GENERAL_ARGS -fname -isdir -ismult -s\n"
            printf "\n* $0 notify -te=... -l=icon:'text',message:'text',tooltip:'text',visible:'text',...\n"
            printf "\n* $0 fileSelect GENERAL_ARGS -l\n"
            ;;
    esac

    # Get response
    getGeneralArgs

    if [ "$type" = "fileSelect" ]||[ "$type" = "list" ]||[ "$type" = "form" ]; then
        eval "$cmd ${otherCmd[@]} 2> /dev/null" 2>&1
    elif [ "$type" = "question" ]; then

        eval "$cmd ${otherCmd[@]}"
        case $? in
            1)
                echo "0"
                ;;
            0)
                echo "1"
                ;;
        esac
    else
        eval "$cmd ${otherCmd[@]}"
    fi
}
main