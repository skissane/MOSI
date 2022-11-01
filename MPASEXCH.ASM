	title 'MOSI-CP/M Pascal MT+: Exception Handling'

	name	'pexch'

;;;	MOSI Interface: Pascal MT+ to CPM 2.2

;;	EXCEPTION HANDLING

;	Last Edit: February 15, 1985
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

;    External Routines
	extrn	@cpcm16		;16-bit compare
	extrn	@oscomm		;common entry point
	extrn	@osdcom		;common entry point, special routines
	extrn	@osraex		;RAISE EXCEPTION suppl. routine
	extrn	@osexth		;EXIT HANDLER suppl. routine
	extrn	@osmter		;MT ERROR suppl. routine
	extrn	@oscpxf		;CP/M interface transfer address
	extrn	@osexch		;appl. exception handler transfer addr.


;    Exception Handling
	public	@err		;error trap
	extrn	osexch		;alternate exception handler
	
	public	osdisex		;DISABLE
	extrn	cpdisex
	public	osenaex		;ENABLE
	extrn	cpenaex
	public	osgtens		;GET_ENABLE_STATUS
	extrn	cpgtens
	public	osgetex		;GET_EXCEPTION_HANDLER
	extrn	cpgetex
	public	ossetex		;SET_EXCEPTION_HANDLER
	extrn	cpsetex
	public	osresdf		;RESET_DEFAULT_HANDLER
	extrn	cpresdf
	public	osraiex		;RAISE_EXCEPTION
	extrn	cpraiex
	public	osgtexc		;GET_EXCEPTION_CODE
	extrn	cpgtexc
	public	osexith		;EXIT_FROM_HANDLER
	extrn	cpexith

	page

;;;	Entry to standard routines

@err:	lxi	h,tbmterr	;invoked by overflow
	jmp	@osdcom		;calls raise_exception

osdisex: lxi	h,tbdisex	;disable
	jmp	@oscomm

osenaex: lxi	h,tbenaex	;enable
	jmp	@oscomm

osgtens: lxi	h,tbgtens	;get_enable_status
	jmp	@oscomm

osgetex: lxi	h,tbgetex	;get_exception_handler
	jmp	@oscomm

ossetex: lxi	h,tbsetex	;set_exception_handler
	jmp	@oscomm

osresdf: lxi	h,tbresdf	;reset_default_handler
	jmp	@oscomm

osraiex: lxi	h,tbraiex	;raise_exception
	jmp	@oscomm

osgtexc: lxi	h,tbgtexc	;get_exception_code
	jmp	@oscomm

osexith: lxi	h,tbexith	;exit_from_handler
	jmp	@oscomm

	page

;;	TRANSFERS TO SUPPLEMENTAL ROUTINES

raiex:
	getwi	cpraiex
	putw	@oscpxf
	getwi	osexch
	putw	@osexch
	jmp	@osraex

mterr:
	getwi	cpraiex
	putw	@oscpxf
	getwi	osexch
	putw	@osexch
	jmp	@osmter

exith:
	getwi	cpexith
	putw	@oscpxf
	jmp	@osexth

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

;	@err (runtime error)
tbmterr: db	10
	db	TYPI,0,2+BYVAL	;status
	db	TYPI,1,0+BYVAL	;error number
	db	0
	dw	mterr
	db	0

;	disable
tbdisex: db	8
	db	TYPI,0,0+BYVAL	;exception_class
	db	0
	dw	cpdisex
	db	0

;	enable
tbenaex: db	8
	db	TYPI,0,0+BYVAL	;exception_class
	db	0
	dw	cpenaex
	db	0

;	get_enable_status
tbgtens: db	10
	db	TYPI,0,2+BYVAL	;exception_class
	db	0
	dw	cpgtens
	db	TYPB,2,0+BYLOC	;status
	db	0

;	get_exception_handler
tbgetex: db	8
	db	0
	dw	cpgetex
	db	TYPI,0,0+BYLOC	;handler code
	db	0		;handler id processed locally

;	set_exception_handler
tbsetex: db	8
	db	TYPI,0,0+BYVAL	;handler code
	db	0
	dw	cpsetex
	db	0

;	reset_default_handler
tbresdf: db	6
	db	0
	dw	cpresdf
	db	0

;	raise_exception
tbraiex: db	10
	db	TYPI,0,2+BYVAL	;exception_class
	db	TYPI,2,0+BYVAL	;sub_class
	db	0
	dw	raiex
	db	0

;	get_exception_code
tbgtexc: db	10
	db	0
	dw	cpgtexc
	db	TYPI,0,2+BYLOC	;class_code
	db	TYPI,2,0+BYLOC	;sub_class

;	exit_from_handler
tbexith: db	8
	db	TYPI,0,0+BYVAL	;disposition
	db	0
	dw	exith
	db	0

	end
