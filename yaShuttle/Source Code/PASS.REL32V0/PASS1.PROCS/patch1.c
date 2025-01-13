{
  // File:      patch1.c
  // For:       COMPACTIFY.c
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

p1_0: ;
  // (1)          CALL INLINE("58", 0, 0, LOWERuBOUND);
  address360B = (mCOMPACTIFYxLOWERuBOUND) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	0,mCOMPACTIFYxLOWERuBOUND(0,0)
  detailedInlineBefore(1, "L	0,mCOMPACTIFYxLOWERuBOUND(0,0)");
  GR[0] = COREWORD(address360B);
  detailedInlineAfter();

p1_4: ;
  // (2)          CALL INLINE("58", 2, 0, I);                                            
  address360B = (mCOMPACTIFYxI) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	2,mCOMPACTIFYxI(0,0)
  detailedInlineBefore(2, "L	2,mCOMPACTIFYxI(0,0)");
  GR[2] = COREWORD(address360B);
  detailedInlineAfter();

p1_8: ;
  // (3)          CALL INLINE("58", 4, 0, UPPERuBOUND);  /* CORETOP PASSED IN R4 */
  address360B = (mCOMPACTIFYxUPPERuBOUND) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	4,mCOMPACTIFYxUPPERuBOUND(0,0)
  detailedInlineBefore(3, "L	4,mCOMPACTIFYxUPPERuBOUND(0,0)");
  GR[4] = COREWORD(address360B);
  detailedInlineAfter();

p1_12: ;
  // (4)          CALL INLINE("58", 5, 0, K);                                            
  address360B = (mCOMPACTIFYxK) & 0xFFFFFF;
  // Type RX, p. 7-7:		L	5,mCOMPACTIFYxK(0,0)
  detailedInlineBefore(4, "L	5,mCOMPACTIFYxK(0,0)");
  GR[5] = COREWORD(address360B);
  detailedInlineAfter();

p1_16: ;
}