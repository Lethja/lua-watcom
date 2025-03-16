#!/usr/bin/env lua

help = [[
DOS and UNIX disagree on what a new line should be
DOS says it's a carriage return followed by a line feed (CRLF)
while UNIX says it's just a line feed on its own (LF).
Many tools (Lua included) don't care while others like
`TYPE` in DOS and Notepad in Windows will not work correctly.
Tools like unix2dos/dos2unix convert line endings between the systems,
however, in doing so, the CR in CRLF on the shebang line might be
interpreted literally and prevent execution on UNIX systems.

This script named "DOS friend" will convert every line ending of the files
passed to it with CRLF with the exception of the first line when a shebang
is present. When this occurs, the line will instead write LFCRLF so that
both system families can pleasantly read and run the file.
]]

if #arg < 1 then
	print(arg[-1] .. " " .. arg[0] .. " [FILE]..." .. '\n\n' .. help)
	os.exit(1)
end

CR = string.char(0x0D)
LF = string.char(0x0A)
CRLF = CR .. LF

local function StripCarriage(str)
	return str:gsub("[" .. CR .. LF .. "]", "")
end

local function Shebang(inFile)
	inFile:seek("set", 0)
	local l = inFile:read("*l")
	if l:match("^#!") then
		local o = StripCarriage(l) .. LF .. CRLF
		l = inFile:read("*l")
		if l ~= "" and l ~= CR then -- Only write 2nd line if it's not blank
			o = o .. StripCarriage(l) .. CRLF
		end
		return o
	end
	return nil
end

for i = 1, #arg do
	local iFile, err = io.open(arg[i])
	if not iFile then print(arg[i] .. ": " .. err) else
		local oFile
		oFile, err = io.open(arg[i] .. ".tmp", "wb")
		if not oFile then
			print(arg[i] .. ".tmp: " .. err)
		else
			local shebang = Shebang(iFile)
			if shebang then
				oFile:write(shebang)
				while true do
					local line = iFile:read("*l")
					if line then
						oFile:write(StripCarriage(line) .. CRLF)
					else
						break
					end
				end
				iFile:close() oFile:close()

				--[[
					Swap the temporary file and original file around
					so that the original files is being copied to.
					This allows system file permissions to remain unchanged.
				--]]

				iFile = io.open(arg[i] .. ".tmp", "rb")
				oFile = io.open(arg[i], "wb")
				if iFile and oFile then
					while true do
						local data = iFile:read(1024)
						if not data then
							break
						end
						oFile:write(data)
					end
					iFile:close() oFile:close()
				end
			end
			os.remove(arg[i] .. ".tmp")
		end
	end
end
