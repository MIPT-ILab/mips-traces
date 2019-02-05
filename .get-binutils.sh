#!/usr/bin/env bash
# Copyright (C) 2018 Pavel Kryukov, MIPT-MIPS Project
#
# This script is intended to be used with CI systems, please do not run it manually.
# To get MIPS GNU Binutils, please follow this instruction: 
# https://github.com/MIPT-ILab/mipt-mips/wiki/MIPS-binutils

wget http://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.bz2
tar xjf binutils-2.32.tar.bz2
cd binutils-2.32
./configure --target=mips-linux-gnu --prefix=$1 --disable-gdb --disable-gprof > /dev/null
make all install MAKEINFO=true CFLAGS='-w -O0' CXXFLAGS='-w -O0' > /dev/null
cd ..
