// Generates g_EA/g_EA_16/g_EXPAND/g_EXPAND_DSE/g_SHIFT_CNT/computeCC*
// reference fixtures from the real gpc/ap101.coffee (which wires up a
// CPU exactly as `gpc run` does — CPU/IOP sharing a MemoryBus — so this
// exercises cpu.coffee's addressing logic under the same conditions
// production uses, not a bare `new CPU()`).
//
// Run: node yaGPC/test/gen_cpu_ea_fixtures.cjs > fixtures.json
const fs = require('fs');
const path = require('path');
const esbuild = require('esbuild');
const coffeeScriptPlugin = require('esbuild-coffeescript');

const root = path.resolve(__dirname, '..', '..');

// gpc/ap101.coffee (via com/lru) and gpc/iop_bce.coffee (via com/bus) pull
// in .civet sources; mirror esbuild/esbuild.gpc.config.js's civet plugin.
const civetPlugin = {
  name: 'civet',
  setup(build) {
    const { compile } = require('@danielx/civet');
    build.onResolve({ filter: /\.civet\.jsx$/ }, (args) => {
      const resolved = path.resolve(path.dirname(args.importer), args.path.replace(/\.jsx$/, ''));
      return { path: resolved };
    });
    build.onLoad({ filter: /\.civet$/ }, async (args) => {
      const source = await fs.promises.readFile(args.path, 'utf8');
      const filename = path.relative(root, args.path);
      const compiled = compile(source, { filename, inlineMap: true, js: true });
      return { contents: compiled, loader: 'js' };
    });
  },
};

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
    plugins: [civetPlugin, coffeeScriptPlugin({})],
    resolveExtensions: ['.coffee', '.js', '.civet'],
    external: ['dgram', 'electron'],
    logLevel: 'silent',
  });
  const code = result.outputFiles[0].text;
  const mod = { exports: {} };
  new Function('module', 'exports', 'require', code)(mod, mod.exports, require);
  return mod.exports;
}

const ADDR_HALFWORD = 1, ADDR_FULLWORD = 2, ADDR_DBLEWORD = 3;
const OPTYPE_DATA = 1, OPTYPE_BRCH = 2, OPTYPE_SHFT = 4;

