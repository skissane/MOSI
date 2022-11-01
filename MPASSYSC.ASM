	title 'MOSI-CP/M Pascal MT+: System Characteristics'

	name	'psysc'

;;;	MOSI Interface: Pascal MT+ to CPM 2.2

;;	SYSTEM CHARACTERISTICS

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

;    External entry point
	extrn	@oscomm		;common entry point

;    System Characteristics
	public	osgtsys		;GET_SYSTEM_CHARACTERISTICS
	extrn	cpgtsys


;;;	Entry to standard routines

osgtsys: lxi	h,tbgtsys	;get_system_characteristics
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

;	get_system_characteristics
tbgtsys: db	8
	db	0
	dw	cpgtsys
	db	TYPI,0,0+BYOFFL	;configuration_code
	dw	0
	db	TYPI,2,0+BYOFFL ;MOSI_standard_number
	dw	2
	db	TYPS,4,0+BYOFFL ;version_id
	dw	4
	db	TYPS,6,0+BYOFFL	;system_name
	dw	264
	db	TYPS,8,0+BYOFFL	;system_serial_number
	dw	524
	db	TYPI,10,0+BYOFFL ;gmt_difference
	dw	784
	db	TYPI,12,0+BYOFFL ;bits_byte
	dw	786
	db	TYPI,14,0+BYOFFL ;bits_address_unit
	dw	788
	db	0

	end
