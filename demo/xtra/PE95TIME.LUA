#!/usr/bin/env lua

--Set PE timestamps to a constant so builds are repeatable
C,E,I,S,V="cur","!EOF","<I4","set",809222400
function R(l)local b=F:read(l)if b and#b>=l then return string.unpack(l==2 and"<I2"or I,b)end error(E)end
function W(p,v)F:seek(S,p)F:write(string.pack(I,v))end
function P()F:seek(S,0)local mz=F:read(2)F:seek(S,0x3C)if mz=="MZ"then return R(4)end error("!MZ")end
function O()
	F:seek(S,J)local s,n,h,m=F:read(4)if s~="PE\0\0"then error("!PE")end F:seek(C,2)n=R(2)F:seek(C,12)s=R(2)F:seek(C,2)h,m=F:seek(),R(2)
	if m~=0x10b then error("!10")end F:seek(S,h+s)
	for _=1,n do local u,o=F:seek(),F:read(8):gsub("\0.*","")F:seek(C,4)J=R(4)F:seek(C,4)K=R(4)F:seek(S,u+40)if o==".rsrc"then return end end error("!rsrc")end
function B(p,s)
	F:seek(S,(p-J)+K)local d,t,k=F:read(s),("VS_VERSION_INFO"):gsub(".","\0%1").."\0\0"k=d:find(t,1,true)
	if k then k=k+#t+((4-((k+#t)%4))%4)+44 F:seek(C,k-s)d,t=R(4),R(4)
		print(string.format("FileDateMS = 0x%X\nFileDateLS = 0x%X",d,t))
	end
end
function A(o,l,v)
	local d,n,i,t,e=K+o+4 W(d,V)F:seek(C,4)n,i=R(2),R(2)t,e=n+i,d+12
	for j=0,t-1 do F:seek(S,e+(j*8))i,d=R(4),R(4)
	if(d&0x80000000)~=0 then A(d&0x7FFFFFFF,l+1,v or(l==1 and i==16))
    elseif v and l==3 then local r=F:seek()F:seek(S,K+d)B(R(4),R(4))F:seek(S,r)end end end
if #arg<1 then os.exit(1)end
F=assert(io.open(arg[1],"r+b"))J=P()W(J+8,V)O()
A(0,1)F:close()
print("DONE")
