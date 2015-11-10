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
include tools/s-as/CMakeFiles/s-as.dir/depend.make

# Include the progress variables for this target.
include tools/s-as/CMakeFiles/s-as.dir/progress.make

# Include the compile flags for this target's objects.
include tools/s-as/CMakeFiles/s-as.dir/flags.make

tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o: tools/s-as/CMakeFiles/s-as.dir/flags.make
tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o: ../tools/s-as/s-as.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/tools/s-as && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/s-as.dir/s-as.cc.o -c /home/shahnawaz/simd-toolchain/tools/s-as/s-as.cc

tools/s-as/CMakeFiles/s-as.dir/s-as.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/s-as.dir/s-as.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/tools/s-as && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/tools/s-as/s-as.cc > CMakeFiles/s-as.dir/s-as.cc.i

tools/s-as/CMakeFiles/s-as.dir/s-as.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/s-as.dir/s-as.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/tools/s-as && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/tools/s-as/s-as.cc -o CMakeFiles/s-as.dir/s-as.cc.s

tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.requires:
.PHONY : tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.requires

tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.provides: tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.requires
	$(MAKE) -f tools/s-as/CMakeFiles/s-as.dir/build.make tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.provides.build
.PHONY : tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.provides

tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.provides.build: tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o

# Object files for target s-as
s__as_OBJECTS = \
"CMakeFiles/s-as.dir/s-as.cc.o"

# External object files for target s-as
s__as_EXTERNAL_OBJECTS =

bin/s-as: tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o
bin/s-as: tools/s-as/CMakeFiles/s-as.dir/build.make
bin/s-as: lib/libTarget.so
bin/s-as: lib/libBaselineTarget.so
bin/s-as: lib/libBaselineASMParser.so
bin/s-as: lib/libUtils.so
bin/s-as: lib/libDataTypes.so
bin/s-as: lib/libBaselineTarget.so
bin/s-as: lib/libTarget.so
bin/s-as: lib/libSIR.so
bin/s-as: lib/libDataTypes.so
bin/s-as: lib/libUtils.so
bin/s-as: lib/libjsoncpp.so
bin/s-as: tools/s-as/CMakeFiles/s-as.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable ../../bin/s-as"
	cd /home/shahnawaz/simd-toolchain/build/tools/s-as && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/s-as.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
tools/s-as/CMakeFiles/s-as.dir/build: bin/s-as
.PHONY : tools/s-as/CMakeFiles/s-as.dir/build

tools/s-as/CMakeFiles/s-as.dir/requires: tools/s-as/CMakeFiles/s-as.dir/s-as.cc.o.requires
.PHONY : tools/s-as/CMakeFiles/s-as.dir/requires

tools/s-as/CMakeFiles/s-as.dir/clean:
	cd /home/shahnawaz/simd-toolchain/build/tools/s-as && $(CMAKE_COMMAND) -P CMakeFiles/s-as.dir/cmake_clean.cmake
.PHONY : tools/s-as/CMakeFiles/s-as.dir/clean

tools/s-as/CMakeFiles/s-as.dir/depend:
	cd /home/shahnawaz/simd-toolchain/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/shahnawaz/simd-toolchain /home/shahnawaz/simd-toolchain/tools/s-as /home/shahnawaz/simd-toolchain/build /home/shahnawaz/simd-toolchain/build/tools/s-as /home/shahnawaz/simd-toolchain/build/tools/s-as/CMakeFiles/s-as.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : tools/s-as/CMakeFiles/s-as.dir/depend

