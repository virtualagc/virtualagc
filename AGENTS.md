# AGENTS.md — ODYSSEY-AGC

## Project purpose

Build **ODYSSEY-AGC**, an experimental synthesizer made from two independently executing Apollo Guidance Computer (AGC) instances using the official VirtualAGC emulator.

The two computers are intended to behave like an interconnected Apollo Command Module / Lunar Module pair:

- **CMC / Comanche:** primary tonal and rhythmic synthesis.
- **LGC / Luminary:** experimental, stochastic, modulation-oriented synthesis.
- **Virtual spacecraft bus:** bidirectional exchange of musical events and control data.
- **Host application:** creates and schedules the AGCs, transports messages, captures their output, buffers and mixes audio, and communicates with the operating system's audio device.

The defining requirement is:

> **The AGC programs calculate the synthesis values. The host transports, buffers, converts, mixes, and plays those values; it must not calculate the oscillator waveforms on behalf of the AGCs.**

This is an experimental extension to VirtualAGC. Do not imply that original Apollo flight hardware or its original mission software generated audio.

## Repository and upstream preservation

Use the official VirtualAGC repository as the emulator base:

- https://github.com/virtualagc/virtualagc

Relevant upstream source files:

- `yaAGC/agc_engine.h`
- `yaAGC/agc_engine.c`
- `yaAGC/agc_engine_init.c`
- `yaAGC/EmbeddedDemo.c`
- `yaAGC/NullAPI.c`
- `yaAGC/Makefile`

The original Apollo 11 software is reference material, not the synthesizer program:

- CMC / Comanche 055: https://github.com/chrislgarry/Apollo-11/tree/master/Comanche055
- LGC / Luminary 099: https://github.com/chrislgarry/Apollo-11/tree/master/Luminary099

**Preserve the normal VirtualAGC build and behavior.** Add ODYSSEY as a separate target and keep experimental code separate from the historical mission source. Preserve upstream licensing and copyright notices. Document every upstream file changed.

Before editing, inspect the current checkout, build instructions, compiler assumptions, and actual declarations/definitions in the checked-out source. Do not rely on filenames or API signatures from memory if the repository differs.

## Non-negotiable architecture

1. Use the official VirtualAGC AGC execution engine. Do not replace it with a new CPU emulator.
2. Create two genuinely independent AGC instances, each with its own `agc_t` and independent program image.
3. Isolate all mutable per-computer engine state. Two `agc_t` objects alone are not sufficient if the engine still uses shared mutable globals or static locals.
4. Initially schedule both AGCs on one host thread in deterministic, bounded execution slices. Do not introduce parallel AGC threads until reentrancy has been demonstrated.
5. Implement a custom, in-process virtual spacecraft bus. Do not use the TCP peripheral interface as the high-rate audio or musical-event transport.
6. Capture AGC-generated values through instance-aware channel I/O. The `agc_t *State` supplied to the channel callback should be used to identify the originating computer.
7. The host may perform audio sample representation conversion, buffering, mixing, gain, stereo placement, clipping protection, and device output. It must not generate or replace the AGC's oscillator waveform.
8. Build and test in small milestones. Do not implement the complete synthesizer before proving the embedded engine, state isolation, audio capture, and bus.

## Suggested project layout

Add a separate directory under `yaAGC/`:

```text
yaAGC/
  odyssey/
    odyssey_main.c
    odyssey_engine.h
    odyssey_engine.c
    odyssey_io.h
    odyssey_io.c
    odyssey_bus.h
    odyssey_bus.c
    odyssey_audio.h
    odyssey_audio.c
    odyssey_scheduler.h
    odyssey_scheduler.c
    odyssey_config.h
    flight/
      ComancheSynth/
        MAIN.agc
        AUDIO.agc
        BUS.agc
        SEQUENCER.agc
      LuminarySynth/
        MAIN.agc
        AUDIO.agc
        BUS.agc
        MODULATION.agc
```

This is a proposed layout, not a reason to force unnecessary files or abstractions into the codebase. Keep modules small and responsibilities clear. Add a separate `odyssey-agc` build target to `yaAGC/Makefile` or an appropriately scoped build file. Do not break the standard `yaAGC` target.

## Upstream files and expected changes

### `yaAGC/agc_engine.h`

- Inspect the existing `agc_t` definition and engine API.
- Add only the minimum per-instance integration state needed.
- Prefer an opaque pointer for engine-private state, so internal emulator details remain private to `agc_engine.c`.
- Use the existing `agc_clientdata` integration hook for ODYSSEY host context only if its ownership and lifecycle are clear.
- Avoid exposing implementation-specific private structures in the public header.

