`default_nettype none

`include "internal_defines.vh"
module Core
  (input logic clock, reset_n,
   input logic [14:0] ROM_read_data, RAM_read_data, IO_read_data,
   output logic [14:0] RAM_write_data, IO_write_data,
   output logic [14:0] ROM_address, RAM_read_address, RAM_write_address,
   output logic [2:0] IO_read_sel, IO_write_sel,
   output logic RAM_write_en, stall, halt);

  /////////////////////////FETCH STAGE///////////////////////////////
  logic stall_D, flush_E, flush_W, flush_DE;
  logic [14:0] pc_F, pc_1_F, next_pc_F;

  assign flush_DE = flush_E | flush_W | stall_D;

  adder #($bits(pc_F)) Next_PC_Adder(.A(pc_E), .B('d1), .cin(1'b0),
            .sum(pc_1_F), .cout());


  register #($bits(pc_F), 'o4000) PC_Register(.clk, .rst_l,
            .en(~stall_D), .clear(1'b0), .D(next_pc_F),
            .Q(pc_F));

  mux #(2, $bits(pc_F)) PC_Mux(.in({pc_E, pc_1_F}),
            .sel(branch_E),
            .out(next_pc_F));

  assign ROM_read_address = pc_F;

  //fetch decode register
   always_ff @(posedge clock, negedge rst_l) begin
         if (!rst_l) begin
            pc_D <= 'o4000;
         end
         else if (flush_E) begin
            pc_D <= 'o4000;
         end
         else if (~stall_D) begin
            pc_D <= pc_F;
         end
    end

  

  /////////////////////////DECODE STAGE////////////////////////////

  logic [14:0] instr_D, rs1_data_D, rs2_data_D, IO_read_data_D, read_data_E, index_data;
  ctrl_t ctrl_D, ctrl_E, ctrl_F;
  logic [11:0] k_D;

  assign IO_read_data_D = IO_read_data;
  assign IO_read_sel = ctrl_D.IO_read_sel;
  assign instr_D = ROM_read_data;


  decoder Decoder(.rst_l, .instr(instr_D), .ctrl_signals(ctrl_D), .clock, .index_data, .pc(pc_D), .flush(flush_DE));

  mux #(2, $bits(index_data)) Index_mux(.in({read_data_E,ctrl_E.K}),
            .sel(ctrl_E.index),
            .out(data_W));

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
            IO_read_data_E <= 'd0; 
         end
         else if (flush_DE) begin 
            ctrl_E <= 'd0;
            rs1_data_E <= 'd0;
            rs2_data_E <= 'd0;
            IO_read_data_E <= 'd0;  
         end
         else if (1'b1) begin
            ctrl_E <= ctrl_D;
            rs1_data_E <= rs1_data_D;
            rs2_data_E <= rs2_data_D;
            IO_read_data_E <= IO_read_data_D; 
         end 
    end

 /////////////////////////EXECUTE STAGE//////////////////////////
  logic [29:0] alu_src1_E, rs1rs2_data_E, alu_out_E;
  logic [14:0] alu_src2_E;
  
  assign rs1rs2_data_E = {rs1_data_E,rs2_data_E};
  
  assign read_data_E = RAM_read_data;

  mux #(3, $bits(rs1rs2_data_E)) ALU1_Mux(.in({rs1rs2_data_E, 15'd0, rs1_data_E, 18'd0, ctrl_E.k}),
      .sel(ctrl_E.alu_src1), .out(alu_src1_E));

  //TODO should it be K or address?
  mux #(4, $bits(alu_src2)) ALU_2_Mux(.in({read_data_E, rs2_data_E, IO_read_data_E, ctrl_E.k}),
            .sel(ctrl_E.alu_src2),
            .out(alu_src2_E));

  
  alu ALU(.src1(alu_src1_E), .src2(alu_src2_E), .out(alu_out_E), sign_bit(sign_bit_E), eq_0(eq_0_E),
          .op(ctrl_E.alu_op));


  //TODO make this logic
  branching_logic Branch(.eq_0(eq_0_E, .sign_bit(sign_bit_E), .ctrl_branch(ctrl.branch_E),
                         .branch(branch_E));
  
  //Execute Writeback Register
  logic [14:0] old_pc_W

   always_ff @(posedge clock, negedge rst_l) begin
         if (!rst_l) begin 
            ctrl_W <= 'd0;
            old_pc_W <= 'd0;
            alu_out_W <= 'd0;
            flush_W <= 'd0;
         end
         else if (1'b0) begin
            ctrl_W <= 'd0;
            old_pc_W <= 'd0;
            alu_out_W <= 'd0;
            flush_W <= 'd0; 
         end
         else if (1'b1) begin
            ctrl_W <= ctrl_E;
            old_pc_W <= pc_;
            alu_out_W <= 'd0;
            flush_W <= flush_E;
         end 
    end

  ///////////////////////////WRITEBACK STAGE////////////////////////////

  logic [29:0] data_W;

  mux #(2, $bits(data_W)) PC_Mux(.in({15'd0,ctrl_W.pc,alu_out_W}),
            .sel(ctrl_W.rd),
            .out(data_W));

  //higher bits wr1 lower bits wr2
  assign wr1_data_W = data_W[29:15];
  assign wr2_data_W = data_W[14:0];

  //data address upper bits data lower bits
  assign RAM_write_address = data_W[29:15];
  assign RAM_write_data = data_W[14:0];
  assign RAM_write_en = ctrl_en.RAM_write_en;

  //data channel upper bits data w
  assign IO_write_sel = data_W[17:15];
  assign IO_write_data = data_W[14:0];
  assign IO_write_en = ctrl_W.IO_write_en;
  assign halt = ctrl_W.halt;

  //STALL UNIT

  stall_logic stall(.ctrl_D, .ctrl_E, .ctrl_W, .stall, .branch_E, .flush_E);

endmodule : Core
