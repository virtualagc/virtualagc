// Generic per-instruction exec fixture generator for the IOP's BCE and MSC
// instruction sets (gpc/iop_bce_instr.coffee, gpc/iop_msc_instr.coffee).
// Unlike gen_cpu_instr_exec_fixtures.cjs (which calls a matched
// instruction's exec body directly, bypassing decode, since cpu_instr.c's
// decode is validated separately), this drives the *full* entry point
// (BCE#exec / MSC#exec — same call path iop.coffee's execProcessors()
// uses) since decode and exec are fused in both BCEInstruction#exec and
// MSCInstruction#exec — there's no standalone decode to test in
// isolation. Fixtures therefore only need (hw1, hw2, page) plus the
// resulting IOPLocalStore/register/memory deltas; the C harness calls
// bce_instr_exec()/msc_instr_exec() directly (which do their own
// decode+dispatch internally, mirroring the JS).
//
// Usage: node gen_iop_instr_exec_fixtures.cjs bce|msc NAME1 NAME2 ... > fixtures.json
const path = require('path');
const esbuild = require('esbuild');
const coffeeScriptPlugin = require('esbuild-coffeescript');

const root = path.resolve(__dirname, '..', '..');

function mulberry32(seed) {
  let a = seed;
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const civetPlugin = {
  name: 'civet',
  setup(build) {
    const fs = require('fs');
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

const MEM_WINDOW = 4096; // halfwords, CPU mainStorage (g_EAF/g_EAH target)

async function main() {
  const kind = process.argv[2];
  if (kind !== 'bce' && kind !== 'msc') {
    console.error('usage: gen_iop_instr_exec_fixtures.cjs bce|msc NAME1 NAME2 ...');
    process.exit(1);
  }
  const names = process.argv.slice(3);
  if (names.length === 0) {
    console.error('usage: gen_iop_instr_exec_fixtures.cjs bce|msc NAME1 NAME2 ...');
    process.exit(1);
  }

  const { AP101 } = await build('gpc/ap101.coffee');

  // gpc/iop.coffee's IOPLocalStore#ls has a genuine bug: `@cp.r(...)`
  // instead of `@cp().r(...)` (missing the call on the `cp` accessor
  // method) — `@cp` without `()` is the bound *function itself*, which
  // has no `.r` method, so this throws `TypeError: this.cp.r is not a
  // function` on every invocation. Since nearly every BCE/MSC
  // instruction reaches this via t.ls.PC()/X()/BASE()/etc (or indirectly
  // via incrNIA/setNIA, which route through ls.PC()), this crashes *any*
  // BCE/MSC instruction execution in the real reference implementation —
  // verified directly against the live CoffeeScript (uncaught exception,
  // no try/catch anywhere between here and cmd_run.coffee's main loop).
  // In practice this is unreachable in typical `gpc run` batch executions
  // (regBusyWait starts all-zero, so execProcessors() no-ops for every
  // processor until something explicitly starts one via SIO/@SIO), so
  // it's very unlikely any of this port's fixture `.fcm` files ever
  // trigger it. The C port implements the evidently-intended behavior
  // (correctly calling through `cp()`) rather than replicating an
  // accidental process crash, so fixture generation patches the same fix
  // here to validate against that intent instead of the crash.
  {
    const gpcProbe = new AP101({});
    gpcProbe.iop.ls.constructor.prototype.ls = function (bank, word) {
      return this.cp().r(bank * 4 + word);
    };
  }

  const rng = mulberry32(9001);
  const randU32 = () => Math.floor(rng() * 4294967296) >>> 0;
  const randU16 = () => Math.floor(rng() * 65536);

  function freshGpc() {
    const gpc = new AP101({});
    for (let a = 0; a < MEM_WINDOW; a++) gpc.cpu.mainStorage.set16(a, randU16(), false, false);
    for (let p = 0; p <= 24; p++) {
      for (let r = 0; r <= 16; r++) gpc.iop.ls.storePage[p].r(r).set32(randU32());
    }
    gpc.iop.regXmitEna.set32(randU32());
    gpc.iop.regRecvEna.set32(randU32());
    gpc.iop.regProgExcept.set32(randU32());
    gpc.iop.regBusyWait.set32(randU32());
    gpc.iop.regHalt.set32(randU32());
    gpc.iop.regIndicator.set32(randU32());
    gpc.iop.msc.regFailDisc.set32(Math.floor(rng() * 32));
    gpc.iop.msc.regIntProg.set32(Math.floor(rng() * 4096));
    gpc.cpu.intPending.iopProg = false;
    return gpc;
  }

  function snapshot(gpc) {
    const ls = [];
    for (let p = 0; p <= 24; p++) {
      const row = [];
      for (let r = 0; r <= 16; r++) row.push(gpc.iop.ls.storePage[p].r(r).get32() >>> 0);
      ls.push(row);
    }
    const mem = [];
    for (let a = 0; a < MEM_WINDOW; a++) mem.push(gpc.cpu.mainStorage.get16(a, false));
    return {
      ls, mem,
      regXmitEna: gpc.iop.regXmitEna.get32() >>> 0,
      regRecvEna: gpc.iop.regRecvEna.get32() >>> 0,
      regProgExcept: gpc.iop.regProgExcept.get32() >>> 0,
      regBusyWait: gpc.iop.regBusyWait.get32() >>> 0,
      regHalt: gpc.iop.regHalt.get32() >>> 0,
      regIndicator: gpc.iop.regIndicator.get32() >>> 0,
      regFailDisc: gpc.iop.msc.regFailDisc.get32() >>> 0,
      regIntProg: gpc.iop.msc.regIntProg.get32() >>> 0,
      iopProg: gpc.cpu.intPending.iopProg,
    };
  }

  function restore(gpc, snap) {
    for (let p = 0; p <= 24; p++) {
      for (let r = 0; r <= 16; r++) gpc.iop.ls.storePage[p].r(r).set32(snap.ls[p][r]);
    }
    for (let a = 0; a < MEM_WINDOW; a++) gpc.cpu.mainStorage.set16(a, snap.mem[a], false, false);
    // Zero everything outside the tracked window — see
    // gen_cpu_instr_exec_fixtures.cjs's identical comment for why (a
    // discarded/skipped trial's leaked out-of-window write must not
    // silently persist into a later kept trial that the C replay never
    // reproduces).
    gpc.cpu.mainStorage.data8.fill(0, MEM_WINDOW * 2);
    gpc.iop.mainStorage.data8.fill(0);
    gpc.iop.regXmitEna.set32(snap.regXmitEna);
    gpc.iop.regRecvEna.set32(snap.regRecvEna);
    gpc.iop.regProgExcept.set32(snap.regProgExcept);
    gpc.iop.regBusyWait.set32(snap.regBusyWait);
    gpc.iop.regHalt.set32(snap.regHalt);
    gpc.iop.regIndicator.set32(snap.regIndicator);
    gpc.iop.msc.regFailDisc.set32(snap.regFailDisc);
    gpc.iop.msc.regIntProg.set32(snap.regIntProg);
    gpc.cpu.intPending.iopProg = snap.iopProg;
    // TDLI/TDL/MOUT@/RDLI/RDL/MIN@ etc queue one DMA request per
    // transferred halfword, and their count field can be up to 18 bits
    // (262144) — never drained here (execDMAQueue is never called), so
    // without a reset this accumulates unboundedly across trials and OOMs
    // within a couple hundred trials.
    gpc.iop.dmaQueue.length = 0;
  }

  const REG_NAMES = ['regXmitEna', 'regRecvEna', 'regProgExcept', 'regBusyWait', 'regHalt', 'regIndicator', 'regFailDisc', 'regIntProg'];

  function diff(before, after) {
    const lsDiff = [];
    for (let p = 0; p <= 24; p++) {
      for (let r = 0; r <= 16; r++) {
        if (before.ls[p][r] !== after.ls[p][r]) lsDiff.push([p, r, after.ls[p][r]]);
      }
    }
    const memDiff = [];
    for (let a = 0; a < MEM_WINDOW; a++) {
      if (before.mem[a] !== after.mem[a]) memDiff.push([a, after.mem[a]]);
    }
    const regDiff = [];
    for (const n of REG_NAMES) if (before[n] !== after[n]) regDiff.push([n, after[n]]);
    return { lsDiff, memDiff, regDiff };
  }

  const gpc = freshGpc();
  const baseline = snapshot(gpc);
  const out = { baseline, byInstr: {} };

  let findMatch;
  const bceInstr = gpc.iop.bce[0].instr;
  const mscInstr = gpc.iop.msc.instr;
  if (kind === 'bce') {
    findMatch = (hw1, hw2) => {
      const combined = ((hw1 << 16) | hw2) >>> 0;
      for (const mask of bceInstr.orderedMasks) {
        if (mask > 0xffff) {
          const mval = (combined & mask) >>> 0;
          if (bceInstr.opByMask[mask] && bceInstr.opByMask[mask][mval]) return bceInstr.opByMask[mask][mval];
        }
      }
      for (const mask of bceInstr.orderedMasks) {
        if (mask <= 0xffff) {
          const mval = (hw1 & mask) >>> 0;
          if (bceInstr.opByMask[mask] && bceInstr.opByMask[mask][mval]) return bceInstr.opByMask[mask][mval];
        }
      }
      return null;
    };
  } else {
    findMatch = (hw1, hw2) => {
      if ((hw1 >>> 12) === 0xf) {
        const fullword = (((hw1 & 0xffff) * 0x10000) + (hw2 & 0xffff)) >>> 0;
        const m = mscInstr._matchLong(fullword);
        if (m) return m;
      }
      return mscInstr._matchShort(hw1 & 0xffff);
    };
  }

  for (const nm of names) {
    let mask, maskedVal;
    if (kind === 'bce') {
      const desc = bceInstr.descByOp[nm];
      if (!desc) { console.error(`unknown BCE instruction: ${nm}`); process.exit(1); }
      mask = desc.mask; maskedVal = desc.maskedVal;
    } else {
      const raw = mscInstr.ops[nm];
      if (!raw) { console.error(`unknown MSC instruction: ${nm}`); process.exit(1); }
      const pd = mscInstr._parseDesc(raw.d);
      mask = pd.mask; maskedVal = pd.maskedVal;
    }
    const isLong = mask > 0xffff;

    const cases = [];
    const TRIALS = 300;
    for (let trial = 0; trial < TRIALS; trial++) {
      let hw1, hw2;
      if (isLong) {
        const rand32 = randU32();
        const combined = (maskedVal | (rand32 & (~mask >>> 0))) >>> 0;
        hw1 = (combined >>> 16) & 0xffff;
        hw2 = combined & 0xffff;
      } else {
        const rand16 = randU16();
        hw1 = (maskedVal | (rand16 & (~mask & 0xffff))) & 0xffff;
        hw2 = randU16();
      }

      const matched = findMatch(hw1, hw2);
      if (!matched || matched.nm !== nm) continue;

      const page = kind === 'bce' ? 1 + Math.floor(rng() * 24) : 0;
      gpc.iop.ls.curPage = page;

      restore(gpc, baseline);
      gpc.iop.ls.curPage = page;
      const before = snapshot(gpc);
      let err = null;
      try {
        if (kind === 'bce') {
          gpc.iop.bce[page - 1].exec(gpc.iop, hw1, hw2);
        } else {
          gpc.iop.msc.exec(gpc.iop, hw1, hw2);
        }
      } catch (e) {
        err = e.message;
      }
      if (err) {
        console.error(`unexpected exception in ${nm} [${hw1.toString(16)},${hw2.toString(16)}]: ${err}`);
        process.exit(1);
      }

      const after = snapshot(gpc);
      const df = diff(before, after);

      // Safety valve for pathologically large diffs (mirrors the CPU
      // generator's MVH accommodation) — TDLI/RDLI/etc's count field can
      // in principle be huge; skip rather than special-case.
      if (df.lsDiff.length > 20 || df.memDiff.length > 60) continue;

      cases.push({
        hw1, hw2, page, err,
        lsDiff: df.lsDiff, memDiff: df.memDiff, regDiff: df.regDiff,
        iopProgAfter: after.iopProg,
      });
    }
    out.byInstr[nm] = cases;
  }
  restore(gpc, baseline);

  console.log(JSON.stringify(out));
}

main().catch((e) => { console.error(e); process.exit(1); });
