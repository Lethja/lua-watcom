if not LIB then print("Please run bench.lua from the same working directory instead") return end

local function benchmark_md5sum()
	local s, bm, file = pcall(require, "MD5SUM"), BS("Checksum MD5", T), io.open(arg[0], "rb")

	if not s or not file then
		if file then file:close() end
		print(string.format("%17s", "Skipped"))
		return
	end

	for _ = 1, T do
		md5_file(file) file:seek("set", 0)
	end

	file:close() BE(bm)
end

local function benchmark_sha256()
	local s, bm, file = pcall(require, "S256SUM"), BS("Checksum SHA256", T), io.open(arg[0], "rb")

	if not s or not file then
		if file then file:close() end
		print(string.format("%17s", "Skipped"))
		return
	end

	for _ = 1, T do
		sha256_file(file) file:seek("set", 0)
	end

	file:close() BE(bm)
end
T=math.floor(2^M)
benchmark_md5sum()
benchmark_sha256()