### `yaAGC/agc_engine.c`

- Audit every writable file-scope variable and every function-local `static`.
- Move mutable state that belongs to a computer into its per-instance private state.
- Preserve instruction execution behavior and existing engine semantics.
- Keep constants, immutable lookup tables, and genuinely stateless functions shared.
- Do not assume that all globals need to be moved: classify them as per-instance, process-wide immutable, or optional subsystem state, and document the decision.
- Keep changes narrowly scoped and explain why each state field is isolated.

Concrete mutable state identified during earlier source inspection includes:

- `TrapPIPA`
- `CduFifos`
- `CduChecker`
- `CountCDUX`, `CountCDUY`, `CountCDUZ` (static locals in `BurstOutput()`)
- `GyroCount`
- `OldChannel14`
- `GyroTimer`
- `ImuCduCount`
- `ImuChannel14`

This list is a starting point, **not a complete audit**. Recheck the current source and all linked engine files. Do not assume these are the only shared-state hazards.

### `yaAGC/agc_engine_init.c`

- Initialize all per-instance private state.
- Make initialization safe for two separate instances.
- Provide or support a matching destruction path.
- Handle partial initialization failures without leaks or invalid cleanup.
- Separate process-level side effects from per-computer initialization. For example, socket setup affecting `stdin` must not be performed blindly once per AGC in the embedded host.
- Ensure configuration for one instance cannot silently alter the other.

### `yaAGC/EmbeddedDemo.c` and `yaAGC/NullAPI.c`

Use these as integration examples. Study their actual initialization, ROM loading, callback, and cleanup behavior. Do not blindly copy global setup patterns into ODYSSEY. In particular, ensure callback context and routing are instance-aware.

## Per-computer state and ownership

Each computer must own independent:

- `agc_t` state and CPU registers
- Erasable memory and fixed-memory/ROM image
- Program counter and execution state
- Cycle counter and timing state
- Interrupt requests and interrupt-related state
- Input/output channel values and peripheral state
- Engine-private mutable state
- Synthesis program state and sequence counters
- Audio sample sequence counter and output queue
- Bus transmit staging area, receive mailbox, and status counters

The two computers must never directly read or write one another's CPU memory, registers, or synthesis variables.

The host owns shared services:

- Scheduler
- Bus transport and routing
- Audio device and mixer
- Configuration and user interface
- Diagnostics and logging

Do not use a process-global `CmOrLm`-style flag as the primary way to identify the active computer. Pass instance context explicitly.

## Engine lifecycle

Provide a clear lifecycle around each computer. Names and signatures must be reconciled with the actual upstream API before implementation. A conceptual interface is:

```c
int odyssey_computer_init(/* computer, ROM, configuration, context */);
int odyssey_computer_step(/* computer, bounded execution budget */);
void odyssey_computer_reset(/* computer */);
void odyssey_computer_destroy(/* computer */);
```

If the underlying engine needs a new cleanup API, add it in a way that preserves existing callers and build targets.

Initialization and destruction must be independent: initializing, resetting, or destroying the CMC must not reset or damage the LGC, and vice versa.

## Virtual audio output

### Audio data path

```text
CMC AGC program -> experimental audio channel -> CMC ring buffer --\
                                                                   +-> host mixer -> OS audio device
LGC AGC program -> experimental audio channel -> LGC ring buffer --/
```

Use the actual upstream channel callback signature after inspecting the current source. The previously inspected interface was of the form:

```c
ChannelOutput(agc_t *State, int Channel, int Value);
```

The `State` argument should identify which instance emitted a channel write. Route output to that computer's queue.

### Experimental channel assignments

The following octal assignments are a proposed ODYSSEY protocol, **not original Apollo channel definitions**. Verify them against the checked-out emulator, selected ROMs, and all existing peripheral/channel behavior before using them.

| Octal channel | Proposed purpose |
|---|---|
| `0300` | Audio sample output |
| `0301` | Audio control/status |
| `0310` | Bus transmit message type |
| `0311` | Bus transmit sequence number |
| `0312` | Bus transmit data word 0 |
| `0313` | Bus transmit data word 1 |
| `0314` | Bus transmit commit |
| `0320` | Bus receive status |
| `0321` | Bus receive message type |
| `0322` | Bus receive sequence number |
| `0323` | Bus receive data word 0 |
| `0324` | Bus receive data word 1 |
| `0325` | Bus receive acknowledgement |

