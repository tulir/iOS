-- iOS - A shell for ComputerCraft computers
-- Copyright (C) 2016-2017 Tulir Asokan

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

Aliases = { "nano", "touch", "rm", "mkdir" }
FillScreen = true

function Run(alias, args)
	local function editFile(file, name)
		if alias == "touch" then
			local file = fs.open(file, "w")
			if string.endsWith(file, ".lua") then
				file.writeLine("Aliases = {}")
				file.writeLine("")
				file.writeLine("function Run()")
				file.writeLine("  ")
				file.writeLine("end")
			end
			file.close()
			io.Cprintfln(colors.cyan, "%s created.", name)
			return
		elseif alias == "rm" then
			fs.delete(file)
			io.Cprintfln(colors.cyan, "%s removed.", name)
			return
		elseif alias == "mkdir" then
			fs.makeDir(file)
			io.Cprintfln(colors.cyan, "Directory %s created.", string.split(name, " ")[2])
			return
		elseif fs.isDir(file) then
			io.Cprintfln(colors.red, "That is a directory.")
			return
		end

		local fsFile = fs.open(file, "r")
		local dataBefore = nil
		if fsFile then
			dataBefore = fsFile.readAll()
			fsFile.close()
		end

		shell.run("/sys/edit.lua", file)

		local dataAfter = nil
		fsFile = fs.open(file, "r")
		if dataBefore then
			dataAfter = fsFile.readAll()
			fsFile.close()
		end

		io.Clear()
		if not fsFile then
			io.Cprintfln(colors.cyan, "%s not created.", name)
		elseif not dataBefore then
			io.Cprintfln(colors.cyan, "%s created.", name)
		elseif dataBefore == dataAfter then
			io.Cprintfln(colors.cyan, "%s unchanged.", name)
		else
			io.Cprintfln(colors.cyan, "%s updated.", name)
		end
	end

	if #args == 1 then
		if args[1] == "startup" or args[1] == "startup.lua" then
			editFile("/.ios/startup.lua", "Startup file")
		elseif string.endsWith(args[1], ".lua") then
			editFile("/.ios/localapps/" .. args[1], "App " .. string.sub(args[1], 1, -5))
		else
			editFile("/.ios/files/" .. args[1], "File " .. args[1])
		end
	elseif #args == 2 then
		if args[1] == "app" then
			editFile("/.ios/localapps/" .. args[2] .. ".lua", "App " .. args[2])
		elseif string.sub(args[2], -4) == ".lua" then
			io.Cprintln(colors.red, "You may not store lua files outside the app directory.")
		else
			editFile("/.ios/files/" .. args[1] .. "/" .. args[2], "File " .. args[2])
		end
	else
		io.Cprintfln(colors.red, "Usage: %s <file>", alias)
	end
end
