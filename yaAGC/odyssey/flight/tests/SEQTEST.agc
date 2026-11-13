# ODYSSEY-AGC test ROM: SEQTEST
#
# Purpose:  Milestone 2 capture-path proof.  The AGC writes a FIXED list of
#           15-bit words to the ODYSSEY audio-sample channel (octal 0300), then
#           writes 1 to the audio-control channel (octal 0301) and spins.
#           The list deliberately includes +0, -0 (077777), the positive and
#           negative extremes, and a mid-range pair, to exercise the one's
#           complement -> PCM conversion.
#
# NOTE:     Channels 0300/0301 are an ODYSSEY EXTENSION, not Apollo channels.
#           This is a test program, not Apollo flight software.
#
# License:  GNU GPL v2 or later (same as VirtualAGC).

$KEEPALIVE.agc

MAIN		RELINT				# interrupts on: T3RUPT keeps the watchdogs fed
		CAF	W1
		EXTEND
		WRITE	0300
		CAF	W2
		EXTEND
		WRITE	0300
		CAF	W3
		EXTEND
		WRITE	0300
		CAF	W4
		EXTEND
		WRITE	0300
		CAF	W5
		EXTEND
		WRITE	0300
		CAF	W6
		EXTEND
		WRITE	0300
		CAF	W7
		EXTEND
		WRITE	0300
		CAF	W8
		EXTEND
		WRITE	0300

		CAF	DONEVAL
		EXTEND
		WRITE	0301			# audio control: "sequence finished"
SPIN		CAF	DONEVAL			# non-TC instruction + TCF every pass
		TCF	SPIN   			# (satisfies the TC Trap watchdog)

# Expected captured sequence (octal word -> signed value):
#   00000 -> 0      (+0)
#   00001 -> 1
#   37777 -> 16383  (largest positive)
#   40000 -> -16383 (largest negative)
#   77777 -> 0      (-0)
#   77776 -> -1
#   12345 -> 5349
#   65432 -> -5349
W1		OCT	00000
W2		OCT	00001
W3		OCT	37777
W4		OCT	40000
W5		OCT	77777
W6		OCT	77776
W7		OCT	12345
W8		OCT	65432
DONEVAL		OCT	00001
