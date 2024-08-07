{
  // File:      patch5.c
  // For:       MOVE.c
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

p5_0: ;
  // (5)             CALL INLINE("58",2,0,INTO);      /* L 2,INTO                      */
  address360B = (mMOVExINTO) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	2,mMOVExINTO(0,0)
  detailedInlineBefore(5, "L	2,mMOVExINTO(0,0)");
  GR[2] = COREWORD(address360B);
  detailedInlineAfter();

p5_4: ;
  // (6)             CALL INLINE("58",3,0,FROM);      /* L 3,FROM                      */
  address360B = (mMOVExFROM) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	3,mMOVExFROM(0,0)
  detailedInlineBefore(6, "L	3,mMOVExFROM(0,0)");
  GR[3] = COREWORD(address360B);
  detailedInlineAfter();

p5_8: ;
  // (7)             CALL INLINE("D2",15,15,2,0,3,0); /* MVC 0(255,2),0(3)             */
  address360A = (GR[2] + 0) & 0xFFFFFF;
  address360B = (GR[3] + 0) & 0xFFFFFF;
  // Type SS, p. 7-83:		MVC	0(255,2),0(3)
  detailedInlineBefore(7, "MVC	0(255,2),0(3)");
  mvc(address360A, address360B, 255);
  detailedInlineAfter();

p5_14: ;
}
