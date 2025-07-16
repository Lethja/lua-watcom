# DIFF.LUA

## Overview
This Lua script is a custom implementation of a **unified diff** utility. 
Its purpose is to compare one or more pairs of files, 
highlight their differences, and print them in a unified diff format, 
just like `git diff` or `diff -u`.

Unified diffs display added, removed, and a few unchanged lines, above and below
to give contextual information that can then be used by a patching utility 
to ensure the patching process is correct.

## Usage Examples
### Compare a file to another
The script can compare a file to another as follows:
```
DIFF.LUA old.txt new.txt
```
This command compares `old1.txt` with `new1.txt`.
### Compare multiple files to each other
It might be useful to compare multiple files to their counterparts
at the same time. The script can compare multiple sets files as follows:
```
DIFF.LUA old1.txt new1.txt old2.txt new2.txt old3.txt new3.txt
```
This command compares `old1.txt` with `new1.txt`,
`old2.txt` with `new2.txt` and `old3.txt` with `new3.txt`.
This can continue indefinitely.


## How It Works
The script performs the following steps:
1. **Input Validation**:
    - There should be at least two arguments representing a valid file.
    - Each two arguments will be treated as another set of files to compare.
    The number of arguments must always be an even number.
    - If the provided input is invalid, 
    the script outputs usage instructions and exits.
    - If any file can't be opened for any reason,
    the script will print an error and exit on the spot.

2. **File Comparison**:
    - The function `diff_u` performs the actual comparison:
        - It reads two files line by line.
        - It tracks which lines are added, removed, 
        or unchanged between the two files using the Myers diff algorithm
        - It groups changes in "hunks,"
        which are logical sections of differences, 
        and formats these differences in the unified diff style.
        - It adds context lines around hunks to provide additional verification.

3. **Unified Diff Output**:
    - The script outputs differences using a standardized format:
        - Lines starting with a space (` `) are unchanged context lines.
        - Lines starting with a minus sign (`-`) are present only in the "old file" (removed lines).
        - Lines starting with a plus sign (`+`) are present only in the "new file" (added lines).
        - Each hunk starts with a header
        that shows the affected line numbers in both files,
        e.g., `@@ -start,count +start,count @@`.
        - If the old and new files are identical, nothing will be printed

## Global Variables

| Variable | Description                                                                                                                                    |
|----------|------------------------------------------------------------------------------------------------------------------------------------------------|
| `CL`     | **C**ontext **L**ines to print above and below a hunk. Defaults to `3`, can be to something else with the `DIFF_CONTEXT` environment variable. |

## Functions

| Function | Parameters                                      | Description                                                                 |
|----------|-------------------------------------------------|-----------------------------------------------------------------------------|
| `diff_u` | **f**ile**n**ame**1**<br/>**f**ile**n**ame**2** | Prints differences between the two files in to stdout.                      |
| `fp`     |                                                 | **F**lushes **p**re-context lines into the buffer when changes are detected |
| `fh`     |                                                 | **F**lushes a complete **h**unk of changes into the buffer                  |
| `fb`     |                                                 | **F**lush (print) and clear the **b**uffer                                  |
| `di`     |                                                 | **D**iagonally **i**terate (lines that match in both files)                 |
| `ri`     |                                                 | **Ri**ght iterate (for a line only present in the old file)                 |
| `dn`     |                                                 | **D**ow**n** Iterate (for a line only present in the new file)              |