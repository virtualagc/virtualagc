![http://virtualagc.googlecode.com/svn/trunk/Apollo32.png](http://virtualagc.googlecode.com/svn/trunk/Apollo32.png)

| This page is under construction has not been extensively checked for errors. |
|:-----------------------------------------------------------------------------|



## Introduction ##

The "block 1" AGC used in unmanned Apollo missions, and which would have been used for the Apollo 1 mission, is very similar to the "block 2" AGC used in all of the manned missions.  But it also differs in a number of details that affect programs written for the block 1 computers, as well as the implementation of the assembler and CPU simulator.  The block 1 DSKY is also quite different in physical appearance from the block 2 DSKY.

This wiki page is intended to described all of the differences in adequate detail to guide implementation changes in the Virtual AGC yaYUL, yaAGC, and yaDSKY(2) programs, as well as to provide guidance for a programmer familiar with block 2 systems to write block 1 programs.


## Documentation for Consultation ##

  * Language definition:
    * AGC3 language, which preceded the AGC4 computer used for Block 1 and Block 2, is defined in document [E-1077](http://www.ibiblio.org/apollo/NARA-SW/E-1077.pdf).
    * Block 1 machine language is defined in document [R-393](http://www.ibiblio.org/apollo/hrst/archive/1008.pdf).
    * Block 2 machine language is defined in [Memo #9](http://www.ibiblio.org/apollo/hrst/archive/1689.pdf), as supplemented by the [AGC4 Basic Training Manual](http://www.ibiblio.org/apollo/NARA-SW/E-2052.pdf).
  * (More later)


## Differences Between Block I and Block II Basic Assembly Language ##

At the source level, the Block I basic language is essentially a subset of the Block II basic language, with a few exceptions.

The common instructions (at the source-code level) between Block 1 and Block 2 are:  AD, CAF, CCS, COM, CS, DEC, DOUBLE, DV, EXTEND, INDEX, INHINT, MASK, MP, NDX, NOOP, OVIND, OVSK, RELINT, RESUME, RETURN, SQUARE, SU, TC, TCR, TCAA, TS, and XCH.  The entire set of i/o channel instructions from Block 2 (such as READ, WRITE, ROR, WOR, RAND, WAND, etc.) is missing from Block 1, since the Block 1 computer uses a memory-mapped i/o system rather than having a separate i/o address space.

Note, however, that some of the exceptional instructions which have been assigned special meanings or given special shorthand mnemonics are not quite the same between Block I and Block II, as follows:

| **Shorthand Mnemonic** | **In Block 1** | **In Block 2** | **Comment** |
|:-----------------------|:---------------|:---------------|:------------|
| BBCON              | (missing)  | OCT 66100   |  |
| COM                | CS A       | CS A        |  |
| DCOM               | (missing)  | DCS A       |  |
| DDOUBL             | (missing)  | DAS A       |  |
| DOUBLE             | AD A       | AD A        |  |
| DTCB               | (missing)  | DXCH Z      |  |
| DTCF               | (missing)  | DXCH 4      |  |
| EXTEND             | INDEX 5777 | TC 6        | Additionally, the programmer is expected to have preloaded address 5777 with the value 47777. |
| INHINT             | INDEX 17   | TC 4        |  |
| NOOP               | XCH A      | (depends on memory region) |  |
| OVSK               | TS A       | TS A        |  |
| RELINT             | INDEX 16   | TC 3        |  |
| RESUME             | INDEX 25   | INDEX 17    |  |
| RETURN             | TC Q       | TC Q        |  |
| SQUARE             | MP A       | MP A        |  |
| TCAA               | TS Z       | TS Z        |  |
| XAQ                | TC A       | (missing)   |  |
| XLQ                | (missing)  | TC L        |  |
| XXALQ              | (missing)  | TC A        |  |
| ZL                 | (missing)  | LXCH 7      |  |
| ZQ                 | (missing)  | QXCH 7      |  |

In general, the differences in the table above wouldn't be significant _if_ the shorthand mnemonics were always used, since the assembler would automatically substitute the correct equivalent.  In very old code, however, one sometimes sees forms like INDEX 17 used directly rather than the short-form INHINT (in Block 1) or RESUME (in Block 2), and in these cases Block 1 code would not run as expected on a Block 2 AGC, or vice-versa.

Though basically forward-compatible at the source-code level, various instructions assemble to different binary machine-code in Block 1 than in Block 2.  We won't elaborate those differences here, since you can find them in the linked reference documents.  This is usually a matter of complete indifference, since the assembler will substitute the correct binary values.  _However_, there is one case in which it is important, and that is the case in which the coder has essentially hand-assembled the code and provides numerical values for the opcodes in place of the normal mnemonics.  This is sometimes seen in very old code, where you might see an instruction like

```
        3       VARIABLE
        # In Block 1 this is the same as
        XCH     VARIABLE
        # In Block 2 this is the same as
        CA      VARIABLE
```

As far as pseudo-ops are concerned, we can't really be sure what the complete set of supported pseudo-ops is for Block 1, since there is no document that defines them.  (Indeed, this is even partially true for Block 2, since a few pseudo-ops appearing in actual Block 2 source code are not defined in any known document.)  The only large example of Block 1 code which is presently accessible is the Apollo 4 program, Solarium 55.  In examining Solarium 55, we conclude that with one exception the Block 1 pseudo-ops are a compatible but greatly reduced subset of Block 2 pseudo-ops, as follows:  =, 2DEC, 2DEC`*`, 2OCT, ADRES, BANK, CADR, DEC, EQUALS, ERASE, OCT, OCTAL, SETLOC.  Note that the Block 1 memory space had no "super-banks" (fixed-memory banks 40, 41, 43, and 43), so there was no need for any pseudo-ops like SBANK whose essential purpose was to deal with super-banks.

The exception mentioned above is that Block 1 has a pseudo-op XCADR which does not exist in Block 2.  The purpose of XCADR is TBD.

## Interpreter-Language Differences ##

Block 1 and Block 2 interpreter languages are identical in syntax, but only partially overlap in terms of the opcodes they supply.  At present, there is no known documentation for the Block 1 interpreter language, so some of the information in the table below is based on inspection of the Block 1 Solarium 55 program, and on the definition of AGC3 interpreter language, which preceded and was obsoleted by Block 1. It is therefore possible that some instructions which are marked as unsupported are actually supported by the simulation; however, they are _not_ supported by the modern assembler.

| **Name** | **Description**  | **AGC3?** | **Block 1?** | **Block 2?** |
|:---------|:-----------------|:----------|:-------------|:-------------|
| ABS or ABVAL | Length of vector or magnitude of scalar. |   | Y | Y |
| ACOS or ARCCOS | Arc cosine. |   | Y | Y |
| ASIN or ARCSIN | Arc sine. |   | Y | Y |
| AST,1 and AST,2 | TBD |   | Y |  |
| AXC,1 and AXC,2 | Address to INDEX complemented. |   | Y | Y |
| AXT,1 and AXC,2 | Address to INDEX true. |   | Y | Y |
| BDDV and BDDV| DP divide into. |   | Y | Y |
| BDSU and BDSU| DP subtract from. |   | Y | Y |
| BHIZ | Branch hi zero |   | Y | Y |
| BPL and BMN  | Branch plus and branch minus. |   | Y | Y |
| BOFCLR BOF BOFF BOFINV BOFSET BON BONCLR BONINV BONSET | Conditional branches |   |  | Y |
| BOV | Branch on overflow |   | Y | Y |
| BOVB | Branch on overflow to Basic. |   |  | Y |
| BVSU and BVSU| Vector subtract from. |   |  | Y |
| BZE | Branch on zero. |   | Y | Y |
| CALL or CALRB | Call and store QPRET. |   |  | Y |
| CCALL and CCALL| Computed call. |   |  | Y |
| CGOTO and CGOTO| Computed goto. |   |  | Y |
| CLEAR or CLR or CLRGO | Clear. |   |  | Y |
| COMP   | Complement vector or scalar. |   | Y |  |
| COS or COSINE and COS| Cosine. |   | Y | Y |
| CROSS | DP Vector Cross Product. | Y |  |  |
| DAD and DAD| DP add. | Y | Y | Y |
| DCA | DP clear and add | Y |  |  |
| DCOMP | DP complement |   |  | Y |
| DCS | DP clear and subtract | Y |  |  |
| DDV and DDV| DP divide by. | Y | Y | Y |
| DLOAD and DLOAD| Load MPAC with a DP scalar. |   |  | Y |
| DMOVE and DMOVE| DP move. |   | Y |  |
| DMP and DMP| DP multiply. | Y | Y | Y |
| DMPR and DMPR| DP multiply and round. |   | Y | Y |
| DO | Do Single Instruction | Y |  |  |
| DOT and DOT| DP Vector Dot Product. | Y | Y | Y |
| DSQ    | DP square. |   | Y | Y |
| DSU and DSU| DP subtract. | Y | Y | Y |
| DTS | DP transfer to storage. | Y |  |  |
| DXCH | DP exchange. | Y |  |  |
| EXIT | Exit from interpretive mode |   | Y | Y |
| GOTO | Unconditional jump |   |  | Y |
| IBMN | Interpreted Branch Minus | Y |  |  |
| INCR | Increment register. | Y |  |  |
| INCR,1 and INCR,2   | Increment INDEX register. |   | Y | Y |
| INI | Interpreted index | Y |  |  |
| INVERT or INVGO | Invert |   |  | Y |
| ITA | Interpreted Transfer Address | Y | Y | Y |
| ITC | TBD | Y | Y |  |
| ITC**ITCI ITCQ**| TBD |   | Y |  |
| LODON | TBD |   | Y |  |
| LXA,1 and LXA,2    | Load INDEX from erasable. |   | Y | Y |
| LXC,1 and LXC,2    | Load INDEX from complement of erasable. |   | Y | Y |
| MXV and MXV| DP Matrix post-multiplied by vector. | Y | Y | Y |
| NOLOD | TBD |   | Y |  |
| NORM and NORM| TBD |   |  | Y |
| PDDL and PDDL| Push down MPAC and load DP. |   |  | Y |
| PDVL and PDVL| Push down MPAC and load vector. |   |  | Y |
| PUSH   | Push down MPAC. |   |  | Y |
| ROUND  | Round to DP. |   | Y | Y |
| RTB | Return To Basic. |   | Y | Y |
| RVQ    | Return via QPRET. |   |  | Y |
| SET | TBD |   |  | Y |
| SETGO | TBD |   |  | Y |
| SETPD  | Set push down pointer (direct only). |   |  | Y |
| SIGN and SIGN| Complement MPAC (V or SC) if X negative. |   | Y | Y |
| SIN or SINE and SIN| Sine. |   | Y | Y |
| SL and SL| TBD |   |  | Y |
| SLOAD and SLOAD| Load MPAC in single precision. |   |  | Y |
| SL1 SL1R SL2 SL2R SL3 SL3R SL4 SL4R | TBD |   | Y |  |
| SLR and SLR| TBD |   | Y |  |
| SMOVE and SMOVE| TBD |   | Y |  |
| SQRT   | Square root. |   |  | Y |
| SR and SR| TBD |   | Y |  |
| SR1 SR1R SR2 SR2R SR3 SR3R SR4 SR4R | TBD |   | Y |  |
| SRR and SRR| TBD |   | Y |  |
| SSP and SSP| Set single precision into X. | Y |  | Y |
| STADR  | Push up on store code. |   |  | Y |
| STCALL | Store and do a call. |   |  | Y |
| STODL  | Store MPAC and reload it in DP with the next address. |   |  | Y |
| STOVL  | Store MPAC and reload a vector. |   |  | Y |
| STORE  | Store MPAC. |   | Y | Y |
| STQ | TBD |   |  | Y |
| STZ | TBD |   | Y |  |
| SWITCH    | Switch instructions. |   | Y |  |
| SXA,1 and SXA,2    | Store index in erasable. |   | Y | Y |
| TAD and TAD| TP Add to MPAC. | Y | Y | Y |
| TCS | TP Clear and Subtract. | Y |  |  |
| TEST | TBD |   | Y |  |
| TIX,1 and TIX,2    | Transfer on INDEX. |   | Y | Y |
| TLOAD and TLOAD| Load MPAC with triple precision. |   |  | Y |
| TP | TBD |   | Y |  |
| TSLC   | Normalize MPAC (scalar only). |   | Y |  |
| TSLT and TSLT| Triple Shift Left | Y | Y |  |
| TSRT and TSRT| Triple Shift Right | Y | Y |  |
| TSU | TBD |   | Y |  |
| TTS | TP Transfer to Storage | Y |  |  |
| UNIT   | Unit vector. |   | Y | Y |
| V/SC and V/SC| Vector divided by a scalar. |   |  | Y |
| VAD and VAD| DP Vector add. | Y | Y | Y |
| VCA | DP Vector Clear and Add | Y |  |  |
| VCOMP | TBD |   |  | Y |
| VCS | DP Vector Clear and Subtract. | Y |  |  |
| VDEF   | Vector define. |   | Y | Y |
| VLOAD and VLOAD| Load MPAC with a vector. |   |  | Y |
| VMOVE and VMOVE| TBD |   | Y |  |
| VPROJ and VPROJ| Vector projection. |   | Y | Y |
| VSC | DP Vector Times Scalar. | Y |  |  |
| VSL and VSL| TBD |   | Y |  |
| VSL1 VSL2 VSL3 VSL4 VSL5 VSL6 VSL7 VSL8 | TBD |   | Y |  |
| VSLT and VSLT| TBD |   | Y |  |
| VSQ    | Square of length of vector. |   | Y | Y |
| VSR and VSR| TBD |   | Y |  |
| VSR1 VSR2 VSR3 VSR4 VSR5 VSR6 VSR7 VSR8 | TBD |   | Y |  |
| VSRT and VSRT| TBD |   | Y |  |
| VSU and VSU| Vector subtract. |   | Y | Y |
| VTS | DP Vector Transfer to Storage. | Y |  |  |
| VXCH | DP Vector Exchange. | Y |  |  |
| VXM and VXM| DP Matrix pre-multiplied by vector. | Y | Y | Y |
| VXSC and VSXC| Vector times scalar. |   | Y | Y |
| VXV and VXV| Vector cross product. |   | Y | Y |
| XAD,1 and XAD,2    | INDEX register add from erasable. |   | Y | Y |
| XCHX,1 and XCHX,2   | Exchange INDEX with erasable. |   | Y | Y |
| XSU,1 and XSU,2    | INDEX subtract from erasable. |   | Y | Y |

Though there is a certain compatibility at the source-code level implied by the table above, at the binary level the interpreter source assembles to different code.  One difference in particular is that when two interpreter opcodes are packed into a single memory word, seven bits for each, the order of the packing is swapped.  These binary differences are generally irrelevant to the coder, since coders never hand-assemble interpreter code.

## Register Differences ##
  * Central registers
| **Address** | **Type**    | **Block I**  | **Block II** | **Comment** |
|:------------|:------------|:-------------|:-------------|:------------|
| 00000     | Flip-flop | A          | A          |  |
| 00001     | Flip-flop | Q          | L          |  |
| 00002     | Flip-flop | Z          | Q          |  |
| 00003     | Flip-flop | LP         | EB         |  |
| 00004     | Flip-flop | IN0        | FB         | IN registers replaced by i/p channels on Block II. |
| 00005     | Flip-flop | IN1        | Z          |  |
| 00006     | Flip-flop | IN2        | BB         |  |
| 00007     | Flip-flop | IN3        | Zeros      |  |
| 00010     | Flip-flop | OUT0       | ARUPT      | OUT registers replaced by o/p channels on Block II. |
| 00011     | Flip-flop | OUT1       | LRUPT      |  |
| 00012     | Flip-flop | OUT2       | QRUPT      |  |
| 00013     | Flip-flop | OUT3       | (spare)    |  |
| 00014     | Flip-flop | OUT4       | (spare)    |  |
| 00015     | Flip-flop | BANK       | ZRUPT      |  |
| 00016     | Flip-flop | RELINT     | BBRUPT     | No bits in Block I register. |
| 00017     | Flip-flop | INHINT     | BRUPT      | No bits in Block I register. |
| 00020     | Erasable  | CYR        | CYR        |  |
| 00021     | Erasable  | SR         | SR         |  |
| 00022     | Erasable  | CYL        | CYL        |  |
| 00023     | Erasable  | SL         | EDOP       |  |
| 00024     | Erasable  | ZRUPT      | Counter    | Supposed to be 20 counters, yet Memo#9 p4 lists range as 024-057 which is 33D? E-2052 lists 024-060 which is 34D. |
| 00025     | Erasable  | BRUPT      | Counter    |  |
| 00026     | Erasable  | ARUPT      | Counter    |  |
| 00027     | Erasable  | QRUPT      | Counter    |  |
| 00030     | Erasable  | Counter    | Counter    | Supposed to be 20 counters, yet R-393 p3-2 lists range as 030-056 which is 22D? |
|   to      |           |            |            |  |
| 00056     | Erasable  | Counter    | Counter    |  |
| 00057     | Erasable  | Erasable   | Counter    |  |
| 00060     | Erasable  | Erasable   | Erasable?  | Counter in Block II? |
| 00061     | Erasable  | Erasable   | Erasable   |  |

  * Counter registers (according to John Pultorak):
    * Block 1: begin either at address 30 or 34 octal (with document R-393 being ambiguous about this).

| **Address** | **Name**   | **Comment** || (Source: R-393)|
|:------------|:-----------|:------------|
| 00034     | OVCTR    |  |
| 00035     | TIME 1   |  |
| 00036     | TIME 2   |  |
| 00037     | TIME 3   |  |
| 00040     | TIME 4   |  |
| 00041     | UPLINK   |  |
| 00042     | OUTCR I  |  |
| 00043     | OUTCR II |  |
| 00044     | PIPA X   |  |
| 00045     | PIPA Y   |  |
| 00046     | PIPA Z   |  |
| 00047     | CDU X    |  |
| 00050     | CDU Y    |  |
| 00051     | CDU Z    |  |
| 00052     | OPT X    |  |
| 00053     | OPT Y    |  |
| 00054     | TRKR X   |  |
| 00055     | TRKR Y   |  |
| 00056     | TRKR R   |  |

  * Block 2: begin at address 24 (octal).

| **Address** | **Name**   | **Comment** || (Source: E-2052)|
|:------------|:-----------|:------------|
| 00024     | TIME 2   | Elapsed time. |
| 00025     | TIME 1   | Elapsed time. |
| 00026     | TIME 3   | Wait-list. |
| 00027     | TIME 4   | T4RUPT. |
| 00030     | TIME 5   | Digital Auto Pilot. |
| 00031     | TIME 6   | Fine time for clocking. |
| 00032     | CDU X    | Inner gimbal. |
| 00033     | CDU Y    | Middle gimbal. |
| 00034     | CDU Z    | Outer gimbal. |
| 00035     | OPT Y    | Optics shaft (or radar). |
| 00036     | OPT X    | Optics shaft (or radar). |
| 00037     | PIPA X   | X stable member, change in velocity. |
| 00040     | PIPA Y   | Y stable member, change in velocity. |
| 00041     | PIPA Z   | Z stable member, change in velocity. |
| 00042     | RHCP     | Spare in CSM. LM rotational hand controller pitch input. |
| 00043     | RHCY     | Spare in CSM. LM rotational hand controller yaw input. |
| 00044     | RHCR     | Spare in CSM. LM rotational hand controller roll input. |
| 00045     | INLINK   | Uplink (up-telemetry). |
| 00046     | RNRAD    | Rendezvous & landing radar data. Parallel to serial conversion. |
| 00047     | Gyro CTR | Outcounter for Gyros. Drift Compensation and Fine Align. |
| 00050     | CDUXCMD  | Outcounter for CDUs. Used for changing the DAC Error Counter in CDU. |
| 00051     | CDUYCMD  | Outcounter for CDUs. Used for changing the DAC Error Counter in CDU. |
| 00052     | CDUZCMD  | Outcounter for CDUs. Used for changing the DAC Error Counter in CDU. |
| 00053     | OPTYCMD  | Outcounter for Optics (or Radar). |
| 00054     | OPTXCMD  | Outcounter for Optics (or Radar). |
| 00055     | Spare Outlink | Parallel to serial LEM and CSM telemetry. |
| 00056     | Spare Outlink | Parallel to serial LEM and CSM telemetry. |
| 00057     | Spare Outlink | Parallel to serial LEM and CSM telemetry. |
| 00060     | (ALTM)   | Altitude meter, drives inertial data display for altitude on LEM. |

## I/O Differences ##

(Block I used registers for I/O while Block II used channels; this should be described here.)


## Other Memory-Map Differences ##

  * TIME1 and TIME2 variables (according to John Pultorak):
    * Block 1:  TIME1 is at the lower address.
    * Block 2:  TIME1 is at the higher address.

  * Program start and interrupt-vector table (according to John Pultorak):
    * Block 1:  Program start is address 2000 and remainder of interrupt vectors begin at 2004.
    * Block 2:  Program start (GOPROG) is at address 4000 and the remainder of the interrupt vectors begin at 4004.


## Uplink/Downlink Protocol Differences ##

(If any.)


## AGC/DSKY Interface Differences ##

(If any.)


## DSKY Appearance ##

Please refer instead to the [Virtual AGC website](http://www.ibiblio.org/apollo/yaDSKY.html).