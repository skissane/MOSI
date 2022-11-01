	title 'MOSI/CPM Pascal MT+: Main Module'

	name	'pmain'

;;;	MOSI Interface: Pascal MT+ to CPM 2.2

;;	MAIN MODULE

;	Last Edit: May 22, 1985
;
;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506

;	Assemble with Digital Research RMAC
;	 or compatible assembler

;	This is a test implementation of the Pascal Language
;	Interface for the proposed IEEE Microprocessor
;	Operating System Interface Standard (MOSI), task P855,
;	the pending trial use standard.

;	This program provides library procedures for
;	Pascal MT+, using the Experimental MOSI CP/M 2.2
;	interface.  The	procedures included are those defined
;	in the draft standard, Appendix	D, which are also
;	included in "Simple Development Support" as defined
;	in section 11.2.2.  In addition, procedures @NEW and
;	@DSP are defined, which preempt the MT+ routines
;	for heap management and instead invoke MOSI functions.
;	Also, procedure @ERR is implemented to trap certain
;	run-time exceptions for MOSI exception handling.
;	Finally, the procedure OsGtErr is implemented in this
;	module.

;	All procedures are accessed as external procedures by
;	the Pascal program, and are defined as specified in
;	Appendix D.

;;	Symbol definitions (must match CP/M modules)

MAXFCB	equ	8	;maximum no. of FCB's
ACMTSTRM equ	1	;stream access method code

	maclib	mcpmmacs	;include MOSI-CPM macros

	page 

;;;	Public Entry Point Declarations
;	   and External Declarations

;    Arithmetic routines
	extrn	@cpcm16		;16-bit compare

;    Heap area limits
	extrn	sysmem		;contains first loc in heap
	extrn	@sfp		;contains last loc in heap

;    Entry points for Pascal interface routines
	public	@oscomm		;normal entry with error code
	public	@osdcom		;direct entry without error code
	public	@oscpxf		;CP/M routine transfer point
	public	@osexch		;appl. exception handler addr.
	public	@osread		;READ supplemental routine
	public	@osrdln		;READ LINE suppl. rtne.
	public	@oswrit		;WRITE suppl. rtne.
	public	@oswrln		;WRITE LINE suppl. rtne.
	public	@osopen		;OPEN suppl. rtne.
	public	@osraex		;RAISE EXCEPTION suppl. rtne.
	public	@osexth		;EXIT FROM HANDLER suppl. rtne.
	public	@osmter		;MT+ error process

;    Error Code Access
	public	osgterr		;GET_ERROR

;    Process Management
	public	osintpg		;INITIALIZE_PROGRAM
	extrn	cpintpg
	public	ostrmpg		;TERMINATE_PROGRAM
	extrn	cptrmpg


	page

;;;	Entry to standard routines


osintpg: lxi	h,tbintpg	;initialize_program
	jmp	@oscomm

ostrmpg: lxi	h,tbtrmpg	;terminate_program
	jmp	@oscomm

osgterr: lxi	h,tbgterr	;get error
	jmp	@oscomm

;
;	Standard Function Processing
;	used by most routines
;
;   Entry for internal MT routines
;   Load local error block on stack
;
@osdcom:
	pop	d
	lxi	b,errblk
	push	b
	push	d

;    Entry for explicit routines
;
@oscomm:
	call	adjstk	;adjust the stack
	call	inproc	;process input parameters
	call	callcpm	;call CP/M 2.2 interface
	call	outproc	;process output parameters
	ret		;return to Pascal MT+ program

	page

;;	SPECIAL PROCESSING ROUTINES

;  The following sections contain all of the special processing
;  routines for functions which cannot be mapped directly from
;  Pascal to CP/M with the standard methods.  Although some of
;  these logically should be in other modules of the Pascal interface,
;  they are included here because they directly reference offsets
;  in the CP/M parameter block, and this is not permitted by LINKMT
;  if the parameter block is external.
;
;  To allow these routines to be separated from the external declarations
;  for the CP/M modules, the latter invoked indirectly through the
;  CPSUBR routine, below.  The variable @oscpxf must first be loaded
;  from the other modules with the address of the CP/M routine.
;  Also, for RAISE EXCEPTION, the variable @osexch must be loaded with
;  the address of the application exception handler.
;
;
;	CPSUBR: Invoke a CP/M subroutine

