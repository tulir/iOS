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

VERSION = "SSH 0.1.0"
msgSeparator = string.char(9)

function Run(args)
    if not net.enabled then
        io.Cprintln(colors.red, "No network adapters found!")
        return
    end

    if #args < 1 then
        io.Cprintln(colors.red, "Usage: ssh <port>")
        return
    end

    local serverPort = tonumber(args[1])
    if serverPort < 1 or serverPort > 65536 then
        io.Cprintln(colors.red, "The port must be between 1 and 65536")
        return
    end

    io.Cprintln(colors.cyan, "Server PIN")
    local pin = io.ReadInputString(">", false, "*")

    local c = crypt.New(pin)
    local localPort = net.OpenRandom()

    net.Transmit(localPort, serverPort, "login" .. msgSeparator .. c.Flip(pin))
    c.Flip("SecurityViaObscurity>>LoginFlip")
    local from, to, message, distance = net.Receive(3)
    if not from then
        io.Cprintfln(colors.red, "Connection to %d timed out.", serverPort)
        return
    end
    local parts = string.split(message, msgSeparator)
    if parts[1] == "data" then
        io.Cprintln(colors.cyan, VERSION .. " - Logged in @ " .. from)
        table.remove(parts, 1)
        c.Flip(table.concat(parts, msgSeparator))
    else
        io.Cprintln(colors.red, "Login to " .. from .. " failed: " .. parts[1])
        return
    end

    local prefix = tostring(serverPort) .. "$"
    while true do
        local line = io.ReadInputString(prefix, false)
        if line then
            local message = "msg" .. msgSeparator .. c.Flip(pin .. msgSeparator .. line)
            c.Flip("SecurityViaObscurity>>MessageFlip")
            net.Transmit(localPort, serverPort, message)

            sshReceive(c)
        end
    end
end

function sshReceive(c)
    local from, to, message, distance = net.Receive(3)
    if not from then
        io.Cprintfln(colors.red, "Connection to %d timed out.", serverPort)
        return
    end

    local parts = string.split(message, msgSeparator)
    if parts[1] == "data" then
        local msg = c.Flip(parts[2])
        parts = string.split(msg, msgSeparator)
        if parts[1] == "stop" then
            io.Cprintln(colors.cyan, "Connection closed: SSHd stop")
            return
        elseif parts[1] == "logout" then
            io.Cprintln(colors.cyan, "Connection closed: Logout")
            return
        elseif parts[1] == "output" then
            table.remove(parts, 1)
            table.remove(parts, 1)
            msg = table.concat(parts, msgSeparator)
            io.Print(msg)
            if string.sub(msg, -1) ~= "\n" then
                io.Newline()
            end
        end
    else
        io.Cprintfln(colors.red, "Failed to send command to %d: %s", from, parts[1])
        io.Cprintln(colors.red, "Disconnected: Invalid session")
        return
    end
end
