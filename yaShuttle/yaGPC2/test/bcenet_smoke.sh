#!/bin/bash
# bcenet_smoke.sh -- manual verification for the --bce-network real-
# peripheral servicer bridge (src/bcenet_framer.c/bcenet_transport.c).
# NOT part of `make test`: opens a real UDP multicast socket, which
# doesn't belong in the deterministic automated suite (port conflicts,
# firewall/multicast-support environment dependence). Run this by hand
# after touching bcenet_*.c, or before relying on --bce-network for a
# real nsts-sim-gpc MEDS session.
#
# Requires ~/donschmidt/nsts-sim-gpc checked out with node_modules
# installed (uses its real com/bus.civet.civet directly, via
# @danielx/civet/register, as the independent reference implementation
# to interoperate with -- not a stub of our own).
#
# IMPORTANT: every Bus construction below uses `new Bus(name,
# busConfig[name])` -- exactly 2 arguments, matching com/lru.civet's own
# _setupBuses() (what MEDS itself actually does) -- NOT `new Bus(name,
# desc, true, iua)`. isShuttleBus defaults to false; a 4-arg
# shuttle-framed construction is a DIFFERENT wire format (an extra
# 2-byte IUA header) that a real MEDS session never strips. Confirmed
# the hard way (2026-08-19): the bridge's own FRAMER_IS_SHUTTLE_BUS used
# to be `true`, verified only against a listener built the same
# (wrong) way -- passed here, failed against a real live MEDS.sh
# session, which showed nothing. Fixed; see bcenet_framer.c's own
# updated comment for the full story.
#
# Confirms, using fixtures/bcenet_smoke.fcm (see its own generator's
# header comment for the full derivation):
#   1. Transmit: running the fixture under --bce-network produces a real
#      UDP multicast packet on DK1's port (6906) that nsts-sim-gpc's own
#      Bus class parses correctly (one word = 0xBEEF).
#   2. Receive: a message sent via nsts-sim-gpc's own Bus#sendMsg() is
#      correctly received and parsed by bcenet_transport_recv()
#      directly (see this script's own comment on why the full CPU/BCE
#      #RDS path isn't exercised live here -- a batch, non-paced yaGPC2
#      run completes too fast to reliably race against an external
#      sender within one process's lifetime; the transport layer is
#      what actually needed proving, and the framer's own receive-side
#      code is a thin, already-reviewed wrapper around it).
#   3. A real, full-sized message: fixtures/bcenet_dfb_relay.fcm relays
#      nsts-sim-gpc's own data/TEST-9011-GPC_MEMORY.dfb test fixture as
#      a real DK-bus op=1 ("DATA FILL") message (542 words, not one
#      arbitrary word) -- confirms the framer's buffering/flush logic
#      and #TDLI long-transmit handling survive a real-sized transfer
#      intact, matching meds/idp.coffee's recvDK exactly. This is the
#      fixture the user confirmed (2026-08-19) actually renders on a
#      live MEDS/IDP display, once the shuttle-bus framing bug above
#      was fixed.
set -u
cd "$(dirname "$0")"

NSTS_SIM_GPC="${NSTS_SIM_GPC:-$HOME/donschmidt/nsts-sim-gpc}"
if [ ! -d "$NSTS_SIM_GPC" ]; then
    echo "SKIP [bcenet_smoke]: nsts-sim-gpc not found at $NSTS_SIM_GPC (set NSTS_SIM_GPC to override)"
    exit 0
fi

YAGPC2="../yaGPC2"
FCM="fixtures/bcenet_smoke.fcm"
fail=0

