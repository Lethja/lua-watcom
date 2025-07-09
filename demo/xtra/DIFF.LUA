local function open(filename)
	local f,e=io.open(filename)
	if not f then print(e) os.exit(1) end
	return f
end

local function blocks(f1, f2)
	local bs, b = 4096, {}
	repeat
		local l, r, lines, data = f1:read(bs), f2:read(bs), {}, nil
		if l then _, lines.l = string.gsub(l,"\n", "\n") end
		if r then _, lines.r = string.gsub(r,"\n", "\n") end
		if l ~= r then data = { l = l, r = r } end
		if lines.l or lines.r then
		  table.insert(b, { data = data, lines = lines })
		end
	until not l and not r
	return b
end

local function lines(str, prev)
	local l, last = {}

	for line, newline in str:gmatch("([^\n]*)(\n?)") do
		if newline ~= "\n" then last = line else table.insert(l, line) end
	end

	if prev and #l > 0 then l[1] = prev .. l[1] end
	return l, last
end

local function diff_u(fn1,fn2)
	local f1, f2 = open(fn1), open(fn2)
	local diff_b, dl, dr, tl, tr = blocks(f1, f2)
	f1:close() f2:close()

	if diff_b then
		for _, v in ipairs(diff_b) do
			dl, tl = lines(v.data.l, tl)
			dr, tr = lines(v.data.r, tr)
			local max = #dl > #dr and #dl or #dr

			for k = 1, max do
				if dl[k] ~= dr[k] then
					print("-"..dl[k].."\n+"..dr[k].."\n")
				end
			end
		end
	end
end

if #arg < 2 then return end
diff_u(arg[1], arg[2])
