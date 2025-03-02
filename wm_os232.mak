# Watcom Makefile for building Lua 5.4
# This is the OS/2 2.0 32-bit version
# There are no configurable parts to this file
# Run with `wmake -f wm_os232.mak`

CC = *wcc386

CFLAGS = -q -bt=os2 -bc -3 -d0 -osr -zc
LFLAGS = SYS os2v2 OPT st=8192

PLATFORM = 22

!include common.inc