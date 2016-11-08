/****************************************************************************
 * ADR - MEMORY ADDRESS subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: ADR.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Memory address for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef ADR_H
#define ADR_H
enum specialRegister
{ // octal addresses of special registers
  // Flip-Flop registers
  A_ADDR = 00,
  Q_ADDR = 01,
  Z_ADDR = 02,
  LP_ADDR = 03,
  IN0_ADDR = 04,
  IN1_ADDR = 05,
  IN2_ADDR = 06,
  IN3_ADDR = 07,
  OUT0_ADDR = 010,
  OUT1_ADDR = 011,
  OUT2_ADDR = 012,
  OUT3_ADDR = 013,
  OUT4_ADDR = 014,
  BANK_ADDR = 015,
  // No bits in these registers
  RELINT_ADDR = 016,
  INHINT_ADDR = 017,
  // In eraseable memory
  CYR_ADDR = 020,
  SR_ADDR = 021,
  CYL_ADDR = 022,
  SL_ADDR = 023,
  ZRUPT_ADDR = 024,
  BRUPT_ADDR = 025,
  ARUPT_ADDR = 026,
  QRUPT_ADDR = 027,
};
class regS : public reg
{
public:
  regS() :
      reg(12, "%04o")
  {
  }
};
class regBNK : public reg
{
public:
  regBNK() :
      reg(4, "%02o")
  {
  }
};
class ADR
{
  friend class MON;
  friend class MEM;
  friend class CLK;
  friend class CPM;
public:
  static void
  execWP_WS();
  static void
  execRP_RBK();
  static void
  execWP_WBK();
  static bool
  GTR_17(); // for MBF, CPM
  static bool
  GTR_27(); // for PAR
  static bool
  EQU_16(); // for CPM
  static bool
  EQU_17(); // for CPM
  static bool
  EQU_25(); // for SEQ
  static bool
  GTR_1777(); // for CPM
  static unsigned
  getEffectiveAddress();
private:
  static regS register_S; // address register
  static regBNK register_BNK; // bank register
  static unsigned
  bankDecoder();
  static unsigned conv_WBK[];
};
#endif
