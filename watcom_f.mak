# Watcom Makefile for building Lua 5.4.6
# This is the DOS 4G flat model version
# There are no configurable parts to this file
# Run with `wmake -f watcom_f.mak`

objs =  lapi.obj lctype.obj lfunc.obj lmathlib.obj loslib.obj          &
        ltable.obj lundump.obj lauxlib.obj ldblib.obj lgc.obj lmem.obj &
        lparser.obj ltablib.obj lutf8lib.obj lbaselib.obj ldebug.obj   &
        linit.obj loadlib.obj lstate.obj ltm.obj lvm.obj lcode.obj     &
        ldo.obj liolib.obj lobject.obj lstring.obj lzio.obj            &
        lcorolib.obj ldump.obj llex.obj lopcodes.obj lstrlib.obj

lua_obj = lua.obj
luac_obj = luac.obj

all: lua4g.exe luac4g.exe dist\bin .SYMBOLIC
!ifdef __UNIX__
    cp lua16.exe luac16.exe dist/bin
!else
    copy lua16.exe dist\bin
    copy luac16.exe dist\bin
!endif

lua4g.exe: $(objs) $(lua_obj)
    *wlink NAME $@ SYS dos4g OPT st=8192 FILE {$(objs) $(lua_obj)}

luac4g.exe: $(objs) $(luac_obj)
    *wlink NAME $@ SYS dos4g OPT st=8192 FILE {$(objs) $(luac_obj)}

.c.obj:
    *wcc386 -q -bt=dos4g -mf -5 -d0 -osr -zc $[&.c

clean: .SYMBOLIC
!ifdef __UNIX__
    rm *.obj *.exe
!else
    del *.obj
    del *.exe
!endif

cleandist: .SYMBOLIC clean
!ifdef __UNIX__
    rm -r dist
!else
    deltree /Y dist
!endif

dist:
    mkdir dist

dist\bin: dist
!ifdef __UNIX__
	mkdir dist/bin
!else
    mkdir dist\bin
!endif
