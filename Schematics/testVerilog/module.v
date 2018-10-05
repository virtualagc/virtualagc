// Verilog module auto-generated for AGC module A1 by dumbVerilog.py

module A1 ( 
  rst, FS01_, F02A, F02B, FS02, FS02A
);

input wand rst, FS01_;

output wand F02A, F02B, FS02, FS02A;

// Gate A1-U127A
assign g38204 = rst ? 1 : ~(0|g38203|FS02);
// Gate A1-U128A
assign g38203 = rst ? 0 : ~(0|g38205|FS01_|F02A);
// Gate A1-U126B
assign FS02A = rst ? 0 : ~(0|g38204);
// Gate A1-U129A
assign g38205 = rst ? 1 : ~(0|F02B|FS01_|g38203);
// Gate A1-U127B
assign FS02 = rst ? 0 : ~(0|g38204|g38205);
// Gate A1-U128B
assign F02A = rst ? 0 : ~(0|g38204|g38203);
// Gate A1-U129B
assign F02B = rst ? 0 : ~(0|g38205|FS02);

endmodule
