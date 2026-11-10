# ODYSSEY-AGC test ROM: SILENT
#
# Purpose:  Negative control for "the host must not synthesize audio".  This
#           program keeps all AGC watchdogs satisfied but NEVER writes the audio
#           channel.  The host must therefore capture exactly zero samples.
#
# License:  GNU GPL v2 or later (same as VirtualAGC).

$KEEPALIVE.agc

MAIN		RELINT
IDLE		CAF	KA37774			# non-TC instruction ...
		TCF	IDLE			# ... plus a TCF: satisfies TC Trap
