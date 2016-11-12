#ifndef reg_H
#define reg_H
#include <iostream>
#include <string.h>
#include <stdio.h>
class reg
  {
  public:
    virtual unsigned read()
      { return mask & slaveVal;}
    virtual void write(unsigned v)
      { load = true; masterVal = mask & v;}
    // asynchronous clear
    void clear()
      { slaveVal = 0;}
    // load is set when a register is written into.
    void clk()
      { if(load) slaveVal = masterVal; load = false;}
    unsigned readField(unsigned msb, unsigned lsb); // bitfield numbered n - 1
    void writeField(unsigned msb, unsigned lsb, unsigned v);// bitfield numbered n - 1
    // Write a 16-bit word (in) into the register. Transpose the bits according to
    // the specification (ib).
    void writeShift(unsigned in, unsigned* ib);
    // Return a shifted 16-bit word. Transpose the 'in' bits according to
    // the specification 'ib'. 'Or' the result to out and return the value.
    unsigned shiftData(unsigned out, unsigned in, unsigned* ib);
    unsigned outmask()
      { return mask;}
  protected:
    reg(unsigned s, char* fs)
    : size(s), mask(0), masterVal(0), slaveVal(0), fmtString(fs), load(false)
      { mask = buildMask(size);}
    static unsigned buildMask(unsigned s);
    friend ostream& operator << (ostream& os, const reg& r)
      { char buf[32]; sprintf(buf, r.fmtString, r.slaveVal); os << buf; return os;}
  private:
    unsigned size; // bits
    unsigned masterVal;
    unsigned slaveVal;
    unsigned mask;
    char* fmtString;
    bool load;
    reg();// prevent instantiation of default constructor
  };
#endif
