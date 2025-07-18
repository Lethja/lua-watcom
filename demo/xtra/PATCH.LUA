#!/usr/bin/env lua

local function patch(p)
	local pf, e = io.open(p)
	if not pf then print(e) os.exit(1) end
	for l in pf:lines() do
		local ls = l:sub(1, 1)
		if ls == "+" then
			if l:sub(2,4) == "++ " then
				--TODO: New file
			else
				--TODO: Add Line
			end
		elseif ls == '-' then
			if l:sub(2,4) == "-- " then
				--TODO: Old file
			else
				--TODO: Del Line
			end
		elseif ls == ' ' then
			--TODO: context line verification
		end
	end
	pf:close()
end

if #arg < 1 then os.exit(1) end
patch(arg[1], arg[2])
