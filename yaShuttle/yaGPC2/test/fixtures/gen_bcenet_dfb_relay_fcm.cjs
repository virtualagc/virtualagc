// Relays a REAL nsts-sim-gpc test fixture (data/TEST-9011-GPC_MEMORY.dfb)
// to BCE 6 (DK1) as a real op=1 ("DATA FILL") message, matching
// meds/idp.coffee's recvDK exactly -- unlike
// gen_bcenet_smoke_fcm.cjs's single arbitrary word, a live MEDS/IDP
// instance receiving this should relay it to the MDU and show real,
// visible display content (recvDK op=1: "forward to the MDUs as a
// background DFB"). Same CPU->MSC->BCE6 activation sequence as
// gen_bcenet_smoke_fcm.cjs (see its own header comment for the
// encoding derivation), plus:
//   - MSC also runs LBB (Load BCE Base) to point BCE6's transmit base
//     at 0x500, separate from its PC (0x300) -- the message itself is
//     data, not code, and needs its own region.
//   - BCE6 uses #TDLI (long transmit, immediate 18-bit count) instead
//     of #TDS (5-bit count, max 32 words) -- a real DFB is hundreds of
//     words. bcenet_framer.c's FRAMER_MAX_WORDS and
//     bcenet_transport.c's own receive buffer were both bumped from 64
//     to 1024 words after finding this out.
//
// Confirmed empirically (2026-08-19): the resulting UDP packet, checked
// against nsts-sim-gpc's own real com/bus.civet Bus class, arrives as
// exactly 542 words (1 op word + the DFB's own 541 words) with content
// matching the source .dfb file byte-for-byte.
//
// Usage: node gen_bcenet_dfb_relay_fcm.cjs [outfile.fcm] [dfb path]
// Default dfb path: ~/donschmidt/nsts-sim-gpc/data/TEST-9011-GPC_MEMORY.dfb
// Manual verification only -- see test/bcenet_smoke.sh.
const fs = require('fs');
const os = require('os');

const dfbPath = process.argv[3] || (os.homedir() + '/donschmidt/nsts-sim-gpc/data/TEST-9011-GPC_MEMORY.dfb');
const dfb = fs.readFileSync(dfbPath);
if (dfb.length % 2 !== 0) throw new Error('DFB length not word-aligned: ' + dfb.length);
const dfbWords = dfb.length / 2;
const msgWords = 1 + dfbWords; // op word + DFB payload
const c = msgWords - 1; // #TDLI's own count-1 encoding
if (c > 0xffff) throw new Error('message too long for this encoding shortcut (c must fit in 16 bits)');

const halfwords = new Array(0x800).fill(0);

// MSC program (page 0; PC starts at 0 by default)
halfwords[0x0000] = 0xF330; halfwords[0x0001] = 0x0300; // LBP BCE6,0x300 (code)
halfwords[0x0002] = 0xF230; halfwords[0x0003] = 0x0500; // LBB BCE6,0x500 (transmit base)
halfwords[0x0004] = 0xEF40;                              // LI 64 (ACC = bit6)
halfwords[0x0005] = 0xE400;                              // SIO (regBusyWait |= ACC)
halfwords[0x0006] = 0x0800;                              // WAT (MSC suspends itself)

// BCE6 program at 0x300
halfwords[0x0300] = 0xF608; halfwords[0x0301] = 0x0000; // #CMDI u=1(IUA),i=0
halfwords[0x0302] = 0xF400; halfwords[0x0303] = c;       // #TDLI count=c+1 (valid as shown since c<=0xffff)

// Data at BASE=0x500: op word, then the DFB content verbatim.
halfwords[0x0500] = 0x0001; // op=1, DATA FILL
for (let i = 0; i < dfbWords; i++) halfwords[0x0501 + i] = dfb.readUInt16BE(i * 2);

// CPU program at 0x10
let a = 0x0010;
halfwords[a] = 0xE8F3 | (1 << 8); halfwords[a + 1] = 0x9204; a += 2; // LHI R1,0x9204 (LOAD MSC BUSY)
halfwords[a] = 0xD8E8 | (1 << 8) | 0; a += 1;                        // PC R1,R0 (start MSC)
halfwords[a] = 0xE8F3 | (3 << 8); halfwords[a + 1] = 0x8504; a += 2; // LHI R3,0x8504 (MIA XMIT ENABLE)
halfwords[a] = 0xE8F3 | (4 << 8); halfwords[a + 1] = 0x0040; a += 2; // LHI R4,0x0040
halfwords[a] = 0xF442; a += 1;                                       // SRL R4,16 (R4 = 0x40)
halfwords[a] = 0xD8E8 | (3 << 8) | 4; a += 1;                        // PC R3,R4 (enable BCE6 transmitter)
for (let i = 0; i < 150; i++) { halfwords[a] = 0x70E0 | (7 << 8) | 7; a += 1; } // filler -- see
// gen_bcenet_smoke_fcm.cjs's own comment on why this many: gives BCE6
// (and, here, MSC's extra LBB instruction) enough IOP round-robin turns.
halfwords[a] = 0xE8F3 | (5 << 8); halfwords[a + 1] = 0x1004; a += 2; // LHI R5,0x1004 (READ STATUS4)
halfwords[a] = 0xD8E8 | (5 << 8) | 6; a += 1;                        // PC R5,R6 -> R6 = regBusyWait
halfwords[a] = 0xE8F3 | (2 << 8); halfwords[a + 1] = 0x0200; a += 2; // LHI R2,0x0200
halfwords[a] = 0xC9F8 | 2; halfwords[a + 1] = 0x0000; a += 2;        // SVC 0(R2) -- HALT
halfwords[0x0200] = 0x0015;

const buf = Buffer.alloc(halfwords.length * 2);
for (let i = 0; i < halfwords.length; i++) buf.writeUInt16BE(halfwords[i], i * 2);
fs.writeFileSync(process.argv[2] || 'bcenet_dfb_relay.fcm', buf);
console.log('wrote', buf.length, 'bytes (' + dfbWords + ' DFB words from ' + dfbPath + ')');