cpsubr:
	getw	@oscpxf	;get CP/M transfer address
	push	h	;put it on the stack
	getwi	cpparm	;get parameter block addr to HL
	ret		;transfer to the CP/M routine

	page

;	READ

@osread:
	; find transfer length from case variant
	getwx	cpparm+2
	xchg
	lxi	h,udlentb-1
	dad	d
	mov	a,m
	sta	cpparm+4	;save in param blk
	xra	a
	sta	cpparm+5
	getw	cpparm+2	;skip data ptr ahead
	inx	h
	inx	h
	putw	cpparm+2

	; get connect id, check access method
	getw	cpparm
	xchg
	lxi	h,acmeth-2
	dad	d
	dad	d
	mov	a,m
	cpi	ACMTSTRM
	jz	readx	;continue if stream

	; access method is by record
	;  record size must match length
	lxi	h,recsiz-2
	dad	d
	dad	d
	getwx
	cmpw	cpparm+4
	jnz	readerr	;they don't match
	getwi	1
	putw	cpparm+4

	; all ok - proceed
readx:
	call	cpsubr
	ret

	; bad record size - error
readerr:
	getwi	0
	putw	cpparm+6	;set amount to 0
	getwi	3
	putw	errblk		;set error to access denied
	getwi	5
	putw	errblk+2
	lxi	h,errblk	;skip call, return error
	ret

;	READ LINE

@osrdln:
	;set transfer length and data addr
	getwi	0	;zero for var. length
	putw	cpparm+4
	getw	cpparm+2	;skip string header
	addwi	4
	putw	cpparm+2

	;check that record size is zero
	getw	cpparm
	xchg
	lxi	h,recsiz-2
	dad	d
	dad	d
	getwx
	cmpwi	0
	jnz	readerr	;not var. length

	; all ok - call read function
	call	cpsubr

	; set count in string
	push	h
	getw	cpparm+6
	putwx	cpparm+2,-2
	pop	h
	ret

	page

;	WRITE

@oswrit:
	; set transfer length from case variant
	getwx	cpparm+2
	xchg
	lxi	h,udlentb-1
	dad	d
	mov	a,m
	sta	cpparm+4	;save in param blk
	xra	a
	sta	cpparm+5
	getw	cpparm+2	;skip length in data
	inx	h
	inx	h
	putw	cpparm+2

	; get connect id, check access method
	getw	cpparm
	xchg
	lxi	h,acmeth-2
	dad	d
	dad	d
	mov	a,m
	cpi	2
	jc	writx	;continue if stream

	; access method is by record
	;  record size must match length
	lxi	h,recsiz-2
	dad	d
	dad	d
	getwx
	cmpw	cpparm+4
	jnz	writerr	;they don't match
	getwi	1
	putw	cpparm+4

	; all ok - proceed
writx:
	call	cpsubr
	ret

	; bad record size - error
writerr:
	getwi	0
	putw	cpparm+6	;set amount to 0
	getwi	3
	putw	errblk		;set error to access denied
	getwi	5
	putw	errblk+2
	lxi	h,errblk	;skip call, return error
	ret

;	WRITE LINE

@oswrln:
	; set transfer count and data pointer
	getwx	cpparm+2,2	;get count from string
	putw	cpparm+4
	getw	cpparm+2	;skip string header
	addwi	4
	putw	cpparm+2

	; check for zero record size
	getw	cpparm
	xchg
	lxi	h,recsiz-2
	dad	d
	dad	d
	getwx
	cmpwi	0
	jnz	writerr	;not var. length

	; all ok - call write function
	call	cpsubr
	ret

	page


;	OPEN
;
;	   Save access method, record size
;
@osopen:
	; call open function
	call	cpsubr
	push	h	;save error block pointer

	; save access method in table
	getw	cpparm	;get connect id
	xchg
	lxi	h,acmeth-2
	dad	d
	dad	d
	lda	cpparm+4	;copy access method
	mov	m,a
	inx	h
	lda	cpparm+5
	mov	m,a

	; save record size in table
	lxi	h,recsiz-2
	dad	d
	dad	d
	lda	cpparm+9	;copy record size
	mov	m,a
	inx	h
	lda	cpparm+10
	mov	m,a
	pop	h	;restore error block pointer
	ret