async function main() {
  const { AP101 } = await build('gpc/ap101.coffee');

  const rng = mulberry32(4242);
  const randU32 = () => Math.floor(rng() * 4294967296) >>> 0;
  const randU16 = () => Math.floor(rng() * 65536);
  const pick = (arr) => arr[Math.floor(rng() * arr.length)];

  function freshGpc() {
    const gpc = new AP101({});
    // Randomize register file, PSW, and a window of memory so the
    // fixtures aren't all-zeros.
    for (let bank = 0; bank < 3; bank++) {
      for (let i = 0; i <= 8; i++) {
        gpc.cpu.regFiles[bank].r(i).set32(randU32());
      }
      for (let i = 0; i < 4; i++) gpc.cpu.regFiles[bank].setDSE(i, Math.floor(rng() * 16));
    }
    gpc.cpu.psw.psw1.set32(randU32());
    gpc.cpu.psw.psw2.set32(randU32());
    // DSR/BSR/regSet influence addressing; also cover the low/zero case.
    if (rng() < 0.3) gpc.cpu.psw.setDSR(0);
    if (rng() < 0.3) gpc.cpu.psw.setBSR(0);
    if (rng() < 0.3) gpc.cpu.psw.setRegSet(0);
    for (let a = 0; a < 4096; a += 2) {
      gpc.cpu.mainStorage.set16(a, randU16(), false, false);
      gpc.cpu.mainStorage.set16(a + 1, randU16(), false, false);
    }
    return gpc;
  }

  function snapshotState(gpc) {
    const regs = [];
    const dse = [];
    for (let bank = 0; bank < 3; bank++) {
      const bankRegs = [];
      for (let i = 0; i <= 8; i++) bankRegs.push(gpc.cpu.regFiles[bank].r(i).get32() >>> 0);
      regs.push(bankRegs);
      const bankDse = [];
      for (let i = 0; i < 4; i++) bankDse.push(gpc.cpu.regFiles[bank].getDSE(i));
      dse.push(bankDse);
    }
    const mem = [];
    for (let a = 0; a < 4096; a++) mem.push(gpc.cpu.mainStorage.get16(a, false));
    return {
      regs, dse, mem,
      psw1: gpc.cpu.psw.psw1.get32() >>> 0, psw2: gpc.cpu.psw.psw2.get32() >>> 0,
    };
  }

  // Compact diff: [[bank,idx,val],...] for registers, [[addr,val],...] for mem.
  function diffState(before, after) {
    const regDiff = [];
    for (let bank = 0; bank < 3; bank++) {
      for (let i = 0; i <= 8; i++) {
        if (before.regs[bank][i] !== after.regs[bank][i]) regDiff.push([bank, i, after.regs[bank][i]]);
      }
    }
    const memDiff = [];
    for (let a = 0; a < 4096; a++) {
      if (before.mem[a] !== after.mem[a]) memDiff.push([a, after.mem[a]]);
    }
    return { regDiff, memDiff };
  }

  function restoreState(gpc, snap) {
    for (let bank = 0; bank < 3; bank++) {
      for (let i = 0; i <= 8; i++) gpc.cpu.regFiles[bank].r(i).set32(snap.regs[bank][i]);
    }
    for (let a = 0; a < 4096; a++) gpc.cpu.mainStorage.set16(a, snap.mem[a], false, false);
    gpc.cpu.psw.psw1.set32(snap.psw1);
    gpc.cpu.psw.psw2.set32(snap.psw2);
  }

  // Build a `v` decode object covering the various addressing submodes.
  function buildV(opts) {
    const v = {
      niaIncr: opts.niaIncr, opType: opts.opType, addrWidth: opts.addrWidth,
    };
    if (opts.I !== undefined) v.I = opts.I;
    if (opts.d !== undefined) v.d = opts.d;
    if (opts.b !== undefined) v.b = opts.b;
    if (opts.i !== undefined) { v.i = opts.i; v.ia = opts.ia; v.ii = opts.ii; }
    return v;
  }

  const gpc = freshGpc();
  const baseline = snapshotState(gpc);
  const eaCases = [];
  const ea16Cases = [];

  const opTypes = [OPTYPE_DATA, OPTYPE_BRCH, OPTYPE_SHFT];
  const addrWidths = [ADDR_HALFWORD, ADDR_FULLWORD, ADDR_DBLEWORD];

  function randomVOpts() {
    const isExtended = rng() < 0.6; // niaIncr==2 && !I -> the "RS extended/indexed" path
    const opType = pick(opTypes);
    const addrWidth = pick(addrWidths);
    if (!isExtended) {
      if (rng() < 0.5) {
        // SI/RI style: niaIncr==2 with I present (not the extended path).
        return { niaIncr: 2, I: randU16(), d: Math.floor(rng() * 64), b: Math.floor(rng() * 4), opType, addrWidth };
      }
      // SRS style: niaIncr==1.
      return { niaIncr: 1, d: Math.floor(rng() * 64), b: Math.floor(rng() * 4), opType, addrWidth };
    }
    const b = Math.floor(rng() * 4);
    const d = Math.floor(rng() * 2048);
    if (rng() < 0.25) {
      // Non-indexed extended (`v.i` absent).
      return { niaIncr: 2, d, b, opType, addrWidth };
    }
    const i = pick([0, 0, 1, 2, 3, 7]); // weight i==0 (IC-relative/indirect) heavily
    const ia = pick([0, 1]);
    const ii = pick([0, 1]);
    return { niaIncr: 2, d, b, i, ia, ii, opType, addrWidth };
  }

  for (let n = 0; n < 4000; n++) {
    const opts = randomVOpts();
    const v = buildV(opts);
    const snap = snapshotState(gpc);
    let ea, err = null;
    try { ea = gpc.cpu.g_EA(v) >>> 0; } catch (e) { err = e.message; }
    const after = snapshotState(gpc);
    const diff = diffState(snap, after);
    eaCases.push({
      opts, ea, err,
      regDiff: diff.regDiff, memDiff: diff.memDiff,
      psw1After: after.psw1, psw2After: after.psw2,
    });
    restoreState(gpc, snap);

    const v2 = buildV(opts);
    const snap2 = snapshotState(gpc);
    let ea16, err16 = null;
    try { ea16 = gpc.cpu.g_EA_16(v2) >>> 0; } catch (e) { err16 = e.message; }
    const after2 = snapshotState(gpc);
    const diff2 = diffState(snap2, after2);
    ea16Cases.push({
      opts, ea16, err: err16,
      regDiff: diff2.regDiff, memDiff: diff2.memDiff,
    });
    restoreState(gpc, snap2);
  }

  // g_EXPAND / g_EXPAND_DSE
  const expandCases = [];
  for (let n = 0; n < 500; n++) {
    const ea = randU16();
    const bsrdsr = pick(opTypes);
    const before = gpc.cpu.psw.psw1.get32() >>> 0;
    const result = gpc.cpu.g_EXPAND(ea, bsrdsr) >>> 0;
    expandCases.push({ ea, bsrdsr, result });
    gpc.cpu.psw.psw1.set32(before);
  }
  const expandDseCases = [];
  for (let n = 0; n < 500; n++) {
    const ea = randU16();
    const bsrdsr = pick(opTypes);
    const dseVal = Math.floor(rng() * 16);
    const result = gpc.cpu.g_EXPAND_DSE(ea, bsrdsr, dseVal) >>> 0;
    expandDseCases.push({ ea, bsrdsr, dseVal, result });
  }

  // g_SHIFT_CNT
  const shiftCntCases = [];
  for (let n = 0; n < 500; n++) {
    const hw1 = randU16();
    const result = gpc.cpu.g_SHIFT_CNT(hw1) >>> 0;
    shiftCntCases.push({ hw1, result });
  }

  // computeCCarith / computeCClogical
  const ccArithCases = [];
  const edgeVals = [0, 1, -1, 0x7fffffff | 0, 0x80000000 | 0, 100, -100];
  const ccVals = [...edgeVals];
  for (let i = 0; i < 100; i++) ccVals.push(randU32() | 0);
  for (const v1 of ccVals) for (const v2 of ccVals.slice(0, 20)) {
    gpc.cpu.computeCCarith(v1, v2);
    ccArithCases.push({ v1: v1 >>> 0, v2: v2 >>> 0, cc: gpc.cpu.psw.getCC() });
  }
  const ccLogicalCases = [];
  for (const v1 of [0, 1, -1 >>> 0, randU32(), randU32()]) {
    gpc.cpu.computeCClogical(v1);
    ccLogicalCases.push({ result: v1 >>> 0, cc: gpc.cpu.psw.getCC() });
  }

  console.log(JSON.stringify({
    baseline, eaCases, ea16Cases, expandCases, expandDseCases, shiftCntCases, ccArithCases, ccLogicalCases,
  }));
}

main().catch((e) => { console.error(e); process.exit(1); });
