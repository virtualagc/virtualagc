/*
  File PRINT_SUMMARY.c generated by XCOM-I, 2024-08-08 04:32:08.
*/

#include "../AUXP/runtimeC.h"

int32_t
PRINT_SUMMARY (int reset)
{
  static int reentryGuard = 0;
  if (reset)
    {
      reentryGuard = 0;
      return (int32_t)0;
    }
  reentryGuard = guardReentry (reentryGuard, "PRINT_SUMMARY");
  // OUTPUT = ''; (698)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = ''; (699)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // CALL PRINT_DATE_AND_TIME('END OF HAL/S AUXILIARY HALMAT GENERATOR ', DATE,
  // TIME); (700)
  {
    putCHARACTERp (
        mPRINT_DATE_AND_TIMExMESSAGE,
        cToDescriptor (NULL, "END OF HAL/S AUXILIARY HALMAT GENERATOR "));
    putFIXED (mPRINT_DATE_AND_TIMExD, DATE ());
    putFIXED (mPRINT_DATE_AND_TIMExT, TIME ());
    PRINT_DATE_AND_TIME (0);
  }
  // T = MONITOR(18); (701)
  {
    int32_t numberRHS = (int32_t)(MONITOR18 ());
    putFIXED (mPRINT_SUMMARYxT, numberRHS);
  }
  // OUTPUT = ''; (702)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // CALL PRINT_TIME('TOTAL CPU TIME FOR AUXILIARY HALMAT GENERATOR     : ', T
  // - CLOCK); (703)
  {
    putCHARACTERp (
        mPRINT_TIMExMESSAGE,
        cToDescriptor (
            NULL, "TOTAL CPU TIME FOR AUXILIARY HALMAT GENERATOR     : "));
    putFIXED (mPRINT_TIMExT,
              xsubtract (getFIXED (mPRINT_SUMMARYxT), getFIXED (mCLOCK)));
    PRINT_TIME (0);
  }
  // CALL PRINT_TIME('CPU TIME FOR AUXILIARY HALMAT GENERATOR SETUP     : ',
  // CLOCK(1) - CLOCK); (704)
  {
    putCHARACTERp (
        mPRINT_TIMExMESSAGE,
        cToDescriptor (
            NULL, "CPU TIME FOR AUXILIARY HALMAT GENERATOR SETUP     : "));
    putFIXED (mPRINT_TIMExT,
              xsubtract (getFIXED (mCLOCK + 4 * 1), getFIXED (mCLOCK)));
    PRINT_TIME (0);
  }
  // CALL PRINT_TIME('CPU TIME FOR AUXILIARY HALMAT GENERATOR CRUNCHING : ',
  // CLOCK(2) - CLOCK(1)); (705)
  {
    putCHARACTERp (
        mPRINT_TIMExMESSAGE,
        cToDescriptor (
            NULL, "CPU TIME FOR AUXILIARY HALMAT GENERATOR CRUNCHING : "));
    putFIXED (mPRINT_TIMExT, xsubtract (getFIXED (mCLOCK + 4 * 2),
                                        getFIXED (mCLOCK + 4 * 1)));
    PRINT_TIME (0);
  }
  // OUTPUT = ''; (706)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'TOTAL NUMBER OF GARBAGE COLLECTIONS    = ' || #GCS; (707)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (
        cToDescriptor (NULL, "TOTAL NUMBER OF GARBAGE COLLECTIONS    = "),
        bitToCharacter (getBIT (16, mpGCS)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'MAXIMUM NUMBER OF USED CELLS           = ' || MAX_USED_CELLS;
  // (708)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (
        cToDescriptor (NULL, "MAXIMUM NUMBER OF USED CELLS           = "),
        bitToCharacter (getBIT (16, mMAX_USED_CELLS)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // CALL PRINT_TIME('TOTAL TIME SPENT IN GARBAGE COLLECTION = ',
  // TOTAL_GC_TIME); (709)
  {
    putCHARACTERp (
        mPRINT_TIMExMESSAGE,
        cToDescriptor (NULL, "TOTAL TIME SPENT IN GARBAGE COLLECTION = "));
    putFIXED (mPRINT_TIMExT, getFIXED (mTOTAL_GC_TIME));
    PRINT_TIME (0);
  }
  // OUTPUT = ''; (710)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // CALL PRINT_TIME('TOTAL TIME SPENT IN PRETTY PRINTING AUXMAT = ',
  // TOTAL_PRETTY_PRINT_TIME); (711)
  {
    putCHARACTERp (
        mPRINT_TIMExMESSAGE,
        cToDescriptor (NULL, "TOTAL TIME SPENT IN PRETTY PRINTING AUXMAT = "));
    putFIXED (mPRINT_TIMExT, getFIXED (mTOTAL_PRETTY_PRINT_TIME));
    PRINT_TIME (0);
  }
  // OUTPUT = ''; (712)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'MAXIMUM STACK LEVEL = ' || MAX_STACK_LEVEL; (713)
  {
    descriptor_t *stringRHS;
    stringRHS = xsCAT (cToDescriptor (NULL, "MAXIMUM STACK LEVEL = "),
                       bitToCharacter (getBIT (16, mMAX_STACK_LEVEL)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = ''; (714)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'NUMBER OF MINOR COMPACTIFIES  = ' || COMPACTIFIES; (715)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "NUMBER OF MINOR COMPACTIFIES  = "),
                 bitToCharacter (getBIT (16, mCOMPACTIFIES)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'NUMBER OF MAJOR COMPACTIFIES  = ' || COMPACTIFIES(1); (716)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "NUMBER OF MAJOR COMPACTIFIES  = "),
                 bitToCharacter (getBIT (16, mCOMPACTIFIES + 2 * 1)));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = 'FREE STRING AREA              = ' || FREELIMIT - FREEBASE; (717)
  {
    descriptor_t *stringRHS;
    stringRHS
        = xsCAT (cToDescriptor (NULL, "FREE STRING AREA              = "),
                 fixedToCharacter (xsubtract (FREELIMIT (), FREEBASE ())));
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = ''; (718)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  // OUTPUT = ''; (719)
  {
    descriptor_t *stringRHS;
    stringRHS = cToDescriptor (NULL, "");
    OUTPUT (0, stringRHS);
    stringRHS->inUse = 0;
  }
  {
    reentryGuard = 0;
    return 0;
  }
}
