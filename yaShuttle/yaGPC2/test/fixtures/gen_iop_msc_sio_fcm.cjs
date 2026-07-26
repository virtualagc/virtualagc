// Hand-assembles a tiny AP-101 program that activates the MSC processor
// via a CPU `PC` (Programmed Control I/O) instruction and lets it
// execute one real MSC instruction (@SIO) through the actual IOP
// round-robin scheduler (IOP#execProcessors, driven each cycle from
// AP101#exec1), closing the last documented Phase 11 gap: IOP/BCE/MSC
// execution was never exercised through the full run() pipeline before.
//
//   0x0000: @SIO (0xE400)     -- MSC instruction placed for the IOP to
//                                 fetch from its PC register (defaults 0)
//   0x0010: LHI R1,0x9204      -- R1 = cmd "LOAD MSC BUSY"
//   0x0012: PC  R1,R0          -- sets IOP.regBusyWait bit0 (MSC busy)
//   0x0013: XR  R7,R7          -- filler (let IOP's round-robin scheduler
//   0x0014: XR  R7,R7             reach the MSC's slice, step 4)
//   0x0015: LHI R3,0x1004      -- R3 = cmd "READ STATUS4(BUSY/WAIT)"
//   0x0017: PC  R3,R4          -- R4 = regBusyWait's value post-@SIO
//   0x0018: LHI R5,0x0200      -- halt-code pointer
//   0x001A: SVC 0(R5)          -- PROGRAM HALT
//   0x0200: 0x0015             -- PROGRAM HALT SVC code
//
// Expected: R4 == 0x00000001 (MSC's busy bit, set at step2, unchanged by
// @SIO since ACC==0 so ORing it into regBusyWait is a no-op) on BOTH
// implementations if IOP dispatch/scheduling/@SIO exec all match.
const fs = require('fs');

const halfwords = new Array(0x201).fill(0);
halfwords[0x000] = 0xE400;            // @SIO
halfwords[0x010] = 0xE8F3 | (1 << 8); // LHI R1,I
halfwords[0x011] = 0x9204;
halfwords[0x012] = 0xD8E8 | (1 << 8) | 0; // PC R1,R0
halfwords[0x013] = 0x70E0 | (7 << 8) | 7; // XR R7,R7
halfwords[0x014] = 0x70E0 | (7 << 8) | 7; // XR R7,R7
halfwords[0x015] = 0xE8F3 | (3 << 8); // LHI R3,I
halfwords[0x016] = 0x1004;
halfwords[0x017] = 0xD8E8 | (3 << 8) | 4; // PC R3,R4
halfwords[0x018] = 0xE8F3 | (2 << 8); // LHI R2,I
halfwords[0x019] = 0x0200;
halfwords[0x01A] = 0xC9F8 | 2;        // SVC D2(B2=2)  (b field is only 2 bits: 0-3)
halfwords[0x01B] = 0x0000;            // D2 = 0
halfwords[0x200] = 0x0015;            // PROGRAM HALT

const buf = Buffer.alloc(halfwords.length * 2);
for (let i = 0; i < halfwords.length; i++) buf.writeUInt16BE(halfwords[i], i * 2);
fs.writeFileSync(process.argv[2] || 'iop_msc_sio.fcm', buf);
console.log('wrote', buf.length, 'bytes');
