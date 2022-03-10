/**
 * lib.sv
 *
 * RISC-V 32-bit Processor
 *
 * ECE 18-447
 * Carnegie Mellon University
 *
 * This is the library of standard components used by the RISC-V processor,
 * which includes both synchronous and combinational components.
 **/

/*----------------------------------------------------------------------------*
 *  You may edit this file and add or change any files in the src directory.  *
 *----------------------------------------------------------------------------*/

// Force the compiler to throw an error if any variables are undeclared
`default_nettype none
`include "internal_defines.vh" 
/*--------------------------------------------------------------------------------------------------------------------
 * Combinational Components
 *--------------------------------------------------------------------------------------------------------------------*/

/**
 * Selects on input from INPUTS inputs to output, each of WIDTH bits.
 *
 * Parameters:
 *  - INPUTS    The number of values from which the mux can select.
 *  - WIDTH     The number of bits each value contains.
 *
 * Inputs:
 *  - in        The values from which to select, packed together as a single
 *              bit-vector.
 *  - sel       The value from the inputs to output.
 *
 * Outputs:
 *  - out       The selected output from the inputs.
 **/
module mux
    #(parameter INPUTS=0, WIDTH=0)
    (input  logic [INPUTS-1:0][WIDTH-1:0]   in,
     input  logic [$clog2(INPUTS)-1:0]      sel,
     output logic [WIDTH-1:0]               out);

    assign out = in[sel];

endmodule: mux

/**
 * makes the inth bit 1 and the rest of the bits 0 if enabled
 *
 * Parameters:
 *  - INPUTS    The number of bits that can be decoded to
 *
 * Inputs:
 *  - in        The number of the bit that should be one
 *  - en        whether or not any bit should be one.
 *
 * Outputs:
 *  - out       the decoded output ((in**2)*en)
 **/

