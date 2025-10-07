# File:       Makefile
# Project:    mango
# Repository: https://github.com/nessbe/mango
#
# Copyright (c) 2025 nessbe
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# For more details, see the LICENSE file at the root of the project.

BUILD_ARCHITECTURE := i686
RUN_ARCHITECTURE   := i386

SOURCE_DIR := source
BUILD_DIR  := build
OBJECT_DIR := $(BUILD_DIR)/obj
BINARY_DIR := $(BUILD_DIR)/bin

ELF_TARGET  := $(BINARY_DIR)/kernel.elf
FLAT_TARGET := $(BINARY_DIR)/kernel.bin

NASM        := nasm
LINKER      := $(BUILD_ARCHITECTURE)-elf-ld
QEMU        := qemu-system-$(RUN_ARCHITECTURE)
OBJECT_COPY := $(BUILD_ARCHITECTURE)-elf-objcopy

NASM_FLAGS        := -f elf32
LINKER_FLAGS      := -T linker.ld
QEMU_FLAGS        := -kernel $(ELF_TARGET)
OBJECT_COPY_FLAGS := -O binary

NASM_SOURCES := $(shell find $(SOURCE_DIR) -name "*.asm")

NASM_OBJECTS := $(NASM_SOURCES:$(SOURCE_DIR)/%.asm=$(OBJECT_DIR)/%.o)

OBJECTS := $(NASM_OBJECTS)

.PHONY: all clean run

all: $(FLAT_TARGET)

clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)

run: $(ELF_TARGET)
	@echo "Running kernel $<..."
	@$(QEMU) $(QEMU_FLAGS)

$(FLAT_TARGET): $(ELF_TARGET)
	@mkdir -p $(dir $@)
	@echo "Creating flat binary kernel $@..."
	@$(OBJECT_COPY) $(OBJECT_COPY_FLAGS) $< $@

$(ELF_TARGET): $(OBJECTS)
	@mkdir -p $(dir $@)
	@echo "Linking kernel $@..."
	@$(LINKER) $(LINKER_FLAGS) $^ -o $@

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.asm
	@mkdir -p $(dir $@)
	@echo "Assembling NASM file $<..."
	@$(NASM) $(NASM_FLAGS) $< -o $@
