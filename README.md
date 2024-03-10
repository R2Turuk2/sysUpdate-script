# sysUpdate Script

This script has been tested and verified on Ubuntu and Debian.

## Overview
The `sysUpdate` Bash script was developed to simplify the process of updating Linux systems. It supports various distributions, including Ubuntu, Debian, Fedora, openSUSE, CentOS, Kali Linux, and more. The script automatically detects the operating system and its version, then performs the necessary update steps.

## Features
- **System Detection:** The script automatically detects the operating system and its version.
- **Package Update:** It updates the package list and performs various update steps, including package upgrades, system upgrades, and removal of unnecessary dependencies.
- **Snap Package Update:** The script also updates Snap packages if installed.
- **User-Friendly Options:** The script provides optional parameters such as restart, shutdown, and clearing the terminal after completing updates.
- **Support for Ubuntu System Upgrades:** If desired, the script allows an upgrade to a new version of Ubuntu.

## Usage
Execute the script with: `bash ./sysUpdate.sh`
Optional parameters:
- `-h` or `--help`:		Display help and available options.
- `-r` or `--reboot`: 	Restart after completing updates.
- `-s` or `--shutdown`: Shutdown after completing updates.
- `-c` or `--clear`: 	Clear the terminal after completing the update.
- `--system-upgrade`: 	Only for Ubuntu system upgrades (e.g., from 20.04 LTS to 22.04 LTS).

## Note
This script requires the availability of the `lsb_release` command for operating system detection and may require additional packages depending on the distribution.

## Script Information
- **Script Name:** 			`sysUpdate`
- **Script Version:** 		`v2.1`
- **Creator:** 				[GitHub/R2Turuk2](https://github.com/R2Turuk2)
- **Create Date and Time:** 2024.03.09 17:00:00
- **Permissions:** 			`chmod +x sysUpdate.sh`