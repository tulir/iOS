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

function table.slice(table, st, en)
	local sliced = {}
	for i = st or 1, en or #table, 1 do
		sliced[#sliced+1] = tbl[i]
	end
	return sliced
end

function table.toString(t)
	local str = ""
	for key, val in table.pairsByKeys(t) do
		if key and val then
			str = str .. key .. "=" .. val .. "\n"
		end
	end
	str = str:sub(1, str:len() - 1)
	return str
end

function table.fromString(str)
	local result = {}
	for line in str:gmatch(("([^%s]+)"):format("\n")) do
		if line and string.len(line) > 0 then
			local parts = string.split(line, "=")
			local key = parts[1]
			table.remove(parts, 1)
			local value = table.concat(parts, "=")
			result[key] = value
		end
	end
	return result
end

function table.pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
		end
	end
	return iter
end

function table.merge(t1, t2)
	for key, value in pairs(t2) do
		t1[key] = value
	end
	return t1
end
