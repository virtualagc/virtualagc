/*
 Copyright 2020-2021 Ronald S. Burkey <info@sandroid.org>

 This file is part of yaAGC.

 yaAGC is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 yaAGC is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with yaAGC; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 In addition, as a special exception, Ronald S. Burkey gives permission to
 link the code of this program with the Orbiter SDK library (or with
 modified versions of the Orbiter SDK library that use the same license as
 the Orbiter SDK library), and distribute linked combinations including
 the two. You must obey the GNU General Public License in all respects for
 all of the code used other than the Orbiter SDK library. If you modify
 this file, you may extend this exception to your version of the file,
 but you are not obligated to do so. If you do not wish to do so, delete
 this exception statement from your version.

 Filename:	virtualWire.c
 Purpose:	Portable functions (*NIX and Win32) for working with sockets
 for connecting yaLVDC to peripherals by "virtual wires".
 Compiler:	GNU gcc.
 Contact:	Ron Burkey <info@sandroid.org>
 Reference:	http://www.ibiblio.org/apollo/LVDC.html
 Mods:		2020-05-06 RSB	Began adapting/simplifying from the yaAGC
                                file agc_utilities.c.
                2021-03-22 RSB  Changes related to compiling for Mac.
                                (MSG_NOSIGNAL #define'd, and all
                                #ifdef unix (or similar) extended to
                                apple.)  Thanks to Ludo Visser for the
                                change.
 */

#include <stdio.h>
#include <string.h>
#ifndef WIN32
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#else
#include <windows.h>
#include <winsock2.h>
#endif

#if (defined(__APPLE__) && defined(__MACH__)) || WIN32
#define MSG_NOSIGNAL 0
#endif

/////////////////////////////////////////////////////////////////////////////////
// Portable functions (*NIX and Win32) for working with sockets.
// LVDC/PTC specific functions.  Just delete them if repurposing this material
// for some other program.

#include "yaLVDC.h"

