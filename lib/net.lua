-- iOS - A shell for ComputerCraft computers
-- Copyright (C) 2016-2017 Tulir Asokan

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

modem = peripheral.find("modem")
if modem == nil then
	enabled = false
else
	enabled = true
end

function Open(port)
	modem.open(port)
end

function Close(port)
	modem.close(port)
end

function OpenRandom()
	local port = math.random(32768, 65536)
	modem.open(port)
	return port
end

function Transmit(from, to, data)
	data = string.bytes(data)
	modem.transmit(to, from, data)
end

function Receive(timeout)
	if not timeout then
		local event, modemSide, targetChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		if event == "terminate" then return nil, nil, nil, nil, true end
		message = string.unbytes(message)
		return replyChannel, targetChannel, message, senderDistance, false
	else
		local timeout = os.startTimer(timeout)
		while true do
			event = {os.pullEvent()}
			if event[1] == "terminate" then return nil, nil, nil, nil, true
			elseif event[1] == "modem_message" then
				return event[4], event[3], string.unbytes(event[5]), event[6], false
			elseif event[1] == "timer" and event[2] == timeout then
				return nil, nil, nil, nil, false
			end
		end
	end

end
