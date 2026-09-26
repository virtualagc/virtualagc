# Documentation staging log

Timestamped notes staged for other documents accumulate here between
documentation syncs.  Format:

    ### [YYYY-MM-DD] Target: [Target_Filename.md]
    - Brief, high-density update note

Applied and cleared 2026-09-16.

### [2026-09-25] Target: [yaShuttle/yaGPC2/README.md]
- DESIGN NOTE, owner's idea, NOT ASKED FOR YET: skeleton models for the
  peripherals PASS reads but this vehicle does not have, each answering with
  plausible data at first and growing later, so the buses carry traffic of the
  right kind and quantity.  `fc-bus-survey.py` already yields the
  specification: 75 commanded reads across the bus programs, 37 currently
  answered, 38 not -- SRB MDMs (12 reads, IUAs 6/9/15/18), FIOPFC15-19 on the
  FF/FA MDMs (8), EIUs (3, IUAs 17/23/24), nose wheel steering (3), IMUs (2),
  payload signal processor (2), payload data interleaver (2), launch data bus
  (2), GPS (1), MCIU (1).
- WHAT TODAY'S FAILURES SAY SUCH SKELETONS MUST GET RIGHT, each learned the
  expensive way:
  1. ZERO IS A READING, NOT A DEFAULT.  Answering the MDM's A/D BITE 4
     reference channels with zeros told PASS every converter in every forward
     and aft MDM was dead, and it isolated them exactly as designed --
     115,128 stopping instructions stored into the bus programs.  A skeleton
     whose unimplemented channels return zero will systematically report its
     own device broken.
  2. SYMMETRY BEATS ACCURACY.  A device that answers SOME computers and not
     others breaks the redundant set; one that answers none merely commfaults
     a string, which the flight software is built for.  So a skeleton must be
     a VEHICLE-level object on the vehicle's shared clock, never per-computer
     -- the timing unit was taking its time from whichever GPC was calling,
     which made its three accumulators three different computers' clocks.
  3. DELIVERY IS THE HARD PART, NOT THE DATA.  Five listener-delivery designs
     were tried and all five failed (see ledger #210).  Whatever framework
     these skeletons hang off must solve listener delivery ONCE, centrally,
     with wire timing on the shared clock -- mmumodel.c's tap is the proven
     shape -- rather than each device reinventing it.
  4. ANSWER ONLY AN ARMED RECEIVE.  A '#CMDI' that sets a listener's IUAR is
     not a read, and FIOHIBAD is a read of a channel that is not there which
     PASS branches to ON PURPOSE to stop a BCE.  Answering either defeats the
     flight software's own fault isolation.  iop_bce_armed_words tells them
     apart.
  6. FIRST SKELETON: GPS, not nose wheel steering (owner, 2026-09-25 -- a
     device that cannot be exercised without simulating a landing proves
     nothing).  FIOGPSPG is RESIDENT (SSW 1dd2c-1dda9, beside FIOPRMPG and
     FIONSPPG), so its traffic runs from the first IPL; it is BIDIRECTIONAL
     (FIOGPSRD X'00026C5F' MDM transmit, FIOGPSWT X'00022C5F' MDM receive,
     card 11 channel 2); it has THREE units FF01/02/03, one per string, so it
     drives redundancy management -- three agreeing is a test that RM is
     happy, making them disagree is a test that RM notices; it issues the
     LISTEN command, so it exercises the listener delivery that defeated five
     designs; and 32 words is a realistic payload for bus loading where a
     one-word read tells you nothing.  Scripted lat/lon/altitude/velocity is
     the right content: generated, not modelled, so the skeleton can be right
     about protocol while arbitrary about data.
     OBSERVABLE: SPEC 055 PRO, "GPS STATUS", in OPS 1, 2, 3, 6, 8 and 9 --
     readable as TEXT by the method used for the timing unit today
     (NSTS_ANNOUNCE_ROWS=all plus screenwatch.py), so no new tooling.  Note
     the traffic starts in OPS 0 but the display does not, so the end-to-end
     check needs an OPS transition.
  5. THE WIRE HAS A CAPACITY.  An FC bus carries ~940 commands/s in OPS 1; at
     33 us a word, replies must be the length actually armed for or the wire
     saturates.  The guessed 64-word reply was 2.1 ms against a 1 ms budget.

### [2026-09-25] Target: [yaShuttle/yaGPC2/README.md]
- The default-configuration gate exists to catch a regression of the build the
  owner validated clean, and it caught one: four fail votes at t=1914 with
  `YAGPC_FC_MDM` OFF.  Three behaviours the MDM work had made unconditional are
  now back behind that switch -- the listener echo rule, the wire pacing on the
  vehicle's shared clock, and the shared clock's effect on the mission
  ACCUMULATORS.  The last was the easy one to miss: folding the halt offset
  into `us` moved every accumulator in the default build, because `us` drives
  the accumulators while only the GMT epoch wants the offset.  `mtu_fill_time`
  now keeps `us` and `epochUs` apart.
- The one semantic change left unconditional is `BST_I` on an illegal BCE
  opcode (BCE Principles of Operation 3.4.7), and it is measured inert: zero
  occurrences in the failed gate's own log.
- `discretePanel/mtuscore.py` (new) scores a run for the timing unit and the
  set from one place -- votes with their times, the model's own counters, and
  the six FIOPRMPG bypass slots read out of a capture.  #210 has had more than
  one measurement voided because the two arms were scored differently.

### [2026-09-25] Target: [yaShuttle/yaGPC2/CAUSES.md]
- #212 added: a command word is not a unique device.  `fc_sym()` resolves by
  the 24-bit word alone and four words appear in both the read and the
  no-receive tables, so with no armed count the model falls back to the
  survey's length and can answer a transaction that asked for nothing.
  `src/fcbustable.h`'s own header already argued the armed count is the only
  right answer; the fallback is a deviation from that.  Not changed while the
  five-computer A/B was in flight.

### [2026-09-26] Target: [yaShuttle/yaGPC2/README.md]
- The MTU freeze is solved mechanically and reproduced twice: with the sensor
  reads answered (`YAGPC_FC_SENSORS`, default off) all six FIOPRMPG bypass
  slots stay live on GPC2-GPC5 through a five-computer ascent.  The
  accumulators freeze because of the SENSORS ON THEIR STRING -- FCMRTBLE
  groups NSP with MTU and FCMBCEMD bypasses the whole string.  It is not a
  shippable fix: both runs lose the redundant set, at different moments.
- The wire pacing had been indexing on `head`, the timing unit's reply cursor,
  which only mtu_fill_time resets.  Listeners lost their data word:
  2,240 command syncs against 8 data words at FIOBYNC3+4, 1,560 error
  terminations, 3 votes.  After: 2,352 against 1,176, 51 errors, 0 votes.
- `make -j8` does not build the unit tests, and test_mtumodel printed a
  hard-coded "23/23" over sixteen checks.  Both hid a live defect behind a
  passing run.  Worth a line in the README's testing section.
