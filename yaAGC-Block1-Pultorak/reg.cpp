#include "reg.h"
#include <math.h>
#include <stdlib.h>
#include "BUS.h"
unsigned
reg::buildMask(unsigned s)
{
  unsigned msk = 0;
  for (unsigned i = 0; i < s; i++)
    {
      msk = (msk << 1) | 1;
    }
  return msk;
}
unsigned
reg::readField(unsigned msb, unsigned lsb)
{
  return (slaveVal >> (lsb - 1)) & buildMask((msb - lsb) + 1);
}
void
reg::writeField(unsigned msb, unsigned lsb, unsigned v)
{
  load = true;
  unsigned fmask = buildMask((msb - lsb) + 1) << (lsb - 1);
  v = (v << (lsb - 1)) & fmask;
  masterVal = (masterVal & (~fmask)) | v;
}
void
reg::writeShift(unsigned in, unsigned* ib)
{
  load = true;
  unsigned out = masterVal;
  // iterate through each bit of the output word, copying in bits from the input
  // word and transposing bit position according to the specification (ib)
  for (unsigned i = 0; i < 16; i++)
    {
      if (ib[i] == BX)
        continue; // BX is 'don't care', so leave it alone
      // zero the output bit at 'ob', where ob specifies a bit
      // position (numbered 16-1, where 1 is lsb)
      unsigned ob = 16 - i;
      unsigned obmask = 1 << (ob - 1); // create mask for output bit
      out &= ~obmask;
      if (ib[i] == D0)
        continue; // D0 is 'force the bit to zero'
      // copy input bit ib[i] to output bit 'ob', where ib and ob
      // specify bit positions (numbered 16-1, where 1 is lsb)
      unsigned ibmask = 1 << (ib[i] - 1); // create mask for input bit
      unsigned inbit = in & ibmask;
      int shift = ib[i] - ob;
      if (shift < 0)
        inbit = inbit << abs(shift);
      else if (shift > 0)
        inbit = inbit >> shift;
      out |= inbit;
    }
  masterVal = out;
}
unsigned
reg::shiftData(unsigned out, unsigned in, unsigned* ib)
{
  // iterate through each bit of the output word, copying in bits from the input
  // word and transposing bit position according to the specification (ib)
  for (unsigned i = 0; i < 16; i++)
    {
      if (ib[i] == BX)
        continue; // BX is 'don't care', so leave it alone
      // zero the output bit at 'ob', where ob specifies a bit
      // position (numbered 16-1, where 1 is lsb)
      unsigned ob = 16 - i;
      unsigned obmask = 1 << (ob - 1); // create mask for output bit
      out &= ~obmask;
      if (ib[i] == D0)
        continue; // D0 is 'force the bit to zero'
      // copy input bit ib[i] to output bit 'ob', where ib and ob
      // specify bit positions (numbered 16-1, where 1 is lsb)
      unsigned ibmask = 1 << (ib[i] - 1); // create mask for input bit
      unsigned inbit = in & ibmask;
      int shift = ib[i] - ob;
      if (shift < 0)
        inbit = inbit << abs(shift);
      else if (shift > 0)
        inbit = inbit >> shift;
      out |= inbit;
    }
  return out;
}

