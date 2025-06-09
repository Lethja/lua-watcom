#!/usr/bin/env lua

--Set PE timestamps to a constant so builds are repeatable
C="cur" E="Unexpected EOF" F="<I4" S="set" V=809222400
local function R(f,l) local b=f:read(l) if not b or #b<l then error(E) end return string.unpack(l==2 and"<I2"or F,b) end
local function W(f,p,v) f:seek(S,p) f:write(string.pack(F,v)) end
local function peo(f) f:seek(S,0) local mz=f:read(2) if mz~="MZ" then error("!MZ") end f:seek(S,0x3C) return R(f,4) end
local function rsrc(f,p)
	f:seek(S,p) local sig=f:read(4) if sig~="PE\0\0" then error("Invalid PE") end f:seek(C,2)
	local n=R(f,2) f:seek(C,12) local s=R(f,2) f:seek(C,2) local h,m=f:seek(),R(f,2)
	if m~=0x10b and m~=0x20b then error("Unknown magic: "..string.format("%x",m)) end f:seek(S,h+s)
	for _=1,n do
		local ss,o=f:seek(),f:read(8):gsub("\0.*",""),f:seek(C,4) local _,t,q=R(f,4),R(f,4),R(f,4) f:seek(S,ss+40)
		if o==".rsrc" then return {s=t,r=q} end
	end return nil end
local function pat(f,bo,oir)
	local dp=bo+oir+4 W(f,dp,V) f:seek(C,4) local nn,ni=R(f,2),R(f,2) local te,eo=nn+ni,dp+16
	for i=0,te-1 do local ep=eo+(i*8) f:seek(S,ep) local d=R(f,4) if (d &0x80000000)~=0 then local o=d&0x7FFFFFFF pat(f,bo,o) end end
end
if #arg<1 then os.exit(1) end
local f=assert(io.open(arg[1],"r+b")) local p=peo(f) W(f,p+8,V) local r=rsrc(f,p)
if not r then error(".rsrc not found") end
pat(f,r.r,0) f:close()
print(".rsrc @: "..r.r..", size: "..r.s.." DONE")
