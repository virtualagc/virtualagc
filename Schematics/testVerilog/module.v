// Verilog module auto-generated for AGC module A1 by dumbVerilog.py

module A1 ( 
  rst, FS01_, F02A, F02B, FS02, FS02A
);

input wire rst, FS01_;

output wire F02A, F02B, FS02, FS02A;

// Gate A1-U127A
pullup(A1U126Pad7);
assign (highz1,strong0) A1U126Pad7 = rst ? 1 : ~(0|A1U127Pad2|FS02);
// Gate A1-U128A
pullup(A1U127Pad2);
assign (highz1,strong0) A1U127Pad2 = rst ? 0 : ~(0|A1U127Pad8|FS01_|F02A);
// Gate A1-U126B
pullup(FS02A);
assign (highz1,strong0) FS02A = rst ? 0 : ~(0|A1U126Pad7);
// Gate A1-U129A
pullup(A1U127Pad8);
assign (highz1,strong0) A1U127Pad8 = rst ? 1 : ~(0|F02B|FS01_|A1U127Pad2);
// Gate A1-U127B
pullup(FS02);
assign (highz1,strong0) FS02 = rst ? 0 : ~(0|A1U126Pad7|A1U127Pad8);
// Gate A1-U128B
pullup(F02A);
assign (highz1,strong0) F02A = rst ? 0 : ~(0|A1U126Pad7|A1U127Pad2);
// Gate A1-U129B
pullup(F02B);
assign (highz1,strong0) F02B = rst ? 0 : ~(0|A1U127Pad8|FS02);

endmodule
