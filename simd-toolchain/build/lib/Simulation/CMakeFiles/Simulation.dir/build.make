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
include lib/Simulation/CMakeFiles/Simulation.dir/depend.make

# Include the progress variables for this target.
include lib/Simulation/CMakeFiles/Simulation.dir/progress.make

# Include the compile flags for this target's objects.
include lib/Simulation/CMakeFiles/Simulation.dir/flags.make

lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o: ../lib/Simulation/CycleAccurateSimulator.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/CycleAccurateSimulator.cc

lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/CycleAccurateSimulator.cc > CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/CycleAccurateSimulator.cc -o CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o

lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o: ../lib/Simulation/SimCore.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/SimCore.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/SimCore.cc

lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/SimCore.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/SimCore.cc > CMakeFiles/Simulation.dir/SimCore.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/SimCore.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/SimCore.cc -o CMakeFiles/Simulation.dir/SimCore.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o

lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o: ../lib/Simulation/SimMemoryCmd.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/SimMemoryCmd.cc

lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/SimMemoryCmd.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/SimMemoryCmd.cc > CMakeFiles/Simulation.dir/SimMemoryCmd.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/SimMemoryCmd.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/SimMemoryCmd.cc -o CMakeFiles/Simulation.dir/SimMemoryCmd.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o

lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o: ../lib/Simulation/SimObjectBase.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_4)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/SimObjectBase.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/SimObjectBase.cc

lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/SimObjectBase.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/SimObjectBase.cc > CMakeFiles/Simulation.dir/SimObjectBase.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/SimObjectBase.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/SimObjectBase.cc -o CMakeFiles/Simulation.dir/SimObjectBase.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o

lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o: ../lib/Simulation/SimProcessor.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_5)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/SimProcessor.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/SimProcessor.cc

lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/SimProcessor.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/SimProcessor.cc > CMakeFiles/Simulation.dir/SimProcessor.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/SimProcessor.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/SimProcessor.cc -o CMakeFiles/Simulation.dir/SimProcessor.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o

lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o: ../lib/Simulation/SimProgramSection.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_6)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/SimProgramSection.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/SimProgramSection.cc

lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/SimProgramSection.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/SimProgramSection.cc > CMakeFiles/Simulation.dir/SimProgramSection.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/SimProgramSection.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/SimProgramSection.cc -o CMakeFiles/Simulation.dir/SimProgramSection.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o

lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o: ../lib/Simulation/SimSRAM.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_7)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/SimSRAM.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/SimSRAM.cc

lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/SimSRAM.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/SimSRAM.cc > CMakeFiles/Simulation.dir/SimSRAM.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/SimSRAM.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/SimSRAM.cc -o CMakeFiles/Simulation.dir/SimSRAM.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o

lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o: lib/Simulation/CMakeFiles/Simulation.dir/flags.make
lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o: ../lib/Simulation/SimSyncChannel.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/shahnawaz/simd-toolchain/build/CMakeFiles $(CMAKE_PROGRESS_8)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/Simulation.dir/SimSyncChannel.cc.o -c /home/shahnawaz/simd-toolchain/lib/Simulation/SimSyncChannel.cc

lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Simulation.dir/SimSyncChannel.cc.i"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/shahnawaz/simd-toolchain/lib/Simulation/SimSyncChannel.cc > CMakeFiles/Simulation.dir/SimSyncChannel.cc.i

lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Simulation.dir/SimSyncChannel.cc.s"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && /usr/local/bin/clang++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/shahnawaz/simd-toolchain/lib/Simulation/SimSyncChannel.cc -o CMakeFiles/Simulation.dir/SimSyncChannel.cc.s

lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.requires:
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.requires

lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.provides: lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.requires
	$(MAKE) -f lib/Simulation/CMakeFiles/Simulation.dir/build.make lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.provides.build
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.provides

lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.provides.build: lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o

# Object files for target Simulation
Simulation_OBJECTS = \
"CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o" \
"CMakeFiles/Simulation.dir/SimCore.cc.o" \
"CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o" \
"CMakeFiles/Simulation.dir/SimObjectBase.cc.o" \
"CMakeFiles/Simulation.dir/SimProcessor.cc.o" \
"CMakeFiles/Simulation.dir/SimProgramSection.cc.o" \
"CMakeFiles/Simulation.dir/SimSRAM.cc.o" \
"CMakeFiles/Simulation.dir/SimSyncChannel.cc.o"

# External object files for target Simulation
Simulation_EXTERNAL_OBJECTS =

lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/build.make
lib/libSimulation.so: lib/libDataTypes.so
lib/libSimulation.so: lib/libUtils.so
lib/libSimulation.so: lib/libjsoncpp.so
lib/libSimulation.so: lib/Simulation/CMakeFiles/Simulation.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX shared library ../libSimulation.so"
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/Simulation.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
lib/Simulation/CMakeFiles/Simulation.dir/build: lib/libSimulation.so
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/build

lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/CycleAccurateSimulator.cc.o.requires
lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/SimCore.cc.o.requires
lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/SimMemoryCmd.cc.o.requires
lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/SimObjectBase.cc.o.requires
lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/SimProcessor.cc.o.requires
lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/SimProgramSection.cc.o.requires
lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/SimSRAM.cc.o.requires
lib/Simulation/CMakeFiles/Simulation.dir/requires: lib/Simulation/CMakeFiles/Simulation.dir/SimSyncChannel.cc.o.requires
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/requires

lib/Simulation/CMakeFiles/Simulation.dir/clean:
	cd /home/shahnawaz/simd-toolchain/build/lib/Simulation && $(CMAKE_COMMAND) -P CMakeFiles/Simulation.dir/cmake_clean.cmake
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/clean

lib/Simulation/CMakeFiles/Simulation.dir/depend:
	cd /home/shahnawaz/simd-toolchain/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/shahnawaz/simd-toolchain /home/shahnawaz/simd-toolchain/lib/Simulation /home/shahnawaz/simd-toolchain/build /home/shahnawaz/simd-toolchain/build/lib/Simulation /home/shahnawaz/simd-toolchain/build/lib/Simulation/CMakeFiles/Simulation.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : lib/Simulation/CMakeFiles/Simulation.dir/depend

