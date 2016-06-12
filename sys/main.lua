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

Apps = {}
Aliases = {}

function LoadLibs(isReload)
	local function printLoad(file)
		if not isReload then
			write("Loading /lib/" .. file)
			for i = 1, 3 do
				write(".")
				os.sleep(math.random() / 10)
			end
			write("\n")
		end
	end
	for _, file in ipairs(fs.list("/lib")) do
		file = string.sub(file, 1, string.len(file) - 4)
		printLoad(file)
		_G[file] = loadFile("/lib/" .. file, true, isReload)
	end
end

function LoadApp(dir, file, isReload)
	file = string.sub(file, 1, string.len(file) - 4)
	if not isReload then
		io.Printf("Loading %s%s", dir, file)
		animate.DotsRandom(3, 10, io.DEFAULT_COLOR, true)
	end
	local app = loadFile(dir .. file, false, isReload)
	if app and type(app) == "table" and type(app.Run) == "function" then
		Apps[file] = app
		if app.Aliases then
			for i, alias in ipairs(app.Aliases) do
				Aliases[alias] = file
			end
		end
		return true
	else
		Apps[file] = file
		return false
	end
end

function LoadApps(isReload)
	for _, file in ipairs(fs.list("/app")) do
		LoadApp("/app/", file, isReload)
	end

	if not isReload then
		io.Printf("Loading /sys/commands")
		animate.DotsRandom(3, 10, io.DEFAULT_COLOR, true)
	end
	_G["commands"] = loadFile("/sys/commands", true, isReload)

	for _, file in ipairs(fs.list("/.ios/localapps")) do
		LoadApp("/.ios/localapps/", file, isReload)
	end
end

function StartupLock()
	io.Print("Loading security info")
	animate.Dots(3, 0.1, io.DEFAULT_COLOR, true)
	io.Clear()
	if not lock.Init() and not fs.exists("/.ios/nolock") then
		lock.PINPrompt()
	end
end

function Welcome()
	io.Clear()
	io.Cprintfln(colors.blue, "Welcome, %s", sys.Owner)
end

function TimeUpdater()
	while true do
		if not runningApp or not runningApp.FillScreen then io.FooterTime() end
		os.sleep(0.5)
	end
end

function Loop()
	if startup.PreLoop then startup.PreLoop() end
	while true do
		cmd, args, termd = io.ReadInput("$", true)
		if cmd == "exit" then break
		elseif not termd and cmd then HandleCommand(cmd, args) end
	end
	if startup.PostLoop then startup.PostLoop() end
end

function runCommandFunc(func, alias, args)
	local success, msg = pcall(func, alias, args)
	if not success then io.Cprintln(colors.red, msg) end
end

function runApp(app, alias, args)
	if app then
		if type(app) ~= "table" or type(app.Run) ~= "function" then
			if app == alias then
				io.Cprintfln(colors.red, "App %s wasn't loaded properly. Try reloading it?", app)
			else
				io.Cprintfln(colors.red, "App %s (alias %s) wasn't loaded properly. Try reloading it?", app, alias)
			end
		else
			_G["runningApp"] = app
			runCommandFunc(app.Run, cmd, args)
			_G["runningApp"] = nil
		end
		return true
	end
	return false
end

function HandleCommand(cmd, args)
	cmd = cmd:lower()
	if Apps["alias"] then
		cmd, args = Apps["alias"].HandleAlias(cmd, args)
	end

	if runApp(Apps[cmd], cmd, args) then return end

	local alias = Aliases[cmd]
	if alias and runApp(Apps[alias], cmd, args) then return end

	local func = commands[cmd]
	if func then
		runCommandFunc(func, cmd, args)
		return
	end

	io.Cprintln(colors.red, "Unknown command. Try help for a list of commands")
end
