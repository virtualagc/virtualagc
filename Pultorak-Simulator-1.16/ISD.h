/****************************************************************************
 * ISD - INSTRUCTION SUBSEQUENCE DECODER subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: ISD.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * Instruction Subsequence Decoder for the Block 1 Apollo Guidance Computer
 * prototype (AGC4).
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
#ifndef ISD_H
#define ISD_H
#include "SEQ.h"
#include "CTR.h"
// INSTRUCTION SUBSEQUENCE DECODER
#ifdef NOTDEF
class ISD
  {
  public:
    static subseq instructionSubsequenceDecoder();
    static char* ISD::subseqString[];
  };
#endif
#endif
