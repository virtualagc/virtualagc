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
  (input  logic rst_l, clock, wr1_en, wr2_en,
   input  logic [14:0] wr1_data, wr2_data,
   input  reg_t rs1_sel, rs2_sel, wr1_sel, wr2_sel,
   output logic [14:0] rs1_data, rs2_data,
   output logic [2:0] bits_EB, bits_FB);

  logic [14:0] reg_A, reg_L, 
               reg_Q, 
               reg_BB,
               reg_CYR, reg_SR, reg_CYL, reg_SL,
               reg_TIME1, reg_TIME2;

  always_ff @(posedge clock) begin
      $display("A = %o", reg_A);
      $display("L = %o", reg_L);
      $display("Q = %o", reg_Q);
      $display("BB = %o", reg_BB);
      $display("CYR = %o", reg_CYR);
      $display("SR = %o", reg_SR);
      $display("SL = %o", reg_SL);
      $display("TIME1 = %o", reg_TIME1);
      $display("TIME2 = %o", reg_TIME2);
  end

  always_ff @(posedge clock, negedge rst_l) begin
  // Register file writes
    if (~rst_l) begin
    // Reset Case
      reg_A <= 15'd0;
      reg_L <= 15'd0;
      reg_Q <= 15'd0;
      reg_BB[14:9] <= 6'd0;
      reg_CYR <= 15'd0;
      reg_SR <= 15'd0;
      reg_SL <= 15'd0;
      reg_TIME1 <= 15'd0;
      reg_TIME2 <= 15'd0;
    end
    else begin
    // Common Case
    // NOTE: If attempt a write of both data ports to same reg, port 2 has precedence.
      if (wr1_en) begin
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
      end
      if (wr2_en) begin
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

