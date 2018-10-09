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

input wand rst, GEM01, GEM02, GEM03, GEM04, GEM05, GEM06, GEM07, GEM08, GEM09,
  GEM10, GEM11, GEM12, GEM13, GEM14, GEM16, GEMP, IL01, IL02, IL03, IL04,
  IL05, IL06, IL07, RESETD, REX, REY, RSTKX_, RSTKY_, SBE, SBF, SETAB, SETCD,
  SETEK, STR412, WEX, WEY, XB1E, XB2E, XB4E, XB6E, XT1E, XT2E, XT4E, XT5E,
  YB1E, YB2E, YT1E, YT2E, YT4E;

inout wand CLROPE, HIMOD, LOMOD, RESETA, RESETB, RESETC, ROPER, ROPES, ROPET,
  SA01, SA02, SA03, SA04, SA05, SA06, SA07, SA08, SA09, SA10, SA11, SA12,
  SA13, SA14, SA16, SAP, STR14, STR19, STR210, STR311, STR58, STR912, XB3E,
  XB5E, XB7E, XT3E, XT6E, XT7E, YB3E, YT3E, YT5E, YT6E, YT7E, ZID;

// Gate A99-U120B
assign #0.2  A99NOROPE = rst ? 1 : !(0|ROPER|ROPES|ROPET);
// Gate A99-U216A
assign #0.2  g99231 = rst ? 1 : !(0|A99RADDR7|g99230);
// Gate A99-U214B
assign #0.2  g99228 = rst ? 0 : !(0|A99ES06_|g99203);
// Gate A99-U218B
assign #0.2  g99236 = rst ? 0 : !(0|A99ES08_|g99203);
// Gate A99-U124A
assign #0.2  g99147 = rst ? 1 : !(0|A99QUARTERB|g99145);
// Gate A99-U117A
assign #0.2  g99133 = rst ? 0 : !(0|g99171|RESETC);
// Gate A99-U116B
assign #0.2  g99132 = rst ? 1 : !(0|CLROPE|g99133);
// Gate A99-U205A A99-U205B
assign #0.2  A99ES03_ = rst ? 1 : !(0|XB5E|XB4E|XB6E|XB7E);
// Gate A99-U131B
assign #0.2  g99162 = rst ? 1 : !(0|g99131|RESETB);
// Gate A99-U116A
assign #0.2  g99131 = rst ? 0 : !(0|g99162|g99130);
// Gate A99-U230B
assign #0.2  g99260 = rst ? 0 : !(0|g99259);
// Gate A99-U222B
assign #0.2  A99RADDR9 = rst ? 0 : !(0|g99242|A99RESETK);
// Gate A99-U220A
assign #0.2  A99RADDR8 = rst ? 0 : !(0|A99RESETK|g99237);
// Gate A99-U222A
assign #0.2  A99RADDR3 = rst ? 0 : !(0|A99RESETK|g99240);
// Gate A99-U201A A99-U201B
assign #0.2  A99ES01_ = rst ? 0 : !(0|XB3E|XB1E|XB5E|XB7E);
// Gate A99-U221B
assign #0.2  g99242 = rst ? 1 : !(0|g99241|A99RADDR9);
// Gate A99-U217A
assign #0.2  A99RADDR7 = rst ? 0 : !(0|A99RESETK|g99231);
// Gate A99-U229B
assign #0.2  A99RADDR6 = rst ? 0 : !(0|g99257|A99RESETK);
// Gate A99-U228A
assign #0.2  A99RADDR5 = rst ? 0 : !(0|A99RESETK|g99252);
// Gate A99-U225A
assign #0.2  A99RADDR4 = rst ? 0 : !(0|A99RESETK|g99245);
// Gate A99-U211A A99-U211B
assign #0.2  A99ES09_ = rst ? 0 : !(0|YT3E|YT1E|YT5E|YT7E);
// Gate A99-U132B
assign #0.2  g99164 = rst ? 1 : !(0|g99163);
// Gate A99-U209A
assign #0.2  g99217 = rst ? 0 : !(0|g99203|A99ES03_);
// Gate A99-U132A
assign #0.2  g99163 = rst ? 0 : !(0|g99162);
// Gate A99-U107B
assign #0.2  g99114 = rst ? 0 : !(0|g99102|HIMOD);
// Gate A99-U237B
assign #0.2  g99274 = rst ? 0 : !(0|g99270);
// Gate A99-U223B
assign #0.2  g99246 = rst ? 0 : !(0|A99ES10_|g99203);
// Gate A99-U135B
assign #0.2  g99170 = rst ? 1 : !(0|g99169);
// Gate A99-U107A
assign #0.2  g99113 = rst ? 0 : !(0|g99112|LOMOD|ROPET);
// Gate A99-U223A
assign #0.2  g99245 = rst ? 1 : !(0|A99RADDR4|g99219);
// Gate A99-U135A
assign #0.2  g99169 = rst ? 0 : !(0|g99168);
// Gate A99-U203A A99-U203B
assign #0.2  A99ES02_ = rst ? 1 : !(0|XB3E|XB2E|XB6E|XB7E);
// Gate A99-U112B
assign #0.2  g99124 = rst ? 0 : !(0|HIMOD|STR58);
// Gate A99-U113B
assign #0.2  g99126 = rst ? 1 : !(0|LOMOD|g99125);
// Gate A99-U224A
assign #0.2  g99247 = rst ? 1 : !(0|A99RADDR10|g99246);
// Gate A99-U108A
assign #0.2  g99115 = rst ? 1 : !(0|STR912);
// Gate A99-U224B
assign #0.2  g99248 = rst ? 1 : !(0|WEX);
// Gate A99-U133B
assign #0.2  g99166 = rst ? 0 : !(0|g99164);
// Gate A99-U103A
assign #0.2  g99105 = rst ? 1 : !(0|STR14|LOMOD|ROPES);
// Gate A99-U102A
assign #0.2  g99103 = rst ? 1 : !(0|ROPES);
// Gate A99-U115A
assign #0.2  g99129 = rst ? 1 : !(0|g99130|CLROPE);
// Gate A99-U226A
assign #0.2  g99251 = rst ? 1 : !(0|WEY);
// Gate A99-U115B
assign #0.2  g99130 = rst ? 0 : !(0|RESETB|g99165);
// Gate A99-U210A
assign #0.2  g99219 = rst ? 0 : !(0|g99203|A99ES04_);
// Gate A99-U212A A99-U212B
assign #0.2  A99ES10_ = rst ? 1 : !(0|YT3E|YT2E|YT6E|YT7E);
// Gate A99-U133A
assign #0.2  g99165 = rst ? 1 : !(0|g99166);
// Gate A99-U119B
assign #0.2  g99138 = rst ? 0 : !(0|g99137|A99NOROPE);
// Gate A99-U119A
assign #0.2  g99137 = rst ? 1 : !(0|SBF);
// Gate A99-U229A
assign #0.2  g99257 = rst ? 1 : !(0|A99RADDR6|g99228);
// Gate A99-U141B
assign #0.2  A99FADDR2 = rst ? 0 : !(0|IL02);
// Gate A99-U128B
assign #0.2  g99156 = rst ? 1 : !(0|g99128|RESETA);
// Gate A99-U114B
assign #0.2  g99128 = rst ? 0 : !(0|g99127|g99156);
// Gate A99-U114A
assign #0.2  g99127 = rst ? 0 : !(0|g99159|RESETA);
// Gate A99-U130A
assign #0.2  g99159 = rst ? 1 : !(0|g99160);
// Gate A99-U215B
assign #0.2  g99230 = rst ? 0 : !(0|A99ES07_|g99203);
// Gate A99-U221A
assign #0.2  g99241 = rst ? 0 : !(0|g99203|A99ES09_);
// Gate A99-U215A
assign #0.2  g99229 = rst ? 1 : !(0|A99RADDR1|g99204);
// Gate A99-U121B
assign #0.2  g99142 = rst ? 1 : !(0|SETAB);
// Gate A99-U111B
assign #0.2  g99122 = rst ? 0 : !(0|g99142|g99141);
// Gate A99-U121A
assign #0.2  g99141 = rst ? 1 : !(0|RESETB);
// Gate A99-U122A
assign #0.2  g99143 = rst ? 1 : !(0|A99QUARTERA|g99122);
// Gate A99-U217B
assign #0.2  g99234 = rst ? 1 : !(0|ZID);
// Gate A99-U113A
assign #0.2  g99125 = rst ? 0 : !(0|STR58);
// Gate A99-U213A
assign #0.2  g99225 = rst ? 0 : !(0|g99203|A99ES05_);
// Gate A99-U230A
assign #0.2  g99259 = rst ? 1 : !(0|REY|REX);
// Gate A99-U219B
assign #0.2  A99RADDR2 = rst ? 0 : !(0|g99235|A99RESETK);
// Gate A99-U233A
assign #0.2  g99265 = rst ? 1 : !(0|A99EDESTROY|g99264);
// Gate A99-U216B
assign #0.2  A99RADDR1 = rst ? 0 : !(0|g99229|A99RESETK);
// Gate A99-U210B
assign #0.2  A99ES08_ = rst ? 0 : !(0|YB2E|YB3E);
// Gate A99-U202B
assign #0.2  g99204 = rst ? 0 : !(0|A99ES01_|g99203);
// Gate A99-U134A
assign #0.2  A99CQC = rst ? 0 : !(0|g99132);
// Gate A99-U131A
assign #0.2  A99CQB = rst ? 0 : !(0|g99129);
// Gate A99-U128A
assign #0.2  A99CQA = rst ? 0 : !(0|g99154);
// Gate A99-U202A
assign #0.2  g99203 = rst ? 1 : !(0|SETEK);
// Gate A99-U208A A99-U208B
assign #0.2  A99ES06_ = rst ? 1 : !(0|XT5E|XT4E|XT6E|XT7E);
// Gate A99-U228B
assign #0.2  A99RADDR11 = rst ? 0 : !(0|g99254|A99RESETK);
// Gate A99-U225B
assign #0.2  A99RADDR10 = rst ? 0 : !(0|g99247|A99RESETK);
// Gate A99-U129A
assign #0.2  g99157 = rst ? 0 : !(0|g99156);
// Gate A99-U138A
assign #0.2  A99FADDR9 = rst ? 1 : !(0|A99QUARTERA|A99QUARTERB);
// Gate A99-U138B
assign #0.2  A99FADDR8 = rst ? 1 : !(0|A99QUARTERA|A99QUARTERC);
// Gate A99-U139A
assign #0.2  A99FADDR7 = rst ? 0 : !(0|IL07);
// Gate A99-U139B
assign #0.2  A99FADDR6 = rst ? 0 : !(0|IL06);
// Gate A99-U140A
assign #0.2  A99FADDR5 = rst ? 0 : !(0|IL05);
// Gate A99-U140B
assign #0.2  A99FADDR4 = rst ? 0 : !(0|IL04);
// Gate A99-U141A
assign #0.2  A99FADDR3 = rst ? 0 : !(0|IL03);
// Gate A99-U129B
assign #0.2  g99158 = rst ? 1 : !(0|g99157);
// Gate A99-U142A
assign #0.2  A99FADDR1 = rst ? 1 : !(0|IL01);
// Gate A99-U104A
assign #0.2  g99107 = rst ? 0 : !(0|STR912|HIMOD|ROPET);
// Gate A99-U126B
assign #0.2  g99152 = rst ? 1 : !(0|g99150|A99QUARTERC);
// Gate A99-U105B
assign #0.2  g99110 = rst ? 0 : !(0|g99103|g99115);
// Gate A99-U106A
assign #0.2  g99111 = rst ? 1 : !(0|STR14|LOMOD|ROPER);
// Gate A99-U213B A99-U214A
assign #0.2  A99ES11_ = rst ? 1 : !(0|YT6E|YT7E|YT5E|YT4E);
// Gate A99-U101A
assign #0.2  A99FADDR16 = rst ? 0 : !(0|STR14|LOMOD|g99106);
// Gate A99-U102B
assign #0.2  A99FADDR15 = rst ? 0 : !(0|ROPER|g99105|g99107);
// Gate A99-U105A A99-U104B
assign #0.2  A99FADDR14 = rst ? 0 : !(0|g99114|g99113|g99110|g99111);
// Gate A99-U109A A99-U109B
assign #0.2  A99FADDR13 = rst ? 0 : !(0|g99119|g99116|g99120|g99121);
// Gate A99-U122B
assign #0.2  A99QUARTERA = rst ? 0 : !(0|g99143|A99CQA);
// Gate A99-U137A
assign #0.2  A99FADDR11 = rst ? 1 : !(0|STR19|STR210);
// Gate A99-U127A
assign #0.2  A99QUARTERC = rst ? 0 : !(0|A99CQC|g99152);
// Gate A99-U233B
assign #0.2  g99266 = rst ? 1 : !(0|SBE);
// Gate A99-U234B
assign #0.2  g99268 = rst ? 1 : !(0|g99267);
// Gate A99-U232A
assign #0.2  g99263 = rst ? 1 : !(0|g99260|g99262);
// Gate A99-U231B
assign #0.2  g99262 = rst ? 0 : !(0|A99EDESTROY|g99263);
// Gate A99-U234A
assign #0.2  g99267 = rst ? 0 : !(0|g99263);
// Gate A99-U120A
assign #0.2  g99139 = rst ? 1 : !(0|g99138);
// Gate A99-U204B
assign #0.2  g99208 = rst ? 0 : !(0|A99ES02_|g99203);
// Gate A99-U209B
assign #0.2  A99ES07_ = rst ? 1 : !(0|YB1E|YB3E);
// Gate A99-U235A
assign #0.2  g99269 = rst ? 0 : !(0|g99268);
// Gate A99-U108B
assign #0.2  g99116 = rst ? 0 : !(0|ROPES|HIMOD|STR912);
// Gate A99-U123B
assign #0.2  g99146 = rst ? 1 : !(0|RESETA);
// Gate A99-U235B
assign #0.2  g99270 = rst ? 1 : !(0|g99269);
// Gate A99-U118A A99-U118B
assign #0.2  g99136 = rst ? 1 : !(0|STR210|STR19|STR311|STR412);
// Gate A99-U123A
assign #0.2  g99145 = rst ? 0 : !(0|g99146|g99142);
// Gate A99-U106B
assign #0.2  g99112 = rst ? 1 : !(0|STR14);
// Gate A99-U220B
assign #0.2  g99240 = rst ? 1 : !(0|g99217|A99RADDR3);
// Gate A99-U112A
assign #0.2  A99FADDR12 = rst ? 0 : !(0|g99126|g99124);
// Gate A99-U226B
assign #0.2  g99252 = rst ? 1 : !(0|g99225|A99RADDR5);
// Gate A99-U103B
assign #0.2  g99106 = rst ? 1 : !(0|ROPET);
// Gate A99-U124B
assign #0.2  A99QUARTERB = rst ? 0 : !(0|g99147|A99CQB);
// Gate A99-U137B
assign #0.2  A99FADDR10 = rst ? 1 : !(0|STR19|STR311);
// Gate A99-U232B
assign #0.2  g99264 = rst ? 0 : !(0|g99248|g99251);
// Gate A99-U101B
assign #0.2  g99102 = rst ? 1 : !(0|ROPER);
// Gate A99-U227B
assign #0.2  g99254 = rst ? 1 : !(0|g99253|A99RADDR11);
// Gate A99-U227A
assign #0.2  g99253 = rst ? 0 : !(0|g99203|A99ES11_);
// Gate A99-U236A
assign #0.2  g99271 = rst ? 1 : !(0|g99272);
// Gate A99-U218A
assign #0.2  g99235 = rst ? 1 : !(0|A99RADDR2|g99208);
// Gate A99-U231A
assign #0.2  A99EDESTROY = rst ? 0 : !(0|g99271|g99260);
// Gate A99-U117B
assign #0.2  g99134 = rst ? 0 : !(0|g99133|g99168);
// Gate A99-U134B
assign #0.2  g99168 = rst ? 1 : !(0|g99134|RESETC);
// Gate A99-U206A A99-U206B
assign #0.2  A99ES04_ = rst ? 1 : !(0|XT3E|XT1E|XT5E|XT7E);
// Gate A99-U136A
assign #0.2  g99171 = rst ? 1 : !(0|g99172);
// Gate A99-U126A
assign #0.2  g99151 = rst ? 1 : !(0|RESETD);
// Gate A99-U125B
assign #0.2  g99150 = rst ? 0 : !(0|g99149|g99151);
// Gate A99-U204A
assign #0.2  A99RESETK = rst ? 0 : !(0|ZID|RSTKY_|RSTKX_);
// Gate A99-U127B
assign #0.2  g99154 = rst ? 1 : !(0|CLROPE|g99127);
// Gate A99-U125A
assign #0.2  g99149 = rst ? 1 : !(0|SETCD);
// Gate A99-U130B
assign #0.2  g99160 = rst ? 0 : !(0|g99158);
// Gate A99-U111A
assign #0.2  g99121 = rst ? 0 : !(0|g99112|LOMOD|g99103);
// Gate A99-U110B
assign #0.2  g99120 = rst ? 0 : !(0|g99103|HIMOD|g99115);
// Gate A99-U110A
assign #0.2  g99119 = rst ? 1 : !(0|STR14|LOMOD|ROPES);
// Gate A99-U207A A99-U207B
assign #0.2  A99ES05_ = rst ? 1 : !(0|XT3E|XT2E|XT6E|XT7E);
// Gate A99-U136B
assign #0.2  g99172 = rst ? 0 : !(0|g99170);
// Gate A99-U237A
assign #0.2  g99273 = rst ? 1 : !(0|g99274);
// Gate A99-U219A
assign #0.2  g99237 = rst ? 1 : !(0|A99RADDR8|g99236);
// Gate A99-U236B
assign #0.2  g99272 = rst ? 0 : !(0|g99273);
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
