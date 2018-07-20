ifneq ($(findstring pi32, $(HOST_ARCH)),)

TOOLCHAIN_PATH ?=
TOOLCHAIN_PREFIX :=
TOOLCHAIN_DEFAULT_FOLDER := clang-pi32

ifneq (,$(wildcard $(COMPILER_ROOT)/${TOOLCHAIN_DEFAULT_FOLDER}/${HOST_OS}/bin))
TOOLCHAIN_PATH := $(COMPILER_ROOT)/${TOOLCHAIN_DEFAULT_FOLDER}/${HOST_OS}/bin/
endif

ifeq (,$(TOOLCHAIN_PATH))
$(error can not find compiler toolchain, please install clang-pi32-elf toolchain to $(COMPILER_ROOT)/${TOOLCHAIN_DEFAULT_FOLDER}/${HOST_OS} folder)
endif # TOOLCHAIN_PATH

CC		:= $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)clang
AS		:= $(CC)
AR		:= $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)ar
LD		:= $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)ld
DUMP	:= $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)objdump
OBJCOPY := $(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)objcopy
OPTIONS_IN_FILE_OPTION	:= @


ADD_COMPILER_SPECIFIC_STANDARD_CFLAGS   = $(1) $(if $(filter yes,$(MXCHIP_INTERNAL) $(TESTER)),-Wl)
ADD_COMPILER_SPECIFIC_STANDARD_CXXFLAGS = $(1) $(if $(filter yes,$(MXCHIP_INTERNAL) $(TESTER)),-Wl)
ADD_COMPILER_SPECIFIC_STANDARD_ADMFLAGS = $(1)
COMPILER_SPECIFIC_OPTIMIZED_CFLAGS    := -Oz
COMPILER_SPECIFIC_UNOPTIMIZED_CFLAGS  := -O0
COMPILER_SPECIFIC_PEDANTIC_CFLAGS  := $(COMPILER_SPECIFIC_STANDARD_CFLAGS)
COMPILER_SPECIFIC_ARFLAGS_CREATE   := rcs
COMPILER_SPECIFIC_ARFLAGS_ADD      := rcs
COMPILER_SPECIFIC_ARFLAGS_VERBOSE  :=

#debug: no optimize and log enable
COMPILER_SPECIFIC_DEBUG_CFLAGS     := -DDEBUG -ggdb $(COMPILER_SPECIFIC_UNOPTIMIZED_CFLAGS)
COMPILER_SPECIFIC_DEBUG_CXXFLAGS   := -DDEBUG -ggdb $(COMPILER_SPECIFIC_UNOPTIMIZED_CFLAGS)
COMPILER_SPECIFIC_DEBUG_ASFLAGS    := -DDEBUG=1
COMPILER_SPECIFIC_DEBUG_LDFLAGS    := --gc-sections --cref

#release_log: optimize but log enable
COMPILER_SPECIFIC_RELEASE_LOG_CFLAGS   := -ggdb $(COMPILER_SPECIFIC_OPTIMIZED_CFLAGS)
COMPILER_SPECIFIC_RELEASE_LOG_CXXFLAGS := -ggdb $(COMPILER_SPECIFIC_OPTIMIZED_CFLAGS)
COMPILER_SPECIFIC_RELEASE_LOG_ASFLAGS  :=
COMPILER_SPECIFIC_RELEASE_LOG_LDFLAGS  := --gc-sections $(COMPILER_SPECIFIC_OPTIMIZED_CFLAGS) --cref

#release: optimize and log disable
COMPILER_SPECIFIC_RELEASE_CFLAGS   := -DNDEBUG $(COMPILER_SPECIFIC_OPTIMIZED_CFLAGS)
COMPILER_SPECIFIC_RELEASE_CXXFLAGS := -DNDEBUG $(COMPILER_SPECIFIC_OPTIMIZED_CFLAGS)
COMPILER_SPECIFIC_RELEASE_ASFLAGS  :=
COMPILER_SPECIFIC_RELEASE_LDFLAGS  := --gc-sections $(COMPILER_SPECIFIC_OPTIMIZED_CFLAGS) --cref
COMPILER_SPECIFIC_DEPS_FLAG        := -MD
COMPILER_SPECIFIC_COMP_ONLY_FLAG   := -c
COMPILER_SPECIFIC_LINK_MAP         = -M=$(1)
COMPILER_SPECIFIC_LINK_FILES       = --start-group $(1) $(TOOLCHAIN_PATH)/../lib/libc.a $(TOOLCHAIN_PATH)/../lib/libcompiler-rt.a --end-group
COMPILER_SPECIFIC_LINK_SCRIPT_DEFINE_OPTION =
COMPILER_SPECIFIC_LINK_SCRIPT      = $(addprefix -T, $(1))
LINKER                             := $(LD)
LINK_SCRIPT_SUFFIX                 := .ld
TOOLCHAIN_NAME := GCC

ENDIAN_CFLAGS_LITTLE   :=
ENDIAN_CXXFLAGS_LITTLE :=
ENDIAN_ASMFLAGS_LITTLE :=
ENDIAN_LDFLAGS_LITTLE  :=
CLIB_LDFLAGS_NANO      :=
CLIB_LDFLAGS_NANO_FLOAT:=

# Chip specific flags for GCC

COMPILER_UNI_CFLAGS :=	-target pi32 \
						-I$(TOOLCHAIN_PATH)/../include/libc -fcolor-diagnostics	\
						-Wno-incompatible-pointer-types							\
						-Wno-format												\
						-Wno-tautological-constant-out-of-range-compare

COMPILER_UNI_SFLAGS := -target pi32 -integrated-as

CPU_ASMFLAGS   := 
CPU_LDFLAGS    := 
CLIB_LDFLAGS_NANO       += 
CLIB_LDFLAGS_NANO_FLOAT += 

# $(1) is map file, $(2) is CSV output file
COMPILER_SPECIFIC_MAPFILE_TO_CSV = $(PYTHON) $(MAPFILE_PARSER) $(1) > $(2)

MAPFILE_PARSER            :=$(MAKEFILES_PATH)/scripts/map_parse_gcc.py

# $(1) is map file, $(2) is CSV output file
COMPILER_SPECIFIC_MAPFILE_DISPLAY_SUMMARY = $(PYTHON) $(MAPFILE_PARSER) $(1)

KILL_OPENOCD_SCRIPT := $(MAKEFILES_PATH)/scripts/kill_openocd.py

KILL_OPENOCD = $(PYTHON) $(KILL_OPENOCD_SCRIPT)

OBJDUMP := "$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)objdump$(EXECUTABLE_SUFFIX)"
OBJCOPY := "$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)objcopy$(EXECUTABLE_SUFFIX)"
STRIP   := "$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)strip$(EXECUTABLE_SUFFIX)"
NM      := "$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)nm$(EXECUTABLE_SUFFIX)"

STRIP_OUTPUT_PREFIX := -o
OBJCOPY_BIN_FLAGS   := -O binary -R .eh_frame -R .init -R .fini -R .comment
OBJCOPY_HEX_FLAGS   := -O ihex -R .eh_frame -R .init -R .fini -R .comment

LINK_OUTPUT_SUFFIX  :=.elf
BIN_OUTPUT_SUFFIX   :=.bin
HEX_OUTPUT_SUFFIX   :=.hex

endif # HOST_ARCH is pi32