module IO_register_file
  (input  logic [14:0] data_write1, data_write2,
                       data_DSKY_VERB, 
                       data_DSKY_NOUN,
                       data_DSKY_NEW,
                       data_AXI_MISSION_TIME,
                       data_AXI_APOGEE,
                       data_AXI_PERIGEE,
   input  IO_reg_t sel_read1, sel_read2, 
                   sel_write1, sel_write2,
   input  logic en_write1, en_write2, 
                rst_l, clock,
   output logic [14:0] data_read1, data_read2);

  logic [14:0] data_DSKY_REG_1_HIGH,
               data_DSKY_REG_1_LOW,
               data_DSKY_REG_2_HIGH,
               data_DSKY_REG_2_LOW,
               data_DSKY_REG_3_HIGH,
               data_DSKY_REG_3_LOW,
               data_DSKY_PROG_NUM,
               data_DSKY_LAMPS,
               data_AXI_CALC_RES;

  logic write1_valid, write2_valid;

  always_ff @(posedge clock, negedge rst_l) begin
  // Output register writes
    if (~rst_l) begin
    // Reset Case
      data_DSKY_REG_1_HIGH <= 15'd0;
      data_DSKY_REG_1_LOW <= 15'd0;
      data_DSKY_REG_2_HIGH <= 15'd0;
      data_DSKY_REG_2_LOW <= 15'd0;
      data_DSKY_REG_3_HIGH <= 15'd0;
      data_DSKY_REG_3_LOW <= 15'd0;
      data_DSKY_PROG_NUM[4:0] <= 5'd0;
      // TODO: Isolate pertinent bits
      data_DSKY_LAMPS <= 15'd0;
      data_AXI_CALC_RES <= 15'd0;
    end
    else begin
    // Common Case
    // NOTE: If attempt a write of both data ports to same reg, port 2 has precedence.
      if (en_write1) begin
        unique case (sel_write1)
          DSKY_REG_1_HIGH: data_DSKY_REG_1_HIGH <= data_write1;
          DSKY_REG_1_LOW: data_DSKY_REG_1_LOW <= data_write1;
          DSKY_REG_2_HIGH: data_DSKY_REG_2_HIGH <= data_write1;
          DSKY_REG_2_LOW: data_DSKY_REG_2_LOW <= data_write1;
          DSKY_REG_3_HIGH: data_DSKY_REG_3_HIGH <= data_write1;
          DSKY_REG_3_LOW: data_DSKY_REG_3_LOW <= data_write1;
          DSKY_PROG_NUM: data_DSKY_PROG_NUM[4:0] <= data_write1[4:0];
          // TODO: Isolate pertinent bits
          DSKY_LAMPS: data_DSKY_LAMPS <= data_write1;
          AXI_CALC_RES: data_AXI_CALC_RES <= data_write1;
          default: begin
          // Necessary as not all I/O registers writeable
          end
        endcase
      end
      if (en_write2) begin
        unique case (sel_write2)
          DSKY_REG_1_HIGH: data_DSKY_REG_1_HIGH <= data_write2;
          DSKY_REG_1_LOW: data_DSKY_REG_1_LOW <= data_write2;
          DSKY_REG_2_HIGH: data_DSKY_REG_2_HIGH <= data_write2;
          DSKY_REG_2_LOW: data_DSKY_REG_2_LOW <= data_write2;
          DSKY_REG_3_HIGH: data_DSKY_REG_3_HIGH <= data_write2;
          DSKY_REG_3_LOW: data_DSKY_REG_3_LOW <= data_write2;
          DSKY_PROG_NUM: data_DSKY_PROG_NUM[4:0] <= data_write2[4:0];
          // TODO: Isolate pertinent bits
          DSKY_LAMPS: data_DSKY_LAMPS <= data_write2;
          AXI_CALC_RES: data_AXI_CALC_RES <= data_write2;
          default: begin
          // Necessary as not all I/O registers writeable
          end
        endcase
      end
    end
  end
  
  always_comb begin
  // I/O register reads
    // Check for valid writes
    write1_valid = (~sel_write1[3] | (sel_write1[2:0] == 3'd0));
    write2_valid = (~sel_write2[3] | (sel_write2[2:0] == 3'd0)); 
    // To Read Port 1
    if (write1_valid & (sel_read1 == sel_write1))
    // Forwarding Case 1
      data_read1 = data_write1;
    else if (write2_valid & (sel_read1 == sel_write2))
    // Forwarding Case 2
      data_read1 = data_write2;
    else begin
    // Common Case
      unique case (sel_read1)
        DSKY_REG_1_HIGH: data_read1 = data_DSKY_REG_1_HIGH;
        DSKY_REG_1_LOW: data_read1 = data_DSKY_REG_1_LOW;
        DSKY_REG_2_HIGH: data_read1 = data_DSKY_REG_2_HIGH;
        DSKY_REG_2_LOW: data_read1 = data_DSKY_REG_2_LOW;
        DSKY_REG_3_HIGH: data_read1 = data_DSKY_REG_3_HIGH;
        DSKY_REG_3_LOW: data_read1 = data_DSKY_REG_3_LOW;
        DSKY_PROG_NUM: data_read1[4:0] = data_DSKY_PROG_NUM[4:0];
        // TODO: Isolate pertinent bits
        DSKY_LAMPS: data_read1 = data_DSKY_LAMPS;
        AXI_CALC_RES: data_read1 = data_AXI_CALC_RES;
        DSKY_VERB: data_read1 = data_DSKY_VERB;
        DSKY_NOUN: data_read1 = data_DSKY_NOUN;
        DSKY_NEW: data_read1[0] = data_DSKY_NEW[0];
        AXI_MISSION_TIME: data_read1 = data_AXI_MISSION_TIME;
        AXI_APOGEE: data_read1 = data_AXI_APOGEE;
        AXI_PERIGEE: data_read1 = data_AXI_PERIGEE;
      endcase
    end
    // To Read Port 2
    if (write1_valid & (sel_read2 == sel_write1))
    // Forwarding Case 1
      data_read2 = data_write1;
    else if (write2_valid & (sel_read2 == sel_write2))
    // Forwarding Case 2
      data_read2 = data_write2;
    else begin
    // Common Case
      unique case (sel_read1)
        DSKY_REG_1_HIGH: data_read2 = data_DSKY_REG_1_HIGH;
        DSKY_REG_1_LOW: data_read2 = data_DSKY_REG_1_LOW;
        DSKY_REG_2_HIGH: data_read2 = data_DSKY_REG_2_HIGH;
        DSKY_REG_2_LOW: data_read2 = data_DSKY_REG_2_LOW;
        DSKY_REG_3_HIGH: data_read2 = data_DSKY_REG_3_HIGH;
        DSKY_REG_3_LOW: data_read2 = data_DSKY_REG_3_LOW;
        DSKY_PROG_NUM: data_read2[4:0] = data_DSKY_PROG_NUM[4:0];
        // TODO: Isolate pertinent bits
        DSKY_LAMPS: data_read2 = data_DSKY_LAMPS;
        AXI_CALC_RES: data_read2 = data_AXI_CALC_RES;
        DSKY_VERB: data_read2 = data_DSKY_VERB;
        DSKY_NOUN: data_read2 = data_DSKY_NOUN;
        DSKY_NEW: data_read2[0] = data_DSKY_NEW[0];
        AXI_MISSION_TIME: data_read2 = data_AXI_MISSION_TIME;
        AXI_APOGEE: data_read2 = data_AXI_APOGEE;
        AXI_PERIGEE: data_read2 = data_AXI_PERIGEE;
      endcase
    end
  end

endmodule: IO_register_file

module addr_translate_ROM
  (input  logic [11:0] addr_soft,
   input  logic [2:0] bits_FB,
   output logic [13:0] addr_ROM);

  logic [13:0] offset_bank, addr_bank;
  logic [11:0] addr_norm_to_ROM, addr_norm_to_bank;
  logic addr_is_fixed;

  always_comb begin
    // Check if addr_soft points to fixed ROM
    addr_is_fixed = $unsigned(addr_soft) >= $unsigned(12'o4000);

    // If addr_soft point to fixed ROM, this value is selected
    // 12'o4000 is lowest software fixed ROM address
    // Fixed region of ROM occupy until address 12'o4000 (non-inclusive)
    addr_norm_to_ROM = $unsigned(addr_soft) - $unsigned(12'o4000);

    // 12'o2000 is lowest software banked ROM address
    // Banked region of ROM occupy address 12'o4000 and higher
    addr_norm_to_bank = $unsigned(addr_soft) + $unsigned(12'o2000);

    // 12'o2000 is size of each bank
    // Lookup table used to eliminate need for multiplier
    unique case (bits_FB)
      3'b000: offset_bank = 14'o00000;
      3'b001: offset_bank = 14'o02000;
      3'b010: offset_bank = 14'o04000;
      3'b011: offset_bank = 14'o06000;
      3'b100: offset_bank = 14'o10000;
      3'b101: offset_bank = 14'o12000;
      3'b110: offset_bank = 14'o14000;
      3'b111: offset_bank = 14'o16000;
    endcase  

    // If addr_soft point to banked ROM, this value is selected
    addr_bank = $unsigned(addr_norm_to_bank) + $unsigned(offset_bank);

    // Select fixed or banked translation
    addr_ROM = (addr_is_fixed) ? {2'd0, addr_norm_to_ROM} : addr_bank;
  end

endmodule: addr_translate_ROM

module addr_translate_RAM
  (input  logic [11:0] addr_soft,
   input  logic [2:0] bits_EB,
   output logic [10:0] addr_RAM);

  logic [10:0] offset_bank_pre, offset_bank, addr_bank;
  logic addr_is_fixed;

  always_comb begin
    // Check if addr_soft points to fixed RAM
    addr_is_fixed = $unsigned(addr_soft) < $unsigned(12'o1400);

    // 12'o1400 is lowest software banked RAM address
    // 12'o0400 is size of banks
    // Lookup table used to eliminate need for multiplier
    unique case (bits_EB[1:0])
      2'b00: offset_bank_pre = 11'o0000;
      2'b01: offset_bank_pre = 11'o0400;
      2'b10: offset_bank_pre = 11'o1000;
      2'b11: offset_bank_pre = 11'o1400;
    endcase

    // Always add 11'o2000 if MSB of EB bits is '1'
    offset_bank = (bits_EB[2]) ? 11'o2000 : offset_bank_pre;

    // If addr_soft point to banked RAM, this value is selected
    addr_bank = $unsigned(addr_soft[10:0]) + $unsigned(offset_bank);

    // Select fixed or banked translation
    addr_RAM = (addr_is_fixed) ? addr_soft[10:0] : addr_bank;
  end

endmodule: addr_translate_RAM

module addr_translate_r
  (input  logic [11:0] addr_k,
   input  logic [2:0] bits_EB, bits_FB,
   output logic [13:0] addr_ROM,
   output logic [10:0] addr_RAM);

  logic [13:0] addr_ROM_pre;
  logic [10:0] addr_RAM_pre;
  logic point_to_ROM;

  addr_translate_RAM translate_read_RAM (.addr_soft(addr_k),
                                         .bits_EB(bits_EB),
                                         .addr_RAM(addr_RAM_pre));

  addr_translate_ROM translate_read_ROM (.addr_soft(addr_k),
                                         .bits_FB(bits_FB),
                                         .addr_ROM(addr_ROM_pre));

  always_comb begin
    // Check if addr_k points to ROM, otherwise points to RAM
    point_to_ROM = $unsigned(addr_k) >= $unsigned(12'o2000);

    // Drive lowest valid address to RAM/ROM address port 
    // if addr_k point to opposite region
    {addr_RAM, addr_ROM} = (point_to_ROM) ? {11'o0000, addr_ROM_pre}
                                          : {addr_RAM_pre, 14'o2000};
  end

endmodule: addr_translate_r

module addr_translate_w
  (input  logic [11:0] addr_k,
   input  logic [2:0] bits_EB,
   input  logic en_write,
   output logic [10:0] addr_RAM,
   output logic en_write_final);

  logic point_to_RAM;

  addr_translate_RAM translate_write_RAM (.addr_soft(addr_k),
                                          .bits_EB(bits_EB),
                                          .addr_RAM(addr_RAM));

  // If attempt to write to ROM, force write enable to '0'
  assign en_write_final = (point_to_RAM) ? en_write : 1'b0;

endmodule: addr_translate_w

// All address translation contained within a single module
module addr_translate
  (input  logic [11:0] addr_pc, addr_r, addr_w,
   input  logic [2:0] bits_EB_r, bits_FB_r, bits_EB_w,
   input  logic en_write,
   output logic [13:0] addr_ROM_pc, addr_ROM_r,
   output logic [10:0] addr_RAM_r, addr_RAM_w,
   output logic en_write_final);

   addr_translate_ROM translate_pc (.addr_soft(addr_pc),
                                    .bits_FB(bits_FB_r),
                                    .addr_ROM(addr_ROM_pc));

   addr_translate_r translate_r (.addr_k(addr_r),
                                 .bits_EB(bits_EB_r),
                                 .bits_FB(bits_FB_r),
                                 .addr_ROM(addr_ROM_r),
                                 .addr_RAM(addr_RAM_r));

   addr_translate_w translate_w (.addr_k(addr_w),
                                 .bits_EB(bits_EB_w),
                                 .en_write(en_write),
                                 .addr_RAM(addr_RAM_w),
                                 .en_write_final(en_write_final));

endmodule: addr_translate

// Processor ALU
// Over/Underflow detection not yet configured
module arithmetic_logic_unit
  (input  alu_op_t operation_sel,
   input  logic [29:0] source_1,
   input  logic [14:0] source_2,
   output logic [29:0] result,
   output logic res_eq_0);

  logic [14:0] res_add_sub, res_div_quot, res_div_remain,
               add_sub_src_1;
  logic [29:0] res_mult; 
  logic sel_subtract;

  always_comb begin
    
    // Result low order word default
    result[14:0] = 15'd0;

    unique case (operation_sel)
      ALU_AD: begin
        sel_subtract = 1'b0;
        add_sub_src_1 = source_1[29:15];
        result[29:15] = res_add_sub;
      end
      ALU_SU: begin
        sel_subtract = 1'b1;
        add_sub_src_1 = source_1[29:15];
        result[29:15] = res_add_sub;
      end
      ALU_AUG: begin
        sel_subtract = source_2[14];
        add_sub_src_1 = 15'd1;
        result[29:15] = res_add_sub;
      end
      ALU_COM: begin
        result[29:15] = ~source_2;
      end
      ALU_READ: begin
        result[29:15] = source_2;
      end
      ALU_BRANCH: begin
        result[29:15] = source_1[29:15];
      end
      ALU_MP: begin
        result = res_mult;
      end
      ALU_DIM: begin
        if (res_eq_0) begin
          result = source_2;
        end
        else begin
          sel_subtract = ~source_2[14];
          add_sub_src_1 = 15'd1;
          result[29:15] = res_add_sub;
        end
      end
      ALU_OR: begin
        result[29:15] = source_1[29:15] | source_2;
      end
      ALU_AND: begin
        result[29:15] = source_1[29:15] & source_2;
      end
      ALU_XOR: begin
        result[29:15] = source_1[29:15] ^ source_2;
      end
      ALU_INCR: begin
        sel_subtract = 1'b0;
        add_sub_src_1 = 15'd1;
        result[29:15] = res_add_sub;
      end
      ALU_DV: begin
        result = {res_div_quot, res_div_remain};
      end
      ALU_QXCH: begin
        result = {source_1[29:15], source_2};
      end
    endcase

    // Set the zero flag
    res_eq_0 = (source_2 == 15'd0 || source_2 == 15'h7FFF);

  end

  ones_comp_add_sub alu_add_sub (.sum(res_add_sub),
                                 .x(add_sub_src_1),
                                 .y(source_2),
                                 .subtract(sel_subtract));

  ones_comp_mult alu_mult (.prod(res_mult),
                           .underflow_flag(),
                           .x(source_1[29:15]),
                           .y(source_2));

  ones_comp_div alu_div (.quot(res_div_quot),
                         .remain(res_div_remain),
                         .underflow_flag(),
                         .numer(source_1),
                         .denom(source_2));

endmodule: arithmetic_logic_unit

module branching_logic 
  (input logic eq_0, sign_bit,
   input branch_t ctrl_branch,
   output logic branch);

  assign branch = (ctrl_branch==BRANCH) ? 1'b1 : (ctrl_branch==BZF && eq_0) ? 1'b1 : (ctrl_branch == BZF && (eq_0 || sign_bit)) ? 1'b1 : 1'b0;
      

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
    stall = 1'b0;
    if ((((ctrl_D.rs1_sel==ctrl_E.wr1_sel)  || (ctrl_D.rs2_sel==ctrl_E.wr1_sel)) && ctrl_E.wr1_en) || (((ctrl_D.rs1_sel==ctrl_E.wr2_sel) || (ctrl_D.rs2_sel==ctrl_E.wr2_sel)) && ctrl_E.wr2_en)) begin
        stall = 1'b1;
    end
    else if ((ctrl_D.K==ctrl_E.K && (ctrl_E.RAM_write_en || ctrl_E.IO_write_en)) || (ctrl_D.K==ctrl_W.K && (ctrl_W.RAM_write_en || ctrl_W.IO_write_en)))
        stall = 1'b1;
    end


endmodule: stall_logic
