# Watcom Makefile for building Lua 5.4
# This is the DOS 4G flat model version
# There are no configurable parts to this file
# Run with `wmake -f wm_dos4g.mak`

CC = *wcc386

CFLAGS = -q -bt=dos4g -mf -3 -d0 -osr -zc
LFLAGS = SYS dos4g OPT st=8192

PLATFORM = 4G
SUFFIX = .EXE

!include common.inc