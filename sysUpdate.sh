#!/bin/bash
#header----------------------------------------------------------------------------------------
# scriptname:            sysUpdate
# scriptversion:         v2.2
# creator:               GitHub/R2Turuk2
# create datetime:       2024.03.10 12:00:00
# permissions:           chmod +x sysUpdate.sh

# script description:    This Bash script is designed to simplify the process of updating
#                        Linux systems. It supports various distributions, including Ubuntu,
#                        Debian, Fedora, openSUSE, CentOS, Kali Linux, and more. The script
#                        automatically checks compatibility with the operating system and 
#                        then performs the necessary update steps.

# features:              System Detection: The script automatically recognizes the operating
#                                          system and its version.

#                        Package Update:   It updates the package list and then carries out
#                                          various update steps, including package upgrades,
#                                          system upgrades, and the removal of unnecessary
#                                          dependencies.

#                        Snap Package Update:   The script also updates Snap packages, if
#                                               installed.

#                        User-Friendly Options: The script provides optional parameters such
#                                               as reboot, shutdown, and clearing the
#                                               terminal after completing updates.

#                        Support for Ubuntu..   If desired, the script allows
#                        System Upgrades:       upgrading to a new version of Ubuntu.

# usage:                 Run the script with ./sysUpdate.sh.
# optional parameters:   -h or --help       for help and available options.
#                        -r or --reboot     for a reboot after completing the updates.
#                        -s or --shutdown   for a shutdown after completing the updates.
#                        -c or --clear      for clearing the terminal after completing the updates.
#                        --system-upgrade   only for Ubuntu system upgrades (e.g. from 20.04 LTS to 22.04 LTS).

# note:                  This script requires the availability of the 'lsb_release' command for
#                        operating system detection and may require additional packages depending
#                        on the distribution.
#script----------------------------------------------------------------------------------------

# Initialize global variables with default values
#-------------------------------------------------------------------------------------------------------------------------------------------
sysUpgrade=false
sysShutdown=false
sysReboot=false
shellClear=false
shellExit=false

# Check if lsb_release is available
#-------------------------------------------------------------------------------------------------------------------------------------------
while ! command -v lsb_release &> /dev/null; do
    echo "-> The command 'lsb_release' is not available on this system. Please install the package to proceed."

    # Check the distribution and suggest manual installation commands
    if command -v apt &> /dev/null; then
        echo "-> Try installing 'lsb-release' with the following command:"
        read -p "     sudo apt install lsb-release  -  try running the automatic installation and script again? [Y/n] " lsbAutoInstall
        if [ "$lsbAutoInstall" == Y ] || [ "$lsbAutoInstall" == y ]; then
            sudo apt install lsb-release
        fi
    
    elif command -v yum &> /dev/null; then
        echo "-> Try installing 'lsb-release' with the following command:"
        read -p "     sudo yum install redhat-lsb-core  -  try running the automatic installation and script again? [Y/n] " lsbAutoInstall
        if [ "$lsbAutoInstall" == Y ] || [ "$lsbAutoInstall" == y ]; then
            sudo yum install redhat-lsb-core
        fi
        
    elif command -v dnf &> /dev/null; then
        echo "-> Try installing 'lsb-release' with the following command:"
        read -p "     sudo dnf install redhat-lsb-core  -  try running the automatic installation and script again? [Y/n] " lsbAutoInstall
        if [ "$lsbAutoInstall" == Y ] || [ "$lsbAutoInstall" == y ]; then
            sudo dnf install redhat-lsb-core
        fi
        
    elif command -v zypper &> /dev/null; then
        echo "-> Try installing 'lsb-release' with the following command:"
        read -p "     sudo zypper install lsb-release  -  try running the automatic installation and script again? [Y/n] " lsbAutoInstall
        if [ "$lsbAutoInstall" == Y ] || [ "$lsbAutoInstall" == y ]; then
            sudo zypper install lsb-release
        fi
        
    else
        echo "-> Unable to determine the package manager for automatic installation."
        echo "-> Please manually install 'lsb-release' using the appropriate package manager for your system."
        exit 100
    fi
	
    if [ "$lsbAutoInstall" != Y ] && [ "$lsbAutoInstall" != Y ]; then
        exit 101
    fi
