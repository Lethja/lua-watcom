if not LIB then print("Please run bench.lua from the same working directory instead") return end

local function benchmark_md5sum()
    local it, s = 2, pcall(require, "md5sum")
    local bm = BenchmarkStart("Checksum MD5", it)
    local file = io.open(arg[0], "rb")

    if not s or not file then
        if file then file:close() end
        print(string.format("%17s", "Skipped"))
        return
    end

    for _ = 1, it do
        md5_file(file)
        file:seek("set", 0)
    end
    file:close()
    BenchmarkEnd(bm)
end

local function benchmark_sha256()
    local it, s = 1, pcall(require, "s256sum")
    local bm = BenchmarkStart("Checksum SHA256", it)
    local file = io.open(arg[0], "rb")

    if not s or not file then
        if file then file:close() end
        print(string.format("%17s", "Skipped"))
        return
    end

    for _ = 1, it do
        sha256_file(file)
        file:seek("set", 0)
    end
    file:close()
    BenchmarkEnd(bm)
end

benchmark_md5sum()
benchmark_sha256()