/****************************************************************************
 * MON - AGC MONITOR subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: MON.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * AGC Monitor for the Block 1 Apollo Guidance Computer prototype (AGC4).
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
#ifndef MON_H
#define MON_H
class MON
{
public:
  static void
  displayAGC();
  static char* MON::clkTypestring[];
  static unsigned PURST; // power up reset
  static unsigned RUN; // run/halt switch
  static unsigned STEP; // single step switch
  static unsigned INST; // instruction/sequence step select switch
  static unsigned FCLK; // clock mode (0=single (manual) clock, 1=continuous clock)
  static unsigned SA; // "standby allowed" SW;
  // 0=NO (full power), 1=YES (low power)
  static unsigned SCL_ENAB; // "scaler enabled" SW; 0=NO (scaler halted), 1=YES (scaler running)
};
#endif
