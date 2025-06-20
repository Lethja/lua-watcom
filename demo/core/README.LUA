#!/usr/bin/env lua

-- This is a single line comment, the line above is a shebang for UNIX systems

--[[ This is a multi-line comment.
To run the script, pass it to a lua binary as an argument.
For full Lua language documentation visit https://www.lua.org/docs.html --]]

H=tonumber(os.date('%H'))
T=(H<4 or H>20)and'night'or H<9 and'morning'or H>16 and'evening'or'day'
print('Good '..T..' from '.._VERSION..'.')
print("Press Enter to Exit...")io.read()os.exit()