done


# Check if the "snap" command is available in the system's PATH
#-------------------------------------------------------------------------------------------------------------------------------------------
if command -v snap &> /dev/null; then
	snapInstall=true
else
	snapInstall=false
fi

# Identify the operating system
#-------------------------------------------------------------------------------------------------------------------------------------------
distribution=$(lsb_release -si 2>/dev/null)
release=$(lsb_release -sr 2>/dev/null)
    
# Check compatibility between OS and script
distribution_lowercase=$(echo "$distribution" | tr '[:upper:]' '[:lower:]')
case $distribution_lowercase in
    ubuntu|debian|fedora|opensuse|centos|kali)
        systemCompatible="compatible"
        ;;
    *)
        systemCompatible="incompatible"
        exit 102
        ;;
esac  # end of compatibility check between OS and script

    
# Display the operating system in the terminal or interrupt the script
if [ ! -n "$distribution" ] && [ ! -n "$release" ]; then
	echo "-> Your Linux distribution could not be identified."
    exit 103
fi

# Help options
#-------------------------------------------------------------------------------------------------------------------------------------------
if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
    echo "-----------------------------------------------------------------------------------------------"
    echo "->   Your operating system is $distribution $release and therefore $systemCompatible."
	echo "     This script runs on Ubuntu, Debian, CentOS, Elementary OS,"
	echo "     Fedora, Kali Linux, Mageia, Mint, openSUSE, RHEL."
    echo ""
	#echo "---- essential parameters ---------------------------------------------------------------------"
    echo "---- optional parameter -----------------------------------------------------------------------"
    echo "->   -h | --help              for help"
	echo "->   -r | --reboot            restart after completing the updates"
    echo "->   -s | --shutdown          shutdown after completing the updates"
    echo "->   -c | --clear             clean the terminal after completing the update"
    
    # for distribution-specific information
    case $distribution_lowercase in
        ubuntu)
            echo "->        --system-upgrade    only for Ubuntu system upgrade"
			echo "                              use only for system upgrade (for example, from 20.04 LTS to 22.04 LTS)"
            ;;
        *)
            ;;
    esac # end of compatibility check between OS and script
    
    exit 104
fi

# setting parameters in the desired order
#-------------------------------------------------------------------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
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
            ;;
    esac

	shift # switch to the next arguments
done

