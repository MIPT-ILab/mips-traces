MIPS test traces for MIPT-MIPS Simulator.


## Traces

| Name |  | Description
|:--|:-|:-----------|
| **add.s** | **✓** | simplest test for add instruction
| **corner.s** | **?** | naughty/corner cases from our debug experience
| **factorial.s** | ✘ | recursive implementation of factorial
| **fib.s** | **✓**  | loop implementation of Fibonacci numbers
| **dc_ic_stress.s** | **✓**  | a data and instruction memory stress based on random memory access pattern
| **dc_stress.s** | **✓**  | a data-only memory stress based on random memory access pattern
| **move.s** | **✓**  | just a single move pseudo-instruction
| **smc.s** | ✘ | self-modifying MIPS code, modification is performed 'in-flight'
| **static_arrays.s** | **✓**  | example of a memory-located static array
| **tt.core.s** | **✓**  | is a part of SPIM S20 MIPS Simulator. Instructions which are not supported by MIPT-MIPS are commented out. SPIM source files are distributed under Free BSD license (see file header). Copyright (c) 1990-2010, James R. Larus. All rights reserved.

## Getting Started

MIPS binutils should be installed and have the following shortcuts:

     mips-as           is an assembler for MIPS ISA
     mips-ld           is a linker for MIPS object files
     mips-objdump      dumps content of MIPS binary files (also disassembles instructions)

MIPT-MIPS wiki has an instruction how to get and build MIPS binutils: https://github.com/MIPT-ILab/mipt-mips/wiki/MIPS-binutils

## Building a Trace

Use `make` command to build all the traces or `make tracename.out` to build one trace. You may specify local `mips-as` and `mips-ld` binaries with `MIPS_AS=` and `MIPS_LD=` Make variables.

In order to create MIPS binary file manually do the following steps:

1. create a file with assember code using and text editor
2. save it as `<test name>.s`
3. generate an object file: `mips-as <test name>.s -o <test name>.o`
4. convert the object file into the binary file: `mips-ld  <test name>.o -o  <test name>.out`
5. (optionally) look the content of <test name>.out using (pay attention only to .text section): `mips-objdump -D <test name>.out`
