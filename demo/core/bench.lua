#!/usr/bin/env lua

function OS()
	if os.getenv("COMSPEC") then
		return os.getenv("OS") and "NT" or "DOS"
	else
		return os.getenv("SHELL") and "UNIX" or "Unknown"
	end
end

function BS(name, iterations)
	io.write(string.format("%-9s", name) .. "\t" .. string.format("%10s", iterations) .. "\t")
	io.flush()
	return os.clock()
end

function BE(start_time)
	local t = os.clock() - start_time
	local m, s = math.floor(t / 60), (t % 60)
	io.write(string.format("%7d:%09.6f\n", m, s))
end

local function b_pi()
	local it, pi, si = 20000, 3, 1
	local b = BS("Nilakantha Pi", it)
	for i = 2, it * 2, 2 do
		pi = pi + si * (4 / (i * (i + 1) * (i + 2)))
		si = -si
	end
	BE(b)
end
local function b_gcd()
	local function gcd(a, b) -- Function to compute the greatest common divisor
		while b ~= 0 do a, b = b, a % b end
		return a
	end
	local m, r = 5000, 0
	local b = BS("Common Divisor", m)
	for i = 1, m do local x = i local y = m - i + 1 r = gcd(x, y) end BE(b)
end
local function b_mul()
	local m, r = 100000, 1
	local b = BS("Multiplication", m)
	for _ = 1, m do r = (r * 1.000000001) end BE(b)
end
local function b_div()
	local m, r = 100000, 1
	local b = BS("Division", m)
	m = m + 1
	for i = 2, m do r = r / i end BE(b)
end
local function b_add()
	local r, m = 1, 100000
	local b = BS("Addition", m)
	for i = 1, m do r = r + i end BE(b)
end
local function b_flt()
	local r, m = 1.0, 100000
	local b = BS("Float Addition", m)
	for _ = 1, m do r = r + 0.01 end BE(b)
end
local function b_sub()
	local r, m = 1, 100000
	local b = BS("Subtraction", m)
	for i = m, 1, -1 do r = r - i end BE(b)
end
local function b_arr()
	local m = 1000
	local b = BS("Array Loop", m)
	local a, s = {}, 0
	for i = 1, m do a[i] = i % 10 end
	for i = 1, m do a[i] = a[i] * 2 end
	for i = 1, m do s = s + a[i] end BE(b)
end
local function L() print(string.rep('_', 49)) end
print("Runtime:", _VERSION)
print("OS Family:", OS())
print("Minimum Int:", math.mininteger or "Unknown")
print("Maximum Int:", math.maxinteger or "Unknown")
print("\nBenchmark", "Iterations", "Time (min:sec.ms)")
L()
b = os.clock()
b_add() b_flt() b_sub() b_mul() b_div() b_pi() b_gcd() b_arr()
LIB = true
pcall(require, "EXBENCH")
L()
io.write("Total:\t\t" .. string.format("%8.3fkB", collectgarbage("count")) .. "\t") BE(b)
print("Press Enter to Exit...") io.read() os.exit()
