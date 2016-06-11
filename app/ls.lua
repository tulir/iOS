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
	local files = {}
	local directories = {}
	local dir = nil
	local longestName = 0
	local w, h = term.getSize()
	local maxLength = w - 6

	if #args == 0 then
		directories["app"] = "N/A"
		longestName = string.len("app")
		if fs.exists("/.ios/startup.lua") then
			files["startup"] = fs.getSize("/.ios/startup.lua")
			longestName = string.len("startup")
		end

		dir = "/.ios/files"
	elseif #args == 1 then
		if args[1] == "app" then
			dir = "/.ios/localapps"
		else
			dir = "/.ios/files/" .. args[1]
		end
	else return end

	if dir then
		for _, file in ipairs(fs.list(dir)) do
			local name = file
			local len = string.len(file)

			if len > maxLength then
				name = string.sub(file, 1, maxLength - 2) .. ".."
			elseif len > longestName then
				longestName = len
			end

			if fs.isDir(file) then directories[name] = fs.getSize(dir .. "/" .. file)
			else files[name] = fs.getSize(dir .. "/" .. file) end
		end
	end

	local x, y = term.getCursorPos()
	term.setTextColor(colors.white)
	term.write("file")
	term.setTextColor(colors.cyan)
	term.write("/")
	term.setTextColor(colors.green)
	term.write("dir")
	term.setTextColor(colors.cyan)
	term.write(" name")
	term.setCursorPos(maxLength, y)
	term.write("Size")
	io.Newline()

	local function printFile(file, size)
		x, y = term.getCursorPos()
		term.write(file)
		term.setCursorPos(maxLength, y)
		term.write(size)
		io.Newline()
	end

	term.setTextColor(colors.green)
	for file, size in pairs(directories) do
		printFile(file, size)
	end

	term.setTextColor(colors.white)
	for file, size in pairs(files) do
		if string.endsWith(file, ".lua") then
			file = string.sub(file, 1, string.len(file) - 4)
		end
		printFile(file, size)
	end

	term.setTextColor(io.DEFAULT_COLOR)
end
