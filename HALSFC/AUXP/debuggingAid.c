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

// Get an integer-like value from memory
int *
getIntegerFromAddress(char *datatype, int bitWidth, int address) {
  int value;
  int *returnValue = &value;
  if (!strcmp(datatype, "FIXED"))
    value = COREWORD(address);
  else if (!strcmp(datatype, "BIT"))
    {
      int numBytes = (bitWidth + 7) / 8;
      if (numBytes == 3)
        numBytes = 4;
      if (numBytes == 1)
        value = memory[address];
      else if (numBytes == 2)
        value = COREHALFWORD(address);
      else if (numBytes == 4)
        value = COREWORD(address);
      else
        returnValue = NULL;
     }
  else
    returnValue = NULL;
  return returnValue;
}

// Get value of an integer-like non-BASED non-indexed variable or a literal.
// Returns a pointer to the value, or NULL if failure.
int *
getIntegerFromString(char *varString) {
  static int value;
  int *returnValue = &value;
  memoryMapEntry_t *entry;
  if (varString == NULL || *varString == 0)
    returnValue = NULL;
  else if (isdigit(*varString))
    value = atoi(varString);
  else
    {
      entry = lookupVariable(varString);
      if (entry == NULL)
        returnValue = NULL;
      else
        returnValue = getIntegerFromAddress(entry->datatype, entry->bitWidth,
                                            entry->address);
    }
  return returnValue;
}

// This function could be used within a debugger to fetch the current value
// of an identifier, perhaps subscripted.  Useful because XPL variables are
// not modeled as C variables (easily accessed by the debugger) but rather
// as indexes into the `memory` array and not encoded the way native C
// variables are.  Because it's so easy (for me, at least) of making the
// mistake of using brackets rather than parentheses, brackets are accepted
// in places of parentheses.  Indices may be either literal decimal numbers
// or non-BASED, non-subscripted identifiers of variables.
char *
getXPL(char *identifier) {
  static char *errorMessage = "Cannot parse this";
  static sbuf_t returnValue = "Cannot parse this";
  memoryMapEntry_t *entry;
  char *s, *baseString = identifier, *baseIndexString = NULL,
       *fieldString = NULL, *fieldIndexString = NULL;
  int isBase = 1, isBaseIndex = 0, isField = 0, isFieldIndex = 0;
  int baseIndex = 0, fieldIndex = 0;
  int i, *value, address;

  // First, parse the input string into BASED name, BASED index, field name,
  // and field index.
  for (s = baseString; *s; s++)
    {
      if (*s == '.')
        {
          isField = 1;
          *s = 0;
          s++;
          break;
        }
      if (*s == '(')
        {
          isBaseIndex = 1;
          *s = 0;
          s++;
          break;
        }
    }
  if (*s == 0)
    {
      // Was just a bare identifier, with no index or field separator.
      fieldString = baseString;
      isField = 1;
      baseString = NULL;
      isBase = 0;
    }
  else
    {
      if (isBaseIndex)
        for (baseIndexString = s; *s; s++)
          if (*s == ')')
            {
              *s = 0;
              s++;
              break;
            }
      if (*s == 0)
        {
          // The stuff already identified as baseString and baseIndexString
          // are really just a non-BASED identifier and its index.
          fieldString = baseString;
          fieldIndexString = baseIndexString;
          isField = 1;
          isFieldIndex = isBaseIndex;
          isBase = 0;
          isBaseIndex = 0;
        }
      else if (*s == '.')
        {
          // Ready to parse the field name and its index.
          s++;
          fieldString = s;
          isField = 1;
          for (; *s; s++)
            if (*s == '(')
              {
                isFieldIndex = 1;
                *s = 0;
                s++;
                fieldIndexString = s;
                break;
              }
          if (isFieldIndex)
            for (; *s; s++)
              if (*s == ')')
                {
                  *s = 0;
                  break;
                }
        }
      else
        {
          return errorMessage;
        }
    }

  // At this point, we've parsed the various fields.  There are certain
  // conditions we haven't checked, such as 0-length fields or the field index
  // not being terminated by ')'.  Let's check now for empty strings, since
  // those might actually cause a problem.  (Missing parenthesis? Not so much!)
  if (isBase && !*baseString)
    return errorMessage;
  if (isBaseIndex && !*baseIndexString)
    return errorMessage;
  if (isField && !*fieldString)
    return errorMessage;
  if (isFieldIndex && !*fieldIndexString)
    return errorMessage;

  // The indices, if any, may be either literal numbers or else themselves
  // the names of identifiers.
  if (isBaseIndex)
    {
      value = getIntegerFromString(baseIndexString);
      if (value == NULL)
        return errorMessage;
      baseIndex = *value;
    }
  if (isFieldIndex)
    {
      value = getIntegerFromString(fieldIndexString);
      if (value == NULL)
        return errorMessage;
      fieldIndex = *value;
    }

  if (!isBase && isField)
    {
      entry = lookupVariable(fieldString);
      if (entry == NULL)
        return errorMessage;
      address = entry->address + fieldIndex * entry->dirWidth;
      if (!strcmp(entry->datatype, "CHARACTER"))
        {
          sprintf(returnValue, "'%s'", descriptorToAscii(getCHARACTER(address)));
          return &returnValue[0];
        }
      value = getIntegerFromAddress(entry->datatype, entry->bitWidth, address);
      if (value == NULL)
        return errorMessage;
      sprintf(returnValue, "%d (0x%X)", *value, *value);
      return &returnValue[0];
    }

  if (isBase && !isField)
    return errorMessage;

  entry = lookupVariable(baseString);
  if (entry == NULL)
    return errorMessage;
  if (strcmp(entry->datatype, "BASED"))
    return errorMessage;
  basedField_t *basedFields = entry->basedFields, *basedField;
  for (i = 0; i < entry->numFieldsInRecord; i++)
    if (!strcmp(basedFields[i].symbol, fieldString))
      {
        basedField = &basedFields[i];
        address = COREWORD(entry->address) + baseIndex * entry->recordSize +
                  basedField->offset + basedField->dirWidth * fieldIndex;
        if (!strcmp(basedField->datatype, "CHARACTER"))
          {
            sprintf(returnValue, "'%s'", descriptorToAscii(getCHARACTER(address)));
            return &returnValue[0];
          }
        value = getIntegerFromAddress(basedField->datatype,
                                      basedField->bitWidth, address);
        if (value == NULL)
          return errorMessage;
        sprintf(returnValue, "%d (0x%X)", *value, *value);
        return &returnValue[0];
      }

  return errorMessage;

}