/*
 * Format for yaLVDC-compatible "virtual wire" packets.
 *
 * The format distinguishes between packets containing "data" and packets
 * containing a "mask".  If the packet carries all 26 bits of data (as
 * packets output by the server do), then there's no need for a mask; all
 * 26 data bits are valid.  However, for packets sent by peripherals to the
 * server (the CPU emulator) it's possible for one peripheral device to
 * supply some of the 26 bits of the port, while other peripherals supply
 * other of the bits.  In that case, the peripheral should precede such
 * a data packet (which will still be the full length) by an otherwise-
 * similar mask packet.  The payload of the mask packet has a 1 wherever
 * the payload in the following data packet will be valid, and a 0 wherever
 * the data packet will be invalid.
 *
 * Each packet consists
 * of 6 data bytes, formatted as follows:
 *
 *  1st byte:   D7      1
 *              D6      1 if the message is a mask, 0 if it's data.
 *              D5-D3   I/O type:       000     PIO
 *                                      001     CIO
 *                                      010     PRS
 *                                      011     Interrupt
 *                                      100     Command or status from panel
 *                                      101     Command or status to panel
 *                                      110     (reserved)
 *                                      111     PING
 *              D2-D0   Unique Source ID.  (000 is the server; i.e., the CPU.)
 *                      The port numbers used are the base port number plus
 *                      the ID.  Thus if the server were port number 19653,
 *                      then ID=1 would be port 19694, ... , ID=7 would be
 *                      port 19660.
 *              Note that if all fields are 0xFF, it could be used as
 *              a harmless 1-byte PING message.  I don't know why I'd
 *              want to use that, necessarily, but at least I'm allowing
 *              for it.
 *
 *   2nd byte   D7      0
 *              D6-D0   Least-significant 7 bits of the channel number
 *
 *   3rd byte   D7      0
 *              D6      Most-significant bit of the channel number
 *              D5      Next-most-significant bit of the channel number
 *              D4-D0   Most-significant 5 bits of the 26-bit data/mask
 *
 *   4th byte   D7      0
 *              D6-D0   Next-most-significant 7 bits of the 26-bit data/mask.
 *
 *   5th byte   D7      0
 *              D6-D0   Next-most-significant 7 bits of the 26-bit data/mask.
 *
 *   6th byte   D7      0
 *              D6-D0   Least-significant 7 bits of the 26-bit data/mask.
 *
 * Commands/status from/to the PTC front panel (I/O type 100 or 101) are, of course,
 * my own invention, and thus are not documented in any of the original Apollo-era
 * documentation, since in the physical PTC they were not implemented with i/o ports.
 * (Except, of course, for data conveyed already by existing PIO or
 * CIO commands.)  So here is the documentation:
 *
 * Type 100 (from panel emulation to CPU emulation):
 *      Channel 000:    Pause at current instruction.  What that means is that the
 *                      main CPU emulation loop will continue cycling normally,
 *                      except that runOneInstruction() is not being executed
 *                      and the cycle/instruction counts are not updated.  This
 *                      means that the yaLVDC debugger interface *won't* appear,
 *                      and virtual-wire transactions will continue to occur.
 *                      The packet payload is ignored.
 *      Channel 001:    Release the instruction pause (from prior channel 000) and
 *                      proceed executing normally.  The packet payload is ignored.
 *      Channel 002:    Set a data-address comparison pattern.  The packet payload
 *                      is the bit pattern against which to compare data addresses.
 *                      The most-significant 13 bits are formatted like a HOP
 *                      constant (containing only the DM and DS fields),
 *                      while the least-significant 13 bits are formatted like
 *                      an instruction (opcode + operand), because those are the 4
 *                      fields specified by the controls on the MLDD panel.
 *      Channel 003:    Set an instruction-address comparison pattern.  The packet
 *                      is formatted like a HOP constant, and provides the payload.
 *                      Only the IM, IS, S, and LOC fields are significant.
 *      Channel 004:    A data value for saving to the current data address (set by
 *                      channel 002 above).  The payload is the 26 bits
 *                      of a pattern for comparison to data.
 *      Channel 005:    Settings from the DISPLAY MODE area of the MLDD, and a
 *                      few other controls whose states we'd like preserved
 *                      if it should happen that the front-panel emulation is
 *                      exited and then restarted during a test procedure:
 *                      Bits D2,D1,D0   0 = PROG-CYCLE REPEAT
 *                                      1 = PROG-CYCLE SINGLE STEP
 *                                      2 = PROG-CYCLE ADR HOLD
 *                                      3 = DISPLAY SINGLE
 *                                      4 = DISPLAY REPEAT
 *                      Bit D3          0 = ADDRESS COMPARE INS
 *                                      1 = ADDRESS COMPARE DATA
 *                      Bits D5,D4      0 = NONE
 *                                      1 = A13 IA
 *                                      2 = A13 DATA
 *                                      3 = TRS
 *                      Bit D6          REPEAT (MLDD MEMORY LOADER area)
 *                      Bit D7          CST (PD PROGRAM CONTROL area)
 *                      Bit D8          MAN CST (PD PROGRAM CONTROL area)
 *                      Bit D9          ML (1) vs DD (0) (TRMC MODE)
 *                      Bit D10         ACC DISPLAY ENABLE (CE ACCUMULATOR area)
 *                      Bit D11         MEM ADD REG (PD DATA area)
 *      Channel 600:    Set the data-comparison mode.  The payload is ignored.
 *      Channel 601:    Set the instruction-comparison mode.  The payload is ignored.
 *      Channel 602:    Inhibit interrupts.  The payload is the 16-bit mask (aligned
 *                      at the least-significant bit) of interrupts to inhibit.
 *      Channel 603:    Step a single instruction.
 *      Channel 604:    Reset the CPU.
 *      Channel 605:    Request status.
 *      Channel 606:    Width of typewriter carriage, in characters.
 *      Channel 607:    Width of typewriter tab stop, in characters.
 *
 * Type 101 (from CPU emulation to panel emulation):
 *      Channel 000:    CPU is paused.
 *      Channel 001:    CPU is running.
 *      Channel 002:    Current data address (same format as i/o type 100 channel 002).
 *      Channel 003:    Current instruction address (same format as i/o type 100 channel 003).
 *      Channel 004:    Current data value.
 *      Channel 005:    Current DISPLAY MODE settings (same format as i/o type 100 channel 005).
 *
 *      Channel 600:    Current accumulator value.
 *      Channel 601:    Current data from the data-address comparison pattern.
 *      Channel 602:    Current data-address comparison pattern.
 *      Channel 603:    Current instruction-address comparison pattern.
 *      Channel 604:    Last PROG REG A configuration received by CPU.
 *      Channel 605:    Last PROG REG B configuration received by CPU.
 */

int ServerBaseSocket = -1;
int PortNum = 19653;
typedef struct
{
  int Listener;
  int disabled;
} Listener_t;
Listener_t Listeners[MAX_LISTENERS];
int NumListeners = 0;
#define MAX_INPACKET_SIZE 1800
uint8_t inPackets[MAX_LISTENERS][MAX_INPACKET_SIZE];
int inPacketSizes[MAX_LISTENERS] =
  { 0 };

static int newConnect = 0;
void
connectCheck(void)
{
  int i, j;
  char *reassigned = "";
  for (j = 0; j < NumListeners; j++)
    if (Listeners[j].disabled)
      break;
  if (j < MAX_LISTENERS)
    {
      i = accept(ServerBaseSocket, NULL, NULL);
      if (i > 0)
        {
          UnblockSocket(i);
          Listeners[j].disabled = 0;
          Listeners[j].Listener = i;
          inPacketSizes[j] = 0;
          if (j < NumListeners)
            {
              reassigned = " (reassigned)";
            }
          else
            {
              NumListeners++;
            }
          printf("\nConnected to peripheral #%d%s on handle %d.\n", j,
              reassigned, i);
          newConnect = 1;
        }
      else if (i == -1 && errno != EAGAIN)
        {
          printf("\nVirtual wire (accept) error: %s\n", strerror(errno));
        }
    }
}

