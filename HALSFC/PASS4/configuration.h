// Configuration settings, inferred from the XPL/I source.
#define DEBUGGING_AID
#define REENTRY_GUARD
void resetAllReentryGuards();
#define APP_NAME "PASS4"
#define XCOM_I_START_TIME 1639800
#define XCOM_I_START_DATE 124221
#define MAJOR_VERSION 0
#define MINOR_VERSION 9
#define PFS
#define COMMON_BASE 0x000000
#define NON_COMMON_BASE 0x001064
#define FREE_BASE 0x002052
#define FREE_POINT 0x0026B4 // Initial value for `freepoint`
#define PHYSICAL_MEMORY_LIMIT 0xFFB8F0
#define PRIVATE_MEMORY_SIZE 0x002710
#define FREE_LIMIT 0xFFB2F0
#define NUM_SYMBOLS 566
#define MAX_SYMBOL_LENGTH 42
#define MAX_DATATYPE_LENGTH 9
#define MAX_RECORD_FIELDS 16
#define MAX_RECORD_FIELD_NAME 15
#define WHERE_MONITOR_23 0
#define WHERE_MONITOR_13 14
#define ROOT_BASED 1344
#define MAX_LENGTH_MANGLED 39
#define NUM_MANGLED 18
#define MAX_TYPE1 64
#define MAX_TYPE2 64
#define USER_MEMORY 4196
#define PRIVATE_MEMORY 4224
#define NUM_INITIALIZED 9912

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

