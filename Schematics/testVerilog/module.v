// Verilog module auto-generated for AGC module A1 by dumbVerilog.py

module A1 ( 
  rst, FS01_, F02A, F02B, FS02, FS02A
);

input wire rst, FS01_;

output wire F02A, F02B, FS02, FS02A;

// Gate A1-U127A
pullup(g38204);
assign g38204 = rst ? 1'bz : ((0|g38203|FS02) ? 1'b0 : 1'bz);
// Gate A1-U128A
pullup(g38203);
assign g38203 = rst ? 0 : ((0|g38205|FS01_|F02A) ? 1'b0 : 1'bz);
// Gate A1-U126B
pullup(FS02A);
assign FS02A = rst ? 0 : ((0|g38204) ? 1'b0 : 1'bz);
// Gate A1-U129A
pullup(g38205);
assign g38205 = rst ? 1'bz : ((0|F02B|FS01_|g38203) ? 1'b0 : 1'bz);
// Gate A1-U127B
pullup(FS02);
assign FS02 = rst ? 0 : ((0|g38204|g38205) ? 1'b0 : 1'bz);
// Gate A1-U128B
pullup(F02A);
assign F02A = rst ? 0 : ((0|g38204|g38203) ? 1'b0 : 1'bz);
// Gate A1-U129B
pullup(F02B);
assign F02B = rst ? 0 : ((0|g38205|FS02) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
