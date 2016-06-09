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

function LoadLibs()
	for _, file in ipairs(fs.list("/lib")) do
	    file = string.sub(file, 1, string.len(file) - 4)
	    _G[file] = loadFile("/lib/" .. file, true, isReload)
	end
end

function LoadApp(dir, file, printInfo)
    file = string.sub(file, 1, string.len(file) - 4)
    local app = loadFile(dir .. file, false, printInfo)
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

function LoadApps()
	for _, file in ipairs(fs.list("/app")) do
	    LoadApp("/app/", file, true)
	end

	for _, file in ipairs(fs.list("/.ios/localapps")) do
	    LoadApp("/.ios/localapps/", file, true)
	end
end

function StartupLock()
	if not isReload then
	    io.Print("Loading security info")
	    animate.Dots(3, 0.1, io.DEFAULT_COLOR, true)
	end
	io.Clear()
	if not lock.Init() then
	    if isReload then
	    	fs.delete("/.ios/reload")
	        -- Reload bar
	        w, h = term.getSize()
	        term.setCursorPos(w / 2 - 8, h / 2 - 1)
	        io.Cprint(colors.cyan, "|----------------|")
	        term.setCursorPos(w / 2 - 8, h / 2 + 1)
	        io.Cprint(colors.cyan, "|----------------|")
	        term.setCursorPos(w / 2 - 8, h / 2)
	        io.Cprint(colors.cyan, "|")
	        io.Cprint(colors.blue, "Reloading")
	        term.setCursorPos(w / 2 + 9, h / 2)
	        io.Cprint(colors.cyan, "|")
	        term.setCursorPos(w / 2 + 2, h / 2)
	        animate.DotsRandom(7, 3, colors.blue, true)
	        -- End reload bar
	    elseif not fs.exists("/.ios/nolock") then
	    	lock.PINPrompt()
	    end
	end
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
    	cmd, args = io.ReadInput("$", true)
        if cmd == "exit" then break
        elseif cmd then commandLoop(cmd, args) end
    end
    if startup.PostLoop then startup.PostLoop() end
end

function commandRun(func, args)
    local success, msg = pcall(func, args)
    if not success then io.Cprintln(colors.red, msg) end
end

function commandLoop(cmd, args)
    app = Apps[cmd]
    if app then
        if type(app) ~= "table" or type(app.Run) ~= "function" then
            io.Cprintfln(colors.red, "App %s wasn't loaded properly. Try load <app>", app)
        else
            _G["runningApp"] = app
            commandRun(app.Run, args)
            _G["runningApp"] = nil
        end
        return
    end

    alias = Aliases[cmd]
    if alias then
        app = apps[alias]
        if app then
            if type(app) ~= "table" or type(app.Run) ~= "function" then
                io.Cprintfln(colors.red, "App %s (alias %s) wasn't loaded properly. Try load <app>", app, alias)
            else
                _G["runningApp"] = app
                commandRun(app.Run, args)
                _G["runningApp"] = nil
            end
            return
        end
    end

	func = commands[cmd]
	if func then
        commandRun(func, args)
        return
    end

	io.Cprintln(colors.red, "Unknown command. Try help for a list of commands")
end