#!/usr/bin/env lua

-- This script will set PE executable timestamps to a constant so NT builds are repeatable
C="cur" E="Unexpected EOF" F="<I4" S="set" V=809222400
local function rs(f)
    local b = f:read(2) if not b or #b < 2 then error(E) end return string.unpack("<I2", b)
end local function rd(f)
    local b = f:read(4) if not b or #b < 4 then error(E) end return string.unpack(F, b)
end local function wd(f, pos, val)
    f:seek(S, pos) f:write(string.pack(F, val))
end local function pe_offset(f)
    f:seek(S, 0) local mz = f:read(2) if mz ~= "MZ" then error("Not MZ") end f:seek(S, 0x3C) return rd(f)
end local function find_rsrc(f, peho)
    f:seek(S, peho) local sig = f:read(4) if sig ~= "PE\0\0" then error("Invalid PE") end f:seek(C, 2)
    local nos = rs(f) f:seek(C, 12) local soh = rs(f) f:seek(C, 2) local ohs, m = f:seek(), rs(f)
    if m ~= 0x10b and m ~= 0x20b then error("Unknown magic: " .. string.format("%x", m)) end f:seek(S, ohs + soh)
    for _ = 1, nos do
        local ss, name = f:seek(), f:read(8):gsub("\0.*", "") f:seek(C, 4) local _, sord, ptrd = rd(f), rd(f), rd(f) f:seek(S, ss + 40)
        if name == ".rsrc" then return { s = sord, r = ptrd } end
    end return nil
end local function patch(f, bo, oir)
    local dp = bo + oir + 4 wd(f, dp, V) f:seek(C, 4) local nn, ni = rs(f), rs(f) local te, eo = nn + ni, dp + 16
    for i = 0, te -1 do local ep = eo + (i * 8) f:seek(S, ep) local dodr = rd(f) if (dodr & 0x80000000) ~= 0 then local o = dodr & 0x7FFFFFFF patch(f, bo, o) end end
end
if #arg < 1 then os.exit(1) end
local f = assert(io.open(arg[1], "r+b")) local p = pe_offset(f) wd(f, p+8, V) local r = find_rsrc(f, p)
if not r then error(".rsrc not found") end
patch(f, r.r, 0) f:close()
print(".rsrc @: " .. r.r .. ", size: " .. r.s .. " DONE")
