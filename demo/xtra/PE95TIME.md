# PE95TIME.LUA

This Lua script modifies timestamps in a Portable Executable (PE) format EXE file to align them with the release date of Windows 95. The goal is to ensure reproducible builds for checksum verification purposes. Key points of usage include backing up files before modification, as this script directly edits the binary files.

## Documentation

### **Globals**
| Global Variable         | Description                                                                                                                                                                                                    |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| The `F`ile              | The open PE exe file in the script. The rest of this documentation will refer to this variable as "the file" as the script never has more than one file open at any time and is always assigned to this value. | 
| Little-endian `I`nteger | A constant used in Lua's `string.pack` and `string.unpack` functions (little-endian, 4-byte integers). Referring to `I` takes fewer bytes than typing `"<I4"` every time.                                      |
| Header `J`ump           | Set to the offset of a PE header in the file then reused and later the offset of ".rsrc"                                                                                                                       |
| `K`                     | The size of the table being jumped to                                                                                                                                                                          |
| INT32 MA`X`             | A constant used for bitwise operations. Represents the maximum 32-bit signed integer. Referring to `X` takes fewer bytes than typing `"0x80000000"` every time.                                                |
| `V`alue                 | The timestamp representing the Windows 95 release date in Unix epoch. Referring to `V` takes fewer bytes than typing `809222400` every time.                                                                   |
| `H`elp String           | A string containing the help message.                                                                                                                                                                          |

---

### **Functions**

| Function           | Parameters                   | Description                                                                                                                                                                      |
|--------------------|------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Seek `C`urrent     | byte position (optional)     | Move the file forward or backward from its current point by the specified amount of bytes. If byte position is not specified then the current position will be returned.         |
| `S`et Point        | byte position                | Set the file pointer to the exact byte location in the file.                                                                                                                     |
| `R`ead Short/Int   | 2 for 16-bit or 4 for 32-bit | Read a 16/32-bit value from the current point of the file. the point is moved by the amount of bytes read. The returned value is a integer representation of the requested data. |
| `W`rite Int        | 32-bit, byte position        | Overwrite 32-bits of data in the file at the exact byte location in the file.                                                                                                    |
| `P`arse Executable |                              | Verify that this is a binary executable. If it can't be verified nil is returned and the caller should close the file.                                                           |
| PE Header `O`ffset |                              | Parse through the file setting `J` to ".rsrc" section                                                                                                                            |
| `B`                | byte position, size          | Find and set timestamp headers in 'VS_VERSION_INFO'                                                                                                                              |
| `A`                | byte position, depth, isSub  | Modifies DateTimeStamp to `V` as it iterates over PE Headers. Calls `B()` if 'VS_VERSION_INFO' resource is found                                                                 |

### Execution Pipeline

1. Ensures at least one argument is provided.
   - If no arguments are provided, help is printed and the program exits.
2. For each file listen as an argument:
    1. Opens it in read/write mode (`r+b`) as "the file".
       - If "the file" doesn't exist or cannot be opened for writing, the program exits with an error on the spot.
    2. Calls `P()` to locate the PE header and `O()` to locate the `.rsrc` section.
       - If the MZ signature, PE header or .rsrc section cannot be found, the program exits with an error on the spot.
    3. Calls `A()` to process the `.rsrc` directory structure and update version information timestamps.
       1. `B()` is called if 'VS_VERSION_INFO' is discovered during interation. 
    4. Closes the file and reports success.