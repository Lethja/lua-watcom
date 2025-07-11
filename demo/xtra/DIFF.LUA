local function open(filename)
	local f,e=io.open(filename)
	if not f then print(e) os.exit(1) end
	return f
end

local function diff_u(fn1,fn2)
	local f1, f2, pre, post, x, y, l1, l2 = open(fn1), open(fn2), {}, 0, 0, 0
	local function flush_pre()
		for _, v in ipairs(pre) do print(" " .. v) end
		pre = {}
	end
	local function diagonal()
		if #pre >= 3 then table.remove(pre, 1) end
		if #pre <= 0 and post > 0 then
			print(" " .. l2) post = post - 1
		else
			table.insert(pre, l2)
		end
		x = x + 1 y = y + 1
		l1, l2 = f1:read("*l"), f2:read("*l")
	end
	local function right()
		flush_pre()
		post = 3
		if l1 then print("-" .. l1) end
		l1 = f1:read("*l")
	end
	local function down()
		flush_pre()
		post = 3
		if l2 then print("+" .. l2) end
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
end

if #arg < 2 then return end
diff_u(arg[1], arg[2])
