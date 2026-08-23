// Generates MCM/MemoryBus reference fixtures from the real gpc/mcm.coffee
// and gpc/membus.coffee. Run:
//   node yaGPC/test/gen_mcm_membus_fixtures.cjs > fixtures.json
const path = require('path');
const esbuild = require('esbuild');
const coffeeScriptPlugin = require('esbuild-coffeescript');

// Reference-simulator root.  YAGPC_REF_ROOT selects WHICH gpc these
// fixtures are generated from; without it the historical default is
// yaShuttle/, whose gpc/ and com/ are symlinks to a frozen checkout.
// That frozen gpc carries bugs since fixed upstream (it computed the
// RS-form auto-index write-back from the EA rather than the index
// register's own address field), so fixtures cut from it assert the
// bug and fail against a corrected yaGPC2.  Name the oracle explicitly.
const root = process.env.YAGPC_REF_ROOT
  ? path.resolve(process.env.YAGPC_REF_ROOT)
  : path.resolve(__dirname, '..', '..');

function mulberry32(seed) {
  let a = seed;
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

async function build(entry) {
  const result = await esbuild.build({
    platform: 'node',
    entryPoints: [path.join(root, entry)],
    bundle: true,
    format: 'cjs',
    write: false,
    plugins: [coffeeScriptPlugin({})],
    resolveExtensions: ['.coffee', '.js'],
    logLevel: 'silent',
  });
  const code = result.outputFiles[0].text;
  const mod = { exports: {} };
  new Function('module', 'exports', 'require', code)(mod, mod.exports, require);
  return mod.exports;
}

async function main() {
  const { MCM } = await build('gpc/mcm.coffee');
  const { MemoryBus } = await build('gpc/membus.coffee');

  const rng = mulberry32(999);
  const randU16 = () => Math.floor(rng() * 65536);
  const randU32 = () => Math.floor(rng() * 4294967296) >>> 0;

  // --- MCM (small word count so we can also exercise get16's 0x7ffff mask
  // wrap-around and out-of-range behavior cheaply) ---
  const wordCount = 4096; // 4096 words = 8192 halfwords
  const mcm = new MCM(wordCount);

  const mcmCases = [];
  // Sequential writes then reads, plus some overlapping/protected addrs.
  const addrs = [];
  for (let i = 0; i < 300; i++) addrs.push(Math.floor(rng() * wordCount * 2));
  addrs.push(0, 1, wordCount * 2 - 1, wordCount * 2 - 2);

  for (const addr of addrs) {
    const v = randU16();
    const ok = mcm.set16(addr, v, true, false);
    mcmCases.push({ op: 'set16', addr, v, ok, after16: mcm.get16(addr, false) });
  }
  for (const addr of addrs) {
    if (addr % 2 !== 0) continue;
    const v = randU32();
    const ok = mcm.set32(addr, v, true, false);
    mcmCases.push({ op: 'set32', addr, v, ok, after32: mcm.get32(addr, false) });
  }
  // Store-protect: protect a few addrs, verify blocked writes.
  const protectCases = [];
  const protAddrs = [10, 11, 20, 4095, 8000];
  for (const a of protAddrs) {
    mcm.setStoreProtect(a, true);
    const before = mcm.get16(a, false);
    const ok16 = mcm.set16(a, 0xbeef, true, false);
    const after16 = mcm.get16(a, false);
    protectCases.push({ addr: a, before, ok16, after16, prot: mcm.getStoreProtect(a) });
    mcm.setStoreProtect(a, false);
    const ok16b = mcm.set16(a, 0xcafe, true, false);
    protectCases.push({ addr: a, ok16Unprotected: ok16b, after16b: mcm.get16(a, false) });
  }
  // set32 protect: protect only the second halfword of a pair, verify set32 blocked.
  {
    const base = 100;
    mcm.setStoreProtect(base + 1, true);
    const ok = mcm.set32(base, 0x11223344, true, false);
    protectCases.push({ addr32: base, ok32BlockedBySecondHW: ok, val: mcm.get32(base, false) });
    mcm.setStoreProtect(base + 1, false);
  }

  // load16: big-endian byte buffer.
  const loadBytes = [];
  for (let i = 0; i < 40; i++) loadBytes.push(Math.floor(rng() * 256));
  const mcm2 = new MCM(wordCount);
  {
    const buf = new ArrayBuffer(loadBytes.length);
    const u8 = new Uint8Array(buf);
    loadBytes.forEach((b, i) => { u8[i] = b; });
    const dv = new DataView(buf);
    mcm2.load16(50, dv);
  }
  const loadResults = [];
  for (let i = 45; i < 45 + 25; i++) loadResults.push(mcm2.get16(i, false));

  // --- MemoryBus: real CPU/IOP sizes ---
  const cpuMcm = new MCM(40 * 1024);
  const iopMcm = new MCM(24 * 1024);
  const bus = new MemoryBus(cpuMcm, iopMcm);
  const busCases = [];
  const busAddrs = [0, 1, 80 * 1024 - 2, 80 * 1024 - 1, 80 * 1024, 80 * 1024 + 1, 128 * 1024 - 1, 65536, 65537];
  for (let i = 0; i < 200; i++) busAddrs.push(Math.floor(rng() * 131072));
  for (const addr of busAddrs) {
    const v = randU16();
    const ok = bus.set16(addr, v, true, false);
    busCases.push({ op: 'set16', addr, v, ok, after16: bus.get16(addr, false) });
  }
  for (const addr of busAddrs) {
    if (addr % 2 !== 0) continue;
    const v = randU32();
    const ok = bus.set32(addr, v, true, false);
    busCases.push({ op: 'set32', addr, v, ok, after32: bus.get32(addr, false) });
  }
  // Store-protect across the CPU/IOP boundary.
  const busProtCases = [];
  for (const a of [80 * 1024 - 1, 80 * 1024, 80 * 1024 + 5]) {
    bus.setStoreProtect(a, true);
    const ok = bus.set16(a, 0x4321, true, false);
    busProtCases.push({ addr: a, ok, prot: bus.getStoreProtect(a), after: bus.get16(a, false) });
    bus.setStoreProtect(a, false);
  }
  // load16 spanning the CPU/IOP boundary.
  const busLoadBytes = [];
  for (let i = 0; i < 20; i++) busLoadBytes.push(Math.floor(rng() * 256));
  const busLoadBase = 80 * 1024 - 5; // starts in CPU range, crosses into IOP range
  {
    const buf = new ArrayBuffer(busLoadBytes.length);
    const u8 = new Uint8Array(buf);
    busLoadBytes.forEach((b, i) => { u8[i] = b; });
    const dv = new DataView(buf);
    bus.load16(busLoadBase, dv);
  }
  const busLoadResults = [];
  for (let i = busLoadBase - 2; i < busLoadBase + 12; i++) busLoadResults.push(bus.get16(i, false));

  console.log(JSON.stringify({
    wordCount, mcmCases, protectCases, loadBytes, loadResults,
    busCases, busProtCases, busLoadBase, busLoadBytes, busLoadResults,
  }));
}

main().catch((e) => { console.error(e); process.exit(1); });
