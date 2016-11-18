/****************************************************************************
 * SEQ - SEQUENCE GENERATOR subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: SEQ.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Sequence Generator for the Block 1 Apollo Guidance Computer prototype (AGC4).
 *
 * SOURCES:
 * Mostly based on information from "Logical Description for the Apollo
 * Guidance Computer (AGC4)", Albert Hopkins, Ramon Alonso, and Hugh
 * Blair-Smith, R-393, MIT Instrumentation Laboratory, 1963.
 *
 * NOTES:
 *
 *****************************************************************************
 */
#ifndef SEQ_H
#define SEQ_H
#include "reg.h"

// In Solaris, in sys/regset.h (which has nothing to do with us at all, but is
// indirectly included by stdlib.h), CS is already #defined.  We need to get
// rid of that definition.
#ifdef CS
#undef CS
#endif

#define MAXPULSES 15
#define MAX_IPULSES 5 // no more than 5 instruction-generated pulses active at any time
enum cpType
{ // **inferred; not defined in original R393 AGC4 spec.
  NO_PULSE = 0,
  /*
   * OUTPUTS FROM SUBSYSTEM A
   */
  CI = 1, // Carry in
  CLG = 2, // Clear G
  CLCTR = 3, // Clear loop counter
  CTR = 4, // Loop counter
  GP = 5, // Generate Parity
  KRPT = 6, // Knock down Rupt priority
  NISQ = 7, // New instruction to the SQ register
  RA = 8, // Read A
  RB = 9, // Read B
  RB14 = 10, // Read bit 14
  RC = 11, // Read C
  RG = 12, // Read G
  RLP = 13, // Read LP
  RP2 = 14, // Read parity 2
  RQ = 15, // Read Q
  RRPA = 16, // Read RUPT address
  RSB = 17, // Read sign bit
  RSCT = 18, // Read selected counter address
  RU = 19, // Read sum
  RZ = 20, // Read Z
  R1 = 21, // Read 1
  R1C = 22, // Read 1 complimented
  R2 = 23, // Read 2
  R22 = 24, // Read 22
  R24 = 25, // Read 24
  ST1 = 26, // Stage 1
  ST2 = 27, // Stage 2
  TMZ = 28, // Test for minus zero
  TOV = 29, // Test for overflow
  TP = 30, // Test parity
  TRSM = 31, // Test for resume
  TSGN = 32, // Test sign
  TSGN2 = 33, // Test sign 2
  WA = 34, // Write A
  WALP = 35, // Write A and LP
  WB = 36, // Write B
  WGx = 37, // Write G (do not reset)
  WLP = 38, // Write LP
  WOVC = 39, // Write overflow counter
  WOVI = 40, // Write overflow RUPT inhibit
  WOVR = 41, // Write overflow
  WP = 42, // Write P
  WPx = 43, // Write P (do not reset)
  WP2 = 44, // Write P2
  WQ = 45, // Write Q
  WS = 46, // Write S
  WX = 47, // Write X
  WY = 48, // Write Y
  WYx = 49, // Write Y (do not reset)
  WZ = 50, // Write Z
  /*
   * OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM B ONLY;
   * NOT USED OUTSIDE CPM
   */
  RSC = 51, // Read special and central (output to B only, not outside CPM)
  WSC = 52, // Write special and central (output to B only, not outside CPM)
  WG = 53, // Write G (output to B only, not outside CPM)
  /*
   * OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM C ONLY;
   * NOT USED OUTSIDE CPM
   */
  SDV1 = 54, // Subsequence DV1 is currently active
  SMP1 = 55, // Subsequence MP1 is currently active
  SRSM3 = 56, // Subsequence RSM3 is currently active
  /*
   * EXTERNAL OUTPUTS FROM SUBSYSTEM B
   */
  RA0 = 57, // Read register at address 0 (A)
  RA1 = 58, // Read register at address 1 (Q)
  RA2 = 59, // Read register at address 2 (Z)
  RA3 = 60, // Read register at address 3 (LP)
  RA4 = 61, // Read register at address 4
  RA5 = 62, // Read register at address 5
  RA6 = 63, // Read register at address 6
  RA7 = 64, // Read register at address 7
  RA10 = 65, // Read register at address 10 (octal)
  RA11 = 66, // Read register at address 11 (octal)
  RA12 = 67, // Read register at address 12 (octal)
  RA13 = 68, // Read register at address 13 (octal)
  RA14 = 69, // Read register at address 14 (octal)
  RBK = 70, // Read BNK
  WA0 = 71, // Write register at address 0 (A)
  WA1 = 72, // Write register at address 1 (Q)
  WA2 = 73, // Write register at address 2 (Z)
  WA3 = 74, // Write register at address 3 (LP)
  WA10 = 75, // Write register at address 10 (octal)
  WA11 = 76, // Write register at address 11 (octal)
  WA12 = 77, // Write register at address 12 (octal)
  WA13 = 78, // Write register at address 13 (octal)
  WA14 = 79, // Write register at address 14 (octal)
  WBK = 80, // Write BNK
  WGn = 81, // Write G (normal gates)**
  W20 = 82, // Write into CYR
  W21 = 83, // Write into SR
  W22 = 84, // Write into CYL
  W23 = 85, // Write into SL
  /*
   * THESE ARE THE LEFTOVERS -- THEY'RE PROBABLY USED IN SUBSYSTEM C
   */
  GENRST = 86, // General Reset**
  CLINH = 87, // Clear INHINT**
  CLINH1 = 88, // Clear INHINT1**
  CLSTA = 89, // Clear state counter A (STA)**
  CLSTB = 90, // Clear state counter B (STB)**
  CLISQ = 91, // Clear SNI**
  CLRP = 92, // Clear RPCELL**
  INH = 93, // Set INHINT**
  RPT = 94, // Read RUPT opcode **
  SBWG = 95, // Write G from memory
  SETSTB = 96, // Set the ST1 bit of STB
  WE = 97, // Write E-MEM from G
  WPCTR = 98, // Write PCTR (latch priority counter sequence)**
  WSQ = 99, // Write SQ
  WSTB = 100, // Write stage counter B (STB)**
  R2000 = 101 // Read 2000 **
};
// INSTRUCTIONS
// Op Codes, as they appear in the SQ register.
enum instruction
{
  /*
   * The code in the SQ register is the same as the op code for these
   * four instructions.
   */
  TC = 00, // 00 TC K Transfer Control 1 MCT
  CCS = 01, // 01 CCS K Count, Compare, and Skip 2 MCT
  INDEX = 02, // 02 INDEX K 2 MCT
  XCH = 03, // 03 XCH K Exchange 2 MCT
  /*
   * The SQ register code is the op code + 010 (octal). This happens because all
   * of these instructions have bit 15 set (the sign (SG) bit) while in memory. When the
   * instruction is copied from memory to the memory buffer register (G) to register
   * B, the SG bit moves from bit 15 to bit 16 and the sign is copied back into bit
   * 15 (US). Therefore, the CS op code (04) becomes (14), and so on.
   */
  CS = 014, // 04 CS K Clear and Subtract 2 MCT
  TS = 015, // 05 TS K Transfer to Storage 2 MCT
  AD = 016, // 06 AD K Add 2 or 3 MCT
  MASK = 017, // 07 MASK K Bitwise AND 2 MCT
  /*
   * These are extended instructions. They are accessed by executing an INDEX 5777
   * before each instruction. By convention, address 5777 contains 47777. The INDEX
   * instruction adds 47777 to the extended instruction to form the SQ op code. For
   * example, the INDEX adds 4 to the 4 op code for MP to produce the 11 (octal; the
   * addition generates an end-around-carry). SQ register code (the 7777 part is a
   * negative zero).
   */
  MP = 011, // 04 MP K Multiply 10 MCT
  DV = 012, // 05 DV K Divide 18 MCT
  SU = 013 // 06 SU K Subtract 4 or 5 MCT
};
enum subseq
{
  TC0 = 0,
  CCS0 = 1,
  CCS1 = 2,
  NDX0 = 3,
  NDX1 = 4,
  RSM3 = 5,
  XCH0 = 6,
  CS0 = 7,
  TS0 = 8,
  AD0 = 9,
  MASK0 = 10,
  MP0 = 11,
  MP1 = 12,
  MP3 = 13,
  DV0 = 14,
  DV1 = 15,
  SU0 = 16,
  RUPT1 = 17,
  RUPT3 = 18,
  STD2 = 19,
  PINC0 = 20,
  MINC0 = 21,
  SHINC0 = 22,
  NO_SEQ = 23
};
enum scType
{ // identifies subsequence for a given instruction
  SUB0 = 0, // ST2=0, ST1=0
  SUB1 = 1, // ST2=0, ST1=1
  SUB2 = 2, // ST2=1, ST1=0
  SUB3 = 3 // ST2=1, ST1=1
};
enum brType
{
  BR00 = 0, // BR1=0, BR2=0
  BR01 = 1, // BR1=0, BR2=1
  BR10 = 2, // BR1=1, BR2=0
  BR11 = 3, // BR1=1, BR2=1
  NO_BR = 4 // NO BRANCH
};
const int GOPROG = 02000; // bottom address of fixed memory
class regSQ : public reg
{
public:
  regSQ() :
      reg(4, "%02o")
  {
  }
};
class regSTA : public reg
{
public:
  regSTA() :
      reg(2, "%01o")
  {
  }
};
class regSTB : public reg
{
public:
  regSTB() :
      reg(2, "%01o")
  {
  }
};
class regBR1 : public reg
{
public:
  regBR1() :
      reg(1, "%01o")
  {
  }
};
class regBR2 : public reg
{
public:
  regBR2() :
      reg(1, "%01o")
  {
  }
};
class regCTR : public reg
{
public:
  regCTR() :
      reg(3, "%01o")
  {
  }
};
class regSNI : public reg
{
public:
  regSNI() :
      reg(1, "%01o")
  {
  }
};
class SEQ
{
public:
  static int
  anyWZ();
  static void
  execWP_GENRST();
  static void
  execWP_WSQ();
  static void
  execWP_NISQ();
  static void
  execWP_CLISQ();
  static void
  execWP_ST1();
  static void
  execWP_ST2();
  static void
  execWP_TRSM();
  static void
  execWP_CLSTA();
  static void
  execWP_WSTB();
  static void
  execWP_CLSTB();
  static void
  execWP_SETSTB();
  static void
  execWP_TSGN();
  static void
  execWP_TOV();
  static void
  execWP_TMZ();
  static void
  execWP_TSGN2();
  static void
  execWP_CTR();
  static void
  execWP_CLCTR();
  static regSNI register_SNI; // select next intruction flag
  static cpType glbl_cp[MAXPULSES]; // current set of asserted control pulses (MAXPULSES)
  static const char* cpTypeString[]; // Test the currently asserted control pulses; return true if the specified
// control pulse is active.
  static bool
  isAsserted(cpType pulse);
// Return a string containing the names of all asserted control pulses.
  static char*
  getControlPulses();
  static subseq glbl_subseq; // currently decoded instruction subsequence
  static regSQ register_SQ; // instruction register
  static regSTA register_STA; // stage counter A
  static regSTB register_STB; // stage counter B
  static regBR1 register_BR1; // branch register1
  static regBR2 register_BR2; // branch register2
  static regCTR register_LOOPCTR; // loop counter
  static const char* instructionString[];
};
#endif
