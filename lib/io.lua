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

local prevIO = 0
DEFAULT_COLOR = colors.lightGray
local cmdHistory = {}

-- Get the timestamp at which an IO event previously happened.
function GetPrevIO()
	return prevIO
end

-- Create artificial lag (if enabled)
function Lag(time, notIfReload)
	if noArtificialLag then return
	elseif notIfReload and isReload then return
	else os.sleep(time) end
end

-- Move the cursor to the next line.
function Newline()
	local x, y = term.getCursorPos()
	local w, h = term.getSize()
	h = h - 1
	if y + 1 <= h then
		term.setCursorPos(1, y + 1)
	else
		Scroll(1)
	end
end

-- Scroll the terminal down `n` lines
function Scroll(n)
	local w, h = term.getSize()
	term.setCursorPos(1, h)
	term.clearLine()
	term.scroll(n)
	term.setCursorPos(1, h - 1)
	Footer()
end

-- Clear the terminal.
function Clear()
	term.clear()
	term.setCursorPos(1, 1)
	Footer()
end

-- Print the terminal footer
function Footer()
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	local oldColor = term.getTextColor()
	term.setCursorPos(1, h)
	SetColor(colors.lime)
	term.write(sys.NameVersion)
	FooterTime(oldColor)
	term.setCursorPos(x, y)
end

-- Update the time in the terminal footer
function FooterTime(oldColor)
	if not oldColor then oldColor = DEFAULT_COLOR end
	local x, y = term.getCursorPos()
	local w, h = term.getSize()
	SetColor(colors.cyan)
	term.setCursorPos(w - 4, h)
	local time = os.time()
	local hour = math.floor(time)
	local minute = math.floor((time - hour) * 60)
	term.write(string.format("%02d:%02d", hour, minute))
	SetColor(oldColor)
	term.setCursorPos(x, y)
end

-- Set the terminal color to the given color (if colors are supported).
function SetColor(color)
	if term.isColor() then
		term.setTextColor(color)
	end
end

-- Print a message with proper line breaking, etc.
function Print(msg)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()

	local lines = 0
	local function newline()
		Newline()
		x, y = term.getCursorPos()
		lines = lines + 1
	end

	while string.len(msg) > 0 do
		local whitespace = string.match(msg, "^[ \t]+")
		if whitespace then
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
					term.write(text)
					text = string.sub(text, (w-x) + 2)
					x, y = term.getCursorPos()
				end
			else
				if x + string.len(text) - 1 > w then
					newline()
				end
				term.write(text)
				x, y = term.getCursorPos()
			end
		end
	end
	prevIO = os.clock()
	return lines
end

-- Format the given message with the given arguments and print it.
function Printf(msg, ...)
	Print(msg:format(...))
end

-- Format the given message with the given arguments, then print it and add a newline.
function Printfln(msg, ...)
	Print(msg:format(...))
	Newline()
end

-- Print the given message and add a newline.
function Println(msg)
	Print(msg)
	Newline()
	prevIO = os.clock()
end

-- Print the given message using the given color.
function Cprint(color, msg)
	SetColor(color)
	Print(msg)
	SetColor(DEFAULT_COLOR)
end

-- Format the given message with the given arguments, then print it using the given color.
function Cprintf(color, msg, ...)
	Cprint(color, msg:format(...))
end

-- Format the given message with the given arguments, then print it using the given color and finally add a newline.
function Cprintfln(color, msg, ...)
	Cprint(color, msg:format(...))
	Newline()
end

-- Print the given message using the given color and add a newline.
function Cprintln(color, msg)
	Cprint(color, msg)
	Newline()
end

-- Wait for the user to press enter
function WaitEnter()
	while true do
		local evt, param = os.pullEvent()
		if evt == "key" and (param == keys.enter or param == keys.numPadEnter) then
			break
		end
	end
end

-- Wait for the user to press a key
function WaitKey()
	os.pullEvent("key")
end

