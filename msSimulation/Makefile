# NOTE: Unlike Mike's original Makefile, this one does not attempt
# to generate Verilog.  It assumes that all Verilog files have been
# pregenerated, so all it does is actually build the .vvp simulation
# file from the existing Verilog.

ROM=Validation-hardware-simulation
#ROM=Aurora12

EXTRA_IV_ARGS = 
ifdef DUMPFILE
	EXTRA_IV_ARGS += -Pmain.DUMPFILE='"$(DUMPFILE)"'
endif
ifdef RUNLENGTH
	EXTRA_IV_ARGS += -Pmain.RUNLENGTH=$(RUNLENGTH)
endif
DUMPED =
ifdef DUMP_ALL
	EXTRA_IV_ARGS += -DDUMP_ALL
	DUMPED = 1
endif
ifdef DUMP_BACKPLANE
	EXTRA_IV_ARGS += -DDUMP_BACKPLANE
	DUMPED = 1
endif
ifdef DUMP_DECODER
	EXTRA_IV_ARGS += -DDUMP_DECODER
	DUMPED = 1
endif
ifndef DUMPED
	EXTRA_IV_ARGS += -DDUMP_ALL
endif

MODULES = scaler\
	  timer\
	  sq_register\
	  stage_branch\
	  crosspoint_nqi\
	  crosspoint_ii\
	  service_gates\
	  four_bit_1\
	  four_bit_2\
	  four_bit_3\
	  four_bit_4\
	  parity_s_register\
	  alarms\
	  memory_timing_addressing\
	  rupt_service\
	  fixed_erasable_memory\
	  inout_i\
	  inout_ii\
	  inout_iii\
	  inout_iv\
	  counter_cell_i\
	  counter_cell_ii\
	  inout_v\
	  inout_vi\
	  inout_vii\

TEST_CONNECTOR = ch77_alarm_box

AUTOGEN_FILES = $(addsuffix .v, $(addprefix modules/, $(MODULES) $(TEST_CONNECTOR)))

COMMON_SOURCES = components/nor_1.v\
		 components/nor_2.v\
		 components/nor_3.v\
		 components/nor_4.v\
		 components/od_buf.v\
		 components/tri_buf.v\
		 components/U74HC04.v\
		 components/U74HC02.v\
		 components/U74HC27.v\
		 components/U74HC4002.v\
		 components/U74LVC06.v\
		 components/U74LVC07.v\
		 components/U74HC244.v\
		 components/MR0A16A.v\
		 components/SST39VF200A.v\

SIM_SOURCES = $(COMMON_SOURCES)\
	      $(AUTOGEN_FILES)\
	      agc.v\
	      tb_agc.v

.PHONY: all
all: ../Schematics/roms/rom.v tb_agc.vvp

../Schematics/roms/rom.v: ../Schematics/roms/$(ROM).v
	cp $< $@

$(info $(SIM_SOURCES))
tb_agc.vvp: 
	iverilog $(EXTRA_IV_ARGS) -o $@ $(SIM_SOURCES)

.PHONY: clean
clean:
	-rm ../Schematics/roms/rom.v tb_agc.vvp

