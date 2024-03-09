#!/bin/bash
#header----------------------------------------------------------------------------------------
# scriptname:            sysUpdate
# scriptversion:         v2.0.0
# creator:               GitHub/R2Turuk2
# create datetime:       2024.03.09 17:00:00
# permissions:           chmod +x sysUpdate.sh

# script description:    This Bash script is designed to simplify the process of updating
#						 Linux systems. It supports various distributions, including Ubuntu,
#						 Debian, Fedora, openSUSE, CentOS, Kali Linux, and more. The script
#						 automatically checks compatibility with the operating system and 
#						 then performs the necessary update steps.

# features:				 System Detection: The script automatically recognizes the operating
#										   system and its version.

#						 Package Update:   It updates the package list and then carries out
#										   various update steps, including package upgrades,
#										   system upgrades, and the removal of unnecessary
#										   dependencies.

#						 Snap Package Update:   The script also updates Snap packages, if
#												installed.

#						 User-Friendly Options: The script provides optional parameters such
#												as reboot, shutdown, and clearing the
#												terminal after completing updates.

#						 Support for Ubuntu..	If desired, the script allows
#						 System Upgrades:	 	upgrading to a new version of Ubuntu.

# usage:				 Run the script with ./sysUpdate.sh.
# optional parameters:	 -h or --help		for help and available options.
#						 -r or --reboot		for a reboot after completing updates.
#						 -s or --shutdown	for a shutdown after completing updates.
#						 -c or --clear		for clearing the terminal after completing updates.
#						 --system-upgrade	only for Ubuntu system upgrades (e.g. from 20.04 LTS to 22.04 LTS).

# note:					 This script requires the availability of the 'lsb_release' command for
#						 operating system detection and may require additional packages depending
#						 on the distribution.
#script----------------------------------------------------------------------------------------

# Initialize global variables with default values
#-------------------------------------------------------------------------------------------------------------------------------------------
sysUpgrade=false
sysShutdown=false
sysReboot=false
shellClear=false

# Check if lsb_release is available
#-------------------------------------------------------------------------------------------------------------------------------------------
if ! command -v lsb_release &> /dev/null; then
    echo "The command 'lsb_release' is not available on this system. Please install the package to proceed."

    # Check the distribution and suggest manual installation commands
    if command -v apt &> /dev/null; then
        echo "Try installing 'lsb-release' with the following command:"
        echo "  sudo apt install lsb-release"
    elif command -v yum &> /dev/null; then
        echo "Try installing 'lsb-release' with the following command:"
        echo "  sudo yum install redhat-lsb-core"
    elif command -v dnf &> /dev/null; then
        echo "Try installing 'lsb-release' with the following command:"
        echo "  sudo dnf install redhat-lsb-core"
    elif command -v zypper &> /dev/null; then
        echo "Try installing 'lsb-release' with the following command:"
        echo "  sudo zypper install lsb-release"
    else
        echo "Unable to determine the package manager for automatic installation."
        echo "Please manually install 'lsb-release' using the appropriate package manager for your system."
    fi

    exit 1
fi

# Identify the operating system
#-------------------------------------------------------------------------------------------------------------------------------------------
if [ "$os" == "Linux" ]; then
    distribution=$(lsb_release -si 2>/dev/null)
    release=$(lsb_release -sr 2>/dev/null)
    
    # Check compatibility between OS and script
    distribution_lowercase=$(echo "$distribution" | tr '[:upper:]' '[:lower:]')
    case $distribution_lowercase in
        ubuntu)
            systemCompatible="compatible"
            break
            ;;
        debian)
            systemCompatible="compatible"
            break
            ;;
        fedora)
            systemCompatible="compatible"
            break
            ;;
        opensuse)
            systemCompatible="compatible"
            break
            ;;
        centos)
            systemCompatible="compatible"
            break
            ;;
        kali)
            systemCompatible="compatible"
            break
            ;;
        *)
            systemCompatible="incompatible"
            exit 100
            ;;
    esac # end of compatibility check between OS and script
    
    # Display the operating system in the terminal or interrupt the script
    if [ -n "$distribution" ] && [ -n "$release" ]; then
        echo "Your operating system is $distribution $release."
    else
        echo "Your Linux distribution could not be identified."
        exit 101
    fi
    echo "----------------------------------------------------------------"
else
    echo "This script is not available for your operating system: $os."
    exit
fi # end of identify the operating system

# Help options
#-------------------------------------------------------------------------------------------------------------------------------------------
if [ "$1" == "-h" ]; then
    echo "#    This script is compatible with Ubuntu, Debian, CentOS, Elementary OS, Fedora, Kali Linux, Mageia, Mint, openSUSE, RHEL."
    echo "#    Your operating system is $systemCompatible."
    echo "->   -h | --help              for help"
    #echo "--- essential parameters ----------------------------------------------------------------------"
    echo "--- optional parameter ------------------------------------------------------------------------"
        echo "->   -r | --reboot            restart after completing the updates"
    echo "->   -s | --shutdown          shutdown after completing the updates"
    echo "->   -c | --clear             clean the terminal after completing the update"
    
    # for distribution-specific information
    case $distribution_lowercase in
        ubuntu)
            echo "->        --system-upgrade    only for Ubuntu system upgrade | use only for system upgrade (for example, from 20.04 LTS to 22.04 LTS)"
            break
            ;;
        *)
            break
            ;;
    esac # end of compatibility check between OS and script
    
    exit 102
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

# Pass all parameters to the function
#-------------------------------------------------------------------------------------------------------------------------------------------
set_parameters "$@"

# Start update script
#-------------------------------------------------------------------------------------------------------------------------------------------
case $distribution_lowercase in
    
    # for Ubuntu, Mint
    #-------------------------------------------------------------------------------------------------------------------------------------------
    ubuntu)
        echo "----------------------------------------------------------------"
        echo "-> The package list is now being updated."
        echo "----------------------------------------------------------------"
        sudo apt update # Updates the package list from all defined package sources.
        
        if [ "$sysUpgrade" = true ]; then
            read -p "-> Was a backup made? If yes, continue? [Y/n] " sysUpgradeContinue
            if [ "$sysUpgradeContinue" = "Y" ] || [ "$sysUpgradeContinue" = "y" ]; then  
                echo "----------------------------------------------------------------"
                echo "-> Your system is now being upgraded!"
                echo "----------------------------------------------------------------"
                sudo do-release-upgrade # Initiates the upgrade process to a new Ubuntu release if available.
            else
                exit 201
            fi
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

        
        echo "----------------------------------------------------------------"
        echo "-> Snap packages have been updated"
        echo "----------------------------------------------------------------"
        sudo snap refresh -y # Updates Snap packages, if installed.

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

        
        echo "----------------------------------------------------------------"
        echo "-> Snap packages have been updated"
        echo "----------------------------------------------------------------"
        sudo snap refresh -y # Updates Snap packages, if installed.

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
        
        echo "----------------------------------------------------------------"
        echo "-> Your system should now be up to date."
        echo "----------------------------------------------------------------"
        
        ;; # end
    #-------------------------------------------------------------------------------------------------------------------------------------------

# Instructions to end the script
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