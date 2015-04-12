include .knightos/variables.make

# This is a list of files that need to be added to the filesystem when installing your program
ALL_TARGETS:=$(BIN)wizardc8

# This is all the make targets to produce said files
$(BIN)wizardc8: main.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)wizardc8

include .knightos/sdk.make