-- Read data from the user until the user presses enter.
function ReadLine(replChar, history)
	term.setCursorBlink(true)

	local sLine = ""
	local termd = false
	local nHistoryPos
	local nPos = 0
	if replChar then
		replChar = string.sub(replChar, 1, 1)
	end

	local w = term.getSize()
	local sx = term.getCursorPos()

	local function redraw(_bClear)
		local nScroll = 0
		if sx + nPos >= w then
			nScroll = (sx + nPos) - w
		end

		local cx,cy = term.getCursorPos()
		term.setCursorPos(sx, cy)
		local sReplace = (_bClear and " ") or replChar
		if sReplace then
			term.write(string.rep(sReplace, math.max(string.len(sLine) - nScroll, 0)))
		else
			term.write(string.sub(sLine, nScroll + 1))
		end

		term.setCursorPos(sx + nPos - nScroll, cy)
	end

	local function clear()
		redraw(true)
	end

	redraw()

	while true do
		local sEvent, param = os.pullEvent()
		prevIO = os.clock()
		if sEvent == "terminate" then
			termd = true
			break
		elseif sEvent == "char" then
			clear()
			sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
			nPos = nPos + 1
			redraw()
		elseif sEvent == "paste" then
			clear()
			sLine = string.sub(sLine, 1, nPos) .. param .. string.sub(sLine, nPos + 1)
			nPos = nPos + string.len(param)
			redraw()
		elseif sEvent == "key" then
			if param == keys.enter or param == keys.numPadEnter then
				break
			elseif param == keys.left then
				if nPos > 0 then
					clear()
					nPos = nPos - 1
					redraw()
				end
			elseif param == keys.right then
				if nPos < string.len(sLine) then
					clear()
					nPos = nPos + 1
					redraw()
				end
			elseif param == keys.up or param == keys.down then
				if history then
					clear()
					if param == keys.up then
						if nHistoryPos == nil then
							if #history > 0 then
								nHistoryPos = #history
							end
						elseif nHistoryPos > 1 then
							nHistoryPos = nHistoryPos - 1
						end
					else
						if nHistoryPos == #history then
							nHistoryPos = nil
						elseif nHistoryPos ~= nil then
							nHistoryPos = nHistoryPos + 1
						end
					end
					if nHistoryPos then
						sLine = history[nHistoryPos]
						nPos = string.len(sLine)
					else
						sLine = ""
						nPos = 0
					end
					redraw()
				end
			elseif param == keys.backspace then
				if nPos > 0 then
					clear()
					sLine = string.sub(sLine, 1, nPos - 1) .. string.sub(sLine, nPos + 1)
					nPos = nPos - 1
					redraw()
				end
			elseif param == keys.home then
				if nPos > 0 then
					clear()
					nPos = 0
					redraw()
				end
			elseif param == keys.delete then
				if nPos < string.len(sLine) then
					clear()
					sLine = string.sub(sLine, 1, nPos) .. string.sub(sLine, nPos + 2)
					redraw()
				end
			elseif param == keys["end"] then
				if nPos < string.len(sLine) then
					clear()
					nPos = string.len(sLine)
					redraw()
				end
			end
		end
	end

	local cx, cy = term.getCursorPos()
	term.setCursorBlink(false)
	term.setCursorPos(w + 1, cy)
	Newline()

	return sLine, termd
end

function ReadInputString(char, history, replChar)
	Cprintf(colors.lime, "%s ", char)
	if history then
		local input, term = ReadLine(replChar, cmdHistory)
		if not term then
			table.insert(cmdHistory, input)
		end
		return input, term
	else
		return ReadLine(replChar)
	end
end

function ReadInput(char, history, replChar)
	Cprintf(colors.lime, "%s ", char)
	local input = ""
	local term = false
	if history then
		input, term = ReadLine(replChar, cmdHistory)
		if not term then
			table.insert(cmdHistory, input)
		end
	else
		input, term = ReadLine(replChar)
	end
	local split = string.split(input, " ")
	local cmd = split[1]
	table.remove(split, 1)
	return cmd, split, term
end
