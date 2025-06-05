# Lua for Open Watcom

[![Lua for Watcom](https://github.com/Lethja/lua-watcom/actions/workflows/LuaWatcom.yml/badge.svg)](https://github.com/Lethja/lua-watcom/actions/workflows/LuaWatcom.yml)

This repository contains `wmake` style makefiles and patches to build [Lua](https://lua.org) on Open Watcom 1.9 or later. 
The primary goal was to allow Lua scripts to be run on DOS systems in real mode but has expanded
to include all Open Watcom targets that don't require external dependencies to build.

## Download

Pre-compiled builds are available on the 
[Release](https://github.com/Lethja/lua-watcom/releases/latest) page. 

### Files
There are two zips available for download in each release. 
Which one you should download depends on how you plan to use the software.
Both zips contain binaries for all listed platforms. 
See [Binary Native Targets](#binary-native-targets) 
and [Binary Compatibility Matrix](#binary-compatibility-matrix)
to determine which binary is right for your system.

#### Watcom Lua Executables (WLE#####.zip) 
This zip contains all demo scripts and platform binaries as regular files.
The zip is formatted with DOS headers and has 8.3 friendly names.

#### Watcom Lua floppy disk Images (WLI#####.zip) 
This zip contains two floppy disk format images (`.ima` format)
which are ready to be written to real disks for distributing to retro machines 
or opened by [emulators](#emulators) directly. 
To save space on these disk images binaries have been compressed 
by [UPX](https://upx.github.io/) where possible.

| Disk Image     | Description                                                                                                               |
|----------------|---------------------------------------------------------------------------------------------------------------------------|
| `LUAMULTI.IMA` | A 1.4MB 3½ floppy disk image that contains all the same files as [Lua Exe.zip](#lua-exezip-)                              |
| `LUA160k.IMA`  | A 160k 5¼ floppy disk image with subset of scripts with only the DOS binary due to space limitations of this type of disk |

## System Requirements

Lua for Watcom binaries can run on a number of legacy systems 
as well as some modern ones. 
The exact memory requirements will depend on the complexity of the script
you want to run.

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

| Operating System                    | Minimum OS ISA(s)           | LUA16.EXE | LUA21.EXE | LUA22.EXE | LUA4G.EXE  | LUANT.EXE |
|-------------------------------------|-----------------------------|-----------|-----------|-----------|------------|-----------|
| DOS 2.x - 4.x<br/>Windows 1.x - 3.x | 8086                        | Yes       | No        | No        | No         | No        |
| DOS 5.x - 7.x                       | 8086<br/>80386SX            | Yes       | No        | No        | No<br/>Yes | No        |
| OS2 1.0 - 1.1                       | 80286                       | Yes       | No        | No        | No         | No        |
| OS2 1.2 - 1.3                       | 80286                       | Yes       | Yes       | No        | No         | No        |
| OS2 2.x                             | 80386SX                     | Yes       | Yes       | Yes       | No         | No        |
| OS2 3.x                             | 80386SX                     | Yes       | Yes       | Yes       | Yes        | No        |
| OS2 4.x                             | 80486SX                     | Yes       | Yes       | Yes       | Yes        | No        |
| Windows 95                          | 80386SX                     | Yes       | No        | No        | Yes        | Yes       |
| Windows 98                          | 80486DX<br/>80486SX+80487SX | Yes       | No        | No        | Yes        | Yes       |
| Windows 2000 - ME                   | 80586                       | No        | No        | No        | No         | Yes       |
| Windows XP                          | 80586<br/>x86_64            | No        | No        | No        | No         | Yes       |
| Windows Vista - 10                  | 80686<br/>x86_64            | No        | No        | No        | No         | Yes       |
| Windows 11                          | x86_64                      | No        | No        | No        | No         | Yes       |

## Build System Requirements
To build Lua with Open Watcom you will need the following:

| Build Requirement                                                   | Sources                                                                                                       |
|---------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| Lua 5.4 source code (or `git submodules`)                           | [lua.org](https://lua.org/ftp/) ([GitHub](https://github.com/lua/lua/tree/v5.4.7))                            |
| Open Watcom 1.9 (or later)                                          | [openwatcom.org](https://www.openwatcom.org/)                                                                 |
| Operating System supported by Open Watcom<br/>(at least MS-DOS 5.0) | [FreeDOS](https://www.freedos.org/download/), [SvarDOS](http://svardos.org/) and/or an [emulator](#emulators) |
| [80386 compatible processor](https://en.wikipedia.org/wiki/I386)    | AMD/Intel processor made after 2008 or an [emulator](#emulators)                                              |
| A patching utility                                                  | [GNU Patch](https://savannah.gnu.org/projects/patch/) or [DifPat](https://github.com/deverac/difpat)          |

> If in doubt, an [emulator](#emulators) can be used 
  to run the DOS version of Open Watcom on a modern machine

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

   | Make Command            | Binary File          | Target OS   | Target ISA     |
   |-------------------------|----------------------|-------------|----------------|
   | `wmake -f wm_dos16.mak` | `dist/bin/lua16.exe` | PC-DOS 2.0+ | 8086 or later  |
   | `wmake -f wm_dos4g.mak` | `dist/bin/lua4g.exe` | MS-DOS 5.0+ | 80386 or later |
   | `wmake -f wm_os216.mak` | `dist/bin/lua21.exe` | OS/2 1.2    | 80286 or later |
   | `wmake -f wm_os232.mak` | `dist/bin/lua22.exe` | OS/2 2.0    | 80386 or later |
   | `wmake -f wm_winnt.mak` | `dist/bin/luant.exe` | Windows 95+ | 80386 or later |


# See also

## Emulators
If you do not have retro hardware but want to try Lua for Watcom 
any of the following emulators can be used to run the Lua binaries
from a modern machine.

| Emulator                                                        | Emulation Type                | Repository                                                                                   | Comment                                                                                           |
|-----------------------------------------------------------------|-------------------------------|----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| [86Box](https://86box.net/)                                     | PC Hardware                   | https://github.com/86Box/86Box                                                               | Requires firmware blobs. For best experience use with 86Box launcher                              |
| [DOSBox-X](https://dosbox-x.com/)                               | DOS Software                  | https://github.com/joncampbell123/dosbox-x                                                   | Not to be confused with DOSBox                                                                    |
| [MISTer FPGA](https://github.com/MiSTer-devel/Wiki_MiSTer/wiki) | Field Programmable Gate Array | https://github.com/MiSTer-devel/ao486_MiSTer</br>https://github.com/MiSTer-devel/PCXT_MiSTer | Requires compatible field programmable gate array (FPGA) hardware.                                |
| [PCem](https://www.pcem-emulator.co.uk/)                        | PC Hardware                   | https://github.com/sarah-walker-pcem/pcem/                                                   | Requires firmware blobs.                                                                          |
| [Qemu](https://www.qemu.org/)                                   | Hypervisor                    | https://gitlab.com/qemu-project/qemu                                                         | Often used with `libvirt`. Only recommended for guests with driver support (Windows XP and later) |

## Other software

Retro computer enthusiasts may be interested in [Lua for ELKS](https://github.com/rafael2k/lua)
(and [ELKS](https://github.com/ghaerr/elks) in general).