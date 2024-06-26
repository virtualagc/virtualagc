{
  // File:    guess42p.c
  // For:     GENERATExINTEGER_VALUED.c
  // Notes:   1. Page references are from IBM "ESA/390 Principles of
  //             Operation", SA22-7201-08, Ninth Edition, June 2003.
  //          2. Labels are of the form p%d_%d, where the 1st number
  //             indicates the leading patch number of the block, and
  //             the 2nd is the byte offset of the instruction within
  //             within the block.
  //          3. Known-problematic translations are marked with the
  //             string  "* * * F I X M E * * *" (without spaces).
  // History: 2024-06-25 RSB  Auto-generated by XCOM-I --guess-inlines.
  //          2024-06-29 RSB  Rework, rename from "guess" to "patch"

p42_0: ;
  // (42)          CALL INLINE("2B", 2, 2);                              /* SDR 2,2 */    
  // Type RR, p. 18-23:		SDR	2,2
  scratchd = FR[2] - FR[2];
  setCCd();
  FR[2] = scratchd;
  // Set FR[2] to 0.0.

p42_2: ;
  // (43)          CALL INLINE("2A", 0, 2 );                             /* ADR 0,2 */    
  // Type RR, p. 18-8:		ADR	0,2
  // The value in FR[0] will have been inherited from a preceding call to
  // `INTEGERIZABLE`, but it will be an unnormalized value, so this addition
  // (to 0.0) serves to normalize it.
  scratchd = FR[0] + FR[2];
  setCCd();
  FR[0] = scratchd;

p42_4: ;
  // (44)          CALL INLINE("58", 1, 0, FOR_DW);              /* L   1,DW  */          
  address360B = 1484;
  // Type RX, p. 7-7:		L	1,1484(0,0)
  GR[1] = COREWORD(address360B);

p42_8: ;
  // (45)         CALL INLINE("69", 0, 0, 1, 0);                        /* CD  0,0(0,1) */
  address360B = GR[1] + 0;
  // Type RX, p. 18-10:		CD	0,0(0,1)
  scratchd = FR[0];
  scratchd -= fromFloatIBM(COREWORD(address360B), COREWORD(address360B + 4));
  setCCd();

p42_12: ;
  // (46)          CALL INLINE("41", 3, 0, 0, 1);                        /* LA  3,1 */    
  address360B = 1;
  // Type RX, p. 7-78:		LA	3,1(0,0)
  GR[3] = address360B;
  // Note that this is setting the return value to 1.

p42_16: ;
  // (47)          CALL INLINE("05", 14, 0);                             /* BALR 14,0 */  
  // Type RR, p. 7-14:		BALR	14,0
  GR[14] = 18;
  /*
   * The XCOM-I framework measures addresses within the INLINE block from the
   * beginning of the block.
   * Note that while this is setting GR14 to p42_18, and GR14 holds the return
   * address upon entry to the procedure, this is not actually changing the
   * procedure's return address.  That's (presumably) saved in the 18-word
   * "save area" and will be restored upon the actual return.
   */

p42_18: ;
  // (48)         CALL INLINE("47", 8, 0, 14, 6);                       /* BC  8,6(,14) */
  address360B = GR[14] + 6;
  // Type RX, p. 7-17:		BC	8,6(0,14)
  // Note that this is just a roundabout way of saying "if (CC==0) goto p42_24"
  // that we need to use because C has no computed goto functionality aside
  // from this.
  mask360 = 8;
  if ((CC == 0 && (mask360 & 8) != 0) ||  (CC == 1 && (mask360 & 4) != 0) ||
      (CC == 2 && (mask360 & 2) != 0) || (CC == 3 && (mask360 & 1) != 0))
    switch (address360B) {
      case 0: goto p42_0;
      case 2: goto p42_2;
      case 4: goto p42_4;
      case 8: goto p42_8;
      case 12: goto p42_12;
      case 16: goto p42_16;
      case 18: goto p42_18;
      case 22: goto p42_22;
      case 24: goto p42_24;
      default: abend("Branch address must be an instruction offset within this block");
    }

p42_22: ;
  // (49)          RETURN INLINE("1B", 3, 3);                            /* SR  3,3 */    
  // Type RR, p. 7-127:		SR	3,3
  scratch = (int64_t) GR[3] - (int64_t) GR[3];
  setCC();
  GR[3] = (int32_t) scratch;
  // Note that this is setting the return value to 0.

p42_24: ;
  RETURN(GR[3]);
}
