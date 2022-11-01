	title 'MOSI-CP/M Pascal MT+: Synchronous File I/O'

	name	'psfio'

;;;	MOSI Interface: Pascal MT+ to CPM 2.2

;;	SYNCHRONOUS FILE I/O

;	Last Edit: June 6, 1985
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

;    External Declarations
	extrn	@cpcm16		;16-bit compare
	extrn	@oscomm		;common entry point
	extrn	@osread		;READ suppl. routine
	extrn	@osrdln		;READ LINE suppl. rtne.
	extrn	@oswrit		;WRITE suppl. routine
	extrn	@oswrln		;WRITE LINE suppl. rtne.
	extrn	@osopen		;OPEN suppl. rtne.
	extrn	@oscpxf		;CP/M interface transfer address

;    Data Transfer
	public	osconn		;CONNECT
	extrn	cpconn
	public	osdconn		;DISCONNECT
	extrn	cpdconn
	public	oscreat		;CREATE
	extrn	cpcreat
	public	osexten		;EXTEND
	extrn	cpexten
	public	ostrunc		;TRUNCATE
	extrn	cptrunc
	public	osopen		;OPEN
	extrn	cpopen
	public	osclose		;CLOSE
	extrn	cpclose
	public	osread		;READ
	public	osrdlin
	extrn	cpread
	public	oswrite		;WRITE
	public	oswrlin
	extrn	cpwrite
	public	osseek		;SEEK
	extrn	cpseek
	public	osgfinf		;GET_FILE_INFORMATION
	extrn	cpgfinf
	public	osgtacc		;GET_ACCESS_CONTROL
	extrn	cpgtacc
	public	oschacc		;CHANGE_ACCESS_CONTROL
	extrn	cpchacc
	public	osdelet		;DELETE
	extrn	cpdelet
	public	osrenam		;RENAME
	extrn	cprenam
	public	osgtwkd		;GET_WORKING_DIRECTORY
	extrn	cpgtwkd
	public	oschwkd		;CHANGE_WORKING_DIRECTORY
	extrn	cpchwkd
	public	osgtidn		;GET_IDENTITY
	extrn	cpgtidn

	page

;;;	Entry to standard routines


osconn:	lxi	h,tbconn	;connect
	jmp	@oscomm

osdconn: lxi	h,tbdconn	;disconnect
	jmp	@oscomm

oscreat: lxi	h,tbcreat	;create
	jmp	@oscomm

osexten: lxi	h,tbexten	;extend
	jmp	@oscomm

ostrunc: lxi	h,tbtrunc	;truncate
	jmp	@oscomm

osopen:	lxi	h,tbopen	;open
	jmp	@oscomm

osclose: lxi	h,tbclose	;close
	jmp	@oscomm

osread:	lxi	h,tbread	;read
	jmp	@oscomm

osrdlin: lxi	h,tbrdlin	;read line
	jmp	@oscomm

oswrite: lxi	h,tbwrite	;write
	jmp	@oscomm

oswrlin: lxi	h,tbwrlin	;write line
	jmp	@oscomm

osseek:	lxi	h,tbseek	;seek
	jmp	@oscomm

osgfinf: lxi	h,tbgfinf	;get_file_information
	jmp	@oscomm

osgtacc: lxi	h,tbgtacc	;get_access_control
	jmp	@oscomm

oschacc: lxi	h,tbchacc	;change_access_control
	jmp	@oscomm

osdelet: lxi	h,tbdelet	;delete
	jmp	@oscomm

osrenam: lxi	h,tbrenam	;rename
	jmp	@oscomm

osgtwkd: lxi	h,tbgtwkd	;get_working_directory
	jmp	@oscomm

oschwkd: lxi	h,tbchwkd	;change_working_directory
	jmp	@oscomm

osgtidn: lxi	h,tbgtidn	;get_identity
	jmp	@oscomm

	page

;;	TRANSFERS TO SUPPLEMENTAL ROUTINES

read:
	getwi	cpread
	putw	@oscpxf
	jmp	@osread

rdlin:
	getwi	cpread
	putw	@oscpxf
	jmp	@osrdln

write:
	getwi	cpwrite
	putw	@oscpxf
	jmp	@oswrit

wrlin:
	getwi	cpwrite
	putw	@oscpxf
	jmp	@oswrln

open:
	getwi	cpopen
	putw	@oscpxf
	jmp	@osopen

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

;	SYNCHRONOUS FILE I/O

;	connect
tbconn:	db	10
	db	TYPS,0,2+BYLOC	;file_name
	db	0
	dw	cpconn
	db	TYPI,2,0+BYLOC	;connect_id
	db	0

;	disconnect
tbdconn: db	8
	db	TYPI,0,0+BYVAL	;connect_id
	db	0
	dw	cpdconn
	db	0

;	create
tbcreat: db	20
	db	TYPS,0,12+BYLOC	;file_name
	db	TYPI,2,10+BYVAL	;file_org
	db	TYPI,4,8+BYVAL	;record_org
	db	TYPI,6,6+BYVAL	;record_size
	db	TYPB,8,4+BYVAL	;text_file
	db	TYPI,9,2+BYVAL	;initial_size
	db	0
	dw	cpcreat
	db	TYPI,11,0+BYLOC	;connect_id
	db	0

