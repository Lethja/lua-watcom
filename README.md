# Lua for Watcom

[![Lua for Watcom](https://github.com/Lethja/lua-watcom/actions/workflows/LuaWatcom.yml/badge.svg)](https://github.com/Lethja/lua-watcom/actions/workflows/LuaWatcom.yml)
[![Lua Scripts](https://github.com/Lethja/lua-scripts/actions/workflows/LuaScripts.yml/badge.svg)](https://github.com/Lethja/lua-scripts/actions/workflows/LuaScripts.yml)

This repository contains `wmake` style makefiles and patches to build
[Lua](https://lua.org) on Open Watcom 1.9 or later.

Initially, the goal of the project was to allow modern Lua scripts
to be run on DOS systems in real mode.
The project has since expanded to include all Open Watcom targets
that don't require external dependencies to build.
Additionally, the simple scripts originally part of Lua for Open Watcoms
disk images made to test these ports have been made into its own repository,
[Lua Scripts](https://github.com/Lethja/lua-scripts).
It includes several example and utility scripts
that can be used on any Lua 5.4 interpreter, including Lua for Watcom.

## Download

Pre-compiled builds are available on the
[Release](https://github.com/Lethja/lua-watcom/releases/latest) page.
These releases are built from a
[GitHub Action workflow](.github/workflows/LuaWatcom.yml).

### Files
There are two zips available for download in each release;
which one you should download depends on how you plan to use the software.
Both zips contain binaries for all listed platforms.
See [Binary Native Targets](#binary-native-targets)
and [Binary Compatibility Matrix](#binary-compatibility-matrix)
to determine which binary is right for your system.

#### Watcom Lua Executables
This zip contains all demo scripts and platform binaries as regular files.
The zip is formatted with DOS headers and has 8.3 friendly names.

#### Watcom Lua floppy disk Images
This zip contains two floppy disk format images (`.ima` format)
which are ready to be written to real disks for distributing to retro machines
or opened by [emulators](#emulators-and-compatibility-layers) directly.
To save space on these disk images, binaries have been compressed
by [UPX](https://upx.github.io/) where possible.

| Disk Image     | Description                                                                                                               |
|----------------|---------------------------------------------------------------------------------------------------------------------------|
| `LUAMULTI.IMA` | A 1.4MB 3½ floppy disk image that contains all the same files as [executable zip](#Watcom-Lua-Executables)                |
| `LUA160k.IMA`  | A 160k 5¼ floppy disk image with subset of scripts with only the DOS binary due to space limitations of this type of disk |

## System Requirements

Lua for Watcom binaries can run on a number of legacy systems
as well as some modern ones.
The exact memory requirements will depend on the complexity of the script
you want to run.

### Binary Native Targets

Since Open Watcom can produce binaries for several operating systems,
each binary has been given a unique name to distinguish the native
**Operating System** and **Instruction Set Architecture** it is intended for.

| Binary Name   | Native Operating System | Native Instruction Set Architecture |
|---------------|-------------------------|-------------------------------------|
| **LUA16.EXE** | Real mode DOS           | 8086                                |
| **LUA21.EXE** | OS/2 1.2                | 80286                               |
| **LUA22.EXE** | OS/2 2.0                | 80386                               |
| **LUA4G.EXE** | DOS4GW extender         | 80386                               |
| **LUANT.EXE** | Windows 95              | 80386                               |
| **LUAUX.ELF** | Linux 1.2.13            | 80386                               |

### Binary Compatibility Matrix

Some operating systems can run binaries intended for another out of the box.
In most cases, the operating system is newer and has higher hardware requirements.

| Operating System                    | Instruction Set Architecture | LUA16 | LUA21 | LUA22 | LUA4G      | LUANT | LUAUX |
|-------------------------------------|------------------------------|-------|-------|-------|------------|-------|-------|
| DOS 2.x - 4.x<br/>Windows 1.x - 3.x | 8086                         | Yes   | No    | No    | No         | No    | No    |
| DOS 5.x - 7.x                       | 8086<br/>80386SX             | Yes   | No    | No    | No<br/>Yes | No    | No    |
| OS2 1.0 - 1.1                       | 80286                        | Yes   | No    | No    | No         | No    | No    |
| OS2 1.2 - 1.3                       | 80286                        | Yes   | Yes   | No    | No         | No    | No    |
| OS2 2.x                             | 80386SX                      | Yes   | Yes   | Yes   | No         | No    | No    |
| OS2 3.x                             | 80386SX                      | Yes   | Yes   | Yes   | Yes        | No    | No    |
| OS2 4.x                             | 80486SX                      | Yes   | Yes   | Yes   | Yes        | No    | No    |
| Linux 1.2.13+                       | 80386SX                      | No    | No    | No    | No         | No    | Yes   |
| Windows 95                          | 80386SX                      | Yes   | No    | No    | Yes        | Yes   | No    |
| Windows 98                          | 80486DX<br/>80486SX+80487SX  | Yes   | No    | No    | Yes        | Yes   | No    |
| ReactOS 0.4.15                      | 80586                        | Yes   | No    | No    | No         | Yes   | No    |
| Windows 2000 - ME                   | 80586                        | No    | No    | No    | No         | Yes   | No    |
| Windows XP                          | 80586<br/>x86_64             | No    | No    | No    | No         | Yes   | No    |
| Windows Vista - 10                  | 80686<br/>x86_64             | No    | No    | No    | No         | Yes   | No    |
| Windows 11                          | x86_64                       | No    | No    | No    | No         | Yes   | No    |

### Software Dependencies

#### DOS
The 32-bit DOS4GW extender version of Lua for Watcom (`LUA4G.EXE`)
requires `DOS4GW.EXE` to either be in the same directory or discoverable
in a directory specified by the `%PATH%` environment variable.

The real-mode version of Lua for Watcom (`LUA16.EXE`)
is completely self-contained and requires no extra files or directory structure.

#### Linux
The Linux version of Lua for Watcom (`LUAUX.ELF`) is completely self-contained
and requires no libraries from a distribution, not even libc.

The Linux kernel itself needs support for running "i386" ELF binaries.

#### OS/2
OS/2 version 2.0 and later have 32-bit executable support
and can run both the 16-bit (`LUA21.EXE`)
and 32-bit (`LUA22.EXE`) OS/2 versions of Lua for Watcom.

OS/2 version 1.3 and earlier are 16-bit and can only run `LUA21.EXE`.
`DOSCALL1.DLL` is required to run `LUA21.EXE`
which is included in OS/2 v1.2 and later.

OS/2 version 1.1 and earlier should run `LUA16.EXE`
in a DOS command prompt.

#### Windows
All the dependencies for the Windows version of Lua for Watcom (`LUANT.EXE`)
ship in a minimal installation of Windows 95,
there are effectively no dependencies.

## Build
See the [Build documentation](BUILD.md).

Additionally, the [GitHub Workflow](.github/workflows/LuaWatcom.yml)
can be studied to understand the release build workflow.

# See also

## Emulators and Compatibility Layers
As shown in the [Binary Compatibility Matrix](#binary-compatibility-matrix)
both `LUANT.EXE` and `LUAUX.ELF` are compatible
with current versions of Windows and Linux operating systems respectively.
An emulator should not be necessary to run these binaries
on current Linux/Windows PCs with AMD/Intel processors.

If you want to run the DOS or OS/2 version on a modern PC
or have a non-x86 processor in your machine,
then any of the following software projects can be used to run the Lua binaries.

| Name                                                            | Type                                       | Repository                                                                                   | Comment                                                                                                                                                                                                                                                                                         |
|-----------------------------------------------------------------|--------------------------------------------|----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [86Box](https://86box.net/)                                     | Full x86 PC Hardware Emulation             | https://github.com/86Box/86Box                                                               | Requires firmware blobs. For best experience use with a 86Box launcher.                                                                                                                                                                                                                         |
| [DOSBox-X](https://dosbox-x.com/)                               | DOS Environment Emulation                  | https://github.com/joncampbell123/dosbox-x                                                   | Only useful for running DOS applications like `LUA16.EXE` and `LUA4G.EXE` on non-DOS operating systems (including Windows versions after Windows 98). Not to be confused with DOSBox.                                                                                                           |
| [MISTer FPGA](https://github.com/MiSTer-devel/Wiki_MiSTer/wiki) | Field Programmable Gate Array              | https://github.com/MiSTer-devel/ao486_MiSTer</br>https://github.com/MiSTer-devel/PCXT_MiSTer | Requires compatible field programmable gate array (FPGA) hardware.                                                                                                                                                                                                                              |
| [PCem](https://www.pcem-emulator.co.uk/)                        | Full x86 PC Hardware Emulation             | https://github.com/sarah-walker-pcem/pcem/                                                   | Requires firmware blobs.                                                                                                                                                                                                                                                                        |
| [Qemu](https://www.qemu.org/)                                   | Processor Compatibility Layer & Hypervisor | https://gitlab.com/qemu-project/qemu                                                         | It might be possible set up `qemu-i386` to run `LUAUX.ELF` on a non-x86 Linux system.</br>Full virtual machines (`qemu-i386-system` & `qemu-x86_64-system`) are only recommended for running operating systems with guest driver support (Windows XP and later, Linux 2.6.26 and later etc...). |
| [Wine](https://www.winehq.org/)                                 | Windows Application Compatibility Layer    | https://gitlab.winehq.org/wine/wine                                                          | Only useful for running Windows applications like `LUANT.EXE` on non-Windows operating systems.                                                                                                                                                                                                 |

## Other software

Retro computer enthusiasts may be interested in [Lua for ELKS](https://github.com/rafael2k/lua)
(and [ELKS](https://github.com/ghaerr/elks) in general).
