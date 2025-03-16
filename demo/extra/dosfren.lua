#!/usr/bin/env lua


--[[
	DOS and UNIX disagree on what a new line should be
	DOS says it's a carriage return followed by a line feed (CRLF)
	while UNIX says it's just a line feed on its own (LF).
	Many tools (Lua included) don't care while others like
	`TYPE` in DOS and Notepad in Windows will not display correctly.
	Tools like unix2dos/dos2unix exist convert line endings between the systems,
	however, in doing so, the CR in CRLF on the shebang line might be
	interpreted literally and prevent correct execution on UNIX systems.

	This script named "DOS friend" will convert every line ending of the files
	passed to it with CRLF with the exception of the first line when a shebang
	is present. When this occurs, the line will instead write LFCRLF so that
	both types of systems can pleasantly read and run the file.
--]]

LF = string.char(0x0A)
CRLF = string.char(0x0D) .. LF

local function Shebang(inFile)
	inFile:seek("set", 0)
	local line1 = inFile:read("*l")
	if line1:match("^#!") then
		return line1 .. LF .. CRLF
	end
	return nil
end

if #arg < 1 then
	print(arg[-1] .. " " .. arg[0] .. " [FILE]...")
	os.exit(1)
end

for i = 1, #arg do
	local inFile, err = io.open(arg[i])
	if not inFile then print(arg[i] .. ": " .. err) else
		local outFile
		outFile, err = io.open(arg[i] .. ".tmp", "wb")
		if not outFile then
			print(arg[i] .. ".tmp: " .. err)
		else
			local shebang = Shebang(inFile)
			if shebang then
				outFile:write(shebang)
				while true do
					local line = inFile:read("*l")
					if line then
						outFile:write(line .. CRLF)
					else
						break
					end
				end
				inFile:close() outFile:close()
				os.remove(arg[i])
				os.rename(arg[i] .. ".tmp", arg[i])
			else
				inFile:close() outFile:close()
				os.remove(arg[i] .. ".tmp")
			end
		end
	end
end
