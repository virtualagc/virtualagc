/*
 * License:     The author (Ronald S. Burkey) declares that this program
 *              is in the Public Domain (U.S. law) and may be used or
 *              modified for any purpose whatever without licensing.
 * Filename:    debuggingAid.c
 * Purpose:     Some XCOM-I runtime library functions useful for debugging
 *              XCOM-I itself.
 * Reference:   http://www.ibibio.org/apollo/Shuttle.html
 * Mods:        2024-06-19 RSB  Split off from runtimeC.c.
 *
 * These functions, many of which were formerly in runtimeC.c, have been
 * segregated here so that: a) I can easily eliminate them from the "production"
 * builds; and b) I can add complex functions at will without compromising
 * maintainability of the production runtime library.
 */

#include "runtimeC.h"

#ifdef DEBUGGING_AID

//---------------------------------------------------------------------------
// Functions useful for CALL INLINE or debugging a la `gdb`.

// The `start` and `end` are addresses, and only variables within the
// range start<=address<end are printed.  Either can be -1 to prevent it from
// being used as a criterion.
void
printMemoryMap(char *msg, int start, int end) {
  int i;
  printf("\n%s\n", msg);
  for (i = 0; i < NUM_SYMBOLS; i++)
    {
      int j;
      int address = memoryMap[i].address;
      char *symbol = memoryMap[i].symbol;
      char *datatype = memoryMap[i].datatype;
      if ((start != -1 && address < start) || (end != -1 && address >= end))
        continue;
      if (!strcmp(datatype, "BASED"))
        {
          int numRecords = memoryMap[i].allocated / memoryMap[i].recordSize;
          uint32_t raddress = getFIXED(address);
          printf("%06X: BASED     %s = %08X %04X %04X %08X %08X %08X %08X %04X %04X\n",
              address, symbol, getFIXED(address), COREHALFWORD(address+4),
              COREHALFWORD(address+6), getFIXED(address+8), getFIXED(address+12),
              getFIXED(address+16), getFIXED(address+20),
              COREHALFWORD(address+24), COREHALFWORD(address+26));
          for (j = 0; j < numRecords; j++)
            {
              int k;
              int numFieldsInRecord = memoryMap[i].numFieldsInRecord;
              const basedField_t *basedField = memoryMap[i].basedFields;
              for (k = 0; k < numFieldsInRecord; k++, basedField++)
                {
                  int n, numElements = basedField->numElements, vector = 1;
                  if (numElements == 0)
                    {
                      vector = 0;
                      numElements = 1;
                    }
                  for (n = 0; n < numElements; n++, raddress += basedField->dirWidth)
                    {
                      const char *fieldName = basedField->symbol;
                      char *s;
                      printf("        %06X: BASED %s %s(%d)", raddress,
                             basedField->datatype, symbol, j);
                      if (strlen(fieldName) != 0)
                        {
                          printf(".%s", fieldName);
                          if (vector)
                            printf("(%d)", n);
                        }
                      if (!strcmp(basedField->datatype, "CHARACTER"))
                        {
                          uint32_t descriptor = getFIXED(raddress);
                          if (descriptor == 0)
                            printf(" = \"%s\"", "");
                          else
                            printf(" = \"%s\" @%06X", getCHARACTER(raddress)->bytes,
                                   0xFFFFFF & getFIXED(raddress));
                        }
                      else if (!strcmp(basedField->datatype, "FIXED"))
                        printf(" = %d", getFIXED(raddress));
                      else if (!strcmp(basedField->datatype, "BIT"))
                        printf(" = %u", getFIXED(raddress));
                      printf("\n");
                    }
                }
            }
        }
      else
        {
          int numElements = memoryMap[i].numElements;
          int dirWidth = memoryMap[i].dirWidth;
          if (numElements == 0)
            {
              uint32_t saddress = getFIXED(address) & 0xFFFFFF;
              if (!strcmp(datatype, "CHARACTER"))
                printf("%06X: CHARACTER %s = \"%s\" @%06X\n",
                       address, symbol, descriptorToAscii(getCHARACTER(address)),
                       saddress);
              else if (!strcmp(datatype, "FIXED"))
                printf("%06X: FIXED     %s = %d\n", address, symbol,
                       getFIXED(address));
              else if (!strcmp(datatype, "BIT"))
                printf("%06X:       BIT %s = %u\n", address, symbol,
                       getFIXED(address));
            }
          for (j = 0; j < numElements; j++)
            {
              int k = address + dirWidth * j;
              uint32_t saddress = getFIXED(k) & 0xFFFFFF;
              if (!strcmp(datatype, "CHARACTER"))
                 printf("%06X: CHARACTER %s(%u) = \"%s\" @%06X\n", k, symbol,
                          j, descriptorToAscii(getCHARACTER(k)), saddress);
              else if (!strcmp(datatype, "FIXED"))
                printf("%06X: FIXED     %s(%u) = %d\n", k, symbol,
                      j, getFIXED(k));
              else if (!strcmp(datatype, "BIT"))
                printf("%06X:       BIT %s(%u) = %u\n", k, symbol,
                      j, getFIXED(k));
            }
        }
    }
}

