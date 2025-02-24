# Watcom Makefile for building Lua 5.4.6
# This is the DOS 4G flat model version
# There are no configurable parts to this file
# Run with `wmake -f wat4g.mak`

objs =  lapi.obj lctype.obj lfunc.obj lmathlib.obj loslib.obj          &
        ltable.obj lundump.obj lauxlib.obj ldblib.obj lgc.obj lmem.obj &
        lparser.obj ltablib.obj lutf8lib.obj lbaselib.obj ldebug.obj   &
        linit.obj loadlib.obj lstate.obj ltm.obj lvm.obj lcode.obj     &
        ldo.obj liolib.obj lobject.obj lstring.obj lzio.obj            &
        lcorolib.obj ldump.obj llex.obj lopcodes.obj lstrlib.obj

lua_obj = lua.obj
luac_obj = luac.obj

CFLAGS = -q -bt=dos4g -mf -5 -d0 -osr -zc
LDFLAGS = SYS dos4g OPT st=8192

!ifdef __UNIX__
DIST = dist/bin
COPY = cp
!else
DIST = dist\bin
COPY = COPY
!endif

lua4g.exe: $(objs) $(lua_obj) dist
    *wlink NAME $@ $(LDFLAGS) FILE {$(objs) $(lua_obj)}
    *$(COPY) $@ $(DIST)

luac4g.exe: $(objs) $(luac_obj) dist
    *wlink NAME $@ $(LDFLAGS) FILE {$(objs) $(luac_obj)}
    *$(COPY) $@ $(DIST)

.c.obj:
    *wcc386 $(CFLAGS) -fo=$@ $[&.c

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
    mkdir $(DIST)
