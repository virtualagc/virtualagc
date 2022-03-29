`include "internal_defines.vh"

`default_nettype none

module decoder
  (input logic rst_l, clock,
   input [14:0] instr, index_data,
   input [11:0] pc,
   ouput ctrl_t ctrl_D);

  logic [2:0] opcode, next_byte, lowest_byte;
  logic [1:0] next2_bits;
  logic [14:0] instr_F;

  logic extra_code1, extra_code2, is_ROM, is_RAM, is_reg, addr_is_0, index1, index2, clk, recent_reset;

  assign clk = clock;
  
  //TODO stalling stuff
  register #(1, 1'b0) reg(.clk, .rst_l,
            .en(1'b1), .clear(1'b0), .D(extra_code1),
            .Q(extra_code2));
  register #(1, 1'b0) reg(.clk, .rst_l,
            .en(1'b1), .clear(1'b0), .D(index1),
            .Q(index2));

  register #(1, 1'b1) rg3(.clk, .rst_l,
            .en(1'b1), .clear(1'b0), .D(1'b0),
            .Q(recent_reset));



  
  assign instr_F = (index2) ? index_data + instr : instr;
  assign clk = clock;
  assign is_ROM = (instr_F[11:0] >= 'o2000) ? 1'b1 : 1'b0;
  assign is_RAM = ((instr_F[11:0] < 'o2000) && (instr_F[11:0] >= 'd13) ? 1'b1 : 1'b0;
  assign is_reg = (instr_F[11:0] < 'd13) ? 1'b1 : 1'b0;
  assign opcode = instr_F[14:12];
  assign next_byte = instr_F[11:9];
  assign last_byte = instr_F[2:0];
  assign next2_bits = instr_F[11:10];
  assign addr_is_0 = instr_F[11:0]==12'b0;


  
  always_comb begin
    ctrl_signals = '{
    alu_op: ALU_ADD,      
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
    IO_read_sel: instr_F[2:0],
    IO_write_en: 1'b0
    K: instr_F[11:0],
    pc: pc,
    index: EXTEND,
    halt: 1'b0
} ctrl_signals_t;
    index1 = 1'b0;
    extra_code1 = 1'b0;
    unique case (extra_code2)
      1'b1 : begin
        unique case(opcode)
          3'd0 : begin
            unique case(next_byte)
              //READ
              3'd0 : begin
                ctrl.alu_op = ALU_READ;
                ctrl.wr1_en = 1'b1;
                ctrl.alu_src2 = IO_READ_DATA2;
              end
              //WRITE
              3'd1 : begin
                ctrl.alu_op = ALU_READ;
                ctrl.alu_src2 = IO_READ_DATA2;
                ctrl.IO_write_en: 1'b1;
              end
              //RAND
              3'd2 : begin
                ctrl.alu_op = ALU_AND;
                ctrl.alu_src2 = IO_READ_DATA2;
                ctrl.wr1_en = 1'b1;
              end
              //WAND
              3'd3 : begin
                ctrl.alu_op = ALU_AND;
                ctrl.alu_src2 = IO_READ_DATA2;
                ctrl.IO_write_en: 1'b1;
              end
              //ROR
              3'd4 : begin
                ctrl.alu_op = ALU_OR;
                ctrl.alu_src2 = IO_READ_DATA2;
                ctrl.wr1_en = 1'b1;
              end
              //WOR
              3'd5 : begin
                ctrl.alu_op = ALU_OR;
                ctrl.alu_src2 = IO_READ_DATA2;
                ctrl.IO_write_en: 1'b1;
              end
              //RXOR
              3'd6 : begin
                ctrl.alu_op = ALU_XOR;
                ctrl.alu_src2 = IO_READ_DATA2;
                ctrl.wr1_en = 1'b1;
              end
              default: begin
                `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl.halt = 1'b1;
              end
            endcase
          end
          3'd1 : begin
            unique case(is_ROM)
              //BZF
              1'b1 : begin
                ctrl.alu_op = ALU_BRANCH;
                ctrl.alu_src1 = K1;
                ctrl.branch = BZF;
              end
              //DV
              defualt :  begin
                ctrl.alu_op = ALU_DV;
                ctrl.wr2_sel = L;
                ctrl.wr1_en = 1'b1;
                ctrl.wr2_en = 1'b1;
                ctrl.rs2_sel = L;
                ctrl.alu_src1 = RS1_RS2_DATA1; 
              end
            endcase
          end
          3'd2 : begin
            unique case(next2_bits)
              //QXCH
              2'd1 : begin
                ctrl.alu_op = ALU_QXCH;
                ctrl.rs1_sel = Q;
                ctrl.wr2_sel = Q;
                ctrl.wr2_en = 1'b1;
                ctrl.rs2_sel = instr_F[3:0];
                ctrl.wr1_sel = instr_F[3:0];
                if(is_reg) begin
                  ctrl.alu_src2 = RS2_DATA2;
                  ctrl.wr1_en = 1'b1;
                end
                else begin
                  ctrl.RAN_write_en = 1'b1;
                end
              end
              //AUG
              2'd2 : begin
                ctrl.rs2_sel = instr_F[3:0];
                ctrl.wr1_sel = instr_F[3:0];
                ctrl.alu_op = ALU_AUG;
                if(is_reg) begin
                  ctrl.alu_src2 = RS2_DATA2;
                  ctrl.wr1_en = 1'b1;
                end
                else begin
                  ctrl.RAM_write_out = 1'b1;
                end
              end  
              //DIM
              2'd3 : begin
                ctrl.rs2_sel = instr_F[3:0];
                ctrl.wr1_sel = instr_F[3:0];
                ctrl.alu_op = ALU_DIM;
                if(is_reg) begin
                  ctrl.alu_src2 = RS2_DATA2;
                  ctrl.wr1_en = 1'b1;
                end
                else begin
                  ctrl.RAM_write_out = 1'b1;
                end               
              end
              default: begin
                `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl.halt = 1'b1;
              end
            endcase
          end
          //halt
          3'd3 : begin
            ctrl.halt = 1'b1;
          end
          //INDEX
          5'd5 : begin
            ctrl_index = EXTEND;
            index1 = 1'b1;
          end
          3'd6 : begin
            unique case(in_ROM)
              //BZMF
              1'b1 : begin
                ctrl.alu_op = ALU_BRANCH;
                ctrl.alu_src1 = K1;
                ctrl.branch = BZMF;
              end
              //SU
              default : begin
                ctrl.wr1_en = 1'b1;
                ctrl.alu_op = ALU_SU;
                ctrl.rs2_sel = instr_F[3:0]
                if(is_reg) begin
                  ctrl.alu_src2 = RS2_DATA2;
                end
              end
            endcase
          end
          //MP Note SQUARE is special case of MP
          3'd7 : begin
            ctrl.alu_op = ALU_MP;
            ctrl.wr1_sel = A;
            ctrl.wr2_sel = L;
            ctrl.wr1_en = 1'b1;
            ctrl.wr2_en = 1'b1;
            ctrl.rs2_sel = L;
            ctrl.alu_src1 = RS1_RS2_DATA1;
          end
          default : begin
            `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.halt = 1'b1;
           end
        endcase
      end
      //no extracode
      default : begin
        unique case(opcode)
          3'd0 : begin
            unique case(last_byte)
              //RETURN
              3'd2 : begin
                ctrl.alu_op = ALU_READ;
                ctrl.rs2_sel = Q;
                ctrl.alu_src2 = RS2_DATA2;
                ctrl.wr1_sel = Q;
                ctrl.wr1_en = 1'b1;
                ctrl.rd = OLD_PC;
                ctrl.branch = BRANCH;
              end
              //EXTEND
              3'd6 : begin
                extra_code1 = 1'b1;
              end
              // TC/XLQ
              default : begin
                //resent reset gets rid of edge case with reset 
                //12d'4 is IHINT and we are treading that as a NOOP
                if (~recent_reset & (~(instr_F[11:0]==12'd4))) begin
                  ctrl.alu_op = ALU_READ;
                  ctrl.alu_src2 = K2;
                  ctrl.wr1_sel = Q;
                  ctrl.wr1_en = 1'b1;
                  ctrl.branch = BRANCH;
                  ctrl.rd = OLD_PC;
                end
              end
            endcase
         end
         //TCF
         3'd1 : begin
           ctrl.alu_op = ALU_READ;
           ctrl.alu_src2 = K2;
           ctrl.branch = BRANCH; 
         
         end
         3'd2 : begin
           unique case(next2_bits)
             //LXCH ZL
             2'd1 : begin               
               ctrl.alu_op = ALU_QXCH;
               ctrl.rs1_sel = L;
               ctrl.wr2_sel = L;
               ctrl.wr2_en = 1'b1;
               ctrl.rs2_sel = instr_F[3:0];
               ctrl.wr1_sel = instr_F[3:0];
               if(is_reg) begin
                 ctrl.alu_src2 = RS2_DATA2;
                 ctrl.wr1_en = 1'b1;
               end
               else begin
                 ctrl.RAM_write_en = 1'b1;
               end
             end
             //INCR
             2'd2 : begin
               ctrl.alu_op = ALU_INCR;
               ctrl.rs2_sel = instr_F[3:0];
               ctrl.wr1_sel = instr_F[3:0];
               if(is_reg) begin
                 ctrl.alu_src2 = RS2_DATA2;
                 ctrl.wr1_en = 1'b1;
               end
               else begin
                 ctrl.RAM_write_en = 1'b1;
               end
             end
             //ADS
             2'd3 : begin
               ctrl.alu_op = ALU_AD;
               ctrl.rs2_sel = instr_F[3:0];
               ctrl.wr2_sel = instr_F[3:0];
               if(is_reg) begin
                 ctrl.alu_src2 = RS2_DATA2;
                 ctrl.wr2_en = 1'b1;
               end
               else begin
                 ctrl.RAM_write_en = 1'b1;
               end
             end
             default : begin
              `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.halt = 1'b1;
             end
           endcase
         end
         //CA
         3'd3 : begin
           ctrl.wr1_en = 1'b1;
           ctrl.alu_op = ALU_READ;
           ctrl.rs2_sel = instr_F[3:0]
           if(is_reg) begin
             ctrl.alu_src2 = RS2_DATA2;
           end
         end
         3'd4 : begin
           //CS
           ctrl.wr1_en = 1'b1;
           ctrl.alu_op = ALU_COM;
           ctrl.rs2_sel = instr_F[3:0]
           if(is_reg) begin
             ctrl.alu_src2 = RS2_DATA2;
           end
         end
         3'd5 : begin
           unique case (next2_bits)
             //INDEX
             2'd0 : begin
               ctrl_index = NEXTEND;
               index1 = 1'b1;
             end
             2'd2 : begin
               //TCAA
               if(instr_F[9:0]==10'd6) begin
                 ctrl.alu_op = ALU_READ;
                 ctrl.alu_src2 = RS2_DATA2;
                 ctrl.branch = BRANCH;
               end
               //TS
               else begin
                 ctrl.alu_op = ALU_READ;
                 ctrl.alu_src2 = RS2_DATA;
                 if(is_reg) begin
                   ctrl.wr2_sel = instr_F[3:0];
                   ctrl.wr2_en = 1'b1;
                 end
                 else begin
                   ctrl.RAM_write_en = 1'b1;
                 end

               end
               
             end
             //XCH
             2'd3 : begin
               ctrl.alu_op = ALU_QXCH;
               ctrl.rs1_sel = A;
               ctrl.wr2_sel = A;
               ctrl.wr2_en = 1'b1;
               ctrl.rs2_sel = instr_F[3:0];
               ctrl.wr1_sel = instr_F[3:0];
               if(is_reg) begin
                 ctrl.alu_src2 = RS2_DATA2;
                 ctrl.wr1_en = 1'b1;
               end
               else begin
                 ctrl.RAM_write_en = 1'b1;
               end
             end

             
             `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.halt = 1'b1;
             end
           endcase
         end
         //AD/DOUBLE
         3'd6 : begin
           ctrl.wr1_en = 1'b1;
           ctrl.alu_op = ALU_AD;
           ctrl.rs2_sel = instr_F[3:0]
           if(is_reg) begin
             ctrl.alu_src2 = RS2_DATA2;
           end
         end
         //MASK
         2'd7 : begin
           ctrl.wr1_en = 1'b1;
           ctrl.alu_op = ALU_AND;
           ctrl.rs2_sel = instr_F[3:0]
           if(is_reg) begin
             ctrl.alu_src2 = RS2_DATA2;
           end
         end
       endcase
     end
   endcase
  end
endmodule: decoder

