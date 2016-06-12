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
_G["loadFile"] = function(path, required)
	local function loadFail()
		if required then
			os.sleep(3)
			os.shutdown()
		elseif not isReload then
			os.sleep(1)
		end
	end

	if filesLoading[path] == true then
		printError(path.." is already being loaded")
		loadFail()
		return false
	end
	filesLoading[path] = true
	local tEnv = {}
	setmetatable(tEnv, {__index = _G})
	local fnAPI, err = loadfile(path .. ".lua", tEnv)
	if fnAPI then
		local ok, err = pcall(fnAPI)
		if not ok then
			printError(err)
			filesLoading[path] = nil
			loadFail()
			return false
		end
	else
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
	OSVersion = "1.1.0"
}
_G["sys"].NameVersion = sys.OSName .. " " .. sys.OSVersion
if pocket then _G["sys"].DeviceName = "iPhone"
elseif turtle then _G["sys"].DeviceName = "iTurtle"
else _G["sys"].DeviceName = "iMac" end

_G["noArtificialLag"] = fs.exists("/.ios/nolag")

-- Create the user data directory if it doesn't exist
if not fs.isDir("/.ios") then
	fs.makeDir("/.ios")
	fs.makeDir("/.ios/localapps")
	fs.makeDir("/.ios/files")
	fs.open("/.ios/startup.lua", "w").close()
end

local function printLoad(file)
	write("Loading " .. file)
	for i = 1, 3 do
		write(".")
		os.sleep(math.random() / 10)
	end
	write("\n")
end

-- Load the user startup script
printLoad("/.ios/startup")
_G["startup"] = loadFile("/.ios/startup")
if not _G["startup"] then _G["startup"] = {} end

-- Load system scripts
printLoad("/sys/main")
_G["main"] = loadFile("/sys/main", true)
printLoad("/sys/lock")
_G["lock"] = loadFile("/sys/lock", true)

if startup.PreLibs then startup.PreLibs() end
main.LoadLibs() -- Load libraries
if startup.PreApps then startup.PreApps() end
main.LoadApps() -- Load system and user apps
if startup.PreLogin then startup.PreLogin() end
main.StartupLock() -- Activate the startup lock
if startup.PostLogin then startup.PostLogin() end

main.Welcome()
-- Run the main loop and the time updater in parallel
parallel.waitForAny(main.Loop, main.TimeUpdater)
