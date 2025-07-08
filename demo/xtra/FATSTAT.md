# FATSTAT.LUA

This Lua script reads and reports on the sector usage
on FAT 12/16 formatted floppy disk images. 
Additionally, it has an optional function to zero out free clusters.
This script is used in continuous integration of Lua for Watcom
to ensure IMA floppy disk images
containing the same files
copied in the same order
with the same metadata
always have the same checksum.
This might be necessary because copy commands may use free sectors like a cache.

## Documentation

This script has been squashed to save on disk space.
The documentation for the functions are below.

### Functions

| **Function**    | **Description**                                                                                                     | **Output**                                |
|-----------------|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| `R16`</br>`R32` | **R**ead **16**-bit (`R16`) or **32**-bit (`R32`) integers from a data string at a specified offset.                | Parsed values (e.g., total sectors).      |
| `F12`</br>`F16` | Decodes the FAT table for **F**AT**12** (`F12`) or **F**AT**16** (`F16`).                                           | Returns a table representing the FAT.     |
| `FD`            | **D**etermines the **F**AT type based on the total cluster count. FAT12 if <4085 clusters, FAT16 if <65525.         | FAT type and total cluster count.         |
| `CC`            | Follows the FAT **c**luster **c**hain to identify which clusters are allocated to a file.                           | A list of clusters allocated to the file. |
| `FR`            | **F**ormats a list of clusters into a readable **r**ange string (e.g., `<2-4>`, `<5>`).                             | String representation of cluster ranges.  |
| `DE`            | Reads **d**irectory **e**ntries (files) from the root directory and retrieves their cluster allocation information. | Outputs file names and cluster ranges.    |
| `FC`            | Identifies **f**ree **c**lusters and optionally writes zeros to them if the `-z` flag is used.                      | Ranges of free clusters.                  |