;    Table of data lengths
udlentb: db	1	;case 1 (8 bit integer)
	db	2	;case 2 (16 bit integer)
	db	2	;case 3 (integer: 16 bits in MT+)
	db	8	;case 4 (real: 64 bits in MT+)
	db	1	;case 5 (character: 8 bits in MT+)
	db	1	;case 6 (boolean: 8 bits in MT+)

	page

;	INITIALIZE_PROGRAM
intpg:
	lhld	sysmem	;addr of start of heap
	shld	cpparm
	lhld	@sfp	;addr of end of heap
	shld	cpparm+2
	lxi	h,cpparm
	call	cpintpg
	ret

;	GET ERROR

gterr:
	lxi	h,errblk ;point to saved error block
	ret

	page

;	@OSRAEX - Raise exception
;
;	If handler code is nonzero, adjusts stack so that
;	on return from osraiex, a "call" to osexch will be
;	inserted, with the handler code on the stack as
;	the single parameter.

@osraex:
	call	cpsubr	;call CPM routine
	putw	etemp	;save error block addr
	getw	cpparm+4	;test handler addr
	cmpwi	0
	jz	raiexx	;skip if zero

	; insert handler code & addr on stack
	pop	h	;save top three entries
	putw	rtemp
	pop	b
	pop	d
	getw	cpparm+4	;push handler code as argument
	push	h
	push	d	;restore osraiex return address
	getw	@osexch	;push handler address to cause transfer
	push	h
	push	b	;restore other saved entries
	getw	rtemp
	push	h

raiexx:
	getw	etemp	;retrieve error block addr
	ret


;	@OSEXTH - Exit from handler

@osexth:
	call	cpsubr	;call CPM routine
	putw	etemp	;save error block addr
	pop	b	;save top two entries from stack
	pop	d
	pop	h	;remove handler entry
	push	d	;restore stack
	push	b
	getw	etemp	;retrieve error block addr
	ret

	page

;	MTERR - error trap routine (@ERR)

@osmter:
	lda	cpparm	;check error code
	ora	a
	jz	mterx	;no error

	; use MT+ error code to access table
	lda	cpparm+1
	add	a
	mov	e,a
	mvi	d,0
	lxi	h,extbl-2
	dad	d

	; copy class and subclass to param list
	mov	a,m
	sta	cpparm
	inx	h
	mov	a,m
	sta	cpparm+2
	xra	a
	sta	cpparm+1
	sta	cpparm+3

	; raise exception
	lxi	h,cpparm
	call	@osraex

mterx:
	ret

;    Exception code table
;
extbl:
	db	1,1	;divide by zero
	db	1,5	;heap overflow
	db	1,2	;string overflow
	db	1,2	;range error
	db	1,4	;floating point underflow
	db	1,3	;floating point overflow
	db	1,3	;AMD 9511 error


	page

;
;	ADJSTK: Adjust the stack on entry
;
;	    Move arguments to data area
;	    replace return address
;
adjstk:
	mov	c,m	;get argument block size from table
	inx	h
	shld	tbptr	;save table pointer

	lxi	h,0	;copy stack block to data area
	dad	sp
	lxi	d,retadr1
adjlp:	mov	a,m
	stax	d
	inx	h
	inx	d
	dcr	c
	jnz	adjlp

	sphl		;update sp
	lhld	retadr	;replace main return addr
	push	h
	lhld	retadr1	;exit from adjstk
	pchl

	page

;	INPROC: Process Input arguments

inproc:
	lhld	tbptr		;check type code or terminator
	mov	a,m
	ora	a
	inx	h
	jz	indone		;exit if zero
	call	argproc		;process arguments


;    Select processing routine
	lda	dtype
	mov	c,a
	mvi	b,0
	lxi	h,inptbl-2
	dad	b
	mov	a,m	;get addr from table
	inx	h
	mov	h,m
	mov	l,a
	pchl

indone:
	shld	tbptr
	ret		;return when all processed

;    Input routine table
inptbl:
	dw	inbool
	dw	inint
	dw	inlong
	dw	instr

;    Input boolean (flag) argument
inbool:
	lhld	mtloc
	mov	a,m
	lhld	cploc
	mov	m,a
	jmp	inproc

;    Input integer argument
inint:
	lhld	mtloc	;copy 2 bytes
	xchg
	lhld	cploc
	mvi	a,2
	call	copy
	jmp	inproc

