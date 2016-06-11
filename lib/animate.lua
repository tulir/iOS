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

function Dots(n, intv, color, newline)
	if color == nil or not color then
		color = io.DEFAULT_COLOR
	end

	for i=1,n do
		io.Cprint(color, ".")
		io.Lag(intv)
	end
	if newline then
		io.Newline()
	end
end

function DotsCustom(n, intvs, color, newline)
	if color == nil or not color then
		color = io.DEFAULT_COLOR
	end

	for i=1,n do
		io.Cprint(color, ".")
		io.Lag(intvs[i])
	end
	if newline then
		io.Newline()
	end
end

function DotsRandom(n, randDiv, color, newline)
	if color == nil or not color then
		color = io.DEFAULT_COLOR
	end

	for i=1,n do
		io.Cprint(color, ".")
		io.Lag(math.random() / randDiv)
	end
	if newline then
		io.Newline()
	end
end
