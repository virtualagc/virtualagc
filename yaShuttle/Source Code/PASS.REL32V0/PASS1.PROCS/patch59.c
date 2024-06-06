/*
 * This is a C-language patch for CALL INLINEs #59-75 in PREPLITE.xpl, as
 * used by XCOM-I in building PASS1 of HAL/S-FC.
 *
 * I'm porting this patch code over from the code I wrote when manually porting
 * PASS1 to Python.  Here are the comments I wrote in PREPLITE.py (but first
 * see the comments in patch57.c):
 *
 *      Once more, we have INLINEs ... *lots* of them, again with no comments.
 *      The IR-182-1 description implies that their purpose is simply to
 *      manufacture the value(s) stored in the variable TABLE_ADDRESS,
 *      apparently branching to NOT_EXACT: (above) if there's an error
 *      detected.
 *
 *      Alas, beyond that, I haven't a clue as to what these INLINEs are trying
 *      to do to TABLE_ADDR.  My best guess is that these things are trying to
 *      use the value stored in DW[0],DW[1] and place it in VALUE.
 */

uint32_t addrDW = getFIXED(mFOR_DW);
uint32_t msw = getFIXED(addrDW + 0), lsw = getFIXED(addrDW + 4);
int32_t ivalue;
double value = fromFloatIBM(msw, lsw);
if (value > INT32_MAX)
  ivalue = INT32_MAX;
else if (value < INT32_MIN)
  ivalue = INT32_MIN;
else
  ivalue = roundf(value);
putFIXED(mVALUE, ivalue);
