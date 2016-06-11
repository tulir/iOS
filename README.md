# iOS
A custom shell for ComputerCraft devices that has some features.

# Features
* Custom shell with clock at bottom
* Custom startup functions at different states of startup
* Locking system
  * PIN code to lock device
  * If empty, the lock screen will simply say "press any key to unlock"
* Commands
  * `shutdown`, `reboot`/`restart` - Manage device power status
  * `reload` - Quickly reload all applications and commands
  * `setpin` - Change the device pin code
  * `lock` - Lock the device (require pin to unlock)
  * `clear` - Clear the terminal
* App system (local and global)
* Global applications
  * `edit` - Edit files, user apps and startup functions
  * `load` - Reload a global or local app
  * `ls` - List files in a directory
  * `man` (NYI) - Help for commands and applications
  * `redstone` - Control redstone outputs and view inputs
  * `ssh` - Remote control a device that's running `sshd`
    * Requires the PIN to the server
  * `sshd` - Open a server that `ssh` can connect to
    * All actual communication is encrypted using the servers' PIN