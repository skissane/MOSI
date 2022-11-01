	title 'MOSI-CP/M Pascal MT+: I/O Assignments'

	name	'pioas'

;;;	MOSI Interface: Pascal MT+ to CPM 2.2

;;	I/O ASSIGNMENTS

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


;;;	Public Entry Point Declarations
;	   and External Declarations

;    External entry points
	extrn	@oscomm		;common entry point

;    I/O Assignments
	public	osgtioa		;GET_IO_ASSIGNMENTS
	extrn	cpgtioa
	public	oschioa		;CHANGE_IO_ASSIGNMENTS
	extrn	cpchioa

	page

;;;	Entry to standard routines


osgtioa: lxi	h,tbgtioa	;get_io_assignments
	jmp	@oscomm

oschioa: lxi	h,tbchioa	;change_io_assignments
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

;	get_io_assignments
tbgtioa: db	16
	db	TYPI,0,8+BYVAL	;io_code
	db	0
	dw	cpgtioa
	db	TYPI,2,6+BYLOC	;io_status
	db	TYPI,4,4+BYLOC	;io_type
	db	TYPS,6,2+BYLOC	;file_name
	db	TYPI,8,0+BYLOC	;connect_id
	db	0

;	change_io_assignments
tbchioa: db	10
	db	TYPI,0,2+BYVAL	;io_code
	db	TYPS,2,0+BYLOC	;file_name
	db	0
	dw	cpchioa
	db	0

	end
