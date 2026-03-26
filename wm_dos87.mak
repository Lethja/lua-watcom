# Watcom Makefile for building Lua 5.5
# This is the DOS 16-bit huge model version
# This build will require an 8087 to be installed
# There are no configurable parts to this file
# Run with `wmake -f mw_dos16.mak`

CC = *wcc

CFLAGS = -q -bt=dos -mh -0 -d0 -osr -zc -fpi87
LFLAGS = SYS dos OPT st=16384

PLATFORM = 87
SUFFIX = .EXE

!include common.inc
!include flat.inc
