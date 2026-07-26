// Generates q31_mul32/q15_mul/q31_div reference fixtures from the real
// gpc/q31.coffee (compiled on the fly). Run:
//   node yaGPC/test/gen_q31_fixtures.cjs > fixtures.json
const path = require('path');
const esbuild = require('esbuild');
const coffeeScriptPlugin = require('esbuild-coffeescript');

const root = path.resolve(__dirname, '..', '..');

function i32(v) { return v | 0; }

// Deterministic PRNG so fixtures are reproducible across regenerations.
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
    entryPoints: [path.join(root, 'gpc/q31.coffee')],
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
  const { q31_mul32, q15_mul, q31_div } = mod.exports;

  const rng = mulberry32(12345);
  const randI32 = () => i32(rng() * 4294967296 - 2147483648);
  const randI16 = () => i32(rng() * 65536 - 32768);

  const edge32 = [0, 1, -1, 2, -2, 0x7fffffff, -2147483648, 0x40000000, -0x40000000, 100, -100];
  const edge16 = [0, 1, -1, 2, -2, 32767, -32768, 16384, -16384, 100, -100];

  const mulCases = [];
  const pairs32 = [];
  for (const a of edge32) for (const b of edge32) pairs32.push([a, b]);
  for (let i = 0; i < 500; i++) pairs32.push([randI32(), randI32()]);
  for (const [a, b] of pairs32) {
    const r = q31_mul32(a, b);
    mulCases.push({ a, b, hi: r.hi >>> 0, lo: r.lo >>> 0, overflow: r.overflow });
  }

  const q15Cases = [];
  const pairs16 = [];
  for (const a of edge16) for (const b of edge16) pairs16.push([a, b]);
  for (let i = 0; i < 500; i++) pairs16.push([randI16(), randI16()]);
  for (const [a, b] of pairs16) {
    const r = q15_mul(a, b);
    q15Cases.push({ a, b, result: r.result | 0, overflow: r.overflow });
  }

  const divCases = [];
  const divTriples = [];
  for (const hi of edge32) for (const lo of [0, 1, -1, 0x7fffffff, -2147483648]) for (const d of edge32) {
    divTriples.push([hi, lo, d]);
  }
  for (let i = 0; i < 500; i++) divTriples.push([randI32(), randI32(), randI32()]);
  for (const [hi, lo, d] of divTriples) {
    const r = q31_div(hi, lo, d);
    divCases.push({ hi, lo, d, quotient: r.quotient | 0, overflow: r.overflow });
  }

  console.log(JSON.stringify({ mulCases, q15Cases, divCases }));
}

main().catch((e) => { console.error(e); process.exit(1); });
