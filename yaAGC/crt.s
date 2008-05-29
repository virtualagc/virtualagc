| Filename:     crt.s
| Purpose:      Demonstration startup code for embedded yaAGC on 
|		Motorola Coldfire MCF5206E processor.  For other
|		processors, it will be similar in concept, but
|		different in detail.
| Mods:         08/18/04 RSB	Wrote.

|****************************************************************
| CPU-type-specific constants.

|----------------------------------------------------------------
| Here are some symbolic constants defining the CPU registers 
| we're going to use.

.equ SYPCR, 0x41	 |System Protection Control Register
.equ SIMR, 3             |System Integration Module Config. Reg.
.equ IMR, 0x36           |Interrupt mask register
.equ IPR, 0x3A           |Interrupt pending register
.equ PPDDR, 0x1C5        |Parallel Port data direction register
.equ PPDAT, 0x1C9        |Parallel Port data register
.equ PAR, 0xCB           |Pin Assignment Register

.equ RSR, 0x40           |Reset status register 

.equ CSAR0, 0x64         |Chip Select Address Register - Bank 0
.equ CSMR0, 0x68         |Chip Select Mask Register -    Bank 0
.equ CSCR0, 0x6E         |Chip Select Control Register - Bank 0

.equ CSAR1, 0x70         |Chip Select Address Register - Bank 1 
.equ CSMR1, 0x74         |Chip Select Mask Register -    Bank 1
.equ CSCR1, 0x7A         |Chip Select Control Register - Bank 1

.equ CSAR2, 0x7C         |Chip Select Address Register - Bank 2
.equ CSMR2, 0x80         |Chip Select Mask Register -    Bank 2
.equ CSCR2, 0x86         |Chip Select Control Register - Bank 2

.equ CSAR3, 0x88         |Chip Select Address Register - Bank 3
.equ CSMR3, 0x8C         |Chip Select Mask Register -    Bank 3
.equ CSCR3, 0x92         |Chip Select Control Register - Bank 3

.equ CSAR4, 0x94         |Chip Select Address Register - Bank 4
.equ CSMR4, 0x98         |Chip Select Mask Register -    Bank 4
.equ CSCR4, 0x9E         |Chip Select Control Register - Bank 4

.equ CSAR5, 0xA0         |Chip Select Address Register - Bank 5
.equ CSMR5, 0xA4         |Chip Select Mask Register -    Bank 5
.equ CSCR5, 0xAA         |Chip Select Control Register - Bank 5

.equ CSAR6, 0xAC         |Chip Select Address Register - Bank 6
.equ CSMR6, 0xB0         |Chip Select Mask Register -    Bank 6
.equ CSCR6, 0xB6         |Chip Select Control Register - Bank 6

.equ CSAR7, 0xB8         |Chip Select Address Register - Bank 7
.equ CSMR7, 0xBC         |Chip Select Mask Register -    Bank 7
.equ CSCR7, 0xC2         |Chip Select Control Register - Bank 7

.equ DMCR, 0xC6          |Default Memory Control Register

.equ ICR1, 0x14		 | Interrupt Control Reg 1 - External IRQ1
.equ ICR2, 0x15		 | Interrupt Control Reg 2 - External IPL2
.equ ICR3, 0x16		 | Interrupt Control Reg 3 - External IPL3
.equ ICR4, 0x17		 | Interrupt Control Reg 4 - External IRQ4
.equ ICR5, 0x18		 | Interrupt Control Reg 5 - External IPL5
.equ ICR6, 0x19		 | Interrupt Control Reg 6 - External IPL6
.equ ICR7, 0x1A		 | Interrupt Control Reg 7 - External IRQ7
.equ ICR8, 0x1B		 | Interrupt Control Reg 8 - SWT
.equ ICR9, 0x1C		 | Interrupt Control Reg 9 - Timer #1
.equ ICR10, 0x1D	 | Interrupt Control Reg 10 - Timer #2
.equ ICR11, 0x1E	 | Interrupt Control Reg 11 - MBUS
.equ ICR12, 0x1F	 | Interrupt Control Reg 12 - UART #1
.equ ICR13, 0x20	 | Interrupt Control Reg 13 - UART #2
.equ ICR14, 0x21	 | Interrupt Control Reg 14 - DMA #0
.equ ICR15, 0x22	 | Interrupt Control Reg 15 - DMA #1

