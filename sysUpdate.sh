#!/bin/bash
#header----------------------------------------------------------------------------------------
# scriptname:            sysUpdate
# scriptversion:         v1.0.0
# script description:    for ubuntu system update
# creater:               R2TURUK2
# create datetime:       2024.03.04 15:42:11
# permissons:		 chmod +x sysUpdate.sh
#script----------------------------------------------------------------------------------------

# Initialize variables with default values
help=false
sysUpgrade=false
sysShutdown=false
sysReboot=false

# Function for setting parameters in the desired order
set_parameters() {
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                help=true
                ;;
            --system-upgrade)
                sysUpgrade=true
                ;;
			-r|--reboot)
				sysReboot=true
				;;
			-s|--shutdown)
				sysShutdown=true
				;;			
            *)
                exit 100
                ;;
        esac
    done
}

# Pass all parameters to the function
set_parameters "$@"

if [ "$help" = true ]; then
    # Use only for system upgrade (for example, from 20.04 LTS to 22.04 LTS)
    echo "->   -h | --help              for help"
    echo "->        --system-upgrade    for system upgrade | use only for system upgrade (for example, from 20.04 LTS to 22.04 LTS)"
	echo "->   -r | --reboot            restart after completing the updates"
    echo "->   -s | --shutdown          shutdown after completing the updates"
	exit 101
fi

if [ "$sysUpgrade" = true ]; then
    read -p "-> Was a backup made? If yes, continue? [Y/n] " sysUpgradeContinue
    if [ "$sysUpgradeContinue" = "Y" ] || [ "$sysUpgradeContinue" = "y" ]; then  
        sudo do-release-upgrade
        echo "----------------------------------------------------------------"
        echo "-> Your system has been upgraded!"
        echo "----------------------------------------------------------------"
    else
        exit 102
    fi
fi

sudo apt update
echo "----------------------------------------------------------------"
echo "-> Package list has been updated"
echo "----------------------------------------------------------------"

sudo apt upgrade -y
echo "----------------------------------------------------------------"
echo "-> All packages have been updated"
echo "----------------------------------------------------------------"

sudo apt dist-upgrade
echo "----------------------------------------------------------------"
echo "-> System packages and dependencies have been updated"
echo "----------------------------------------------------------------"

sudo apt autoremove
echo "----------------------------------------------------------------"
echo "-> Unnecessary dependencies have been removed"
echo "----------------------------------------------------------------"

sudo snap refresh
echo "----------------------------------------------------------------"
echo "-> Snap packages have been updated"
echo "----------------------------------------------------------------"
echo "-> Your system is now up to date"
echo "----------------------------------------------------------------"

if [ "$sysReboot" = true ]; then
	sudo reboot
fi
if [ "$sysShutdown" = true ]; then
	sudo shutdown -h now
fi
