// Hand-assembles a small AP-101 program exercising the --bce-network
// bridge (src/bcenet_framer.c/bcenet_transport.c) end to end on a real
// BCE bus: CPU activates the MSC via a `PC` command -> the MSC's own
// micro-program (`LBP`/`LI`/`SIO`) sets BCE 6 (DK1)'s entry point and
// starts it -> BCE 6 runs a real `#CMDI` (IUA=1) then `#TDS` (transmits
// one word, 0xBEEF, from address 0x08) -- the same "activate via CPU PC
// command, verify via a live JS reference" methodology as
// gen_iop_msc_sio_fcm.cjs, extended one level further (MSC -> BCE,
// not just CPU -> MSC).
//
// Confirmed empirically (2026-08-19), not just derived by hand:
//   - LBP/LI/SIO's own encodings, and MSC's round-robin scheduling
//     (iopls_next_slice(): BCE,BCE,BCE,MSC repeating, each BCE getting
//     exactly one turn per 33-slice major cycle) -- via a --trace run
//     reading back regBusyWait into a CPU register (see this repo's own
//     session history; the 90-instruction filler below is sized to give
//     BCE 6 two turns after activation: one for #CMDI, one for #TDS,
//     each 32 iop_exec() calls apart).
//   - The resulting UDP packet was received correctly by a raw socket
//     AND by nsts-sim-gpc's own real `com/bus.civet` Bus class directly
//     (`node -e "require('@danielx/civet/register'); const {Bus,BusMsg}
//     = require('.../com/bus.civet'); ..."`), confirming real wire-
//     format interop, not just "some bytes went out."
//   - The receive path (bcenet_transport_recv()) was verified separately
//     against a real Bus#sendMsg() call, since a batch (non-interactive,
//     non-paced) yaGPC2 run completes too fast to reliably race against
//     an external sender within one process's lifetime.
//
// Usage: node gen_bcenet_smoke_fcm.cjs [outfile.fcm]  (default bcenet_smoke.fcm)
// Manual verification only -- NOT part of `make test` (real UDP
// multicast socket use doesn't belong in the deterministic automated
// suite). See test/bcenet_smoke.sh for how to actually exercise it.
const fs = require('fs');
const halfwords = new Array(0x400).fill(0);

// MSC program (page 0; PC starts at 0 by default -- no LBP-equivalent
// needed for the MSC itself, only for the BCE it's about to start).
halfwords[0x0000] = 0xF330; halfwords[0x0001] = 0x0300; // LBP BCE6,0x300
halfwords[0x0002] = 0xEF40;                              // LI 64 (ACC = bit6)
halfwords[0x0003] = 0xE400;                              // SIO (regBusyWait |= ACC)
halfwords[0x0004] = 0x0800;                              // WAT (MSC suspends itself)

// BCE 6 program at 0x300 (its PC, set by the MSC's LBP above)
halfwords[0x0300] = 0xF608; halfwords[0x0301] = 0x0000; // #CMDI u=1(IUA),i=0
halfwords[0x0302] = 0x8008;                               // #TDS count=1,d=0x08

// Data word #TDS transmits -- placed at 0x08, deliberately before the
// CPU program (0x10 onward) so the filler loop below can't clobber it.
halfwords[0x0008] = 0xBEEF;

// CPU program at 0x10
let a = 0x0010;
halfwords[a] = 0xE8F3 | (1 << 8); halfwords[a + 1] = 0x9204; a += 2; // LHI R1,0x9204 (LOAD MSC BUSY)
halfwords[a] = 0xD8E8 | (1 << 8) | 0; a += 1;                        // PC R1,R0 (start MSC)
halfwords[a] = 0xE8F3 | (3 << 8); halfwords[a + 1] = 0x8504; a += 2; // LHI R3,0x8504 (MIA XMIT ENABLE)
halfwords[a] = 0xE8F3 | (4 << 8); halfwords[a + 1] = 0x0040; a += 2; // LHI R4,0x0040
halfwords[a] = 0xF442; a += 1;                                       // SRL R4,16  (R4 = 0x00000040)
halfwords[a] = 0xD8E8 | (3 << 8) | 4; a += 1;                        // PC R3,R4 (enable BCE6 transmitter)
for (let i = 0; i < 90; i++) {
  halfwords[a] = 0x70E0 | (7 << 8) | 7; a += 1; // XR R7,R7 filler -- lets the IOP round-robin
}                                                 // scheduler give BCE6 both of its turns (~call 39, ~call 71)
halfwords[a] = 0xE8F3 | (5 << 8); halfwords[a + 1] = 0x1004; a += 2; // LHI R5,0x1004 (READ STATUS4/BUSY-WAIT)
halfwords[a] = 0xD8E8 | (5 << 8) | 6; a += 1;                        // PC R5,R6 -> R6 = regBusyWait (expect 0x41)
halfwords[a] = 0xE8F3 | (2 << 8); halfwords[a + 1] = 0x0200; a += 2; // LHI R2,0x0200
halfwords[a] = 0xC9F8 | 2; halfwords[a + 1] = 0x0000; a += 2;        // SVC 0(R2) -- PROGRAM HALT
halfwords[0x0200] = 0x0015; // PROGRAM HALT SVC code

const buf = Buffer.alloc(halfwords.length * 2);
for (let i = 0; i < halfwords.length; i++) buf.writeUInt16BE(halfwords[i], i * 2);
fs.writeFileSync(process.argv[2] || 'bcenet_smoke.fcm', buf);
console.log('wrote', buf.length, 'bytes');
