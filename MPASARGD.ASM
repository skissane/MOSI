	title 'MOSI-CP/M Pascal MT+: Direct Argument Acquisition'

	name	'pargd'

;;;	MOSI Interface: Pascal MT+ to CPM 2.2

;;	DIRECT ARGUMENT ACQUISITION

;	Last Edit: Feb. 14, 1985
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

;    External entry points
	extrn	@oscomm		;common entry point

;    Direct Argument acquisition
	public	osgtcnt		;GET_ARGUMENT_COUNT
	extrn	cpgtcnt
	public	osgtarg		;GET_ARGUMENT
	extrn	cpgtarg

;;;	Entry to standard routines

osgtcnt: lxi	h,tbgtcnt	;get_argument_count
	jmp	@oscomm

osgtarg: lxi	h,tbgtarg	;get_argument
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

;	get_argument_count
tbgtcnt: db	8
	db	0
	dw	cpgtcnt
	db	TYPI,0,0+BYLOC	;argument_count
	db	0

;	get_argument
tbgtarg: db	8
	db	0
	dw	cpgtarg
	db	TYPS,0,0+BYLOC	;next_argument; replaces other
				;parameters in CPM
	db	0

	end
