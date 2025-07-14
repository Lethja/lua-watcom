#!/usr/bin/env lua

local function diff_u(fn1,fn2)
	local function open(fn) local f, e = io.open(fn) if not f then print(e) os.exit(1) end return f end
	local f1, f2, pre, add, del, p1, p2, x, y, h, l1, l2 = open(fn1), open(fn2), {}, {}, {}, 0, 0, 0, 0
	local buf = {add = 0, del = 0, line = {}}
	local function flush_pre()
		if not h then print("--- " .. fn1 .. "\n+++ " .. fn2) h = true end
		for _, v in ipairs(pre) do table.insert(buf.line, " " .. v) end
		buf.ls, buf.rs, pre = x, y, {}
	end
	local function flush_hunk()
		for _, v in ipairs(del) do table.insert(buf.line, "-" .. v) end
		for _, v in ipairs(add) do table.insert(buf.line, "+" .. v) end
		buf.add, buf.del = buf.add + #add, buf.del + #del del, add = {}, {}
	end
	local function flush_buf()
		if #buf.line > 0 then
			local header = "@@ -" .. (buf.ls or "0") .. (buf.del == 1 and "" or "," .. buf.del) ..
					" +" .. (buf.rs or "0") .. (buf.add == 1 and "" or "," .. buf.add) .. " @@"
			table.insert(buf.line, 1, header)
			for _, v in ipairs(buf.line) do print(v) end
		end
		buf.line, buf.add, buf.del, buf.ls, buf.rs = {}, 0, 0, nil, nil
	end
	local function diagonal()
		flush_hunk()
		if #pre >= 3 then table.remove(pre, 1) end
		if #pre <= 0 and p1 > 0 then
			table.insert(buf.line, " " .. l2) p1 = p1 - 1
			if p1 == 0 then flush_buf() end
		else
			table.insert(pre, l2)
		end
		x, y, l1, l2 = x + 1, y + 1, f1:read("*l"), f2:read("*l")
	end
	local function right()
		flush_pre() p1 = 3
		table.insert(del, l1)
		l1 = f1:read("*l")
	end
	local function down()
		flush_pre() p1 = 3
		table.insert(add, l2)
		l2 = f2:read("*l")
	end
	repeat
		if l1 == l2 then diagonal()
		elseif not l2 then right()
		elseif not l1 then down()
		else right() down()
		end

	until not l1 and not l2
	f1:close() f2:close()
	if #add > 0 or #del > 0 then flush_pre() flush_hunk() flush_buf() end
end

if #arg < 2 then return end
diff_u(arg[1], arg[2])
