// Verilog module auto-generated for AGC module A99 by dumbVerilog.py

module A99 ( 
  rst, GEM01, GEM02, GEM03, GEM04, GEM05, GEM06, GEM07, GEM08, GEM09, GEM10,
  GEM11, GEM12, GEM13, GEM14, GEM16, GEMP, IL01, IL02, IL03, IL04, IL05,
  IL06, IL07, RESETD, REX, REY, RSTKX_, RSTKY_, SBE, SBF, SETAB, SETCD, SETEK,
  STR412, WEX, WEY, XB1E, XB2E, XB4E, XB6E, XT1E, XT2E, XT4E, XT5E, YB1E,
  YB2E, YT1E, YT2E, YT4E, CLROPE, HIMOD, LOMOD, RESETA, RESETB, RESETC, ROPER,
  ROPES, ROPET, SA01, SA02, SA03, SA04, SA05, SA06, SA07, SA08, SA09, SA10,
  SA11, SA12, SA13, SA14, SA16, SAP, STR14, STR19, STR210, STR311, STR58,
  STR912, XB3E, XB5E, XB7E, XT3E, XT6E, XT7E, YB3E, YT3E, YT5E, YT6E, YT7E,
  ZID
);

input wire rst, GEM01, GEM02, GEM03, GEM04, GEM05, GEM06, GEM07, GEM08, GEM09,
  GEM10, GEM11, GEM12, GEM13, GEM14, GEM16, GEMP, IL01, IL02, IL03, IL04,
  IL05, IL06, IL07, RESETD, REX, REY, RSTKX_, RSTKY_, SBE, SBF, SETAB, SETCD,
  SETEK, STR412, WEX, WEY, XB1E, XB2E, XB4E, XB6E, XT1E, XT2E, XT4E, XT5E,
  YB1E, YB2E, YT1E, YT2E, YT4E;

inout wire CLROPE, HIMOD, LOMOD, RESETA, RESETB, RESETC, ROPER, ROPES, ROPET,
  STR14, STR19, STR210, STR311, STR58, STR912, XB3E, XB5E, XB7E, XT3E, XT6E,
  XT7E, YB3E, YT3E, YT5E, YT6E, YT7E, ZID;

inout wire SA01, SA02, SA03, SA04, SA05, SA06, SA07, SA08, SA09, SA10, SA11,
  SA12, SA13, SA14, SA16, SAP;

parameter GATE_DELAY = 0.2; // This default may be overridden at compile time.
initial $display("Gate delay (A99) will be %f ns.", GATE_DELAY*100);

