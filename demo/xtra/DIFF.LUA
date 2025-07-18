#!/usr/bin/env lua

CL=tonumber(os.getenv("DIFF_CONTEXT"))or 3
local function diff_u(fn1,fn2)
	local function open(fn)local f,e=io.open(fn)if not f then print(e)os.exit(1)end return f end
	local f1,f2,p,a,d,p1,p2,x,y,B,h,l1,l2=open(fn1),open(fn2),{},{},{},0,0,0,0,{a=0,d=0,l={}}
	local function FP()
		local function SW(s) return string.match(s,"%s")and '"'..s..'"'or s end
		if not h then print("--- "..SW(fn1).."\n+++ "..SW(fn2))h=true end
		if#p>0 then for _,v in ipairs(p)do table.insert(B.l," "..v)end B.o,B.n=x-#p,y-#p end
		p={}end
	local function FH()
		local pol={}
		local function optimize()local i,j=1 repeat j=1 repeat if d[i]== a[j]then table.insert(pol,table.remove(d,i))table.remove(a,j)break end j=j+1 until j>#a i=i+1 until i>#d end
    	if#d>0 and#a>0 then optimize()end
		for _,v in ipairs(d)do table.insert(B.l,"-"..v)end
		for _,v in ipairs(a)do table.insert(B.l,"+"..v)end
		for _,v in ipairs(pol)do table.insert(B.l," "..v)end
		B.a,B.d=B.a+#a,B.d+#d
		d,a={},{}end
	local function FB()
		if#B.l>0 then B.d,B.a=#B.l-B.a,#B.l-B.d
			local he="@@ -"..(B.o or B.d>0 and "1" or "0")..(B.d==1 and "" or ","..B.d).." +"..(B.n or B.a>0 and "1" or "0")..(B.a==1 and "" or ","..B.a).." @@"
			table.insert(B.l,1,he)for _,v in ipairs(B.l)do print(v)end end
		B.l,B.a,B.d,B.o,B.n={},0,0,nil,nil end
	local function di()
		FH()if#p>CL then table.remove(p,1)end
		if p1>0 or p2>0 then
			if p1>0 and p2>0 then if p1>CL or p2>CL then table.insert(B.l," "..l2)end p1,p2=p1-1,p2-1
			elseif p1>0 then if p1>CL then table.insert(B.l," "..l1)end p1=p1-1
			elseif p2>0 then if p2>CL then table.insert(B.l," "..l2)end p2=p2-1
			elseif p2<=CL then table.insert(p,l2)
			elseif p1<=CL then table.insert(p,l1)end
			if p1==0 or p2==0 then FB()table.insert(p,l2)end
		else table.insert(p,l2)end x,y,l1,l2=x+1,y+1,f1:read("*l"),f2:read("*l")end
	local function ri()FP()p1=(CL*2)+1 table.insert(d,l1)x,l1=x+1,f1:read("*l")end
	local function dn()FP()p2=(CL*2)+1 table.insert(a,l2)y,l2=y+1,f2:read("*l")end
	repeat if l1==l2 then di()elseif not l2 then ri()elseif not l1 then dn()else ri()dn()end until not l1 and not l2 f1:close()f2:close()if#a>0 or#d>0 then FP()FH()end if#B.l>0 then FB()end end
if#arg<2 or#arg%2~=0 then print(arg[-1].." "..arg[0]..[[ old new...

Compare differences between old and new files and print them as unified context.
To compare multiple sets of files at a time,write as sequential parameters.
Example: ']]..arg[0]..[[ old1 new1 old2 new2 old3 new3' etc...]])os.exit(1)end
for i=1,#arg,2 do diff_u(arg[i],arg[i+1])end
