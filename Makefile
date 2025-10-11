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

BUILD_DIR  := build
SOURCE_DIR := source
BINARY_DIR := $(BUILD_DIR)/bin
OBJECT_DIR := $(BUILD_DIR)/obj

ARCHITECTURE := i686

ELF_TARGET   := $(BINARY_DIR)/kernel.elf
IMAGE_TARGET := $(BINARY_DIR)/kernel.img

NASM   := nasm
LINKER := $(ARCHITECTURE)-elf-ld
DD     := dd

NASM_FLAGS   :=
LINKER_FLAGS := -T linker.ld
DD_FLAGS     :=

NASM_SOURCES := $(shell find $(SOURCE_DIR) -name "*.asm")
NASM_OBJECTS := $(NASM_SOURCES:$(SOURCE_DIR)/%.asm=$(OBJECT_DIR)/%.o)

BOOTLOADER_SOURCE := $(SOURCE_DIR)/boot/bootloader.asm
BOOTLOADER_OBJECT := $(OBJECT_DIR)/boot/bootloader.o

ALL_OBJECTS      := $(NASM_OBJECTS)
FILTERED_OBJECTS := $(filter-out $(BOOTLOADER_OBJECT), $(ALL_OBJECTS))

NO_OUTPUT := >/dev/null 2>&1

all: $(IMAGE_TARGET)

clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)

$(ELF_TARGET): $(FILTERED_OBJECTS)
	@mkdir -p $(dir $@)
	@echo "Linking ELF kernel $@..."
	@$(LINKER) $(LINKER_FLAGS) $^ -o $@

$(IMAGE_TARGET): $(BOOTLOADER_OBJECT) $(ELF_TARGET)
	@mkdir -p $(dir $@)
	@echo "Generating disk image kernel $@..."
	@$(DD) $(DD_FLAGS) if=/dev/zero            of=$(IMAGE_TARGET)              bs=512 count=2048 $(NO_OUTPUT)
	@$(DD) $(DD_FLAGS) if=$(BOOTLOADER_OBJECT) of=$(IMAGE_TARGET) conv=notrunc bs=512 count=1    $(NO_OUTPUT)
	@$(DD) $(DD_FLAGS) if=$(ELF_TARGET)        of=$(IMAGE_TARGET) conv=notrunc bs=512 seek=1     $(NO_OUTPUT)

$(BOOTLOADER_OBJECT): $(BOOTLOADER_SOURCE)
	@mkdir -p $(dir $@)
	@echo "Assembling bootloader $<..."
	@$(NASM) $(NASM_FLAGS) -f bin $< -o $@

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.asm
	@mkdir -p $(dir $@)
	@echo "Assembling NASM file $<..."
	@$(NASM) $(NASM_FLAGS) -f elf32 $< -o $@

.PHONY: all clean