;	extend
tbexten: db	10
	db	TYPI,0,2+BYVAL	;connect_id
	db	TYPI,2,0+BYVAL	;extend_length
	db	0
	dw	cpexten
	db	0

;	truncate
tbtrunc: db	8
	db	TYPI,0,0+BYVAL	;connect_id
	db	0
	dw	cptrunc
	db	0

	page

;	open
tbopen: db	20
	db	TYPI,0,12+BYVAL	;connect_id
	db	TYPI,2,10+BYVAL	;access_permission
	db	TYPI,4,8+BYVAL	;access_method
	db	TYPI,6,6+BYVAL	;expected_record_size
	db	TYPB,8,4+BYVAL	;text_file
	db	0
	dw	open
	db	TYPI,9,2+BYLOC	;record_size
	db	TYPI,11,0+BYLOC	;efficient_size
	db	0

;	close
tbclose: db	8
	db	TYPI,0,0+BYVAL	;connect_id
	db	0
	dw	cpclose
	db	0

;	read
tbread:	db	12
	db	TYPI,0,4+BYVAL	;connect_id
	db	TYPI,2,2+BYVAL	;data (address)
	db	0
	dw	read
	db	TYPI,6,0+BYLOC	;amount
	db	0

;	read line
tbrdlin: db	12
	db	TYPI,0,4+BYVAL	;connect_id
	db	TYPI,2,2+BYVAL	;data (address)
	db	0
	dw	rdlin
	db	TYPI,6,0+BYLOC	;amount
	db	0

	page

;	write
tbwrite: db	12
	db	TYPI,0,4+BYVAL	;connect_id
	db	TYPI,2,2+BYVAL	;data (address)
	db	0
	dw	write
	db	TYPI,6,0+BYLOC	;amount
	db	0

;	write line
tbwrlin: db	12
	db	TYPI,0,4+BYVAL	;connect_id
	db	TYPI,2,2+BYVAL	;data (address)
	db	0
	dw	wrlin
	db	TYPI,6,0+BYLOC	;amount
	db	0

;	seek
tbseek:	db	16
	db	TYPI,0,8+BYVAL	;connect_id
	db	TYPI,2,6+BYVAL	;seek_origin
	db	TYPB,4,4+BYVAL	;seek_forward
	db	TYPL,5,2+BYLOC	;seek_record
	db	0
	dw	cpseek
	db	TYPL,9,0+BYLOC	;current_position
	db	0

	page

;	get_file_information
tbgfinf: db	10
	db	TYPI,0,2+BYVAL	;connect_id
	db	0
	dw	cpgfinf
	db	TYPS,2,0+BYOFFL	;file_name
	dw	0
	db	TYPB,4,0+BYOFFL	;open flag
	dw	260
	db	TYPB,5,0+BYOFFL	;temporary_file flag
	dw	261
	db	TYPB,6,0+BYOFFL	;text_file flag
	dw	262
	db	TYPI,7,0+BYOFFL	;record_size
	dw	263
	db	TYPI,9,0+BYOFFL	;record_organization
	dw	265
	db	TYPL,11,0+BYOFFL ;file_length
	dw	267
	db	TYPL,15,0+BYOFFL ;current_position
	dw	271
	db	TYPI,19,0+BYOFFL ;efficient_size
	dw	275
	db	TYPI,21,0+BYOFFL ;access_permission
	dw	277
	db	TYPI,23,0+BYOFFL ;access_method
	dw	279
	db	TYPI,25,0+BYOFFL ;file_organization
	dw	281
	db	TYPL,27,0+BYOFFL ;create_time
	dw	283
	db	TYPI,31,0+BYOFFL ;create_date
	dw	287
	db	TYPL,33,0+BYOFFL ;last_modified_time
	dw	289
	db	TYPI,37,0+BYOFFL ;last_modified_date
	dw	293
	db	TYPL,39,0+BYOFFL ;last_access_time
	dw	295
	db	TYPI,43,0+BYOFFL ;last_access_date
	dw	299
	db	0

	page

;	get_access_control
tbgtacc: db	12
	db	TYPI,0,4+BYVAL	;connect_id
	db	TYPI,2,2+BYVAL	;identity
	db	0
	dw	cpgtacc
	db	TYPI,4,0+BYLOC	;access_control
	db	0

;	change_access_control
tbchacc: db	12
	db	TYPI,0,4+BYVAL	;connect_id
	db	TYPI,2,2+BYVAL	;identity
	db	TYPI,4,0+BYVAL	;access_control
	db	0
	dw	cpchacc
	db	0

;	delete
tbdelet: db	8
	db	TYPI,0,0+BYVAL	;connect_id
	db	0
	dw	cpdelet
	db	0

;	rename
tbrenam: db	10
	db	TYPI,0,2+BYVAL	;connect_id
	db	TYPS,2,0+BYLOC	;new_name
	db	0
	dw	cprenam
	db	0

	page

;	get_working_directory
tbgtwkd: db	8
	db	0
	dw	cpgtwkd
	db	TYPS,0,0+BYLOC	;directory_name
	db	0

;	change_working_directory
tbchwkd: db	8
	db	TYPS,0,0+BYLOC	;directory_name
	db	0
	dw	cpchwkd
	db	0

;	get_identity
tbgtidn: db	10
	db	TYPI,0,2+BYVAL	;identity_code
	db	0
	dw	cpgtidn
	db	TYPI,2,0+BYLOC	;identity
	db	0

	end