// Add a 6-byte chunk to the output packet. First set outPacketSize=0; then
// call formatPacket() up to MAX_CHUNKS_PER_PACKET times.  Then send()
// outPacket[].
#define MAX_CHUNKS_PER_PACKET 32
static int outPacketSize = 0;
static uint8_t outPacket[6 * MAX_CHUNKS_PER_PACKET];
void
formatPacket(int ioType, int channel, int payload, int isMask)
{
  int id = 0;
  outPacket[outPacketSize++] = (isMask ? 0300 : 0200) | ((ioType << 3) & 0070)
      | (id & 0007);
  outPacket[outPacketSize++] = channel & 0177;
  outPacket[outPacketSize++] = ((channel & 0600) >> 2)
      | ((payload >> 21) & 0037);
  outPacket[outPacketSize++] = (payload >> 14) & 0177;
  outPacket[outPacketSize++] = (payload >> 7) & 0177;
  outPacket[outPacketSize++] = payload & 0177;
}

// Compute parity of a 6-bit value.  The value returned is suitable for direct
// insertion into an interrupt latch after a PRS instruction.
int
oddParity6(int value)
{
  value ^= (value >> 1) ^ (value >> 2) ^ (value >> 3) ^ (value >> 4) ^ (value >> 5);
  value = 1 & ~value;
  if (value)
    return (0004000000 >> 1);
  else
    return (0000000000 >> 1);
}

// Once the server system has been activated, call this function once after
// emulation of each LVDC/PTC instruction to take care of any pending
// virtual-wire actions.  Returns 0 on success, non-zero on error.
typedef struct
{
  int valid;
  int source;
  int ioType;
  int channel;
  int mask;
} pendingMask_t;
pendingMask_t pendingMasks[MAX_LISTENERS] =
  {
    { 0 } };