| UART1 registers.  To get UART2, add 0x40.
.equ UMR1, 0x140
.equ UMR2, 0x140
.equ USR, 0x144
.equ UCSR, 0x144
.equ UCR, 0x148
.equ URB, 0x14C
.equ UTB, 0x14C
.equ UIPCR, 0x150
.equ UACR, 0x150
.equ UISR, 0x154
.equ UIMR, 0x154
.equ UBG1, 0x158
.equ UBG2, 0x15C
.equ UIVR, 0x170
.equ UIP, 0x174
.equ UOP1, 0x178
.equ UOP0, 0x17C

| Timer1 registers.  To get timer2, add 0x20.
.equ TMR, 0x100
.equ TRR, 0x104
.equ TCR, 0x108
.equ TCN, 0x10C
.equ TER, 0x111

|------------------------------------------------------------------
| Masks and bitfields for the built-in UARTs.

| Various masks used with UART register UMR1.
.equ	RxRTS_NOTAUTO, 0x00
.equ	RxRTS_AUTO, 0x80
.equ	RxIRQ_RxRDY, 0x00
.equ	RxIRQ_FFULL, 0x40
.equ	ERR_CHAR, 0x00
.equ	ERR_BLOCK, 0x20
.equ	PARITY_EVEN, 0x00
.equ	PARITY_ODD, 0x04
.equ	PARITY_0, 0x08
.equ	PARITY_1, 0x0c
.equ	PARITY_NONE, 0x10
| There is no 0x14, because it would have the same effect as 0x10.
.equ	PARITY_MULTIDROP_DATA, 0x18
.equ	PARITY_MULTIDROP_ADDRESS, 0x1c
.equ	WORDSIZE_5, 0
.equ	WORDSIZE_6, 1
.equ	WORDSIZE_7, 2
.equ	WORDSIZE_8, 3

| Various masks used with UART register UMR2.
.equ	CHAN_NORMAL, 0x00
.equ	CHAN_AUTOECHO, 0x40
.equ	CHAN_LOCALLOOP, 0x80
.equ	CHAN_REMOTELOOP, 0xc0
.equ	TxRTS_NOTAUTO, 0x00
.equ	TxRTS_AUTO, 0x20
.equ	TxCTS_NOTAUTO, 0x00
.equ	TxCTS_AUTO, 0x10
| The lowest 4 bits control the number of stops in some funky way.
| We provide constants for only the most common settings:
.equ	STOPS_1, 7
.equ	STOPS_2, 15

| Various masks used with UART register UCR.
.equ	CMD_NONE, 0
.equ	CMD_RST_MODE, 0x10
.equ	CMD_RST_RECV, 0x20
.equ	CMD_RST_XMIT, 0x30
.equ	CMD_RST_ERR, 0x40
.equ	CMD_RST_BRK, 0x50
.equ	CMD_START_BRK, 0x60
.equ	CMD_STOP_BRK, 0x70
.equ	TC_NONE, 0x00
.equ	TC_ENA, 0x04
.equ	TC_DISA, 0x08
.equ	RC_NONE, 0x00
.equ	RC_ENA, 0x01
.equ	RC_DISA, 0x02

| Masks for use with UART UCSR register.
.equ	RCS_TIMER, 0xd0
.equ	RCS_X16_EXT, 0xe0
.equ	RCS_X1_EXT, 0xf0
.equ	TCS_TIMER, 0x0d
.equ	TCS_X16_EXT, 0x0e
.equ	TCS_X1_EXT, 0x0f

| Masks for use with UART UACR register.
.equ	IEC_NOTAUTO, 0x00
.equ	IEC_AUTO, 0x01

|-------------------------------------------------------------------
| Values for ICR-register fields.

