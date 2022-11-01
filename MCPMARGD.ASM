	title 'MOSI CP/M: DIRECT ARGUMENT ACQUISITION'

	name	'argd'

;;;	MOSI Interface for CP/M 2.2

;;	CAPABILITY: Interface With the Environment
;;	MODULE:     Direct Argument Acquisition

;	Last Edit: January 8, 1985
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

	public	cpgtcnt		;get_argument_count
	public	cpgtarg		;get_argument

	public  @cpiarg		;initalize arg processing


;    External references

	extrn	@cpinf		;initialize function
	extrn	@cpexf		;exit function
	extrn	@cperr		;error return
	extrn	@cpcopy		;block copy
	extrn	@cpsb16		;16-bit subtract
	extrn	@cpcm16		;16-bit compare
	extrn	@cppba		;parameter block address

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CPM macros


;;	SYMBOL DEFINITIONS

CMLADR	equ	80h	;address of command line buffer
CMLSIZ	equ	128	;size of command line buffer
TAB	equ	9	;ASCII tab

ERR7NMA equ	4	;no more arguments

	page

;;	GET_ARGUMENT_COUNT
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		argument_count	integer		(2 bytes)
;
;	Returns the number of arguments not yet scanned in
;	the command line, if any.  The argument syntax is
;	described under GET_ARGUMENT, below.

cpgtcnt:
	mvi	a,7
	call	@cpinf

	; transfer argnum as result
	getw	argnum
	putwx	@cppba

	jmp	@cpexf

	page

;;	GET_ARGUMENT
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		next_argument	string		(2 bytes)
;
;	GET_ARGUMENT scans for the next argument, if any,
;	and returns it in the form of a string.  Its single
;	parameter structure is simpler than, but functionally
;	equivalent to, that specified in the standard.  The
;	language interface is responsible for copying this
;	string to the user's area.
;
;	Arguments in the command line are sequences of
;	characters delimited by blanks or commas.  Any
;	character including blanks and commas can be
;	included in an argument string by enclosing the
;	string in double quotes (").  As usual,	two double
;	quote characters within a string are taken as
;	an actual double quote character.

cpgtarg:
	mvi	a,7
	call	@cpinf	;initialize, class 7

	xra	a
	sta	argbuf	;zero argument buffer
	lxi	h,argbuf	;return it as result
	putwx	@cppba

	lda	argnum
	ora	a
	mvi	a,ERR7NMA
	jz	@cperr	;no more arguments
	
	call	scanarg	;scan argument to buffer

	; decrease argument count
	lda	argnum
	dcr	a
	sta	argnum

	jmp	@cpexf

	page

;;	SUPPORT SUBROUTINES


;	@CPIARG: Initialize Command Line Processing

@cpiarg:

	; copy command line from CP/M area
	lxi	d,CMLADR
	lxi	h,cmdbuf
	mvi	a,CMLSIZ
	call	@cpcopy

	; terminate with null
	lda	cmdbuf
	mov	c,a
	mvi	b,0
	lxi	h,cmdbuf+1
	dad	b
	mvi	m,0

	; scan and count arguments
	xra	a
	sta	argnum
	getwi	cmdbuf+1
	putw	argix

iarg0:
	call	scanarg
	lda	argbuf	;argument null?
	ora	a
	jnz	iarg1	;no - continue
	getw	argix	;yes - at eol?
	mov	a,m
	ora	a
	jz	iarg2	;yes - done
iarg1:
	lda	argnum	;count and continue
	inr	a
	sta	argnum
	jmp	iarg0


	; initialize buffer index
iarg2:
	getwi	cmdbuf+1
	putw	argix

	ret

	page

;;	SCANARG - scan an argument into arg buffer

scanarg:

	; initialize indexes & count
	mvi	c,0	;character count
	lxi	d,argbuf+1	;output ptr
	lhld	argix	;input ptr
	mov	a,m	;get first char

	; skip blanks or tabs
scan1:
	cpi	' '
	jz	scan2
	cpi	TAB
	jnz	scan3
scan2:
	inx	h	;get next
	mov	a,m
	jmp	scan1

	;test for quoted string
scan3:
	cpi	'"'
	jz	scan5	;found one

; Argument is not a quoted string
;
scan4:
	cpi	0
	jz	scanx	;eos - done
	cpi	','
	jz	scan9	;skip, then done
	cpi	' '
	jz	scan9	;skip, then done
	cpi	TAB
	jz	scan9	;skip, then done
	stax	d	;store char
	inx	d
	inr	c	;count it
	inx	h	;get next
	mov	a,m
	jmp	scan4	;continue

; Argument is a quoted string
;
scan5:
	inx	h	;get next
	mov	a,m
	cpi	0
	jz	scanx	;eos - done
	cpi	'"'
	jnz	scan6	;not terminator
	inx	h
	mov	a,m	;check for double quote
	cpi	'"'
	jnz	scan9	;end - skip & finish
scan6:
	stax	d	;insert it
	inx	d
	inr	c	;count it
	jmp	scan5	;continue

	; skip any blanks & one comma
scan9:
	cpi	' '
	jz	scan9a
	cpi	TAB
	jnz	scan9b
scan9a:
	inx	h
	mov	a,m
	jmp	scan9
scan9b:
	cpi	','
	jnz	scanx
	inx	h	;skip comma

	; set index & count, exit
scanx:
	mov	a,c
	sta	argbuf
	shld	argix
	ret

	page

;;	DATA SEGMENT

	dseg

argix	ds	2	;next position in command buffer
argnum	ds	2	;number of arguments remaining

cmdbuf	ds	CMLSIZ	;command line buffer
argbuf	ds	CMLSIZ	;argument buffer

	end
