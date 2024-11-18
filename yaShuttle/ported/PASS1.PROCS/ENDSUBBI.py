#!/usr/bin/env python3
"""
   Access:     Public Domain, no restrictions believed to exist.
   Filename:   ENDSUBBI.py
   Purpose:    This is a part of the HAL/S-FC compiler program.
   Reference:  "HAL/S Compiler Functional Specification", section 2.1.2.
   Contact:    The Virtual AGC Project (www.ibiblio.org/apollo).
   History:    2024-06-05 RSB  Ported to XPL
"""

from xplBuiltins import *
import g
import HALINCL.CERRDECL as d
import HALINCL.COMMON as h
from ERROR import ERROR
from HALMATFI import HALMAT_FIX_PIPp
from HALMATPI import HALMAT_PIP
from HALMATTU import HALMAT_TUPLE
from REDUCESU import REDUCE_SUBSCRIPT
from SETUPVAC import SETUP_VAC
'''
from ARITHLIT import ARITH_LITERAL
from GETFCNPA import GET_FCN_PARM
from HALMATBA import HALMAT_BACKUP
from HALMATPO import HALMAT_POP
from HALMATXN import HALMAT_XNOP
from MATCHSIM import MATCH_SIMPLES
from RESETARR import RESET_ARRAYNESS
from HALINCL.SAVELITE import SAVE_LITERAL
'''

'''
 /***************************************************************************/
 /* PROCEDURE NAME:  END_SUBBIT_FCN                                         */
 /* MEMBER NAME:     ENDSUBBI                                               */
 /* INPUT PARAMETERS:                                                       */
 /*          T                 BIT(16)                                      */
 /* EXTERNAL VARIABLES REFERENCED:                                          */
 /*          BIT_LENGTH_LIM                                                 */
 /*          BIT_TYPE                                                       */
 /*          CLASS_QX                                                       */
 /*          CLASS_SR                                                       */
 /*          INT_TYPE                                                       */
 /*          LAST_POPp                                                      */
 /*          LOC_P                                                          */
 /*          MP                                                             */
 /*          MPP1                                                           */
 /*          PSEUDO_FORM                                                    */
 /*          PTR                                                            */
 /*          STRING_MASK                                                    */
 /*          VAL_P                                                          */
 /*          XBTOQ                                                          */
 /* EXTERNAL VARIABLES CHANGED:                                             */
 /*          FIXL                                                           */
 /*          FIX_DIM                                                        */
 /*          FIXV                                                           */
 /*          IND_LINK                                                       */
 /*          INX                                                            */
 /*          NEXT_SUB                                                       */
 /*          PSEUDO_LENGTH                                                  */
 /*          PSEUDO_TYPE                                                    */
 /*          PTR_TOP                                                        */
 /*          TEMP                                                           */
 /*          VAR                                                            */
 /* EXTERNAL PROCEDURES CALLED:                                             */
 /*          ERROR                                                          */
 /*          HALMAT_FIX_PIP#                                                */
 /*          HALMAT_PIP                                                     */
 /*          HALMAT_TUPLE                                                   */
 /*          REDUCE_SUBSCRIPT                                               */
 /*          SETUP_VAC                                                      */
 /* CALLED BY:                                                              */
 /*          SYNTHESIZE                                                     */
 /***************************************************************************/
'''


def END_SUBBIT_FCN(T = 0):
    # No locals. T is BIT(16) and defaults to 0.
    
      g.TEMP = g.PTR[g.MPP1];
      if (g.VAL_P[g.TEMP] != -1) and (SHR(g.VAL_P[g.TEMP],8) & 1) != 0:
          ERROR(d.CLASS_QX,9);
      g.NEXT_SUB = g.PTR[g.MP];
      if (SHL(1,g.PSEUDO_TYPE[g.TEMP]) & g.STRING_MASK) == 0: #  DO;
          ERROR(d.CLASS_QX,8);
          g.PSEUDO_TYPE[d.TEMP] = g.INT_TYPE;
      # END;
      g.IND_LINK = 0
      g.PSEUDO_LENGTH[0] = 0;
      if g.INX[g.NEXT_SUB] == 0:
          g.FIX_DIM = g.BIT_LENGTH_LIM;
      else: # DO;
         REDUCE_SUBSCRIPT(0,0);
         if g.FIX_DIM > g.BIT_LENGTH_LIM: # DO;
             g.FIX_DIM = g.BIT_LENGTH_LIM;
             ERROR(d.CLASS_SR, 2, g.VAR[g.MP]);
         # END;
         elif g.FIX_DIM < 0: # DO;
             g.FIX_DIM = 1;
             ERROR(d.CLASS_SR, 6, g.VAR[g.MP]);
         #END;
      # END;
      HALMAT_TUPLE(g.XBTOQ[g.PSEUDO_TYPE[g.TEMP] - g.BIT_TYPE], 0, g.MPP1, 0, T);
      SETUP_VAC(g.MP, g.BIT_TYPE, g.FIX_DIM);
      T = 0;
      g.NEXT_SUB = 1;
      while T != g.IND_LINK:
          T = g.PSEUDO_LENGTH[T];
          HALMAT_PIP(g.LOC_P[T], g.PSEUDO_FORM[T], g.INX[T], g.VAL_P[T]);
          g.NEXT_SUB = g.NEXT_SUB + 1;
      # END;
      HALMAT_FIX_PIPp(g.LAST_POPp, g.NEXT_SUB);
      g.PTR_TOP = g.PTR[g.MP];
      g.INX[g.PTR_TOP] = 0;
      g.FIXL[g.MP] = g.FIXL[g.MPP1];
      g.FIXV[g.MP] = g.FIXV[g.MPP1];
      g.VAR[g.MP]=g.VAR[g.MPP1];
      T=0;
