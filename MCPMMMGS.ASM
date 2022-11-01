	title 'MOSI CP/M: SIMPLE MEMORY MANAGEMENT'

	name	'mmgs'

;;;	MOSI Interface for CP/M 2.2

;;	CAPABILITY: Memory Management
;;	MODULE:     Simple Memory Management

;	Last Edit: Jan. 9, 1985
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
;	This module implements simple memory management 
;	within a heap, whose limits must be supplied by
;	the initialization routine.
;
;	Available blocks are maintained on a free list in
;	order by address.  Each block has a 4-byte header.
;	The first two bytes are the pointer to the next
;	block, or zero if there is no next block.  The next
;	two bytes are the size of the block in bytes, not
;	counting the header.
;
;	Allocated blocks are maintained in a similar fashion
;	on an allocated list.
;
	page

;    Exported procedure declarations

	public	cpalloc		;allocate
	public	cpfree		;free
	public	cpgtalu		;get_allocation_unit
	public	cpgtamt		;get_amount_remaining
	public	cpgtsiz		;get_size

	public	@cpimem		;initialize


;    External References

	extrn	@cpinf		;initialize function
	extrn	@cpexf		;exit function
	extrn	@cperr		;error return
	extrn	@cpcopy		;block copy
	extrn	@cpsb16		;16-bit subtract
	extrn	@cpcm16		;16-bit compare
	extrn	@cppba		;parameter block address

;    Error Codes

ERR1IVRQ equ	1		;invalid memory request
ERR1INSM equ	2		;insufficient memory
ERR1IVBK equ	3		;invalid memory block

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CPM macros


	page

;;;	ALLOCATE
;
;	Input Parameters:
;		size		long integer	(4 bytes)
;
;	Output Parameters:
;		location	storageid	(2 bytes)
;
;	Allocates memory of the specified size.  A first fit
;	algorithm is used.  Allocation is in the exact size
;	requested, except that the remainder is not split
;	if it would be less than 5 bytes.

cpalloc:
	call	finit1	;initialize, class 1

	; clear return argument
	getwi	0
	putwx	@cppba,4

	; get requested size (must be < 64K)
	getwx	@cppba
	putw	rqsize

	; initialize freelist pointers
	copyw	freelist,cur
	getwi	0
	putw	prv

; Search freelist for first block large enough
;
alloc1:
	; see if there are any more blocks
	getw	cur
	cmpwi	0
	jz	er1insm	;no, no room

	; check size of current block
	getwx	cur,2
	putw	csize
	cmpw	rqsize
	jnc	alloc2	;it fits

	; otherwise, on to the next block
	copyw	cur,prv
	getwx	cur
	putw	cur
	jmp	alloc1

; Remove chosen block from free list
;
alloc2:
	; see how much leftover space in block
	getw	rqsize
	addwi	5
	xchg
	getw	csize
	call	@cpcm16
	jnc	alloc4

	; no extra space - delete from free list
	getw	prv
	cmpwi	0	; is it the first block?
	getwx	cur
	jnz	alloc3
	putw	freelist ; yes - update head pointer
	jmp	alloc5
alloc3:
	putwx	prv	; no - update ptr in previous block
	jmp	alloc5

	; split existing block, allocate from low end
alloc4:
	getw	cur	;save ptr to selected block
	putw	sel
	addw	rqsize	;set cur ptr to remainder
	addwi	4
	putw	cur
	getwx	sel	;move link to remainder header
	putwx	cur
	getw	csize	;put size in remainder header
	subw	rqsize
	subwi	4
	putwx	cur,2
	getw	rqsize	;put alloc size in original block
	putwx	sel,2

; replace original with remainder in free list
	getw	prv
	cmpwi	0
	getw	cur
	jnz	alloc4a
	putw	freelist
	jmp	alloc4b
alloc4a:
	putwx	prv
alloc4b:
	copyw	sel,cur	;set cur to allocated block

;  Attach at proper position in allocated chain
alloc5:
	copyw	cur,sel	;save new block ptr
	addwi	4
	putwx	@cppba,4 ;set return parameter

	; initialize pointers to allocated list
	getwi	0
	putw	prv
	copyw	aloclist,cur

	; search until larger address or end
alloc6:
	getw	cur
	cmpwi	0
	jz	alloc7	;end of list
	getw	sel
	cmpw	cur
	jc	alloc7	;larger address
	copyw	cur,prv
	getwx	cur
	putw	cur
	jmp	alloc6	;keep looking

	; insert block into allocated list
alloc7:
	getw	cur
	putwx	sel
	getw	prv
	cmpwi	0	;insert at head of list?
	getw	sel
	jz	alloc8
	putwx	prv	;no - set ptr in previous block
	jmp	alloc9
alloc8:
	putw	aloclist ;yes - set head pointer

alloc9:
	jmp	@cpexf	;return

	page

