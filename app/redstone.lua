-- iOS - A shell for ComputerCraft computers
-- Copyright (C) 2016-2017 Tulir Asokan

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>

Aliases = { "rs" }

function Run(alias, args)
	if #args == 2 then
		args[1] = args[1]:lower()
		if isSide(args[1]) then
			local num = tonumber(args[2])
			if num and num >= 0 and num < 16 then
				redstone.setAnalogOutput(args[1], num)
				io.Cprintfln(colors.blue, "Output %s set to %d.", args[1], num)
			else
				local bool = toBool(args[2])
				redstone.setOutput(args[1], bool)
				io.Cprintfln(colors.blue, "Output %s set to %s.", args[1], tostring(bool))
			end
		else
			io.Cprintln(colors.red, "Usage: redstone <side> <value>")
		end
	else
		io.Cprintln(colors.red, "Usage: redstone <side> <value>")
	end
end

function toBool(str)
	local str = str:lower()
	return str == "true" or str == "yes"
end

function isSide(str)
	for key, value in pairs(redstone.getSides()) do
		if str == value then return true end
	end
	return false
end
