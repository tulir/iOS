# iOS
[![License](http://img.shields.io/:license-gpl3-blue.svg?style=flat-square)](http://www.gnu.org/licenses/gpl-3.0.html)

A custom shell for ComputerCraft devices that has some features.

# Features
* Custom shell with clock at bottom
* Custom startup functions at different states of startup
* Bash-like aliasing system
* Locking system
  * PIN code to lock device
  * If empty, the lock screen will simply say "press any key to unlock"
* Commands
  * `shutdown`, `reboot`/`restart` - Manage device power status
  * `setpin` - Change the device pin code
  * `lock` - Lock the device (require pin to unlock)
  * `clear` - Clear the terminal
* App system (local and global)
* Global applications
  * `alias` - Add, remove and view aliases
  * `edit` - Edit files, user apps and startup functions
  * `ls` - List files in a directory
  * `man` (NYI) - Help for commands and applications
  * `redstone` - Control redstone outputs and view inputs
  * `reload` - Reload global and local apps, commands or libraries one at a time or all at once
  * `ssh` - Remote control a device that's running `sshd`
    * Requires the PIN to the server
  * `sshd` - Open a server that `ssh` can connect to
    * All actual communication is encrypted using the servers' PIN
