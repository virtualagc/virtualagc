/****************************************************************************
 * SEQ - SEQUENCE GENERATOR subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: SEQ.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "SEQ.h"
#include "ADR.h"
#include "BUS.h"
regSNI SEQ::register_SNI; // select next intruction flag
cpType SEQ::glbl_cp[]; // current set of asserted control pulses (MAXPULSES)
regSQ SEQ::register_SQ; // instruction register
regSTA SEQ::register_STA; // stage counter A
regSTB SEQ::register_STB; // stage counter B
regBR1 SEQ::register_BR1; // branch register1
regBR2 SEQ::register_BR2; // branch register2
regCTR SEQ::register_LOOPCTR; // loop counter
subseq SEQ::glbl_subseq; // currently decoded instruction subsequence
const char* SEQ::instructionString[] =
  { "TC", "CCS", "INDEX", "XCH", "***", "***", "***", "***", "***", "MP", "DV",
      "SU", "CS", "TS", "AD", "MASK" };
const char* SEQ::cpTypeString[] =
  {  "NO_PULSE",
// OUTPUTS FROM SUBSYSTEM A
      "CI", "CLG", "CLCTR", "CTR", "GP", "KRPT", "NISQ", "RA", "RB", "RB14",
      "RC", "RG", "RLP", "RP2", "RQ", "RRPA", "RSB", "RSCT", "RU", "RZ", "R1",
      "R1C", "R2", "R22", "R24", "ST1", "ST2", "TMZ", "TOV", "TP", "TRSM",
      "TSGN", "TSGN2", "WA", "WALP", "WB", "WGx", "WLP", "WOVC", "WOVI", "WOVR",
      "WP", "WPx", "WP2", "WQ", "WS", "WX", "WY", "WYx", "WZ",
// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM B ONLY;
// NOT USED OUTSIDE CPM
//
      "RSC", "WSC", "WG",
// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM C ONLY;
// NOT USED OUTSIDE CPM
//
      "SDV1", "SMP1", "SRSM3",
// EXTERNAL OUTPUTS FROM SUBSYSTEM B
//
      "RA0", "RA1", "RA2", "RA3", "RA4", "RA5", "RA6", "RA7", "RA10", "RA11",
      "RA12", "RA13", "RA14", "RBK", "WA0", "WA1", "WA2", "WA3", "WA10", "WA11",
      "WA12", "WA13", "WA14", "WBK", "WGn", "W20", "W21", "W22", "W23",
// THESE ARE THE LEFTOVERS -- THEY'RE PROBABLY USED IN SUBSYSTEM C
//
      "GENRST", "CLINH", "CLINH1", "CLSTA", "CLSTB", "CLISQ", "CLRP", "INH",
      "RPT", "SBWG", "SETSTB", "WE", "WPCTR", "WSQ", "WSTB", "R2000" };
void
SEQ::execWP_GENRST()
{
  register_SQ.write(0);
  register_BR1.write(0);
  register_BR2.write(0);
  register_SNI.write(0);
  register_LOOPCTR.write(0);
  register_STA.write(0);
  register_STB.write(0);
}
void
SEQ::execWP_WSQ()
{
  register_SQ.write(BUS::glbl_WRITE_BUS >> 12);
}
void
SEQ::execWP_NISQ()
{
  register_SNI.writeField(1, 1, 1); // change to write(1)??
}
void
SEQ::execWP_CLISQ()
{
  register_SNI.writeField(1, 1, 0); // change to write(0)??
}
bool
SEQ::isAsserted(cpType pulse)
{
  for (unsigned i = 0; i < MAXPULSES; i++)
    if (glbl_cp[i] == pulse)
      return true;
  return false;
}
char*
SEQ::getControlPulses()
{
  static char buf[MAXPULSES * 6];
  strcpy(buf, "");
  for (unsigned i = 0; i < MAXPULSES && glbl_cp[i] != NO_PULSE; i++)
    {
      strcat(buf, cpTypeString[glbl_cp[i]]);
      strcat(buf, " ");
    }
//if(strcmp(buf,"") == 0) strcat(buf,"NONE");
  return buf;
}
int
SEQ::anyWZ()
{
  for (unsigned i = 0; i < MAXPULSES && glbl_cp[i] != NO_PULSE; i++)
    {
      if (glbl_cp[i] == WZ)
        return (1);
    }
  return (0);
}
void
SEQ::execWP_ST1()
{
  register_STA.writeField(1, 1, 1);
}
void
SEQ::execWP_ST2()
{
  register_STA.writeField(2, 2, 1);
}
void
SEQ::execWP_TRSM()
{
  if (ADR::EQU_25())
    register_STA.writeField(2, 2, 1);
}
void
SEQ::execWP_CLSTA()
{
  register_STA.writeField(2, 1, 0);
}
void
SEQ::execWP_WSTB()
{
  register_STB.write(SEQ::register_STA.read());
}
void
SEQ::execWP_CLSTB()
{
  register_STB.writeField(2, 1, 0);
}
void
SEQ::execWP_SETSTB()
{
  register_STB.writeField(2, 1, 1);
}
void
SEQ::execWP_TSGN()
{
// Set Branch 1 FF
// if sign bit is '1' (negative sign)
  if (BUS::glbl_WRITE_BUS & 0100000)
    register_BR1.write(1);
  else
    register_BR1.write(0);
}
void
SEQ::execWP_TOV()
{
// Set Branch 1 FF
// if negative overflow (sign==1; overflow==0)
  if ((BUS::glbl_WRITE_BUS & 0140000) == 0100000)
    register_BR1.write(1);
  else
    register_BR1.write(0);
// Set Branch 2 FF
// if positive overflow (sign==0; oveflow==1)
  if ((BUS::glbl_WRITE_BUS & 0140000) == 0040000)
    register_BR2.write(1);
  else
    register_BR2.write(0);
}
void
SEQ::execWP_TSGN2()
{
// Set Branch 2 FF
// if sign bit is '1' (negative sign)
  if (BUS::glbl_WRITE_BUS & 0100000)
    register_BR2.write(1);
  else
    register_BR2.write(0);
}
void
SEQ::execWP_TMZ()
{
// Set Branch 2 FF
// if minus zero
  if (BUS::glbl_WRITE_BUS == 0177777)
    register_BR2.write(1);
  else
    register_BR2.write(0);
}
void
SEQ::execWP_CTR()
{
  register_LOOPCTR.write(register_LOOPCTR.read() + 1);
}
void
SEQ::execWP_CLCTR()
{
  register_LOOPCTR.write(0);
}

