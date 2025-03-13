#!/usr/bin/env lua

function SystemFamily()
	local env = os.getenv("COMSPEC")

	if env then
		env = os.getenv("OS")
		if env then
			return "NT"
		else
			return "DOS"
		end
	else
		env = os.getenv("SHELL")
		if env then
			return "UNIX"
		else
			return "Unknown"
		end
	end
end

function BenchmarkStart(name, iterations)
	io.write(string.format("%-9s", name) .. "\t" .. string.format("%10s", iterations) .. "\t")
	io.flush()
	return os.clock()
end

function BenchmarkEnd(start_time)
	local t = os.clock() - start_time
	local m, s = math.floor(t / 60), (t % 60)
	io.write(string.format("%6d:%010.7f\n", m, s))
end

local function benchmark_pi()
	local it, pi, si = 20000, 3, 1
	local bm = BenchmarkStart("Nilakantha Pi", it)

	-- Calculate using Nilakantha series
	for i = 2, it * 2, 2 do
		pi = pi + si * (4 / (i * (i + 1) * (i + 2)))
		si = -si -- Alternate the sign for each term
	end

	BenchmarkEnd(bm)
end

local function benchmark_gcd()
	-- Function to compute the greatest common divisor
	local function gcd(a, b)
		while b ~= 0 do
			a, b = b, a % b
		end
		return a
	end

	local it, r = 5000, 0
	local bm = BenchmarkStart("Common Divisor", it)

	for i = 1, it do
		local x = i
		local y = it - i + 1
		r = gcd(x, y)
	end

	BenchmarkEnd(bm)
end

local function benchmark_mul()
	local r, it = 1, 100000
	local bm = BenchmarkStart("Multiplication", it)

	for i = 1, it do
		r = (r * i) % 1000000007  -- Keep the result small to avoid overflow
	end

	BenchmarkEnd(bm)
end

local function benchmark_div()
	local it, result = 100000, 1
	local bm = BenchmarkStart("Division", it)

	it = it + 1
	for i = 2, it do
		result = result / i
	end

	BenchmarkEnd(bm)
end

local function benchmark_add()
	local r, it = 1, 100000
	local bm = BenchmarkStart("Addition", it)

	for i = 1, it do
		r = r + i
	end

	BenchmarkEnd(bm)
end

local function benchmark_flt()
	local r, it = 1.0, 100000
	local bm = BenchmarkStart("Float Addition", it)

	for _ = 1, it do
		r = r + 0.01
	end

	BenchmarkEnd(bm)
end

local function benchmark_sub()
	local r, it = 1, 100000
	local bm = BenchmarkStart("Subtraction", it)

	for i = it, 1, -1 do
		r = r - i
	end

	BenchmarkEnd(bm)
end

local function benchmark_array()
	local it = 1000
	local bm = BenchmarkStart("Array Loop", it)

	local array = {}
	for i = 1, it do
		array[i] = i % 10
	end

	for i = 1, it do
		array[i] = array[i] * 2
	end

	local sum = 0
	for i = 1, it do
		sum = sum + array[i]
	end

	BenchmarkEnd(bm)
end

-- Some information
print("Interpreter:", _VERSION)
print("System Family:", SystemFamily())
print("Memory (KB):", collectgarbage("count"))
print("Minimum Int:", math.mininteger or "Unknown")
print("Maximum Int:", math.maxinteger or "Unknown")
print()
print("Benchmark", "Iterations", "Time (min:sec.ms)")
-- Run the benchmarks

bm = os.clock()

benchmark_add()
benchmark_flt()
benchmark_sub()
benchmark_mul()
benchmark_div()

benchmark_pi()
benchmark_gcd()

benchmark_array()

print()
print("Total memory usage (KB):", collectgarbage("count"))
io.write("Total benchmark seconds:\t")
BenchmarkEnd(bm)