;    Input String argument
instr:
	lhld	mtloc
	xchg
	lxi	h,stbuf
	inx	d	;skip buffer size
	inx	d
	ldax	d	;char count (assume <256)
	inx	d
	inx	d
	mov	m,a	;set count in string buffer
	inx	h
	call	copy	;copy string to buffer
	lxi	d,stbuf	;enter buffer ptr in param block
	lhld	cploc
	mov	m,e
	inx	h
	mov	m,d
	jmp	inproc

	page

;    Input Long Integer argument
;
inlong:
	; copy MT+ value to buffer
	getw	mtloc
	xchg
	getwi	lval
	mvi	a,4
	call	copy

	; get absolute value, save sign
	mvi	c,0
	lda	lval+3
	ora	a
	jp	inl1
	getwi	lval	;negate each 16-bit part
	call	com32
	getwi	lval
	call	inc16
	getwi	lval+2
	call	inc16
	mvi	c,1
inl1:
	mov	a,c
	sta	lvsign

	; convert from base MAXINT+1 (2**15)
	; to 32-bit binary
	xra	a
	lda	lval+3
	rar
	sta	lval+3
	lda	lval+2
	rar
	sta	lval+2
	jnc	inl2
	lda	lval+1
	ori	80h
	sta	lval+1

	; restore sign
inl2:
	lda	lvsign
	ora	a
	jz	inl3
	getwi	lval
	call	com32
	getwi	lval
	call	inc32

	; copy to CPM buffer
inl3:
	getwi	lval
	xchg
	getw	cploc
	mvi	a,4
	call	copy
	jmp	inproc

	page

;	CALLCPM: Call CP/M 2.2 Interface

callcpm:
	lhld	tbptr
	mov	e,m	;routine addr to DE
	inx	h
	mov	d,m
	inx	h
	shld	tbptr
	lxi	h,callcp1	;set up return addr
	push	h
	lxi	h,cpparm
	push	d	;transfer to CPM routine
	ret
callcp1:
	xchg		;error addr to DE
	lxi	h,errblk
	mvi	a,8
	call	copy	;error from CP/M to save area
	lxi	d,errblk
	lhld	ebadr
	mvi	a,8
	call	copy	;error from save area to MT+ program
	ret

	page

;	OUTPROC: Process output arguments

outproc:
	lhld	tbptr		;check type code or terminator
	mov	a,m
	ora	a
	inx	h
	jz	outdone		;exit if zero
	call	argproc		;process arguments


;    Select processing routine
	lda	dtype
	mov	c,a
	mvi	b,0
	lxi	h,outptbl-2
	dad	b
	mov	a,m	;get addr from table
	inx	h
	mov	h,m
	mov	l,a
	pchl

outdone: ret		;return when all processed

;    Input routine table
outptbl:
	dw	outbool
	dw	outint
	dw	outlong
	dw	outstr

;    Output a Boolean (flag) argument
outbool:
	lhld	cploc	;copy 1 byte
	mov	a,m
	lhld	mtloc
	mov	m,a
	jmp	outproc

;    Output an Integer argument
outint:
	lhld	cploc	;copy 2 bytes
	xchg
	lhld	mtloc
	mvi	a,2
	call	copy
	jmp	outproc

;    Output a String argument
outstr:
	lhld	cploc
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	xchg		;addr of CP/M string to DE
	lhld	mtloc
	inx	h
	inx	h
	ldax	d	;copy char count
	mov	m,a
	inx	h
	mvi	m,0
	inx	h
	inx	d
	call	copy
	jmp	outproc

	page

	; Output a long integer argument
	;
outlong:
	; copy CPM value to buffer
	getw	cploc
	xchg
	getwi	lval
	mvi	a,4
	call	copy

	; get abs. value, save sign
	mvi	c,0
	lda	lval+3
	ora	a
	jp	outl1
	getwi	lval	;32-bit negate
	call	com32
	getwi	lval
	call	inc32
	mvi	c,1
outl1:
	mov	a,c
	sta	lvsign

	; convert from 32-bit binary to
	; 2 digits, base 2**15 (MAXINT+1)
	lda	lval+1
	ral
	lda	lval+2
	ral
	sta	lval+2
	lda	lval+3
	ral
	sta	lval+3
	lda	lval+1
	ani	7Fh
	sta	lval+1

	; restore sign
	lda	lvsign
	ora	a
	jz	outl2
	getwi	lval	;negate 2 16-bit values
	call	com32
	getwi	lval
	call	inc16
	getwi	lval+2
	call	inc16

	; copy to MT+ buffer
