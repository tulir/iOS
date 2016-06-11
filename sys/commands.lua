-- iOS - A shell for ComputerCraft computers
-- Copyright (C) 2016 Tulir Asokan

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>

shutdown = os.shutdown
reboot = os.reboot
restart = os.reboot
setpin = lock.SetNewPin
lock = lock.PINPrompt
clear = io.Clear

function reload()
	fs.open("/.ios/reload", "w").close()
	os.reboot()
end

function reset()
	io.Cprintln(colors.red, "Are you sure you want to reset everything to factory settings [y/N]?")
	resp = io.ReadInputString(">", false)
	if resp == "y" or resp == "Y" then
		io.Cprint(colors.orange, "Resetting")
		fs.delete("/.ios")
		animate.Dots(5, 0.7, colors.orange, true)
		io.Cprint(colors.blue, "Reset complete. Shutting down.")
		os.sleep(2)
		os.shutdown()
	else
		io.Cprintln(colors.green, "Reset cancelled.")
	end
end

function echo(alias, args)
	io.Println(table.concat(args, " "))
end