# Start update script
#-------------------------------------------------------------------------------------------------------------------------------------------
case $distribution_lowercase in
    
    # for Ubuntu, Mint, Elementary OS
    #-------------------------------------------------------------------------------------------------------------------------------------------
    ubuntu)
        if [ ! -f $HOME/.sysUpdate.do-release.beforeRestart ]; then
			echo "----------------------------------------------------------------"
			echo "-> The package list is now being updated."
			echo "----------------------------------------------------------------"
			sudo apt update # Updates the package list from all defined package sources.
        
			if [ "$sysUpgrade" = true ]; then
				read -p "-> For system upgrade: Was a backup made? If yes, continue? [Y/n] " sysUpgradeContinue
				if [ "$sysUpgradeContinue" == "Y" ] || [ "$sysUpgradeContinue" == "y" ]; then  
					while ! command -v sudo do-release-upgrade &> /dev/null; do # Initiates the upgrade process to a new Ubuntu release if available.
						sudo apt install update-manager-core
					done
				
					read -p "-> Do you need a system reboot? [Y/n] " sysReboot
					if [ "$sysReboot" == "Y" ] || [ "$sysReboot" == "y" ]; then 
						echo "-> Please run this script again after the reboot. The system will reboot in 15 seconds."
						echo "-> To cancel the countdown, press \"ctrl+\"c."
						sleep 5
						for ((i = 10; i >0; i--))
						do
							echo "$i sec until reboot."
							sleep 1
						done
						touch $HOME/.sysUpdate.do-release.beforeRestart
						sudo reboot
					else
						echo "----------------------------------------------------------------"
						echo "-> Your system is now being upgraded!"
						echo "----------------------------------------------------------------"
						sudo do-release-upgrade
					fi
				fi	
			else
				exit 201
			fi
		fi
		if [ -f $HOME/.sysUpdate.do-release.beforeRestart ]; then
			sudo do-release-upgrade -y # Initiates the upgrade process after reboot to a new Ubuntu release.
		fi

        echo "----------------------------------------------------------------"
        echo "-> All packages are now being updated"
        echo "----------------------------------------------------------------"
        sudo apt upgrade -y # Upgrades all installed packages to the latest versions.
        
        echo "----------------------------------------------------------------"
        echo "-> System packages and dependencies are now being updated"
        echo "----------------------------------------------------------------"
        sudo apt dist-upgrade -y # Upgrades the system, including system packages and dependencies.
    
        echo "----------------------------------------------------------------"
        echo "-> Unnecessary dependencies are now being removed"
        echo "----------------------------------------------------------------"
        sudo apt autoremove -y # Removes unnecessary dependencies and no longer needed packages.

        if $snapInstall; then 
			echo "----------------------------------------------------------------"
			echo "-> Snap packages are now being updated"
			echo "----------------------------------------------------------------"
			sudo snap refresh # Updates Snap packages, if installed.
		fi

        echo "----------------------------------------------------------------"
        echo "-> Your system should now be up to date."
        echo "----------------------------------------------------------------"
        
        ;; # end
    #-------------------------------------------------------------------------------------------------------------------------------------------
    
    # for Debian
    #-------------------------------------------------------------------------------------------------------------------------------------------    
    debian)
        echo "----------------------------------------------------------------"
        echo "-> The package list is now being updated."
        echo "----------------------------------------------------------------"
        sudo apt update # Updates the package list from all defined package sources.
        
        echo "----------------------------------------------------------------"
        echo "-> All packages are now being updated"
        echo "----------------------------------------------------------------"
        sudo apt upgrade -y # Upgrades all installed packages to the latest versions.
        
        echo "----------------------------------------------------------------"
        echo "-> System packages and dependencies are now being updated"
        echo "----------------------------------------------------------------"
        sudo apt dist-upgrade -y # Upgrades the system, including system packages and dependencies.
    
        echo "----------------------------------------------------------------"
        echo "-> Unnecessary dependencies are now being removed"
        echo "----------------------------------------------------------------"
        sudo apt autoremove -y # Removes unnecessary dependencies and no longer needed packages.

        if $snapInstall; then 
			echo "----------------------------------------------------------------"
			echo "-> Snap packages are now being updated"
			echo "----------------------------------------------------------------"
			sudo snap refresh # Updates Snap packages, if installed.
		fi

        echo "----------------------------------------------------------------"
        echo "-> Your system should now be up to date."
        echo "----------------------------------------------------------------"
        
        ;; # end
    #-------------------------------------------------------------------------------------------------------------------------------------------
    
    # for Fedora
    #-------------------------------------------------------------------------------------------------------------------------------------------    
    fedora)
        echo "----------------------------------------------------------------"
        echo "-> The package list is now being updated."
        echo "----------------------------------------------------------------"
        sudo sudo dnf check-update # Check for available updates
        
        echo "----------------------------------------------------------------"
        echo "-> All packages are now being updated"
        echo "----------------------------------------------------------------"
        sudo sudo dnf upgrade -y # Upgrade all installed packages
    
        echo "----------------------------------------------------------------"
        echo "-> Unnecessary dependencies are now being removed"
        echo "----------------------------------------------------------------"
        sudo dnf autoremove -y # Removes unnecessary dependencies and no longer needed packages.
        
		if $snapInstall; then 
			echo "----------------------------------------------------------------"
			echo "-> Snap packages are now being updated"
			echo "----------------------------------------------------------------"
			sudo snap refresh # Updates Snap packages, if installed.
		fi
        
		echo "----------------------------------------------------------------"
        echo "-> Your system should now be up to date."
        echo "----------------------------------------------------------------"
        
        ;; # end
    #-------------------------------------------------------------------------------------------------------------------------------------------
    
    # for openSUSE
    #-------------------------------------------------------------------------------------------------------------------------------------------    
    opensuse)
        echo "----------------------------------------------------------------"
        echo "-> The package list is now being updated."
        echo "----------------------------------------------------------------"
        sudo zypper refresh # Updates the package list from all defined package sources.
        
        echo "----------------------------------------------------------------"
        echo "-> All packages are now being updated"
        echo "----------------------------------------------------------------"
        sudo sudo zypper update -y # Upgrades all installed packages to the latest versions.

        if $snapInstall; then 
			echo "----------------------------------------------------------------"
			echo "-> Snap packages are now being updated"
			echo "----------------------------------------------------------------"
			sudo snap refresh # Updates Snap packages, if installed.
		fi
		
        echo "----------------------------------------------------------------"
        echo "-> Your system should now be up to date."
        echo "----------------------------------------------------------------"
        
        ;; # end
    #-------------------------------------------------------------------------------------------------------------------------------------------
    
    # for CentOS, Red Hat Enterprise Linux (RHEL) / Mageia
    #-------------------------------------------------------------------------------------------------------------------------------------------    
    centos)
        echo "----------------------------------------------------------------"
        echo "-> The package list is now being updated."
        echo "----------------------------------------------------------------"
        sudo yum check-update # Updates the package list from all defined package sources.
        
        echo "----------------------------------------------------------------"
        echo "-> All packages are now being updated"
        echo "----------------------------------------------------------------"
        sudo yum upgrade -y # Upgrades all installed packages to the latest versions.
    
        echo "----------------------------------------------------------------"
        echo "-> Unnecessary dependencies are now being removed"
        echo "----------------------------------------------------------------"
        sudo yum autoremove -y # Removes unnecessary dependencies and no longer needed packages.

        if $snapInstall; then 
			echo "----------------------------------------------------------------"
			echo "-> Snap packages are now being updated"
			echo "----------------------------------------------------------------"
			sudo snap refresh # Updates Snap packages, if installed.
		fi
		
        echo "----------------------------------------------------------------"
        echo "-> Your system should now be up to date."
        echo "----------------------------------------------------------------"
        
        ;; # end
    #-------------------------------------------------------------------------------------------------------------------------------------------
    
    # for Kali Linux
    #-------------------------------------------------------------------------------------------------------------------------------------------    
    kali)
        echo "----------------------------------------------------------------"
        echo "-> The package list is now being updated."
        echo "----------------------------------------------------------------"
        sudo apt update # Updates the package list from all defined package sources.
        
        echo "----------------------------------------------------------------"
        echo "-> All packages are now being updated"
        echo "----------------------------------------------------------------"
        sudo apt full-upgrade -y # Upgrades all installed packages to the latest versions.
        
		if $snapInstall; then 
			echo "----------------------------------------------------------------"
			echo "-> Snap packages are now being updated"
			echo "----------------------------------------------------------------"
			sudo snap refresh # Updates Snap packages, if installed.
		fi
		
        echo "----------------------------------------------------------------"
        echo "-> Your system should now be up to date."
        echo "----------------------------------------------------------------"
        
        ;; # end
    #-------------------------------------------------------------------------------------------------------------------------------------------
	*)
		;;
esac

# Instructions to end the script
#-------------------------------------------------------------------------------------------------------------------------------------------
# Check for terminal clear condition
if $shellClear; then
    clear  # Clear the terminal if the condition is true
fi

# Check for system reboot condition
if $sysReboot; then
    sudo reboot  # Reboot the system if the condition is true
fi

# Check for system shutdown condition
if $sysShutdown; then
    sudo shutdown -h now  # Shutdown the system if the condition is true
fi