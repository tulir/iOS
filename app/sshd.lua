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

VERSION = "SSHd 0.1.0"
msgSeparator = string.char(9)
sessions = {}

function Run(args)
    if not net.enabled then
        io.Cprintln(colors.red, "No network adapters found!")
        return
    end
    local port = 22
    if #args > 0 then
        port = tonumber(args[1])
    end
    net.Open(port)
    io.Cprintln(colors.cyan, VERSION .. " listening on port " .. port)

    while true do
        if not sshdListener(port) then break end
    end

    net.Close(port)
    io.Cprintln(colors.orange, VERSION .. " closed!")
end

function runString(code, tEnv)
    if not tEnv then tEnv = {} end

    output = {}
    if not tEnv.term then tEnv.term = {} end
    tEnv.term.write = function(text)
        if not text then text = "" end
        if #output == 0 or not output[#output] or string.sub(output[#output], -1) == "\n" then
            output[#output + 1] = text
        else
            output[#output] = output[#output] .. text
        end
    end
    tEnv.write = tEnv.term.write
    tEnv.print = function(text)
        if not text then text = "" end
        tEnv.term.write(text .. "\n")
    end

    setmetatable(tEnv, {__index = _G})

    local returnVal
    if setfenv and loadstring then
        local f = loadstring(code)
        setfenv(f, tEnv)
        returnVal = { f() }
    else
        returnVal = { load(code, nil, "t", tEnv)() }
    end
    if returnVal ~= nil then
        if type(returnVal) == "string" then
            output[#output + 1] = returnVal
        elseif type(returnVal) == "number" then
            output[#output + 1] = tostring(returnVal)
        elseif type(returnVal) == "table" then
            output[#output + 1] = table.concat(returnVal, ", ")
        elseif type(returnVal) == "function" then
            output[#output + 1] = string.dump(returnVal)
        elseif type(returnVal) == "boolean" then
            if returnVal then output[#output + 1] = "true"
            else output[#output + 1] = "false" end
        else
            output[#output + 1] = "OK"
        end
    end

    output = table.concat(output)
    return output
end

function sshdListener(port)
    local from, to, message, distance = net.Receive()
    distance = tostring(distance)
    local parts = string.split(message, msgSeparator)
    if #parts ~= 2 then
        return true
    end
    if parts[1] == "login" then
        table.remove(parts, 1)
        local c = lock.NewCrypt()
        local msg = c.Flip(table.concat(parts, msgSeparator))
        c.Flip("SecurityViaObscurity>>LoginFlip")
        if lock.CheckPIN(msg) then
            io.Cprintfln(colors.green, "Successful login from %d", from)
            sessions[from] = c
            net.Transmit(port, from, "data" .. msgSeparator .. c.Flip("loggedin" .. msgSeparator .. distance))
        else
            io.Cprintfln(colors.orange, "Failed login from %d", from)
            net.Transmit(port, from, "Invalid PIN" .. msgSeparator .. distance)
        end
        return true
    elseif sessions[from] ~= nil and parts[1] == "msg" then
        local c = sessions[from]
        table.remove(parts, 1)
        local msg = c.Flip(table.concat(parts, msgSeparator))
        c.Flip("SecurityViaObscurity>>MessageFlip")
        parts = string.split(msg, msgSeparator)
        if #parts < 2 then
            return true
        end

        if lock.CheckPIN(parts[1]) then
            table.remove(parts, 1)
            msg = table.concat(parts, msgSeparator)
            if msg == "stop" then
                io.Cprintfln(colors.cyan, "Received stop from client @ %d", from)
                net.Transmit(port, from, "data" .. msgSeparator .. c.Flip("stop" .. msgSeparator .. distance))
                return false
            elseif msg == "exit" or msg == "logout" or msg == "quit" then
                net.Transmit(port, from, "data" .. msgSeparator .. c.Flip("logout" .. msgSeparator .. distance))
                table.remove(sessions, from)
                return true
            end
            io.Cprintfln(colors.cyan, "Executing data from %d:\n%s", from, msg)
            net.Transmit(port, from, "data" .. msgSeparator .. c.Flip("output" .. msgSeparator .. distance .. msgSeparator .. runString(msg)))
        else
            net.Transmit(port, from, "Invalid PIN" .. msgSeparator .. distance)
        end
        return true
    end
end
