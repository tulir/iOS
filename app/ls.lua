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
	if #args == 0 then
		io.Cprintln(colors.green, "app")
		if fs.exists("/.ios/startup.lua") then
			io.Cprintln(colors.white, "startup")
		end

		for _, file in ipairs(fs.list("/.ios/files")) do
			if fs.isDir(file) then io.Cprintln(colors.green, file)
			else io.Cprintln(colors.white, file) end
		end
	elseif #args == 1 then
		if args[1] == "app" then
			for _, file in ipairs(fs.list("/.ios/localapps")) do
				if fs.isDir then io.Cprintln(colors.green, file)
				else io.Cprintln(colors.white, file) end
			end
		else
			for _, file in ipairs(fs.list("/.ios/files/" .. args[1])) do
				if fs.isDir then io.Cprintln(colors.green, file)
				else io.Cprintln(colors.white, file) end
			end
		end
	end
end
