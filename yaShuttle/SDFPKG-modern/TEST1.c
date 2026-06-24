/*
 * License:	Public Domain in the U.S.  Use, modify, or distribute freely.
 * Filename:	TEST1.c
 * Purpose:	Implement a replacement for SDFPKG.ASM/TEST1.bal.
 * Contact:	https://www.ibiblio.org/apollo
 * Reference:	https://www.ibiblio.org/apollo/Shuttle/HAL-S-FC-SDL-INTERFACE-CONTROL-DOCUMENT.pdf#page=24
 * History:	2026-06-20 RSB 	Began.
 */

#include "SDFPKG.h"

int
main(void) {
  uint32_t commarea = 100000;	// An arbitrary choice for this test!
  int len = 1024*1024;		// An arbitrary size for this test!

  // Create a memory model.
  sdfpkgMemoryModel(malloc(len), len);

  // Initialize the commarea.
  memset(&memory[commarea], 0, COMMAREA_SIZE);
  memcpy(&memory[commarea+SDFNAM], "##IMUERR", 8);

  sdfpkg(0, commarea);

  sdfpkg(4);

  while (1) {
      sdfpkg(14);
  }

}