static int needStatus = 0;
int printerOctalMode = 0;
static const int octalPATN[] = {
    0120300000>>1, 0130300000>>1, 0120300000>>1, 0130300000>>1, 0160300000>>1, 0170300000>>1, 0160300000>>1, 0170300000>>1
};
int
pendingVirtualWireActivity(void /* int id, int mask */)
{
  int i, j, received, ioType, payload, channel;
  // For a general-purpose function, the following would be a
  // function argument, but for an LVDC server they always have the
  // same values, so it would be kind of pointless for them to be anything
  // other than constants.
  int mask;

  retryStatus: ;
  received = 0;
  ioType = -1;
  mask = 0377777777;
  outPacketSize = 0;
  // Format the output packet.
  if (needStatus || newConnect || panelPause == 2 || panelPause == 4)
    {
      uint16_t instruction = 0;
      int data = -1, hop = -1, hopd = -1, dataReadback = -1, datapat = -1,
          inspat = -1;
      int displayModePayload = -1, progRegA = -1, progRegB = -1;
      hopStructure_t hs =
        { 0 };
      if (needStatus != 3 && needStatus != 4 && needStatus != 5)
        hop = state.hop;
      if (hop != -1 && !parseHopConstant(hop, &hs))
        if (!fetchInstruction(hs.im, hs.dm, hs.s, hs.loc, &instruction,
            &instructionFromDataMemory))
          {
            int opcode = instruction & 0x0F;
            int a9 = (instruction >> 4) & 1;
            int a81 = (instruction >> 5) & 0xFF;
            hopd = (state.hop & 0377760000) | instruction;
            if ((ptc && (opcode == 01 || opcode == 05)) || opcode == 04
                || opcode == 010 || opcode == 012 || opcode == 014
                || opcode == 016)
              {
                // These are operators whose operands are not variables.
              }
            else if (needStatus != 2)
              {
                if (fetchData(hs.dm, a9, hs.ds, a81, &data,
                    &dataFromInstructionMemory))
                  data = 0;
              }
          }
      if (needStatus == 3)
        datapat = panelPatternDataAddress;
      if (needStatus == 4)
        inspat = panelPatternInstructionAddress;
      if (needStatus == 2 || newConnect || needStatus == 5)
        {
          if (needStatus == 2 || newConnect)
            {
              inspat = panelPatternInstructionAddress;
              datapat = panelPatternDataAddress;
              displayModePayload = panelDisplayModePlus;
              progRegA = state.cio[0214];
              progRegB = state.cio[0220];
            }
          dataReadback = -1;
          if (panelPatternDataAddress != -1)
            {
              if (fetchData(panelPatternDM, 0, panelPatternDS, panelPatternDLOC,
                  &dataReadback, &dataFromInstructionMemory))
                dataReadback = 0;
            }
        }
      formatPacket(5, (panelPause == 0 || panelPause == 4) ? 001 : 000, 0, 0);
      if (hop != -1)
        formatPacket(5, 003, state.hop, 0);
      if (hopd != -1)
        formatPacket(5, 002, hopd, 0);
      if (data != -1)
        formatPacket(5, 004, data, 0);
      if (displayModePayload != -1)
        formatPacket(5, 005, displayModePayload, 0);
      formatPacket(5, 0600, state.acc, 0);
      if (progRegA != -1)
        formatPacket(5, 0604, progRegA, 0);
      if (progRegB != -1)
        formatPacket(5, 0605, progRegB, 0);
      if (inspat != -1)
        formatPacket(5, 0603, inspat, 0);
      if (datapat != -1)
        formatPacket(5, 0602, datapat, 0);
      if (dataReadback != -1)
        formatPacket(5, 0601, dataReadback, 0);
      needStatus = 0;
      newConnect = 0;
    }
  // Take care of any virtual-wire outputs needed.  The changes (triggered by
  // the last LVDC/PTC instruction executed) have stuck the necessary info in
  // the global "state" structure.  Note that any given instruction can flag
  // at _most_ one of state.pioChange, .cioChange, or .prsChange.  Moreover,
  // packets are guaranteed to be delivered in the same order generated (by
  // any given source), so there's no possibility of getting anything
  // out of order here.
  if (state.pioChange != -1)
    {
      ioType = 0;
      channel = state.pioChange;
      payload = state.pio[channel];
      state.pioChange = -1;
    }
  else if (state.cioChange != -1)
    {
      ioType = 1;
      channel = state.cioChange;
      payload = state.cio[channel];
      state.cioChange = -1;
      // If the CIO was something that should have made the typewriter, plotter,
      // or printer busy, we fake that up right here, since otherwise there
      // wouldn't be enough time to allow the PTC front-panel emulation to
      // report back that the device wasn't busy.
      if (channel == 0144 || channel == 0150)
        {
          state.bbPlotter = 2;
          state.busyCountPlotter = PERIPHERAL_BUSY_CYCLES;
        }
      else if (channel == 0160)
        {
          state.bbPrinter = 1;
          state.busyCountPrinter = PERIPHERAL_BUSY_CYCLES;
          state.cio[0154] = (payload & 0374000000) | (0002100000 >> 1) | oddParity6((payload >> 20) & 077);
          state.lastWasPrinter = 1;
        }
      else if (channel == 0164)
        {
          printerOctalMode = 1;
          state.cio264Buffer = 0;
          state.cio[0264] = 0;
          state.lastWasPrinter = 1;
        }
      else if (channel == 0170)
        {
          printerOctalMode = 0;
          state.cio264Buffer = 0;
          state.cio[0264] = 0;
          state.lastWasPrinter = 1;
        }
      else if (channel == 0120 || channel == 0124 || channel == 0130 || channel == 0134)
        {
          state.bbTypewriter = 4;
          state.lastWasPrinter = 0;
          if (typewriterCharsInLine >= typewriterMargin)
            {
              dPrintoutsTypewriter("VW HIT MARGIN or RETURN");
              state.busyCountTypewriter = CARRIAGE_RETURN_BUSY_CYCLES;
              typewriterCharsInLine = 0;
            }
          else
            {
              state.busyCountTypewriter = PERIPHERAL_BUSY_CYCLES;
              dPrintoutsTypewriter("VW CIO 120/124/130/134");
            }
        }
    }
  else if (state.prsChange != -1)
    {
      int i;

      ioType = 2;
      channel = state.prsChange;
      payload = state.prs[channel];
      state.prsChange = -1;
      state.bbPrinter = 1;
      state.prsParityDelayCount = 0;

      state.cio[0154] = 0;
      if (channel == 0774) // Group mark.
        {
          state.busyCountPrinter = MEDIUM_BUSY_CYCLES;
          state.cio[0154] |= 0000700000 >> 1;
          state.prsDelayedParity[1] = oddParity6(000);
          state.prsDelayedParity[2] = oddParity6(000);
          state.prsDelayedParity[3] = oddParity6(000);
        }
      else if (printerOctalMode)
        {
          state.busyCountPrinter = PERIPHERAL_BUSY_CYCLES;
          for (i = 0; i <= 24; i += 3)
            {
              int octal = ((payload << i) & 0340000000) >> 23;
              state.cio[0154] |= octalPATN[octal];
              if (i == 3)
                state.prsDelayedParity[1] = oddParity6(octal);
              else if (i == 18)
                {
                  if (state.inhibit250)
                    state.prsDelayedParity[2] = oddParity6(octal);
                  else
                    {
                      // I have no rationale for this whatever.  I was
                      // sure it should be oddParity6(octal), *regardless*
                      // of the state of inhibit250.  It undoubtedly means
                      // that my whole rationale for how to compute the
                      // PRS check parity is wrong ... perhaps it will be
                      // figured out and corrected later.  Adding this is
                      // purely an ad hoc measure to get test L34P9 in the
                      // PAST program to pass.
                      state.prsDelayedParity[2] = oddParity6(000);
                    }
                }
              else if (i == 24)
                {
                  if (state.inhibit250)
                    state.prsDelayedParity[3] = oddParity6(octal);
                  else
                    state.prsDelayedParity[3] = oddParity6(000);
                }
            }
        }
      else // BCD mode
        {
          state.busyCountPrinter = PERIPHERAL_BUSY_CYCLES;
          for (i = 0; i <= 18; i += 6)
            {
              int ba8421 = (payload << i) & (0770000000 >> 1);
              state.cio[0154] |= ba8421;
              state.cio[0154] |= 0000300000 >> 1;
              if (i == 6)
                state.prsDelayedParity[1] = oddParity6(ba8421 >> 20);
              else if (i == 18)
                {
                  state.prsDelayedParity[2] = oddParity6(ba8421 >> 20);
                  state.prsDelayedParity[3] = oddParity6(ba8421 >> 20);
                }
            }
        }
    }
  if (ioType >= 0)
    {
      if ((mask & 0377777777) != 0377777777)
        formatPacket(ioType, channel, mask, 1);
      formatPacket(ioType, channel, payload, 0);
    }

  // Take care of any network stuff needed.
  connectCheck();
  // Receive data.
  for (i = 0; i < NumListeners; i++)
    if (!Listeners[i].disabled)
      {
        j = recv(Listeners[i].Listener, &inPackets[i][inPacketSizes[i]],
        MAX_INPACKET_SIZE - inPacketSizes[i], 0);
        if (j == -1 && errno != EAGAIN)
          {
            printf("Peripheral handle #%d error message (by recv: %s).\n", i,
                strerror(errno));
            if (errno == ENOTCONN)
              {
                printf("Disconnected socket #%d, handle %d.\n", i,
                    Listeners[i].Listener);
                Listeners[i].disabled = 1;
              }
          }
        else if (j > 0)
          {
            received += j;
            inPacketSizes[i] += j;
          }
      }
  // Send data.  I suppose I should check that the entire packet is sent,
  // and do something about it if not, but I'm not sure what.  I'll
  // come back to that later.
  for (i = 0; i < NumListeners; i++)
    if (!Listeners[i].disabled)
      {
        j = send(Listeners[i].Listener, outPacket, outPacketSize, MSG_NOSIGNAL);
        if (j == -1)
          {
            printf("Peripheral handle #%d error message (by send: %s).\n", i,
                strerror(errno));
            if (errno == ENOTCONN || errno == EPIPE)
              {
                printf("Disconnected socket #%d, handle %d.\n", i,
                    Listeners[i].Listener);
                Listeners[i].disabled = 1;
              }
          }
        else if (j >= 0 && j < outPacketSize)
          printf("Message to peripheral handle #%d incomplete.\n", i);
      }
  // The following is just a little trick:  a delay to allow the UI
  // some time to take care of its business after receiving the data.
  // Undoubtedly there are better ways of handling this.
  if (outPacketSize)
    {
      void
      sleepMilliseconds(unsigned Milliseconds);
      sleepMilliseconds(5);
    }

  // Parse the received data.  All we have to do is to read any
  // inputs and stick them in the global "state" structure, where
  // the LVDC emulation will see them at some point.  By the way,
  // note that while there could be buffered output data even if
  // received==0, previous iterations will have insured that there
  // can't be enough buffered yet to form complete packets.
  if (received != 0)
    {
      //printf("Received %d bytes.\n", received);
      for (i = 0; i < NumListeners; i++)
        {
          int size, offsetIntoPacket, offsetIntoBuffer, offset;
          int source, isMask, ioType, channel, value, firstByte;
          if (Listeners[i].disabled)
            continue;
          size = inPacketSizes[i];
          offsetIntoBuffer = 0;
          offset = 0;
          retry: ;
          offsetIntoPacket = 0;
          for (; offset < size; offset++)
            {
              uint8_t currentByte;
              currentByte = inPackets[i][offset];
              //printf("%02X %03o\n", currentByte, currentByte);
              // Check for corruption.
              firstByte = currentByte & 0x80;
              if (!firstByte && !offsetIntoPacket)
                {
                  printf("Corrupt input packet.\n");
                  offset++;
                  // Mark corrupted stuff for removal from buffer.
                  offsetIntoBuffer = offset;
                  goto retry;
                }
              else if (firstByte && offsetIntoPacket)
                {
                  printf("Corrupt input packet.\n");
                  // Mark corrupted stuff for removal from buffer.
                  offsetIntoBuffer = offset;
                  goto retry;
                }
              switch (offsetIntoPacket)
                {
              case 0:
                offsetIntoPacket++;
                isMask = 0x40 & currentByte;
                ioType = 0x07 & (currentByte >> 3);
                source = 0x07 & currentByte;
                break;
              case 1:
                offsetIntoPacket++;
                channel = 0x7F & currentByte;
                break;
              case 2:
                offsetIntoPacket++;
                channel |= ((currentByte << 2) & 0x180);
                value = (currentByte & 0x1F) << 21;
                break;
              case 3:
                offsetIntoPacket++;
                value |= currentByte << 14;
                break;
              case 4:
                offsetIntoPacket++;
                value |= currentByte << 7;
                break;
              case 5:
                offsetIntoPacket = 0;
                value |= currentByte;
                // If we've gotten to here, then it means that the packet has
                // been completely parsed, and we can mark everything so-far
                // processed for removal from the input buffer.
                offsetIntoBuffer = offset + 1;
                // If this is a mask, we can't do anything with it immediately,
                // and so set it aside for later.  Otherwise, apply the pending
                // mask (if any) to the data and update the i/o buffers in
                // the state structure.
                if (isMask)
                  {
                    pendingMasks[i].valid = 1;
                    pendingMasks[i].source = source;
                    pendingMasks[i].ioType = ioType;
                    pendingMasks[i].channel = channel;
                    pendingMasks[i].mask = value;
                  }
                else
                  {
                    int mask = 0377777777;
                    if (pendingMasks[i].valid)
                      {
                        if (pendingMasks[i].source != source)
                          printf("Input mask does not match source.\n");
                        else if (pendingMasks[i].ioType != ioType)
                          printf("Input mask does not match i/o type.\n");
                        else if (pendingMasks[i].channel != channel)
                          printf("Input mask does not match channel.\n");
                        else
                          mask = pendingMasks[i].mask;
                        pendingMasks[i].valid = 0;
                      }
                    switch (ioType)
                      {
                    case 0: // PIO
                      if (channel < 0 || channel > 0777)
                        printf("Input PIO channel out of range.\n");
                      printf(
                          "PIO-%03o changed from %09o to %09o with mask %09o.\n",
                          channel, state.pio[channel], value, mask);
                      state.pio[channel] = (state.pio[channel] & ~mask)
                          | (value & mask);
                      break;
                    case 1: // CIO
                      if (channel < 0 || channel > 0777)
                        printf("Input CIO channel out of range.\n");
                      printf(
                          "CIO-%03o changed from %09o to %09o with mask %09o.\n",
                          channel, state.cio[channel], value, mask);
                      state.cio[channel] = (state.pio[channel] & ~mask)
                          | (value & mask);
                      break;
                    case 2: // PRS
                      printf(
                          "PRS data received from peripheral, which is not allowed.\n");
                      break;
                    case 3: // INT
                      printf(
                          "INT data received from peripheral, which is not yet implemented.\n");
                      break;
                    case 4: // Commands directly from PTC panel emulation
                      if (channel == 0)
                        {
                          printf("PTC panel commands halt.\n");
                          panelPause = 2;
                        }
                      else if (channel == 1)
                        {
                          printf("PTC panel commands resumption.\n");
                          panelPause = 4;
                        }
                      else if (channel == 2)
                        {
                          int residual, opcode;
                          panelPatternDM = (value >> 17) & 1;
                          panelPatternDS = (value >> 20) & 017;
                          residual = (value >> 4) & 1;
                          panelPatternDLOC = (value >> 5) & 0377;
                          opcode = value & 017;
                          printf(
                              "PTC panel new DATA ADDRESS %o-%02o, OPCODE=%02o, OPERAND=%03o.\n",
                              panelPatternDM, panelPatternDS, opcode,
                              (residual << 8) | panelPatternDLOC);
                          panelPatternDataAddress = value;
                          if (residual)
                            {
                              if (ptc)
                                panelPatternDM = 0;
                              panelPatternDS = 017;
                            }
                          needStatus = 3;
                        }
                      else if (channel == 3)
                        {
                          printf(
                              "PTC panel new INSTRUCTION ADDRESS %o-%02o-%o-%03o.\n",
                              (value >> 25) & 1, (value >> 2) & 017,
                              (value >> 6) & 1, (value >> 7) & 0377);
                          panelPatternInstructionAddress = value;
                          needStatus = 4;
                        }
                      else if (channel == 4)
                        {
                          printf("PTC new DATA %09o.\n", value);
                          panelPatternDataValue = value;
                          state.core[panelPatternDM][panelPatternDS][2][panelPatternDLOC] =
                              value;
                          state.core[panelPatternDM][panelPatternDS][0][panelPatternDLOC] =
                              -1;
                          state.core[panelPatternDM][panelPatternDS][1][panelPatternDLOC] =
                              -1;
                          needStatus = 5;
                        }
                      else if (channel == 5)
                        {
                          /*
                           char *dsStrings[] =
                           { "NONE", "A13 IA", "A13 DATA", "TRS" };
                           char *acStrings[] =
                           { "INS", "DATA" };
                           char *mcStrings[] =
                           { "PROG-CYCLE REPEAT", "PROG-CYCLE SINGLE-STEP",
                           "PROG-CYCLE ADR-HOLD", "DISPLAY SINGLE",
                           "DISPLAY REPEAT" };
                           */
                          panelDisplayModePlus = value;
                          panelModeControl = value & 7;
                          panelAddressCompare = (value >> 3) & 1;
                          panelDisplaySelect = (value >> 4) & 3;
                          if (panelModeControl >= 3)
                            panelPause = 0;
                          /*
                           printf(
                           "PTC panel:  DISPLAY SELECT = %s, ADDRESS COMPARE = %s, MODE CONTROL = %s\n",
                           dsStrings[panelDisplaySelect],
                           acStrings[panelAddressCompare],
                           mcStrings[panelModeControl]);
                           */
                        }
                      else if (channel == 0603)
                        {
                          printf("PTC panel requesting single step.\n");
                          panelPause = 1;
                        }
                      else if (channel == 0604)
                        {
                          printf("PTC panel requesting reset.\n");
                          //state.restart = 1;
                          state.hop = 0;
                          panelPause = 0;
                        }
                      else if (channel == 0605)
                        {
                          printf("PTC panel requesting status.\n");
                          needStatus = 1;
                        }
                      else if (channel == 0606)
                        {
                          printf("PTC typewriter carriage width %d.\n", value);
                          typewriterMargin = value;
                        }
                      else if (channel == 0607)
                        {
                          printf("PTC typewriter tab width %d.\n", value);
                          typewriterTabStop = value;
                        }
                      else
                        printf("Command %03o/%09o received from PTC panel\n",
                            channel, value);
                      break;
                    case 5: // Status sent directly from CPU to PTC panel emulation.
                      printf(
                          "Illegal status info received ... should be output only.\n");
                      break;
                    default:
                      printf("Unrecognized input i/o type.\n");
                      break;
                      }
                  }
                break;
              default:
                break;
                }
            }
          // Everything from the input buffer than cat be processed has
          // been.  So removed that stuff from the buffer, leaving everything
          // not yet processed.
          if (offsetIntoBuffer > 0)
            {
              size = size - offsetIntoBuffer;
              if (size > 0)
                memcpy(inPackets[i], &inPackets[i][offsetIntoBuffer], size);
              inPacketSizes[i] = size;
            }
        }
    }

  // If we've gotten to this point and needStatus is non-zero, due to something
  // received from the panel or (I suppose) other peripherals that requires
  // informing the panel of the changed status.  We want to take care of this
  // right away rather than sitting through another potential instruction cycle.
  if (needStatus)
    goto retryStatus;
  return (0);
}

