[![Build Status](https://travis-ci.com/MIPT-ILab/mips-traces.svg?branch=master)](https://travis-ci.com/MIPT-ILab/mips-traces)

MIPS test traces for MIPT-MIPS Simulator.

## Traces

| Name |  | Description
|:--|:-|:-----------|
| **add.s** | **✓** | simplest test for add instruction
| **bubble_sort.s** | **✓** | bubble sort of 20 integers, contains a lot of branches
| **corner.s** | **?** | naughty/corner cases from our debug experience
| **factorial.s** | ✘ | recursive implementation of factorial
| **fib.s** | **✓**  | loop implementation of Fibonacci numbers
| **dc_ic_stress.s** | **✓**  | a data and instruction memory stress based on random memory access pattern
| **dc_stress.s** | **✓**  | a data-only memory stress based on random memory access pattern
| **move.s** | **✓**  | just a single move pseudo-instruction
| **smc.s** | ✘ | self-modifying MIPS code, modification is performed 'in-flight'
| **static_arrays.s** | **✓**  | example of a memory-located static array
| **syscalls.s** | ✘ | example of syscalls

### Torture tests

Torture tests were developed as a part of SPIM S20 MIPS Simulator. SPIM source files are distributed under Free BSD license (see file header). Copyright (c) 1990-2010, James R. Larus. All rights reserved.

We separated tests for MIPS32 and MIPS64 versions, as these architectures have different flow to initialize negative value or all-ones value.

| Name |  | Description
|:--|:-|:-----------|
| **tt.core.universal.s** | **✓**  | Instructions which behave similarly in MIPS32 and MIPS64 |
| **tt.core32.s** | **✓**  | Tests MIPS32-specific instruction behavior |
| **tt.core32.le.s** | **✓**  | Tests MIPS32-specific and little-endian instruction behavior |
| **tt.core64.s** | **✓**  | MIPS64-specific version of tests |
| **tt.core64.le.s** | **✓**  | Tests MIPS64-specific and little-endian instruction behavior |

## Getting Started

GNU binutils for MIPS should be installed and have the following shortcuts:

     mips-linux-gnu-as           is an assembler for MIPS ISA
     mips-linux-gnu-ld           is a linker for MIPS object files
     mips-linux-gnu-objdump      dumps content of MIPS binary files (also disassembles instructions)

MIPT-MIPS wiki has an instruction how to get and build MIPS binutils: https://github.com/MIPT-ILab/mipt-mips/wiki/MIPS-binutils

Additionally, you may look inside get-binutils.sh script. The script is used to install GNU Binutils on CI hostings.

## Building a Trace

Use `make` command to build all the traces or `make tracename.out` to build one trace. You may specify local `mips-linux-gnu-as` and `mips-linux-gnu-ld` binaries with `MIPS_AS=` and `MIPS_LD=` Make variables.

In order to create MIPS binary file manually do the following steps:

1. create a file with assember code using and text editor
2. save it as `<test name>.s`
3. generate an object file: `mips-linux-gnu-as <test name>.s -o <test name>.o`
4. convert the object file into the binary file: `mips-linux-gnu-ld  <test name>.o -o  <test name>.out`
5. (optionally) look the content of <test name>.out using (pay attention only to .text section): `mips-linux-gnu-objdump -D <test name>.out`
