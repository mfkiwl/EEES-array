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
include lib/Transform/CMakeFiles/Transform.dir/depend.make

# Include the progress variables for this target.
include lib/Transform/CMakeFiles/Transform.dir/progress.make

# Include the compile flags for this target's objects.
include lib/Transform/CMakeFiles/Transform.dir/flags.make

lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o: lib/Transform/CMakeFiles/Transform.dir/flags.make
lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o: ../lib/Transform/SIRCallSiteProcessing.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o -c /home/shahnawaz/simd-toolchain/lib/Transform/SIRCallSiteProcessing.cc

lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Transform/SIRCallSiteProcessing.cc > CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.i

lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Transform/SIRCallSiteProcessing.cc -o CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.s

lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.requires:
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.requires

lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.provides: lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.requires
	$(MAKE) -f lib/Transform/CMakeFiles/Transform.dir/build.make lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.provides.build
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.provides

lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.provides.build: lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o

lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o: lib/Transform/CMakeFiles/Transform.dir/flags.make
lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o: ../lib/Transform/SplitSIRCallBlock.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o -c /home/shahnawaz/simd-toolchain/lib/Transform/SplitSIRCallBlock.cc

lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Transform/SplitSIRCallBlock.cc > CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.i

lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Transform/SplitSIRCallBlock.cc -o CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.s

lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.requires:
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.requires

lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.provides: lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.requires
	$(MAKE) -f lib/Transform/CMakeFiles/Transform.dir/build.make lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.provides.build
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.provides

lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.provides.build: lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o

lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o: lib/Transform/CMakeFiles/Transform.dir/flags.make
lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o: ../lib/Transform/SIRSimplfyBranch.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o -c /home/shahnawaz/simd-toolchain/lib/Transform/SIRSimplfyBranch.cc

lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Transform/SIRSimplfyBranch.cc > CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.i

lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Transform/SIRSimplfyBranch.cc -o CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.s

lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.requires:
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.requires

lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.provides: lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.requires
	$(MAKE) -f lib/Transform/CMakeFiles/Transform.dir/build.make lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.provides.build
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.provides

lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.provides.build: lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o

lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o: lib/Transform/CMakeFiles/Transform.dir/flags.make
lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o: ../lib/Transform/SIRFunctionLayout.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_4)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o -c /home/shahnawaz/simd-toolchain/lib/Transform/SIRFunctionLayout.cc

lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Transform.dir/SIRFunctionLayout.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Transform/SIRFunctionLayout.cc > CMakeFiles/Transform.dir/SIRFunctionLayout.cc.i

lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Transform.dir/SIRFunctionLayout.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Transform/SIRFunctionLayout.cc -o CMakeFiles/Transform.dir/SIRFunctionLayout.cc.s

lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.requires:
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.requires

lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.provides: lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.requires
	$(MAKE) -f lib/Transform/CMakeFiles/Transform.dir/build.make lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.provides.build
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.provides

lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.provides.build: lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o

lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o: lib/Transform/CMakeFiles/Transform.dir/flags.make
lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o: ../lib/Transform/DeadFunctionElimination.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_5)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o -c /home/shahnawaz/simd-toolchain/lib/Transform/DeadFunctionElimination.cc

lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Transform.dir/DeadFunctionElimination.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Transform/DeadFunctionElimination.cc > CMakeFiles/Transform.dir/DeadFunctionElimination.cc.i

lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Transform.dir/DeadFunctionElimination.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Transform/DeadFunctionElimination.cc -o CMakeFiles/Transform.dir/DeadFunctionElimination.cc.s

lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.requires:
.PHONY : lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.requires

lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.provides: lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.requires
	$(MAKE) -f lib/Transform/CMakeFiles/Transform.dir/build.make lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.provides.build
.PHONY : lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.provides

lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.provides.build: lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o

lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o: lib/Transform/CMakeFiles/Transform.dir/flags.make
lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o: ../lib/Transform/SIRFinalize.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_6)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Transform.dir/SIRFinalize.cc.o -c /home/shahnawaz/simd-toolchain/lib/Transform/SIRFinalize.cc

lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Transform.dir/SIRFinalize.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Transform/SIRFinalize.cc > CMakeFiles/Transform.dir/SIRFinalize.cc.i

lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Transform.dir/SIRFinalize.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Transform/SIRFinalize.cc -o CMakeFiles/Transform.dir/SIRFinalize.cc.s

lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.requires:
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.requires

lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.provides: lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.requires
	$(MAKE) -f lib/Transform/CMakeFiles/Transform.dir/build.make lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.provides.build
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.provides

lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.provides.build: lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o

lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o: lib/Transform/CMakeFiles/Transform.dir/flags.make
lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o: ../lib/Transform/SIRLocalOpt.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_7)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Transform.dir/SIRLocalOpt.cc.o -c /home/shahnawaz/simd-toolchain/lib/Transform/SIRLocalOpt.cc

lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Transform.dir/SIRLocalOpt.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Transform/SIRLocalOpt.cc > CMakeFiles/Transform.dir/SIRLocalOpt.cc.i

lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Transform.dir/SIRLocalOpt.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Transform/SIRLocalOpt.cc -o CMakeFiles/Transform.dir/SIRLocalOpt.cc.s

lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.requires:
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.requires

lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.provides: lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.requires
	$(MAKE) -f lib/Transform/CMakeFiles/Transform.dir/build.make lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.provides.build
.PHONY : lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.provides

lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.provides.build: lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o

# Object files for target Transform
Transform_OBJECTS = \
"CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o" \
"CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o" \
"CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o" \
"CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o" \
"CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o" \
"CMakeFiles/Transform.dir/SIRFinalize.cc.o" \
"CMakeFiles/Transform.dir/SIRLocalOpt.cc.o"

# External object files for target Transform
Transform_EXTERNAL_OBJECTS =

lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/build.make
lib/libTransform.so: lib/libSIR.so
lib/libTransform.so: lib/libDataTypes.so
lib/libTransform.so: lib/libUtils.so
lib/libTransform.so: lib/libjsoncpp.so
lib/libTransform.so: lib/Transform/CMakeFiles/Transform.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX shared library ../libTransform.so"
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/Transform.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
lib/Transform/CMakeFiles/Transform.dir/build: lib/libTransform.so
.PHONY : lib/Transform/CMakeFiles/Transform.dir/build

lib/Transform/CMakeFiles/Transform.dir/requires: lib/Transform/CMakeFiles/Transform.dir/SIRCallSiteProcessing.cc.o.requires
lib/Transform/CMakeFiles/Transform.dir/requires: lib/Transform/CMakeFiles/Transform.dir/SplitSIRCallBlock.cc.o.requires
lib/Transform/CMakeFiles/Transform.dir/requires: lib/Transform/CMakeFiles/Transform.dir/SIRSimplfyBranch.cc.o.requires
lib/Transform/CMakeFiles/Transform.dir/requires: lib/Transform/CMakeFiles/Transform.dir/SIRFunctionLayout.cc.o.requires
lib/Transform/CMakeFiles/Transform.dir/requires: lib/Transform/CMakeFiles/Transform.dir/DeadFunctionElimination.cc.o.requires
lib/Transform/CMakeFiles/Transform.dir/requires: lib/Transform/CMakeFiles/Transform.dir/SIRFinalize.cc.o.requires
lib/Transform/CMakeFiles/Transform.dir/requires: lib/Transform/CMakeFiles/Transform.dir/SIRLocalOpt.cc.o.requires
.PHONY : lib/Transform/CMakeFiles/Transform.dir/requires

lib/Transform/CMakeFiles/Transform.dir/clean:
	cd /home/shahnawaz/simd-toolchain/build/lib/Transform && $(CMAKE_COMMAND) -P CMakeFiles/Transform.dir/cmake_clean.cmake
.PHONY : lib/Transform/CMakeFiles/Transform.dir/clean

lib/Transform/CMakeFiles/Transform.dir/depend:
	cd /home/shahnawaz/simd-toolchain/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/shahnawaz/simd-toolchain /home/shahnawaz/simd-toolchain/lib/Transform /home/shahnawaz/simd-toolchain/build /home/shahnawaz/simd-toolchain/build/lib/Transform /home/shahnawaz/simd-toolchain/build/lib/Transform/CMakeFiles/Transform.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : lib/Transform/CMakeFiles/Transform.dir/depend

