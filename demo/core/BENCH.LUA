#!/usr/bin/env lua

function OS()
	if os.getenv("COMSPEC") then
		return os.getenv("OS") and "NT" or "DOS"
	else
		return os.getenv("SHELL") and "UNIX" or "Unknown"
	end
end
function BS(name, iterations)
	local t = #tostring(iterations) > 10 and string.format("%10e", iterations):gsub("%..-e", "e") or iterations
	io.write(string.format("%-9s", name) .. "\t" .. string.format("%10s", t) .. "\t") io.flush() return os.clock()
end
function BE(start_time)
	local t = os.clock() - start_time
	local m, s = math.floor(t / 60), (t % 60)
	io.write(string.format("%7d:%09.6f\n", m, s))
end
local function b_pi()
	local it, pi, si = S, 3, 1
	local b = BS("Nilakantha Pi", it)
	for i = 2, it * 2, 2 do
		pi = pi + si * (4 / (i * (i + 1) * (i + 2))) si = -si
	end BE(b)
end
local function b_gcd()
	local function gcd(a, b) while b ~= 0 do a, b = b, a % b end return a end
	local r, b = 0, BS("Common Divisor", S)
	for i = 1, S do local x = i local y = S - i + 1 r = gcd(x, y) end BE(b)
end
local function b_mul()
	local r, b = 1, BS("Multiplication", B)
	for _ = 1, B do r = (r * 1.000000001) end BE(b)
end
local function b_div()
	local m, r = B, 1
	local b = BS("Division", m) m = m + 1
	for i = 2, m do r = r / i end BE(b)
end
local function b_add()
	local r, b = 1, BS("Addition", B)
	for i = 1, B do r = r + i end BE(b)
end
local function b_flt()
	local r, b = 1.0, BS("Float Addition", B)
	for _ = 1, B do r = r + 0.01 end BE(b)
end
local function b_sub()
	local r, b = 1, BS("Subtraction", B)
	for i = B, 1, -1 do r = r - i end BE(b)
end
local function b_arr()
	local b, a, s = BS("Array Loop", S), {}, 0
	for i = 1, S do a[i] = i % 10 end
	for i = 1, S do a[i] = a[i] * 2 end
	for i = 1, S do s = s + a[i] end BE(b)
end
local function L() print(string.rep('_', 49)) end
print("Runtime:", _VERSION)
print("OS Family:", OS())
print("Minimum Int:", math.mininteger or "Unknown")
print("Maximum Int:", math.maxinteger or "Unknown")
M=tonumber(arg[1])
if not M or M < 1980 then
	print("\nTo benchmark, run again and specify a year > 1979") os.exit()
end
print("\nRunning benchmark: " .. M) M = (M-1955)/25
B, S = math.floor(500^M), math.floor(100^M)
print("\nBenchmark", "Iterations", "Time (min:sec.ms)")
L()
b = os.clock()
b_add() b_flt() b_sub() b_mul() b_div() b_pi() b_gcd() b_arr()
LIB = true
pcall(require, "EXBENCH")
L()
io.write("Total:\t\t" .. string.format("%8.3fkB", collectgarbage("count")) .. "\t") BE(b)
print("Press Enter to Exit...") io.read() os.exit()
