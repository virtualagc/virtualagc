/* The GPC discrete-input bus, receiving side.
 *
 * A GPC's discrete inputs are hardware lines rather than bus traffic: the
 * crew panel drives HALT/STANDBY/RUN, a mass memory drives its own READY,
 * the orbiter drives BFS engage.  This emulator held them as a fixed
 * constant, which is fine for software that samples a discrete once and
 * fatal for software that HANDSHAKES on one -- see iop.c's
 * iop_discrete_in_a() for what FCMBOOT does with MASS MEMORY READY.
 *
 * iop.c can derive that one bit locally, from whether this GPC's own bus
 * controller is running, and does; that is enough to get the bootstrap
 * through its handshake with nothing else attached.  It is not the real
 * signal, though.  The real one comes from the mass memory, and when a
 * mass memory is actually present it should be the thing that says so.
 *
 * This subscribes to the bus those devices publish on -- the same
 * multicast transport as every other inter-process signal here, group
 * 239.255.1.1, port 6980, one datagram per set/reset.  Four 16-bit words
 * in network order:
 *
 *     0   operation   SET = 1, RESET = 2
 *     1   register    A = 1 (inputs 1-32), B = 2 (inputs 33-40)
 *     2   mask, high half    IBM bit 0 is 0x8000 of this word
 *     3   mask, low half
 *
 * Set/reset of a MASK rather than a whole word is what lets a mass memory
 * and a crew panel drive different bits of register A without either
 * overwriting the other's.  yaShuttle/discretePanel/ has the same protocol
 * in Python, with the reasoning written out, plus a panel and a monitor.
 *
 * WHAT WINS
 *
 * A bit somebody is actually publishing overrides whatever iop.c would
 * derive for it; a bit nobody is publishing keeps the derived or
 * configured value.  So attaching a real mass memory takes over READY,
 * and running with nothing attached still works.
 *
 * A discrete is a level, and publishers repeat themselves precisely
 * because this transport can drop a datagram and has no replay for a late
 * joiner.  A bit therefore counts as externally driven only while its
 * publisher is still being heard from: go quiet for DISCRETES_STALE_SEC
 * and it reverts to the local value, rather than latching whatever was
 * last seen.  Without that, a publisher killed mid-transfer would leave
 * READY stuck low and hang the flight software with nothing to show why.
 */
#ifndef YAGPC_DISCRETES_H
#define YAGPC_DISCRETES_H

#include <stdbool.h>
#include <stdint.h>

/* ONE PER COMPUTER, not one per process.  Five GPCs run in one process and
 * each has its own discrete channel (port base+80+gpcId), its own register
 * A/B/OUT, and its own view of who is driving what.  The bus really is per
 * computer -- see the channel-per-GPC note on DISCRETES_PORT_FOR -- so this
 * is the machine's connection to it, held by the BatchRunner that owns the
 * machine and reachable from its IOP. */
typedef struct Discretes Discretes;

#define DISCRETES_REG_A 1
#define DISCRETES_REG_B 2
/* The discrete OUTPUT register, added with REQUEST/VALUE in
 * nsts-sim-gpc 7946bc1.  The GPC owns every bit of it and publishes its
 * own writes; nothing else drives it. */
#define DISCRETES_REG_OUT 3

