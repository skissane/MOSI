	title 'MOSI/CPM: Static File Buffer Management'

	name	'sfbm'

;;;	MOSI Interface for CP/M 2.2

;;	Static Storage Management for File Buffers

;	Last Edit: November 30, 1984
;
;	Copyright (C) 1984 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506
;
;	  Assemble with Digital Research RMAC
;		or compatible assembler
;
;	This version uses static buffers, no dynamic
;	allocation.  It is suitable when the memory
;	management module cannot be used due to built
;	in language support mechanisms.

;    Exported procedure names
	public	@cpalfb		;allocate a file buffer
	public	@cpfrfb		;free a file buffer

	extrn	@cpcopy

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CPM macros

;    Symbol Definitions
	BLKSIZE	equ	128	;standard file block size
	MAXFCB	equ	8	;no. of FCB's permitted

	page

;;	 @CPALFB - Allocate a file buffer
;
;	Entry: connect id in A
;
;	Exit: carry set if error
;	       (not possible in static version)
;	      buffer address in HL
;
	; initialize variables
@cpalfb:
	lxi	h,filebuf
	lxi	d,BLKSIZE

	; find location of the buffer
alcbf1:
	dcr	a
	jz	alcbf2
	dad	d
	jmp	alcbf1

	; return
alcbf2:
	ora	a	;clear carry
	ret

;;	FREEBUF - Free a file buffer
;
;	Entry: buffer addr in HL
;
;	Exit: carry set if error
;		(not possible in static version)
@cpfrfb:
	ora	a	;clear carry & return
	ret

	page
;;	DATA SEGMENT

	dseg

; Permanent File Buffers
filebuf	ds	BLKSIZE * MAXFCB

	end