// Gate A99-U120B
pullup(A99NOROPE);
assign #GATE_DELAY A99NOROPE = rst ? 1'bz : ((0|ROPER|ROPES|ROPET) ? 1'b0 : 1'bz);
// Gate A99-U216A
pullup(g99231);
assign #GATE_DELAY g99231 = rst ? 1'bz : ((0|A99RADDR7|g99230) ? 1'b0 : 1'bz);
// Gate A99-U214B
pullup(g99228);
assign #GATE_DELAY g99228 = rst ? 0 : ((0|A99ES06_|g99203) ? 1'b0 : 1'bz);
// Gate A99-U218B
pullup(g99236);
assign #GATE_DELAY g99236 = rst ? 0 : ((0|A99ES08_|g99203) ? 1'b0 : 1'bz);
// Gate A99-U124A
pullup(g99147);
assign #GATE_DELAY g99147 = rst ? 1'bz : ((0|A99QUARTERB|g99145) ? 1'b0 : 1'bz);
// Gate A99-U117A
pullup(g99133);
assign #GATE_DELAY g99133 = rst ? 0 : ((0|g99171|RESETC) ? 1'b0 : 1'bz);
// Gate A99-U116B
pullup(g99132);
assign #GATE_DELAY g99132 = rst ? 1'bz : ((0|CLROPE|g99133) ? 1'b0 : 1'bz);
// Gate A99-U205A A99-U205B
pullup(A99ES03_);
assign #GATE_DELAY A99ES03_ = rst ? 0 : ((0|XB5E|XB4E|XB6E|XB7E) ? 1'b0 : 1'bz);
// Gate A99-U131B
pullup(g99162);
assign #GATE_DELAY g99162 = rst ? 1'bz : ((0|g99131|RESETB) ? 1'b0 : 1'bz);
// Gate A99-U116A
pullup(g99131);
assign #GATE_DELAY g99131 = rst ? 0 : ((0|g99162|g99130) ? 1'b0 : 1'bz);
// Gate A99-U230B
pullup(g99260);
assign #GATE_DELAY g99260 = rst ? 0 : ((0|g99259) ? 1'b0 : 1'bz);
// Gate A99-U222B
pullup(A99RADDR9);
assign #GATE_DELAY A99RADDR9 = rst ? 0 : ((0|g99242|A99RESETK) ? 1'b0 : 1'bz);
// Gate A99-U220A
pullup(A99RADDR8);
assign #GATE_DELAY A99RADDR8 = rst ? 0 : ((0|A99RESETK|g99237) ? 1'b0 : 1'bz);
// Gate A99-U222A
pullup(A99RADDR3);
assign #GATE_DELAY A99RADDR3 = rst ? 0 : ((0|A99RESETK|g99240) ? 1'b0 : 1'bz);
// Gate A99-U201A A99-U201B
pullup(A99ES01_);
assign #GATE_DELAY A99ES01_ = rst ? 0 : ((0|XB3E|XB1E|XB5E|XB7E) ? 1'b0 : 1'bz);
// Gate A99-U221B
pullup(g99242);
assign #GATE_DELAY g99242 = rst ? 1'bz : ((0|g99241|A99RADDR9) ? 1'b0 : 1'bz);
// Gate A99-U217A
pullup(A99RADDR7);
assign #GATE_DELAY A99RADDR7 = rst ? 0 : ((0|A99RESETK|g99231) ? 1'b0 : 1'bz);
// Gate A99-U229B
pullup(A99RADDR6);
assign #GATE_DELAY A99RADDR6 = rst ? 0 : ((0|g99257|A99RESETK) ? 1'b0 : 1'bz);
// Gate A99-U228A
pullup(A99RADDR5);
assign #GATE_DELAY A99RADDR5 = rst ? 0 : ((0|A99RESETK|g99252) ? 1'b0 : 1'bz);
// Gate A99-U225A
pullup(A99RADDR4);
assign #GATE_DELAY A99RADDR4 = rst ? 0 : ((0|A99RESETK|g99245) ? 1'b0 : 1'bz);
// Gate A99-U211A A99-U211B
pullup(A99ES09_);
assign #GATE_DELAY A99ES09_ = rst ? 0 : ((0|YT3E|YT1E|YT5E|YT7E) ? 1'b0 : 1'bz);
// Gate A99-U132B
pullup(g99164);
assign #GATE_DELAY g99164 = rst ? 1'bz : ((0|g99163) ? 1'b0 : 1'bz);
// Gate A99-U209A
pullup(g99217);
assign #GATE_DELAY g99217 = rst ? 0 : ((0|g99203|A99ES03_) ? 1'b0 : 1'bz);
// Gate A99-U132A
pullup(g99163);
assign #GATE_DELAY g99163 = rst ? 0 : ((0|g99162) ? 1'b0 : 1'bz);
// Gate A99-U107B
pullup(g99114);
assign #GATE_DELAY g99114 = rst ? 0 : ((0|g99102|HIMOD) ? 1'b0 : 1'bz);
// Gate A99-U237B
pullup(g99274);
assign #GATE_DELAY g99274 = rst ? 0 : ((0|g99270) ? 1'b0 : 1'bz);
// Gate A99-U223B
pullup(g99246);
assign #GATE_DELAY g99246 = rst ? 0 : ((0|A99ES10_|g99203) ? 1'b0 : 1'bz);
// Gate A99-U135B
pullup(g99170);
assign #GATE_DELAY g99170 = rst ? 1'bz : ((0|g99169) ? 1'b0 : 1'bz);
// Gate A99-U107A
pullup(g99113);
assign #GATE_DELAY g99113 = rst ? 0 : ((0|g99112|LOMOD|ROPET) ? 1'b0 : 1'bz);
// Gate A99-U223A
pullup(g99245);
assign #GATE_DELAY g99245 = rst ? 1'bz : ((0|A99RADDR4|g99219) ? 1'b0 : 1'bz);
// Gate A99-U135A
pullup(g99169);
assign #GATE_DELAY g99169 = rst ? 0 : ((0|g99168) ? 1'b0 : 1'bz);
// Gate A99-U203A A99-U203B
pullup(A99ES02_);
assign #GATE_DELAY A99ES02_ = rst ? 1'bz : ((0|XB3E|XB2E|XB6E|XB7E) ? 1'b0 : 1'bz);
// Gate A99-U112B
pullup(g99124);
assign #GATE_DELAY g99124 = rst ? 0 : ((0|HIMOD|STR58) ? 1'b0 : 1'bz);
// Gate A99-U113B
pullup(g99126);
assign #GATE_DELAY g99126 = rst ? 0 : ((0|LOMOD|g99125) ? 1'b0 : 1'bz);
// Gate A99-U224A
pullup(g99247);
assign #GATE_DELAY g99247 = rst ? 1'bz : ((0|A99RADDR10|g99246) ? 1'b0 : 1'bz);
// Gate A99-U108A
pullup(g99115);
assign #GATE_DELAY g99115 = rst ? 1'bz : ((0|STR912) ? 1'b0 : 1'bz);
// Gate A99-U224B
pullup(g99248);
assign #GATE_DELAY g99248 = rst ? 1'bz : ((0|WEX) ? 1'b0 : 1'bz);
// Gate A99-U133B
pullup(g99166);
assign #GATE_DELAY g99166 = rst ? 0 : ((0|g99164) ? 1'b0 : 1'bz);
// Gate A99-U103A
pullup(g99105);
assign #GATE_DELAY g99105 = rst ? 0 : ((0|STR14|LOMOD|ROPES) ? 1'b0 : 1'bz);
// Gate A99-U102A
pullup(g99103);
assign #GATE_DELAY g99103 = rst ? 1'bz : ((0|ROPES) ? 1'b0 : 1'bz);
// Gate A99-U115A
pullup(g99129);
assign #GATE_DELAY g99129 = rst ? 1'bz : ((0|g99130|CLROPE) ? 1'b0 : 1'bz);
// Gate A99-U226A
pullup(g99251);
assign #GATE_DELAY g99251 = rst ? 1'bz : ((0|WEY) ? 1'b0 : 1'bz);
// Gate A99-U115B
pullup(g99130);
assign #GATE_DELAY g99130 = rst ? 0 : ((0|RESETB|g99165) ? 1'b0 : 1'bz);
// Gate A99-U210A
pullup(g99219);
assign #GATE_DELAY g99219 = rst ? 0 : ((0|g99203|A99ES04_) ? 1'b0 : 1'bz);
// Gate A99-U212A A99-U212B
pullup(A99ES10_);
assign #GATE_DELAY A99ES10_ = rst ? 0 : ((0|YT3E|YT2E|YT6E|YT7E) ? 1'b0 : 1'bz);
// Gate A99-U133A
pullup(g99165);
assign #GATE_DELAY g99165 = rst ? 1'bz : ((0|g99166) ? 1'b0 : 1'bz);
// Gate A99-U119B
pullup(g99138);
assign #GATE_DELAY g99138 = rst ? 0 : ((0|g99137|A99NOROPE) ? 1'b0 : 1'bz);
// Gate A99-U119A
pullup(g99137);
assign #GATE_DELAY g99137 = rst ? 1'bz : ((0|SBF) ? 1'b0 : 1'bz);
// Gate A99-U229A
pullup(g99257);
assign #GATE_DELAY g99257 = rst ? 1'bz : ((0|A99RADDR6|g99228) ? 1'b0 : 1'bz);
// Gate A99-U141B
pullup(A99FADDR2);
assign #GATE_DELAY A99FADDR2 = rst ? 0 : ((0|IL02) ? 1'b0 : 1'bz);
// Gate A99-U128B
pullup(g99156);
assign #GATE_DELAY g99156 = rst ? 1'bz : ((0|g99128|RESETA) ? 1'b0 : 1'bz);
// Gate A99-U114B
pullup(g99128);
assign #GATE_DELAY g99128 = rst ? 0 : ((0|g99127|g99156) ? 1'b0 : 1'bz);
// Gate A99-U114A
pullup(g99127);
assign #GATE_DELAY g99127 = rst ? 0 : ((0|g99159|RESETA) ? 1'b0 : 1'bz);
// Gate A99-U130A
pullup(g99159);
assign #GATE_DELAY g99159 = rst ? 1'bz : ((0|g99160) ? 1'b0 : 1'bz);
// Gate A99-U215B
pullup(g99230);
assign #GATE_DELAY g99230 = rst ? 0 : ((0|A99ES07_|g99203) ? 1'b0 : 1'bz);
// Gate A99-U221A
pullup(g99241);
assign #GATE_DELAY g99241 = rst ? 0 : ((0|g99203|A99ES09_) ? 1'b0 : 1'bz);
// Gate A99-U215A
pullup(g99229);
assign #GATE_DELAY g99229 = rst ? 1'bz : ((0|A99RADDR1|g99204) ? 1'b0 : 1'bz);
// Gate A99-U121B
pullup(g99142);
assign #GATE_DELAY g99142 = rst ? 1'bz : ((0|SETAB) ? 1'b0 : 1'bz);
// Gate A99-U111B
pullup(g99122);
assign #GATE_DELAY g99122 = rst ? 0 : ((0|g99142|g99141) ? 1'b0 : 1'bz);
// Gate A99-U121A
pullup(g99141);
assign #GATE_DELAY g99141 = rst ? 1'bz : ((0|RESETB) ? 1'b0 : 1'bz);
// Gate A99-U122A
pullup(g99143);
assign #GATE_DELAY g99143 = rst ? 1'bz : ((0|A99QUARTERA|g99122) ? 1'b0 : 1'bz);
// Gate A99-U217B
pullup(g99234);
assign #GATE_DELAY g99234 = rst ? 1'bz : ((0|ZID) ? 1'b0 : 1'bz);
// Gate A99-U113A
pullup(g99125);
assign #GATE_DELAY g99125 = rst ? 0 : ((0|STR58) ? 1'b0 : 1'bz);
// Gate A99-U213A
pullup(g99225);
assign #GATE_DELAY g99225 = rst ? 0 : ((0|g99203|A99ES05_) ? 1'b0 : 1'bz);
// Gate A99-U230A
pullup(g99259);
assign #GATE_DELAY g99259 = rst ? 1'bz : ((0|REY|REX) ? 1'b0 : 1'bz);
// Gate A99-U219B
pullup(A99RADDR2);
assign #GATE_DELAY A99RADDR2 = rst ? 0 : ((0|g99235|A99RESETK) ? 1'b0 : 1'bz);
// Gate A99-U233A
pullup(g99265);
assign #GATE_DELAY g99265 = rst ? 1'bz : ((0|A99EDESTROY|g99264) ? 1'b0 : 1'bz);
// Gate A99-U216B
pullup(A99RADDR1);
assign #GATE_DELAY A99RADDR1 = rst ? 0 : ((0|g99229|A99RESETK) ? 1'b0 : 1'bz);
// Gate A99-U210B
pullup(A99ES08_);
assign #GATE_DELAY A99ES08_ = rst ? 0 : ((0|YB2E|YB3E) ? 1'b0 : 1'bz);
// Gate A99-U202B
pullup(g99204);
assign #GATE_DELAY g99204 = rst ? 0 : ((0|A99ES01_|g99203) ? 1'b0 : 1'bz);
// Gate A99-U134A
pullup(A99CQC);
assign #GATE_DELAY A99CQC = rst ? 0 : ((0|g99132) ? 1'b0 : 1'bz);
// Gate A99-U131A
pullup(A99CQB);
assign #GATE_DELAY A99CQB = rst ? 0 : ((0|g99129) ? 1'b0 : 1'bz);
// Gate A99-U128A
pullup(A99CQA);
assign #GATE_DELAY A99CQA = rst ? 0 : ((0|g99154) ? 1'b0 : 1'bz);
// Gate A99-U202A
pullup(g99203);
assign #GATE_DELAY g99203 = rst ? 1'bz : ((0|SETEK) ? 1'b0 : 1'bz);
// Gate A99-U208A A99-U208B
pullup(A99ES06_);
assign #GATE_DELAY A99ES06_ = rst ? 0 : ((0|XT5E|XT4E|XT6E|XT7E) ? 1'b0 : 1'bz);
// Gate A99-U228B
pullup(A99RADDR11);
assign #GATE_DELAY A99RADDR11 = rst ? 0 : ((0|g99254|A99RESETK) ? 1'b0 : 1'bz);
// Gate A99-U225B
pullup(A99RADDR10);
assign #GATE_DELAY A99RADDR10 = rst ? 0 : ((0|g99247|A99RESETK) ? 1'b0 : 1'bz);
// Gate A99-U129A
pullup(g99157);
assign #GATE_DELAY g99157 = rst ? 0 : ((0|g99156) ? 1'b0 : 1'bz);
// Gate A99-U138A
pullup(A99FADDR9);
assign #GATE_DELAY A99FADDR9 = rst ? 1'bz : ((0|A99QUARTERA|A99QUARTERB) ? 1'b0 : 1'bz);
// Gate A99-U138B
pullup(A99FADDR8);
assign #GATE_DELAY A99FADDR8 = rst ? 1'bz : ((0|A99QUARTERA|A99QUARTERC) ? 1'b0 : 1'bz);
// Gate A99-U139A
pullup(A99FADDR7);
assign #GATE_DELAY A99FADDR7 = rst ? 1'bz : ((0|IL07) ? 1'b0 : 1'bz);
// Gate A99-U139B
pullup(A99FADDR6);
assign #GATE_DELAY A99FADDR6 = rst ? 1'bz : ((0|IL06) ? 1'b0 : 1'bz);
// Gate A99-U140A
pullup(A99FADDR5);
assign #GATE_DELAY A99FADDR5 = rst ? 1'bz : ((0|IL05) ? 1'b0 : 1'bz);
// Gate A99-U140B
pullup(A99FADDR4);
assign #GATE_DELAY A99FADDR4 = rst ? 1'bz : ((0|IL04) ? 1'b0 : 1'bz);
// Gate A99-U141A
pullup(A99FADDR3);
assign #GATE_DELAY A99FADDR3 = rst ? 1'bz : ((0|IL03) ? 1'b0 : 1'bz);
// Gate A99-U129B
pullup(g99158);
assign #GATE_DELAY g99158 = rst ? 1'bz : ((0|g99157) ? 1'b0 : 1'bz);
// Gate A99-U142A
pullup(A99FADDR1);
assign #GATE_DELAY A99FADDR1 = rst ? 1'bz : ((0|IL01) ? 1'b0 : 1'bz);
// Gate A99-U104A
pullup(g99107);
assign #GATE_DELAY g99107 = rst ? 1'bz : ((0|STR912|HIMOD|ROPET) ? 1'b0 : 1'bz);
// Gate A99-U126B
pullup(g99152);
assign #GATE_DELAY g99152 = rst ? 1'bz : ((0|g99150|A99QUARTERC) ? 1'b0 : 1'bz);
// Gate A99-U105B
pullup(g99110);
assign #GATE_DELAY g99110 = rst ? 0 : ((0|g99103|g99115) ? 1'b0 : 1'bz);
// Gate A99-U106A
pullup(g99111);
assign #GATE_DELAY g99111 = rst ? 0 : ((0|STR14|LOMOD|ROPER) ? 1'b0 : 1'bz);
// Gate A99-U213B A99-U214A
pullup(A99ES11_);
assign #GATE_DELAY A99ES11_ = rst ? 0 : ((0|YT6E|YT7E|YT5E|YT4E) ? 1'b0 : 1'bz);
// Gate A99-U101A
pullup(A99FADDR16);
assign #GATE_DELAY A99FADDR16 = rst ? 0 : ((0|STR14|LOMOD|g99106) ? 1'b0 : 1'bz);
// Gate A99-U102B
pullup(A99FADDR15);
assign #GATE_DELAY A99FADDR15 = rst ? 0 : ((0|ROPER|g99105|g99107) ? 1'b0 : 1'bz);
// Gate A99-U105A A99-U104B
pullup(A99FADDR14);
assign #GATE_DELAY A99FADDR14 = rst ? 1'bz : ((0|g99114|g99113|g99110|g99111) ? 1'b0 : 1'bz);
// Gate A99-U109A A99-U109B
pullup(A99FADDR13);
assign #GATE_DELAY A99FADDR13 = rst ? 0 : ((0|g99119|g99116|g99120|g99121) ? 1'b0 : 1'bz);
// Gate A99-U122B
pullup(A99QUARTERA);
assign #GATE_DELAY A99QUARTERA = rst ? 0 : ((0|g99143|A99CQA) ? 1'b0 : 1'bz);
// Gate A99-U137A
pullup(A99FADDR11);
assign #GATE_DELAY A99FADDR11 = rst ? 1'bz : ((0|STR19|STR210) ? 1'b0 : 1'bz);
// Gate A99-U127A
pullup(A99QUARTERC);
assign #GATE_DELAY A99QUARTERC = rst ? 0 : ((0|A99CQC|g99152) ? 1'b0 : 1'bz);
// Gate A99-U233B
pullup(g99266);
assign #GATE_DELAY g99266 = rst ? 1'bz : ((0|SBE) ? 1'b0 : 1'bz);
// Gate A99-U234B
pullup(g99268);
assign #GATE_DELAY g99268 = rst ? 1'bz : ((0|g99267) ? 1'b0 : 1'bz);
// Gate A99-U232A
pullup(g99263);
assign #GATE_DELAY g99263 = rst ? 1'bz : ((0|g99260|g99262) ? 1'b0 : 1'bz);
// Gate A99-U231B
pullup(g99262);
assign #GATE_DELAY g99262 = rst ? 0 : ((0|A99EDESTROY|g99263) ? 1'b0 : 1'bz);
// Gate A99-U234A
pullup(g99267);
assign #GATE_DELAY g99267 = rst ? 0 : ((0|g99263) ? 1'b0 : 1'bz);
// Gate A99-U120A
pullup(g99139);
assign #GATE_DELAY g99139 = rst ? 1'bz : ((0|g99138) ? 1'b0 : 1'bz);
// Gate A99-U204B
pullup(g99208);
assign #GATE_DELAY g99208 = rst ? 0 : ((0|A99ES02_|g99203) ? 1'b0 : 1'bz);
// Gate A99-U209B
pullup(A99ES07_);
assign #GATE_DELAY A99ES07_ = rst ? 0 : ((0|YB1E|YB3E) ? 1'b0 : 1'bz);
// Gate A99-U235A
pullup(g99269);
assign #GATE_DELAY g99269 = rst ? 0 : ((0|g99268) ? 1'b0 : 1'bz);
// Gate A99-U108B
pullup(g99116);
assign #GATE_DELAY g99116 = rst ? 1'bz : ((0|ROPES|HIMOD|STR912) ? 1'b0 : 1'bz);
// Gate A99-U123B
pullup(g99146);
assign #GATE_DELAY g99146 = rst ? 1'bz : ((0|RESETA) ? 1'b0 : 1'bz);
// Gate A99-U235B
pullup(g99270);
assign #GATE_DELAY g99270 = rst ? 1'bz : ((0|g99269) ? 1'b0 : 1'bz);
// Gate A99-U118A A99-U118B
pullup(g99136);
assign #GATE_DELAY g99136 = rst ? 1'bz : ((0|STR210|STR19|STR311|STR412) ? 1'b0 : 1'bz);
// Gate A99-U123A
pullup(g99145);
assign #GATE_DELAY g99145 = rst ? 0 : ((0|g99146|g99142) ? 1'b0 : 1'bz);
// Gate A99-U106B
pullup(g99112);
assign #GATE_DELAY g99112 = rst ? 1'bz : ((0|STR14) ? 1'b0 : 1'bz);
// Gate A99-U220B
pullup(g99240);
assign #GATE_DELAY g99240 = rst ? 1'bz : ((0|g99217|A99RADDR3) ? 1'b0 : 1'bz);
// Gate A99-U112A
pullup(A99FADDR12);
assign #GATE_DELAY A99FADDR12 = rst ? 1'bz : ((0|g99126|g99124) ? 1'b0 : 1'bz);
// Gate A99-U226B
pullup(g99252);
assign #GATE_DELAY g99252 = rst ? 1'bz : ((0|g99225|A99RADDR5) ? 1'b0 : 1'bz);
// Gate A99-U103B
pullup(g99106);
assign #GATE_DELAY g99106 = rst ? 1'bz : ((0|ROPET) ? 1'b0 : 1'bz);
// Gate A99-U124B
pullup(A99QUARTERB);
assign #GATE_DELAY A99QUARTERB = rst ? 0 : ((0|g99147|A99CQB) ? 1'b0 : 1'bz);
// Gate A99-U137B
pullup(A99FADDR10);
assign #GATE_DELAY A99FADDR10 = rst ? 1'bz : ((0|STR19|STR311) ? 1'b0 : 1'bz);
// Gate A99-U232B
pullup(g99264);
assign #GATE_DELAY g99264 = rst ? 0 : ((0|g99248|g99251) ? 1'b0 : 1'bz);
// Gate A99-U101B
pullup(g99102);
assign #GATE_DELAY g99102 = rst ? 1'bz : ((0|ROPER) ? 1'b0 : 1'bz);
// Gate A99-U227B
pullup(g99254);
assign #GATE_DELAY g99254 = rst ? 1'bz : ((0|g99253|A99RADDR11) ? 1'b0 : 1'bz);
// Gate A99-U227A
pullup(g99253);
assign #GATE_DELAY g99253 = rst ? 0 : ((0|g99203|A99ES11_) ? 1'b0 : 1'bz);
// Gate A99-U236A
pullup(g99271);
assign #GATE_DELAY g99271 = rst ? 1'bz : ((0|g99272) ? 1'b0 : 1'bz);
// Gate A99-U218A
pullup(g99235);
assign #GATE_DELAY g99235 = rst ? 1'bz : ((0|A99RADDR2|g99208) ? 1'b0 : 1'bz);
// Gate A99-U231A
pullup(A99EDESTROY);
assign #GATE_DELAY A99EDESTROY = rst ? 0 : ((0|g99271|g99260) ? 1'b0 : 1'bz);
// Gate A99-U117B
pullup(g99134);
assign #GATE_DELAY g99134 = rst ? 0 : ((0|g99133|g99168) ? 1'b0 : 1'bz);
// Gate A99-U134B
pullup(g99168);
assign #GATE_DELAY g99168 = rst ? 1'bz : ((0|g99134|RESETC) ? 1'b0 : 1'bz);
// Gate A99-U206A A99-U206B
pullup(A99ES04_);
assign #GATE_DELAY A99ES04_ = rst ? 0 : ((0|XT3E|XT1E|XT5E|XT7E) ? 1'b0 : 1'bz);
// Gate A99-U136A
pullup(g99171);
assign #GATE_DELAY g99171 = rst ? 1'bz : ((0|g99172) ? 1'b0 : 1'bz);
// Gate A99-U126A
pullup(g99151);
assign #GATE_DELAY g99151 = rst ? 1'bz : ((0|RESETD) ? 1'b0 : 1'bz);
// Gate A99-U125B
pullup(g99150);
assign #GATE_DELAY g99150 = rst ? 0 : ((0|g99149|g99151) ? 1'b0 : 1'bz);
// Gate A99-U204A
pullup(A99RESETK);
assign #GATE_DELAY A99RESETK = rst ? 0 : ((0|ZID|RSTKY_|RSTKX_) ? 1'b0 : 1'bz);
// Gate A99-U127B
pullup(g99154);
assign #GATE_DELAY g99154 = rst ? 1'bz : ((0|CLROPE|g99127) ? 1'b0 : 1'bz);
// Gate A99-U125A
pullup(g99149);
assign #GATE_DELAY g99149 = rst ? 1'bz : ((0|SETCD) ? 1'b0 : 1'bz);
// Gate A99-U130B
pullup(g99160);
assign #GATE_DELAY g99160 = rst ? 0 : ((0|g99158) ? 1'b0 : 1'bz);
// Gate A99-U111A
pullup(g99121);
assign #GATE_DELAY g99121 = rst ? 0 : ((0|g99112|LOMOD|g99103) ? 1'b0 : 1'bz);
// Gate A99-U110B
pullup(g99120);
assign #GATE_DELAY g99120 = rst ? 0 : ((0|g99103|HIMOD|g99115) ? 1'b0 : 1'bz);
// Gate A99-U110A
pullup(g99119);
assign #GATE_DELAY g99119 = rst ? 0 : ((0|STR14|LOMOD|ROPES) ? 1'b0 : 1'bz);
// Gate A99-U207A A99-U207B
pullup(A99ES05_);
assign #GATE_DELAY A99ES05_ = rst ? 0 : ((0|XT3E|XT2E|XT6E|XT7E) ? 1'b0 : 1'bz);
// Gate A99-U136B
pullup(g99172);
assign #GATE_DELAY g99172 = rst ? 0 : ((0|g99170) ? 1'b0 : 1'bz);
// Gate A99-U237A
pullup(g99273);
assign #GATE_DELAY g99273 = rst ? 1'bz : ((0|g99274) ? 1'b0 : 1'bz);
// Gate A99-U219A
pullup(g99237);
assign #GATE_DELAY g99237 = rst ? 1'bz : ((0|A99RADDR8|g99236) ? 1'b0 : 1'bz);
// Gate A99-U236B
pullup(g99272);
assign #GATE_DELAY g99272 = rst ? 0 : ((0|g99273) ? 1'b0 : 1'bz);
// End of NOR gates
BUFFER A99_U3(
  g99234, g99234, GEM08, GEM09, 
  GEM10, GEM11, GEM12, GEM13, 
  GEM14, GEM16, SA08, SA09, 
  SA10, SA11, SA12, SA13, 
  SA14, SA16
);
BUFFER A99_U4(
  g99234, g99234, GEMP, GEM01, 
  GEM02, GEM03, GEM04, GEM05, 
  GEM06, GEM07, SAP, SA01, 
  SA02, SA03, SA04, SA05, 
  SA06, SA07
);
RAM A99_U2(
  1'b0, g99265, g99266, 1'b0, 
  1'b0, A99RADDR1, A99RADDR2, A99RADDR3, 
  A99RADDR4, A99RADDR5, A99RADDR6, A99RADDR7, 
  A99RADDR8, A99RADDR9, A99RADDR10, A99RADDR11, 
  1'b0, 1'b0, 1'b0, 1'b0, 
  1'b0, SA01, SA02, SA03, 
  SA04, SA05, SA06, SA07, 
  SA08, SA09, SA10, SA11, 
  SA12, SA13, SA14, SAP, 
  SA16
);
ROM A99_U1(
  g99136, g99139, 1'b1, A99FADDR1, 
  A99FADDR2, A99FADDR3, A99FADDR4, A99FADDR5, 
  A99FADDR6, A99FADDR7, A99FADDR8, A99FADDR9, 
  A99FADDR10, A99FADDR11, A99FADDR12, A99FADDR13, 
  A99FADDR14, A99FADDR15, A99FADDR16, 1'b0, 
  SA01, SA02, SA03, SA04, 
  SA05, SA06, SA07, SA08, 
  SA09, SA10, SA11, SA12, 
  SA13, SA14, SAP, SA16
);

endmodule
