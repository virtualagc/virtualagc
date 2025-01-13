{
  // File:      patch117.c
  // For:       HALMATuINITuCONSTxROUNDuSCALAR.c
  // Notes:     1. Page references are from IBM "ESA/390 Principles of
  //               Operation", SA22-7201-08, Ninth Edition, June 2003.
  //            2. Labels are of the form p%d_%d, where the 1st number
  //               indicates the leading patch number of the block, and
  //               the 2nd is the byte offset of the instruction within
  //               within the block.
  //            3. Known-problematic translations are marked with the
  //               string  "* * * F I X M E * * *" (without spaces).
  // History:   2024-07-17 RSB  Auto-generated by XCOM-I --guess=....
  //                            Inspected.

p117_0: ;
  // (117)          CALL INLINE("58",1,0,DWuAD);              /* L    1,DWuAD            */
  address360B = (mDWuAD) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	1,mDWuAD(0,0)
  detailedInlineBefore(117, "L	1,mDWuAD(0,0)");
  GR[1] = COREWORD(address360B);
  detailedInlineAfter();

p117_4: ;
  // (118)          CALL INLINE("2B",0,0);                    /* SDR  0,0                */
  // Type RR, p. 18-23:		SDR	0,0
  detailedInlineBefore(118, "SDR	0,0");
  scratchd = FR[0] - FR[0];
  setCCd();
  FR[0] = scratchd;
  detailedInlineAfter();

p117_6: ;
  // (119)          CALL INLINE("6A",0,0,1,0);                /* AD   0,0(0,1)           */
  address360B = (GR[1] + 0) & 0xFFFFFF;
  // Type RX, p. 18-8:		AD	0,0(0,1)
  detailedInlineBefore(119, "AD	0,0(0,1)");
  scratchd = FR[0];
  scratchd += fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));
  setCCd();
  FR[0] = scratchd;
  detailedInlineAfter();

p117_10: ;
  // (120)          CALL INLINE("60",0,0,1,0);                /* STD  0,0(0,1)           */
  address360B = (GR[1] + 0) & 0xFFFFFF;
  // Type RX, p. 9-11:		STD	0,0(0,1)
  detailedInlineBefore(120, "STD	0,0(0,1)");
  std(0, address360B);
  detailedInlineAfter();

p117_14: ;
}