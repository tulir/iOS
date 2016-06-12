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

Aliases = { "help", "manual" }
FillScreen = false

Man = [[Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed posuere interdum sem. Quisque ligula eros ullamcorper quis, lacinia quis facilisis sed sapien. Mauris varius diam vitae arcu. Sed arcu lectus auctor vitae, consectetuer et venenatis eget velit. Sed augue orci, lacinia eu tincidunt et eleifend nec lacus. Donec ultricies nisl ut felis, suspendisse potenti. Lorem ipsum ligula ]]

function Run(alias, args)
	if #args == 0 then
		io.Println("What manual page do you want?")
	elseif #args == 1 then
		local app = main.GetApp(args[1])
		if app and app.Man then
			Manpage(app.Man)
			return
		end
		io.Cprintfln(colors.red, "No manual entry for %s", args[1])
	end
end

function Manpage(data)
	io.Clear()
	local lines = printAndString(data)
	local lineCount = #lines

	local w, h = term.getSize()
	h = h - 2
	local halfHeight = math.floor(h / 2)

	local scroll = 1
	while true do
		term.clear()
		term.setCursorPos(1, 1)
		for i = scroll, scroll + h do
			if lines[i] then io.Print(lines[i]) end
			if i < scroll + h then io.Newline() end
		end
		io.Footer()

		local evt, param = os.pullEvent("key")
		if evt == "terminate" or param == keys.q then
			break
		elseif param == keys.up then
			if scroll > 1 then
				scroll = scroll - 1
			end
		elseif param == keys.down then
			if scroll < lineCount - h then
				scroll = scroll + 1
			end
		elseif param == keys.pageUp then
			if scroll > halfHeight then
				scroll = scroll - halfHeight
			elseif scroll > 1 then
				scroll = 1
			end
		elseif param == keys.pageDown then
			if scroll < lineCount - halfHeight - h then
				scroll = scroll + halfHeight
			elseif scroll < lineCount - h then
				scroll = lineCount - h
			end
		end
	end
	io.Clear()
end

function printAndString(msg)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	local lines = {}

	local function writeLine(line)
		if not lines[#lines] or string.endsWith(lines[#lines], "\n") then
			if lines[#lines] then
				lines[#lines] = string.sub(lines[#lines], 1, string.len(lines[#lines]) - 1)
			end
			lines[#lines + 1] = line
		else
			lines[#lines] = lines[#lines] .. line
		end
	end

	local function newline()
		io.Newline()
		writeLine("\n")
		x, y = term.getCursorPos()
	end

	while string.len(msg) > 0 do
		local whitespace = string.match(msg, "^[ \t]+")
		if whitespace then
			writeLine(whitespace)
			term.write(whitespace)
			x, y = term.getCursorPos()
			msg = string.sub(msg, string.len(whitespace) + 1)
		end

		if string.match(msg, "^\n") then
			newline()
			msg = string.sub(msg, 2)
		end

		local text = string.match(msg, "^[^ \t\n]+")
		if text then
			msg = string.sub(msg, string.len(text) + 1)
			if string.len(text) > w then
				while string.len(text) > 0 do
					if x > w then
						newline()
					end
					writeLine(text)
					term.write(text)
					text = string.sub(text, (w-x) + 2)
					x, y = term.getCursorPos()
				end
			else
				if x + string.len(text) - 1 > w then
					newline()
				end
				writeLine(text)
				term.write(text)
				x, y = term.getCursorPos()
			end
		end
	end
	lines[#lines] = string.sub(lines[#lines], 1, string.len(lines[#lines]) - 1)
	return lines
end