/* THE FAIL-VOTE DISCRETES -- the GPC STATUS matrix on panel O1.
 *
 * Five bits, one computer's ROW of the 5x5 matrix: which computers THIS one
 * has voted out of the set.  They are not a software report but a hardware
 * register, driven by the IOP's MSC through the @SFD and @RFD instructions
 * (Set / Reset Fail Discretes) from the MSC program FCMSFCAM, whose two
 * masks -- TCVTSETC and TCVTRESC -- FCMSFAIL fills as it votes.  An
 * application asks for them through SVC 25 request 2, the SETCAMEX macro in
 * INCL80/CAMEMACS.hal; CAM is the Computer Annunciation Matrix, which is
 * what the panel lamps are.
 *
 * THE BITS, per the IOP Principles of Operation (IBM 6246556A, @SFD/@RFD):
 * the MSC accumulator's bits 0-4 land here, bit 0 -- 0x10 in this value --
 * "will inhibit the output of the four fail discretes", and bits 1-4 --
 * 0x08, 0x04, 0x02, 0x01 -- are the four fail discretes themselves.  They
 * are ROTATED as the sync lines are: 0x08 is a vote against the computer
 * N+1 places along from this one, 0x01 against N+4.  CONFIRMED by run
 * le-g5-0, where GPC1, 2, 3 and 5 all voted GPC4 out and published 0x02,
 * 0x04, 0x08 and 0x01 -- N+3, N+2, N+1 and N+4 of each.  What is published
 * is the RAW REGISTER; a consumer wanting columns un-rotates it. */
#define DISCRETES_REG_FAILVOTE 4

/* THE COMPUTER FAIL LAMP -- the CAM's diagonal.  Bit 31 (value 1) lit.
 *
 * A computer's own cell on the diagonal shows its Computer Fail: the RM
 * voter's fail latch, which the hardware sets when "at least two of four"
 * fail discretes from the other computers vote against it, and which
 * FCMSFAIL also sets on purpose -- "ISSUE GPC TEST VOTER COMMAND TO LIGHT
 * SELF'S DIAGONAL" -- when it finds itself alone.  Not an IOP register:
 * the emulated voter models self test only, so this is composed by the
 * vehicle FOR THE LAMP (see vehicle_votes_against and run.c) and changes
 * nothing the flight software sees.  A new register on the wire; nothing
 * but cam.py reads it. */
#define DISCRETES_REG_CFAIL 5

/* How long a bit stays "externally driven" after its last message.
 * Publishers republish every 250 ms, so this is several periods -- long
 * enough not to flap on a dropped datagram, short enough that a departed
 * publisher does not strand the machine.  YAGPC_DISCRETES_STALE_SEC
 * overrides it. */
#define DISCRETES_STALE_SEC 1.5

/* Join the bus as the named computer (1-5, or 0 for a standalone GPC).
 * NULL (with a message on stderr) if the socket cannot be opened; the caller
 * carries on without it, and every function below is a safe no-op on NULL. */
Discretes *discretes_create(int gpcId);
void discretes_free(Discretes *d);
bool discretes_enabled(const Discretes *d);

/* Take in whatever has arrived.  Cheap, non-blocking, and safe to call on
 * every read of the discrete registers -- which is what iop.c does, so the
 * value a PCI returns is as fresh as the wire. */
void discretes_poll(Discretes *d);

/* One datagram at a time, for a caller that must not miss an intermediate
 * state -- see the definition. */
bool discretes_poll_one(Discretes *d);

/* THE INTER-GPC WIRING.
 *
 * A computer's discrete OUTPUT register carries its own STBY (bit 20), BFS
 * RUN (22), RUN (24) and SYNC (28), and those four lines run to the other
 * four computers' INPUT register A -- at a position that depends on who is
 * listening.  The groups are numbered N+1..N+4 relative to the reader, and
 * "the wiring rotates, so N+1 at gpc 1 is gpc 2 and N+1 at gpc 5 is gpc 1"
 * (BILDNEW5.asm).  So the same fact -- "GPC 4 is in RUN" -- arrives at a
 * DIFFERENT BIT in each recipient's register.
 *
 * STBY/RUN/SYNC are not three independent signals.  The flight software
 * drives them as one 3-bit code (it calls them A, B, C): null is all three
 * set, X'0888' in the output register, and a sync is issued by RESETTING
 * bits out of that -- 110 SSIP, 101 timer, 100 SVC, 010 input problem
 * report, 001 I/O complete, 000 halt/standby/dead.  Five FCOS programs spin
 * on the result with a 3.85 ms timeout and vote out whoever misses it, so a
 * code that arrives half-applied is a different code with a different
 * meaning.  They are therefore rotated and delivered together.
 *
 * `k` is which neighbour the source is, from the reader's seat:
 * (source - reader) mod 5, 1..4.  Returns the reader's register A mask for
 * the bits `outMask` sets in the source's output register. */
