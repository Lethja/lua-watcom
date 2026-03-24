# Watcom Makefile for building Lua 5.5
# This is the DOS 16-bit large model version
# There are no configurable parts to this file
# Run with `wmake -f mw_dos16.mak`

CC = *wcc

CFLAGS = -q -bt=dos -mh -0 -d0 -osr -zc
LFLAGS = SYS dos OPT st=16384

PLATFORM = 16
SUFFIX = .EXE

!include common.inc
!include flat.inc
