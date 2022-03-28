# Target executable
TARGET = simv

# Source files
SRC = $(wildcard *.sv) $(wildcard *.v)

# Set the number of threads to use for parallel compilation (2 * cores)
CORES = $(shell getconf _NPROCESSORS_ONLN)
THREADS = $(shell echo $$((2 * $(CORES))))

# VCS flags
VCSFLAGS = -full64 -sverilog -debug_all +lint=all,noVCDE +warn=all -j$(THREADS) \
                                         -timescale=1ns/1ps +v2k
COMMON_FLAGS +=

# Simulator
SIM = vcs

# Altera FPGA library files (for simulation)
INC_V = /afs/ece/support/altera/release/16.1.2/quartus/eda/sim_lib/altera_primitives.v \
                                /afs/ece/support/altera/release/16.1.2/quartus/eda/sim_lib/220model.v \
                                /afs/ece/support/altera/release/16.1.2/quartus/eda/sim_lib/sgate.v \
                                /afs/ece/support/altera/release/16.1.2/quartus/eda/sim_lib/altera_mf.v \
                                /afs/ece/support/altera/release/16.1.2/quartus/eda/sim_lib/cyclonev_atoms.v
INC_V_FLAGS = $(addprefix -v , $(INC_V))
INC_SV =
INC_SV_FLAGS = $(addprefix -v , $(INC_SV))

# Copy common flags
VCSFLAGS += $(COMMON_FLAGS)

default : top.sv 
	$(SIM) $(VCSFLAGS) $(INC_V_FLAGS) $(INC_SV_FLAGS) -o $(TARGET) 

