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

Aliases = { "load" }

function Run(alias, args)
	if #args == 0 then
		_G["isReload"] = true
		io.Clear()
		w, h = term.getSize()
		--[[ Draw the following box:
			|----------------|
			|Reloading       |
			|----------------|
		]]--
		term.setCursorPos(w / 2 - 8, 2)
		io.Cprint(colors.cyan, "|----------------|")

		term.setCursorPos(w / 2 - 8, 3)
		io.Cprint(colors.cyan, "|")
		io.Cprint(colors.blue, "Reloading")
		term.setCursorPos(w / 2 + 9, 3)
		io.Cprint(colors.cyan, "|")

		term.setCursorPos(w / 2 - 8, 4)
		io.Cprint(colors.cyan, "|----------------|")

		term.setCursorPos(w / 2 + 2, 3)

		-- Animates dots into the box while reloading libraries, apps and commands
		animate.DotsRandom(nil, 1, 3, colors.blue, true, true)

		term.setCursorPos(1, 5)
		main.LoadLibs()
		term.setCursorPos(w / 2 + 3, 3)

		animate.DotsRandom(nil, 3, 3, colors.blue, true, true)

		term.setCursorPos(1, 5)
		main.Apps = {}
		main.Aliases = {}
		main.LoadApps()
		term.setCursorPos(w / 2 + 6, 3)

		animate.DotsRandom(nil, 3, 3, colors.blue, true, true)
		_G["isReload"] = false

		main.Welcome()
	elseif #args == 1 then
		app = args[1] .. ".lua"
		local dir = ""
		if fs.exists("/app/" .. app) then
			dir = "/app/"
		elseif fs.exists("/.ios/localapps/" .. app) then
			dir = "/.ios/localapps/"
		else
			io.Cprintfln(colors.red, "App %s not found.", args[1])
			return
		end

		if main.LoadApp(dir, app, true) then
			io.Cprintfln(colors.cyan, "Successfully loaded %s.", args[1])
		else
			io.Cprintfln(colors.red, "Failed to load %s.", args[1])
		end
	elseif #args == 2 then
		app = args[2] .. ".lua"
		local dir = ""
		if args[1] == "g" or args[1] == "global" then
			dir = "/app/"
		elseif args[1] == "l" or args[1] == "local" then
			dir = "/.ios/localapps/"
		else
			io.Cprintfln(colors.red, "Usage: %s [g/l] [app]", alias)
			return
		end

		if main.LoadApp(dir, app, true) then
			io.Cprintfln(colors.cyan, "Successfully loaded %s.", args[2])
		else
			io.Cprintfln(colors.red, "Failed to load %s.", args[2])
		end
	else
		main.HandleCommand("man reload")
	end
end
