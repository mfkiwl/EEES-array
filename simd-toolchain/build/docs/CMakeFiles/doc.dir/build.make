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

# Utility rule file for doc.

# Include the progress variables for this target.
include docs/CMakeFiles/doc.dir/progress.make

docs/CMakeFiles/doc:

doc: docs/CMakeFiles/doc
doc: docs/CMakeFiles/doc.dir/build.make
.PHONY : doc

# Rule to build all files generated by this target.
docs/CMakeFiles/doc.dir/build: doc
.PHONY : docs/CMakeFiles/doc.dir/build

docs/CMakeFiles/doc.dir/clean:
	cd /home/shahnawaz/simd-toolchain/build/docs && $(CMAKE_COMMAND) -P CMakeFiles/doc.dir/cmake_clean.cmake
.PHONY : docs/CMakeFiles/doc.dir/clean

docs/CMakeFiles/doc.dir/depend:
	cd /home/shahnawaz/simd-toolchain/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/shahnawaz/simd-toolchain /home/shahnawaz/simd-toolchain/docs /home/shahnawaz/simd-toolchain/build /home/shahnawaz/simd-toolchain/build/docs /home/shahnawaz/simd-toolchain/build/docs/CMakeFiles/doc.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : docs/CMakeFiles/doc.dir/depend
