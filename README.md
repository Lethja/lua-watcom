# Lua for Open Watcom

This repository contains wmake style makefiles an patches to build [Lua](https://lua.org) [5.4.6](https://lua.org/ftp/) on Open Watcom 1.9 or later. The primary goal for these is to allow Lua scripts to be run on DOS systems in real mode.

## Runtime Requirements
To run Lua built by Open Watcom you will need the following:

| Requirement | Sources/Comment |
|--|--|
| [8088 CPU](https://en.wikipedia.org/wiki/Intel_8088)*<br/> <pre>*or compatibiles<br/>like the 8086, V20,<br/>286, 386 etc<br/><br/>Machine emulators<br/>provided as an option<br/>for other ISAs</pre> | [86Box](https://86box.net/) ([GitHub](https://github.com/86Box/86Box))<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[PCem](https://www.pcem-emulator.co.uk/) ([GitHub](https://github.com/sarah-walker-pcem/pcem/))
| PC-DOS 2.1 or higher | [FreeDOS](https://www.freedos.org/download/)<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[SvarDOS](http://svardos.org/)
| At least 320 kilobytes<br/>of total system memory | <pre>Any memory above<br/>640 kilobytes is<br/>inaccessible to all<br/>real mode DOS programs |
| At least 600 kilobytes<br/>of hard disk space or x2<br/>360 kilobyte diskettes | <pre>Can be ran directly<br/>from a diskette on<br/>machines without a<br/>hard drive

> If in doubt, install [DOSBox-X](https://dosbox-x.com/)

## Build Requirements
To build Lua with Open Watcom you will need the following:

| Requirement | Sources |
|--|--|
| Lua 5.4.6 source code | [lua.org](https://lua.org/ftp/) ([GitHub](https://github.com/lua/lua/tree/v5.4.6)) |
| Open Watcom 1.9 (or later) | [openwatcom.org](https://www.openwatcom.org/) ([GitHub](https://github.com/open-watcom))<br/>[FreeDOS Bonus CD](https://www.freedos.org/download/) (`FDIMPLES`)<br/>[SvarDOS](http://svardos.org/?p=repo) (`PKGNET` repository) |
| DOS operating system<br/>(MS-DOS 5.0 compatible) | [FreeDOS](https://www.freedos.org/download/)<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[SvarDOS](http://svardos.org/)
| [80386 compatible processor](https://en.wikipedia.org/wiki/I386)* <br/> <pre>*Any AMD or Intel CPU <br/>made in the last 3 decades<br/>is compatible.<br/><br/>Machine emulators provided <br/>as an option for other ISAs </pre> | [86Box](https://86box.net/) ([GitHub](https://github.com/86Box/86Box))<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[PCem](https://www.pcem-emulator.co.uk/) ([GitHub](https://github.com/sarah-walker-pcem/pcem/))<br/>[Qemu](https://www.qemu.org/) ([GitLab](https://gitlab.com/qemu-project/qemu))

> If in doubt, install [DOSBox-X](https://dosbox-x.com/)
