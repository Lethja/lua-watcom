#!/usr/bin/env lua

--Set PE timestamps to a constant so builds are repeatable
C,E,F,S,V="cur","!EOF","<I4","set",809222400
function R(f,l)local b=f:read(l)if b and#b>=l then return string.unpack(l==2 and"<I2"or F,b)end error(E)end
function W(f,p,v)f:seek(S,p)f:write(string.pack(F,v))end
function P(f)f:seek(S,0)local mz=f:read(2)f:seek(S,0x3C)if mz=="MZ"then return R(f,4)end error("!MZ")end
function O(f,p)
	f:seek(S,p)local s,n,h,m=f:read(4)if s~="PE\0\0"then error("!PE")end f:seek(C,2)
	n=R(f,2)f:seek(C,12)s=R(f,2)f:seek(C,2)h,m=f:seek(),R(f,2)
	if m~=0x10b then error("!10")end f:seek(S,h+s)
	for _=1,n do local u,o,q=f:seek(),f:read(8):gsub("\0.*","")f:seek(C,12)q=R(f,4)f:seek(S,u+40) if o==".rsrc"then return q end end end
function B(f,o)
	local r,s=R(f,4),R(f,4)
	print("TODO: handle VS_VERSION_INFO @" .. r .. " (size " .. s .. ")")
end
function A(f,b,o,l,v)
	local d,n,i,t,e=b+o+4 W(f,d,V)f:seek(C,4)n,i=R(f,2),R(f,2)t,e=n+i,d+12
	for j=0,t-1 do f:seek(S,e+(j*8))i,d=R(f,4),R(f,4)
		if(d&0x80000000)~=0 then A(f,b,d&0x7FFFFFFF,l+1,v or(l==1 and i==16))
		elseif v and l==3 then B(f,b+d)end
	end
end
if #arg<1 then os.exit(1)end
local f,p,r=assert(io.open(arg[1],"r+b"))p=P(f)W(f,p+8,V)r=O(f,p)
if not r then error("!rsrc")end
A(f,r,0,1)f:close()
print("DONE")
