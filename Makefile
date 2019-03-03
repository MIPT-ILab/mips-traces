# Building MIPS ElF binaries
# @author Alexander Titov <alexander.igorevich.titov@gmail.com>
# Copyright 2012-2018 uArchSim iLab Project

# create a list of all assembly files in the current folder
ASM_FILES = $(wildcard *.s)

# using names of the assembly files create a list of output 
# execution files 
OUT_FILES= $(patsubst %.s,%.out,$(ASM_FILES))
TT_FILES= $(wildcard tt.*.s)
OUT_TT_FILES= $(patsubst %.s,%.out,$(TT_FILES))

MIPS_AS?=mips-linux-gnu-as
MIPS_LD?=mips-linux-gnu-ld

# assemble all the object files 
build_all: $(OUT_FILES)
tt: $(OUT_TT_FILES) smc.out fib.out

%.out: %.o
	@$(MIPS_LD) $< -o $@ -EL
	@chmod -x $@
	@echo $@ is built

%.o: %.s
	@$(MIPS_AS) $< -o $@ -O0 -mips64 -no-break -EL -g

# it is needed to preven make from 
# deleting .o files automatically
.PRECIOUS: %.o

.PHONY: clean
clean:
	-rm *.o *.out -rf

.PHONY: help
help:
	@echo "  This makefile build all MIPS assembly files in the directory."
	@echo "  To do that just type 'make' or 'make build_all'."
	@echo "  Note that assembly files should have '.s' extension."
