	title 'MOSI-CP/M Pascal MT+: Memory Management'

	name	'pmmgt'

;;;	MOSI Interface: Pascal MT+ to CPM 2.2

;;	MEMORY MANAGEMENT

;	Last Edit: Feb. 15, 1985
;
;	Copyright 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506

;	Assemble with Digital Research RMAC
;	 or compatible assembler


	maclib	mcpmmacs	;include MOSI-CPM macros

	page 

;;;	Public Entry Point Declarations
;	   and External Declarations

;    Arithmetic routines
	extrn	@cpcm16		;16-bit compare
	extrn	@oscomm		;common entry point
	extrn	@osdcom		;common entry, special routines

;    Memory Management
	public	@new		;NEW routine; calls ALLOCATE
	extrn	cpalloc
	public	@dsp		;DISPOSE routine; calls FREE
	extrn	cpfree
	public	osgtalu		;GET_ALLOCATION_UNIT
	extrn	cpgtalu
	public	osgtamt		;GET_AMOUNT_REMAINING
	extrn	cpgtamt

	page

;;;	Entry to standard routines

@new:	lxi	h,tballoc	;called by new
	jmp	@osdcom		;calls allocate

@dsp:	lxi	h,tbfree	;called by dispose
	jmp	@osdcom		;calls free

osgtalu: lxi	h,tbgtalu	;get_allocation_unit
	jmp	@oscomm

osgtamt: lxi	h,tbgtamt	;get_amount_remaining
	jmp	@oscomm

	page

;;;	Argument Descriptor Tables


;	Each table has the following format:

;	1. Total stack frame size in bytes,
;	     including return addresses		(1 byte)
;	2. Descriptor for each INPUT parameter,
;	   if any:			(3 or 5 bytes each)
;
;	    a.	Type code (1 byte)
;	    b.	Starting offset in CP/M argument
;		  block (1 byte)
;	    c.	Starting offset in MT+ stack frame, not
;		  counting error block.  Bit 7 is set if
;		  the stack contains the address of the
;		  argument.  If there is a further offset
;		  from this address, bit 6 is also set and
;		  the optional argument (d) is included.( 1 byte)
;	    d.  Secondary offset, if any.	(2 bytes)
;
;	3. Input terminator, 1 byte of zero	(1 byte)
;
;	4. MOSI procedure address		(2 bytes)
;
;	5. Descriptor for each OUTPUT parameter,
;	   not counting error block, if any,
;	   same format as input descriptors  (3 or 5 bytes each)
;
;	6. Output terminator, 1 byte of zero	(1 byte)
;

TYPB	equ	2	;boolean type code
TYPI	equ	4	;integer (or equivalent) type code
TYPL	equ	6	;long integer type code
TYPS	equ	8	;string type code

BYVAL	equ	00000000b	;argument passed by value
BYLOC	equ	10000000b	;argument passed by location
BYOFFL	equ	11000000b	;argument passed by loc + offset

	page

;	@new (allocate)
tballoc: db	10
	db	TYPI,0,0+BYVAL	;size
	db	0
	dw	cpalloc
	db	TYPI,4,2+BYLOC	;location
	db	0

;	@dsp (free)
tbfree: db	10
	db	TYPI,0,2+BYVAL	;location
	db	0
	dw	cpfree
	db	0

;	get_allocation_unit
tbgtalu: db	8
	db	0
	dw	cpgtalu
	db	TYPI,0,0+BYLOC	;unit_size
	db	0

;	get_amount_remaining
tbgtamt: db	10
	db	0
	dw	cpgtamt
	db	TYPL,0,2+BYLOC	;total
	db	TYPL,4,0+BYLOC	;largest
	db	0

	end
