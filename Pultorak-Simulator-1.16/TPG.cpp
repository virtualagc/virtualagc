/****************************************************************************
 * TPG - TIME PULSE GENERATOR subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: TPG.cpp
 *
 * NOTES: see header file.
 *
 *****************************************************************************
 */
#include "TPG.h"
#include "MON.h"
#include "SCL.h"
#include "SEQ.h"
#include "OUT.h"
char* TPG::tpTypestring[] = // must correspond to tpType enumerated type
      { "STBY", "PWRON", "TP1", "TP2", "TP3", "TP4", "TP5", "TP6", "TP7", "TP8",
          "TP9", "TP10", "TP11", "TP12", "SRLSE", "WAIT" };
regSG TPG::register_SG; // static member
void
TPG::doexecWP_TPG()
{
  unsigned mystate = register_SG.read();
  if (MON::PURST)
    mystate = STBY;
  else
    switch (mystate)
      {
    case STBY:
      if (!MON::PURST && ((!MON::FCLK) || SCL::F17x()))
        mystate = PWRON;
      break;
    case PWRON:
      if (((!MON::FCLK) || SCL::F13x()))
        mystate = TP1;
      break;
    case TP1:
      mystate = TP2;
      break;
    case TP2:
      mystate = TP3;
      break;
    case TP3:
      mystate = TP4;
      break;
    case TP4:
      mystate = TP5;
      break;
    case TP5:
      mystate = TP6;
      break;
    case TP6:
      mystate = TP7;
      break;
    case TP7:
      mystate = TP8;
      break;
    case TP8:
      mystate = TP9;
      break;
    case TP9:
      mystate = TP10;
      break;
    case TP10:
      mystate = TP11;
      break;
    case TP11:
      mystate = TP12;
      break;
    case TP12:
      if (SEQ::register_SNI.read() && OUT::register_OUT1.readField(8, 8)
          && MON::SA)
        mystate = STBY;
      // the next transition to TP1 is incompletely decoded; it works because
      // the transition to STBY has already been tested.
      else if ((MON::RUN) || (!SEQ::register_SNI.read() && MON::INST))
        mystate = TP1;
      else
        mystate = SRLSE;
      break;
    case SRLSE:
      if (!MON::STEP)
        mystate = WAIT;
      break;
    case WAIT:
      if (MON::STEP || MON::RUN)
        mystate = TP1;
      break;
    default:
      break;
      }
  register_SG.write(mystate);
}
