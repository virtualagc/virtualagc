`default_nettype none

`include "internal_defines.vh"
module Core
  (input logic clock, reset_n,
   input logic [14:0] ROM_read_data, RAM_read_data, IO_read_data,
   output logic [14:0] RAM_write_data, IO_write_data,
   output logic [14:0] ROM_address, RAM_read_address, RAM_write_address,
   output logic [2:0] IO_read_sel, IO_write_sel,
   output logic RAM_write_en, stall);

  /////////////////////////FETCH STAGE///////////////////////////////
  logic stall_D;
  logic [14:0] pc_F, pc_1_F, next_pc_F;


  adder #($bits(pc_F)) Next_PC_Adder(.A(pc_E), .B('d1), .cin(1'b0),
            .sum(pc_1_F), .cout());


  register #($bits(pc_F), USER_TEXT_START) PC_Register(.clk, .rst_l,
            .en(~stall_D), .clear(1'b0), .D(next_pc_F),
            .Q(pc_F));

  mux #(2, $bits(pc_F)) PC_Mux(.in({pc_E, pc_1_F}),
            .sel(branch_E),
            .out(next_pc_F));

  assign ROM_read_address = pc_F;

  /////////////////////////DECODE STAGE////////////////////////////

  logic [14:0] instr_D, rs1_data_D, rs2_data_D, IO_read_data_D;
  ctrl_t ctrl_D, ctrl_E, ctrl_F;
  logic [11:0] k_D;

  assign IO_read_data_D = IO_read_data;
  assign instr_D = ROM_read_data;

  decoder Decoder(.rst_l, .instr(instr_D), .ctrl_signals(ctrl_D), .clock, .k(k_D));

  //TODO donny make address thing  
 

  

  register_file reg(.rst_l, .clock, .rs1_sel(ctrl_D.rs1_sel), .rs2_sel(ctrl_D.rs2_sel),
                    .wr1_data(ctrl_W.wr1_data), .wr2_data(ctrl_W.wr2_data),
                    .wr1_sel(ctrl_W.wr1_sel), .wr2_sel(ctrl_W.wr2_sel),
                    .wr1_en(ctrl_W.wr1_en), .wr2_en(ctrl_W.wr2_en),
                    .rs1_data_D, .rs2_data_D);

  //decode execute register
  logic [14:0] rs1_data_E, rs2_data_E, IO_read_data_E, k_E;

   always_ff @(posedge clock, negedge rst_l) begin
         if (!rst_l) begin 
            ctrl_E <= 'd0;
            rs1_data_E <= 'd0;
            rs2_data_E <= 'd0;
            k_E <= 'd0;
            IO_read_data_E <= 'd0; 
         end
         else if (clear_D) begin 
            ctrl_E <= 'd0;
            rs1_data_E <= 'd0;
            rs2_data_E <= 'd0;
            k_E <= 'd0;
            IO_read_data_E <= 'd0;  
         end
         else if (en) begin
            ctrl_E <= ctrl_D;
            rs1_data_E <= rs1_data_D;
            rs2_data_E <= rs2_data_D;
            k_E <= k_D;
            IO_read_data_E <= IO_read_data_D; 
         end 
    end

  /////////////////////////EXECUTE STAGE//////////////////////////
  









 
  


endmodule : Core
