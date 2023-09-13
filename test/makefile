# Version: GHDL 0.29 (20100109) [Sokcho edition] - mcode code generator
#	I've disabled warnings from numeric_std otherwise they 
# popped up because of a few innocuous 'X' in signals coming from don't cares
# Run makefile FROM the riscV_pipeline/test/ directory
# change SRC_FILE here if running a different testbench

SRC_PATH=/home/agrael/pierpaolo/cafp/hardware/riscV_pipeline
SRC_FILE=datapath
TB_FILE=$(SRC_FILE)_TB
GHDL=/usr/bin/ghdl-mcode
GHDLFLAGS=
GHDLRUNFLAGS= --ieee-asserts=disable --stop-time=10000ns --vcd=$(VCDFILE)
VCDFILE=$(SRC_FILE).vcd
#VCDFILE=$(SRC_FILE)_arithm.vcd
#--disp-time 

# Default target : elaborate
all : analyze elab run

# analyze
analyze: 
	$(GHDL) -a $(SRC_PATH)/common.vhd
	$(GHDL) -a $(SRC_PATH)/mux_2_1_64b.vhd
	$(GHDL) -a $(SRC_PATH)/mux_2_1_32b.vhd
	$(GHDL) -a $(SRC_PATH)/mux_3_1.vhd
	$(GHDL) -a $(SRC_PATH)/mux_32_1.vhd
	$(GHDL) -a $(SRC_PATH)/mux_ID_EX_Flush.vhd
	$(GHDL) -a $(SRC_PATH)/mux_EX_MEM_Flush.vhd
	$(GHDL) -a $(SRC_PATH)/reg_pkg.vhd
#	$(GHDL) -a $(SRC_PATH)/OR_unit.vhd
	$(GHDL) -a $(SRC_PATH)/FullAdder.vhd
	$(GHDL) -a $(SRC_PATH)/adder_subtractor.vhd
	$(GHDL) -a $(SRC_PATH)/adder_subtractor_WordOvrf.vhd
	$(GHDL) -a $(SRC_PATH)/ADDER_N.vhd
	$(GHDL) -a $(SRC_PATH)/AND_1xN.vhd
	$(GHDL) -a $(SRC_PATH)/register_file.vhd
	$(GHDL) -a $(SRC_PATH)/program_counter.vhd
	$(GHDL) -a $(SRC_PATH)/instruction_memory.vhd
	$(GHDL) -a $(SRC_PATH)/IF_ID_DIV.vhd
	$(GHDL) -a $(SRC_PATH)/imm_generator.vhd
	$(GHDL) -a $(SRC_PATH)/branch_address_unit.vhd
	$(GHDL) -a $(SRC_PATH)/ID_EX_DIV.vhd
	$(GHDL) -a $(SRC_PATH)/hazard_unit.vhd
	$(GHDL) -a $(SRC_PATH)/forwarding_unit_branch.vhd
	$(GHDL) -a $(SRC_PATH)/forwarding_unit_ALU.vhd
	$(GHDL) -a $(SRC_PATH)/EX_MEM_DIV.vhd
	$(GHDL) -a $(SRC_PATH)/control_unit.vhd
	$(GHDL) -a $(SRC_PATH)/branch_comparator.vhd
	$(GHDL) -a $(SRC_PATH)/multiplier_divider.vhd
	$(GHDL) -a $(SRC_PATH)/multiplier.vhd
	$(GHDL) -a $(SRC_PATH)/divider.vhd
	$(GHDL) -a $(SRC_PATH)/ALU_control_unit.vhd
	$(GHDL) -a $(SRC_PATH)/ALU.vhd
	$(GHDL) -a $(SRC_PATH)/exception_unit.vhd
	$(GHDL) -a $(SRC_PATH)/MEM_WB_DIV.vhd
	$(GHDL) -a $(SRC_PATH)/datamem.vhd
	$(GHDL) -a $(SRC_PATH)/datamem_interface.vhd
	$(GHDL) -a $(SRC_PATH)/debug_regbank.vhd

#	$(GHDL) -a /home/agrael/pierpaolo/cafp/hardware/riscV_pipeline/mux_2_1_64b.vhd
	$(GHDL) -a $(SRC_PATH)/$(SRC_FILE).vhd
	$(GHDL) -a $(TB_FILE).vhd

# Elaborate target.  Almost useless
elab : 
	$(GHDL) -c $(GHDLFLAGS) -e $(TB_FILE)

# Run target
run : 
	$(GHDL) -c $(GHDLFLAGS) -r $(TB_FILE)  $(GHDLRUNFLAGS)