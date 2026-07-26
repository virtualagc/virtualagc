// Generates Instruction.decode() reference fixtures from the real
// gpc/cpu_instr.coffee, covering every instruction's exact bit pattern
// plus randomized field bits, to validate cpu_instr.c's decode()+decodef()
// translation (independent of exec-body correctness).
//
// Run: node yaGPC/test/gen_cpu_instr_decode_fixtures.cjs > fixtures.json
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

async function main() {
  const result = await esbuild.build({
    platform: 'node',
    entryPoints: [path.join(root, 'gpc/cpu_instr.coffee')],
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
  const inst = mod.exports.default;

  const rng = mulberry32(31337);
  const randU16 = () => Math.floor(rng() * 65536);

  // Fields we care about comparing (everything decodef might set).
  const FIELD_CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'.split('');

  function snapshotDecode(hw1, hw2) {
    const [d, v] = inst.decode(hw1, hw2);
    if (!d) return { matched: false };
    const fields = {};
    for (const c of FIELD_CHARS) {
      if (v[c] !== undefined) fields[c] = v[c];
    }
    return {
      matched: true,
      nm: v.nm,
      len: d.len,
      extended: !!v.extended,
      hasIa: v.ia !== undefined, ia: v.ia,
      hasIi: v.ii !== undefined, ii: v.ii,
      addrWidth: v.addrWidth,
      opType: v.opType,
      fields,
    };
  }

  const cases = [];

  // Exact bit patterns for every instruction (literal bits fixed, field
  // bits swept via masking) — build hw1 by taking desc.maskedVal and OR-ing
  // in random bits only at field positions (mask==0 positions).
  for (const nm in inst.descByOp) {
    const desc = inst.descByOp[nm];
    for (let trial = 0; trial < 12; trial++) {
      const randomBits = randU16() & 0xffff;
      const hw1 = (desc.maskedVal | (randomBits & ~desc.mask)) & 0xffff;
      const hw2 = randU16();
      cases.push({ hw1, hw2, expect: snapshotDecode(hw1, hw2) });
    }
  }

  // Fully random hw1/hw2 (covers "no match" cases and cross-instruction
  // collisions exercising mask-priority resolution).
  for (let i = 0; i < 3000; i++) {
    const hw1 = randU16();
    const hw2 = randU16();
    cases.push({ hw1, hw2, expect: snapshotDecode(hw1, hw2) });
  }

  console.log(JSON.stringify({ cases }));
}

main().catch((e) => { console.error(e); process.exit(1); });
