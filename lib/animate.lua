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

function Dots(prefix, n, intv, color, noNewline, evenIfReload)
	if isReload and not evenIfReload then return
	elseif color == nil or not color then
		color = io.DEFAULT_COLOR
	end

	if prefix then io.Cprint(color, prefix) end
	for i=1,n do
		io.Cprint(color, ".")
		io.Lag(intv)
	end
	if not noNewline then
		io.Newline()
	end
end

function DotsCustom(prefix, n, intvs, color, noNewline, evenIfReload)
	if isReload and not evenIfReload then return
	elseif color == nil or not color then
		color = io.DEFAULT_COLOR
	end

	if prefix then io.Cprint(color, prefix) end
	for i=1,n do
		io.Cprint(color, ".")
		io.Lag(intvs[i])
	end
	if not noNewline then
		io.Newline()
	end
end

function DotsRandom(prefix, n, randDiv, color, noNewline, evenIfReload)
	if isReload and not evenIfReload then return
	elseif color == nil or not color then
		color = io.DEFAULT_COLOR
	end

	if prefix then io.Cprint(color, prefix) end
	for i=1,n do
		io.Cprint(color, ".")
		io.Lag(math.random() / randDiv)
	end
	if not noNewline then
		io.Newline()
	end
end
