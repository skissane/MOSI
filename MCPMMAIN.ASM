	title 'MOSI CP/M: MAIN MODULE'

	name	'main'

;;;	MOSI Interface for CP/M 2.2

;;	MAIN CONTROL MODULE

;	Last Edit: Oct. 1, 1984
;
;	Copyright (C) 1984 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506
;
;
;	   Assemble with Digital Research RMAC
;	      or compatible assembler
;
;	This is a test implementation of the proposed IEEE
;	Microprocessor Operating System Interface standard
;	(MOSI), task P855, draft 6.2.  It implements "Simple
;	Development Support" for CP/M 2.2.
;
;	Function arguments are specified through a parameter
;	block which must be of sufficient size to hold all input
;	and output arguments.  Arguments are entered in the
;	parameter block in the order given in the standard, input
;	arguments followed by output arguments.	the error block
;	is handled separately.
;
;	Data values are entered into the parameter block directly,
;	except for strings.  items of type SYSTEMTAG, PROCESSTAG,
;	STORAGEID, and INTEGER occupy 2 bytes.  Items of type FLAG
;	occupy one byte.  Items of type LONG INTEGER occupy 4
;	bytes.  Items of type STRING use 2 bytes for a POINTER to
;	the string, which consists of a single byte specifying its
;	length (max 255) followed by that many bytes of data.  Note
;	that in the case of string type returned items, the string
;	must be copied to a user area prior to the next MOSI
;	function call.
;
;	The following conditions apply to each function:
;
;	Entry:
;		HL - Address of Parameter Block
;
;	Exit:
;		HL - Address of Error Block
;		SP - restored to original value
;		Other Registers Indeterminate

	page

;    Exported procedure names

	public	@cpinf		;function initialization
	public	@cpexf		;function exit
	public	@cperr		;error return

	public	@cpcopy		;copy a block
	public	@cpsb16		;16 bit subtract
	public	@cpcm16		;16 bit compare

	public	@cppba		;parameter block pointer

;    Symbol Definitions

STACKLEN equ	128		;size of local stack in bytes

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CP/M macros

	page

;
;	@CPINF: Initialize all functions
;
@cpinf:
	sta	class	;save class code
	shld	@cppba	;save parameter block addr
	pop	b	;save @cpinf return addr

;    Setup local stack
	lxi	h,0
	dad	sp
	shld	oldsp	;save old stack pointer
	lxi	sp,stack+STACKLEN
	push	b	;restore return addr

;    Clear error block
	lxi	h,0
	shld	errblk
	shld	errblk+2
	shld	errblk+4
	shld	errblk+6
	ret

;
;	@CPERR: return if error occurs
;
@cperr:
	sta	errblk+2	;reason code to error block
	lda	class
	sta	errblk		;class code to error block

;
;	@CPEXF: return when function complete
;
@cpexf:
	lhld	oldsp		;restore old stack pointer
	sphl
	lxi	h,errblk	;point HL to error block
	ret

	page

;;;	UTILITY SUBROUTINES

;	@CPCOPY - Copy a block of memory
;
;	Entry:
;		DE - address of source block
;		HL - address of destination block
;		A - number of bytes

@cpcopy:
	mov	b,a
copylp:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	b
	jnz	copylp
	ret

;   Include subroutines for general macros
	gmacsubs


	page

;;;	DATA SEGMENT
	dseg


;	UNINITIALIZED DATA

@cppba:	ds	2	;parameter block address
oldsp:	ds	2	;saved stack ptr
class:	ds	2	;class code for errors


;  Error Block
errblk:	ds	2	;class code
	ds	2	;reason code
	ds	4	;system info (not used)


;  Local stack
stack:	ds	STACKLEN


	end
