// Generates FloatIBM reference fixtures from the real gpc/floatIBM.coffee
// (compiled on the fly with esbuild-coffeescript). Covers every exported
// operation with a mix of targeted edge cases and randomized 32/64-bit
// bit patterns (including deliberately-unnormalized inputs, since the
// arithmetic functions all renormalize their operands internally).
//
// Run: node yaGPC/test/gen_floatIBM_fixtures.cjs > fixtures.json
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

// JSON.stringify(-0) === "0" — loses the sign of zero. Encode doubles as
// exact hex bit patterns instead wherever a computed float value (not an
// input we chose) needs to round-trip through the fixture JSON.
function bitsOf(v) {
  const buf = Buffer.alloc(8);
  buf.writeDoubleBE(v);
  return buf.toString('hex');
}

async function main() {
  const result = await esbuild.build({
    platform: 'node',
    entryPoints: [path.join(root, 'gpc/floatIBM.coffee')],
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
  const { FloatIBM, compE_anomalous, addE, subE, mulE, mulQeE, divE, cvfx, cvfl } = mod.exports;

  const rng = mulberry32(2024);
  const randU32 = () => Math.floor(rng() * 4294967296) >>> 0;

  // A pool of "interesting" 64-bit (hi,lo) bit patterns: zero, normalized
  // and unnormalized fractions, signs, exponent extremes, plus random.
  function pool() {
    const p = [];
    const chars = [0x00, 0x01, 0x40, 0x41, 0x7f, 0x80, 0xbf, 0xc0, 0xff];
    // Structured combos: sign/exp byte x a few fraction patterns.
    const fracPatterns = [
      [0, 0, 0, 0, 0, 0, 0],
      [0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], // normalized min
      [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], // normalized max
      [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], // unnormalized (needs 1 shift)
      [0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00], // unnormalized (needs 2 shifts)
      [0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde],
      [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01], // needs many shifts
    ];
    for (const c of chars) {
      for (const fp of fracPatterns) {
        const bytes = [c, ...fp];
        const hi = (bytes[0] << 24 | bytes[1] << 16 | bytes[2] << 8 | bytes[3]) >>> 0;
        const lo = (bytes[4] << 24 | bytes[5] << 16 | bytes[6] << 8 | bytes[7] || 0) >>> 0;
        p.push([hi, lo]);
      }
    }
    for (let i = 0; i < 400; i++) p.push([randU32(), randU32()]);
    return p;
  }
  const pairs = pool();

  // --- Accessor round-trips ---
  const accessorCases = [];
  for (const [hi, lo] of pairs) {
    const f = FloatIBM.From64(hi, lo);
    accessorCases.push({
      hi, lo,
      to32: f.to32() >>> 0, to64x: f.to64x() >>> 0, to64y: f.to64y() >>> 0,
      gSign: f.gSign(), gExp: f.gExp(),
      gFracBitsHigh: f.gFracBits().getHighBitsUnsigned() >>> 0,
      gFracBitsLow: f.gFracBits().getLowBitsUnsigned() >>> 0,
    });
  }

  // --- normalize ---
  const normalizeCases = [];
  for (const [hi, lo] of pairs) {
    const f = FloatIBM.From64(hi, lo);
    f.normalize();
    normalizeCases.push({ hi, lo, resultHi: f.to64x() >>> 0, resultLo: f.to64y() >>> 0 });
  }

  // --- compE_anomalous (pairwise over a subset to keep the fixture set a reasonable size) ---
  const compECases = [];
  const compEPairs = pairs.filter((_, i) => i % 3 === 0);
  for (const [hi1, lo1] of compEPairs.slice(0, 60)) {
    for (const [hi2, lo2] of compEPairs.slice(0, 60)) {
      const x = FloatIBM.From64(hi1, lo1);
      const y = FloatIBM.From64(hi2, lo2);
      compECases.push({ hi1, lo1, hi2, lo2, cc: compE_anomalous(x, y) });
    }
  }

  // --- addE/subE/mulE/mulQeE/divE (pairwise) ---
  function binOpCases(fn) {
    const cases = [];
    const opPairs = pairs.filter((_, i) => i % 4 === 0);
    for (const [hi1, lo1] of opPairs) {
      for (const [hi2, lo2] of opPairs) {
        const x = FloatIBM.From64(hi1, lo1);
        const y = FloatIBM.From64(hi2, lo2);
        const { result, exc } = fn(x, y);
        cases.push({
          hi1, lo1, hi2, lo2, exc,
          resultHi: result.to64x() >>> 0, resultLo: result.to64y() >>> 0,
        });
      }
    }
    return cases;
  }
  const addECases = binOpCases(addE);
  const subECases = binOpCases(subE);
  const mulECases = binOpCases(mulE);
  const mulQeECases = binOpCases(mulQeE);
  const divECases = binOpCases(divE);

  // --- cvfx ---
  const cvfxCases = [];
  for (const [hi, lo] of pairs) {
    const x = FloatIBM.From64(hi, lo);
    const { result, exc } = cvfx(x);
    cvfxCases.push({ hi, lo, result: result | 0, exc });
  }

  // --- cvfl ---
  const cvflCases = [];
  const cvflVals = [0, 1, -1, 2147483647, -2147483648, 100, -100, 12345, -12345, 0x7fffffff, 0x80000000 | 0];
  for (let i = 0; i < 200; i++) cvflVals.push((randU32() | 0));
  for (const v of cvflVals) {
    const f = cvfl(v);
    cvflCases.push({ v, resultHi: f.to64x() >>> 0, resultLo: f.to64y() >>> 0 });
  }

  // --- setFromFloat / toFloat round-trips ---
  const floatRoundTripCases = [];
  const floatVals = [
    0, 1, -1, 0.5, -0.5, 3.14159265358979, -2.71828182845905, 100000,
    1e-10, 1e10, 123.456, -123.456, 1 / 3, 65535, -65536, 0.1, 16, 256,
    4096, 1 / 16, 1 / 256,
  ];
  for (let i = 0; i < 100; i++) floatVals.push((rng() - 0.5) * Math.pow(10, Math.floor(rng() * 20 - 10)));
  for (const v of floatVals) {
    const f = new FloatIBM(v);
    floatRoundTripCases.push({
      v, resultHi: f.to64x() >>> 0, resultLo: f.to64y() >>> 0, backBitsHex: bitsOf(f.toFloat()),
    });
  }
  // toFloat on arbitrary bit patterns too.
  const toFloatCases = [];
  for (const [hi, lo] of pairs) {
    const f = FloatIBM.From64(hi, lo);
    toFloatCases.push({ hi, lo, vBitsHex: bitsOf(f.toFloat()) });
  }

  console.log(JSON.stringify({
    accessorCases, normalizeCases, compECases,
    addECases, subECases, mulECases, mulQeECases, divECases,
    cvfxCases, cvflCases, floatRoundTripCases, toFloatCases,
  }));
}

main().catch((e) => { console.error(e); process.exit(1); });