void
printXPL(char *identifier) {
  fflush(stdout);
  fprintf(stderr, "\n%s", getXPL(identifier));
  fflush(stderr);
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

#ifdef IS_PASS2
/*
 * This is for trying to check out the objects `LIB_NAMES`, `LIB_NAME_INDEX`,
 * `LIB_START`, etc., and associated functions.
 */
void
checkoutPASS2(void) {
  uint32_t HASHSIZE = 49;
  uint32_t LIB_NUM = 282;
  int32_t hashcode;
  int16_t lib_start;
  int32_t lib_name_index;
  int16_t lib_link;
  descriptor_t *name, *lib_name;
  int i;

  // First, print out all of the function names from the AP-101S runtime library.
  fprintf(stderr, "\n\nLIB_NAMES\n");
  for (i = 1; i <= LIB_NUM; i++)
    {
      name = getCHARACTER(mLIB_NAME_INDEX + 4 * i);
      hashcode = ( putCHARACTER(mHASHxNAME, name), HASH(0) );
      lib_start = COREHALFWORD(mLIB_START + 2 * hashcode);
      lib_name = getCHARACTER(mLIB_NAME_INDEX + 4 * abs(lib_start));
      lib_link = COREHALFWORD(mLIB_LINK + 2 * abs(lib_start));
      fprintf(stderr, "\t%3d:  %-6s  %2d  %4d  %-6s  %3d  \n",
              i,
              descriptorToAscii(name),
              hashcode,
              lib_start,
              descriptorToAscii(lib_name),
              lib_link
              );
    }
}
#endif

#endif // DEBUGGING_AID

