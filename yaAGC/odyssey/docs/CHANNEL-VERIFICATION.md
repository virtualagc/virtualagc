# Experimental channel map: verification

AGENTS.md: "Document any channel conflict and revise the allocation rather than
silently overriding existing behavior." This file records what was checked
against the actual engine source and what was observed.

**Everything at octal `0300`-`0325` is an ODYSSEY extension. None of it is an
Apollo channel definition.**

## Map in use (defined in `odyssey_config.h`)

| Channel (octal) | Name | Status |
|---|---|---|
| `0300` | `ODY_CH_AUDIO_SAMPLE` | **implemented**: one 15-bit audio word per write |
| `0301` | `ODY_CH_AUDIO_CONTROL` | **implemented minimally**: latched value + write counter, no behaviour yet |
| `0310`-`0314` | bus transmit (type, seq, data0, data1, commit) | reserved, **not implemented** (milestone 6) |
| `0320`-`0325` | bus receive (status, type, seq, data0, data1, ack) | reserved, **not implemented** (milestone 6) |

## Checks performed against the source

1. **Range.** `NUM_CHANNELS` is 512 (`agc_engine.h`), valid octal `0000`-`0777`.
   `0300`-`0325` are in range. `WriteIO()` ignores addresses above `0777`.
2. **Instruction reach.** The AGC `WRITE`/`READ` instructions take a 9-bit channel
   address, `000`-`777` octal (per the VirtualAGC/ibiblio Assembly Language
   Manual). `WRITE 0300` therefore assembles and executes.
3. **Callback routing.** Every CPU write goes `CpuWriteIO()` -> `WriteIO()` ->
   `ChannelOutput(State, channel, value & 077777)`, with the originating `agc_t *`.
   That is what lets ODYSSEY route by instance.
4. **Engine special cases.** The engine gives meaning to low channels (e.g. 01/02
   L/Q, 010, 011, 013, 014 (gyro/IMU), 015/016, 033, 034/035, 077, the fake DSKY
   channel `0163`, and fake-IMU outputs `0171`, `0172`, `0177`). A grep of
   `agc_engine.c` and `agc_engine_init.c` found **no reference to any channel
   numbered `0200` or above**, so nothing overlaps `0300`-`0325`. **No conflict
   found.** (An earlier draft listed 03, 07, 012, 030-032 as special-cased; that
   was not confirmed in the source and has been removed.)
5. **Observed behaviour.** `SEQTEST` writes channel `0300` eight times and `0301`
   once; the host captured exactly those, in order, and the engine's own
   background traffic (see below) never landed on them.

## Other channels the host sees (diagnostic, not a conflict)

* `0163` (value `00200`): the engine's fake DSKY channel, lighting RESTART on
  cycle 0. Appears once at start-up in every run. It is below `0300`.
* `077`: alarm bits, written by the engine on every watchdog restart. ODYSSEY uses
  non-zero values to count restarts (`alarm_restarts`). See
  `AGC-PROGRAMMING-RULES.md`.
* `0171`, `0172`, `0177`: fake IMU CDU/gyro output channels. Only appear if a program
  drives the IMU. Not used by ODYSSEY synthesis.
* All other unhandled writes are counted in `other_channel_writes`; the latest
  channel/value are in `last_other_channel` / `last_other_value`.

## Unverified / for later

* Whether `READ` of `0320`-`0325` behaves as intended depends on the engine's
  `ReadIO()` path and on how `InputChannel[]` is populated; this must be tested
  when the bus is implemented (milestone 6). **Not yet verified.**
* The AGC address of `0301`'s intended semantics (mute/gain/flags) is undefined;
  nothing depends on it yet.
