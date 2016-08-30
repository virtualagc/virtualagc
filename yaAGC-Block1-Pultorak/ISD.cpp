/****************************************************************************
 * ISD - INSTRUCTION SUBSEQUENCE DECODER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: ISD.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "ISD.h"
#ifdef NOTDEF
char* ISD::subseqString[] =
  {
    "TC0",
    "CCS0",
    "CCS1",
    "NDX0",
    "NDX1",
    "RSM3",
    "XCH0",
    "CS0",
    "TS0",
    "AD0",
    "MASK0",
    "MP0",
    "MP1",
    "MP3",
    "DV0",
    "DV1",
    "SU0",
    "RUPT1",
    "RUPT3",
    "STD2",
    "PINC0",
    "MINC0",
    "SHINC0",
    "NO_SEQ"
  };
subseq ISD::instructionSubsequenceDecoder()
  {
// Combinational logic decodes instruction and the stage count
// to get the instruction subsequence.
    static subseq decode[16][4] =
      {
          { TC0, RUPT1, STD2, RUPT3}, // 00
          { CCS0, CCS1, NO_SEQ, NO_SEQ}, // 01
          { NDX0, NDX1, NO_SEQ, RSM3}, // 02
          { XCH0, NO_SEQ, STD2, NO_SEQ}, // 03
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ}, // 04
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ}, // 05
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ}, // 06
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ}, // 07
          { NO_SEQ, NO_SEQ, NO_SEQ, NO_SEQ}, // 10
          { MP0, MP1, NO_SEQ, MP3}, // 11
          { DV0, DV1, STD2, NO_SEQ}, // 12
          { SU0, NO_SEQ, STD2, NO_SEQ}, // 13
          { CS0, NO_SEQ, STD2, NO_SEQ}, // 14
          { TS0, NO_SEQ, STD2, NO_SEQ}, // 15
          { AD0, NO_SEQ, STD2, NO_SEQ}, // 16
          { MASK0, NO_SEQ, STD2, NO_SEQ} // 17
      };
    switch(CTR::getSubseq())
      {
        case PINCSEL: return PINC0;
        case MINCSEL: return MINC0;
        default: return decode[SEQ::register_SQ.read()][SEQ::register_STB.read()];
      }
  }
#endif
