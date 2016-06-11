-- iOS - A shell for ComputerCraft computers
-- Copyright (C) 2016 Tulir Asokan

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>

function string.split(str, sep)
	local result = {}
	local regex = ("([^%s]+)"):format(sep)
	for each in str:gmatch(regex) do
		table.insert(result, each)
	end
	return result
end

function string.startsWith(str, prefix)
	return str:sub(1, prefix:len()) == prefix
end

function string.endsWith(str, suffix)
	return str:sub(-suffix:len()) == suffix
end

function string.bytes(str)
	local result = ""
	str:gsub(".", function(c)
		result = result .. tostring(string.byte(c)) .. ","
	end)
	return result
end

function string.unbytes(bytestr)
	local result = ""
	bytestr:gsub("([^,]+)", function(c)
		if string.len(c) == 0 then return end
		local cn = tonumber(c)
		if not cn then return end
		result = result .. string.char(cn)
	end)
	return result
end
