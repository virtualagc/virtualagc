// Generic per-instruction exec-body fixture generator, reused across all
// 135 CPU instructions. For each instruction name given on argv, builds
// many (hw1,hw2) pairs matching that instruction's exact bit pattern
// (random field bits), decodes them, sets up an AP101-wired CPU with
// randomized-but-address-contained state, calls Instruction.descByOp[nm]
// .e(cpu, v) directly (bypassing exec1 — this validates exec bodies
// independent of the fetch/decode/interrupt machinery, which Phase 4's
// cpu.c and this phase's decode tests already cover separately), and
// records register/memory/PSW deltas plus the decoded `v` fields (so the
// C harness can reconstruct the same call without re-implementing decode).
//
// Usage: node gen_cpu_instr_exec_fixtures.cjs NAME1 NAME2 ... > fixtures.json
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

const MEM_WINDOW = 4096; // halfwords
const FIELD_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'.split('');

async function main() {
  const { AP101 } = await build('gpc/ap101.coffee');
  const instMod = await build('gpc/cpu_instr.coffee');
  const inst = instMod.default;

  const names = process.argv.slice(2);
  if (names.length === 0) {
    console.error('usage: gen_cpu_instr_exec_fixtures.cjs NAME1 NAME2 ...');
    process.exit(1);
  }

  const rng = mulberry32(9001);
  const randU32 = () => Math.floor(rng() * 4294967296) >>> 0;
  const randU16 = () => Math.floor(rng() * 65536);
  const EDGE32 = [0, 1, 0xffffffff, 0x80000000, 0x7fffffff, 2, 100, 0x10000, 0xffff];

  function freshGpc() {
    const gpc = new AP101({});
    for (let bank = 0; bank < 3; bank++) {
      for (let i = 0; i <= 8; i++) {
        const useEdge = rng() < 0.3;
        gpc.cpu.regFiles[bank].r(i).set32(useEdge ? EDGE32[Math.floor(rng() * EDGE32.length)] : randU32());
      }
      for (let i = 0; i < 4; i++) gpc.cpu.regFiles[bank].setDSE(i, Math.floor(rng() * 16));
    }
    // Keep BSR/DSR at 0 so g_EXPAND-computed addresses stay in [0,0x7fff]
    // (well within MEM_WINDOW's low range) for most trials; still
    // randomize occasionally to exercise the sector-expansion paths.
    gpc.cpu.psw.psw1.set32(randU32());
    gpc.cpu.psw.psw2.set32(randU32());
    if (rng() < 0.7) gpc.cpu.psw.setDSR(0);
    if (rng() < 0.7) gpc.cpu.psw.setBSR(0);
    for (let a = 0; a < MEM_WINDOW; a++) {
      gpc.cpu.mainStorage.set16(a, randU16(), false, false);
    }
    // Bias base-register high halves small so EA calc lands in-window.
    for (let bank = 0; bank < 3; bank++) {
      for (let i = 0; i < 4; i++) {
        if (rng() < 0.6) {
          const cur = gpc.cpu.regFiles[bank].r(i).get32();
          gpc.cpu.regFiles[bank].r(i).set32((Math.floor(rng() * 2000) << 16) | (cur & 0xffff));
        }
      }
    }
    return gpc;
  }

  function snapshot(gpc) {
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
    for (let a = 0; a < MEM_WINDOW; a++) mem.push(gpc.cpu.mainStorage.get16(a, false));
    return {
      regs, dse, mem,
      psw1: gpc.cpu.psw.psw1.get32() >>> 0, psw2: gpc.cpu.psw.psw2.get32() >>> 0,
    };
  }

  function restore(gpc, snap) {
    for (let bank = 0; bank < 3; bank++) {
      for (let i = 0; i <= 8; i++) gpc.cpu.regFiles[bank].r(i).set32(snap.regs[bank][i]);
      for (let i = 0; i < 4; i++) gpc.cpu.regFiles[bank].setDSE(i, snap.dse[bank][i]);
    }
    for (let a = 0; a < MEM_WINDOW; a++) gpc.cpu.mainStorage.set16(a, snap.mem[a], false, false);
    // Zero everything outside the tracked window (both CPU and IOP MCMs,
    // since g_EA/g_EXPAND can route there via BSR/DSR) directly via the
    // backing byte array (fast — a single memset-equivalent instead of a
    // per-halfword loop). Without this, a trial whose EA lands outside
    // MEM_WINDOW (e.g. MVH's register-controlled count can be huge)
    // leaves a write there that isn't captured by snapshot/diff and
    // silently leaks into every later trial that happens to touch the
    // same address — including trials for other instructions, and
    // *especially* trials this generator itself discards below (a C
    // replay of only the kept fixtures then diverges, since it never
    // executes the discarded ones that caused the leak).
    gpc.cpu.mainStorage.data8.fill(0, MEM_WINDOW * 2);
    gpc.iop.mainStorage.data8.fill(0);
    gpc.cpu.psw.psw1.set32(snap.psw1);
    gpc.cpu.psw.psw2.set32(snap.psw2);
  }

  function diff(before, after) {
    const regDiff = [];
    for (let bank = 0; bank < 3; bank++) {
      for (let i = 0; i <= 8; i++) {
        if (before.regs[bank][i] !== after.regs[bank][i]) regDiff.push([bank, i, after.regs[bank][i]]);
      }
    }
    const memDiff = [];
    for (let a = 0; a < MEM_WINDOW; a++) {
      if (before.mem[a] !== after.mem[a]) memDiff.push([a, after.mem[a]]);
    }
    return { regDiff, memDiff };
  }

  const gpc = freshGpc();
  const baseline = snapshot(gpc);

  const out = { baseline, byInstr: {} };

  for (const nm of names) {
    const desc = inst.descByOp[nm];
    if (!desc) {
      console.error(`unknown instruction: ${nm}`);
      process.exit(1);
    }
    const cases = [];
    const TRIALS = 300;
    for (let trial = 0; trial < TRIALS; trial++) {
      const randomBits = randU16();
      const hw1 = (desc.maskedVal | (randomBits & ~desc.mask)) & 0xffff;
      const hw2 = randU16();
      const [d, v] = inst.decode(hw1, hw2);
      if (!d || v.nm !== nm) continue; // shouldn't happen, but be safe
      // cpu.coffee's exec1 sets these from decode()'s result *after*
      // decode() returns — decode()/decodef() never touch v.niaIncr,
      // v.hw1, or v.hw2 themselves, but g_EA/g_EA_16 (niaIncr) and the
      // shift instructions (g_SHIFT_CNT(v.hw1)) all depend on them.
      v.niaIncr = d.len;
      v.hw1 = hw1;
      v.hw2 = hw2;

      restore(gpc, baseline);
      const before = snapshot(gpc);
      let err = null;
      try {
        d.e(gpc.cpu, v);
      } catch (e) {
        err = e.message;
      }
      const after = snapshot(gpc);
      const df = diff(before, after);

      // A few instructions (MVH) loop a register-controlled halfword
      // count that can be huge; skip pathologically large trials rather
      // than either special-casing per instruction or blowing up the
      // fixture header — plenty of other trials still exercise them.
      if (df.regDiff.length > 12 || df.memDiff.length > 24) continue;

      const fields = {};
      for (const c of FIELD_CHARS) if (v[c] !== undefined) fields[c] = v[c];

      cases.push({
        hw1, hw2, err,
        fields, extended: !!v.extended, niaIncr: v.niaIncr,
        addrWidth: v.addrWidth, opType: v.opType,
        regDiff: df.regDiff, memDiff: df.memDiff,
        psw1After: after.psw1, psw2After: after.psw2,
      });
    }
    out.byInstr[nm] = cases;
  }
  restore(gpc, baseline);

  console.log(JSON.stringify(out));
}

main().catch((e) => { console.error(e); process.exit(1); });
