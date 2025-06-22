# Build System Requirements

## Mandatory
To build Lua with Open Watcom you will need the following software and hardware in your development environment.

### Lua
The Lua source code is not included directly in this repository and needs to be required.

#### Git Submodule
Assuming the development environment has access to Git and the Internet, 
the easiest way to get the Lua source code is to initialize the submodule
with `git submodules init` then `git submodules update --recursive`.

#### Website archive
If Git is not available in the development environment,
then Lua sources can be acquired from https://lua.org/ftp.
Download any 5.4 version of the tarball sources and extract them. 
Then copy the contents inside the extracted `src` folder
into the projects `lua` folder.

### Open Watcom

While Open Watcoms requirements are not difficult to satisfy, it
should be noted that a DOS and/or x86 [emulator](README.md#emulators) might
be required in some modern development environments, 
such as those not natively running on a x86(_64) processor.

#### Hardware
Open Watcom requires a processor that is 80386 instruction 
set architecture compliant.

#### Operating System
Open Watcom is available for several operating systems
including DOS, OS/2, Windows and Linux. 
Regardless of which version is used, they are all capable of cross-compiling 
to other systems assuming a full installation was done.

> The DOS version of Open Watcom must be run on an operating system
that supports the DOS4GW memory extender. 
If in doubt, consider [FreeDOS](https://www.freedos.org/download/)
or [SvarDOS](http://svardos.org/).

## Optional
These tools are not strictly needed to build Lua with Open Watcom
but are beneficial.

### Patching Utility
There are a few patches for the Lua source code available,
however, the patch changes are minimal 
and only serve to silence Watcom compiler warnings.

#### GNU Patch
The standard patch utility on GNU systems. 
It's likely already installed if the development environment is GNU/Linux, 
otherwise find it at https://savannah.gnu.org/projects/patch/.

#### DifPat
An alternative to GNUs patching utility, 
DifPat stands out in that it can run on DOS systems
and is included in the repositories
of [FreeDOS](https://www.freedos.org/download/)
and [SvarDOS](http://svardos.org/).
It's also available at https://github.com/deverac/difpat.

### Ultimate Packer for eXecutables
Ultimate Packer for eXecutables (UPX) can be used to compress the built binaries
and save disk space on the end users machine. 
UPX is free software and is available in the repositories
of [FreeDOS](https://www.freedos.org/download/), [SvarDOS](http://svardos.org/)
and most Linux distributions as well as directly from https://upx.github.io/.

### GNU mtools
mtools is a set of unix utility functions that allow handling of floppy disks
on UNIX-like systems without mounting the disk. Although its default behaviour
is to interact with real floppy disks and drives it is also possible to create
and interact with disk image files (.IMA) using the `-i` option.

### Lua 5.4
Some of the included scripts in the Lua for Watcom repository can be used to
ensure repeatable builds are possible.
To use these scripts, a Lua 5.4 compatible should be installed
to the development environment. This may include the one being built. 

# Building
## Patch the source code for Open Watcom (optional):

Depending on which patching utility is installed, run the applicable command:

| GNU Patch              | DifPat          |
|------------------------|-----------------|
| `patch -p0 -i lua.pat` | `pat lua.pat .` |

## Setup Open Watcom build environment
Open Watcom should contain a script for the respective development environment
it was installed on named `OWSETENV` or similar.
Running this script should set the correct environment in the
shell it was run on. After running the script make sure that `WATCOM` is defined
and points to a real directory by using the `echo` command to print it. 
Depending on your development environments operating system family, 
the command to do this may differ:
### DOS/NT
```bat
echo %WATCOM%
```
### UNIX
```sh
echo $WATCOM
```

## Build Lua with Open Watcom:

Run any of commands in the table below for the targets that should be built
and be mindful of how the `INCLUDE` environment variable changes
between different targets and development environments.

| INCLUDE (DOS/NT)            | INCLUDE (UNIX)            | Make Command            | Binary File          | Target OS   | Target ISA |
|-----------------------------|---------------------------|-------------------------|----------------------|-------------|------------|
| `%WATCOM%\h`                | `$WATCOM/h`               | `wmake -f wm_dos16.mak` | `dist/bin/LUA16.EXE` | PC-DOS 2.0+ | 8086+      |
| `%WATCOM%\h`                | `$WATCOM/h`               | `wmake -f wm_dos4g.mak` | `dist/bin/LUA4G.EXE` | MS-DOS 5.0+ | 80386+     |
| `%WATCOM%\h;%WATCOM%\h\os2` | `$WATCOM/h:$WATCOM/h/os2` | `wmake -f wm_os216.mak` | `dist/bin/LUA21.EXE` | OS/2 1.2    | 80286+     |
| `%WATCOM%\h;%WATCOM%\h\os2` | `$WATCOM/h:$WATCOM/h/os2` | `wmake -f wm_os232.mak` | `dist/bin/LUA22.EXE` | OS/2 2.0    | 80386+     |
| `%WATCOM%\h;%WATCOM%\h\nt`  | `$WATCOM/h:$WATCOM/h/nt`  | `wmake -f wm_winnt.mak` | `dist/bin/LUANT.EXE` | Windows 95+ | 80386+     |

## Copy DOS4GW (optional)
`LUA4G.EXE` requires `DOS4GW.EXE` to be accessible to it to run. 
The easiest way to ensure this is to copy the existing `DOS4GW.EXE` from the
Open Watcom installation into the same directory.
Depending on your development environments operating system family,
the command to do this may differ:
### DOS/NT
```bat
copy %WATCOM%/binw/dos4gw.exe dist/bin/DOS4GW.EXE
```
### UNIX
```sh
cp $WATCOM/binw/dos4gw.exe dist/bin/DOS4GW.EXE
```

## Replicable builds of LUANT.EXE with PE95TIME.LUA (optional)
`LUANT.EXE` is the Windows 95 version of the Lua for Watcom build. 
While the build is ready to run as it is, Open Watcom built the binary
with timestamp metadata in the PE executable headers,
meaning that subsequent builds will not be identical
even if the executed code is the same. 
To fix this the `PE95TIME.LUA` script can be used
to set this metadata time to August 21st 1995 (The release date of Windows 95).
```sh
lua PE95TIME.LUA dist/bin/LUANT.EXE
```
With this constant applied to the binary,
it should now be identical to any other build with the same input.
If it isn't, then tools like [diffoscope](https://diffoscope.org/) 
can be used to audit the difference 
without timestamps appearing as false positives.

## Compress binaries with UPX (optional)
It's possible to compress some of the binaries so they take less disk space.
```sh
upx -9 --8086 dist/bin/LUA16.EXE dist/bin/LUA4G.EXE dist/bin/LUANT.EXE
```
OS/2 and DOS4GW binaries should NOT be compressed by UPX.

## Creating a floppy disk image with mtools (optional)
The most convenient way to get Lua to some old hardware or an emulator might be
to create a floppy disk image. This can be achieved with GNU mtools.

### Create disk image
To create a disk use the `mformat` command
with parameters best suited to the disk type for that machine. 
The most important parameters are:
- `-C` Create if doesn't exist
- `-i` Specify an image file path
- `-v` Specify disk label
- `-f` The size of the disk in kilobytes
- `-N` Serial number of the disk 

Example:
```sh
mformat -C -i Lua.ima -v "LUA" -f 1440 -N 12345
```

### Copy files to disk image

With the disk image made copy over any files with `mcopy`. 
The most important parameters are:
- `-m` Keep the old modification date of each file from the development system
- `-i` Specify an image file path (which should be the same as was used in `mformat`)
- `::` Specifies a path in the disk image

Example:
```sh
mcopy -m -i Lua.ima dist/bin/LUA16.EXE dist/bin/LUA4G.EXE dist/bin/LUANT.EXE dist/bin/DOS4GW.EXE ::
```

## Trim the floppy disk image (optional)
Because mtools is designed to work on real floppy drives as well as images
`mcopy` may leave some junk data behind
in unallocated sectors of the disks partition.
Under normal circumstances this is uneventful, 
but when trying to create a replicable floppy disk image, 
this may cause the files to differ between builds.
To fix this the `FATSTAT.LUA` script can be used with it's `-z` parameter
to zero out any unused sector on the disk. This is sometimes called trimming
or shredding by other tools.
```sh
lua FATSTAT.LUA -z Lua.ima
```
