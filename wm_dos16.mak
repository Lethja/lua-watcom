# Watcom Makefile for building Lua 5.4.6
# This is the DOS 16-bit large model version
# There are no configurable parts to this file
# Run with `wmake -f mw_dos16.mak`

objs =  $(OBJDIR)lapi.obj      $(OBJDIR)lctype.obj    &
        $(OBJDIR)lfunc.obj     $(OBJDIR)lmathlib.obj  &
        $(OBJDIR)loslib.obj    $(OBJDIR)ltable.obj    &
        $(OBJDIR)lundump.obj   $(OBJDIR)lauxlib.obj   &
        $(OBJDIR)ldblib.obj    $(OBJDIR)lgc.obj       &
        $(OBJDIR)lmem.obj      $(OBJDIR)lparser.obj   &
        $(OBJDIR)ltablib.obj   $(OBJDIR)lutf8lib.obj  &
        $(OBJDIR)lbaselib.obj  $(OBJDIR)ldebug.obj    &
        $(OBJDIR)linit.obj     $(OBJDIR)loadlib.obj   &
        $(OBJDIR)lstate.obj    $(OBJDIR)ltm.obj       &
        $(OBJDIR)lvm.obj       $(OBJDIR)lcode.obj     &
        $(OBJDIR)ldo.obj       $(OBJDIR)liolib.obj    &
        $(OBJDIR)lobject.obj   $(OBJDIR)lstring.obj   &
        $(OBJDIR)lzio.obj      $(OBJDIR)lcorolib.obj  &
        $(OBJDIR)ldump.obj     $(OBJDIR)llex.obj      &
        $(OBJDIR)lopcodes.obj  $(OBJDIR)lstrlib.obj

lua_obj = $(OBJDIR)lua.obj
luac_obj = $(OBJDIR)luac.obj

CC = *wcc

CFLAGS = -q -bt=dos -ml -0 -d0 -osr -zc
LFLAGS = SYS dos OPT st=8192

!ifdef __UNIX__
BINDIR = dist/bin/
OBJDIR = obj/16/
SRCDIR = lua/
!else
BINDIR = dist\bin\ #
OBJDIR = obj\16\ #
SRCDIR = lua\ #
!endif

$(BINDIR)lua16.exe: $(OBJDIR) $(BINDIR) $(objs) $(lua_obj)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(lua_obj)}

$(BINDIR)luac16.exe: $(BINDIR) $(OBJDIR) $(objs) $(luac_obj)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(luac_obj)}

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
    $(CC) $(CFLAGS) -fo=$@ $<

clean: .SYMBOLIC
!ifdef __UNIX__
    @!if [ -e $(OBJDIR) ]; then rm -R $(OBJDIR); fi
    @!if [ -e $(BINDIR)lua16.exe ]; then rm $(BINDIR)lua16.exe; fi
    @!if [ -e $(BINDIR)luac16.exe ]; then rm $(BINDIR)luac16.exe; fi
!else
    !ifdef __NT__
         @!if exist $(OBJDIR) rd /S /Q $(OBJDIR)
    !else
         @!if exist $(OBJDIR) deltree /Y $(OBJDIR)
    !endif
    @!if exist $(BINDIR)lua16.exe del $(BINDIR)lua16.exe
    @!if exist $(BINDIR)luac16.exe del $(BINDIR)luac16.exe
!endif

dist:
    mkdir dist

obj:
    mkdir obj

$(BINDIR): dist
    mkdir $(BINDIR)

$(OBJDIR): obj
    mkdir $(OBJDIR)
