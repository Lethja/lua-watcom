#!/usr/bin/env lua

--- Read file hash
--- @param file file The file
--- @return string The checksum result
function sha256_file(file)
	local M = 0xFFFFFFFF
	local K = {0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}
	local function RR(x, n) return (x >> n) | ((x & M) << (32 - n)) end
	local function TF(k, H)
		local W = {}
		for i = 0, 15 do
			local o = i * 4 + 1
			W[i] = string.byte(k, o) << 24 | string.byte(k, o + 1) << 16 | string.byte(k, o + 2) << 8 | string.byte(k, o + 3)
		end
		for i = 16, 63 do
			local s0 = RR(W[i - 15], 7) ~ RR(W[i - 15], 18) ~ (W[i - 15] >> 3)
			local s1 = RR(W[i - 2], 17) ~ RR(W[i - 2], 19) ~ (W[i - 2] >> 10)
			W[i] = (W[i - 16] + s0 + W[i - 7] + s1) & M
		end
		local a, b, c, d, e, f, g, h = table.unpack(H)
		for i = 0, 63 do
			local S0, S1, ch, maj = RR(a, 2) ~ RR(a, 13) ~ RR(a, 22), RR(e, 6) ~ RR(e, 11) ~ RR(e, 25), (e & f) ~ ((~e) & g), (a & b) ~ (a & c) ~ (b & c)
			local t1 = (h + S1 + ch + K[i + 1] + W[i]) & M
			local t2 = (S0 + maj) & M
			h = g g = f f = e e = (d + t1) & M d = c c = b b = a a = (t1 + t2) & M
		end
		H[1] = (H[1] + a) & M H[2] = (H[2] + b) & M H[3] = (H[3] + c) & M H[4] = (H[4] + d) & M H[5] = (H[5] + e) & M H[6] = (H[6] + f) & M H[7] = (H[7] + g) & M H[8] = (H[8] + h) & M
	end
	local function P(l)
		local ml = l * 8
		local p = "\128"
		local pl = (56 - (l % 64))
		if pl <= 0 then pl = pl + 64 end
		p = p .. string.rep("\0", pl - 1)
		for i = 7, 0, -1 do p = p .. string.char((ml >> (i * 8)) & 0xFF) end
		return p
	end
	local H, l = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}, 0
	while 1 do
		local c = file:read(64)
		if not c then break end
		l = l + #c
		if #c < 64 then c = c .. P(l) TF(c, H) break end
		TF(c, H)
	end
	local function h(x) return string.format("%08x", x) end
	return table.concat({h(H[1]),h(H[2]),h(H[3]),h(H[4]),h(H[5]),h(H[6]),h(H[7]),h(H[8])})
end

if LIB then return end
if #arg < 1 then print((arg[-1] or "?") .. " " .. (arg[0] or "?") .. " [FILE]...") os.exit(1)
else for i = 1, #arg do
		local file, err = io.open(arg[i], "rb")
		if not file then print(arg[i] .. ": " .. err) os.exit(1) end
		local sum = sha256_file(file) file:close()
		if sum then print(sum .. "  " .. arg[i]) else print(arg[i] .. ": " .. "Unknown error") os.exit(-1) end
	end
end