.equ	AVEC,0x80
.equ	NOAVEC,0x00
.equ	LEVEL0,0x00
.equ	LEVEL1,0x04
.equ	LEVEL2,0x08
.equ	LEVEL3,0x0c
.equ	LEVEL4,0x10
.equ	LEVEL5,0x14
.equ	LEVEL6,0x18
.equ	LEVEL7,0x1c
.equ	PRIO0,0x00
.equ	PRIO1,0x01
.equ	PRIO2,0x02
.equ	PRIO3,0x03

|--------------------------------------------------------------------
| Here are some helpful constants that can be used to construct
| easy-to-read values for the CSCR registers below.  
| Just add together the constants you need.

.equ wait, 0x0400
.equ brst, 0x0200
.equ aa, 0x0100
.equ bus32, 0x0000
.equ bus16, 0x00c0 
.equ bus8, 0x0040
.equ emaa, 0x0020
.equ aset, 0x0010
.equ wrah, 0x0008
.equ rdah, 0x0004
.equ wr, 0x0002 
.equ rd, 0x0001

|********************************************************************
| Stuff specific to the fictitious target system.

|*-------------   Values for various registers    ------------------*|

.equ _sypcr, 0x00
.equ _simr, 0xC0   
.equ _imr, 0x3FFE 
.equ _par, 0x20 
.equ _rsr, 0xA0   
.equ _immr, 0x00700000 
.equ _init_ppdat, 0x01

|*-------------      chip select directives      ------------------*|

| Non-volatile memory, at address 0x000000.
.equ _csar0, 0x0000     
.equ _csmr0, 0x001F0000	
.equ _cscr0, rd+wr+rdah+wrah+bus16+aa+(4*wait)

| RAM, at address 0x200000.
.equ _csar1, 0x0020
.equ _csmr1, 0x001F0000	
.equ _cscr1, rd+wr+wrah+bus32+aa
.equ XRAM_START, 0x10000*_csar1

| Peripherals, at address 0x400000.
.equ _csar2, 0x0040     
.equ _csmr2, 0x001F0000	
.equ _cscr2, rd+wr+rdah+wrah+aset+bus32+(1*wait)

| Not used
.equ _csar3, 0xffff     
.equ _csmr3, 0x00000000  
.equ _cscr3, 0x0000

| Not used, since pin is used for WE3.
.equ _csar4, 0xffff     
.equ _csmr4, 0x00000000  
.equ _cscr4, 0x0000

| Not used, since pin is used for WE2.
.equ _csar5, 0xffff     
.equ _csmr5, 0x00000000
.equ _cscr5, 0x0000

| Not used, since pin is used for WE1.
.equ _csar6, 0xffff     
.equ _csmr6, 0x00000000
.equ _cscr6, 0x0000

| Not used, since pin is used for WE0.
.equ _csar7, 0xffff     
.equ _csmr7, 0x00000000
.equ _cscr7, 0x0000

|*-----------------  Miscellaneous stuff -------------------------*|

.equ INTERNAL_RAM, 0xF0000000 
.equ STACK, INTERNAL_RAM+0x2000	

.equ CSPEED, 40000000	 
.equ CLOCK_SPEED, 40000000
.equ INTERRUPTS_PER_SECOND, (1024000/12)

|*******************************************************************
| Code.

|-------------------------------------------------------------------
| Vector table and code.

        .text
        .org	0

| Default vector table. 
.set	UART2_VECTORNUM, 64
.set	UART1_VECTORNUM, 65
VectorTable:   
        .long	STACK,   start,   TrapAces, TrapAddr,TrapInst,TrapMisc,TrapMisc,TrapMisc
        .long	TrapPriv,TrapTrac,TrapLinA, TrapLinF,TrapDebg,TrapMisc,TrapForm,TrapUint
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapSpur,IrqIsr1, TimerIsr1,TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	UartIsr2,UartIsr1,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
        .long	TrapMisc,TrapMisc,TrapMisc, TrapMisc,TrapMisc,TrapMisc,TrapMisc,TrapMisc
		
