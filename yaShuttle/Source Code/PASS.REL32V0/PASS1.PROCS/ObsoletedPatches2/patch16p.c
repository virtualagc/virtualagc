{
  // File:      patch16p.c
  // For:       MOVE.c
  // Notes:     1. Page references are from IBM "ESA/390 Principles of
  //               Operation", SA22-7201-08, Ninth Edition, June 2003.
  //            2. Labels are of the form p%d_%d, where the 1st number
  //               indicates the leading patch number of the block, and
  //               the 2nd is the byte offset of the instruction within
  //               within the block.
  //            3. Known-problematic translations are marked with the
  //               string  "* * * F I X M E * * *" (without spaces).
  // History:   2024-06-26 RSB  Auto-generated by XCOM-I --guess-inlines.
  //                            Checked.

  // This is the target of an EX instruction, and not reachable in the C
  // translation.

p16_0: ;
  // (16)       CALL INLINE("D2",0,0,2,0,3,0);  /* MVC 0(0,2),0(3)                      */
  address360A = GR[2] + 0;
  address360B = GR[3] + 0;
  // Type SS, p. 7-83:		MVC	0(0,2),0(3)
  mvc(address360A, address360B, 0);

p16_6: ;
}