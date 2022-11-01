	title 'MOSI CP/M: EXCEPTION HANDLING'

	name	'exch'

;;;	MOSI Interface for CP/M 2.2

;;	CAPABILITY: Exception Handling
;;	MODULES:    Default Handler
;;		    Single Exception Handler

;	Last Edit: May 26, 1985
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

;    Exported Procedure Names

	public	cpdisex		;disable
	public	cpenaex		;enable
	public	cpgtens		;get_enable_status

	public	cpgetex		;get_exception_handler
	public	cpsetex		;set_exception_handler
	public	cpresdf		;reset_default_handler
	public	cpraiex		;raise_exception
	public	cpgtexc		;get_exception_code
	public	cpexith		;exit_from_handler

	public	@cpiexh		;initialize

;    External references

	extrn	@cpinf		;initialize function
	extrn	@cpexf		;exit function
	extrn	@cperr		;error return
	extrn	@cpcopy		;block copy
	extrn	@cpsb16		;16-bit subtract
	extrn	@cpcm16		;16-bit compare
	extrn	@cppba		;parameter block address

	page

;    Symbol Definitions
	BDOS	equ	5	;BDOS transfer location
	WBOOT	equ	0	;warm boot BDOS function
	CONOUT	equ	2	;console output BDOS function
	PRSTR	equ	9	;print string BDOS function
	CR	equ	13	;ASCII return
	LF	equ	10	;ASCII line feed

;    Error Codes
	ERR8IVEX equ	1	;invalid exception
	ERR8ECNS equ	2	;exception not supported

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CPM macros

	page

