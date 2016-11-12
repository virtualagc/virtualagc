/****************************************************************************
 * BUS - READ/WRITE BUS subsystem
 *
 * AUTHOR: John Pultorak
 * DATE: 9/22/01
 * FILE: BUS.h
 *
 * VERSIONS:
 *
 * DESCRIPTION:
 * RW Bus for the Block 1 Apollo Guidance Computer prototype (AGC4).
 *
 * SOURCES:
 * Mostly based on information from "Logical Description for the Apollo
 * Guidance Computer (AGC4)", Albert Hopkins, Ramon Alonso, and Hugh
 * Blair-Smith, R-393, MIT Instrumentation Laboratory, 1963.
 *
 * NOTES:
 *
 *****************************************************************************
 */
#ifndef BUS_H
#define BUS_H
// BUS LINE DESIGNATIONS
// Specify the assignment of bus lines to the inputs of a register (for a 'write'
// operation into a register). Each 'conv_' array specifies the inputs into a
// single register. The index into the array corresponds to the bit position in
// the register, where the first parameter (index=0) is bit 16 of the register (msb)
// and the last parameter (index=15) is register bit 1 (lsb). The value of
// the parameter identifies the bus line assigned to that register bit. 'BX'
// means 'don't care'; i.e.: leave that register bit alone.
enum
{
  D0 = 17, // force bit to zero
  SGM = 15, // sign bit in memory
  SG = 16, // sign (S2; one's compliment)
  US = 15, // uncorrected sign (S1; overflow), except in register G
  B15 = 16,
  B14 = 14,
  B13 = 13,
  B12 = 12,
  B11 = 11,
  B10 = 10,
  B9 = 9,
  B8 = 8,
  B7 = 7,
  B6 = 6,
  B5 = 5,
  B4 = 4,
  B3 = 3,
  B2 = 2,
  B1 = 1,
  BX = 0 // ignore
};
enum ovfState
{
  NO_OVF, POS_OVF, NEG_OVF
};
class BUS
{
public:
  static unsigned glbl_READ_BUS; // read/write bus for xfer between central regs
  static unsigned glbl_WRITE_BUS; // read/write bus for xfer between central regs
  friend class INT;
  friend class CTR;
private:
  static ovfState
  testOverflow(unsigned bus);
};
#endif
