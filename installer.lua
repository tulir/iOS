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

-- Define the loadFile function that allows lua source files to be loaded
function fatal(message)
	print("[Fatal] ", message)
	exit(1)
end

function formatPath(base, fileName)
	if not base:sub(-1) ~= "/" then
		base = base .. "/"
	end

	if fileName:sub(1, 1) == "/" then
		fileName = fileName:sub(-2)
	end

	return base .. fileName
end

function install(baseURL, directory, data)
	local versions = {}
	for name, value in pairs(data) do
		if type(value) == "number" then
			name = name .. ".lua"
			url = formatPath(baseURL, formatPath(directory, name))
			print("[Trace] ", "Downloading ", url)
			local conn = http.get(url)
			if conn then
				print("[Trace] ", "Reading ", url)
				local fileData = conn.readAll()
				conn.close()
				if fileData then
					print("[Trace] ", "Writing ", formatPath(directory, name))
					local file = fs.open(formatPath(directory, name), "w")
					file.write(fileData)
					file.close()
					versions[name] = value
					print("[Info] ", formatPath(directory, name:sub(1, -5)), " installed.")
				else
					print("[Error] ", "Failed to read ", url)
				end
			else
				print("[Error] ", "Failed to download ", url)
			end
		elseif type(value) == "table" then
			local path = formatPath(directory, name)
			print("[Trace] ", "Creating ", path)
			fs.makeDir(path)
			print("[Trace] ", "Recursing into ", path)
			versions[name] = install(baseURL, path, value)
		else
			print("[Warning] ", "Unknown file definition value type: ", value)
		end
	end
end

local dataPath = "https://raw.githubusercontent.com/tulir/iOS/master/ios.manifest"

local args = {...}
if table.getn(args) > 0 then
	dataPath = args[0]
end

print("[Debug] ", "Downloading file manifest")
local conn = http.get(dataPath)
if not conn then
	fatal("Failed to download file manifest")
end

local rawData = conn.readAll()
conn.close()
if not rawData then
	fatal("Failed to download read manifest")
end

local data = textutils.unserialize(rawData)
if not data then
	fatal("Failed to download parse manifest")
end

print("[Debug] ", "Installing files")
local installedData = {
	files = install(data.baseURL, "", data.files),
	baseURL = data.baseURL,
	version = data.version,
	updatePath = dataPath
}

print("[Debug] ", "Writing manifest")
versionFile = fs.open("ios.manifest", "w")
versionFile.write(textutils.serialize(installedData))
versionFile.close()

print("[Debug] ", "Creating startup file")
startupFile = fs.open("startup", "w")
startupFile.write("os.run({}, \"ios.lua\")")
startupFile.close()
