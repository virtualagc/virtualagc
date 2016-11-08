/****************************************************************************
 * CLK - CLOCK subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: CLK.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "CLK.h"
#include "INP.h"
#include "OUT.h"
#include "MBF.h"
#include "ADR.h"
#include "SEQ.h"
#include "ALU.h"
#include "CRG.h"
#include "CTR.h"
#include "INT.h"
#include "PAR.h"
#include "TPG.h"
#include "SCL.h"
#include "MEM.h"
// A container for all registers. This is kept so we can iterate through
// all registers to execute the control pulses. For simulation purposes
// only; this has no counterpart in the hardware AGC.
reg* CLK::registerList[] = // registers are in no particular sequence
      { &INP::register_IN0, &INP::register_IN1, &INP::register_IN2,
          &INP::register_IN3, &OUT::register_OUT1, &OUT::register_OUT2,
          &OUT::register_OUT3, &OUT::register_OUT4, &MBF::register_G,
          &PAR::register_G15, &ADR::register_S, &ADR::register_BNK,
          &SEQ::register_SQ, &ALU::register_B, &CRG::register_Q,
          &CRG::register_Z, &CRG::register_LP, &CRG::register_A,
          &ALU::register_X, &ALU::register_Y, &ALU::register_U,
          &SEQ::register_STA, &SEQ::register_STB, &SEQ::register_SNI,
          &SEQ::register_LOOPCTR, &ALU::register_CI, &SEQ::register_BR1,
          &SEQ::register_BR2, &CTR::register_UpCELL, &CTR::register_DnCELL,
          &INT::register_RPCELL, &INT::register_INHINT1, &INT::register_INHINT,
          &PAR::register_P, &PAR::register_P2, &PAR::register_PALM,
          &TPG::register_SG, &SCL::register_SCL, &SCL::register_F17,
          &SCL::register_F13, &SCL::register_F10, 0 // zero is end-of-list flag
      };
void
CLK::clkAGC()
{
// Now that all the inputs are set up, clock the registers so the outputs
// can change state in accordance with the inputs.
  for (int i = 0; registerList[i]; i++)
    {
      registerList[i]->clk();
    }
}
void
execR_NOPULSE()
{
}
void
execR_RA0()
{
  CRG::execRP_RA0();
}
void
execR_RA1()
{
  CRG::execRP_RA1();
}
void
execR_RA2()
{
  CRG::execRP_RA2();
}
void
execR_RA3()
{
  CRG::execRP_RA3();
}
void
execR_RA4()
{
  INP::execRP_RA4();
}
void
execR_RA5()
{
  INP::execRP_RA5();
}
void
execR_RA6()
{
  INP::execRP_RA6();
}
void
execR_RA7()
{
  INP::execRP_RA7();
}
void
execR_RA11()
{
  OUT::execRP_RA11();
}
void
execR_RA12()
{
  OUT::execRP_RA12();
}
void
execR_RA13()
{
  OUT::execRP_RA13();
}
void
execR_RA14()
{
  OUT::execRP_RA14();
}
void
execR_RA()
{
  CRG::execRP_RA();
}
void
execR_RBK()
{
  ADR::execRP_RBK();
}
void
execR_RG()
{
  MBF::execRP_RG();
}
void
execR_RLP()
{
  CRG::execRP_RLP();
}
void
execR_RQ()
{
  CRG::execRP_RQ();
}
void
execR_RRPA()
{
  INT::execRP_RRPA();
}
void
execR_RSCT()
{
  CTR::execRP_RSCT();
}
void
execR_RZ()
{
  CRG::execRP_RZ();
}
void
execR_SBWG()
{
  MEM::execRP_SBWG();
}
void
execR_WE()
{
  MBF::execRP_WE();
  PAR::execRP_WE();
}
void
execR_ALU_RB()
{
  ALU::execRP_ALU_RB();
}
void
execR_ALU_RC()
{
  ALU::execRP_ALU_RC();
}
void
execR_ALU_RU()
{
  ALU::execRP_ALU_RU();
}
void
execR_ALU_OR_RSB()
{
  ALU::execRP_ALU_OR_RSB();
}
void
execR_ALU_OR_R1()
{
  ALU::execRP_ALU_OR_R1();
}
void
execR_ALU_OR_R1C()
{
  ALU::execRP_ALU_OR_R1C();
}
void
execR_ALU_OR_R2()
{
  ALU::execRP_ALU_OR_R2();
}
void
execR_ALU_OR_R22()
{
  ALU::execRP_ALU_OR_R22();
}
void
execR_ALU_OR_R24()
{
  ALU::execRP_ALU_OR_R24();
}
void
execR_ALU_OR_R2000()
{
  ALU::execRP_ALU_OR_R2000();
}
void
execR_ALU_OR_RB14()
{
  ALU::execRP_ALU_OR_RB14();
}
EXECTYPE execR[] =
  { execR_NOPULSE, // NO_PULSE,
      execR_NOPULSE, // CI, // Carry in
      execR_NOPULSE, // CLG, // Clear G
      execR_NOPULSE, // CLCTR, // Clear loop counter**
      execR_NOPULSE, // CTR, // Loop counter
      execR_NOPULSE, // GP, // Generate Parity
      execR_NOPULSE, // KRPT, // Knock down Rupt priority
      execR_NOPULSE, // NISQ, // New instruction to the SQ register
      execR_RA, // RA, // Read A
      execR_NOPULSE, // RB, // Read B
      execR_NOPULSE, // RB14, // Read bit 14
      execR_NOPULSE, // RC, // Read C
      execR_RG, // RG, // Read G
      execR_RLP, // RLP, // Read LP
      execR_NOPULSE, // RP2, // Read parity 2
      execR_RQ, // RQ, // Read Q
      execR_RRPA, // RRPA, // Read RUPT address
      execR_NOPULSE, // RSB, // Read sign bit
      execR_RSCT, // RSCT, // Read selected counter address
      execR_NOPULSE, // RU, // Read sum
      execR_RZ, // RZ, // Read Z
      execR_NOPULSE, // R1, // Read 1
      execR_NOPULSE, // R1C, // Read 1 complimented
      execR_NOPULSE, // R2, // Read 2
      execR_NOPULSE, // R22, // Read 22
      execR_NOPULSE, // R24, // Read 24
      execR_NOPULSE, // ST1, // Stage 1
      execR_NOPULSE, // ST2, // Stage 2
      execR_NOPULSE, // TMZ, // Test for minus zero
      execR_NOPULSE, // TOV, // Test for overflow
      execR_NOPULSE, // TP, // Test parity
      execR_NOPULSE, // TRSM, // Test for resume
      execR_NOPULSE, // TSGN, // Test sign
      execR_NOPULSE, // TSGN2, // Test sign 2
      execR_NOPULSE, // WA, // Write A
      execR_NOPULSE, // WALP, // Write A and LP
      execR_NOPULSE, // WB, // Write B
      execR_NOPULSE, // WGx, // Write G (do not reset)
      execR_NOPULSE, // WLP, // Write LP
      execR_NOPULSE, // WOVC, // Write overflow counter
      execR_NOPULSE, // WOVI, // Write overflow RUPT inhibit
      execR_NOPULSE, // WOVR, // Write overflow
      execR_NOPULSE, // WP, // Write P
      execR_NOPULSE, // WPx, // Write P (do not reset)
      execR_NOPULSE, // WP2, // Write P2
      execR_NOPULSE, // WQ, // Write Q
      execR_NOPULSE, // WS, // Write S
      execR_NOPULSE, // WX, // Write X
      execR_NOPULSE, // WY, // Write Y
      execR_NOPULSE, // WYx, // Write Y (do not reset)
      execR_NOPULSE, // WZ, // Write Z
      execR_NOPULSE, // RSC, // Read special and central
      execR_NOPULSE, // WSC, // Write special and central
      execR_NOPULSE, // WG, // Write G
      execR_NOPULSE, // SDV1, // Subsequence DV1 is active
      execR_NOPULSE, // SMP1, // Subsequence MP1 is active
      execR_NOPULSE, // SRSM3, // Subsequence RSM3 is active
      execR_RA0, // RA0, // Read register at address 0 (A)
      execR_RA1, // RA1, // Read register at address 1 (Q)
      execR_RA2, // RA2, // Read register at address 2 (Z)
      execR_RA3, // RA3, // Read register at address 3 (LP)
      execR_RA4, // RA4, // Read register at address 4
      execR_RA5, // RA5, // Read register at address 5
      execR_RA6, // RA6, // Read register at address 6
      execR_RA7, // RA7, // Read register at address 7
      execR_NOPULSE, // RA10, // Read register at address 10 (octal)
      execR_RA11, // RA11, // Read register at address 11 (octal)
      execR_RA12, // RA12, // Read register at address 12 (octal)
      execR_RA13, // RA13, // Read register at address 13 (octal)
      execR_RA14, // RA14, // Read register at address 14 (octal)
      execR_RBK, // RBK, // Read BNK
      execR_NOPULSE, // WA0, // Write register at address 0 (A)
      execR_NOPULSE, // WA1, // Write register at address 1 (Q)
      execR_NOPULSE, // WA2, // Write register at address 2 (Z)
      execR_NOPULSE, // WA3, // Write register at address 3 (LP)
      execR_NOPULSE, // WA10, // Write register at address 10 (octal)
      execR_NOPULSE, // WA11, // Write register at address 11 (octal)
      execR_NOPULSE, // WA12, // Write register at address 12 (octal)
      execR_NOPULSE, // WA13, // Write register at address 13 (octal)
      execR_NOPULSE, // WA14, // Write register at address 14 (octal)
      execR_NOPULSE, // WBK, // Write BNK
      execR_NOPULSE, // WGn, // Write G (normal gates)**
      execR_NOPULSE, // W20, // Write into CYR
      execR_NOPULSE, // W21, // Write into SR
      execR_NOPULSE, // W22, // Write into CYL
      execR_NOPULSE, // W23 // Write into SL
      execR_NOPULSE, // GENRST,// General Reset**
      execR_NOPULSE, // CLINH, // Clear INHINT**
      execR_NOPULSE, // CLINH1,// Clear INHINT1**
      execR_NOPULSE, // CLSTA, // Clear state counter A (STA)**
      execR_NOPULSE, // CLSTB, // Clear state counter B (STB)**
      execR_NOPULSE, // CLISQ, // Clear SNI**
      execR_NOPULSE, // CLRP, // Clear RPCELL**
      execR_NOPULSE, // INH, // Set INHINT**
      execR_NOPULSE, // RPT, // Read RUPT opcode **
      execR_SBWG, // SBWG, // Write G from memory
      execR_NOPULSE, // SETSTB,// Set the ST1 bit of STB
      execR_WE, // WE, // Write E-MEM from G
      execR_NOPULSE, // WPCTR, // Write PCTR (latch priority counter sequence)**
      execR_NOPULSE, // WSQ, // Write SQ
      execR_NOPULSE, // WSTB, // Write stage counter B (STB)**
      execR_NOPULSE, // R2000, // Read 2000 **
    };// 99
void
CLK::doexecR(int pulse)
{
  execR[pulse]();
}
EXECTYPE execR_ALU[] =
  { execR_NOPULSE, // NO_PULSE,
      execR_NOPULSE, // CI, // Carry in
      execR_NOPULSE, // CLG, // Clear G
      execR_NOPULSE, // CLCTR, // Clear loop counter**
      execR_NOPULSE, // CTR, // Loop counter
      execR_NOPULSE, // GP, // Generate Parity
      execR_NOPULSE, // KRPT, // Knock down Rupt priority
      execR_NOPULSE, // NISQ, // New instruction to the SQ register
      execR_NOPULSE, // RA, // Read A
      execR_ALU_RB, // RB, // Read B
      execR_NOPULSE, // RB14, // Read bit 14
      execR_ALU_RC, // RC, // Read C
      execR_NOPULSE, // RG, // Read G
      execR_NOPULSE, // RLP, // Read LP
      execR_NOPULSE, // RP2, // Read parity 2
      execR_NOPULSE, // RQ, // Read Q
      execR_NOPULSE, // RRPA, // Read RUPT address
      execR_NOPULSE, // RSB, // Read sign bit
      execR_NOPULSE, // RSCT, // Read selected counter address
      execR_ALU_RU, // RU, // Read sum
      execR_NOPULSE, // RZ, // Read Z
      execR_NOPULSE, // R1, // Read 1
      execR_NOPULSE, // R1C, // Read 1 complimented
      execR_NOPULSE, // R2, // Read 2
      execR_NOPULSE, // R22, // Read 22
      execR_NOPULSE, // R24, // Read 24
      execR_NOPULSE, // ST1, // Stage 1
      execR_NOPULSE, // ST2, // Stage 2
      execR_NOPULSE, // TMZ, // Test for minus zero
      execR_NOPULSE, // TOV, // Test for overflow
      execR_NOPULSE, // TP, // Test parity
      execR_NOPULSE, // TRSM, // Test for resume
      execR_NOPULSE, // TSGN, // Test sign
      execR_NOPULSE, // TSGN2, // Test sign 2
      execR_NOPULSE, // WA, // Write A
      execR_NOPULSE, // WALP, // Write A and LP
      execR_NOPULSE, // WB, // Write B
      execR_NOPULSE, // WGx, // Write G (do not reset)
      execR_NOPULSE, // WLP, // Write LP
      execR_NOPULSE, // WOVC, // Write overflow counter
      execR_NOPULSE, // WOVI, // Write overflow RUPT inhibit
      execR_NOPULSE, // WOVR, // Write overflow
      execR_NOPULSE, // WP, // Write P
      execR_NOPULSE, // WPx, // Write P (do not reset)
      execR_NOPULSE, // WP2, // Write P2
      execR_NOPULSE, // WQ, // Write Q
      execR_NOPULSE, // WS, // Write S
      execR_NOPULSE, // WX, // Write X
      execR_NOPULSE, // WY, // Write Y
      execR_NOPULSE, // WYx, // Write Y (do not reset)
      execR_NOPULSE, // WZ, // Write Z
      execR_NOPULSE, // RSC, // Read special and central
      execR_NOPULSE, // WSC, // Write special and central
      execR_NOPULSE, // WG, // Write G
      execR_NOPULSE, // SDV1, // Subsequence DV1 is active
      execR_NOPULSE, // SMP1, // Subsequence MP1 is active
      execR_NOPULSE, // SRSM3, // Subsequence RSM3 is active
      execR_NOPULSE, // RA0, // Read register at address 0 (A)
      execR_NOPULSE, // RA1, // Read register at address 1 (Q)
      execR_NOPULSE, // RA2, // Read register at address 2 (Z)
      execR_NOPULSE, // RA3, // Read register at address 3 (LP)
      execR_NOPULSE, // RA4, // Read register at address 4
      execR_NOPULSE, // RA5, // Read register at address 5
      execR_NOPULSE, // RA6, // Read register at address 6
      execR_NOPULSE, // RA7, // Read register at address 7
      execR_NOPULSE, // RA10, // Read register at address 10 (octal)
      execR_NOPULSE, // RA11, // Read register at address 11 (octal)
      execR_NOPULSE, // RA12, // Read register at address 12 (octal)
      execR_NOPULSE, // RA13, // Read register at address 13 (octal)
      execR_NOPULSE, // RA14, // Read register at address 14 (octal)
      execR_NOPULSE, // RBK, // Read BNK
      execR_NOPULSE, // WA0, // Write register at address 0 (A)
      execR_NOPULSE, // WA1, // Write register at address 1 (Q)
      execR_NOPULSE, // WA2, // Write register at address 2 (Z)
      execR_NOPULSE, // WA3, // Write register at address 3 (LP)
      execR_NOPULSE, // WA10, // Write register at address 10 (octal)
      execR_NOPULSE, // WA11, // Write register at address 11 (octal)
      execR_NOPULSE, // WA12, // Write register at address 12 (octal)
      execR_NOPULSE, // WA13, // Write register at address 13 (octal)
      execR_NOPULSE, // WA14, // Write register at address 14 (octal)
      execR_NOPULSE, // WBK, // Write BNK
      execR_NOPULSE, // WGn, // Write G (normal gates)**
      execR_NOPULSE, // W20, // Write into CYR
      execR_NOPULSE, // W21, // Write into SR
      execR_NOPULSE, // W22, // Write into CYL
      execR_NOPULSE, // W23 // Write into SL
      execR_NOPULSE, // GENRST,// General Reset**
      execR_NOPULSE, // CLINH, // Clear INHINT**
      execR_NOPULSE, // CLINH1,// Clear INHINT1**
      execR_NOPULSE, // CLSTA, // Clear state counter A (STA)**
      execR_NOPULSE, // CLSTB, // Clear state counter B (STB)**
      execR_NOPULSE, // CLISQ, // Clear SNI**
      execR_NOPULSE, // CLRP, // Clear RPCELL**
      execR_NOPULSE, // INH, // Set INHINT**
      execR_NOPULSE, // RPT, // Read RUPT opcode **
      execR_NOPULSE, // SBWG, // Write G from memory
      execR_NOPULSE, // SETSTB,// Set the ST1 bit of STB
      execR_NOPULSE, // WE, // Write E-MEM from G
      execR_NOPULSE, // WPCTR, // Write PCTR (latch priority counter sequence)**
      execR_NOPULSE, // WSQ, // Write SQ
      execR_NOPULSE, // WSTB, // Write stage counter B (STB)**
      execR_NOPULSE, // R2000, // Read 2000 **
    };
void
CLK::doexecR_ALU(int pulse)
{
  execR_ALU[pulse]();
}
EXECTYPE execR_ALU_OR[] =
  { execR_NOPULSE, // NO_PULSE,
      execR_NOPULSE, // CI, // Carry in
      execR_NOPULSE, // CLG, // Clear G
      execR_NOPULSE, // CLCTR, // Clear loop counter**
      execR_NOPULSE, // CTR, // Loop counter
      execR_NOPULSE, // GP, // Generate Parity
      execR_NOPULSE, // KRPT, // Knock down Rupt priority
      execR_NOPULSE, // NISQ, // New instruction to the SQ register
      execR_NOPULSE, // RA, // Read A
      execR_NOPULSE, // RB, // Read B
      execR_ALU_OR_RB14, // RB14, // Read bit 14
      execR_NOPULSE, // RC, // Read C
      execR_NOPULSE, // RG, // Read G
      execR_NOPULSE, // RLP, // Read LP
      execR_NOPULSE, // RP2, // Read parity 2
      execR_NOPULSE, // RQ, // Read Q
      execR_NOPULSE, // RRPA, // Read RUPT address
      execR_ALU_OR_RSB, // RSB, // Read sign bit
      execR_NOPULSE, // RSCT, // Read selected counter address
      execR_NOPULSE, // RU, // Read sum
      execR_NOPULSE, // RZ, // Read Z
      execR_ALU_OR_R1, // R1, // Read 1
      execR_ALU_OR_R1C, // R1C, // Read 1 complimented
      execR_ALU_OR_R2, // R2, // Read 2
      execR_ALU_OR_R22, // R22, // Read 22
      execR_ALU_OR_R24, // R24, // Read 24
      execR_NOPULSE, // ST1, // Stage 1
      execR_NOPULSE, // ST2, // Stage 2
      execR_NOPULSE, // TMZ, // Test for minus zero
      execR_NOPULSE, // TOV, // Test for overflow
      execR_NOPULSE, // TP, // Test parity
      execR_NOPULSE, // TRSM, // Test for resume
      execR_NOPULSE, // TSGN, // Test sign
      execR_NOPULSE, // TSGN2, // Test sign 2
      execR_NOPULSE, // WA, // Write A
      execR_NOPULSE, // WALP, // Write A and LP
      execR_NOPULSE, // WB, // Write B
      execR_NOPULSE, // WGx, // Write G (do not reset)
      execR_NOPULSE, // WLP, // Write LP
      execR_NOPULSE, // WOVC, // Write overflow counter
      execR_NOPULSE, // WOVI, // Write overflow RUPT inhibit
      execR_NOPULSE, // WOVR, // Write overflow
      execR_NOPULSE, // WP, // Write P
      execR_NOPULSE, // WPx, // Write P (do not reset)
      execR_NOPULSE, // WP2, // Write P2
      execR_NOPULSE, // WQ, // Write Q
      execR_NOPULSE, // WS, // Write S
      execR_NOPULSE, // WX, // Write X
      execR_NOPULSE, // WY, // Write Y
      execR_NOPULSE, // WYx, // Write Y (do not reset)
      execR_NOPULSE, // WZ, // Write Z
      execR_NOPULSE, // RSC, // Read special and central
      execR_NOPULSE, // WSC, // Write special and central
      execR_NOPULSE, // WG, // Write G
      execR_NOPULSE, // SDV1, // Subsequence DV1 is active
      execR_NOPULSE, // SMP1, // Subsequence MP1 is active
      execR_NOPULSE, // SRSM3, // Subsequence RSM3 is active
      execR_NOPULSE, // RA0, // Read register at address 0 (A)
      execR_NOPULSE, // RA1, // Read register at address 1 (Q)
      execR_NOPULSE, // RA2, // Read register at address 2 (Z)
      execR_NOPULSE, // RA3, // Read register at address 3 (LP)
      execR_NOPULSE, // RA4, // Read register at address 4
      execR_NOPULSE, // RA5, // Read register at address 5
      execR_NOPULSE, // RA6, // Read register at address 6
      execR_NOPULSE, // RA7, // Read register at address 7
      execR_NOPULSE, // RA10, // Read register at address 10 (octal)
      execR_NOPULSE, // RA11, // Read register at address 11 (octal)
      execR_NOPULSE, // RA12, // Read register at address 12 (octal)
      execR_NOPULSE, // RA13, // Read register at address 13 (octal)
      execR_NOPULSE, // RA14, // Read register at address 14 (octal)
      execR_NOPULSE, // RBK, // Read BNK
      execR_NOPULSE, // WA0, // Write register at address 0 (A)
      execR_NOPULSE, // WA1, // Write register at address 1 (Q)
      execR_NOPULSE, // WA2, // Write register at address 2 (Z)
      execR_NOPULSE, // WA3, // Write register at address 3 (LP)
      execR_NOPULSE, // WA10, // Write register at address 10 (octal)
      execR_NOPULSE, // WA11, // Write register at address 11 (octal)
      execR_NOPULSE, // WA12, // Write register at address 12 (octal)
      execR_NOPULSE, // WA13, // Write register at address 13 (octal)
      execR_NOPULSE, // WA14, // Write register at address 14 (octal)
      execR_NOPULSE, // WBK, // Write BNK
      execR_NOPULSE, // WGn, // Write G (normal gates)**
      execR_NOPULSE, // W20, // Write into CYR
      execR_NOPULSE, // W21, // Write into SR
      execR_NOPULSE, // W22, // Write into CYL
      execR_NOPULSE, // W23 // Write into SL
      execR_NOPULSE, // GENRST,// General Reset**
      execR_NOPULSE, // CLINH, // Clear INHINT**
      execR_NOPULSE, // CLINH1,// Clear INHINT1**
      execR_NOPULSE, // CLSTA, // Clear state counter A (STA)**
      execR_NOPULSE, // CLSTB, // Clear state counter B (STB)**
      execR_NOPULSE, // CLISQ, // Clear SNI**
      execR_NOPULSE, // CLRP, // Clear RPCELL**
      execR_NOPULSE, // INH, // Set INHINT**
      execR_NOPULSE, // RPT, // Read RUPT opcode **
      execR_NOPULSE, // SBWG, // Write G from memory
      execR_NOPULSE, // SETSTB,// Set the ST1 bit of STB
      execR_NOPULSE, // WE, // Write E-MEM from G
      execR_NOPULSE, // WPCTR, // Write PCTR (latch priority counter sequence)**
      execR_NOPULSE, // WSQ, // Write SQ
      execR_NOPULSE, // WSTB, // Write stage counter B (STB)**
      execR_ALU_OR_R2000, // R2000, // Read 2000 **
    };
void
CLK::doexecR_ALU_OR(int pulse)
{
  execR_ALU_OR[pulse]();
}
void
execW_NOPULSE()
{
}
void
execW_CI()
{
  ALU::execWP_CI();
}
void
execW_CLG()
{
  PAR::execWP_CLG();
}
void
execW_CLINH()
{
  INT::execWP_CLINH();
}
void
execW_CLINH1()
{
  INT::execWP_CLINH1();
}
void
execW_CLISQ()
{
  SEQ::execWP_CLISQ();
}
void
execW_CLCTR()
{
  SEQ::execWP_CLCTR();
}
void
execW_CLRP()
{
  INT::execWP_CLRP();
}
void
execW_CLSTA()
{
  SEQ::execWP_CLSTA();
}
void
execW_CLSTB()
{
  SEQ::execWP_CLSTB();
}
void
execW_CTR()
{
  SEQ::execWP_CTR();
}
void
execW_GENRST()
{
  SEQ::execWP_GENRST();
  MBF::execWP_GENRST();
  CRG::execWP_GENRST();
  PAR::execWP_GENRST();
  ALU::execWP_GENRST();
  CTR::execWP_GENRST();
  INT::execWP_GENRST();
  OUT::execWP_GENRST();
}
void
execW_GP()
{
  PAR::execWP_GP();
}
void
execW_INH()
{
  INT::execWP_INH();
}
void
execW_KRPT()
{
  INT::execWP_KRPT();
}
void
execW_NISQ()
{
  SEQ::execWP_NISQ();
}
void
execW_RPT()
{
  INT::execWP_RPT();
}
void
execW_RP2()
{
  PAR::execWP_RP2();
}
void
execW_SBWG()
{
  MBF::execWP_SBWG();
  PAR::execWP_SBWG();
}
void
execW_SETSTB()
{
  SEQ::execWP_SETSTB();
}
void
execW_ST1()
{
  SEQ::execWP_ST1();
}
void
execW_ST2()
{
  SEQ::execWP_ST2();
}
void
execW_TMZ()
{
  SEQ::execWP_TMZ();
}
void
execW_TOV()
{
  SEQ::execWP_TOV();
}
void
execW_TP()
{
  PAR::execWP_TP();
}
void
execW_TRSM()
{
  SEQ::execWP_TRSM();
}
void
execW_TSGN()
{
  SEQ::execWP_TSGN();
}
void
execW_TSGN2()
{
  SEQ::execWP_TSGN2();
}
void
execW_WA0()
{
  CRG::execWP_WA0();
}
void
execW_WA1()
{
  CRG::execWP_WA1();
}
void
execW_WA2()
{
  CRG::execWP_WA2();
}
void
execW_WA3()
{
  CRG::execWP_WA3();
}
void
execW_WA10()
{
  OUT::execWP_WA10();
}
void
execW_WA11()
{
  OUT::execWP_WA11();
}
void
execW_WA12()
{
  OUT::execWP_WA12();
}
void
execW_WA13()
{
  OUT::execWP_WA13();
}
void
execW_WA14()
{
  OUT::execWP_WA14();
}
void
execW_WA()
{
  CRG::execWP_WA();
}
void
execW_WALP()
{
  CRG::execWP_WALP();
}
void
execW_WB()
{
  ALU::execWP_WB();
}
void
execW_WBK()
{
  ADR::execWP_WBK();
}
void
execW_WE()
{
  MEM::execWP_WE();
}
void
execW_WGn()
{
  MBF::execWP_WGn();
}
void
execW_WGx()
{
  MBF::execWP_WGx();
  PAR::execWP_WGx();
}
void
execW_WLP()
{
  CRG::execWP_WLP();
}
void
execW_WOVC()
{
  CTR::execWP_WOVC();
}
void
execW_WOVI()
{
  INT::execWP_WOVI();
}
void
execW_WOVR()
{
  CTR::execWP_WOVR();
}
void
execW_WP()
{
  PAR::execWP_WP();
}
void
execW_WPx()
{
  PAR::execWP_WPx();
}
void
execW_WP2()
{
  PAR::execWP_WP2();
}
void
execW_WPCTR()
{
  CTR::execWP_WPCTR();
}
void
execW_WQ()
{
  CRG::execWP_WQ();
}
void
execW_WS()
{
  ADR::execWP_WS();
}
void
execW_WSQ()
{
  SEQ::execWP_WSQ();
}
void
execW_WSTB()
{
  SEQ::execWP_WSTB();
}
void
execW_WX()
{
  ALU::execWP_WX();
}
void
execW_WY()
{
  ALU::execWP_WY();
}
void
execW_WYx()
{
  ALU::execWP_WYx();
}
void
execW_WZ()
{
  CRG::execWP_WZ();
}
void
execW_W20()
{
  MBF::execWP_W20();
}
void
execW_W21()
{
  MBF::execWP_W21();
}
void
execW_W22()
{
  MBF::execWP_W22();
}
void
execW_W23()
{
  MBF::execWP_W23();
}
EXECTYPE execW[] =
  { execW_NOPULSE, // NO_PULSE,
      execW_CI, // CI, // Carry in
      execW_CLG, // CLG, // Clear G
      execW_CLCTR, // CLCTR, // Clear loop counter**
      execW_CTR, // CTR, // Loop counter
      execW_GP, // GP, // Generate Parity
      execW_KRPT, // KRPT, // Knock down Rupt priority
      execW_NISQ, // NISQ, // New instruction to the SQ register
      execW_NOPULSE, // RA, // Read A
      execW_NOPULSE, // RB, // Read B
      execW_NOPULSE, // RB14, // Read bit 14
      execW_NOPULSE, // RC, // Read C
      execW_NOPULSE, // RG, // Read G
      execW_NOPULSE, // RLP, // Read LP
      execW_RP2, // RP2, // Read parity 2
      execW_NOPULSE, // RQ, // Read Q
      execW_NOPULSE, // RRPA, // Read RUPT address
      execW_NOPULSE, // RSB, // Read sign bit
      execW_NOPULSE, // RSCT, // Read selected counter address
      execW_NOPULSE, // RU, // Read sum
      execW_NOPULSE, // RZ, // Read Z
      execW_NOPULSE, // R1, // Read 1
      execW_NOPULSE, // R1C, // Read 1 complimented
      execW_NOPULSE, // R2, // Read 2
      execW_NOPULSE, // R22, // Read 22
      execW_NOPULSE, // R24, // Read 24
      execW_ST1, // ST1, // Stage 1
      execW_ST2, // ST2, // Stage 2
      execW_TMZ, // TMZ, // Test for minus zero
      execW_TOV, // TOV, // Test for overflow
      execW_TP, // TP, // Test parity
      execW_TRSM, // TRSM, // Test for resume
      execW_TSGN, // TSGN, // Test sign
      execW_TSGN2, // TSGN2, // Test sign 2
      execW_WA, // WA, // Write A
      execW_WALP, // WALP, // Write A and LP
      execW_WB, // WB, // Write B
      execW_WGx, // WGx, // Write G (do not reset)
      execW_WLP, // WLP, // Write LP
      execW_WOVC, // WOVC, // Write overflow counter
      execW_WOVI, // WOVI, // Write overflow RUPT inhibit
      execW_WOVR, // WOVR, // Write overflow
      execW_WP, // WP, // Write P
      execW_WPx, // WPx, // Write P (do not reset)
      execW_WP2, // WP2, // Write P2
      execW_WQ, // WQ, // Write Q
      execW_WS, // WS, // Write S
      execW_WX, // WX, // Write X
      execW_WY, // WY, // Write Y
      execW_WYx, // WYx, // Write Y (do not reset)
      execW_WZ, // WZ, // Write Z
      execW_NOPULSE, // RSC, // Read special and central
      execW_NOPULSE, // WSC, // Write special and central
      execW_NOPULSE, // WG, // Write G
      execR_NOPULSE, // SDV1, // Subsequence DV1 is active
      execR_NOPULSE, // SMP1, // Subsequence MP1 is active
      execR_NOPULSE, // SRSM3, // Subsequence RSM3 is active
      execW_NOPULSE, // RA0, // Read register at address 0 (A)
      execW_NOPULSE, // RA1, // Read register at address 1 (Q)
      execW_NOPULSE, // RA2, // Read register at address 2 (Z)
      execW_NOPULSE, // RA3, // Read register at address 3 (LP)
      execW_NOPULSE, // RA4, // Read register at address 4
      execW_NOPULSE, // RA5, // Read register at address 5
      execW_NOPULSE, // RA6, // Read register at address 6
      execW_NOPULSE, // RA7, // Read register at address 7
      execW_NOPULSE, // RA10, // Read register at address 10 (octal)
      execW_NOPULSE, // RA11, // Read register at address 11 (octal)
      execW_NOPULSE, // RA12, // Read register at address 12 (octal)
      execW_NOPULSE, // RA13, // Read register at address 13 (octal)
      execW_NOPULSE, // RA14, // Read register at address 14 (octal)
      execW_NOPULSE, // RBK, // Read BNK
      execW_WA0, // WA0, // Write register at address 0 (A)
      execW_WA1, // WA1, // Write register at address 1 (Q)
      execW_WA2, // WA2, // Write register at address 2 (Z)
      execW_WA3, // WA3, // Write register at address 3 (LP)
      execW_WA10, // WA10, // Write register at address 10 (octal)
      execW_WA11, // WA11, // Write register at address 11 (octal)
      execW_WA12, // WA12, // Write register at address 12 (octal)
      execW_WA13, // WA13, // Write register at address 13 (octal)
      execW_WA14, // WA14, // Write register at address 14 (octal)
      execW_WBK, // WBK, // Write BNK
      execW_WGn, // WGn, // Write G (normal gates)**
      execW_W20, // W20, // Write into CYR
      execW_W21, // W21, // Write into SR
      execW_W22, // W22, // Write into CYL
      execW_W23, // W23 // Write into SL
      execW_GENRST, // GENRST,// General Reset**
      execW_CLINH, // CLINH, // Clear INHINT**
      execW_CLINH1, // CLINH1,// Clear INHINT1**
      execW_CLSTA, // CLSTA, // Clear state counter A (STA)**
      execW_CLSTB, // CLSTB, // Clear state counter B (STB)**
      execW_CLISQ, // CLISQ, // Clear SNI**
      execW_CLRP, // CLRP, // Clear RPCELL**
      execW_INH, // INH, // Set INHINT**
      execW_RPT, // RPT, // Read RUPT opcode **
      execW_SBWG, // SBWG, // Write G from memory
      execW_SETSTB, // SETSTB,// Set the ST1 bit of STB
      execW_WE, // WE, // Write E-MEM from G
      execW_WPCTR, // WPCTR, // Write PCTR (latch priority counter sequence)**
      execW_WSQ, // WSQ, // Write SQ
      execW_WSTB, // WSTB, // Write stage counter B (STB)**
      execW_NOPULSE, // R2000, // Read 2000 **
    };// 99
void
CLK::doexecW(int pulse)
{
  execW[pulse]();
}
