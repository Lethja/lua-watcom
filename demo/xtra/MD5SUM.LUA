#!/usr/bin/env lua

--- Read file hash
--- @param file file The file to read (to end)
--- @return string MD5 checksum
function md5_file(file)
	local function Md5Transform(chunk, A, B, C, D)
		local F = function(x, y, z) return (x & y) | (~x & z) end
		local G = function(x, y, z) return (x & z) | (y & ~z) end
		local H = function(x, y, z) return x ~ y ~ z end
		local I = function(x, y, z) return y ~ (x | ~z) end
		local function LS(x, n) return ((x << n) | (x >> (32 - n))) & 0xFFFFFFFF end
		local wo, sh = {}, {{ 7, 12, 17, 22 }, { 5,  9, 14, 20 }, { 4, 11, 16, 23 }, { 6, 10, 15, 21 }}
		for i = 0, 15 do
			local o = i * 4 + 1
			wo[i + 1] =
			string.byte(chunk, o) |
			(string.byte(chunk, o + 1) << 8) |
			(string.byte(chunk, o + 2) << 16) |
			(string.byte(chunk, o + 3) << 24)
		end
		local a, b, c, d = A, B, C, D
		for i = 1, 64 do
			local f, g
			local r = math.floor((i - 1) / 16) + 1
			local s = sh[r][(i - 1) % 4 + 1]
			if r == 1 then
				f = F(b, c, d)
				g = (i - 1) % 16
			elseif r == 2 then
				f = G(b, c, d)
				g = (5 * (i - 1) + 1) % 16
			elseif r == 3 then
				f = H(b, c, d)
				g = (3 * (i - 1) + 5) % 16
			elseif r == 4 then
				f = I(b, c, d)
				g = (7 * (i - 1)) % 16
			end
			local t = d
			d = c
			c = b
			b = (b + LS((a + f + wo[g + 1] + T[i]) & 0xFFFFFFFF, s)) & 0xFFFFFFFF
			a = t
		end
		A = (A + a) & 0xFFFFFFFF
		B = (B + b) & 0xFFFFFFFF
		C = (C + c) & 0xFFFFFFFF
		D = (D + d) & 0xFFFFFFFF
		return A, B, C, D
	end
	local function Md5Pad(messageLength)
		local ml = messageLength * 8
		local p = "\128"
		local pl = (56 - (messageLength % 64))
		if pl <= 0 then pl = pl + 64 end
		p = p .. string.rep("\0", pl - 1)
		for i = 0, 7 do p = p .. string.char((ml >> (8 * i)) & 0xFF) end
		return p
	end
    local A, B, C, D, l = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0

    while true do
        local c = file:read(64)
        if not c then break end
        l = l + #c
        if #c < 64 then c = c .. Md5Pad(l) end
        A, B, C, D = Md5Transform(c, A, B, C, D)
        if #c > 64 then break end
    end
    local function to_hex(x)
        return string.format("%02x%02x%02x%02x",
				x & 0xFF, (x >> 8) & 0xFF, (x >> 16) & 0xFF, (x >> 24) & 0xFF)
    end
    return to_hex(A) .. to_hex(B) .. to_hex(C) .. to_hex(D)
end

local function init()
	T = {}
	for i = 1, 64 do T[i] = math.floor(2 ^ 32 * math.abs(math.sin(i))) end
end

if LIB then init() return end
if #arg < 1 then
    print((arg[-1] or "?") .. " " .. (arg[0] or "?") .. " [FILE]...")
    os.exit(1)
else
	init()
    for i = 1, #arg do
        local f, e = io.open(arg[i], "rb")
        if f then
            local sum = md5_file(f) f:close()
            if sum then
                print(sum .. "  " .. arg[i])
            else
                print(arg[i] .. ": " .. "Unknown error") os.exit(-1)
            end
        else
            print(arg[i] .. ": " .. e) os.exit(1)
        end
    end
end