Both AGCs may use the same logical channel assignments because the host routes by instance. Document any channel conflict and revise the allocation rather than silently overriding existing behavior.

### Sample representation

AGC words are 15-bit one’s-complement values. Define and test an explicit conversion from the AGC word representation to the host PCM representation, including both positive and negative zero. Do not assume ordinary two's-complement signed conversion is correct.

Each captured sample event should retain:

- Source computer identity
- Original 15-bit AGC word
- Per-computer monotonically increasing sample sequence number
- AGC cycle counter or another defensible execution timestamp

Preserve sample order. Detect and report sequence gaps and queue overflow.

### Sample rates and performance

Begin by measuring 500 Hz, 1 kHz, and 2 kHz sample-generation targets. These are experimental benchmarks, not guaranteed capabilities. Do not promise 44.1 kHz or 48 kHz direct AGC sample generation.

At the AGC's limited instruction throughput, high-rate synthesis may be impractical. Prefer simple low-rate stepped waveforms and event/pulse output initially. Measure instruction cost and timing before adding more complex algorithms.

Sample-and-hold is the baseline host playback method. Interpolation may be evaluated as a playback/resampling convenience only; it must not become a host-generated substitute waveform or conceal the actual AGC sample rate.

### Buffering and audio backend

- Use one single-producer/single-consumer ring buffer per AGC, or another design with equally clear ownership and bounded behavior.
- AGC execution must never block waiting for the audio device.
- The audio callback must never execute the AGC engine.
- Define an explicit overflow/underrun policy and counters.
- Keep the audio backend behind a small interface so SDL2, miniaudio, or PortAudio can be selected after checking project dependencies and platform requirements.
- Host-side responsibilities may include PCM conversion, buffering, mixing, gain, stereo placement, clipping protection, and device output.
- Provide independent CMC/LGC mute, solo, and gain controls. Stereo placement should be configurable.

## CMC–LGC virtual spacecraft bus

### Transport and isolation

Implement the bus in-process with two directional queues:

```text
CMC transmit queue -> LGC receive queue
LGC transmit queue -> CMC receive queue
```

Do not expose one AGC's memory to the other. The host bus copies complete protocol messages between queues.

Deliver messages at deterministic scheduler boundaries, never halfway through an AGC instruction. Initially use polling through custom channel input rather than adding a new interrupt mechanism.

### Proposed message format

A message consists of four 15-bit words followed by a commit write:

| Field | Meaning |
|---|---|
| `TYPE` | Message type |
| `SEQ` | 15-bit sequence number |
| `DATA0` | Payload word 0 |
| `DATA1` | Payload word 1 |
| `COMMIT` | Host recognizes a complete staged message |

The host must not deliver a message until all required fields have been staged and a valid commit matching the sequence number is received. Sequence numbers wrap from octal `077777` to zero.

Document write ordering and behavior when a field is rewritten before commit. Reject incomplete or malformed messages.

### Initial message types

| ID | Type | Intended use |
|---:|---|---|
| 1 | `SYNC` | Musical clock or synchronization event |
| 2 | `PITCH` | Pitch or pitch-structure information |
| 3 | `MODULATION` | Modulation destination, rate, or depth |
| 4 | `TRIGGER` | Trigger/note event and intensity |
| 5 | `PARAMETER` | Synthesis parameter update |
| 6 | `HEARTBEAT` | Computer-alive/status message |
| 7 | `RESET` | Reset musical synchronization state |
| 8 | `ACK` | Acknowledgement or delivery status |

Define exact payload layouts, signed representation, valid ranges, and units for every implemented message type. Do not leave payload interpretation implicit.

### Mailbox and delivery behavior

A basic receive flow:

1. Sender writes message fields and commit.
2. Host validates and queues the complete message.
3. At a scheduler boundary, host places the message in the receiver mailbox/input channels.
4. Receiver observes valid receive status and reads the fields.
5. Receiver writes acknowledgement.
6. Host releases the mailbox and updates counters.

Start with at least 256 messages per directional queue, subject to measured memory needs. Queue-full must never block an AGC. Initial policy: drop the newest message, set a sticky overflow status, and increment a diagnostic counter.

Support sequence validation, incomplete-message rejection, duplicate detection, acknowledgement timeout reporting, reset/resynchronization, and per-computer counters.

## Scheduler and execution model

Start with one host thread and deterministic bounded slices:

