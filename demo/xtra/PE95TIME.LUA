#!/usr/bin/env lua

I,X,V,H="<I4",0x80000000,809222400,[[This script edits timestamps in a PE formatted EXE to the Windows 95 release date.
This allows repeatable builds to be verified by checksum tools. Backup the EXE before using this tool on it.]]
function C(x)return F:seek("cur",x)end
function S(x)return F:seek("set",x)end
function R(l)local b=F:read(l)if b and#b>=l then return string.unpack(l==2 and"<I2"or I,b)end error("!EOF")end
function W(p,v)S(p)F:write(string.pack(I,v))end
function P()local mz=F:read(2)S(60)if mz=="MZ"then return R(4)end error("!MZ")end
function O()
	S(J)local s,n,h,m=F:read(4)if s~="PE\0\0"then error("!PE")end C(2)n=R(2)C(12)s=R(2)C(2)h,m=C(),R(2)
	if m~=267 then error("!10")end S(h+s)
	for _=1,n do local u,o=C(),F:read(8):gsub("\0.*","")C(4)J=R(4)C(4)K=R(4)S(u+40)if o==".rsrc"then return end end error("!rsrc")end
function B(p,s)
	S((p-J)+K)local d,t,k=F:read(s),("VS_VERSION_INFO"):gsub(".","\0%1").."\0\0"k=d:find(t,1,1)
	if k then k=k+#t+((4-((k+#t)%4))%4)+44 d,t=C()+(k-s)W(d,0)W(d+4,V)end end
function A(o,l,v)
	local d,n,i,t,e=K+o+4 W(d,V)C(4)n,i=R(2),R(2)t,e=n+i,d+12
	for j=0,t-1 do S(e+(j*8))i,d=R(4),R(4)
	if(d&X)~=0 then A(d&(X-1),l+1,v or(l==1 and i==16))
    elseif v and l==3 then local r=C()S(K+d)B(R(4),R(4))S(r)end end end
if #arg<1 then print(arg[0],"'PEFORMAT.EXE'\n\n"..H)os.exit(1)end
F=assert(io.open(arg[1],"r+b"))J=P()W(J+8,V)O()A(0,1)F:close()print("OK")
