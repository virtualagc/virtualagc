/*
 * ODYSSEY-AGC -- experimental dual-AGC synthesizer built on VirtualAGC.
 *
 * Filename:  odyssey_config.h
 * Purpose:   Compile-time constants and the ODYSSEY experimental channel map.
 *
 * Licensed under the GNU General Public License v2 or later, like the
 * VirtualAGC code it links against.  See ../../COPYING.
 *
 * IMPORTANT: everything defined here is an ODYSSEY EXTENSION.  None of the
 * channel numbers below are original Apollo channel definitions, and nothing
 * here implies that Apollo flight hardware or flight software produced audio.
 */
#ifndef ODYSSEY_CONFIG_H
#define ODYSSEY_CONFIG_H

/* ------------------------------------------------------------------------
 * Experimental I/O channel map (octal), from AGENTS.md.
 *
 * Verified against the checked-out engine (see docs/CHANNEL-VERIFICATION.md):
 *   - NUM_CHANNELS is 512 (octal 0777), so every channel below is in range;
 *   - the engine routes every CPU WRITE to ChannelOutput(State, ch, value);
 *   - agc_engine.c / agc_engine_init.c contain no reference to any channel
 *     numbered 0200 or above (grep-checked), so 0300-0325 do not collide with
 *     engine-defined channel behaviour.
 * ---------------------------------------------------------------------- */
#define ODY_CH_AUDIO_SAMPLE   0300  /* AGC writes one 15-bit audio sample    */
#define ODY_CH_AUDIO_CONTROL  0301  /* audio control/status (host: latched)  */

/* Bus channels: reserved here, NOT yet implemented (milestone 6). */
#define ODY_CH_BUS_TX_TYPE    0310
#define ODY_CH_BUS_TX_SEQ     0311
#define ODY_CH_BUS_TX_DATA0   0312
#define ODY_CH_BUS_TX_DATA1   0313
#define ODY_CH_BUS_TX_COMMIT  0314
#define ODY_CH_BUS_RX_STATUS  0320
#define ODY_CH_BUS_RX_TYPE    0321
#define ODY_CH_BUS_RX_SEQ     0322
#define ODY_CH_BUS_RX_DATA0   0323
#define ODY_CH_BUS_RX_DATA1   0324
#define ODY_CH_BUS_RX_ACK     0325

/* ------------------------------------------------------------------------
 * Computer identities.  The host routes by instance, so both computers may
 * use the same logical channel numbers.
 * ---------------------------------------------------------------------- */
#define ODY_COMPUTER_CMC  0     /* Comanche-derived command-module computer */
#define ODY_COMPUTER_LGC  1     /* Luminary-derived lunar-module computer   */
#define ODY_MAX_COMPUTERS 2

/* ------------------------------------------------------------------------
 * Sample queue.  Capacity MUST be a power of two.  One queue per computer.
 * Overflow policy: drop the NEWEST sample, bump a counter, never block.
 * ---------------------------------------------------------------------- */
#define ODY_SAMPLE_QUEUE_CAPACITY (1u << 16)

/* Default bounded execution slice, in engine calls (one call == one AGC
 * machine cycle, MCT, nominally 11.72 microseconds). */
#define ODY_DEFAULT_SLICE_CYCLES 1000u

#endif /* ODYSSEY_CONFIG_H */
