# Watcom Makefile for building Lua 5.4
# This is the Linux version
# There are no configurable parts to this file
# Run with `wmake -f wm_linux.mak`

CC = *wcc386

CFLAGS = -q -bt=linux -mf -3 -d0 -osr -zc
LFLAGS = SYS linux OPT st=8192

PLATFORM = IX
SUFFIX = .ELF

!include common.inc
