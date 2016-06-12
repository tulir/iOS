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

Aliases = { "unalias" }
UserAliases = {}

function Run(alias, args)
	if alias == "alias" then
		if #args == 1 then
			local cmd = args[1]:lower()
			local target = UserAliases[cmd]
			if target then
				io.Cprintfln(colors.cyan, "%s is aliased to %s", cmd, target)
			else
				io.Cprintfln(colors.red, "%s is not aliased.", cmd)
			end
		elseif #args > 1 then
			local cmd = args[1]:lower()
			table.remove(args, 1)
			local target = table.concat(args, " ")
			AddAlias(cmd, target)
			io.Cprintfln(colors.cyan, "Aliased %s into %s", cmd, target)
		else
			io.Cprintfln(colors.red, "Usage: %s <alias> <command>", alias)
		end
	elseif alias == "unalias" then
		if #args == 1 then
			RemoveAlias(args[1])
			io.Cprintfln(colors.cyan, "Removed alias for %s", args[1])
		else
			io.Cprintfln(colors.red, "Usage: %s <alias>", alias)
		end
	end
end

function LoadAliases(quick)
	if not quick then animate.DotsRandom("Loading user aliases", 3, 10) end
	local file = fs.open("/.ios/aliases", "r")
	local data = file.readAll()
	file.close()
	UserAliases = table.fromString(data)
end

function SaveAliases(quick)
	if not quick then animate.DotsRandom("Saving user aliases", 3, 10) end
	local file = fs.open("/.ios/aliases", "w")
	local data = table.toString(UserAliases)
	file.write(data)
	file.close()
end

function AddAlias(alias, cmd)
	UserAliases[alias] = cmd
	SaveAliases(true)
end

function RemoveAlias(alias)
	UserAliases[alias] = nil
	SaveAliases(true)
end

function HandleAlias(cmd, args)
	local userAlias = UserAliases[cmd]
	if userAlias then
		if string.contains(userAlias, " ") then
			local parts = string.split(userAlias, " ")
			cmd = parts[1]
			table.remove(parts, 1)
			for i = 1, #args do
				parts[#parts + 1] = args[i]
			end
			args = parts
		else
			cmd = userAlias
		end
		cmd = cmd:lower()
	end
	return cmd, args
end

if not fs.exists("/.ios/aliases") then
	fs.open("/.ios/aliases", "w").close()
end
LoadAliases()