/////////////////////////////////////////////////////////////////////////////////
// Portable functions (*NIX and Win32) for working with sockets.

// Used for socket-operation error codes.
int virtualWireErrorCodes = 0;

/*
 The usage is this:

 1. Servers:  Create a socket, suitable for clients to connect to,
 with EstablishSocket().  Call accept(,NULL,NULL) to listen for a new
 client; the function will return whether or not there is a new
 listener, with either -1 (no new client) or else the new socket
 number (>=0); the first parameter is the socket number created by
 EstablishSocket().   The socket should be unblocked with UnblockSocket().

 2. Clients:  Connect to a server with CallSocket().  The function will
 return whether or not the connection succeeded, with either -1
 (failure) or else with the connection socket number.

 3. Either the client or server can then proceed to perform i/o using
 send() or recv() to all connected servers or clients.

 Server example:

 int ServerBaseSocket;
 #define MAX_LISTENERS 5
 int ListeningSockets[MAX_LISTENERS], NumListeners = 0;
 int PortNum = ... something ...;
 int i, j;

 ServerBaseSocket = EstablishSocket (PortNum, MAX_LISTENERS);
 if (ServerBaseSocket == -1)
 ... unrecoverable error ...
 // Main activity loop
 for (;;)
 {
 ...
 // Periodically do this:
 if (NumListeners < MAX_LISTENERS)
 {
 i = accept (ServerBaseSocket, NULL, NULL);
 if (i != -1)
 {
 UnblockSocket (i);
 Listeners[NumListeners++] = i;
 }
 }
 ...
 // Receive data.
 for (i = 0; i < NumListeners; i++)
 ... receive data from listener i using recv() ...
 ...
 // Send data.
 for (i = 0; i < NumListeners; i++)
 ... transmit data to listener i using send() ...
 ...
 }

 Client Example:

 int ConnectionSocket = -1;

 // Main activity loop.
 for (;;)
 {
 ...
 // Try for a connection.
 if (ConnectionSocket == -1)
 ConnectionSocket = CallSocket (Hostname, Portnum);
 ...
 // Perform i/o with send/recv:
 if (ConnectionSocket != -1)
 ... send/recv ...
 ...
 }

 These examples don't illustrate what to do in case of broken
 connections.  (I don't actually KNOW what to do.)

 */