;;	DISABLE
;
;	Input Parameters:
;		exception_class	integer		(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Disables exception handling for the specified class.
;	The exception classes recognized are class 1-3, as
;	listed in Appendix B of the standard.

cpdisex:
	mvi	a,8
	call	@cpinf	;initialize, class 8

	; validate class, set status
	call	valexc
	mvi	m,0

	jmp	@cpexf	;return

	page

;;	ENABLE
;
;	Input Parameters:
;		exception_class	integer		(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Enables handling of exceptions in the specified class
;	by the current handler.  The classes recognized are 1-3
;	as specified in Appendix B of the standard.

cpenaex:
	mvi	a,8
	call	@cpinf	;initialize, class 8

	; validate class, set status
	call	valexc
	mvi	m,1

	jmp	@cpexf

	page

;;	GET_ENABLE_STATUS
;
;	Input Parameters:
;		exception_class	integer		(2 bytes)
;
;	Output Parameters:
;		status		flag		(1 byte)
;
;	Returns the current status, enabled or not, for the
;	specified exception class.

cpgtens:
	mvi	a,8
	call	@cpinf	;initialize, class 8

	; initialize output parameter
	lhld	@cppba
	inx	h
	inx	h
	xra	a
	mov	m,a

	; validate class, get status
	call	valexc
	mov	c,m

	; insert status as output parameter
	lhld	@cppba
	inx	h
	inx	h
	mov	m,c

	jmp	@cpexf	;return

	page

;;	GET_EXCEPTION_HANDLER
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		current_handler	storageid	(2 bytes)
;
;	Returns the storageid (address) of the
;	current exception handler.  A value of zero
;	signifies the default handler.

cpgetex:
	call	finit8	;initialize, class 8

	;return current handler
	getw	curexh
	putwx	@cppba

	jmp	@cpexf	;return

	page

;;	SET_EXCEPTION_HANDLER
;
;	Input Parameters:
;		new_handler	storageid	(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Accepts a storageid (address) for the current exception
;	handler.  A value of 0 signifies the default handler.
;
cpsetex:
	call	finit8	;initialize, class 8

	; save current handler addr
	getwx	@cppba
	putw	curexh

	jmp	@cpexf	;return

	page

;;	RESET_DEFAULT_HANDLER
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		(none)
;
;	Sets the address of the current handler to zero,
;	which signifies the default handler.
;
cpresdf:
	call	finit8	;initialize, class 8

	; set handler addr to zero
	getwi	0
	putw	curexh

	jmp	@cpexf	;return

	page

;;	RAISE_EXCEPTION
;
;	Input Parameters:
;		exception_class	integer		(2 bytes)
;		sub_class	integer		(2 bytes)
;
;	Output Parameters:
;		handler_addr	storageid	(2 bytes)
;
;	Initiates the raising of an exception.  The specified
;	class and subclass are stored for use by
;	GET_EXCEPTION_CODE. A flag is set to indicate that
;	an exception is currently active.  Nested exceptions
;	are not allowed.
;
;	To avoid the difficulty of recursive calls to the CPM
;	interface, the function passes the address of the
;	handler	back to the language interface, if it is a
;	user handler.  The language interface is responsible
;	for actually invoking the handler.  If the default
;	handler is selected, RAISE_EXCEPTION transfers directly
;	to it.  The default handler calls no functions and
;	always aborts.
;
;	A zero value returned means that no handler should be
;	invoked.  Either the class was disabled, or the class
;	was invalid.  In the latter case an error code will be
;	present.
;
cpraiex:
	call	finit8	;initialize, class 8

	; initialize output parameter
	getwi	0
	putwx	@cppba,4

	; check for nested exceptions
	lda	exactv
	ora	a
	jnz	er8ivex	;nested - not allowed

	; validate class, get status
	call	valexc
	mov	a,m

	; return if not enabled
	ora	a
	jz	@cpexf

	; save class & subclass, set active flag
	getwx	@cppba
	putw	excls
	getwx	@cppba,2
	putw	exsub
	mvi	a,1
	sta	exactv

	; test current handler
	getw	curexh
	cmpwi	0
	jz	defexh	;go to default if zero

	; return handler address
	putwx	@cppba,4

	jmp	@cpexf	;return

	page

;;	GET_EXCEPTION_CODE
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		class_code	integer		(2 bytes)
;		sub_class	integer		(2 bytes)
;
;	Returns the current exception class and subclass.
;	These will be zero if not called from a handler.
;	No error is provided by the standard for this
;	situation.
;
cpgtexc:
	call	finit8	;initialize, class 8

	; return class and subclass
	getw	excls
	putwx	@cppba
	getw	exsub
	putwx	@cppba,2

	jmp	@cpexf	;return

	page

;;	EXIT_FROM_HANDLER
;
;	Input Parameters:
;		disposition		integer		(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Returns from an active handler.  If there is no active
;	handler, the program is aborted.  A disposition code
;	of 0 causes a return to the point at which the
;	exception was raised.  Any other value causes the
;	program to abort.
;
;	If this function returns to the language interface,
;	it is the responsibility of that interface to resume
;	the interrupted program.
;
cpexith:
	call	finit8	;initialize, class 8

	; check to-whom parameter
	getwx	@cppba
	cmpwi	0
	jnz	exith2	;value is not 1
	lda	exactv
	ora	a
	jz	exith2	;no handler active

	; cleanup and return
	xra	a
	sta	exactv	;nothing active now
	getwi	0
	putw	excls	;clear class and subclass
	putw	exsub
	jmp	@cpexf	;return

	; abort program
exith2:
	lxi	d,abrtmsg
	syscall	PRSTR
	syscall	WBOOT

;    Program Abort Message
;
abrtmsg:
	db	CR,LF
	db	'PROGRAM ABORTED'
	db	CR,LF,'$'

	page

;;;	SUPPORT SUBROUTINES


;	@CPIEXH - Initialize module

@cpiexh:
	xra	a
	sta	exctbl	;clear status table
	sta	exctbl+1
	sta	exctbl+2
	sta	exactv	;clear active flag
	getwi	0
	putw	curexh	;set current handler to default
	putw	excls	;clear class and subclass
	putw	exsub
	ret

	page

;	VALEXC - Validate Exception Class, check status

valexc:
	getwx	@cppba
	cmpwi	1
	jc	er8ecns	;not valid
	cmpwi	4
	jnc	er8ecns	;not valid
	lxi	d,exctbl-1
	dad	d
	ret

	page

;	DPNUM - display byte as 3-digit number

dpnum:
	; compute & display 1st digit
	sta	dpval
	mvi	e,'0'
dpn1:
	sui	100
	jc	dpn2
	inr	e
	sta	dpval
	jmp	dpn1
dpn2:
	syscall	CONOUT

	; compute & display 2nd digit
	lda	dpval
	mvi	e,'0'
dpn3:
	sui	10
	jc	dpn4
	inr	e
	sta	dpval
	jmp	dpn3
dpn4:
	syscall	CONOUT

	; compute & display 3rd digit
	lda	dpval
	adi	'0'
	mov	e,a
	syscall	CONOUT

	ret

	page

;	DEFEXH - Default Exception Handler

defexh:
	; display message
	; assumes class & subclass are in range 0-255
	lxi	d,defmg1 ;display first part of message
	syscall	PRSTR
	lda	excls	;display class
	call	dpnum
	lxi	d,defmg2 ;display second part of message
	syscall	PRSTR
	lda	exsub	;display subclass
	call	dpnum
	lxi	d,abrtmsg ;display abort message
	syscall	PRSTR
	syscall	WBOOT	;abort

;    Exception display messages
;
defmg1:	db	CR,LF
	db	'EXCEPTION: CLASS=$'
defmg2:	db	', SUBCLASS=$'

	page


;	INITIALIZATION TRANSFER

finit8:
	mvi	a,8
	jmp	@cpinf

;	ERROR TRANSFERS

er8ivex:
	mvi	a,ERR8IVEX	;invalid exception
	jmp	@cperr

er8ecns:
	mvi	a,ERR8ECNS	;exception class not supported
	jmp	@cperr

	page

;;	DATA SEGMENT
	dseg

curexh:	ds	2	;current handler
exactv:	ds	1	;active flag
excls:	ds	2	;class for active exception
exsub:	ds	2	;subclass for active exception
exctbl:	ds	3	;status table
dpval:	ds	1	;temporary for dpnum

	end
