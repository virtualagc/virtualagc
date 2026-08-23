// Fixture generator for Instruction#toStr (gpc/cpu_instr.coffee) —
// disassembly text used by Phase 10's --trace output and watchpoint
// messages. Random (hw1, hw2) pairs across the full 16-bit space
// naturally exercise every instruction (and plenty of UNDEFINED
// no-matches) without needing per-instruction targeting, since toStr
// just wraps the already-validated decode().
//
// Usage: node gen_instr_tostr_fixtures.cjs [count] > fixtures.json
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
  const count = parseInt(process.argv[2] || '20000', 10);

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

  const rng = mulberry32(42);
  const out = [];
  for (let i = 0; i < count; i++) {
    const hw1 = Math.floor(rng() * 65536);
    const hw2 = Math.floor(rng() * 65536);
    const s = inst.toStr(hw1, hw2);
    out.push({ hw1, hw2, s });
  }
  console.log(JSON.stringify(out));
}

main().catch((e) => { console.error(e); process.exit(1); });
