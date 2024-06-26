# Watcom Makefile for building Lua 5.4.6
# This is the DOS 16-bit large model version
# There are no configurable parts to this file
# Run with `wmake -f watcom_l.mak`

objs =  lapi.obj lctype.obj lfunc.obj lmathlib.obj loslib.obj          &
        ltable.obj lundump.obj lauxlib.obj ldblib.obj lgc.obj lmem.obj &
        lparser.obj ltablib.obj lutf8lib.obj lbaselib.obj ldebug.obj   &
        linit.obj loadlib.obj lstate.obj ltm.obj lvm.obj lcode.obj     &
        ldo.obj liolib.obj lobject.obj lstring.obj lzio.obj            &
        lcorolib.obj ldump.obj llex.obj lopcodes.obj lstrlib.obj

lua_obj = lua.obj
luac_obj = luac.obj

all: lua16.exe luac16.exe dist .SYMBOLIC
!ifdef __UNIX__
    cp lua16.exe luac16.exe dist/bin
!else
    copy lua16.exe dist\bin
    copy luac16.exe dist\bin
!endif

lua16.exe: $(objs) $(lua_obj)
    *wlink NAME $@ SYS dos OPT st=8192 FILE {$(objs) $(lua_obj)}

luac16.exe: $(objs) $(luac_obj)
    *wlink NAME $@ SYS dos OPT st=8192 FILE {$(objs) $(luac_obj)}

.c.obj:
    *wcc -q -bt=dos -ml -0 -d0 -osr -zc -fo=$@ $[&.c

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
!ifdef __UNIX__
    mkdir dist/bin
!else
    mkdir dist\bin
!endif