module decoder
   #(parameter WIDTH = 8)
   (output logic [WIDTH-1:0] out,
    input logic en,
    input logic  [$clog2(WIDTH)-1:0] in);
    always_comb begin
    if(en == 1'b0)
       out = 'b0;
    else
      out = 2**in;
    end
endmodule: decoder

/**
 * Adds two numbers of WIDTH bits, with a carry in bit, producing a sum and a
 * carry out bit.
 *
 * Parameters:
 *  - WIDTH     The number of bits of the numbers being summed together.
 *
 * Inputs:
 *  - cin       The carry in to the addition.
 *  - A         The first number to add.
 *  - B         The second number to add.
 *
 * Outputs:
 *  - cout      The carry out from the addition.
 *  - sum       The result of the addition.
 **/
module adder
    #(parameter WIDTH=0)
    (input  logic               cin,
     input  logic [WIDTH-1:0]   A, B,
     output logic               cout,
     output logic [WIDTH-1:0]   sum);

     assign {cout, sum} = A + B + cin;

endmodule: adder

/*--------------------------------------------------------------------------------------------------------------------
 * Synchronous Components
 *--------------------------------------------------------------------------------------------------------------------*/

/**
 * Latches and stores values of WIDTH bits and initializes to RESET_VAL.
 *
 * This register uses an asynchronous active-low reset and a synchronous
 * active-high clear. Upon clear or reset, the value of the register becomes
 * RESET_VAL.
 *
 * Parameters:
 *  - WIDTH         The number of bits that the register holds.
 *  - RESET_VAL     The value that the register holds after a reset.
 *
 * Inputs:
 *  - clk           The clock to use for the register.
 *  - rst_l         An active-low asynchronous reset.
 *  - clear         An active-high synchronous reset.
 *  - en            Indicates whether or not to load the register.
 *  - D             The input to the register.
 *
 * Outputs:
 *  - Q             The latched output from the register.
 **/
module register
   #(parameter                      WIDTH=0,
     parameter logic [WIDTH-1:0]    RESET_VAL='b0)
    (input  logic               clk, en, rst_l, clear,
     input  logic [WIDTH-1:0]   D,
     output logic [WIDTH-1:0]   Q);

     always_ff @(posedge clk, negedge rst_l) begin
         if (!rst_l)
             Q <= RESET_VAL;
         else if (clear)
             Q <= RESET_VAL;
         else if (en)
             Q <= D;
     end

endmodule:register



// FETCH/DECODE Pipeline Reg

module fetchDecodeRegister
    (input  logic               clk, en, rst_l, clear,
     input  logic [31:0]   pc_in, btb_next_pc_in,
     input  logic [1:0]  btb_hist_in,
     input  logic in_btb_in,
     output logic in_btb_out,
     output logic [1:0]  btb_hist_out,
     output logic [31:0]   pc_out, btb_next_pc_out);

     always_ff @(posedge clk, negedge rst_l) begin
         if (!rst_l) begin
             pc_out <= 32'b0;
             btb_hist_out <= 2'b00;
             in_btb_out <= 0;
             btb_next_pc_out <= 32'b0;
         end
         else if (clear) begin
             pc_out <= 32'b0;
             btb_hist_out <= 2'b00;
             in_btb_out <= 0;
             btb_next_pc_out <= 32'b0;
         end
         else if (en) begin
             pc_out <= pc_in;
             btb_hist_out <= btb_hist_in;
             in_btb_out <= in_btb_in;
             btb_next_pc_out <= btb_next_pc_in;
         end
     end

endmodule:fetchDecodeRegister
 

// DECODE/EXECUTE Pipeline Reg


module decodeExecuteRegister
    (input  logic               clk, en, rst_l, clear,
     input ctrl_signals_t sig_in,
     input logic [4:0] rs1_in, rs2_in, rd_in,
     input logic [31:0] rs1_data_in, rs2_data_in, se_immediate_in,
     input  logic [31:0]   pc_in, btb_next_pc_in,
     input  logic [1:0]  btb_hist_in,
     input  logic in_btb_in,
     output logic in_btb_out,
     output logic [1:0]  btb_hist_out,
     output logic [31:0]   pc_out, btb_next_pc_out,
     output ctrl_signals_t sig_out,
     output logic [4:0] rs1_out, rs2_out, rd_out,
     output logic [31:0] rs1_data_out, rs2_data_out, se_immediate_out);

     always_ff @(posedge clk, negedge rst_l) begin
         if (!rst_l) begin
            sig_out <= 0;
            rs1_out <= 0;
            rs2_out <= 0;
            rd_out <= 0;
            rs1_data_out <= 0;
            rs2_data_out <= 0;
            se_immediate_out <= 0;
            pc_out <= 0;
            btb_hist_out <= 2'b00; 
            in_btb_out <= 0;
            btb_next_pc_out <= 32'b0;
         end
         else if (clear) begin
            sig_out <= 0;
            rs1_out <= 0;
            rs2_out <= 0;
            rd_out <= 0;
            rs1_data_out <= 0;
            rs2_data_out <= 0;
            se_immediate_out <= 0;
            pc_out <= 0;
            btb_hist_out <= 2'b00;
            in_btb_out <= 0;
            btb_next_pc_out <= 32'b0;
         end
         else if (en) begin
            sig_out <= sig_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            se_immediate_out <= se_immediate_in;
            pc_out <= pc_in;
            btb_hist_out <= btb_hist_in;;
            in_btb_out <= in_btb_in;
            btb_next_pc_out <= btb_next_pc_in;
         end
     end

endmodule:decodeExecuteRegister

// EXECUTE/MEM Pipeline Reg


module executeMemRegister
    (input  logic  clk, en, rst_l, clear, syscall_halt_in, exception_halt_in,
     input ctrl_signals_t sig_in,
     input logic [4:0] rd_in,
     input logic [31:0] alu_val_in, rs2_data_in,
     input logic [31:0] se_immediate_in,
     input  logic [31:0]   pc_in,
     output logic [31:0]   pc_out,
     output logic [31:0]   se_immediate_out,
     output logic syscall_halt_out, exception_halt_out,
     output ctrl_signals_t sig_out,
     output logic [4:0] rd_out,
     output logic [31:0]  alu_val_out, rs2_data_out);

     always_ff @(posedge clk, negedge rst_l) begin
         if (!rst_l) begin
            sig_out <= 0;
            rd_out <= 0;
            alu_val_out <= 0;
            rs2_data_out <= 0;
            syscall_halt_out <= 0;
            exception_halt_out <= 0;
            pc_out <= 0;
            se_immediate_out <= 0;
         end
         else if (clear) begin
            sig_out <= 0;
            rd_out <= 0;
            alu_val_out <= 0;
            rs2_data_out <= 0;
            syscall_halt_out <= 0;
            exception_halt_out <= 0;
            pc_out <= 0;
            se_immediate_out <= 0;
         end         
         else if (en) begin
            sig_out <= sig_in;
            rd_out <= rd_in;
            alu_val_out <= alu_val_in;
            rs2_data_out <= rs2_data_in;
            syscall_halt_out <= syscall_halt_in;
            exception_halt_out <= exception_halt_in;
            pc_out <= pc_in;
            se_immediate_out <= se_immediate_in;
         end
     end

endmodule: executeMemRegister

// MEM/WB Pipeline Reg


module memWBRegister
    (input  logic clk, en, rst_l, clear, exception_halt_in, syscall_halt_in,
     input ctrl_signals_t sig_in,
     input logic [4:0] rd_in,
     input logic [31:0] data_val_in, alu_val_in,
     input logic [31:0] se_immediate_in,
     input  logic [31:0]   pc_in,
     output logic [31:0]   pc_out,
     output logic [31:0]   se_immediate_out,
     output logic exception_halt_out, syscall_halt_out,
     output ctrl_signals_t sig_out,
     output logic [4:0] rd_out,
     output logic [31:0] data_val_out, alu_val_out);

     always_ff @(posedge clk, negedge rst_l) begin
         if (!rst_l) begin
            sig_out <= 0;
            rd_out <= 0;
            data_val_out <= 0;
            alu_val_out <= 0;
            syscall_halt_out <= 0;
            exception_halt_out <= 0;
            se_immediate_out <= 0;
            pc_out <= 0;
         end
        else if (clear) begin
            sig_out <= 0;
            rd_out <= 0;
            data_val_out <= 0;
            alu_val_out <= 0;
            syscall_halt_out <= 0;
            exception_halt_out <= 0;
            se_immediate_out <= 0;
            pc_out <= 0;
        end
         else if (en) begin
            sig_out <= sig_in;
            rd_out <= rd_in;
            data_val_out <= data_val_in;
            alu_val_out <= alu_val_in;
            syscall_halt_out <= syscall_halt_in;
            exception_halt_out <= exception_halt_in;
            pc_out <= pc_in;
            se_immediate_out <= se_immediate_in;
         end
     end
endmodule: memWBRegister


/*
 * Counter Logic
 */
module counter
    (input  logic clk, rst_l, en, 
     output logic [31:0] count );

    always_ff @(posedge clk, negedge rst_l) begin
        if(~rst_l) begin
            count <= 0;
        end
        else if (en) begin
            count <= count + 1;
        end
    end
endmodule: counter

module countFSM
    (input logic clk, rst_l, stall,
    output logic en_instr_0, en_instr_1, en_instr_2, en_instr_3);

    enum logic[1:0] {ZERO, ONE, TWO, THREE} state, nextState;


    always_ff @(posedge clk, negedge rst_l) begin
        if(~rst_l) begin
            state <= ZERO;
        end
        else begin
            state <= nextState;
        end
    end

    always_comb begin
        en_instr_0 = 0;
        en_instr_1 = 0;
        en_instr_2 = 0;
        en_instr_3 = 0;
        unique case (state)
            ZERO: begin
                  if(stall) begin
                    nextState = ONE;
                  end 
                  else begin
                    nextState = ZERO;
                    en_instr_0 = 1;
                  end
            end
            
            ONE: begin
                  if(stall) begin
                    nextState = TWO;
                  end 
                  else begin
                    nextState = ZERO;
                    en_instr_1 = 1;
                  end
            end
            
            TWO: begin
                  if(stall) begin
                    nextState = THREE;
                  end 
                  else begin
                    nextState = ZERO;
                    en_instr_2 = 1;
                  end
            end

            THREE: begin
                  nextState = ZERO;
                  en_instr_3 = 1;
            end
        endcase
    end

endmodule: countFSM



//Immediate Logic
//Takes in instruction and returns all possible sign extended immediate formats

module immediate_logic
  #(parameter  DATA_SIZE = 32,
   parameter  INSTRUCTION_SIZE = 32)
   (input logic [INSTRUCTION_SIZE-1:0] instr,
    output logic [DATA_SIZE-1:0] i_immediate, s_immediate, sb_immediate,
    output logic [DATA_SIZE-1:0] u_immediate, uj_immediate);
    assign i_immediate = {{21{instr[31]}}, instr[30:20]};
    assign s_immediate = {{21{instr[31]}}, instr[30:25], instr[11:7]};
    assign sb_immediate = 
    {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; 
    assign u_immediate = {instr[31:12], 12'b0};
    assign uj_immediate = 
    {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
endmodule:immediate_logic

//Load Logic
//Takes in control signals and data from data memory and outputs
//all possible bytes and half words.
module load_logic
    #(parameter DATA_SIZE = 32)
    (output logic [DATA_SIZE-1:0] data_load_b0, data_load_b1, 
    output logic [DATA_SIZE-1:0] data_load_b2, data_load_b3, data_load_h1,
    output logic [DATA_SIZE-1:0] data_load_h0, data_load_w,
    input logic [DATA_SIZE-1:0] data_load,
    input ctrl_signals_t ctrl_signals);
    always_comb begin
        data_load_w = data_load;
        if(ctrl_signals.signed_load) begin
            data_load_b0 = {{25{data_load[7]}}, data_load[6:0]};
            data_load_b1 = {{25{data_load[15]}}, data_load[14:8]};
            data_load_b2 = {{25{data_load[23]}}, data_load[22:16]};
            data_load_b3 = {{25{data_load[31]}}, data_load[30:24]};
            data_load_h0 = {{17{data_load[15]}}, data_load[14:0]};
            data_load_h1 = {{17{data_load[31]}}, data_load[30:16]};
        end
        else begin
            data_load_b0 = {24'b0, data_load[7:0]};
            data_load_b1 = {24'b0, data_load[15:8]};
            data_load_b2 = {24'b0, data_load[23:16]};
            data_load_b3 = {24'b0, data_load[31:24]};
            data_load_h0 = {16'b0, data_load[15:0]};
            data_load_h1 = {16'b0, data_load[31:16]};
        end
    end
endmodule: load_logic

//store logic
//Takes in control signals, rs2 data and alu out and returns
//store mask and data to be stored

module store_logic
    #(parameter DATA_SIZE = 32) 
    (input ctrl_signals_t ctrl_signals,
    input  logic [DATA_SIZE-1:0] rs2_data, alu_out,
    output logic [3:0] data_store_mask,
    output logic [DATA_SIZE-1:0] data_store);
    always_comb begin
        data_store = (rs2_data);
        if(ctrl_signals.str_mask==MASK_W) begin
            data_store_mask = 4'b1111;
        end
        else if(ctrl_signals.str_mask==MASK_H) begin
            data_store = (rs2_data << (alu_out[1] * 16));
            data_store_mask = (4'b0011 << (alu_out[1] * 2));
        end
        else if(ctrl_signals.str_mask==MASK_B) begin
            data_store = (rs2_data << (alu_out[1:0] * 8)); 
            data_store_mask = (4'b0001 << (alu_out[1:0]));
        end
        else begin
            data_store_mask = 4'b0;
        end
    end
endmodule: store_logic


//stall logic
//calculates whether or not to stall in decode stage based on
//RAW conflicts in later stages.

module stall_logic
    (input  logic [4:0] rs1D, rs2D, rdEx,  
     input  imm_t immD, input logic data_load_enE,
     input  rd_we_t rd_weEx, 
     output logic stall);
     
    logic need_rs1, need_rs2;
    logic stallrs1Ex,
          stallrs2Ex;
    always_comb begin
        need_rs1 = ((rs1D != 5'b00000) && (immD != UJ_IMM) && (immD != U_IMM));
        need_rs2 = ((rs2D != 5'b00000) && (immD != UJ_IMM) && (immD != U_IMM) &&
                                                               (immD != I_IMM));
        stallrs1Ex = ((rs1D == rdEx) && need_rs1 && rd_weEx);
        stallrs2Ex = ((rs2D == rdEx) && need_rs2 && rd_weEx);
        stall = (stallrs1Ex  || stallrs2Ex) && data_load_enE;
    end
    
endmodule: stall_logic


//forward == 00 -> forward from WB
//forward == 01 -> forward from Mem
//forward == 10 -> no forward
//forward == 11 ->xxxxxxxxxxxxx
module forward_logic
    (input  logic [4:0] rs1E, rs2E, rdMem, rdWb,
     input  rd_we_t rd_weMem, rd_weWb,
     input  imm_t immE,
     output logic [1:0] rs1_forward, rs2_forward);
     
    logic need_rs1, need_rs2;
    logic fwrs1Ex, fwrs1Mem, fwrs1Wb,
          fwrs2Ex, fwrs2Mem, fwrs2Wb; 
    always_comb begin
        need_rs1 = ((rs1E != 5'b00000) && (immE != UJ_IMM) && (immE != U_IMM));
        need_rs2 = ((rs2E != 5'b00000) && (immE != UJ_IMM) && (immE != U_IMM) &&
                                                               (immE != I_IMM));

        fwrs1Mem=  ((rs1E == rdMem) && need_rs1 && rd_weMem);
        fwrs1Wb = ((rs1E == rdWb) && need_rs1 && rd_weWb);
        fwrs2Mem=  ((rs2E == rdMem) && need_rs2 && rd_weMem);
        fwrs2Wb =((rs2E == rdWb) && need_rs2 && rd_weWb);

        if(fwrs1Mem) 
            rs1_forward = 2'b01;
        else if (fwrs1Wb)
            rs1_forward = 2'b00;
        else
            rs1_forward = 2'b10;

        
        if(fwrs2Mem) 
            rs2_forward = 2'b01;
        else if (fwrs2Wb)
            rs2_forward = 2'b00;
        else
            rs2_forward = 2'b10;

        
    end
    
endmodule: forward_logic

//Takes in input from btb and outputs the proper next value for pc
//If tag doesn't match or history is < 2, then push pc+4, otherwise push
//next pc.
module btb_eval
    (input  btb_t btb_out, 
     input  logic [31:0] pc,  
     output logic [31:0] next_pc,
     output logic [1:0] hist,
     output logic in_btb);

    logic [31:0] pc_4;
    logic btb_found;
    always_comb begin
        btb_found = (pc == {btb_out.tag_pc,2'b0});
        in_btb = btb_found;
        pc_4 = pc + 4;
        if (btb_found) begin
            hist = btb_out.hist;

            if ((btb_out.hist == 2'b00) || (btb_out.hist== 2'b01))
                next_pc = pc_4;
                
            else //btb.hist == 2'b10 || btb.hist == 2'b11
                next_pc = {btb_out.next_pc,2'b0};

        end
        else begin
            next_pc = pc_4;
            hist = 2'b00;
        end
    end
endmodule: btb_eval    


//Takes history and current pc in execute stage and computes
//new btb value to write into btb
//Handles flushes on mispredicts

module btb_update
    (input  logic bcond,
     input  logic [1:0] hist, pc_ctrl_sig,
     input  logic [31:0] pc, imm, alu_out,
     input logic [31:0] btb_next_pc,
     output logic [1:0] next_pc_mux,
     output logic update, flush,
     output btb_t btb_update);

    logic [1:0] new_hist;
    logic [31:0] pc_target;
    logic btb_equal;
    always_comb begin
        if (pc_ctrl_sig == ALU_OUT_PC)
            pc_target = alu_out;
        else 
            pc_target = pc + imm;


        //makes sure btb is only updated on ctrl_flow instrs
        update = (pc_ctrl_sig != PC_4_PC);
        flush = 0;


       /* if (bcond) 
            new_hist = (hist < 2'b11) ? hist + 1 : 2'b11;
        else
            new_hist = (hist == 2'b00) ? 2'b00 : hist - 2'b01;*/
        
        new_hist = 2'b00;

        btb_equal = btb_next_pc != pc_target;
        
        
        if ((hist == 2'b00) || (hist == 2'b01)) begin
            if (bcond) begin
                next_pc_mux = 2'b00; // mispredict | actually branch
                flush = 1;
            end
            else begin // correct
                next_pc_mux = 2'b10; 
            end
        end
        else begin //hist == 2'b10 || hist == 2'b11
            if (bcond) begin
                if (btb_equal) begin
                    next_pc_mux = 2'b00; // take actual
                    flush = 1;
                end
                else
                    next_pc_mux = 2'b10; // correct
            end
            else begin
                next_pc_mux = 2'b01; // mispredict | actually pc+4
                flush = 1;
            end
        end
        

        btb_update.tag_pc = pc[31:2];
        btb_update.hist =  new_hist;
        btb_update.next_pc = pc_target[31:2];
    end
    
endmodule: btb_update