|-------------------------------------------------------------------------------		
| Come here various bad interrupts, particularly traps.

IrqIsr1:
	nop
	nop
	nop
	nop
	bra	TrapMisc

UartIsr1:
	nop
	nop
	nop
	nop
	bra	TrapMisc

UartIsr2:
	nop
	nop
	nop
	nop
	bra	TrapMisc

TrapMisc:
	nop
	nop
	nop
	nop
	bra	TrapMisc

TrapAces:
	nop
	nop
	nop
	nop
	bra	TrapAces

TrapAddr:
	nop
	nop
	nop
	nop
	bra	TrapAddr

TrapInst:
	nop
	nop
	nop
	nop
	bra	TrapInst

TrapPriv:
	nop
	nop
	nop
	nop
	bra	TrapPriv

TrapTrac:
	nop
	nop
	nop
	nop
	bra	TrapTrac

TrapLinA:
	nop
	nop
	nop
	nop
	bra	TrapLinA

TrapLinF:
	nop
	nop
	nop
	nop
	bra	TrapLinF

TrapDebg:
	nop
	nop
	nop
	nop
	bra	TrapDebg

TrapForm:
	nop
	nop
	nop
	nop
	bra	TrapForm

TrapUint:
	nop
	nop
	nop
	nop
	bra	TrapUint

TrapSpur:
	nop
	nop
	nop
	nop
	bra	TrapSpur

|-------------------------------------------------------------------------------
| Main timer interrupt.
	.extern	agc_engine
TimerIsr1:
	lea	(-60,%a7),%a7		| Allocate stack space for registers.
	movem.l	%d0-%d7/%a0-%a6,(%a7)	| Move all (15) registers onto stack.
|	... needs to push &State here.
	jsr	agc_engine		| Call the (presumably) C ISR.
	moveq	#2,%d0			| Clear the IRQ.
	move.b	%d0,(_immr+TER).l
	movem.l	(%a7),%d0-%d7/%a0-%a6	| Move all registers from stack.
	lea	(60,%a7),%a7		| Deallocate stack space.
	rte				| Return.
	

|----------------------------------------------------------------------------
	.global	start, _start
_start:	
start:
        move.w  #0x2700,%sr    		| set status register
	
| Set internal memory mapped registers address
        move.l  #_immr+1,%d0    	| set up MBAR
        movec.l %d0,%MBAR
        move.l  #_immr,%d0      	| %a0 points to module base addr.
        movea.l %d0,%a0
	
| set up stack pointer.
        move.l  #STACK,%d0
        movea.l %d0,%a7

| Invalidate cache
        move.l  #0x01000000,%d0 	| invalidate cache
        movec.l %d0,%CACR       	

| set access control
        clr.l   %d0
        movec.l %d0,%acr0
        movec.l %d0,%acr1

| Set internal ram address
        move.l  #INTERNAL_RAM+1,%d0	| set up SRAM
        movec.l %d0,%RAMBAR0

        move.b  #0xc0,%d0
        move.b  %d0,(SIMR,%a0)

|--------------------------------------------------------------------------
	
| Initialize all interrupt-control registers. 

| External request or level 1:
        move.b  #(AVEC+LEVEL1+PRIO0),%d0
        move.b  %d0,(ICR1,%a0)
| External level 2:	
        move.b  #(NOAVEC+LEVEL2+PRIO0),%d0
        move.b  %d0,(ICR2,%a0) 
| External level 3:	
        move.b  #(NOAVEC+LEVEL3+PRIO0),%d0
        move.b  %d0,(ICR3,%a0)    
| External request or level 4:	
        move.b  #(AVEC+LEVEL4+PRIO0),%d0
        move.b  %d0,(ICR4,%a0)     
| External level 5:	
        move.b  #(NOAVEC+LEVEL5+PRIO0),%d0
        move.b  %d0,(ICR5,%a0)     
| External level 6:	
        move.b  #(NOAVEC+LEVEL6+PRIO0),%d0
        move.b  %d0,(ICR6,%a0)     
| External request or level 7:	
        move.b  #(AVEC+LEVEL7+PRIO0),%d0
        move.b  %d0,(ICR7,%a0)
