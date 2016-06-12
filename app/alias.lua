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
		if #args > 1 then
			local cmd = args[1]
			table.remove(args, 1)
			local target = table.concat(args, " ")
			main.AddAlias(cmd, target)
			io.Cprintfln(colors.cyan, "Aliased %s into %s", cmd, target)
		else
			io.Cprintfln(colors.red, "Usage: %s <alias> <command>", alias)
		end
	elseif alias == "unalias" then
		if #args == 1 then
			main.RemoveAlias(args[1])
			io.Cprintfln(colors.cyan, "Removed alias for %s", args[1])
		else
			io.Cprintfln(colors.red, "Usage: %s <alias>", alias)
		end
	end
end

function LoadAliases()
	io.Print("Loading user aliases")
	local file = fs.open("/.ios/aliases", "r")
	local data = file.readAll()
	file.close()
	UserAliases = table.fromString(data)
	animate.DotsRandom(3, 10, io.DEFAULT_COLOR, true)
end

function SaveAliases()
	io.Cprint("Saving aliases")
	local file = fs.open("/.ios/aliases", "w")
	local data = table.toString(UserAliases)
	file.write(data)
	file.close()
	animate.Dots(3, 0.1, io.DEFAULT_COLOR, true)
end

function AddAlias(alias, cmd)
	UserAliases[alias] = cmd
	SaveAliases()
end

function RemoveAlias(alias)
	UserAliases[alias] = nil
	SaveAliases()
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
	end
	return cmd, args
end

if not fs.exists("/.ios/aliases") then
	fs.open("/.ios/aliases", "w").close()
end
LoadAliases()
