// Verilog module auto-generated for AGC module A1 by dumbVerilog.py

module A1 ( 
  rst, FS01_, F02A, F02B, FS02, FS02A
);

input wire rst, FS01_;

output wire F02A, F02B, FS02, FS02A;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A1) will be %f ns.", GATE_DELAY*100);

// Gate A1-U127A
pullup(g38204);
assign #GATE_DELAY g38204 = rst ? 1'bz : ((0|FS02|g38203) ? 1'b0 : 1'bz);
// Gate A1-U128A
pullup(g38203);
assign #GATE_DELAY g38203 = rst ? 0 : ((0|F02A|FS01_|g38205) ? 1'b0 : 1'bz);
// Gate A1-U126B
pullup(FS02A);
assign #GATE_DELAY FS02A = rst ? 0 : ((0|g38204) ? 1'b0 : 1'bz);
// Gate A1-U129A
pullup(g38205);
assign #GATE_DELAY g38205 = rst ? 1'bz : ((0|g38203|FS01_|F02B) ? 1'b0 : 1'bz);
// Gate A1-U127B
pullup(FS02);
assign #GATE_DELAY FS02 = rst ? 0 : ((0|g38204|g38205) ? 1'b0 : 1'bz);
// Gate A1-U128B
pullup(F02A);
assign #GATE_DELAY F02A = rst ? 0 : ((0|g38204|g38203) ? 1'b0 : 1'bz);
// Gate A1-U129B
pullup(F02B);
assign #GATE_DELAY F02B = rst ? 0 : ((0|g38205|FS02) ? 1'b0 : 1'bz);
// End of NOR gates

endmodule
