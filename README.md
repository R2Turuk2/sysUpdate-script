sysUpdate - Ubuntu System Updater

Overview:
sysUpdate is a Bash script designed by Timon Bachmann for simplifying the process of updating Ubuntu systems. It provides options for system upgrades, automatic reboot, and shutdown after updates.

Features:

System Upgrade: Effortlessly upgrade your Ubuntu system, e.g., from 20.04 LTS to 22.04 LTS.
Automatic Actions: Choose to automatically reboot (-r) or shutdown (-s) after completing updates.
Backup Prompt: Ensures user confirmation for a backup before initiating a system upgrade.
Clear Updates: Provides clear progress messages for package updates, system upgrades, and removal of unnecessary dependencies.
Usage:

Make the script executable: chmod +x sysUpdate.sh
Run the script with desired options:
-h or --help: Display help.
--system-upgrade: Perform a system upgrade.
-r or --reboot: Automatically restart after updates.
-s or --shutdown: Automatically shut down after updates.
Getting Started:

Clone the repository.
Execute the script with the desired options.
Example:

bash
Copy code
./sysUpdate.sh --system-upgrade
Note:
Ensure a backup is made before initiating a system upgrade.

Creator: R2TURUK2
Creation Date: 2024.03.04 15:42:11
Permissions: chmod +x sysUpdate.sh
