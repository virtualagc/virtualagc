// Regenerates test/fixtures/svc_{halt,senderror,unknown}.fcm — hand-assembled
// AP-101 programs that each exercise one branch of HalUCP.handleSVC
// (gpc/halUCP.coffee), none of which any HAL/S-compiled fixture in
// gpc/gen/ reaches (they carry no .sym.json and never start an SVC).
//
// Every program is just:
//   0x0000: LHI R2, <dataAddr>   ; R2 = dataAddr << 16
//   0x0002: SVC 0(R2)            ; EA = (R2>>>16) + 0 = dataAddr
//   <dataAddr>: ...              ; SVC code (+ error descriptor, if any)
//
// Encoding derived by hand from the PackedBits descriptor strings in
// gpc/cpu_instr.coffee (LHI: '11101xxx11110011/I', SVC:
// '1100100111111abb/X') and confirmed against the live JS reference
// (node dist/gpc.js run --trace --verbose) before being adopted — see
// the yaGPC port session notes. Byte-for-byte verified against yaGPC
// across --trace/--verbose/--no-trap-svc-error variants.
//
// Usage: node gen_svc_fcms.cjs   (run from this directory; overwrites
// the checked-in .fcm files — only needed if the encoding ever changes)
const fs = require('fs');
const path = require('path');

function build(dataAt, hw) {
  const halfwords = new Array(dataAt + 2).fill(0);
  halfwords[0x00] = 0xE8F3 | (2 << 8); // LHI R2,I
  halfwords[0x01] = dataAt;            // I = data address
  halfwords[0x02] = 0xC9F8 | 2;        // SVC D2(B2=2), a=0 (non-indexed extended)
  halfwords[0x03] = 0x0000;            // D2 = 0
  for (let i = 0; i < hw.length; i++) halfwords[dataAt + i] = hw[i];
  const buf = Buffer.alloc(halfwords.length * 2);
  for (let i = 0; i < halfwords.length; i++) buf.writeUInt16BE(halfwords[i], i * 2);
  return buf;
}

const dir = __dirname;
fs.writeFileSync(path.join(dir, 'svc_halt.fcm'), build(0x100, [0x0015]));
fs.writeFileSync(path.join(dir, 'svc_senderror.fcm'), build(0x100, [0x0014, (1 << 8) | 4]));
fs.writeFileSync(path.join(dir, 'svc_unknown.fcm'), build(0x100, [0x0099]));
console.log('wrote svc_halt.fcm, svc_senderror.fcm, svc_unknown.fcm to', dir);
