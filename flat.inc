# This file is part of wmake but should not be run directly.
# It depends on other makefiles to setup variables for the target first
# and stores only common tasks amongst builds that use the flat memory model.

$(BINDIR)$(SEP)LUA$(PLATFORM)$(SUFFIX): $(OBJDIR) $(BINDIR) $(objs) $(lua_obj) $(XTRA)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(lua_obj)}

$(BINDIR)$(SEP)LUAC$(PLATFORM)$(SUFFIX): $(BINDIR) $(OBJDIR) $(SRCDIR)$(SEP)luac.c $(objs) $(luac_obj) $(XTRA)
    *wlink NAME $@ $(LFLAGS) FILE {$(objs) $(luac_obj)}