echo "=== 1. Transmit: yaGPC2 -> real Bus class ==="
recv_out=$(mktemp)
(cd "$NSTS_SIM_GPC" && node -e "
require('@danielx/civet/register');
const {Bus, busConfig} = require('./com/bus.civet');
const bus = new Bus('DK1', busConfig['DK1']);
bus.onReceive((ctx, busID, msg) => {
  console.log('RECEIVED', busID, Array.from(msg.data16).map(w => '0x' + w.toString(16)).join(','));
  process.exit(0);
}, null);
setTimeout(() => { console.log('TIMEOUT'); process.exit(1); }, 8000);
" >"$recv_out" 2>&1) &
listener_pid=$!
sleep 1.5
"$YAGPC2" --start 0x10 --bce-network --max-steps 200 "$FCM" >/dev/null 2>&1
wait "$listener_pid"
if grep -q "RECEIVED DK1 0xbeef$" "$recv_out"; then
    echo "PASS [bcenet_smoke/transmit]"
else
    echo "FAIL [bcenet_smoke/transmit]: expected 'RECEIVED DK1 0xbeef', got:"
    cat "$recv_out"
    fail=1
fi
rm -f "$recv_out"

echo "=== 2. Receive: real Bus class -> bcenet_transport_recv() ==="
recv_out=$(mktemp)
make -s -C .. build/test/bcenet_recv_check 2>&1 | grep -v '^$' || true
if [ ! -x ../build/test/bcenet_recv_check ]; then
    echo "FAIL [bcenet_smoke/receive]: build/test/bcenet_recv_check missing (see Makefile)"
    fail=1
else
    ../build/test/bcenet_recv_check >"$recv_out" &
    recv_pid=$!
    sleep 0.5
    (cd "$NSTS_SIM_GPC" && node -e "
require('@danielx/civet/register');
const {Bus, BusMsg, busConfig} = require('./com/bus.civet');
const bus = new Bus('DK1', busConfig['DK1']);
const msg = new BusMsg(2);
msg.data16[0] = 0xCAFE;
msg.data16[1] = 0xBABE;
bus.sendMsg(msg);
setTimeout(() => process.exit(0), 500);
")
    wait "$recv_pid"
    if grep -q "RECEIVED 2 words: 0xcafe 0xbabe" "$recv_out"; then
        echo "PASS [bcenet_smoke/receive]"
    else
        echo "FAIL [bcenet_smoke/receive]: expected 'RECEIVED 2 words: 0xcafe 0xbabe', got:"
        cat "$recv_out"
        fail=1
    fi
fi
rm -f "$recv_out"

echo "=== 3. Real DFB relay: yaGPC2 -> real Bus class (542-word DATA FILL) ==="
DFB_FCM="fixtures/bcenet_dfb_relay.fcm"
DFB_SOURCE="$NSTS_SIM_GPC/data/TEST-9011-GPC_MEMORY.dfb"
if [ ! -f "$DFB_SOURCE" ]; then
    echo "SKIP [bcenet_smoke/dfb_relay]: $DFB_SOURCE not found"
else
    recv_out=$(mktemp)
    (cd "$NSTS_SIM_GPC" && node -e "
require('@danielx/civet/register');
const {Bus, busConfig} = require('./com/bus.civet');
const fs = require('fs');
const dfb = fs.readFileSync('data/TEST-9011-GPC_MEMORY.dfb');
const bus = new Bus('DK1', busConfig['DK1']);
bus.onReceive((ctx, busID, msg) => {
  const words = Array.from(msg.data16);
  const expectedLen = 1 + dfb.length / 2;
  if (words.length !== expectedLen || words[0] !== 1) {
    console.log('SHAPE MISMATCH: got', words.length, 'words, op=' + words[0], '(expected', expectedLen, 'words, op=1)');
    process.exit(0);
  }
  for (let i = 0; i < dfb.length / 2; i++) {
    if (words[1 + i] !== dfb.readUInt16BE(i * 2)) {
      console.log('CONTENT MISMATCH at word', i);
      process.exit(0);
    }
  }
  console.log('CONTENT MATCHES EXACTLY');
  process.exit(0);
}, null);
setTimeout(() => { console.log('TIMEOUT'); process.exit(1); }, 8000);
" >"$recv_out" 2>&1) &
    listener_pid=$!
    sleep 1.5
    "$YAGPC2" --start 0x10 --bce-network --max-steps 300 "$DFB_FCM" >/dev/null 2>&1
    wait "$listener_pid"
    if grep -q "CONTENT MATCHES EXACTLY" "$recv_out"; then
        echo "PASS [bcenet_smoke/dfb_relay]"
    else
        echo "FAIL [bcenet_smoke/dfb_relay]: expected 'CONTENT MATCHES EXACTLY', got:"
        cat "$recv_out"
        fail=1
    fi
    rm -f "$recv_out"
fi

exit $fail
