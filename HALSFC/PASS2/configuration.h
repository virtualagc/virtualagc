// Configuration settings, inferred from the XPL/I source.
#define DEBUGGING_AID
#define REENTRY_GUARD
void resetAllReentryGuards();
#define APP_NAME "PASS2"
#define XCOM_I_START_TIME 4556300
#define XCOM_I_START_DATE 124222
#define MAJOR_VERSION 0
#define MINOR_VERSION 9
#define PFS
#define COMMON_BASE 0x000000
#define NON_COMMON_BASE 0x001064
#define FREE_BASE 0x011EB0
#define FREE_POINT 0x0132CA // Initial value for `freepoint`
#define PHYSICAL_MEMORY_LIMIT 0xFFB8F0
#define PRIVATE_MEMORY_SIZE 0x002710
#define FREE_LIMIT 0xFFB2F0
#define NUM_SYMBOLS 2483
#define MAX_SYMBOL_LENGTH 66
#define MAX_DATATYPE_LENGTH 9
#define MAX_RECORD_FIELDS 37
#define MAX_RECORD_FIELD_NAME 14
#define WHERE_MONITOR_23 0
#define WHERE_MONITOR_13 14
#define ROOT_BASED 1344
#define MAX_LENGTH_MANGLED 55
#define NUM_MANGLED 115
#define MAX_TYPE1 64
#define MAX_TYPE2 64
#define USER_MEMORY 4196
#define PRIVATE_MEMORY 4224
#define NUM_INITIALIZED 78544

extern char *mangledLabels[NUM_MANGLED];
typedef char symbol_t[MAX_SYMBOL_LENGTH + 1];
typedef char datatype_t[MAX_DATATYPE_LENGTH + 1];
typedef struct {
  symbol_t symbol;
  datatype_t datatype;
  int numElements;
  int dirWidth;
  int bitWidth;
  int offset;
} basedField_t;
typedef struct {
  int address;
  symbol_t symbol;
  datatype_t datatype;
  int numElements;
  int allocated;
  basedField_t *basedFields;
  int numFieldsInRecord;
  int recordSize;
  int dirWidth;
  int bitWidth;
  int parentAddress;
  int common;
  int library;
} memoryMapEntry_t;
extern memoryMapEntry_t memoryMap[NUM_SYMBOLS]; // Sorted by address
extern memoryMapEntry_t *memoryMapBySymbol[NUM_SYMBOLS]; // Sorted by symbol
typedef struct {
  int start;
  int end;
} memoryRegion_t;
extern memoryRegion_t memoryRegions[7];