| Watchdog timer:  	     
        move.b  #(NOAVEC+LEVEL7+PRIO1),%d0
        move.b  %d0,(ICR8,%a0)     
| Timer 1:
        move.b  #(AVEC+LEVEL2+PRIO1),%d0	
        move.b  %d0,(ICR9,%a0)     
| Timer 2:	
        move.b  #(AVEC+LEVEL3+PRIO1),%d0
        move.b  %d0,(ICR10,%a0)  
| MBUS (I2C):	
        move.b  #(AVEC+LEVEL0+PRIO0),%d0
        move.b  %d0,(ICR11,%a0)    
| UART 1:	
        move.b  #(NOAVEC+LEVEL5+PRIO2),%d0
        move.b  %d0,(ICR12,%a0)
| UART 2:  	
        move.b  #(NOAVEC+LEVEL4+PRIO2),%d0
        move.b  %d0,(ICR13,%a0)   
| DMA ICRs 
        move.b  #(AVEC+LEVEL2+PRIO2),%d0
        move.b  %d0,(ICR14,%a0)   
        move.b  #(AVEC+LEVEL2+PRIO3),%d0
        move.b  %d0,(ICR15,%a0)   

| Intialize 5206 chip select registers

        move.w  #_imr, %d0
        move.w  %d0, (IMR,%a0)      	|interrupt mask register

        clr.b   (PPDDR,%a0)       	|parallel port data direction reg
        clr.b   (PPDAT,%a0)      	|parallel port data register

        move.b  #_rsr, %d0   
        move.b  %d0, (RSR,%a0)

| Initialize 5206 chip select registers
|
|*-------------         Chip Select 1        ------------------*|

        move.w  #_csar1, %d0             
        move.w  %d0, (CSAR1,%a0)
        move.l  #_csmr1, %d0
        move.l  %d0, (CSMR1,%a0)
        move.w  #_cscr1, %d0  
        move.w  %d0, (CSCR1,%a0)

|*-------------         Chip Select 2        ------------------*|

        move.w  #_csar2, %d0           
        move.w  %d0, (CSAR2,%a0)
        move.l  #_csmr2, %d0
        nop
        nop
        move.l  %d0, (CSMR2,%a0)
        move.w  #_cscr2, %d0           
        move.w  %d0, (CSCR2,%a0)

|*-------------         Chip Select 3        ------------------*|

        move.w  #_csar3, %d0           
        move.w  %d0, (CSAR3,%a0)
        move.l  #_csmr3, %d0
        nop
        nop
        move.l  %d0, (CSMR3,%a0)
        move.w  #_cscr3, %d0           
        move.w  %d0, (CSCR3,%a0)

|*-------------         Chip Select 4        ------------------*|

        move.w  #_csar4, %d0           
        move.w  %d0, (CSAR4,%a0)
        move.l  #_csmr4, %d0
        nop
        nop
        move.l  %d0, (CSMR4,%a0)
        move.w  #_cscr4, %d0           
        move.w  %d0, (CSCR4,%a0)

|*-------------         Chip Select 5        ------------------*|

        move.w  #_csar5, %d0           
        move.w  %d0, (CSAR5,%a0)
        move.l  #_csmr5, %d0
        nop
        nop
        move.l  %d0, (CSMR5,%a0)
        move.w  #_cscr5, %d0           
        move.w  %d0, (CSCR5,%a0)

|*-------------         Chip Select 6        ------------------*|

        move.w  #_csar6, %d0           
        move.w  %d0, (CSAR6,%a0)
        move.l  #_csmr6, %d0
        nop
        nop
        move.l  %d0, (CSMR6,%a0)
        move.w  #_cscr6, %d0           
        move.w  %d0, (CSCR6,%a0)
		
|*-------------         Chip Select 7        ------------------*|

        move.w  #_csar7, %d0            
        move.w  %d0, (CSAR7,%a0)
        move.l  #_csmr7, %d0
        nop
        nop
        move.l  %d0, (CSMR7,%a0)
        move.w  #_cscr7, %d0            
        move.w  %d0, (CSCR7,%a0)
	
