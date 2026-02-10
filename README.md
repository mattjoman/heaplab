# HeapLab

HeapLab is a hands-on exploration of **glibc malloc internals**, common heap
vulnerabilities, and the effectiveness of modern debugging and sanitization
tools.

The project implements a series of intentionally buggy heap scenarios and
analyzes them using:

- **AddressSanitizer (ASan)**
- **Valgrind** *(planned)*
- **Custom GDB commands** for inspecting heap chunks and allocator metadata

The focus is on understanding *why* failures occur, not just detecting that
they do.

## Scenarios

- Use-after-free
- Double free
- Heap overflow

## Requirements

- Linux
- Glibc (this was tested with version 2.42 unless stated otherwise)
- Glibc debuginfo
- Valgrind
- GDB
- GCC, Make

*Note: On Arch Linux, getting glibc debuginfo required for valgrind is a pain.
I am planning to try a different distro for this reason.*

## Usage

- Compile the code: `./build.sh`
- Run a scenario: `./bin/<build>.out <scenario>` (e.g. `./bin/asan.out uaf`)
- To use my custom GDB commands, in GDB run `source .gdbinit`

## GDB Extensions

The `.gdbinit` file contains custom commands for:

- General memory inspection
- Inspecting a glibc allocator chunk's metadata and memory
- Automatically stepping through scenarios and displaying relevant data

## Analysis

Detailed write-ups are available in the `analysis/`.
The `heap_overflow` includes a full GDB walkthrough and is a good starting
point.

## Logs

Example output from the various tools and scenarios can be found in `logs/`.
Use these in conjunction with the analyses.

## Todo

- Add Valgrind analysis 
- Write a simple custom allocator