//----------------------------------------------------------------------
// The following are the only two socket functions that internally differ
// between *nix and Win32.
// Initialize the socket system.  Return 0 on success.
static int SocketSystemInitialized = 0;
int
InitializeSocketSystem(void)
{
  if (SocketSystemInitialized)
    return (0);
  SocketSystemInitialized = 1;
#if defined(unix) || (defined(__APPLE__) && defined(__MACH__))
  return (0);
#else
  WSADATA wsaData;
  return (WSAStartup (MAKEWORD (2, 0), &wsaData));
#endif
}

// Set an existing socket to be non-blocking.
void
UnblockSocket(int SocketNum)
{
#if defined(unix) || (defined(__APPLE__) && defined(__MACH__))
  fcntl(SocketNum, F_SETFL, O_NONBLOCK);
#else
  unsigned long nonBlock = 1;
  ioctlsocket (SocketNum, FIONBIO, &nonBlock);
#endif
}

//----------------------------------------------------------------------
// Function for creating a socket.  Copied from
// http://world.std.com/~jimf/papers/sockets/sockets.html, and then
// modified somewhat for my own purposes.  The parameters:
//
//      portnum         The port on which we're going to listen.
//      MaxClients      Max number of queued connections.  (5 is good.)
//
// Returns -1 on error, or the new socket number (>=0) if successful.

