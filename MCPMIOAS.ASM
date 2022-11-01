	title 'MOSI CP/M: I/O ASSIGNMENTS'

	name	'ioas'

;;;	MOSI Interface for CP/M 2.2

;;	CAPABILITY: Interface With the Environment
;;	MODULE:     I/O Assignments

;	Last Edit: January 19, 1985
;
;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506
;
;
;	   Assemble with Digital Research RMAC
;	     or compatible assembler
;

;   Exported Procedure Names

	public	cpgtioa		;get_io_assignments
	public	cpchioa		;change_io_assignments

	public	@cpiioa		;initialize

;    External References

	extrn	@cpinf		;initialize function
	extrn	@cpexf		;exit function
	extrn	@cperr		;error return
	extrn	@cpcopy		;block copy
	extrn	@cpsb16		;16-bit subtract
	extrn	@cpcm16		;16-bit compare
	extrn	@cppba		;parameter block address

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CP/M macros

;    Symbol Definitions
MAXIOC	equ	7		;highest valid I/O code
ERR7IVCD equ	1		;invalid code
ERR7ASNC equ	8		;assignment not changed

	page

;;	GET_IO_ASSIGNMENTS
;
;	Input Parameters:
;		io_code		integer		(2 bytes)
;
;	Output Parameters:
;		io_status	integer		(2 bytes)
;		io_type		integer		(2 bytes)
;		file_name	string		(2 bytes)
;		connect_id	systemtag	(2 bytes)
;
;	Returns the specified status information, which is taken
;	directly from the tables.  Note that this information gives
;	the INITIAL status of each channel.  It will not change,
;	for example, if an unopened i/o assignment channel is later
;	opened by the application.

cpgtioa:
	mvi	a,7	;set class to 7
	call	@cpinf	;initialize

	; copy null data to output parameters
	lhld	@cppba
	inx	h	;skip to output position
	inx	h
	lxi	d,ioasgtb	;get data from front of table
	mvi	a,ioaesiz
	call	@cpcopy

	; get and validate i/o code
	call	gvalioc
	jc	er7ivcd	;error - invalid code

	; copy proper data to output
	lxi	h,ioasgtb
	lxi	d,ioaesiz
gtioa1:
	dad	d	;find start point in table
	dcr	a
	jnz	gtioa1
	xchg		;setup for copy
	lhld	@cppba
	inx	h
	inx	h
	mvi	a,ioaesiz
	call	@cpcopy	;copy the data

	jmp	@cpexf	;return

	page

;;	CHANGE_IO_ASSIGNMENTS
;
;	Input Parameters:
;		io_code		integer		(2 bytes)
;		file_name	string		(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Changes the file associated with the specified I/O
;	channel, if permitted.  In the present CP/M version,
;	no changes are permitted.

cpchioa:
	mvi	a,7	;set class to 7
	call	@cpinf	;initialize

	; get and validate i/o code
	call	gvalioc
	jc	er7ivcd	;error - invalid code
	jmp	er7asnc	;otherwise error - not permitted

	jmp	@cpexf	;(return - cannot happen)

	page

;;;	SUPPORT SUBROUTINES

;	GVALIOC: Get and validate I/O Code
;
;	Entry:
;		I/O code in parameter block
;
;	Exit:
;		I/O code (1 byte) in A
;		carry set iff invalid

gvalioc:
	; get 1 byte of code to A
	getwx	@cppba
	mov	a,l

	; check that code is in range
	cpi	1
	jc	gval1
	cpi	MAXIOC+1
	jnc	gval1

; return if no error
	ora	a
	ret

; return in case of error
gval1:
	stc
	ret	;return with carry

	page

;	@CPIIOA: Initialize I/O Assignment Table
;
;	Does nothing in the present version, since the
;	table cannot change.

@cpiioa:
	ret

;;	ERROR TRANSFERS

er7ivcd:
	mvi	a,ERR7IVCD	;invalid i/o code
	jmp	@cperr
er7asnc:
	mvi	a,ERR7ASNC	;assignment not changed
	jmp	@cperr

	page

;;	I/O ASSIGNMENT TABLE
;
;	Entries:
;		1. channel status code (2 bytes)
;		2. channel type code (2 bytes)
;		3. pointer to file name string (2 bytes)
;		4. connect id, if connected (2 bytes)
;
ioasgtb:
	dw	0,0,dvnul,0	;null data for invalid id
ioaesiz	equ	$-ioasgtb
	dw	1,2,dvcon,0	;standard input (console, init open)
	dw	1,2,dvcon,0	;standard output (console, init open)
	dw	1,2,dvtrm,0	;error input (terminal)
	dw	1,2,dvtrm,0	;error output (terminal)
	dw	1,2,dvtrm,0	;terminal input (terminal)
	dw	1,2,dvtrm,0	;terminal output (terminal)
	dw	1,4,dvlst,0	;printer output (printer)

; File name strings
dvcon:	mstring	'CON:'
dvtrm:	mstring	'TRM:'
dvlst:	mstring	'LST:'
dvnul:	mstring	''

	end
