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
#						 -r or --reboot		for a reboot after completing the updates.
#						 -s or --shutdown	for a shutdown after completing the updates.
#						 -c or --clear		for clearing the terminal after completing the updates.
#						 -e or --exit		for close the terminal after completing the updates.
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
shellExit=false

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
        exit 100
        ;;
esac  # end of compatibility check between OS and script

    
# Display the operating system in the terminal or interrupt the script
if [ -n "$distribution" ] && [ -n "$release" ]; then
    echo "-> Your operating system is $distribution $release."
	echo "----------------------------------------------------------------"
else
    echo "-> Your Linux distribution could not be identified."
    exit 101
fi

# Help options
#-------------------------------------------------------------------------------------------------------------------------------------------
if [ "$1" == "-h" ]; then
    echo "#    Your operating system is $systemCompatible. This script is compatible with Ubuntu, Debian, CentOS, Elementary OS, Fedora, Kali Linux, Mageia, Mint, openSUSE, RHEL."
    echo "->   -h | --help              for help"
   #echo "--- essential parameters ----------------------------------------------------------------------"
    echo "--- optional parameter ------------------------------------------------------------------------"
    echo "->   -r | --reboot            restart after completing the updates"
    echo "->   -s | --shutdown          shutdown after completing the updates"
    echo "->   -c | --clear             clean the terminal after completing the update"
	echo "->   -e | --exit				for close the terminal after completing updates."
    
    # for distribution-specific information
    case $distribution_lowercase in
        ubuntu)
            echo "->        --system-upgrade    only for Ubuntu system upgrade | use only for system upgrade (for example, from 20.04 LTS to 22.04 LTS)"
            ;;
        *)
            ;;
    esac # end of compatibility check between OS and script
    
    exit 102
fi