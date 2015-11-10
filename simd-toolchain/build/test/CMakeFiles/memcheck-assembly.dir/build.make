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

# Utility rule file for memcheck-assembly.

# Include the progress variables for this target.
include test/CMakeFiles/memcheck-assembly.dir/progress.make

test/CMakeFiles/memcheck-assembly:

memcheck-assembly: test/CMakeFiles/memcheck-assembly
memcheck-assembly: test/CMakeFiles/memcheck-assembly.dir/build.make
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold "Running Test assembly with memory checker"
	cd /home/shahnawaz/simd-toolchain/build/test && /usr/bin/python /home/shahnawaz/simd-toolchain/build/lib/solver/python/test_driver/test_tool.py --tool-path /home/shahnawaz/simd-toolchain/build/bin --memcheck --solver-root /home/shahnawaz/simd-toolchain/solver /home/shahnawaz/simd-toolchain/test/assembly --parallel
.PHONY : memcheck-assembly

# Rule to build all files generated by this target.
test/CMakeFiles/memcheck-assembly.dir/build: memcheck-assembly
.PHONY : test/CMakeFiles/memcheck-assembly.dir/build

test/CMakeFiles/memcheck-assembly.dir/clean:
	cd /home/shahnawaz/simd-toolchain/build/test && $(CMAKE_COMMAND) -P CMakeFiles/memcheck-assembly.dir/cmake_clean.cmake
.PHONY : test/CMakeFiles/memcheck-assembly.dir/clean

test/CMakeFiles/memcheck-assembly.dir/depend:
	cd /home/shahnawaz/simd-toolchain/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/shahnawaz/simd-toolchain /home/shahnawaz/simd-toolchain/test /home/shahnawaz/simd-toolchain/build /home/shahnawaz/simd-toolchain/build/test /home/shahnawaz/simd-toolchain/build/test/CMakeFiles/memcheck-assembly.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : test/CMakeFiles/memcheck-assembly.dir/depend
