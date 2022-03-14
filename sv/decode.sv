`include "internal_defines.vh"

`default_nettype none

module decoder
  (input logic rst_l, clock,
   input [14:0] instr, read_data_E
   ouput ctrl_t ctrl_D);

  logic [2:0] opcode, next_byte, lowest_byte;
  logic [1:0] next2_bits;
  logic [14:0] instr_F;
  logic extra_code1, extra_code2, in_ROM, in_RAM, is_reg, addr_is_0, index1, index2;

  register #(1, 1'b0) reg(.clk, .rst_l,
            .en(1'b1), .clear(1'b0), .D(extra_code1),
            .Q(extra_code2));
  register #(1, 1'b0) reg(.clk, .rst_l,
            .en(1'b1), .clear(1'b0), .D(index1),
            .Q(index2));


  
  assign instr_F = (index2) ? read_data_E + instr : instr;
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
    IO_read_sel: 3'b0,
    IO_write_en: 1'b0
    K: 12'b0,
    pc: 15'b0,
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
                alu_op = ALU_READ;
                data_read_en = 1'b0
              end
              //WRITE
              3'd1 : begin
              end
              //RAND
              3'd2 : begin
              end
              //WAND
              3'd3 : begin
              end
              //ROR
              3'd4 : begin
              end
              //WOR
              3'd5 : begin
              end
              //RXOR
              3'd6 : begin
              end
              default: begin
                `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.illegal_instr = 1'b1;
              end
            endcase
          end
          3'd1 : begin
            unique case(is_ROM)
              //BZF
              1'b1 : begin
              end
              //DV
              defualt :  begin
              end
            endcase
          end
          3'd2 : begin
            unique case(next2_bits)
              //QXCH
              2'd1 : begin
              end
              //AUG
              2'd2 : begin
              end  
              //DIM
              2'd3 : begin
              end
              default: begin
                `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.illegal_instr = 1'b1;
              end
            endcase
          end
          //INDEX
          5'd5 : begin
          end
          3'd6 : begin
            unique case(in_ROM)
              //BZMF
              1'b1 : begin
              end
              //SU
              default : begin
              end
            endcase
          end
          //MP Note SQUARE is special case of MP
          3'd7 : begin
          end
          default : begin
            `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.illegal_instr = 1'b1;
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
              end
              //EXTEND
              3'd6 : begin
              end
              // TC/XLQ
              default : begin
              end
            endcase
         end
         //TCF
         3'd1 : begin
         end
         3'd2 : begin
           unique case(next2_bits)
             //LXCH ZL
             2'd1 : begin 
             end
             //INCR
             2'd2 : begin
             end
             //ADS
             2'd3 : begin
             end
             default : begin
              `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.illegal_instr = 1'b1;
             end
           endcase
         end
         //CA
         3'd3 : begin
         end
         3'd4 : begin
           unique case(addr_is_0)
             //COM
             1'b1 : begin
             end
             //CS
             default : begin
             end
           endcase
         end
         3'd5 : begin
           unique case (next2_bits)
             //TS Note: TCAA is special case of TS
             2'd2 : begin
             end
             //XCH
             2'd3 : begin
             end
             `display(rst_l, "Encountered unknown/unimplemented instr 0x%05o." ,instr);
                                ctrl_signals.illegal_instr = 1'b1;
             end
           endcase
         end
         //AD/DOUBLE
         3'd6 : begin
         end
         //MASK
         2'd7 : begin
         end
       endcase
     end
   endcase
  end
endmodule: decoder

