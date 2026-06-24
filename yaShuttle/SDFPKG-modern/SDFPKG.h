/*
 * License:	Public Domain in the U.S.  Use, modify, or distribute freely.
 * Filename:	SDFPKG.h
 * Purpose:	Header file for SDFPKG.c et al.
 * Contact:	https://www.ibiblio.org/apollo
 * Reference:	https://www.ibiblio.org/apollo/Shuttle/HAL-S-FC-SDL-INTERFACE-CONTROL-DOCUMENT.pdf#page=24
 * History:	2026-06-20 RSB 	Began.
 */

#ifndef SDFPKG_H

#define SDFPKG_H
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdarg.h>

typedef uint32_t sdfpkg0_t(void);
typedef uint32_t sdfpkg_t(uint32_t parm);

// Offsets of fields from beginning of `COMMAREA`, in bytes.
#define APGAREA		0
#define AFCBBLKS	(APGAREA + 4)
#define NPAGES		(AFCBBLKS + 4)
#define NBYTES		(NPAGES + 2)
#define MISC		(NBYTES + 2)
#define CRETURN		(MISC + 2)
#define BLKNO		(CRETURN + 2)
#define SYMBNO		(BLKNO + 2)
#define STMTNO		(SYMBNO + 2)
#define BLKNLEN		(STMTNO + 2)
#define SYMBNLEN	(BLKNLEN + 1)
#define PNTR		(SYMBNLEN + 1)
#define ADDR		(PNTR + 4)
#define SDFNAM		(ADDR + 4)
#define CSECTNAM	(SDFNAM + 8)
#define SREFNO		(CSECTNAM + 8)
#define INCLCNT 	(SREFNO + 6)
#define BLKNAM		(INCLCNT + 2)
#define SYMBNAM		(BLKNAM + 32)
#define COMMAREA_SIZE	(SYMBNAM + 32)

void
sdfpkgAbend(const char *format, ...);

void
sdfpkgMemoryModel(uint8_t *memoryPtr, int length);

uint32_t
sdfpkg(uint32_t mode, uint32_t commAreaAddress);

#endif // SDFPKG_H

#if 0
// This stuff doesn't belong here.  Do something about it later.

// Used only when outputting in-memory structures as a packed array of 1680-byte
// records.
typedef struct {
  uint16_t pageNumber;  // 0, 1, 2, ...
  uint16_t offsetInPage;  // 0 to 1679.
} sdfPointer_t;

typedef struct _dataCell_ {
  uint32_t availableBytes;
  struct _dataCell_ *nextDataCell;
  uint8_t *data;
} dataCell_t;

typedef struct _directoryCell_ {
  uint16_t phase3VersionNumber;
  uint16_t unused; // 0x0000
  dataCell_t *firstDirectoryFreeCell;
  struct _directoryCell_ *directoryRootCell;
  dataCell_t *firstDataFreeCell;
} directoryCell_t;

//------------------------------------------------------------------------------

// Recursively free a linked list of data cells.
void
freeCell(dataCell_t *dataCell) {
  if (dataCell == NULL)
    return;
  freeCell(dataCell->nextDataCell);
  free(dataCell->data);
  free(dataCell);
}

// Recursively free all of the allocated memory for a directoryCell_t tree.
void
freeSDF(directoryCell_t *masterDirectoryCell) {
  if (masterDirectoryCell == NULL)
    return;
  freeSDF(masterDirectoryCell->directoryRootCell);
  freeCell(masterDirectoryCell->firstDirectoryFreeCell);
  freeCell(masterDirectoryCell->firstDataFreeCell);
  free(masterDirectoryCell);
}

// Create a data cell and return a pointer to it, or NULL on failure.
dataCell_t *
createDataCell(uint32_t size) {
  dataCell_t *cell;
  cell = calloc(1, sizeof(dataCell_t));
  if (cell == NULL)
    return cell;
  cell->data = calloc(1, size);
  if (cell->data == NULL) {
      free(cell);
      return NULL;
  }
  cell->availableBytes = size;
  return cell;
}

// Create a master directory cell and return a pointer to it, or NULL on failure.
directoryCell_t *
createMasterDirectoryCell(uint16_t phase3VersionNumber) {
  directoryCell_t *cell;
  cell = calloc(1, sizeof(directoryCell_t));
  if (cell == NULL)
    return cell;
  cell->phase3VersionNumber = phase3VersionNumber;
  return cell;
}

// Pack a directoryCell_t and all its descendants into an array of 1680-byte
// records and return a pointer to that array, or else NULL on failure.  The
// `size` parameter is ignored on entry, but the size of the returned array
// (in bytes) is written into it upon return.
uint8_t *
packSDF (directoryCell_t *masterDirectoryCell, int *size) {
  return NULL;
}

// Unpack an array of 1680-byte records into a linked structure of
// directoryCell_t and dataCell_t objects.  Return a pointer to the master
// directoryCell_t, or else NULL on failure.
directoryCell_t *
unpackSDF(uint8_t *packedArray, int packedArraySize) {
  return NULL;
}

#endif // 0
