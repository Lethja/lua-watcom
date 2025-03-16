#!/usr/bin/env lua

-- This is a single line comment, the line above is a shebang for UNIX systems

--[[ This is a multi-line comment. To run the script, pass it to the lua binary
 as an argument (`LUA16.EXE EXAMPLE.LUA` on 16-bit DOS for example).
 For full Lua language documentation visit https://www.lua.org/docs.html --]]

hour = tonumber(os.date('%H')) -- Get the hour of day from clock
if hour < 4 or hour > 20 then -- Convert hour into fuzzy time of day
	timeOfDay = 'night'
elseif hour < 9 then
	timeOfDay = 'morning'
elseif hour > 16 then
	timeOfDay = 'evening'
else
	timeOfDay = 'day'
end

print('Good ' .. timeOfDay .. ' from ' .. _VERSION .. '.') -- Print a greeting
print("Press Enter to Exit...") io.read() -- Wait for Enter to be pressed
os.exit() -- Exit the script. Will also exit an interactive shell