#define MAXHOSTNAME 256
int
EstablishSocket(unsigned short portnum, int MaxClients)
{
  char myname[MAXHOSTNAME + 1];
  int s, i;
  struct sockaddr_in sa;
  struct hostent *hp;

  InitializeSocketSystem();

  memset(&sa, 0, sizeof(struct sockaddr_in)); /* clear our address */
  gethostname(myname, MAXHOSTNAME); /* who are we? */
  hp = gethostbyname(myname); /* get our address info */
  if (hp == NULL) /* we don't exist !? */
    {
      char s[32];
      switch (h_errno)
        {
      case HOST_NOT_FOUND:
        strcpy(s, "Host not found");
        break;
      case NO_ADDRESS:
        strcpy(s, "No address");
        break;
        //case NO_DATA: strcpy(s, "No data"); break;
      case NO_RECOVERY:
        strcpy(s, "No recovery");
        break;
      case TRY_AGAIN:
        strcpy(s, "Try again");
        break;
      default:
        sprintf(s, "Error %d", h_errno);
        break;
        }
      fprintf(stderr, "gethostbyname (\"%s\" %d) reports %s\n", myname, portnum,
          s);
      virtualWireErrorCodes = 0x101;
      return (-1);
    }
  sa.sin_family = hp->h_addrtype; /* this is our host address */
  sa.sin_port = htons(portnum); /* this is our port number */
  if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) /* create socket */
    {
      virtualWireErrorCodes = 0x102;
      return (-1);
    }

  // Make sure to clean up after any previous disconnects of the
  // port.  Otherwise there would be a timeout until we could
  // reuse the port.
  i = 1;
  setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (const char *) &i, sizeof(int));

  if (bind(s, (struct sockaddr *) &sa, sizeof(struct sockaddr_in)) < 0)
    {
#if defined(unix) || (defined(__APPLE__) && defined(__MACH__))
      close(s);
#else
      closesocket (s);
#endif
      virtualWireErrorCodes = 0x103;
      return (-1); /* bind address to socket */
    }
  listen(s, MaxClients); /* max # of queued connects */
  // Don't want to wait when there's no incoming data.
  UnblockSocket(s);
  return (s);
}

