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
		_G["sys"].Owner = io.ReadInputString(">", false)
		io.Cprintfln(colors.lime, "Hello, %s.", sys.Owner)
        if not noArtificialLag then os.sleep(0.5) end
        io.Cprintln(colors.lime, "What's the name of this computer?")
        _G["sys"].Name = io.ReadInputString(">", false)
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
		local pin1 = io.ReadInputString(">", false, "*")
		io.Cprintln(colors.lime, "Enter the same PIN again")
		local pin2 = io.ReadInputString(">", false, "*")
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
        io.Cprintln(colors.lime, "\nPress enter to unlock.")
        io.WaitKey()
    else
    	local showIncorrectPIN = false
    	while true do
    		io.Clear()
            io.Cprintln(colors.orange, "\n\n" .. sys.Owner .. "'s " .. sys.DeviceName .. " (locked)")
    		if showIncorrectPIN then io.Cprintln(colors.red, "Incorrect PIN!\n")
    		else io.Print("\n\n") end
    		local givenPIN = io.ReadInputString("  PIN >", false, "*")
    		if not givenPIN or string.len(givenPIN) == 0 then
    			showIncorrectPIN = false
    		elseif pin == givenPIN then
    			break
    		else
    			showIncorrectPIN = true
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
