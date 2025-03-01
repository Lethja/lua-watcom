# Watcom Makefile for building Lua 5.4
# This is the DOS 16-bit large model version
# There are no configurable parts to this file
# Run with `wmake -f mw_dos16.mak`

objs =  $(OBJDIR)$(SEP)lapi.obj      $(OBJDIR)$(SEP)lctype.obj    &
        $(OBJDIR)$(SEP)lfunc.obj     $(OBJDIR)$(SEP)lmathlib.obj  &
        $(OBJDIR)$(SEP)loslib.obj    $(OBJDIR)$(SEP)ltable.obj    &
        $(OBJDIR)$(SEP)lundump.obj   $(OBJDIR)$(SEP)lauxlib.obj   &
        $(OBJDIR)$(SEP)ldblib.obj    $(OBJDIR)$(SEP)lgc.obj       &
        $(OBJDIR)$(SEP)lmem.obj      $(OBJDIR)$(SEP)lparser.obj   &
        $(OBJDIR)$(SEP)ltablib.obj   $(OBJDIR)$(SEP)lutf8lib.obj  &
        $(OBJDIR)$(SEP)lbaselib.obj  $(OBJDIR)$(SEP)ldebug.obj    &
        $(OBJDIR)$(SEP)linit.obj     $(OBJDIR)$(SEP)loadlib.obj   &
        $(OBJDIR)$(SEP)lstate.obj    $(OBJDIR)$(SEP)ltm.obj       &
        $(OBJDIR)$(SEP)lvm.obj       $(OBJDIR)$(SEP)lcode.obj     &
        $(OBJDIR)$(SEP)ldo.obj       $(OBJDIR)$(SEP)liolib.obj    &
        $(OBJDIR)$(SEP)lobject.obj   $(OBJDIR)$(SEP)lstring.obj   &
        $(OBJDIR)$(SEP)lzio.obj      $(OBJDIR)$(SEP)lcorolib.obj  &
        $(OBJDIR)$(SEP)ldump.obj     $(OBJDIR)$(SEP)llex.obj      &
        $(OBJDIR)$(SEP)lopcodes.obj  $(OBJDIR)$(SEP)lstrlib.obj

lua_obj = $(OBJDIR)$(SEP)lua.obj
luac_obj = $(OBJDIR)$(SEP)luac.obj

CC = *wcc

CFLAGS = -q -bt=dos -ml -0 -d0 -osr -zc
LFLAGS = SYS dos OPT st=8192

PLATFORM = 16

!ifdef __UNIX__
SEP = /
!else
SEP = \
!endif

BINDIR = dist$(SEP)bin
OBJDIR = obj$(SEP)$(PLATFORM)
SRCDIR = lua

$(BINDIR)$(SEP)lua$(PLATFORM).exe: $(OBJDIR) $(BINDIR) $(objs) $(lua_obj)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(lua_obj)}

$(BINDIR)$(SEP)luac$(PLATFORM).exe: $(BINDIR) $(OBJDIR) $(objs) $(luac_obj)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(luac_obj)}

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
    $(CC) $(CFLAGS) -fo=$@ $<

clean: .SYMBOLIC
!ifdef __UNIX__
    @!if [ -e $(OBJDIR) ]; then rm -R $(OBJDIR); fi
    @!if [ -e $(BINDIR)lua$(PLATFORM).exe ]; then rm $(BINDIR)lua$(PLATFORM).exe; fi
    @!if [ -e $(BINDIR)luac$(PLATFORM).exe ]; then rm $(BINDIR)luac$(PLATFORM).exe; fi
!elif __NT__
    @!if exist $(OBJDIR) rd /S /Q $(OBJDIR)
    @!if exist $(BINDIR)$(SEP)lua$(PLATFORM).exe del $(BINDIR)$(SEP)lua$(PLATFORM).exe
    @!if exist $(BINDIR)$(SEP)luac$(PLATFORM).exe del $(BINDIR)$(SEP)luac$(PLATFORM).exe
!else # Assuming DOS
    @!dir $(OBJDIR) > NUL
    @!if NOT ERRORLEVEL 1 deltree /Y $(OBJDIR)
    @!if exist $(BINDIR)$(SEP)lua$(PLATFORM).exe del $(BINDIR)$(SEP)lua$(PLATFORM).exe
    @!if exist $(BINDIR)$(SEP)luac$(PLATFORM).exe del $(BINDIR)$(SEP)luac$(PLATFORM).exe
!endif

dist:
    mkdir dist

obj:
    mkdir obj

$(BINDIR): dist
    mkdir $(BINDIR)

$(OBJDIR): obj
    mkdir $(OBJDIR)