//----------------------------------------------------------------------
// Client connection to server via socket.
// http://world.std.com/~jimf/papers/sockets/sockets.html.
// The hostname is the name of the server, either resolvable by DNS,
// or else a dotted IP number.  (The latter fails on Win32.)
// The portnum is the port-number on which the server listens.

int
CallSocket(char *hostname, unsigned short portnum)
{
  struct sockaddr_in sa;
  struct hostent *hp;
  //int a;
  int s;

  InitializeSocketSystem();

  if ((hp = gethostbyname(hostname)) == NULL)
    {
      /* do we know the host's */
      //errno= ECONNREFUSED; /* address? */
      virtualWireErrorCodes = 0x301;
      return (-1); /* no */
    }

  memset(&sa, 0, sizeof(sa));
  memcpy((char *) &sa.sin_addr, hp->h_addr, hp->h_length); /* set address */
  sa.sin_family = hp->h_addrtype;
  sa.sin_port = htons((u_short) portnum);
  if ((s = socket(hp->h_addrtype, SOCK_STREAM, 0)) < 0) /* get socket */
    {
      virtualWireErrorCodes = 0x302;
      return (-1);
    }
  if (connect(s, (struct sockaddr *) &sa, sizeof(sa)) < 0)
    {
      /* connect */
#if defined(unix) || (defined(__APPLE__) && defined(__MACH__))
      close(s);
#else
      closesocket (s);
#endif
      virtualWireErrorCodes = 0x303;
      return (-1);
    }
  UnblockSocket(s);
  return (s);
}
