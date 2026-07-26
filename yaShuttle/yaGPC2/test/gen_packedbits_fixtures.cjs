// Generates PackedBits reference fixtures from the real gpc/util.coffee
// (compiled on the fly with esbuild-coffeescript) for cross-checking
// yaGPC's C port. Run: node yaGPC/test/gen_packedbits_fixtures.cjs
// <descriptor-list-file> > fixtures.json
const fs = require('fs');
const path = require('path');
const esbuild = require('esbuild');
const coffeeScriptPlugin = require('esbuild-coffeescript');

const root = path.resolve(__dirname, '..', '..');

async function main() {
  const result = await esbuild.build({
    platform: 'node',
    entryPoints: [path.join(root, 'gpc/util.coffee')],
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
  const { PackedBits } = mod.exports;

  const descFile = process.argv[2];
  const descs = fs.readFileSync(descFile, 'utf8').split('\n').filter((l) => l.length > 0);

  const out = [];
  for (const d of descs) {
    const pb = new PackedBits(d);
    const desc = pb.desc;
    const fields = {};
    for (const [k, f] of Object.entries(desc.f)) {
      fields[k] = { mask: f.mask >>> 0, shift: f.shift, bitlen: f.bitlen };
    }
    out.push({
      d,
      bitLen: pb.bitLen,
      len: desc.len,
      type: desc.type,
      mask: desc.mask >>> 0,
      maskedVal: desc.maskedVal >>> 0,
      fields,
    });
  }
  console.log(JSON.stringify(out, null, 2));
}

main().catch((e) => { console.error(e); process.exit(1); });
