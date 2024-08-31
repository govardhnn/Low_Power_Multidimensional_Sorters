include makefile.inc

EG ?= $(EG_NAME)
FOLDER ?= ../../
VSIM ?= $(SIM)

TOPFILE ?= $(FOLDER)/bsv/$(EG)/$(TB_BSV).bsv
TOPMODULE ?= $(TB_BSV_TOP)

BSC_COMP_FLAGS = -elab -keep-fires -show-schedule -show-range-conflict -aggressive-conditions -no-warn-action-shadowing
BSC_LINK_FLAGS = -keep-fires
BSC_PATHS = -p $(FOLDER)/bsv/$(EG)/:$(FOLDER)/bsv/Common:%/Libraries

V_DIRS = -vdir verilog_dir -bdir build_v -info-dir build_v
VSIM_EXE = $(TOPMODULE)_vsim

.PHONY: all_vsim
all_vsim: clean verilog v_link v_simulate

build_v:
	mkdir build_v

verilog_dir:
	mkdir verilog_dir

.PHONY: verilog
verilog: build_v verilog_dir
	@echo Compiling for Verilog ...
	bsc -u -verilog $(V_DIRS) $(BSC_COMP_FLAGS) $(BSC_PATHS) -g $(TOPMODULE) $(TOPFILE)
	@echo Compiling for Verilog finished

.PHONY: v_link
v_link: build_v verilog_dir
	@echo Linking for Verilog sim ...
	bsc -e $(TOPMODULE) -verilog -o ./$(VSIM_EXE) $(V_DIRS) -vsim $(VSIM) verilog_dir/$(TOPMODULE).v $(FOLDER)/bsv/Common/C_imports.c
	@echo Linking for Verilog sim finished

.PHONY: v_simulate
v_simulate:
	@echo Verilog simulation...
	./$(VSIM_EXE) +bscvcd
	@echo Verilog simulation finished

.PHONY: clean
clean:
	rm -rf build_bsim build_v verilog_dir *~ *.vcd *_vsim *$(TOPMODULE)*  
