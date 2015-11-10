################################
# GENERAL OPTIONS
PROJECT_NAME   		= mirror
VERBOSE				= 0

################################
# TARGET CONFIGURATION
# set configurable to 1 if you modify these variables, 
# either here or from the commandline. Fixing the configuration
# and setting configurable to 0 will result in less overhead
CONFIGURABLE        = 1
N_PE				= 8
AUTO_BYPASS         = 0
ARCHITECTURE_FILE	= arch-conf.json

################################
# SIMULATION OPTIONS
SIM_MAX_CYCLES   	= 10000


################################
# USAGE
# 
# make sim    Simulate code on cycle accurate simulator
# make rtl    Simulate code on RTL 
# make check  Compare simulation outputs of both methods for consistency
# make clean  Clean all generated files
#

################################
# AUTOMAGIC VARIABLES
# Do not edit after this point!
# (unless you know what you are doing of course. I so, just go ahead, enjoy!)
#
ASSEMBLY_FILE		= $(PROJECT_NAME).s
ifeq ($(AUTO_BYPASS), 1)
	TEMPLATE_FILE	= $(PROJECT_NAME)_auto.t
	EXP_BYPASS      = false
	TARGET_DIR   	= ./RTL-baseline-32b-4stage
else
	TEMPLATE_FILE	= $(PROJECT_NAME).t
	EXP_BYPASS      = true
	TARGET_DIR   	= ./RTL-baseline-32b-4stage-bypass
endif

ifeq ($(VERBOSE), 0)
	SINK = > /dev/null
	VERB =
else
	SINK =
	VERB = --verbose
endif


################################
# GENERAL TARGETS
#
all: sim rtl

clean:
	@rm -rf compiled.zip
	@rm -rf sim-out
	@rm -rf ./RTL-baseline-32b-4stage*
	@rm -rf $(ASSEMBLY_FILE)
	@rm -rf $(ARCHITECTURE_FILE)
	@rm -rf rtl-sim-out

#generic target name
assemby:$(ASSEMBLY_FILE)
$(ASSEMBLY_FILE):$(TEMPLATE_FILE) $(ARCHITECTURE_FILE)
	@echo Generating Assembly from Template
	@s-as-gen -i $(TEMPLATE_FILE) -o $(ASSEMBLY_FILE) $(ARCHITECTURE_FILE)

ifneq ( ,$(findstring command line, "$(filter command line, $(origin ARCHITECTURE_FILE))"))
#if architecture file is from the commandline, regenerate RTL and simulation files
.PHONY:$(TARGET_DIR) compiled.zip
else
#else always generate the arch config as the makefile variables can come both from the file or commandline
#and can thus not be trusted! N.B. this implies the file is generated every time, requiring new RTL templating
#and compilation. To avoid this, comment the PHONY target below this comment
ifeq ($(CONFIGURABLE), 1)
.PHONY:$(ARCHITECTURE_FILE)
endif
$(ARCHITECTURE_FILE):$(ARCHITECTURE_FILE).t
	@echo -e "Generating Config File\n\t-- Explicit Bypass: $(EXP_BYPASS)\n\t-- NPE: $(N_PE)"
	@sed s/EXP_BYPASS/$(EXP_BYPASS)/g $(ARCHITECTURE_FILE).t | sed -e s/NPE/$(N_PE)/g > $(ARCHITECTURE_FILE)
endif

################################
# SIMULATION TARGETS
#
compiled.zip: $(ASSEMBLY_FILE) $(ARCHITECTURE_FILE)
	@echo Compling for Simulation
	@s-cc $(ASSEMBLY_FILE) -o compiled --arch-cfg=$(ARCHITECTURE_FILE)

sim-out: compiled.zip $(ARCHITECTURE_FILE)
	@echo Simulating
	@s-run-sim compiled.zip  --max-cycle=$(SIM_MAX_CYCLES) --arch-cfg=$(ARCHITECTURE_FILE) --dump-dmem --sim-stat --full-trace

sim:sim-out

################################
# RTL SIMULATION TARGETS
#
$(TARGET_DIR): $(ARCHITECTURE_FILE)
	@echo Generating RTL from Template
	@s-rtl-gen  $(ARCHITECTURE_FILE)

rtl-sim-out:$(TARGET_DIR) compiled.zip
	@echo "Simulating RTL"
	@$(TARGET_DIR)/misc/rtl-sim compiled.zip $(VERB) $(SINK)

rtl-gui:$(TARGET_DIR)
	@echo Starting GUI for RTL Simulation
	@$(TARGET_DIR)/misc/rtl-sim compiled.zip --gui $(VERB) $(SINK)

rtl:rtl-sim-out

################################
# SIM-RTL COMPARE TARGETS
#

#very rudimentary check of output files
check:sim rtl
	@cmp sim-out/dump/dmem.baseline.vector.dump rtl-sim-out/pe-array.dmem.dump -n `stat -c %s rtl-sim-out/pe-array.dmem.dump`
	@sed s/x/0/g rtl-sim-out/cp.dmem.dump | sed  '/\/\//d' | cmp sim-out/dump/dmem.baseline.scalar.dump -i 3:0 