|*-------------         Chip Select 0        ------------------*|

        move.w  #_csar0, %d0           
        move.w  %d0, (CSAR0,%a0)
        move.w  #_cscr0, %d0           
        move.w  %d0, (CSCR0,%a0)
        move.l  #_csmr0, %d0           
        move.l  %d0, (CSMR0,%a0)

| Turn on cache
        move.l  #0x80000503,%d0  	|CENB, CEIB, DCM (=0), DBWE
        movec.l %d0,%cacr         
        move.l  #0x0000C000,%d0
        movec.l %d0,%acr0

| Miscellaneous stuff.
        movea.l #_immr,%a0
        move.b  #0xff,%d0     		| Set up the parallel port for output
        move.b  %d0,(PPDDR,%a0)
        move.b  #_init_ppdat,%d0   	| Write some data on it.
        move.b  %d0,(PPDAT,%a0)

|-----------------------------------------------------------------------------
| Here is some 4GO initialization, in which we activate the kernel interrupt.

	| Point to the vector table.
	move.l	#VectorTable,%d0
      	movec.l %d0,%VBR
	
| Initialize timer 1.
| Compute the timer-reload and prescale values, given the desired interrupt rate
| and crystal frequency.  The RELOAD value must be in the range of 1..65536.  
| PRESCALAR must be 1..256.  We first calculate the RELOAD value assuming that the
| PRESCALAR is 1, and then recalculate it if RELOAD comes out greater than 0x10000.
| All calculations are rounded to the nearest integer, to achieve the highest
| accuracy.   
.set	PRESCALAR, 1
.set	RELOAD, (CLOCK_SPEED+INTERRUPTS_PER_SECOND/2)/INTERRUPTS_PER_SECOND
| Did RELOAD overflow?
.ifgt	RELOAD-0x10000
.set	PRESCALAR, 1+RELOAD/0x10001
.set	RELOAD, (CLOCK_SPEED+INTERRUPTS_PER_SECOND*PRESCALAR/2)/(INTERRUPTS_PER_SECOND*PRESCALAR)
.endif
| Just in case the calculation above can come out to exactly RELOAD==0x10001 
| with some freakish combination of inputs ...
.ifgt	RELOAD-0x10000
.set	PRESCALAR, 1+PRESCALAR
.set	RELOAD, (CLOCK_SPEED+INTERRUPTS_PER_SECOND*PRESCALAR/2)/(INTERRUPTS_PER_SECOND*PRESCALAR)
.endif
| Check for overflow of PRESCALAR.  Can't ever happen, of course.
.ifgt	PRESCALAR-256
.err	Interrupt rate is too slow for the hardware to achieve.
.endif
| Change PRESCALAR from 1..256 to 0..255, and make it the MSB of a word.
| Similarly, convert RELOAD from 1..65536 to 0..65535.
.set	PRESCALAR, (PRESCALAR-1)<<8
.set	RELOAD, RELOAD-1
| The following should cause the timer to run from the master system clock
| (rather than dividing the master system clock by 16), should cause the 
| timer to reset upon reaching its "reference value", and should cause 
| an interrupt upon doing so.  (It also turns the timer on.)
        movea.l #_immr,%a0
	move.w	#PRESCALAR+0x3b,%d0
	move.w	%d0,(TMR,%a0)
	move.w	#RELOAD,%d0
	move.w	%d0,(TRR,%a0)
	move.b	#0x03,%d0
	move.b	%d0,(TER,%a0)
        movea.l #_immr,%a0
	move.w	(IMR,%a0),%d0
	and.l	#0xfffffdff,%d0
	move.w	%d0,(IMR,%a0)	

|-----------------------------------------------------------------------------
| Unmask interrupts.  
	move.w	#0x2000,%sr

|-----------------------------------------------------------------------------
| All done with initialization now!  Execute the main program.
	.extern	main
	jsr	main			| Run program.
Done:	bra.b	Done			| Shouldn't ever get here.

