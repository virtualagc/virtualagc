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
  (input logic rst_l, clock, wr1_en, we2_en,
   input logic [14:0] wr1_data, wr2_data,
   input reg_t rs1_sel, rs2_sel, wr1_sel, wr2_sel,
   output logic [14:0] rs1_data_D, rs2_data_D);
   
endmodule: register_file