```text
initialize CMC
initialize LGC
initialize bus
initialize audio

while running:
    execute bounded CMC slice
    execute bounded LGC slice
    deliver pending bus messages at a defined boundary
    collect diagnostics
```

Do not assume one engine call equals one audio sample. Synthesis timing is determined by AGC execution and the experimental AGC program.

Implement two modes:

- **Offline:** execute as quickly as possible and record output for deterministic analysis.
- **Real-time:** pace execution and playback against a target rate, with timing/underrun diagnostics.

Implement and validate offline mode first.

## Experimental AGC programs

Do not modify the historical `Comanche055/` or `Luminary099/` source trees to add synthesizer code. Create separate experimental programs and assemble separate ROM images.

Initial intended roles:

**Comanche-derived CMC**
- Main pitch generation
- Integer phase accumulators
- Square/pulse waveforms
- Stepped triangle and crude sawtooth
- Small integer wavetable
- Primary rhythmic sequence

**Luminary-derived LGC**
- Pseudo-random/noise-like sequences
- Integer frequency or phase modulation
- Irregular pulses
- Sequence mutation
- Secondary rhythmic and melodic material

Each AGC must calculate its own waveform values. The bus should let one computer influence the other's synthesis state through musical messages.

Begin with the simplest possible program that emits a known sequence of sample values. Verify the capture path before implementing full synthesis.

## Implementation milestones and gates

Do not skip ahead. Each milestone must build on a passing previous milestone.

1. **Embedded baseline:** Build and run the upstream embedded demo. Verify ROM loading, execution, callbacks, and cleanup.
2. **Single-instance host:** Create one ODYSSEY computer and capture test channel writes into a host buffer.
3. **Audio proof:** Have an AGC program calculate a simple square or stepped waveform. Record values, timestamps, instruction cost, and achievable rate.
4. **State isolation:** Audit every mutable static/global in all linked engine files. Move per-computer state into instance-owned storage. Test independent initialization, stepping, reset, and destruction.
5. **Dual execution:** Run separate CMC and LGC instances with separate ROM images and output queues under the deterministic scheduler.
6. **Bus:** Implement bidirectional staged messages, commit, sequence numbers, mailbox delivery, acknowledgements, overflow, and diagnostics.
7. **Dual synthesis:** Implement the distinct synthesis programs and demonstrate measurable cross-computer musical influence.
8. **Audio backend:** Add real-time playback, independent gain/mute/solo, mixing, stereo positioning, and underrun reporting.

Do not declare a milestone complete based only on compilation. Provide the test command, test result, and evidence for each pass condition.

## Required acceptance tests

- Normal VirtualAGC build still works.
- Single embedded AGC execution works.
- CMC and LGC have independent memory and cycle counters.
- All mutable engine state is either per-instance or explicitly justified as process-wide.
- Initializing, resetting, or destroying one instance does not affect the other.
- Audio output is routed to the correct instance queue.
- Samples preserve per-instance order and sequence numbers.
- Sample timestamps are monotonic and useful for timing analysis.
- Bus messages are delivered only when complete and valid.
- CMC-to-LGC and LGC-to-CMC communication both work.
- Queue overflow never blocks AGC execution.
- Bus messages measurably alter the receiving AGC's synthesis behavior.
- Host code does not calculate the AGC oscillator waveform.
- Offline output can be recorded and inspected without an audio device.

Record instructions/cycles per second, samples per second, timing variation, message counts, dropped messages, queue overflows, audio underruns, and host CPU utilization.

## Coding and engineering rules

- Inspect source before editing; do not guess at current APIs or structure layouts.
- Make small, reviewable changes.
- Keep the standard VirtualAGC build working.
- Preserve licensing notices.
- Use explicit ownership and cleanup for allocations, buffers, and engine-private state.
- Avoid global mutable state and hidden cross-instance dependencies.
- Prefer deterministic tests and reproducible offline output.
- Document experimental channel assignments and verify conflicts.
- Document any deviation from this specification before implementing it.
- Do not silently substitute host-side synthesis for AGC-side synthesis.
- Do not claim thread safety, real-time performance, or sample rates without tests.
- When uncertain whether a behavior is inherited from Apollo hardware or invented for ODYSSEY, label it clearly as an ODYSSEY extension.

## Definition of done

The dual-AGC engine is not complete merely because two emulator structures can be allocated. It is complete when two independently executing AGCs can generate their own synthesis values, exchange musical messages through the virtual spacecraft bus, and produce separately capturable audio streams that the host can play and mix—without shared mutable CPU state and without host-generated oscillator waveforms.
