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

local pin

-- Load PIN code from file.
function Init()
	if not fs.exists(".ios/auth") then
		io.Cprintln(colors.green, "I don't think I know you.")
		io.Cprintln(colors.lime, "What should I call you?")
		local termd = true
		while termd do
			_G["sys"].Owner, termd = io.ReadInputString(">", false)
		end
		io.Cprintfln(colors.lime, "Hello, %s.", sys.Owner)
		io.Lag(0.5)
		io.Cprintln(colors.lime, "What's the name of this computer?")
		termd = true
		while termd do
			_G["sys"].Name, termd = io.ReadInputString(">", false)
		end
		SetNewPin()
		return true
	end

	file = fs.open(".ios/auth", "r")
	pin = file.readLine()
	_G["sys"].Owner = file.readLine()
	_G["sys"].Name = file.readLine()
	return false
end

-- Ask the user for a new PIN.
function SetNewPin()
	while true do
		io.Cprintln(colors.lime, "Enter a PIN code")
		local pin1 = ""
		local pin2 = ""
		local termd = true
		while termd do
			pin1, termd = io.ReadInputString(">", false, "*")
		end
		io.Cprintln(colors.lime, "Enter the same PIN again")
		termd = true
		while termd do
			pin2, termd = io.ReadInputString(">", false, "*")
		end
		if pin1 == pin2 then
			pin = pin1
			break
		else
			io.Cprintln(colors.red, "The two PINs don't match!")
		end
	end

	local file = fs.open(".ios/auth", "w")
	file.writeLine(pin)
	file.writeLine(sys.Owner)
	file.writeLine(sys.Name)
	file.close()
	io.Cprintln(colors.lime, "PIN updated successfully.")
end

-- Prompt the user for the PIN code.
function PINPrompt()
	if not pin or string.len(pin) == 0 then
		io.Clear()
		io.Cprintln(colors.orange, "\n\n" .. sys.Owner .. "'s " .. sys.DeviceName .. " (locked)")
		io.Cprintln(colors.lime, "\nPress any key to unlock.")
		io.WaitKey()
	else
		local errorMsg = ""
		while true do
			io.Clear()
			io.Cprintln(colors.orange, "\n\n" .. sys.Owner .. "'s " .. sys.DeviceName .. " (locked)")
			io.Cprintln(colors.red, errorMsg)
			io.Newline()
			local givenPIN, termd = io.ReadInputString("  PIN >", false, "*")
			if termd or not givenPIN or string.len(givenPIN) == 0 then
				errorMsg = ""
			elseif pin == givenPIN then
				break
			else
				errorMsg = "Incorrect PIN!"
			end
		end
	end
	io.Clear()
	io.Cprintfln(colors.blue, "Welcome, %s", sys.Owner)
end

function CheckPIN(givenPIN)
	return givenPIN == pin
end

function NewCrypt()
	return crypt.New(pin)
end
