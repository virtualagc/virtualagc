/****************************************************************************
 * CPM - CONTROL PULSE MATRIX subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: CPM.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "CPM.h"
#include "SEQ.h"
#include "MON.h"
#include "CTR.h"
#include "INT.h"
#include "ADR.h"
#include <stdlib.h>
char* CPM::subseqString[] =
  { "TC0", "CCS0", "CCS1", "NDX0", "NDX1", "RSM3", "XCH0", "CS0", "TS0", "AD0",
      "MASK0", "MP0", "MP1", "MP3", "DV0", "DV1", "SU0", "RUPT1", "RUPT3",
      "STD2", "PINC0", "MINC0", "SHINC0", "NO_SEQ" };
subseq
CPM::instructionSubsequenceDecoder(int counter_subseq, int SQ_field,
    int STB_field)
{
  // Combinational logic decodes instruction and the stage count
  // to get the instruction subsequence.
  static subseq decode[16][4] =
    {
      { TC0, RUPT1, STD2, RUPT3 }, // 00
          { CCS0, CCS1, NO_SEQ, NO_SEQ }, // 01
          { NDX0, NDX1, NO_SEQ, RSM3 }, // 02
          { XCH0, NO_SEQ, STD2, NO_SEQ }, // 03
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ }, // 04
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ }, // 05
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ }, // 06
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ }, // 07
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ }, // 10
          { MP0, MP1, NO_SEQ, MP3 }, // 11
          { DV0, DV1, STD2, NO_SEQ }, // 12
          { SU0, NO_SEQ, STD2, NO_SEQ }, // 13
          { CS0, NO_SEQ, STD2, NO_SEQ }, // 14
          { TS0, NO_SEQ, STD2, NO_SEQ }, // 15
          { AD0, NO_SEQ, STD2, NO_SEQ }, // 16
          { MASK0, NO_SEQ, STD2, NO_SEQ } // 17
    };
  if (counter_subseq == PINCSEL)
    return PINC0;
  else if (counter_subseq == MINCSEL)
    return MINC0;
  else
    return decode[SQ_field][STB_field];
}
void
CPM::clearControlPulses()
{
  for (unsigned i = 0; i < MAXPULSES; i++)
    SEQ::glbl_cp[i] = NO_PULSE;
}
void
CPM::assert(cpType* pulse)
{
  int j = 0;
  for (unsigned i = 0; i < MAXPULSES && j < MAX_IPULSES && pulse[j] != NO_PULSE;
      i++)
    {
      if (SEQ::glbl_cp[i] == NO_PULSE)
        {
          SEQ::glbl_cp[i] = pulse[j];
          j++;
        }
    }
}
void
CPM::assert(cpType pulse)
{
  for (unsigned i = 0; i < MAXPULSES; i++)
    {
      if (SEQ::glbl_cp[i] == NO_PULSE)
        {
          SEQ::glbl_cp[i] = pulse;
          break;
        }
    }
}
int CPM::EPROM1_8[];
int CPM::EPROM9_16[];
int CPM::EPROM17_24[];
int CPM::EPROM25_32[];
int CPM::EPROM33_40[];
int CPM::EPROM41_48[];
int CPM::EPROM49_56[];
void
CPM::readEPROM(char* fileName, int* eprom)
{
  cout << "Reading EPROM: " << fileName << endl;
  // Open the EPROM file.
  FILE* ifp = fopen(fileName, "r");
  if (!ifp)
    {
      perror("fopen failed for source file");
      exit(-1);
    }
  const int addressBytes = 3; // 24-bit address range
  const int sumCheckBytes = 1;
  char buf[4096];
  while (fgets(buf, 4096, ifp))
    {
      // process a record
      if (buf[0] != 'S')
        {
          cout << "Error reading start of EPROM record for: " << fileName
              << endl;
          exit(-1);
        }
      char tmp[256];
      strncpy(tmp, &buf[2], 2);
      tmp[2] = '\0';
      int totalByteCount = strtol(tmp, 0, 16);
      int mySumCheck = totalByteCount & 0xff;
      strncpy(tmp, &buf[4], 6);
      tmp[addressBytes * 2] = '\0';
      int address = strtol(tmp, 0, 16);
      mySumCheck = (mySumCheck + ((address & 0xff0000) >> 16)) % 256;
      mySumCheck = (mySumCheck + ((address & 0x00ff00) >> 8)) % 256;
      mySumCheck = (mySumCheck + ((address & 0x0000ff))) % 256;
      //cout << hex << totalByteCount << ", " << address << dec << endl;
      int dataBytes = totalByteCount - addressBytes - sumCheckBytes;
      int i = (addressBytes + 2) * 2; // index to 1st databyte char.
      for (int j = 0; j < dataBytes; j++)
        {
          // get a data byte
          strncpy(tmp, &buf[i], 2);
          tmp[2] = '\0';
          int data = strtol(tmp, 0, 16);
          //cout << hex << data << dec << endl;
          mySumCheck = (mySumCheck + data) % 256;
          // The H/W AGC needs negative logic in the EPROMS (0=asserted)
          // but this simulator needs positive logic, so we bit flip the word.
          //eprom[address] = data;
          eprom[address] = ((~data) & 0xff);
          address++;
          i += 2; // bump to next databyte char
        }
      strncpy(tmp, &buf[i], 2);
      tmp[2] = '\0';
      int sumCheck = strtol(tmp, 0, 16);
      if (sumCheck != ((~mySumCheck) & 0xff))
        {
          cout << "sumCheck failed; file: " << fileName << ", address: " << hex
              << address << ", sumCheck: " << sumCheck << ", mySumCheck: "
              << mySumCheck << dec << endl;
          exit(-1);
        }
    }
  fclose(ifp);
}
void
CPM::checkEPROM(int inval, int lowbit)
{
  for (int mask = 0x1; inval && mask != 0x100; mask = mask << 1)
    {
      if (inval & mask)
        assert((cpType) lowbit);
      lowbit++;
    }
}
// perform the CPM-A EPROM function using the EPROM files
void
CPM::getControlPulses_EPROM(int address)
{
  checkEPROM(EPROM1_8[address], 1);
  checkEPROM(EPROM9_16[address], 9);
  checkEPROM(EPROM17_24[address], 17);
  checkEPROM(EPROM25_32[address], 25);
  checkEPROM(EPROM33_40[address], 33);
  checkEPROM(EPROM41_48[address], 41);
  checkEPROM(EPROM49_56[address], 49);
}
void
CPM::get_CPM_A(int address)
{
  // Use the EPROM tables to get the CPM-A control pulses documented
  // in R-393.
  getControlPulses_EPROM(address);
  // Now add some additional control pulses implied, but not documented
  // in R-393.
  if (SEQ::register_LOOPCTR.read() == 6)
    {
      assert(ST2); // STA <- 2
      assert(CLCTR); // CTR <- 0
    }
  //*****************************************************************
  // Now that the EPROM tables are used for CPM-A, this function is only
  // used to display the instruction subsequence in MON.
  SEQ::glbl_subseq = CPM::instructionSubsequenceDecoder(CTR::getSubseq(),
      SEQ::register_SQ.read(), SEQ::register_STB.read());
  //*****************************************************************
  // These were in CPM-C, where the rest of the control signal assertions
  // related to their use still are, but were moved here because WB and RB
  // are part of the R-393 sequence tables. Check CPM-C to see how these
  // assertions fit in (the former use is commented out there).
  switch (TPG::register_SG.read())
    {
  case PWRON:
    assert(WB); // TC GOPROG copied to B (see CPM-C for related assertions)
    break;
  case TP12:
    if (SEQ::register_SNI.read() == 1)
      {
        if (!INT::IRQ())
          {
            // Normal instruction
            assert(RB); // SQ <- B (see CPM-C for related assertions)
          }
      }
    break;
  default:
    ;
    }
}
void
CPM::controlPulseMatrix()
{
  // Combination logic decodes time pulse, subsequence, branch register, and
  // "select next instruction" latch to get control pulses associated with
  // those states.
  // Get rid of any old control pulses.
  clearControlPulses();
  //*******************************************************************************
  // SUBSYSTEM A
  int SB2_field = 0;
  int SB1_field = 0;
  switch (CTR::getSubseq())
    {
  case PINCSEL:
    SB2_field = 0;
    SB1_field = 1;
    break;
  case MINCSEL:
    SB2_field = 1;
    SB1_field = 0;
    break;
  default:
    SB2_field = 0;
    SB1_field = 0;
    };
  int CPM_A_address = 0;
  CPM_A_address = (SB2_field << 13) | (SB1_field << 12)
      | (SEQ::register_SQ.read() << 8) | (SEQ::register_STB.read() << 6)
      | (TPG::register_SG.read() << 2) | (SEQ::register_BR1.read() << 1)
      | SEQ::register_BR2.read();
  // Construct address into CPM-A control pulse ROM:
  // Address bits (bit 1 is LSB)
  // 1: register BR2
  // 2: register BR1
  // 3-6: register SG (4)
  // 7,8: register STB (2)
  // 9-12: register SQ (4)
  // 13: STB_01 (from CTR: selects PINC, MINC, or none)
  // 14: STB_02 (from CTR: selects PINC, MINC, or none)
  get_CPM_A(CPM_A_address);
  //*******************************************************************************
  //*******************************************************************************
  // SUBSYSTEM B
  // NOTE: WG, RSC, WSC are generated by SUBSYSTEM A. Those 3 signals are only used
  // by SUBSYSTEM B; not anywhere else.
  // CONSIDER MOVING TO ADR **********************8
  if (SEQ::isAsserted(WG))
    {
      switch (ADR::register_S.read())
        {
      case 020:
        assert(W20);
        break;
      case 021:
        assert(W21);
        break;
      case 022:
        assert(W22);
        break;
      case 023:
        assert(W23);
        break;
      default:
        if (ADR::GTR_17())
          assert(WGn); // not a central register
        }
    }
  if (SEQ::isAsserted(RSC))
    {
      switch (ADR::register_S.read())
        {
      case 00:
        assert(RA0);
        break;
      case 01:
        assert(RA1);
        break;
      case 02:
        assert(RA2);
        break;
      case 03:
        assert(RA3);
        break;
      case 04:
        assert(RA4);
        break;
      case 05:
        assert(RA5);
        break;
      case 06:
        assert(RA6);
        break;
      case 07:
        assert(RA7);
        break;
      case 010:
        assert(RA10);
        break;
      case 011:
        assert(RA11);
        break;
      case 012:
        assert(RA12);
        break;
      case 013:
        assert(RA13);
        break;
      case 014:
        assert(RA14);
        break;
      case 015:
        assert(RBK);
        break;
      default:
        break; // 016, 017
        }
    }
  if (SEQ::isAsserted(WSC))
    switch (ADR::register_S.read())
      {
    case 00:
      assert(WA0);
      break;
    case 01:
      assert(WA1);
      break;
    case 02:
      assert(WA2);
      break;
    case 03:
      assert(WA3);
      break;
    case 010:
      assert(WA10);
      break;
    case 011:
      assert(WA11);
      break;
    case 012:
      assert(WA12);
      break;
    case 013:
      assert(WA13);
      break;
    case 014:
      assert(WA14);
      break;
    case 015:
      assert(WBK);
      break;
    default:
      break; // 016, 017
      }
//*******************************************************************************
//*******************************************************************************
// SUBSYSTEM C
  switch (TPG::register_SG.read())
    {
  case STBY:
    assert(GENRST);
    // inhibit all alarms
    // init "SQ" complex
    // clear branch registers
    // stage registers are not cleared; should they be?
    // zeroes are already gated onto bus when no read pulses are asserted.
    // to zero synchronous-clocked registers, assert write pulses here.
    // Level-triggered registers are zeroed by GENRST anded with CLK2.
    break;
  case PWRON:
    assert(R2000);
    //assert(WB); // TC GOPROG copied to B (implemented in CPM-A)
    break;
  case TP1:
    // Moved this from TP12 to TP1 because CLISQ was getting cleared in the
    // hardware AGC before TPG was clocked; therefore TPG was not seeing the
    // SNI indication.
    assert(CLISQ); // SNI <- 0
  case TP5:
    // EMEM must be available in G register by TP6
    if (ADR::GTR_17() && // not a central register
        !ADR::GTR_1777() && // not fixed memory
        !SEQ::isAsserted(SDV1) && // not a loop counter subseq
        !SEQ::isAsserted(SMP1))
      {
        assert(SBWG);
      }
    if (ADR::EQU_17())
      assert(INH); // INHINT (INDEX 017)
    if (ADR::EQU_16())
      assert(CLINH); // RELINT (INDEX 016)
    break;
  case TP6:
    // FMEM must be available in G register by TP7
    if ( ADR::GTR_1777() && // not eraseable  memory
    !SEQ::isAsserted(SDV1) &&// not a loop counter subseq
    !SEQ::isAsserted(SMP1))
      {
        assert(SBWG);
      }
    break;
  case TP11:
    // G register written to memory beginning at TP11; Memory updates are in
    // G by TP10 for all normal and extracode instructions, but the PINC, MINC,
    // and SHINC sequences write to G in TP10 because they need to update the
    // parity bit.
    if (ADR::GTR_17() && // not a central register
        !ADR::GTR_1777() && // not fixed memory
        !SEQ::isAsserted(SDV1) && // not a loop counter subseq
        !SEQ::isAsserted(SMP1))
      {
        assert(WE);
      }
    // Additional interrupts are inhibited during servicing of an interrupt;
    // Remove the inhibition when RESUME is executed (INDEX 025)
    if (SEQ::isAsserted(SRSM3))
      assert(CLRP);
    break;
  case TP12:
    // DISABLE INPUT CHANGE TO PRIORITY COUNTER (reenable after TP1)
    // Check the priority counters; service any waiting inputs on the next
    // memory cycle.
    assert(WPCTR);
    if (SEQ::register_SNI.read() == 1) // if SNI is set, get next instruction
      {
        if (INT::IRQ()) // if interrupt requested (see CPM-A for similar assertion)
          {
            // Interrupt: SQ <- 0 (the default RW bus state)
            assert(RPT); // latch interrupt vector
            assert(SETSTB); // STB <- 1
          }
        else
          {
            // Normal instruction
            //assert(RB); // SQ <- B (implemented in CPM-A)
            assert(CLSTB); // STB <- 0
          }
        assert(WSQ);
        assert(CLSTA); // STA <- 0
        // Remove inhibition of interrupts (if they were) AFTER the next
        instruction assert(CLINH1); // INHINT1 <- 0
      }
    else if (CTR::getSubseq() == NOPSEL) // if previous sequence was not a counter
      {
        // get next sequence for same instruction.
        assert(WSTB); // STB <- STA
        assert(CLSTA); // STA <- 0
      }
    //assert(CLISQ); // SNI <- 0 (moved to TP1)
    break;
  default:
    ;
    }
//*******************************************************************************
}
