# Watcom Makefile for building Lua 5.4
# This is the Windows 95 and later version
# There are no configurable parts to this file
# Run with `wmake -f wm_winnt.mak`

CC = *wcc386

CFLAGS = -q -bt=nt -bc -3 -d0 -osr -zc
LFLAGS = SYS nt OPT st=8192

PLATFORM = nt

!include common.inc
