#!/bin/bash
#header----------------------------------------------------------------------------------------
# scriptname:            sysUpdate
# scriptversion:         v2.0.0
# script description:    for Linux system update
# creater:               Timon Bachmann
# creater (sysuser):     timon
# create datetime:       2024.03.04 15:42:11
# permissons:			 chmod +x sysUpdate.sh
#script----------------------------------------------------------------------------------------



# Initialize globale variables with default values
#-------------------------------------------------------------------------------------------------------------------------------------------
sysUpgrade=false
sysShutdown=false
sysReboot=false
shellClear=false



# identify the operating system
#-------------------------------------------------------------------------------------------------------------------------------------------
if [ "$os" == "Linux" ]; then
    distribution=$(lsb_release -si 2>/dev/null)
    release=$(lsb_release -sr 2>/dev/null)
    
	# compatible check between OS and script
	distribution_lowercase=$(echo "$distribution" | tr '[:upper:]' '[:lower:]')
	case $distribution_lowercase in
		ubuntu)
			systemCompatible="compatible"
			;;
		debian)
			systemCompatible="compatible"
			;;
		*)
			systemCompatible="incompatible"
			;;
	esac # end of compatible check between OS and script
	
	# displays the operating system in the terminal or interrupts the script
	if [ -n "$distribution" ] && [ -n "$release" ]; then
		echo "Your operating system is $distribution $release."
	else
		echo "Your Linux distribution could not be identified."
		exit 100
	fi
	echo "----------------------------------------------------------------"
else
	echo "This script is not available for your operating system: $os."
	exit
fi # end of identify the operating system



# Help options
#-------------------------------------------------------------------------------------------------------------------------------------------
if [ "$1" == "-h" ]; then
    # Use only for system upgrade (for example, from 20.04 LTS to 22.04 LTS)
    echo "->   -h | --help              for help"
	echo "#    This script is compatible for Ubuntu, Debian. Your operating system is $systemCompatible."
   #echo "--- essential parameters ----------------------------------------------------------------------"
	echo "--- optional parameter ------------------------------------------------------------------------"
    echo "->        --system-upgrade    for system upgrade | use only for system upgrade (for example, from 20.04 LTS to 22.04 LTS)"
	echo "->   -r | --reboot            restart after completing the updates"
    echo "->   -s | --shutdown          shutdown after completing the updates"
	echo "->   -c | --clear				clean the termianl after completing the update"
	exit 101
fi



# Function for setting parameters in the desired order
#-------------------------------------------------------------------------------------------------------------------------------------------
set_parameters() {
    for ((i=1; i<=$#; i++)); do
        arg="${!i}"
        case "$arg" in
            --system-upgrade)
                sysUpgrade=true
                ;;
            -r|--reboot)
                sysReboot=true
                ;;
            -s|--shutdown)
                sysShutdown=true
                ;;
			-c|--clear)
				shellClear=true
				;;
            *)
                exit 200
                ;;
        esac
    done
}


#set_parameters() {
#    for arg in "$@"; do
#        case "$arg" in
#            -h|--help)
#                help=true
#                ;;
#            --system-upgrade)
#                sysUpgrade=true
#                ;;
#			-r|--reboot)
#				sysReboot=true
#				;;
#			-s|--shutdown)
#				sysShutdown=true
#				;;
#			-c|--clear)
#				shellClear=true
#				;;
#           *)
#              exit 100
#              ;;
#        esac
#    done
#}

# Pass all parameters to the function
#-------------------------------------------------------------------------------------------------------------------------------------------
set_parameters "$@"


Start update script
#-------------------------------------------------------------------------------------------------------------------------------------------

case $distribution_lowercase in
	
	#for Ubuntu, Debian, Mint
	#-------------------------------------------------------------------------------------------------------------------------------------------
	ubuntu|debian)
		echo "----------------------------------------------------------------"
		echo "-> The package list is now being updated."
		echo "----------------------------------------------------------------"
		sudo apt update
		
		if [ "$sysUpgrade" = true ]; then
			read -p "-> Was a backup made? If yes, continue? [Y/n] " sysUpgradeContinue
			if [ "$sysUpgradeContinue" = "Y" ] || [ "$sysUpgradeContinue" = "y" ]; then  
				echo "----------------------------------------------------------------"
				echo "-> Your system is now being upgraded!"
				echo "----------------------------------------------------------------"
				sudo do-release-upgrade
			else
				exit 201
			fi
		fi

		echo "----------------------------------------------------------------"
		echo "-> All packages are now being updated"
		echo "----------------------------------------------------------------"
		sudo apt upgrade -y
		
		echo "----------------------------------------------------------------"
		echo "-> System packages and dependencies are now being updated"
		echo "----------------------------------------------------------------"
		sudo apt dist-upgrade -y
	
		echo "----------------------------------------------------------------"
		echo "-> Unnecessary dependencies are now being removed"
		echo "----------------------------------------------------------------"
		sudo apt autoremove -y

		
		echo "----------------------------------------------------------------"
		echo "-> Snap packages have been updated"
		echo "----------------------------------------------------------------"
		sudo snap refresh -y

		echo "----------------------------------------------------------------"
		echo "-> Your system should now be up to date."
		echo "----------------------------------------------------------------"
		
		;; # instruction to end script
	#-------------------------------------------------------------------------------------------------------------------------------------------
	
	



# instruction to end script
#-------------------------------------------------------------------------------------------------------------------------------------------
if [ "$shellClear" = true ]; then
	clear
fi
if [ "$sysReboot" = true ]; then
	sudo reboot
fi
if [ "$sysShutdown" = true ]; then
	sudo shutdown -h now
fi