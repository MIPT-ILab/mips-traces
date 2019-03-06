#!/usr/bin/env bash
# Copyright (C) 2018 Pavel Kryukov, MIPT-MIPS Project
#
# This script is intended to be used with CI systems, please do not run it manually.

export MIPT_MIPS=$1

run_test()
{
    echo -n "running $2 on ISA $1..."
    $MIPT_MIPS -f -I $1 -b $2 && echo " success" || exit 1
}

run_test_limited()
{
    echo -n "running $2 on ISA $1..."
    $MIPT_MIPS -f -I $1 -b $2 -n 1000 && echo " success" || exit 1
}

# Start with primitive stuff
run_test mips32 move.out
run_test mips32 add.out
run_test mips32 static_arrays.out

# Do something more complicated
run_test mips32 bubble_sort.out
run_test_limited mips32 factorial.out
run_test_limited mips32 fib.out
run_test_limited mips32 sqrt.out

# Check some strange things
run_test mips32 corner_cases.out
run_test mips32 smc.out

# Torture tests without delayed branches
run_test mars tt.core.universal.out
run_test mars tt.core32.le.out
run_test mars tt.core32.out
run_test mars64 tt.core.universal.out
run_test mars64 tt.core64.le.out
run_test mars64 tt.core64.out

# Torture tests, MIPS32, little-endian
run_test mips32 tt.core.universal_reorder.out
run_test mips32 tt.core32.le_reorder.out

# Torture tests, MIPS64, little-endian
run_test mips64 tt.core.universal_reorder.out
