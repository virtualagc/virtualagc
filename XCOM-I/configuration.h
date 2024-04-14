// This is a generic version of configuration.h that's provided merely as
// a convenience when editing runtimeC.c source code via certain integrated
// development environments (IDE's).  This configuration.h is *not* used
// for building executables from XPL or XPL/I source code compiled by XCOM-I,
// and none of its numerical values can be relied upon.  The correct
// configuration.h is for specific XPL source-code files is generated rather
// by XCOM-I.

#define NULL_STRING_METHOD 1
#define PFS
#define COMMON_BASE 0x000000
#define NON_COMMON_BASE 0x000000
#define FREE_BASE 0x000FC4
#define FREE_POINT 0x0010C3 // Initial value for `freepoint`
#define FREE_LIMIT 0x1000000
#define NUM_SYMBOLS 9
#define MAX_SYMBOL_LENGTH 8
#define MAX_DATATYPE_LENGTH 9
#define MAX_RECORD_FIELDS 0
#define MAX_RECORD_FIELD_NAME 0

typedef char symbol_t[MAX_SYMBOL_LENGTH + 1];
typedef struct {
  int address;
  symbol_t symbol;
  char datatype[MAX_DATATYPE_LENGTH + 1];
  int numElements;
} memoryMapEntry_t;
extern memoryMapEntry_t memoryMap[NUM_SYMBOLS]; // Sorted by address
extern memoryMapEntry_t *memoryMapBySymbol[NUM_SYMBOLS]; // Sorted by symbol
