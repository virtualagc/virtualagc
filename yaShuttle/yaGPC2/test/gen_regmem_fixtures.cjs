// Generates Register/RegisterFile/ProgramStatusWord reference fixtures
// from the real gpc/regmem.coffee. Run:
//   node yaGPC/test/gen_regmem_fixtures.cjs > fixtures.json
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

async function main() {
  const result = await esbuild.build({
    platform: 'node',
    entryPoints: [path.join(root, 'gpc/regmem.coffee')],
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
  const { Register, RegisterFile, ProgramStatusWord } = mod.exports;

  const rng = mulberry32(777);
  const randU32 = () => Math.floor(rng() * 4294967296) >>> 0;

  // --- Register ---
  const registerCases = [];
  const vals = [0, 1, 0xffff, 0x10000, 0x12345678, 0xffffffff, 0x80000000, 0xabcd, 0x1, 0xdeadbeef];
  for (const v of vals) {
    const r = new Register('t', 32);
    r.set32(v);
    registerCases.push({
      op: 'set32', v,
      get32: r.get32() >>> 0, get16: r.get16() >>> 0,
    });
  }
  for (const v of [0, 1, 0xffff, 0x1234, 0xabcd]) {
    const r = new Register('t', 32);
    r.set16(v);
    registerCases.push({
      op: 'set16', v,
      get32: r.get32() >>> 0, get16: r.get16() >>> 0,
    });
  }
  const bitCases = [];
  for (const v of [0, 0x12345678, 0xffffffff, 0x80000001]) {
    for (let b = 0; b < 32; b++) {
      const r = new Register('t', 32);
      r.set32(v);
      bitCases.push({ v, b, getbit32: r.getbit32(b) >>> 0 });
      const r2 = new Register('t', 32);
      r2.set32(v);
      r2.setbit32(b, 1);
      bitCases.push({ v, b, setbit32to1: r2.get32() >>> 0 });
      const r3 = new Register('t', 32);
      r3.set32(v);
      r3.setbit32(b, 0);
      bitCases.push({ v, b, setbit32to0: r3.get32() >>> 0 });
    }
  }

  // --- RegisterFile DSE ---
  const dseCases = [];
  const rf = new RegisterFile('r0', 8, 32);
  for (let base = 0; base < 8; base++) {
    for (const val of [0, 0xf, 0x1a, 5]) {
      rf.setDSE(base, val);
      dseCases.push({ base, val, dse: rf.getDSE(base) });
    }
  }

  // --- ProgramStatusWord ---
  const pswGetters = [
    'getNIA', 'getCC', 'getCarry', 'getOverflow', 'getFixedPtOverflow',
    'getExponentUnderflow', 'getSignificanceMask', 'getBSR', 'getDSR',
    'getIntMask', 'getRegSet', 'getMachCheckMask', 'getWaitState',
    'getProblemState', 'getIntCode',
  ];
  const pswCases = [];
  const pswRandomPairs = [];
  for (let i = 0; i < 300; i++) pswRandomPairs.push([randU32(), randU32()]);
  const pswEdgePairs = [
    [0, 0], [0xffffffff, 0xffffffff], [0x8000, 0], [0x7fff, 0],
    [0xffff, 0], [0, 0x1], [0, 0x2000], [0, 0x4000],
  ];
  for (const [p1, p2] of [...pswEdgePairs, ...pswRandomPairs]) {
    const psw = new ProgramStatusWord();
    psw.load(p1, p2);
    const getters = {};
    for (const g of pswGetters) getters[g] = psw[g]();
    pswCases.push({ p1, p2, getters });
  }

  // Setter round-trips: for each setter, apply to a base (p1,p2) and record resulting psw1/psw2.
  const pswSetterCases = [];
  const setterSpecs = [
    ['setNIA', [0, 1, 0x7fff, 0x8000, 0x12345, 0x7ffff]],
    ['setCC', [0, 1, 2, 3]],
    ['setCarry', [0, 1]],
    ['setOverflow', [0, 1]],
    ['setFixedPtOverflow', [0, 1]],
    ['setExponentUnderflow', [0, 1]],
    ['setSignificanceMask', [0, 1]],
    ['setBSR', [0, 1, 7, 15]],
    ['setDSR', [0, 1, 7, 15]],
    ['setIntMask', [0, 1, 0xff, 0xaa]],
    ['setRegSet', [0, 1]],
    ['setMachCheckMask', [0, 1]],
    ['setWaitState', [true, false]],
    ['setProblemState', [0, 1]],
    ['setIntCode', [0, 1, 0x3ffff, 0x1234]],
  ];
  for (const [p1, p2] of [[0, 0], [0xffffffff, 0xffffffff], [0x12345678, 0x9abcdef0]]) {
    for (const [setter, values] of setterSpecs) {
      for (const val of values) {
        const psw = new ProgramStatusWord();
        psw.load(p1, p2);
        psw[setter](val);
        pswSetterCases.push({
          p1, p2, setter, val: typeof val === 'boolean' ? val : val,
          psw1: psw.psw1.get32() >>> 0, psw2: psw.psw2.get32() >>> 0,
        });
      }
    }
  }

  console.log(JSON.stringify({ registerCases, bitCases, dseCases, pswCases, pswSetterCases }));
}

main().catch((e) => { console.error(e); process.exit(1); });
