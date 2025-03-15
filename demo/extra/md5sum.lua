#!/usr/bin/env lua

--- Read a files hash from it's current point to the end
--- @param file file The file to read to the end
--- @return string The md5 checksum result of the file
function md5_file(file)
	local function Md5Transform(chunk, A, B, C, D) -- Core MD5 transformation
		local F = function(x, y, z)
			return (x & y) | (~x & z)
		end

		local G = function(x, y, z)
			return (x & z) | (y & ~z)
		end

		local H = function(x, y, z)
			return x ~ y ~ z
		end

		local I = function(x, y, z)
			return y ~ (x | ~z)
		end

		local function LShift32(x, n)
			return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF
		end

		local words, shifts = {}, {
			{ 7, 12, 17, 22 },
			{ 5,  9, 14, 20 },
			{ 4, 11, 16, 23 },
			{ 6, 10, 15, 21 },
		}

		for i = 0, 15 do -- Break the chunk into 16 little-endian 32-bit words
			local offset = i * 4 + 1
			words[i + 1] = string.byte(chunk, offset) |
					(string.byte(chunk, offset + 1) << 8) |
					(string.byte(chunk, offset + 2) << 16) |
					(string.byte(chunk, offset + 3) << 24)
		end

		local a, b, c, d = A, B, C, D

		for i = 1, 64 do -- Main loop: 64 rounds of transformations
			local f, g
			local round = math.floor((i - 1) / 16) + 1
			local shift = shifts[round][(i - 1) % 4 + 1]

			if round == 1 then
				f = F(b, c, d)
				g = (i - 1) % 16
			elseif round == 2 then
				f = G(b, c, d)
				g = (5 * (i - 1) + 1) % 16
			elseif round == 3 then
				f = H(b, c, d)
				g = (3 * (i - 1) + 5) % 16
			elseif round == 4 then
				f = I(b, c, d)
				g = (7 * (i - 1)) % 16
			end

			local temp = d
			d = c
			c = b
			b = (b + LShift32((a + f + words[g + 1] +
					T[i]) & 0xFFFFFFFF, shift)) & 0xFFFFFFFF
			a = temp
		end

		-- Add chunk's hash to the result so far
		A = (A + a) & 0xFFFFFFFF
		B = (B + b) & 0xFFFFFFFF
		C = (C + c) & 0xFFFFFFFF
		D = (D + d) & 0xFFFFFFFF

		return A, B, C, D
	end

	local function Md5Pad(messageLength)
		local msg_len = messageLength * 8 -- Message length in bits
		local padding = "\128" -- Initial padding
		local pad_len = (56 - (messageLength % 64)) -- 448 mod 512

		if pad_len <= 0 then
			pad_len = pad_len + 64
		end

		padding = padding .. string.rep("\0", pad_len - 1)

		-- Append the original message length as a 64-bit little-endian integer
		for i = 0, 7 do
			padding = padding .. string.char((msg_len >> (8 * i)) & 0xFF)
		end

		return padding
	end

    local A, B, C, D, len = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0

    while true do
        local chunk = file:read(64) -- Read in chunks of 64 bytes (512 bits)

        if not chunk then break end
        len = len + #chunk

		-- If it's the final chunk, apply padding
        if #chunk < 64 then chunk = chunk .. Md5Pad(len) end
        A, B, C, D = Md5Transform(chunk, A, B, C, D)

		-- Stop processing after the padded block
        if #chunk > 64 then break end
    end

	-- Format output as a hexadecimal string in little-endian order
    local function to_hex(x)
        return string.format("%02x%02x%02x%02x",
				x & 0xFF, (x >> 8) & 0xFF, (x >> 16) & 0xFF, (x >> 24) & 0xFF)
    end

    return to_hex(A) .. to_hex(B) .. to_hex(C) .. to_hex(D)
end

if #arg < 1 then
	-- Show accurate Lua binary and script location
    print((arg[-1] or "?") .. " " .. (arg[0] or "?") .. " [FILE]...")
    os.exit(1)
else
	T = {} -- Predefined MD5 constants of sine-based shifts (T values)
	for i = 1, 64 do
		T[i] = math.floor(2 ^ 32 * math.abs(math.sin(i)))
	end

    for i = 1, #arg do
        local file, err = io.open(arg[i], "rb")

        if file then
            local sum = md5_file(file)
            file:close()

            if sum then
                print(sum .. "  " .. arg[i])
            else
                print(arg[i] .. ": " .. "Unknown error")
                os.exit(-1)
            end
        else
            print(arg[i] .. ": " .. err)
            os.exit(1)
        end
    end
end
