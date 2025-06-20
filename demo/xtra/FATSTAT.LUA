#!/usr/bin/env lua

H=[[This script shows what blocks are allocated to what files on a FAT12/16 formatted floppy disk image (.IMA).
The -z option will zero out unallocated clusters. Always backup the IMA before using this tool with the -z option on it.]]
if #arg<1 then print(arg[-1].." "..arg[0].." [-z] [FILE...]"..'\n\n'..H)os.exit(1)end
function A()F={} for _,v in ipairs(arg)do if v=="-z" then Z=true else table.insert(F,v)end end end
function R16(s,o)local a,b=s:byte(o,o+1)return a+b*256 end
function R32(s,o)local a,b,c,d=s:byte(o,o+3)return a+b*256+c*65536+d*16777216 end
function F12(f,o,s)f:seek("set",o)local fd,fat,mc=f:read(s),{},math.floor(s*8/12)
	function E(i)local c=math.floor(i*1.5)local a,b=fd:byte(c+1)or 0,fd:byte(c+2)or 0 if i%2==0 then return a+(b&0x0F)*256 else return (a>>4)+b*16 end end
	for i=2,mc-1 do fat[i]=E(i)end return fat end
function F16(f,o,s)
	f:seek("set",o)local fd,fat=f:read(s),{}
	for i=2,#fd-1,2 do local lo,hi=fd:byte(i),fd:byte(i+1)fat[((i-2)//2)+2]=lo+hi*256 end return fat end
function FD(ts,rs,nf,sf,rd,sc)
	local cc=math.floor((ts-rs-(nf*sf)-rd)/sc)
	if cc<4085 then return 12 elseif cc<65525 then return 16 else return 32 end end
function CC(fat,sc)
	local chain,current={},sc
	while current>=2 and current<0xFF8 do table.insert(chain,current)current=fat[current] end return chain end
function FR(c)
	table.sort(c)local ranges,i={},1
	while i <=#c do
		local s,j,f=c[i],i while j+1<=#c and c[j+1]==c[j]+1 do j=j+1 end f=c[j]
		if s==f then table.insert(ranges,string.format("<%d>",s))
		else table.insert(ranges,string.format("<%d-%d>",s,f))end
		i=j+1 end return table.concat(ranges," ")end
function DE(f,o,e,fat)
	f:seek("set",o)
	for _=1,e do
		local en,fb=f:read(32)if not en then break end fb=en:byte(1)if fb==0 then break end
		if fb~=229 and(en:byte(12)&8)==0 then
			local n,x=en:sub(1,8):gsub("+$",""),en:sub(9,11):gsub("+$","")n=n..(x~=""and"."..x or"")
			io.write(string.format("\t%12s: %s\n",n,FR(CC(fat,R16(en,27)))))end end end
function FC(fat,f,st,s)
	io.write("\n\t  Free Space: ")
	local free,zero={},string.rep("\0",s)
	for i=2,#fat do if fat[i]==0 then table.insert(free,i)if Z then local o=st+(i-2)*s f:seek("set",o)f:write(zero)end end end print(FR(free))end
A()for _,file in ipairs(F)do
	local f=io.open(file,(Z and"r+b"or"rb"))
	if f then
		print(file..":")
		local boot=f:read(512)assert(boot:sub(1,1):byte()==0xEB or boot:sub(1,1):byte()==0xE9,"Invalid boot sector")
		local bs,sc,rs,nf,re,ts,sf=R16(boot,12),boot:byte(14),R16(boot,15),boot:byte(17),R16(boot,18),R16(boot,19)or R32(boot,32),R16(boot,23)
		local rd,fo,fs,ro=math.ceil(re*32/bs),rs*bs,sf*bs,(rs+nf*sf)*bs
		local ft=FD(ts,rs,nf,sf,rd,bs)
		print(string.format("\t       FAT type: FAT%s\n\t   Bytes/sector: %d\n\tSectors/cluster: %d\n\n",ft,bs,sc))
		local fat=ft==12 and F12(f,fo,fs)or ft==16 and F16(f,fo,fs)or error("Non-FAT type")
		DE(f,ro,re,fat)FC(fat,f,(rs+(nf*sf)+rd)*bs,sc*bs)f:close()print()end end
