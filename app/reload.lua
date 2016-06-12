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
		io.Clear()
		w, h = term.getSize()
		--[[ Draw the following box:
			|----------------|
			|Reloading       |
			|----------------|
		]]--
		term.setCursorPos(w / 2 - 8, h / 2 - 1)
		io.Cprint(colors.cyan, "|----------------|")

		term.setCursorPos(w / 2 - 8, h / 2)
		io.Cprint(colors.cyan, "|")
		io.Cprint(colors.blue, "Reloading")
		term.setCursorPos(w / 2 + 9, h / 2)
		io.Cprint(colors.cyan, "|")

		term.setCursorPos(w / 2 - 8, h / 2 + 1)
		io.Cprint(colors.cyan, "|----------------|")

		term.setCursorPos(w / 2 + 2, h / 2)

		-- Animates dots into the box while reloading libraries, apps and commands
		animate.DotsRandom(1, 3, colors.blue)
		main.LoadLibs(true)
		animate.DotsRandom(3, 3, colors.blue)
		main.LoadApps(true)
		animate.DotsRandom(3, 3, colors.blue)

		main.Welcome()
	elseif #args == 1 then
		local dir = ""
		if fs.exists("/app/" .. args[1]) then
			dir = "/app/"
		elseif fs.exists("/.ios/localapps/" .. args[1]) then
			dir = "/.ios/localapps/"
		else
			io.Cprintfln(colors.red, "App %s not found.", args[1])
		end

		if main.LoadApp(dir, args[1]) then
			io.Cprintfln(colors.cyan, "Successfully loaded %s.", args[2])
		else
			io.Cprintfln(colors.red, "Failed to load %s.", args[2])
		end
	elseif #args == 2 then
		local dir = ""
		if args[1] == "g" or args[1] == "global" then
			dir = "/app/"
		elseif args[1] == "l" or args[1] == "local" then
			dir = "/.ios/localapps/"
		else
			io.Cprintfln(colors.red, "Usage: %s [g/l] [app]", alias)
			return
		end

		if main.LoadApp(dir, args[2]) then
			io.Cprintfln(colors.cyan, "Successfully loaded %s.", args[2])
		else
			io.Cprintfln(colors.red, "Failed to load %s.", args[2])
		end
	else
		main.HandleCommand("man reload")
	end
end
