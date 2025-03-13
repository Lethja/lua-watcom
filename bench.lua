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

local function benchmark_pi()
    local iterations = 100000
    local pi = 3
    local sign = 1

    io.write("Benchmarking Pi  (" .. iterations .. " iterations)...\t")

    local start_time = os.clock()

    -- Calculate using Nilakantha series
    for i = 2, iterations * 2, 2 do
        pi = pi + sign * (4 / (i * (i + 1) * (i + 2)))
        sign = -sign -- Alternate the sign for each term
    end

    local end_time = os.clock()

    io.write(string.format("%.6f", end_time - start_time) .. " seconds\n")
end

local function benchmark_gcd()

    -- Function to compute the greatest common divisor
    local function gcd(a, b)
        while b ~= 0 do
            a, b = b, a % b
        end
        return a
    end

    local iterations = 100000
    local result = 0

    io.write("Benchmarking GCD (" .. iterations .. " iterations)...\t")

    local start_time = os.clock()

    for i = 1, iterations do
        local x = i
        local y = iterations - i + 1
        result = gcd(x, y)
    end

    local end_time = os.clock()

    io.write(string.format("%.6f", end_time - start_time) .. " seconds\n")
end

local function benchmark_mul()
    local iterations = 100000

    io.write("Benchmarking Mul (" .. iterations .. " iterations)...\t")

    local start_time = os.clock()
    local result = 1
    for i = 1, iterations do
        result = (result * i) % 1000000007  -- Keep the result small to avoid overflow
    end

    local end_time = os.clock()

    io.write(string.format("%.6f", end_time - start_time) .. " seconds\n")
end

local function benchmark_div()
    local iterations = 100000

    io.write("Benchmarking Div (" .. iterations .. " iterations)...\t")
    iterations = iterations + 1

    local start_time = os.clock()
    local result = 1
    for i = 2, iterations do
        result = result / i  -- Add 10 to avoid divide-by-zero
    end

    local end_time = os.clock()

    io.write(string.format("%.6f", end_time - start_time) .. " seconds\n")
end

local function benchmark_add()
    local iterations = 100000

    io.write("Benchmarking Add (" .. iterations .. " iterations)...\t")

    local start_time = os.clock()
    local result = 1
    for i = 1, iterations do
        result = result + i
    end

    local end_time = os.clock()

    io.write(string.format("%.6f", end_time - start_time) .. " seconds\n")
end

local function benchmark_sub()
    local iterations = 100000

    io.write("Benchmarking Sub (" .. iterations .. " iterations)...\t")

    local start_time = os.clock()
    local result = 1
    for i = iterations, 1, -1 do
        result = result - i
    end

    local end_time = os.clock()

    io.write(string.format("%.6f", end_time - start_time) .. " seconds\n")
end

local function benchmark_array()
    local elements = 1000  -- Total number of array elements (adjust for intensity)

    io.write("Benchmarking Array (" .. elements .. " iterations)...\t")

    local start_time = os.clock()

    local array = {}
    for i = 1, elements do
        array[i] = i % 10  -- Arbitrary initialization
    end

    for i = 1, elements do
        array[i] = array[i] * 2  -- Double every element
    end

    local sum = 0
    for i = 1, elements do
        sum = sum + array[i]
    end

    local end_time = os.clock()

    io.write(string.format("%.6f", end_time - start_time) .. " seconds\n")
end

-- Some information
print("Interpreter:", _VERSION)
print("System Family:", SystemFamily())
print("Memory (KB):", collectgarbage("count"))
print("Minimum Int:", math.mininteger or "Unknown")
print("Maximum Int:", math.maxinteger or "Unknown")
print()

-- Run the benchmarks

start_time = os.clock()

benchmark_add()
benchmark_sub()
benchmark_mul()
benchmark_div()

benchmark_pi()
benchmark_gcd()

benchmark_array()

end_time = os.clock()

print()
print("Total memory usage (KB):", collectgarbage("count"))
print("Total benchmark time:   ", string.format("%.6f", end_time - start_time))