outl2:
	getwi	lval
	xchg
	getw	mtloc
	mvi	a,4
	call	copy
	jmp	outproc

	page

;	ARGPROC:  Process an argument descriptor

argproc:
	sta	dtype		;save data type
	mov	a,m
	sta	cpoff		;save CP/M offset
	inx	h
	mov	a,m
	sta	mtoff		;save MT+ offset
	inx	h
	shld	tbptr

;    Compute CP/M argument location
	lda	cpoff
	mov	e,a
	mvi	d,0
	lxi	h,cpparm
	dad	d
	shld	cploc

;    Compute MT+ argument location
	lda	mtoff
	ani	00111111b	;mask flag bits
	mov	e,a
	mvi	d,0
	lxi	h,mtparm
	dad	d	;HL has stack location
	lda	mtoff
	ora	a
	jp	argp1	;not indirect
	mov	a,m	;data area loc to HL
	inx	h
	mov	h,m
	mov	l,a
	lda	mtoff	;check for secondary offset
	add	a
	jp	argp1	;none
	xchg
	lhld	tbptr
	mov	c,m
	inx	h
	mov	b,m
	inx	h
	shld	tbptr
	xchg
	dad	b	;add secondary offset
argp1:	shld	mtloc
	ret

	page

;;	COM32 - 4 byte complement
;
;	Entry: HL contains address of 4-byte value
;
;	Exit: value has been complemented
;
com32:
	mvi	c,4	;set byte count
com32a:
	mov	a,m	;complement each byte
	cma
	mov	m,a
	inx	h
	dcr	c
	jnz	com32a
	ret

;;	INC32 - 4 byte increment
;;	INC16 - 2 byte increment
;
;	Entry: HL contains address of 2 or 4 byte value
;
;	Exit: value has been incremented
;
inc32:
	mvi	c,4	;set byte count for 32 bit
	jmp	inca
inc16:
	mvi	c,2	;set byte count for 16 bit
inca:
	inr	m	;increment low to high
	jnz	incb	;quit unless overflow
	inx	h
	dcr	c
	jnz	inca	;quit if all bytes processed
incb:
	ret

	page

;	COPY - Copy a block of memory
;
;	Entry:
;		DE - address of source block
;		HL - address of destination block
;		A - number of bytes
;
copy:
	mov	b,a
copylp:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	b
	jnz	copylp
	ret

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

;	get_error
tbgterr: db	6
	db	0
	dw	gterr
	db	0

;	initiate_program
tbintpg: db	8
	db	0
	dw	intpg
	db	TYPI,4,0+BYLOC	;process_id
	db	0

;	terminate_program
tbtrmpg: db	10
	db	TYPI,0,2+BYVAL	;process_id
	db	TYPI,2,0+BYVAL	;termination_status
	db	0
	dw	cptrmpg
	db	0

	page


;;;	DATA AREA

	dseg

tbptr:	ds	2	;working table pointer
dtype:	ds	2	;argument data type
cpoff:	ds	2	;cpm block offset
cploc:	ds	2	;cpm argument address
mtoff:	ds	2	;mt block offset
mtloc:	ds	2	;mt argument address

etemp:	ds	2	;temporaries for raiex and exith
rtemp:	ds	2

lval:	ds	4	;buffer for long integer conversion
lvsign:	ds	1	;sign for long integer conversion

@oscpxf: ds	2	;CP/M interface routine address
@osexch: ds	2	;application exception handler address

;    Saved information for open files
acmeth:	ds	2*MAXFCB	;access method
recsiz:	ds	2*MAXFCB	;record size

;    Saved error block
errblk: ds	2	;error class
	ds	2	;error reason
	ds	4	;system data (not used by CP/M)

;    Buffer for input string arguments
;       assumes no function has more than one

stbuf:	ds	256

;    Stack data area

retadr1: ds	2	;return address for ADJSTK
retadr:	ds	2	;return address for main routine
ebadr:	ds	2	;error block address
mtparm:	ds	12	;remaining arguments
			;  (in reverse order of declaration)

;    CP/M interface parameter area
;	(Maximum size for get_file_information)

cpparm:	ds	45

	end
