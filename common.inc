# This file is part of wmake but should not be run directly.
# It depends on other makefiles to setup variables for the target first
# and stores only common tasks amongst all platform build processes.

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

!ifdef __UNIX__
SEP = /
!else
SEP = \
!endif

BINDIR = dist$(SEP)bin
OBJDIR = obj$(SEP)$(PLATFORM)
SRCDIR = lua

help: .SYMBOLIC
    @!echo "Build the standard Lua interpreter:      $(BINDIR)$(SEP)LUA$(PLATFORM)$(SUFFIX)"
    @!echo "Build the experimental JIT interpreter:  $(BINDIR)$(SEP)LUAC$(PLATFORM)$(SUFFIX)"
    @!echo "Clean all previous builds:               clean"

$(BINDIR)$(SEP)LUA$(PLATFORM)$(SUFFIX): $(OBJDIR) $(BINDIR) $(objs) $(lua_obj) $(XTRA)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(lua_obj)}

$(BINDIR)$(SEP)LUAC$(PLATFORM)$(SUFFIX): $(BINDIR) $(OBJDIR) $(objs) $(luac_obj) $(XTRA)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(luac_obj)}

{$(SRCDIR)}.c{$(OBJDIR)}.obj:
    $(CC) $(CFLAGS) -fo=$@ $<

clean: .SYMBOLIC
!ifdef __UNIX__
    @!if [ -e $(OBJDIR) ]; then rm -R $(OBJDIR); fi
    @!if [ -e $(BINDIR)LUA$(PLATFORM)$(SUFFIX) ]; then rm $(BINDIR)LUA$(PLATFORM)$(SUFFIX); fi
    @!if [ -e $(BINDIR)LUAC$(PLATFORM)$(SUFFIX) ]; then rm $(BINDIR)LUAC$(PLATFORM)$(SUFFIX); fi
!else # Assuming DOS 5.0 +
    @!if exist $(BINDIR)$(SEP)LUA$(PLATFORM)$(SUFFIX) del $(BINDIR)$(SEP)LUA$(PLATFORM)$(SUFFIX)
    @!if exist $(BINDIR)$(SEP)LUAC$(PLATFORM)$(SUFFIX) del $(BINDIR)$(SEP)LUAC$(PLATFORM)$(SUFFIX)
    @!if exist $(OBJDIR)$(SEP)*.* echo Run `DEL $(OBJDIR)$(SEP)*.* && RD $(OBJDIR)` to clean compiler objects
!endif

dist:
    mkdir dist

obj:
    mkdir obj

$(BINDIR): dist
    mkdir $(BINDIR)

$(OBJDIR): obj
    mkdir $(OBJDIR)