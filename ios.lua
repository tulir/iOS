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
term.setTextColor(colors.lightGray)
os.pullEvent = os.pullEventRaw

_G["shell"] = shell
_G["sys"] = {}

_G["sys"].OSName = "iOS"
_G["sys"].OSVersion = "0.3.0"
_G["sys"].NameVersion = sys.OSName .. " " .. sys.OSVersion

if pocket then _G["sys"].DeviceName = "iPhone"
else _G["sys"].DeviceName = "iMac" end

local isReload = fs.exists("/.ios/reload")

local function fakeSleep(time)
    if not isReload then os.sleep(time) end
end

local filesLoading = {}
function loadFile(path, required, printInfo)
    local function loadFail()
        term.setTextColor(colors.red)
        term.setTextColor(colors.lightGray)
        if required then
    		os.sleep(3)
    		os.shutdown()
        elseif not isReload then
            os.sleep(1)
        end
    end

    if printInfo then write("Loading " .. path) end

    if filesLoading[path] == true then
        write("\n")
        printError(path.." is already being loaded")
        loadFail()
        return false
    end
    filesLoading[path] = true
    fakeSleep(math.random() / 8)
    if printInfo then write(".") end
    local tEnv = {}
    setmetatable(tEnv, {__index = _G})
    local fnAPI, err = loadfile(path .. ".lua", tEnv)
    if fnAPI then
        local ok, err = pcall(fnAPI)
        if not ok then
            if printInfo then write("\n") end
            printError(err)
            filesLoading[path] = nil
            loadFail()
            return false
        end
        fakeSleep(math.random() / 8)
        if printInfo then write(".") end
    else
        if printInfo then write("\n") end
        printError(err)
        filesLoading[path] = nil
        loadFail()
        return false
    end

    local tAPI = {}
    for k,v in pairs(tEnv) do
        if k ~= "_ENV" then
            tAPI[k] =  v
        end
    end
    fakeSleep(math.random() / 8)
    if printInfo then print(".") end

    filesLoading[path] = nil
    return tAPI
end

term.clear()
term.setCursorPos(1, 1)

if not fs.isDir("/.ios") then
	fs.makeDir("/.ios")
	fs.makeDir("/.ios/localapps")
	fs.makeDir("/.ios/files")
	fs.open("/.ios/startup.lua", "w").close()
end

_G["startup"] = loadFile("/.ios/startup", false, true)
if not startup then startup = {} end

_G["lock"] = loadFile("/sys/lock", true, true)
_G["commands"] = loadFile("/sys/commands", true, true)

if startup.PreLibs then startup.PreLibs() end

-- Load everything in the library directory into the global namespace.
for _, file in ipairs(fs.list("/lib")) do
    file = string.sub(file, 1, string.len(file) - 4)
    _G[file] = loadFile("/lib/" .. file, true, true)
end

if startup.PreApps then startup.PreApps() end

_G["apps"] = {}
_G["aliases"] = {}
_G["loadApp"] = function(dir, file, printInfo)
    file = string.sub(file, 1, string.len(file) - 4)
    local app = loadFile(dir .. file, false, printInfo)
    if app and type(app) == "table" and type(app.Run) == "function" then
        _G["apps"][file] = app
        if app.Aliases then
            for i, alias in ipairs(app.Aliases) do
                _G["aliases"][alias] = file
            end
        end
        return true
    else
        _G["apps"][file] = file
        return false
    end
end

-- Load everything in the apps directory into the apps table.
for _, file in ipairs(fs.list("/app")) do
    loadApp("/app/", file, true)
end

-- Load the users own apps into the apps table.
for _, file in ipairs(fs.list("/.ios/localapps")) do
    loadApp("/.ios/localapps/", file, true)
end

if startup.PreLogin then startup.PreLogin() end

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

local function commandRun(func, args)
    local success, msg = pcall(func, args)
    if not success then io.Cprintln(colors.red, msg) end
end

local function commandLoop(cmd, args)
    app = apps[cmd]
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

    alias = aliases[cmd]
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

isReload = false
_G["runningApp"] = nil

function timeUpdater()
    while true do
        if not runningApp or not runningApp.FillScreen then io.FooterTime() end
        os.sleep(0.5)
    end
end

if startup.PostLogin then startup.PostLogin() end
io.Clear()
io.Cprintfln(colors.blue, "Welcome, %s", sys.Owner)
function mainLoop()
    if startup.PreLoop then startup.PreLoop() end
    while true do
    	cmd, args = io.ReadInput("$", true)
        if cmd == "exit" then break
        elseif cmd then commandLoop(cmd, args) end
    end
    if startup.PostLoop then startup.PostLoop() end
end

parallel.waitForAny(mainLoop, timeUpdater)