// Convert the data of a BIT to a string in the currently-set radix.
int bitBits = 4;
descriptor_t *
bitToRadix(descriptor_t *b) {
  descriptor_t *returnValue;
  int offset;
  int radix = 1 << bitBits;
  int numDigits = (b->bitWidth + bitBits - 1) / bitBits;
  int i, nextByte, bitsLeftInValue = 0, value = 0, thisDigit;
  if (bitBits < 1 || bitBits > 4)
    return cToDescriptor(NULL, "Set bitBits 1, 2, 3, or 4 (not %d)", bitBits);
  if (bitBits < 4)
    returnValue = cToDescriptor(NULL, "\"(%d) ", bitBits);
  else
    returnValue = cToDescriptor(NULL, "\"");
  offset = returnValue->numBytes;
  for (i = 0, nextByte = 0; i < numDigits; i++)
    {
      int keep;
      while (bitsLeftInValue < bitBits)
        {
          value = (value << 8) | b->bytes[nextByte++];
          bitsLeftInValue += 8;
        }
      keep = bitsLeftInValue - bitBits;
      thisDigit = value >> keep;
      value = value & ((1 << keep) - 1);
      bitsLeftInValue -= bitBits;
      if (thisDigit < 10)
        returnValue->bytes[offset + i] = '0' + thisDigit;
      else
        returnValue->bytes[offset + i] = 'A' + (thisDigit - 10);
    }
  returnValue->bytes[offset + numDigits] = '"';
  returnValue->bytes[offset + numDigits + 1] = 0;
  returnValue->numBytes += numDigits + 1;
  return returnValue;
}

// This function could be used within a debugger to fetch the current value
// of an identifier, perhaps subscripted.  Useful because XPL variables are
// not modeled as C variables (easily accessed by the debugger) but rather
// as indexes into the `memory` array and not encoded the way native C
// variables are.  Because it's so easy (for me, at least) of making the
// mistake of using brackets rather than parentheses, brackets are accepted
// in places of parentheses.
descriptor_t *
getXPL(char *identifier) {
  memoryMapEntry_t *entry;
  char *base = NULL, *field = NULL;
  int baseIndex = 0, fieldIndex = 0;
  char *s;
  for (s = identifier, base = identifier; *s; s++)
    {
      if (*s == '[')
        *s = '(';
      else if (*s == ']')
        *s = ')';
      else if (*s == '.')
        {
          if (field != NULL)
            return cToDescriptor(NULL,
                                 "Too many . separators in %s.", identifier);
          *s = 0;
          field = s + 1;
        }
    }
  for (s = base; *s; s++)
    {
      if (*s == '(')
        {
          *s = 0;
          baseIndex = atoi(s + 1);
          break;
        }
    }
  if (field != NULL)
    for (s = field; *s; s++)
      {
        if (*s == '(')
          {
            *s = 0;
            fieldIndex = atoi(s + 1);
            break;
          }
      }
  entry = lookupVariable(base);
  if (entry == NULL)
    return cToDescriptor(NULL,
                         "Cannot find variable %s; could it be a macro?", base);
  if (entry->basedFields == NULL)
    {
      if (field != NULL)
        return cToDescriptor(NULL, "Variable %s is not BASED RECORD.", base);
      field = base;
      fieldIndex = baseIndex;
      base = NULL;
      baseIndex = 0;
    }

  return rawGetXPL(base, baseIndex, field, fieldIndex);
}

void
printXPL(char *identifier) {
  printf("%s\n", getXPL(identifier)->bytes);
}

