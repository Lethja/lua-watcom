# Watcom Makefile for building Lua 5.4
# This is the OS/2 1.2 16-bit version
# There are no configurable parts to this file
# Run with `wmake -f wm_os216.mak`

CC = *wcc

CFLAGS = -q -bt=os2 -bc -2 -ml -d0 -osr -zc
LFLAGS = SYS os2 OPT st=8192 OPT description \'Lua Programming Language Interpreter\'

PLATFORM = 21

!include common.inc