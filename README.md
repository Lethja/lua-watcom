# Lua for Open Watcom

This repository contains `wmake` style makefiles and patches to build [Lua](https://lua.org) on Open Watcom 1.9 or later. 
The primary goal was to allow Lua scripts to be run on DOS systems in real mode but has expanded
to include all Open Watcom targets that don't require external dependencies to build.

## Runtime Requirements

Lua for Watcom binaries can run on a number of legacy systems as well as some modern ones.

### Absolute Minimum Requirements

These are the absolute lowest system requirements needed for a PC to run `LUA16.EXE`. 

| Type                 | Requirement                                                 | Remarks                                                                                                                                                                                                                                                                                                                                                                                                                       |
|----------------------|-------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CPU                  | [8086 compatible](https://en.wikipedia.org/wiki/Intel_8086) | <pre>Compatibles like<br/>the Intel 8088, NEC V20,<br/>286, 386 etc<br/><br/>Machine emulators<br/>provided as an alternative<br/>for other ISAs</pre>[86Box](https://86box.net/) ([GitHub](https://github.com/86Box/86Box))<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[PCem](https://www.pcem-emulator.co.uk/) ([GitHub](https://github.com/sarah-walker-pcem/pcem/)) |
| Operating System     | PC-DOS 2.0                                                  | [FreeDOS](https://www.freedos.org/download/)<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[SvarDOS](http://svardos.org/)                                                                                                                                                                                                                                                  |
| Random Access Memory | At least 512 kilobytes<br/>of base system memory            | <pre>Any memory above<br/>640 kilobytes is<br/>inaccessible to all<br/>real mode DOS programs                                                                                                                                                                                                                                                                                                                                 |
| Storage              | At least 150 kilobytes<br/>of free disk space               | <pre>Can be ran directly<br/>from a diskette on<br/>machines without a<br/>hard drive                                                                                                                                                                                                                                                                                                                                         |

### Binary Native Targets

Since Open Watcom can produce binaries for several operating systems, 
each binary has been given a unique name to distinguish the native **Operating System** (OS) 
and **Instruction Set Architecture** (ISA) it is intended for.  

| Binary Name   | Native OS       | Native ISA |
|---------------|-----------------|------------|
| **LUA16.EXE** | Real mode DOS   | 8086       |
| **LUA21.EXE** | OS/2 1.2        | 80286      |
| **LUA22.EXE** | OS/2 2.0        | 80386      |
| **LUA4G.EXE** | DOS4GW extender | 80386      |
| **LUANT.EXE** | Windows 95      | 80386      |

### Binary Compatibility Matrix

Some OSes can run binaries intended for another out of the box. 
Do keep in mind, however, that in most of these cases 
the OS is newer and has higher minimum requirements.

| Operating System                    | Minimum OS ISA(s)           | LUA16.EXE | LUA21.EXE | LUA22.EXE | LUA4G.EXE | LUANT.EXE |
|-------------------------------------|-----------------------------|-----------|-----------|-----------|-----------|-----------|
| DOS 2.x - 4.x<br/>Windows 1.x - 3.x | 8086                        | Yes       | No        | No        | No        | No        |
| DOS 5.x - 7.x                       | 8086<br>80386SX             | Yes       | No        | No        | No<br>Yes | No        |
| OS2 1.0 - 1.1                       | 80286                       | Yes       | No        | No        | No        | No        |
| OS2 1.2 - 1.3                       | 80286                       | Yes       | Yes       | No        | No        | No        |
| OS2 2.x                             | 80386SX                     | Yes       | Yes       | Yes       | No        | No        |
| OS2 3.x                             | 80386SX                     | Yes       | Yes       | Yes       | Yes       | No        |
| OS2 4.x                             | 80486SX                     | Yes       | Yes       | Yes       | Yes       | No        |
| Windows 95                          | 80386SX                     | Yes       | No        | No        | Yes       | Yes       |
| Windows 98                          | 80486DX<br/>80486SX+80487SX | Yes       | No        | No        | Yes       | Yes       |
| Windows 2000 - ME                   | 80586                       | No        | No        | No        | No        | Yes       |
| Windows XP                          | 80586<br/>x86_64            | No        | No        | No        | No        | Yes       |
| Windows Vista - 10                  | 80686<br/>x86_64            | No        | No        | No        | No        | Yes       |
| Windows 11                          | x86_64                      | No        | No        | No        | No        | Yes       |

## Build Requirements
To build Lua with Open Watcom you will need the following:

| Requirement                                                                                                                                                                                                                            | Sources                                                                                                                                                                                                                                                                                                                                                    |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Lua 5.4 source code (or build machine with `git submodules`)                                                                                                                                                                           | [lua.org](https://lua.org/ftp/) ([GitHub](https://github.com/lua/lua/tree/v5.4.6))                                                                                                                                                                                                                                                                         |
| Open Watcom 1.9 (or later)                                                                                                                                                                                                             | [openwatcom.org](https://www.openwatcom.org/) ([GitHub](https://github.com/open-watcom))<br/>[FreeDOS Bonus CD](https://www.freedos.org/download/) (`FDIMPLES`)<br/>[SvarDOS](http://svardos.org/?p=repo) (`PKGNET` repository)                                                                                                                            |
| Operating System supported by Open Watcom<br/>(at least MS-DOS 5.0)                                                                                                                                                                    | [FreeDOS](https://www.freedos.org/download/)<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[SvarDOS](http://svardos.org/)                                                                                                                                                                               |
| [80386 compatible processor](https://en.wikipedia.org/wiki/I386)* <br/> <pre>*Any AMD or Intel CPU <br/>made in the last 3 decades<br/>is compatible.<br/><br/>Machine emulators provided <br/>as an alternative for other ISAs </pre> | [86Box](https://86box.net/) ([GitHub](https://github.com/86Box/86Box))<br/>[DOSBox-X](https://dosbox-x.com/) ([GitHub](https://github.com/joncampbell123/dosbox-x))<br/>[PCem](https://www.pcem-emulator.co.uk/) ([GitHub](https://github.com/sarah-walker-pcem/pcem/))<br/>[Qemu](https://www.qemu.org/) ([GitLab](https://gitlab.com/qemu-project/qemu)) |
| A patching utility                                                                                                                                                                                                                     | [GNU Patch](https://savannah.gnu.org/projects/patch/)<br>[DifPat](https://github.com/deverac/difpat)                                                                                                                                                                                                                                                       |

> If in doubt, [DOSBox-X](https://dosbox-x.com/) can be used on a modern machine

## How to build
1) Extract Luas source code to the `Lua` folder. This can be achieved in two ways:
   * Use `git submodules init` then `git submodules update --recursive` to get the sources directly from the Lua mirror repository
   * Download the Lua 5.4.x sources tarballs from https://lua.org/ftp/, extract them and copy all files in `src` to `Lua`
2) Patch the source code for Watcom (optional):

   | GNU Patch              | DifPat          |
   |------------------------|-----------------|
   | `patch -p0 -i lua.pat` | `pat lua.pat .` |
   > If no patching program is available mimic the changes in each `.pat` file manually. 
   > Patch changes are minimal and only serve to silence Watcom compiler warnings

3) Build Lua with the following commands:

   | Make Command            | Binary File          | System      | Processor          |
   |-------------------------|----------------------|-------------|--------------------|
   | `wmake -f wm_dos16.mak` | `dist/bin/lua16.exe` | PC-DOS 2.0+ | 8086/8088 or later |
   | `wmake -f wm_dos4g.mak` | `dist/bin/lua4g.exe` | MS-DOS 5.0+ | 80386 or later     |
   | `wmake -f wm_os216.mak` | `dist/bin/lua21.exe` | OS/2 1.2    | 80286 or later     |
   | `wmake -f wm_os232.mak` | `dist/bin/lua22.exe` | OS/2 2.0    | 80386 or later     |
   | `wmake -f wm_winnt.mak` | `dist/bin/luant.exe` | Windows 95+ | 80386 or later     |


Other targets may work but are untested