descriptor_t *
rawGetXPL(char *base, int baseIndex, char *field, int fieldIndex) {
  int32_t address = rawADDR(base, baseIndex, field, fieldIndex);
  if (foundRawADDR == NULL || address < 0 || \
        address + foundRawADDR->dirWidth > sizeof(memory))
    return cToDescriptor(NULL, "Outside of physical memory");
  if (!strcmp(foundRawADDR->datatype, "FIXED"))
    {
      int32_t i = getFIXED(address);
      return cToDescriptor(NULL, "%d (0x%08X)", i, i);
    }
  if (!strcmp(foundRawADDR->datatype, "CHARACTER"))
    return cToDescriptor(NULL, "'%s'", getCHARACTER(address)->bytes);
  if (!strcmp(foundRawADDR->datatype, "BIT"))
    {
      descriptor_t *b = getBIT(foundRawADDR->bitWidth, address);
      return cToDescriptor(NULL,
                           "bitWidth=%d numBytes=%d bytes=%s",
                           b->bitWidth, b->numBytes,
                           bitToRadix(b)->bytes);
    }
  return cToDescriptor(NULL, "Unrecognized datatype %s", foundRawADDR->datatype);
}

// Functions to simplify interactive debugging.  They print out the value of
// a variable in a human-friendly fashion.
char *
g0(char *identifier, memoryMapEntry_t *me) {
  static sbuf_t msg;
  uint32_t address = me->address, fixed = getFIXED(address);
  char *datatype = me->datatype;
  if (!strcmp(datatype, "FIXED"))
    sprintf(msg, "@0x%X, %s = %d (0x%X)", address, identifier, fixed, fixed);
  else if (!strcmp(datatype, "CHARACTER"))
    sprintf(msg, "@0x%X, %s = '%s'", address, identifier,
            descriptorToAscii(getCHARACTER(address)));
  else if (!strcmp(datatype, "BIT") && me->bitWidth <= 32)
    {
      fixed = bitToFixed(getBIT(me->bitWidth, address));
      sprintf(msg, "@0x%X, %s = %d (0x%X)", address, identifier, fixed, fixed);
    }
  else
    sprintf(msg, "@0x%X, %s: Datatype %s not yet implemented", address,
            identifier, datatype);
  return msg;
}

char *
g(char *identifier) {
  memoryMapEntry_t *me = lookupVariable(identifier);
  if (me == NULL)
    {
      static sbuf_t msg;
      sprintf(msg, "Variable %s not found", identifier);
      return msg;
    }
  else
    return g0(identifier, me);
}

/*
 * The `guardReentry` function detects (surprise!) reentry of a procedure,
 * which is not allowed in XPL.  Use it like so:  Near the top of the procedure,
 * put this:
 *      static int reentryGuard = 0;
 *      reentryGuard = guardReentry(reentryGuard, "...function name...");
 * Wherever the procedure has a `return ...;`, replace it with
 *      { reentryGuard = 0; return ...; }
 * (Including at the ends of procedures with no explicit `return`.)
 * This code is added automatically in the C code generated by XCOM-I, but
 * needs to be added explicitly in patche files (always, for the `return`
 * statements) and in runtime-library functions (for functions that might
 * conceivably reenter).  The principal cause of worry was functions that
 * use `putCHARACTER`, which might call `COMPACTIFY`, which might fail, which
 * might try to use an error routine that uses `putCHARACTER`.  In fact, I
 * don't think this actually can occur, but that was my motivating concern.
 */
sbuf_t lastWatchFunction = "(Initial)";
int lastWatchValue = -1;
int
guardReentry(int reentryGuard, char *functionName) {
  if (reentryGuard) {
      fprintf(stderr, "\nIllegal reentry of function %s\n", functionName);
      exit(1);
  }
  //if (memory[mNEXT_CHAR] == 0x4A && lastWatchValue != 0x4A)
  //  fprintf(stderr,"\n%s: NEXT_CHAR = 0x4A\n", functionName);
  //lastWatchValue = memory[mNEXT_CHAR];
  //if (memoryRegions[0].end != lastWatchValue)
  //  fprintf(stderr, "\n***DEBUG mem %s\n", functionName);
  //lastWatchValue = memoryRegions[0].end;
  if (watchpoint != -1)
    {
      uint8_t value = memory[watchpoint];
      if (value != lastWatchValue)
        fprintf(stderr, "\nWatchpoint (%d 0x%X) change: %d (%s) != %d (%s)\n",
                  watchpoint, watchpoint,
                  value, functionName, lastWatchValue, lastWatchFunction);
      lastWatchValue = value;
      strcpy(lastWatchFunction, functionName);
    }
  return 1;
}

#endif // DEBUGGING_AID
