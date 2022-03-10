/**
 * internal_defines.vh
 *
 * RISC-V 32-bit Processor
 *
 * ECE 18-447
 * Carnegie Mellon University
 *
 * This contains the definitions of constants and types that are used by the
 * core of the RISC-V processor, such as control signals and ALU operations.
 **/

/*----------------------------------------------------------------------------*
 *  You may edit this file and add or change any files in the src directory.  *
 *----------------------------------------------------------------------------*/

`ifndef INTERNAL_DEFINES_VH_
`define INTERNAL_DEFINES_VH_

typedef enum logic [3:0] {
    ALU_AD,                // AD, ADS, #these last 3 don't mater NOOP, EXTND, INDEX
    ALU_SU,                // SU, BZF, BZFM
    ALU_AUG,                 // AUG
    ALU_RET,                 // RETURN, TC, TCAA, TCF, L, TS
    ALU_COM,                // COM
    ALU_READ,               // READ, WRITE
    ALU_ZL,                 // ZL, ZQ
    ALU_MP,                //MP, SQUARE
    ALU_DIM,                // DIM
    ALU_OR,                 // OR, ROR, WOR
    ALU_AND,                // AND, RAND, MASK, WAND
    ALU_XOR,                  //RXOR
    ALU_INCR,                //INCR
    ALU_DV,                  //DV
    ALU_QXCH,                //QXCH, LXCH, XLQ, XCH
} alu_op_t;

typedef enum logic [3:0] {
    A,
    L,
    Q,
    EB,
    FB,
    Z,  //TODO should we get rid of this from the reg file?
    BB,
    O,
    CYR,
    SR,
    CYL,
    SL,
    TIME1,
    TIME2,
} reg_t

typedef enum logic [1:0] {
    K1,
    RS1_DATA1,
    RS1_RS2_DATA1,
} alu_src1_t

typedef enum logic [1:0] {
    READ_DATA2,
    RS2_DATA2,
    IO_READ_DATA2,
    ADDR2,
} alu_src2_t

typedef enum logic  {
    ALU_OUT,
    OLD_PC,
} rd_t

typedef enum logic  {
    NO_BRANCH,
    BZF,
    BZFK,
} branch_t

typedef struct packed {
    alu_op_t alu_op;      // The ALU operation to perform
    logic data_read_en;   // whether or not we're loading the data
    reg_t wr1_sel;        // write register 1
    reg_t wr2_sel;        // write register 2
    logic wr1_en;         // write enaable register 1
    logic wr2_en;         // write enable register 2
    reg_t rs1_sel;        // read register 1
    reg_t rs2_sel;        //read register 2
    alu_src1_t alu_src1;
    alu_src2_t alu_src2;
    branch_t branch;
    rd_t rd;              // what data is writing back
    logic RAM_write_en;
    logic [2:0] IO_read_sel;
    logic IO_write_en;
    logic [12:0] K;
    logic [14:0] pc;
} ctrl_signals_t;



