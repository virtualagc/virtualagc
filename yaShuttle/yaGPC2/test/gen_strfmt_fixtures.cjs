// Generates lpad/rpad/asHex reference fixtures from the real
// com/util.coffee (compiled on the fly), for cross-checking yaGPC's
// strfmt.c port. Run: node yaGPC/test/gen_strfmt_fixtures.cjs > fixtures.json
const path = require('path');
const esbuild = require('esbuild');
const coffeeScriptPlugin = require('esbuild-coffeescript');

const root = path.resolve(__dirname, '..', '..');

async function main() {
  const result = await esbuild.build({
    platform: 'node',
    entryPoints: [path.join(root, 'com/util.coffee')],
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
  // com/util.coffee augments String.prototype/Number.prototype as a side effect.

  const lpadCases = [];
  const strs = ['', 'x', '12', '12345', 'abc'];
  const pads = [' ', '0', 'ab'];
  const lens = [0, 1, 2, 5, 6, 8];
  for (const s of strs) for (const p of pads) for (const l of lens) {
    lpadCases.push({ s, pad: p, len: l, expect: s.lpad(p, l) });
  }

  const rpadCases = [];
  for (const s of strs) for (const p of pads) for (const l of lens) {
    rpadCases.push({ s, pad: p, len: l, expect: s.rpad(p, l) });
  }

  const hexCases = [];
  const vals = [0, 1, 15, 16, 255, 0x1234, 0x7fffffff, 0xffffffff, 100000, 8, -1, -255];
  const hlens = [1, 2, 3, 4, 5, 6, 8, 10];
  for (const v of vals) for (const l of hlens) {
    hexCases.push({ v, len: l, expect: v.asHex(l) });
  }

  console.log(JSON.stringify({ lpadCases, rpadCases, hexCases }, null, 2));
}

main().catch((e) => { console.error(e); process.exit(1); });
