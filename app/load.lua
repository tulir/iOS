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

function Run(alias, args)
	if #args ~= 2 then
		io.Cprintln(colors.red, "Usage: load <g/l> <app>")
		return
	end

	local loaded = false
	if args[1] == "g" or args[1] == "global" then
		loaded = main.LoadApp("/app/", args[2], false)
	elseif args[1] == "l" or args[1] == "local" then
		loaded = main.LoadApp("/.ios/localapps/", args[2], false)
	else
		io.Cprintln(colors.red, "Usage: load <g/l> <app>")
		return
	end

	if not loaded then io.Cprintfln(colors.red, "Failed to load %s.", args[2])
	else io.Cprintfln(colors.cyan, "Successfully loaded %s.", args[2]) end
end
