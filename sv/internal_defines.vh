
/**
 * internal_defines.vh
 *
 * 
 *
 * capstone
 * 
 *
 * This contains the definitions of constants and types that are used by the
 * core of the AGC processor, such as control signals and ALU operations.
 **/

/*----------------------------------------------------------------------------*
 *  You may edit this file and add or change any files in the src directory.  *
 *----------------------------------------------------------------------------*/



typedef enum logic [3:0] {
    ALU_AD,                // AD, ADS, DOUBLE #these last 3 don't mater NOOP, EXTND, INDEX = alu_out[29:15] = alu_src_1 + alu_src_2
    ALU_SU,                // SU -> alu_out[29:15] = alu_src_1 - alu_src_2
    ALU_AUG,               // AUG alu_out -> alu_out[29:15] = alu_src_2 incremented away from 0
    ALU_COM,               // COM -> alu_out[29:15] = ~alu_src_2
    ALU_READ,              // READ, WRITE, RETURN, TC, TCAA, TCF, L, TS, CA -> alu_out[29:15] = alu_src_2
    ALU_BRANCH,            // BZF, BZMF -> alu_out[29:15] = alu_src_1
    ALU_MP,                // MP, SQUARE -> alu_out[29:0] = alu_src_1 * alu_src_2
    ALU_DIM,               // DIM -> alu_out[29:15] = alu_src_2 incremented towards 0
    ALU_OR,                // OR, ROR, WOR -> alu_out[29:15] = alu_src_1 | alu_src_2
    ALU_AND,               // AND, RAND, MASK, WAND -> alu_out[29:15] = alu_src_1 & alu_src_2
    ALU_XOR,               // RXOR -> alu_out[29:15] = alu_src_1 ^ alu_src_2
    ALU_INCR,              // INCR -> alu_out[29:15] = alu_src_2 + 15'd1
    ALU_DV,                // DV -> alu_out[29:15] = alu_src_1[29:0] / alu_src_2
    ALU_QXCH              // QXCH, LXCH, XLQ, XCH -> alu_out[29:0] = {alu_src_1[29:15], alu_src_2}
} alu_op_t;

typedef enum logic [3:0] {
    A,
    L,
    Q,
    EB,
    FB, 
    BB,
    ZERO,
    CYR,
    SR,
    CYL,
    SL,
    TIME1,
    TIME2
} reg_t;

typedef enum logic [3:0] {
    // OUT
    DSKY_REG_1_HIGH,
    DSKY_REG_1_LOW,
    DSKY_REG_2_HIGH,
    DSKY_REG_2_LOW,
    DSKY_REG_3_HIGH,
    DSKY_REG_3_LOW,
    DSKY_PROG_NUM,
    DSKY_LAMPS,
    AXI_CALC_RES,
    // IN
    DSKY_VERB,
    DSKY_NOUN,
    DSKY_NEW,
    AXI_MISSION_TIME,
    AXI_APOGEE,
    AXI_PERIGEE
} IO_reg_t;

typedef enum logic [1:0] {
    K1,
    RS1_DATA1,
    RS1_RS2_DATA1
} alu_src1_t;

typedef enum logic [1:0] {
    K2,
    IO_READ_DATA2,
    RS2_DATA2,
    READ_DATA2 
} alu_src2_t;

typedef enum logic  {
    ALU_OUT,
    OLD_PC
} rd_t;


typedef enum logic [1:0] { 
    NO_BRANCH,
    BRANCH,
    BZF,
    BZMF
} branch_t;

typedef enum logic  {
    EXTEND,
    NEXTEND
}index_t;

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
    logic [11:0] K;
    logic [14:0] pc;
    index_t index;
    logic halt;
    logic [2:0] EB;
    logic [2:0] FB;
    logic in_ROM;
} ctrl_t;



