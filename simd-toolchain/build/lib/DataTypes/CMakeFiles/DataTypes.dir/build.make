# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/shahnawaz/simd-toolchain

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/shahnawaz/simd-toolchain/build

# Include any dependencies generated for this target.
include lib/DataTypes/CMakeFiles/DataTypes.dir/depend.make

# Include the progress variables for this target.
include lib/DataTypes/CMakeFiles/DataTypes.dir/progress.make

# Include the compile flags for this target's objects.
include lib/DataTypes/CMakeFiles/DataTypes.dir/flags.make

lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o: lib/DataTypes/CMakeFiles/DataTypes.dir/flags.make
lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o: ../lib/DataTypes/Error.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/DataTypes.dir/Error.cc.o -c /home/shahnawaz/simd-toolchain/lib/DataTypes/Error.cc

lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/DataTypes.dir/Error.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/DataTypes/Error.cc > CMakeFiles/DataTypes.dir/Error.cc.i

lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/DataTypes.dir/Error.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/DataTypes/Error.cc -o CMakeFiles/DataTypes.dir/Error.cc.s

lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.requires:
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.requires

lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.provides: lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.requires
	$(MAKE) -f lib/DataTypes/CMakeFiles/DataTypes.dir/build.make lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.provides.build
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.provides

lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.provides.build: lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o

lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o: lib/DataTypes/CMakeFiles/DataTypes.dir/flags.make
lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o: ../lib/DataTypes/ContainerTypes.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/DataTypes.dir/ContainerTypes.cc.o -c /home/shahnawaz/simd-toolchain/lib/DataTypes/ContainerTypes.cc

lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/DataTypes.dir/ContainerTypes.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/DataTypes/ContainerTypes.cc > CMakeFiles/DataTypes.dir/ContainerTypes.cc.i

lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/DataTypes.dir/ContainerTypes.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/DataTypes/ContainerTypes.cc -o CMakeFiles/DataTypes.dir/ContainerTypes.cc.s

lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.requires:
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.requires

lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.provides: lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.requires
	$(MAKE) -f lib/DataTypes/CMakeFiles/DataTypes.dir/build.make lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.provides.build
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.provides

lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.provides.build: lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o

lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o: lib/DataTypes/CMakeFiles/DataTypes.dir/flags.make
lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o: ../lib/DataTypes/SIRDataType.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/DataTypes.dir/SIRDataType.cc.o -c /home/shahnawaz/simd-toolchain/lib/DataTypes/SIRDataType.cc

lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/DataTypes.dir/SIRDataType.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/DataTypes/SIRDataType.cc > CMakeFiles/DataTypes.dir/SIRDataType.cc.i

lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/DataTypes.dir/SIRDataType.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/DataTypes/SIRDataType.cc -o CMakeFiles/DataTypes.dir/SIRDataType.cc.s

lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.requires:
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.requires

lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.provides: lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.requires
	$(MAKE) -f lib/DataTypes/CMakeFiles/DataTypes.dir/build.make lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.provides.build
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.provides

lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.provides.build: lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o

lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o: lib/DataTypes/CMakeFiles/DataTypes.dir/flags.make
lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o: ../lib/DataTypes/SIROpcode.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_4)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/DataTypes.dir/SIROpcode.cc.o -c /home/shahnawaz/simd-toolchain/lib/DataTypes/SIROpcode.cc

lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/DataTypes.dir/SIROpcode.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/DataTypes/SIROpcode.cc > CMakeFiles/DataTypes.dir/SIROpcode.cc.i

lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/DataTypes.dir/SIROpcode.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/DataTypes/SIROpcode.cc -o CMakeFiles/DataTypes.dir/SIROpcode.cc.s

lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.requires:
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.requires

lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.provides: lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.requires
	$(MAKE) -f lib/DataTypes/CMakeFiles/DataTypes.dir/build.make lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.provides.build
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.provides

lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.provides.build: lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o

lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o: lib/DataTypes/CMakeFiles/DataTypes.dir/flags.make
lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o: ../lib/DataTypes/TargetOpcode.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_5)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/DataTypes.dir/TargetOpcode.cc.o -c /home/shahnawaz/simd-toolchain/lib/DataTypes/TargetOpcode.cc

lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/DataTypes.dir/TargetOpcode.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/DataTypes/TargetOpcode.cc > CMakeFiles/DataTypes.dir/TargetOpcode.cc.i

lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/DataTypes.dir/TargetOpcode.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/DataTypes/TargetOpcode.cc -o CMakeFiles/DataTypes.dir/TargetOpcode.cc.s

lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.requires:
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.requires

lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.provides: lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.requires
	$(MAKE) -f lib/DataTypes/CMakeFiles/DataTypes.dir/build.make lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.provides.build
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.provides

lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.provides.build: lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o

# Object files for target DataTypes
DataTypes_OBJECTS = \
"CMakeFiles/DataTypes.dir/Error.cc.o" \
"CMakeFiles/DataTypes.dir/ContainerTypes.cc.o" \
"CMakeFiles/DataTypes.dir/SIRDataType.cc.o" \
"CMakeFiles/DataTypes.dir/SIROpcode.cc.o" \
"CMakeFiles/DataTypes.dir/TargetOpcode.cc.o"

# External object files for target DataTypes
DataTypes_EXTERNAL_OBJECTS =

lib/libDataTypes.so: lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o
lib/libDataTypes.so: lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o
lib/libDataTypes.so: lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o
lib/libDataTypes.so: lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o
lib/libDataTypes.so: lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o
lib/libDataTypes.so: lib/DataTypes/CMakeFiles/DataTypes.dir/build.make
lib/libDataTypes.so: lib/libUtils.so
lib/libDataTypes.so: lib/libjsoncpp.so
lib/libDataTypes.so: lib/DataTypes/CMakeFiles/DataTypes.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX shared library ../libDataTypes.so"
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/DataTypes.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
lib/DataTypes/CMakeFiles/DataTypes.dir/build: lib/libDataTypes.so
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/build

lib/DataTypes/CMakeFiles/DataTypes.dir/requires: lib/DataTypes/CMakeFiles/DataTypes.dir/Error.cc.o.requires
lib/DataTypes/CMakeFiles/DataTypes.dir/requires: lib/DataTypes/CMakeFiles/DataTypes.dir/ContainerTypes.cc.o.requires
lib/DataTypes/CMakeFiles/DataTypes.dir/requires: lib/DataTypes/CMakeFiles/DataTypes.dir/SIRDataType.cc.o.requires
lib/DataTypes/CMakeFiles/DataTypes.dir/requires: lib/DataTypes/CMakeFiles/DataTypes.dir/SIROpcode.cc.o.requires
lib/DataTypes/CMakeFiles/DataTypes.dir/requires: lib/DataTypes/CMakeFiles/DataTypes.dir/TargetOpcode.cc.o.requires
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/requires

lib/DataTypes/CMakeFiles/DataTypes.dir/clean:
	cd /home/shahnawaz/simd-toolchain/build/lib/DataTypes && $(CMAKE_COMMAND) -P CMakeFiles/DataTypes.dir/cmake_clean.cmake
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/clean

lib/DataTypes/CMakeFiles/DataTypes.dir/depend:
	cd /home/shahnawaz/simd-toolchain/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/shahnawaz/simd-toolchain /home/shahnawaz/simd-toolchain/lib/DataTypes /home/shahnawaz/simd-toolchain/build /home/shahnawaz/simd-toolchain/build/lib/DataTypes /home/shahnawaz/simd-toolchain/build/lib/DataTypes/CMakeFiles/DataTypes.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : lib/DataTypes/CMakeFiles/DataTypes.dir/depend

