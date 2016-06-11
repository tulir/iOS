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

-- Define the loadFile function that allows lua source files to be loaded
local filesLoading = {}
_G["loadFile"] = function(path, required, printInfo)
	local function lag(time)
		if noArtificialLag or isReload then return
		else os.sleep(time) end
	end

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
	lag(math.random() / 10)
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
		lag(math.random() / 10)
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
	lag(math.random() / 10)
	if printInfo then print(".") end

	filesLoading[path] = nil
	return tAPI
end

-- Set default color
term.setTextColor(colors.lightGray)
-- Clear the output of the underlying OS
term.clear()
term.setCursorPos(1, 1)

-- Don't allow termination and other nasty things -> replace pullEvent with pullEventRaw
os.pullEvent = os.pullEventRaw
-- Allow the Shell API to be accessed in apps and libs
_G["shell"] = shell

-- Set system information
_G["sys"] = {
	OSName = "iOS",
	OSVersion = "1.0.0"
}
_G["sys"].NameVersion = sys.OSName .. " " .. sys.OSVersion
if pocket then _G["sys"].DeviceName = "iPhone"
else _G["sys"].DeviceName = "iMac" end

-- Check if the device is being reloaded (rather than rebooted)
_G["isReload"] = fs.exists("/.ios/reload")
_G["noArtificialLag"] = fs.exists("/.ios/nolag")

-- Create the user data directory if it doesn't exist
if not fs.isDir("/.ios") then
	fs.makeDir("/.ios")
	fs.makeDir("/.ios/localapps")
	fs.makeDir("/.ios/files")
	fs.open("/.ios/startup.lua", "w").close()
end

-- Load the user startup script
_G["startup"] = loadFile("/.ios/startup", false, not isReload)
if not startup then startup = {} end

-- Load system scripts
_G["main"] = loadFile("/sys/main", true, not isReload)
_G["lock"] = loadFile("/sys/lock", true, not isReload)

if startup.PreLibs then startup.PreLibs() end
main.LoadLibs() -- Load libraries
if startup.PreApps then startup.PreApps() end
main.LoadApps() -- Load system and user apps
_G["commands"] = loadFile("/sys/commands", true, not isReload)
if startup.PreLogin then startup.PreLogin() end
main.StartupLock() -- Activate the startup lock

-- Unset isReload so it wouldn't affect anything
_G["isReload"] = false

if startup.PostLogin then startup.PostLogin() end

-- Clear terminal and welcome user
io.Clear()
io.Cprintfln(colors.blue, "Welcome, %s", sys.Owner)

-- Run the main loop and the time updater in parallel
parallel.waitForAny(main.Loop, main.TimeUpdater)