/* The three output lines that carry the sync code: STBY (20), RUN (24) and
 * SYNC (28), X'0888'.  All three clear is 000, "halt / standby / dead" -- the
 * code a computer that is not executing must present, so that its neighbours
 * read it as gone rather than as present and silent.  See run.c's held path. */
#define DISCRETES_OUT_SYNC_MASK 0x00000888u

uint32_t discretes_rotate_out(int sourceGpc, int readerGpc, uint32_t outMask);

/* Publish onto ANOTHER computer's channel, from this one's socket.  That is
 * what the inter-GPC wiring is: GPC n's output lines are an input to GPC m,
 * so n drives them on m's channel and m hears them as it hears any other
 * device.  Deliberately over the wire rather than reached into m's state --
 * m must see them as externally driven, and a monitor should see them too. */
void discretes_publish_to(Discretes *from, int destGpc, int reg, uint32_t mask,
                          bool on);

/* APPLY A CHANGE STRAIGHT INTO THIS COMPUTER'S REGISTER, from another
 * computer's thread.
 *
 * The datagram in discretes_publish_to is the right carrier for a crew panel
 * and the only one an external monitor can see, but it is far too slow for
 * the inter-GPC sync lines, which FCOS gives a 3.85 ms timeout.  MEASURED
 * between two machines in one process: median 0.80 ms, p90 158.6 ms, worst
 * 455.9 ms, with 28.7% of codes arriving LATE -- the median is the receiving
 * machine's poll interval and the tail is it sitting in the real-time idle
 * wait, not executing instructions and so not polling at all.  A quarter of
 * every sync missing its deadline is not a set that can form.
 *
 * So when the sender and the receiver are in the same process, the bits go
 * in directly and the datagram is still sent, for the monitors.  Safe to
 * call from another machine's thread. */
void discretes_apply_external(Discretes *d, int reg, uint32_t mask, bool on);

/* SET AND CLEAR IN ONE INDIVISIBLE STEP.
 *
 * The inter-GPC lines are a three-bit code, and half of one is a DIFFERENT
 * code with a different meaning -- which is why the rotation delivers all
 * three together.  Applying the set and the clear as two locked operations
 * defeats that: the neighbour's CPU reads discrete input A whenever it likes,
 * and a read landing between them sees a torn code.  Measured, that is what
 * the sync failures are: each computer waiting on TWO of its neighbour's
 * three bits, GPC1 on 0x088 out of 0x888 and GPC2 on 0x011 out of 0x111. */
void discretes_apply_external_pair(Discretes *d, int reg, uint32_t setMask,
                                   uint32_t clrMask);

/* Told whenever this computer's discrete OUTPUT register changes, so the
 * vehicle can route the inter-GPC lines to the other computers. */
typedef void (*DiscretesOutFn)(void *ctx, int sourceGpc, uint32_t before,
                               uint32_t after);
void discretes_set_out_hook(Discretes *d, DiscretesOutFn fn, void *ctx);
/* Input bits of `reg` that a neighbour in this process writes directly; a
 * received datagram for them is ignored (see apply() in discretes.c). */
void discretes_set_local_wired(Discretes *d, int reg, uint32_t mask);

/* YAGPC_SYNCTRACE: report this computer's outgoing 3-bit sync code and each
 * neighbour's incoming one whenever either changes, decoded into the flight
 * software's own alphabet.  Called from the poll and publish paths; a no-op
 * unless the variable is set.  See the block comment in discretes.c for the
 * codes and where they come from. */
void discretes_synctrace(Discretes *d);
/* Print the recorded sync conversation (YAGPC_SYNC_HISTORY=N), which is
 * what a full trace would have shown without the full trace's cost.
 * Called when a computer declares a sync failure -- the one moment the
 * history is worth having. */
