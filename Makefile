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

TARGET := $(BINARY_DIR)/kernel.elf

NASM         := nasm
NASM_FLAGS   :=
NASM_SOURCES := $(shell find $(SOURCE_DIR) -name "*.asm")
NASM_OBJECTS := $(NASM_SOURCES:$(SOURCE_DIR)/%.asm=$(OBJECT_DIR)/%.o)

OBJECTS := $(NASM_OBJECTS)

all: $(TARGET)

clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)

$(TARGET): $(OBJECTS)

$(OBJECT_DIR)/%.o: $(SOURCE_DIR)/%.asm
	@mkdir -p $(dir $@)
	@echo "Assembling NASM file $<..."
	@$(NASM) $(NASM_FLAGS) -f elf32 $< -o $@

.PHONY: all clean