;;;	FREE
;
;	Input Parameters:
;		location	storageid	(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Frees the specified block, after validating that it is
;	on the allocated list.  The freed block is returned to
;	the free list and merged with its neighbors if possible.

cpfree:
	call	finit1	;initialize, class 1

	call	valmem	;validate memory block, set ptrs

	; Delete block from allocated list
	getw	prv
	cmpwi	0	;first block in list?
	getwx	cur
	jnz	free1
	putw	aloclist	;yes - set head ptr
	jmp	free2
free1:
	putwx	prv	;no - set ptr in prev block

	; Find insert position in free list
free2:
	getwi	0
	putw	prv
	getw	freelist
	putw	cur
free3:
	getw	cur
	cmpwi	0
	jz	free4	;reached end of list
	getw	cur
	cmpw	sel
	jnc	free4	;goes before current block
	getw	cur
	putw	prv
	getwx	cur
	putw	cur
	jmp	free3	;keep looking

	; Link into freelist
free4:
	getw	cur
	putwx	sel
	getw	prv
	cmpwi	0	;link at first position?
	getw	sel
	jnz	free5
	putw	freelist	;yes - set head ptr
	jmp	free6
free5:
	putwx	prv	;no - set ptr in prv

	; Merge with following block, if possible
free6:
	getw	cur
	cmpwi	0
	jz	free7	;no following block
	getw	sel
	addw	csize
	addwi	4
	cmpw	cur
	jc	free7	;blocks not contiguous
	getw	csize
	addwx	cur,2
	addwi	4
	putwx	sel,2 ;combined size to current block
	getwx	cur
	putwx	sel	;update current block ptr

	; Merge with preceding block, if possible
free7:
	getw	prv
	cmpwi	0
	jz	free8	;no preceding block
	getw	prv
	addwx	prv,2
	addwi	4
	cmpw	sel
	jc	free8	;blocks not contiguous
	getwx	prv,2
	addwx	sel,2
	addwi	4
	putwx	prv,2	;combined size to previous block
	getwx	sel
	putwx	prv	;update previous block ptr

free8:
	jmp	@cpexf

	page

;;;	GET_ALLOCATION_UNIT
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		unit_size	integer	(2 bytes)
;
;	Returns the size of the smallest possible allocation,
;	which is 1 byte.

cpgtalu:
	call	finit1	;initialize, class 1

	getwi	1	;set return value to 1 byte
	putwx	@cppba

	jmp	@cpexf

	page

;;	GET_AMOUNT_REMAINING
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		total		long integer	(4 bytes)
;		largest		long integer	(4 bytes)
;
;	Determines the largest contiguous block on the free list,
;	and the total memory capacity of the free list.

cpgtamt:
	call	finit1	;initialize, class 1

	getw	freelist
	putw	cur
	getwi	0
	putw	total
	putw	largest

gtamt1:
	getw	cur
	cmpwi	0
	jz	gtamt3	;end of list
	getw	total
	addwx	cur,2
	putw	total	;update total
	getwx	cur,2
	cmpw	largest
	jc	gtamt2
	putw	largest ;update largest, if required
gtamt2:
	getwx	cur
	putw	cur
	jmp	gtamt1	;keep scanning

	; setup parameter block
gtamt3:
	getw	total
	putwx	@cppba
	getw	largest
	putwx	@cppba,4
	getwi	0
	putwx	@cppba,2
	getwi	0
	putwx	@cppba,6

	jmp	@cpexf

	page

;;;	GET_SIZE
;
;	Input Parameters:
;		location	storageid	(2 bytes)
;
;	Output Parameters:
;		size		long integer	(4 bytes)
;
;	Returns the size of the specified memory block, after
;	validating that it is present on the allocated list
;
cpgtsiz:
	call	finit1	;initialize, class 1

	getwi	0	;clear result
	putwx	@cppba
	getwi	0
	putwx	@cppba,2

	call	valmem	;validate memory allocation

	; return result parameter
	getwx	cur,2
	putwx	@cppba

	jmp	@cpexf

	page

;;;	SUPPORT ROUTINES -- MEMORY MANAGEMENT

;	VALMEM: Validate Memory Block

valmem:
	getwx	@cppba	;get memory block logical addr
	subwi	4
	putw	sel	;save real address

	; initalize pointers
	copyw	aloclist,cur
	getwi	0
	putw	prv

	; Search for block in allocated list
valm1:
	getw	cur
	cmpwi	0
	jz	er1ivbk	;end of list - not found
	cmpw	sel
	jz	valm2	;found it here
	jnc	er1ivbk	;past its place - not found
	putw	prv
	getwx	cur
	putw	cur
	jmp	valm1	;keep looking
valm2:
	getwx	sel,2	;get current block size
	putw	csize
	ret

	page

;	@CPIMEM: Initialize Memory Management
;
;	Entry: HL - address of start of heap area
;	       DE - address of end of heap area


@cpimem:
	putw	freelist
	putw	stheap
	xchg
	putw	enheap
	subw	stheap
	subwi	3		;get difference less header
	putwx	stheap,2
	getwi	0
	putw	aloclist
	putwx	stheap
	ret

;	INITIALIZATION TRANSFER

finit1:
	mvi	a,1
	jmp	@cpinf


;	ERROR TRANSFERS

er1ivrq:
	mvi	a,ERR1IVRQ	;invalid memory request
	jmp	@cperr

er1insm:
	mvi	a,ERR1INSM	;insufficient memory
	jmp	@cperr

er1ivbk:
	mvi	a,ERR1IVBK	;invalid memory block
	jmp	@cperr

	page

;;;	DATA SEGMENT
	dseg

;	UNINITIALIZED DATA

freelist: ds	2	;start of free memory list
aloclist: ds	2	;start of allocated memory list
stheap:	ds	2	;first address of heap area
enheap	ds	2	;last address of heap area
cur	ds	2	;current block pointer
prv	ds	2	;previous block pointer
sel	ds	2	;selected block pointer
rqsize	ds	2	;requested size
csize	ds	2	;current block size
largest	ds	2	;largest block size
total	ds	2	;total free memory


	end
