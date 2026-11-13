NASM ?= nasm
LD ?= ld
BUILD := build
COMPILER_SRC := MCII.asm

.PHONY: all clean test example

all: $(BUILD)/mcii

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/mcii: $(COMPILER_SRC) | $(BUILD)
	$(NASM) -f elf64 $(COMPILER_SRC) -o $(BUILD)/mcii.o
	$(LD) $(BUILD)/mcii.o -o $@

example: $(BUILD)/mcii
	$(BUILD)/mcii examples/hello.mku $(BUILD)/hello.asm
	$(NASM) -f elf64 $(BUILD)/hello.asm -o $(BUILD)/hello.o
	$(LD) $(BUILD)/hello.o -o $(BUILD)/hello
	$(BUILD)/hello

test: $(BUILD)/mcii
	sh tests/smoke.sh

clean:
	rm -rf $(BUILD)
