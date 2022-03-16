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

//TODO donny fill out register file
module register_file 
  (input logic rst_l, clock, wr1_en, wr2_en,
   input logic [14:0] wr1_data, wr2_data,
   input reg_t rs1_sel, rs2_sel, wr1_sel, wr2_sel,
   output logic [14:0] rs1_data, rs2_data,
   output logic [2:0] bits_EB, bits_FB);

  logic [14:0] reg_A, reg_L, 
               reg_Q, 
               reg_BB,
               reg_CYR, reg_SR, reg_CYL, reg_SL,
               reg_TIME1, reg_TIME2;

  always_ff @(posedge clock, negedge rst_l) begin
  // Register file writes
    if (~rst_1) begin
    // Reset Case
      reg_A <= 15'd0;
      reg_L <= 15'd0;
      reg_Q <= 15'd0;
      reg_BB[14:9] <= 6'd0;
      reg_CYR <= 15'd0;
      reg_SR <= 15'd0;
      reg_SL <= 15'd0;
      reg_TIME1 <= 15'd0;
      reg_TIME2 <= 15'd0
    end
    else if (~(wr1_en | wr2_en)) begin
    // No Write Case
      reg_A <= reg_A;
      reg_L <= reg_L;
      reg_Q <= reg_Q;
      reg_BB[14:9] <= reg_BB[14:9];
      reg_CYR <= reg_CYR;
      reg_SR <= reg_SR;
      reg_SL <= reg_SL;
      reg_TIME1 <= reg_TIME1;
      reg_TIME2 <= reg_TIME2;
    end
    else begin
    // Write Case
    // NOTE: If attempt a write of both data ports to same reg, port 2 has precedence.
      unique case (wr1_sel)
      // From Write Port 1
        // Accumulators
        A: reg_A <= wr1_data;
        L: reg_L <= wr1_data;

        // Link register
        Q: reg_Q <= wr1_data;

        // Bank registers
        EB: reg_BB[11:9] <= wr1_data[11:9];
        FB: reg_BB[14:12] <= wr1_data[14:12];
        BB: reg_BB[14:9] <= wr1_data[14:9];
        
        // Editing registers
        CYR: reg_CYR <= {wr1_data[0], wr1_data[14:1]};
        SR: reg_SR <= {wr1_data[14], wr1_data[14:1]};
        CYL: reg_CYL <= {wr1_data[13:0], wr1_data[14]};
        SL: reg_SL <= {wr1_data[13:0], 1'b0};

        // Timers
        TIME1: reg_TIME1 <= wr1_data;
        TIME2: reg_TIME2 <= wr1_data;
      endcase

      unique case (wr2_sel)
      // From Write Port 2
        // Accumulators
        A: reg_A <= wr2_data;
        L: reg_L <= wr2_data;

        // Link register
        Q: reg_Q <= wr2_data;

        // Bank registers (only write to pertinent bits)
        EB: reg_BB[11:9] <= wr2_data[11:9];
        FB: reg_BB[14:12] <= wr2_data[14:12];
        BB: reg_BB[14:9] <= wr2_data[14:9];
        
        // Editing registers (shifted value is written)
        CYR: reg_CYR <= {wr2_data[0], wr2_data[14:1]};
        SR: reg_SR <= {wr2_data[14], wr2_data[14:1]};
        CYL: reg_CYL <= {wr2_data[13:0], wr2_data[14]};
        SL: reg_SL <= {wr2_data[13:0], 1'b0};

        // Timers
        TIME1: reg_TIME1 <= wr2_data;
        TIME2: reg_TIME2 <= wr2_data;
      endcase 
    end
  end
  
  always_comb begin
  // Register file reads
    // To Read Port 1
    if (rs1_sel == wr1_sel)
    // Forwarding Case 1
      rs1_data = wr1_data;
    else if (rs1_sel == wr2_sel)
    // Forwarding Case 2
      rs1_data = wr2_data;
    else begin
    // Common Case
      unique case (rs1_sel)
        // Accumulators
        A: rs1_data = reg_A;
        L: rs1_data = reg_L;

        // Link register
        Q: rs1_data = reg_Q;

        // Bank registers
        EB: rs1_data = {3'd0, reg_BB[11:9], 9'd0};
        FB: rs1_data = {reg_BB[14:12], 13'd0};
        BB: rs1_data = {reg_BB[14:9], 9'd0};

        // Zero
        ZERO: rs1_data = 15'd0;

        // Editing registers
        CYR: rs1_data = reg_CYR;
        SR: rs1_data = reg_SR;
        CYL: rs1_data = reg_CYL;
        SL: rs1_data = reg_SL;
        
        // Timers
        TIME1: rs1_data = reg_TIME1;
        TIME2: rs1_data = reg_TIME2;
      endcase
    end

    // To Read Port 2
    if (rs2_sel == wr1_sel)
    // Forwarding Case 1
      rs1_data = wr1_data;
    else if (rs2_sel == wr2_sel)
    // Forwarding Case 2
      rs2_data = wr2_data;
    else begin
    // Common Case
      unique case (rs2_sel)
        // Accumulators
        A: rs2_data = reg_A;
        L: rs2_data = reg_L;

        // Link register
        Q: rs2_data = reg_Q;

        // Bank registers
        EB: rs2_data = {3'd0, reg_BB[11:9], 9'd0};
        FB: rs2_data = {reg_BB[14:12], 13'd0};
        BB: rs2_data = {reg_BB[14:9], 9'd0};

        // Zero
        ZERO: rs2_data = 15'd0;

        // Editing registers
        CYR: rs2_data = reg_CYR;
        SR: rs2_data = reg_SR;
        CYL: rs2_data = reg_CYL;
        SL: rs2_data = reg_SL;
        
        // Timers
        TIME1: rs2_data = reg_TIME1;
        TIME2: rs2_data = reg_TIME2;
      endcase
    end

    // Bank bit output taps for address translation module
    bits_EB = reg_BB[11:9];
    bits_FB = reg_BB[14:12];
  end 
   
endmodule: register_file

module branching_logic 
  (input logic eq_0, sign_bit,
   input branch_t, ctrl_branch,
   output logic branch);

  assign branch = (branch==BRANCH) ? 1'b1 : (branch==BZF && eq_0) ? 1'b1 : (branch == BZF && (eq_0 || sign_bit) ? 1'b1 : 1'b0;
      

endmodule: branching_logic
    
module stall_logic
  (input ctrl_t ctrl_D, ctrl_E, ctrl_W,
   input logic branch_E,
   output logic stall, flush);


  always_comb begin
    flush = 1'b0;
    
    if(branch_E) begin
       flush = 1'b1;
    end
  end


  always_comb begin
    stall = 1'b0
    if ((ctrl_D.rs1_sel==ctrl_E.wr1 && ctrl_E.wr1_en) ||(ctrl_D.rs2_sel==ctrl_E.wr2 && ctrl_E.wr2_en)) begin
        stall = 1'b1;
    end
    else if ((ctrl_D.K==ctrl_E.K && (ctrl_E.RAM_write_en || ctrl_E.IO_write_en)) || (ctrl_D.K==ctrl_W.K && (ctrl_W.RAM_write_en || ctrl_W.IO_write_en)))
        stall = 1'b1;
    end
  end

endmodule: stall_logic