void discretes_dump_history(Discretes *d, const char *why);
/* This machine's own 3-bit sync code as it stands now.  A phase that
 * outlasts every healthy one is the thing to catch: an SVC phase runs
 * 211 us median and has never exceeded 638 us in 155,580 samples, while
 * the peers in the #190 failure held one for 4.7 ms. */
/* Record a bus program's end in the sync history (see sync_record). */
void discretes_note_io_done(Discretes *d, int bce, bool error);
void discretes_note_sim_us(Discretes *d, double us);
unsigned discretes_sync_code_out(Discretes *d);
const char *discretes_sync_code_name(unsigned code);

/* Bits of `reg` currently being published by somebody, and their values.
 * Call discretes_poll() first.  The mask is empty when disabled, so
 * callers need no special case. */
uint32_t discretes_driven_mask(const Discretes *d, int reg);
/* How long ago, in attentive seconds, BIT (IBM numbering, 0 = MSB) of REG was
 * last heard from outside; negative if never.  For YAGPC_HELDTRACE. */
double discretes_bit_age(const Discretes *d, int reg, int bit);
uint32_t discretes_value(const Discretes *d, int reg);

/* Datagrams applied since open, for the run summary. */
unsigned long discretes_message_count(const Discretes *d);

/* Changes whenever the discrete bus state does; lets a caller cache what it
 * derived from discretes_driven_mask()/discretes_value(). */
unsigned discretes_generation(const Discretes *d);

/* The whole value of a register as this GPC believes it -- what a REQUEST
 * is answered with.  iop.c keeps A and B current here because only it can
 * combine the locally derived bits with the published ones; the OUT
 * register is this process's own and is published on every change. */
void discretes_set_canonical(Discretes *d, int reg, uint32_t value);
void discretes_publish_out(Discretes *d, uint32_t before, uint32_t after);

/* Publish a change in this computer's fail-vote register.  A no-op when the
 * value has not moved, so it is safe to call periodically. */
void discretes_publish_failvote(Discretes *d, uint32_t value);
/* This computer's CAM diagonal -- see DISCRETES_REG_CFAIL. */
void discretes_publish_cfail(Discretes *d, bool lit);

/* Drive a level onto the bus, for a device modelled in this process that
 * a real vehicle would have wired to a discrete line -- the mass memory's
 * READY, to begin with.  Publishing it is what lets a crew panel or any
 * other listener SEE the signal; without it the line exists only inside
 * this process and the panel's "observed" pane stays blank whether the
 * emulator is running or not.
 *
 * A discrete is a level, so this must be repeated: subscribers drop a bit
 * they have not heard about for DISCRETES_STALE_SEC.  Call it whenever the
 * level changes and periodically regardless.  Cheap and non-blocking; a
 * no-op when the bus was never opened.
 *
 * What we publish, we do NOT then read back as though somebody else had
 * driven it: see discretes_driven_mask.  The model that drove the line is
 * in this process and already authoritative, and routing its own signal
 * out through a socket and back would put UDP delivery -- the very thing
 * --mmu-model exists to keep out of the tape path -- between a device and
 * the machine reading it. */
void discretes_publish(Discretes *d, int reg, uint32_t mask, bool on);


/* ALL bus ports derive from one base, so a second emulation can be run
 * alongside the first without fighting over sockets.  Bus n listens on
 * base+n (IC1-5 = 1-5, DK1-4 = 6-9, ... FC1-4 = 20-23) and the discrete
 * bus on base+80, matching nsts-sim-gpc's busConfig at the default base
 * of 6900.  Set once, before any socket is opened, from --port-base or
 * NSTS_BUS_PORT_BASE. */
#define YAGPC_PORT_BASE_DEFAULT 6900
#define YAGPC_DISCRETES_OFFSET  80
void yagpc_set_port_base(int base);
int  yagpc_port_base(void);
/* The port base stays process-wide: the five computers share one port range
 * by design.  The GPC IDENTITY does not -- it is a property of a machine, is
 * now carried by its Discretes, and selects both that machine's discrete
 * channel and its intercomputer (bus 24) port. */
int  discretes_gpc_id(const Discretes *d);

#endif
