`default_nettype none


module Core
  (input logic clock, reset_n,
   input logic [14:0] ROM_pc_data, ROM_constant_data, RAM_read_data, IO_read_data,
   output logic [14:0] RAM_write_data, IO_write_data,
   output logic [13:0] ROM_pc_address, ROM_constant_address,
   output logic [10:0] RAM_read_address, RAM_write_address,
   output logic [2:0] IO_read_sel, IO_write_sel,
   output logic RAM_write_en, stall, halt, IO_write_en);

  /////////////////////////FETCH STAGE///////////////////////////////
  logic stall_D, flush_E, flush_W, flush_DE, branch_E, rst_l, clk;
  logic [11:0] pc_F, pc_1_F, next_pc_F, pc_E, pc_D;
  logic [29:0] alu_out_E;

  assign flush_DE = flush_E | flush_W | stall_D;
  assign rst_l = reset_n;
  assign clk = clock;

  adder #($bits(pc_F)) Next_PC_Adder(.A(pc_F), .B(12'd1), .cin(1'b0),
            .sum(pc_1_F), .cout());


  register #($bits(pc_F), 'o4000) PC_Register(.clk, .rst_l,
            .en(~stall_D), .clear(1'b0), .D(next_pc_F),
            .Q(pc_F));

  mux #(2, $bits(pc_F)) PC_Mux(.in({alu_out_E[26:15], pc_1_F}),
            .sel(branch_E),
            .out(next_pc_F));

  

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

  logic [14:0] instr_D, rs1_data_D, rs2_data_D, IO_read_data_D, read_data_E, index_data, wr1_data_W, wr2_data_W;
  ctrl_t ctrl_D, ctrl_E, ctrl_F, ctrl_W;
  logic [11:0] k_D;
  logic [2:0] bits_FB, bits_EB;

  assign IO_read_data_D = IO_read_data;
  assign IO_read_sel = ctrl_D.IO_read_sel;
  assign instr_D = ROM_pc_data;


  decode Decoder(.rst_l, .instr(instr_D), .ctrl_D, .clock, .index_data, .pc(pc_D), .flush(flush_DE), .bits_FB, .bits_EB);

  mux #(2, $bits(index_data)) Index_mux(.in({read_data_E, 3'd0, ctrl_E.K}),
            .sel(ctrl_E.index),
            .out(index_data));

  register_file rf(.rst_l, .clock, .rs1_sel(ctrl_D.rs1_sel), .rs2_sel(ctrl_D.rs2_sel),
                    .wr1_data(wr1_data_W), .wr2_data(wr2_data_W),
                    .wr1_sel(ctrl_W.wr1_sel), .wr2_sel(ctrl_W.wr2_sel),
                    .wr1_en(ctrl_W.wr1_en), .wr2_en(ctrl_W.wr2_en),
                    .rs1_data(rs1_data_D), .rs2_data(rs2_data_D), .bits_FB, .bits_EB);

  //decode execute register
  logic [14:0] rs1_data_E, rs2_data_E, IO_read_data_E, k_E;

    always_ff @(posedge clock, negedge rst_l) begin
         if (!rst_l) begin  
            ctrl_E <= '{
            alu_op: ALU_AD,
            data_read_en: 1'b1,
            wr1_sel: A,
            wr2_sel: A,
            wr1_en: 1'b0,
            wr2_en: 1'b0,
            rs1_sel: A,
            rs2_sel: A,
            alu_src1: RS1_DATA1,
            alu_src2: READ_DATA2,
            branch: NO_BRANCH,
            rd: ALU_OUT,
            RAM_write_en: 1'b0,
            IO_read_sel: 3'b0,
            IO_write_en: 1'b0,
            K: 12'b0,
            pc: 12'b0,
            index: EXTEND,
            halt: 1'b0,
            EB: 3'b0,
            FB: 3'b0,
            in_ROM: 3'b0
            };

           rs1_data_E <= 'd0;
            rs2_data_E <= 'd0;
            IO_read_data_E <= 'd0; 
         end
         else if (flush_DE) begin 
            ctrl_E <= '{
            alu_op: ALU_AD,
            data_read_en: 1'b1,
            wr1_sel: A,
            wr2_sel: A,
            wr1_en: 1'b0,
            wr2_en: 1'b0,
            rs1_sel: A,
            rs2_sel: A,
            alu_src1: RS1_DATA1,
            alu_src2: READ_DATA2,
            branch: NO_BRANCH,
            rd: ALU_OUT,
            RAM_write_en: 1'b0,
            IO_read_sel: 3'b0,
            IO_write_en: 1'b0,
            K: 12'b0,
            pc: 12'b0,
            index: EXTEND,
            halt: 1'b0,
            EB: 3'b0,
            FB: 3'b0,
            in_ROM: 3'b0
            };


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
  logic sign_bit_E, eq_0_E;
  logic [29:0] alu_src1_E, rs1rs2_data_E;
  logic [14:0] alu_src2_E;
  
  assign rs1rs2_data_E = {rs1_data_E,rs2_data_E};
  
  assign read_data_E = ctrl_E.in_ROM ? ROM_constant_data :  RAM_read_data;

  mux #(3, $bits(rs1rs2_data_E)) ALU1_Mux(.in({rs1rs2_data_E, 15'd0, rs1_data_E, 18'd0, ctrl_E.K}),
      .sel(ctrl_E.alu_src1), .out(alu_src1_E));

  //TODO should it be K or address?
  mux #(4, $bits(alu_src2_E)) ALU_2_Mux(.in({read_data_E, rs2_data_E, IO_read_data_E, 3'd0, ctrl_E.K}),
            .sel(ctrl_E.alu_src2),
            .out(alu_src2_E));

  assign sign_bit_E = alu_src2_E[14];
  
  
 
  arithmetic_logic_unit ALU(.source_1(alu_src1_E), .source_2(alu_src2_E), .result(alu_out_E), .res_eq_0(eq_0_E),
          .operation_sel(ctrl_E.alu_op));

  branching_logic Branch(.eq_0(eq_0_E), .sign_bit(sign_bit_E), .ctrl_branch(ctrl_E.branch),
                         .branch(branch_E));
  
  //Execute Writeback Register
  logic [29:0] alu_out_W;

  always_ff @(posedge clock, negedge rst_l) begin
         if (!rst_l) begin 
            ctrl_W <= '{
            alu_op: ALU_AD,
            data_read_en: 1'b1,
            wr1_sel: A,
            wr2_sel: A,
            wr1_en: 1'b0,
            wr2_en: 1'b0,
            rs1_sel: A,
            rs2_sel: A,
            alu_src1: RS1_DATA1,
            alu_src2: READ_DATA2,
            branch: NO_BRANCH,
            rd: ALU_OUT,
            RAM_write_en: 1'b0,
            IO_read_sel: 3'b0,
            IO_write_en: 1'b0,
            K: 12'b0,
            pc: 12'b0,
            index: EXTEND,
            halt: 1'b0,
            EB: 3'b0,
            FB: 3'b0,
            in_ROM: 3'b0
            };

            alu_out_W <= 'd0;
            flush_W <= 'd0;
         end       
         else if (1'b1) begin
            ctrl_W <= ctrl_E;
            alu_out_W <= alu_out_E;
            flush_W <= flush_E;
         end 
    end

  ///////////////////////////WRITEBACK STAGE////////////////////////////

  logic [29:0] data_W;
  logic [13:0] addr_ROM_pc, addr_ROM_r;

  mux #(2, $bits(data_W)) output_mux(.in({15'd0,ctrl_W.pc,alu_out_W}),
            .sel(ctrl_W.rd),
            .out(data_W));

  //higher bits wr1 lower bits wr2
  assign wr1_data_W = data_W[29:15];
  assign wr2_data_W = data_W[14:0];

  //data address upper bits data lower bits
  assign RAM_write_data = data_W[14:0];

  //data channel upper bits data w
  assign IO_write_sel = ctrl_W.K[3:0]; 
  assign IO_write_data = data_W[14:0];
  assign IO_write_en = ctrl_W.IO_write_en;
  assign halt = ctrl_W.halt;
 
  //hooking up the address translation 
  addr_translate addr (.addr_pc(pc_F), .addr_r(ctrl_D.K), .addr_w(data_W[26:15]), .bits_EB_r(ctrl_D.EB), .bits_EB_w(ctrl_W.EB), .bits_FB_r(ctrl_W.FB), .en_write(ctrl_W.RAM_write_en), .addr_ROM_pc(ROM_pc_address),  .addr_ROM_r(ROM_constant_address), .addr_RAM_r(RAM_read_address), .addr_RAM_w(RAM_write_address), .en_write_final(RAM_write_en));

  assign stall_D = stall;

  //STALL UNIT
  stall_logic stl(.ctrl_D, .ctrl_E, .ctrl_W, .stall, .branch_E, .flush(flush_E));

endmodule : Core
