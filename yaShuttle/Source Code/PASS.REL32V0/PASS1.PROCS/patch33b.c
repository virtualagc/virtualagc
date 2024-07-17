{
  // File:      patch33b.c
  // For:       MAKE_FIXED_LIT.c
  // Notes:     1. Page references are from IBM "ESA/390 Principles of
  //               Operation", SA22-7201-08, Ninth Edition, June 2003.
  //            2. Labels are of the form p%d_%d, where the 1st number
  //               indicates the leading patch number of the block, and
  //               the 2nd is the byte offset of the instruction within
  //               within the block.
  //            3. Known-problematic translations are marked with the
  //               string  "* * * F I X M E * * *" (without spaces).
  // History:   2024-07-17 RSB  Auto-generated by XCOM-I --guess-inlines.
  //                            Inspected.

p33_0: ;
  // (33)       CALL INLINE("58",3,0,DW_AD);             /*  L    3,DW_AD            */   
  address360B = (33700) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	3,33700(0,0)
  detailedInlineBefore(33, "L	3,33700(0,0)");
  GR[3] = COREWORD(address360B);
  detailedInlineAfter();

p33_4: ;
  // (34)       CALL INLINE("68",0,0,3,0);               /*  LD   0,0(0,3)           */   
  address360B = (GR[3] + 0) & 0xFFFFFF;
  // Type RX, p. 9-10:		LD	0,0(0,3)
  detailedInlineBefore(34, "LD	0,0(0,3)");
  FR[0] = fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));
  detailedInlineAfter();

p33_8: ;
  // (35)       CALL INLINE("20", 0, 0);                            /* LPDR 0,0         */
  // Type RR, p. 18-17:		LPDR	0,0
  detailedInlineBefore(35, "LPDR	0,0");
  scratchd = fabs(FR[0]);
  setCCd();
  FR[0] = scratchd;
  detailedInlineAfter();

p33_10: ;
  // (36)       CALL INLINE("58", 1, 0, ADDR_ROUNDER);/* L   1,ADDR_ROUNDER         */    
  address360B = (2196) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	1,2196(0,0)
  detailedInlineBefore(36, "L	1,2196(0,0)");
  GR[1] = COREWORD(address360B);
  detailedInlineAfter();

p33_14: ;
  // (37)       CALL INLINE("6A", 0, 0, 1, 0);        /* AD  0,0(0,1)               */    
  address360B = (GR[1] + 0) & 0xFFFFFF;
  // Type RX, p. 18-8:		AD	0,0(0,1)
  detailedInlineBefore(37, "AD	0,0(0,1)");
  scratchd = FR[0];
  scratchd += fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));
  setCCd();
  FR[0] = scratchd;
  detailedInlineAfter();

p33_18: ;
  // (38)       CALL INLINE("58", 1, 0, ADDR_FIXED_LIMIT);/* L 1,ADDR_FIXED_LIMIT   */    
  address360B = (2192) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	1,2192(0,0)
  detailedInlineBefore(38, "L	1,2192(0,0)");
  GR[1] = COREWORD(address360B);
  detailedInlineAfter();

p33_22: ;
  // (39)       CALL INLINE("58",2,0,PTR);                   /*   L   2,  PTR   */        
  address360B = (56552) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	2,56552(0,0)
  detailedInlineBefore(39, "L	2,56552(0,0)");
  GR[2] = COREWORD(address360B);
  detailedInlineAfter();

p33_26: ;
  // (40)       CALL INLINE("69", 0, 0, 1, 0);        /* CD  0,0(0,1)               */    
  address360B = (GR[1] + 0) & 0xFFFFFF;
  // Type RX, p. 18-10:		CD	0,0(0,1)
  detailedInlineBefore(40, "CD	0,0(0,1)");
  scratchd = FR[0];
  scratchd -= fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));
  setCCd();
  detailedInlineAfter();

p33_30: ;
  // (41)       CALL INLINE("07",12,2);                  /*  BNHR 2                  */   
  // Type RR, p. 7-17:		BCR	12,2
  detailedInlineBefore(41, "BCR	12,2");
  mask360 = 12;
  if ((CC == 0 && (mask360 & 8) != 0) || (CC == 1 && (mask360 & 4) != 0) || (CC == 2 && (mask360 & 2) != 0) || (CC == 3 && (mask360 & 1) != 0))
    switch (GR[2]) {
      case -1: goto LIMIT_OK;
      default: abend("Branch address must be a label in this procedure");
    }
  detailedInlineAfter();

p33_32: ;
  // (42)       CALL INLINE("68",0,0,1,0);               /*  LD   0,0(0,1)           */   
  address360B = (GR[1] + 0) & 0xFFFFFF;
  // Type RX, p. 9-10:		LD	0,0(0,1)
  detailedInlineBefore(42, "LD	0,0(0,1)");
  FR[0] = fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));
  detailedInlineAfter();

p33_36: ;
}
