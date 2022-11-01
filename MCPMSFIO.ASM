	title 'MOSI/CPM: SYNCHRONOUS FILE I/O'

	name	'sfio'

;;;	MOSI Interface for CP/M 2.2

;;	CAPABILITY: Data Transfer
;;	MODULE:     Synchronous File I/O

;	Last Edit: June 6, 1985
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

;    Exported procedure names
	public	cpconn		;connect
	public	cpdconn		;disconnect
	public	cpcreat		;create
	public	cpexten		;extend
	public	cptrunc		;truncate
	public	cpopen		;open
	public	cpclose		;close
	public	cpread		;read
	public	cpwrite		;write
	public	cpseek		;seek
	public	cpgfinf		;get_file_information
	public	cpgtacc		;get_access_control
	public	cpchacc		;change_access_control
	public	cpdelet		;delete
	public	cprenam		;rename
	public	cpgtwkd		;get_working_directory
	public	cpchwkd		;change_working_directory
	public	cpgtidn		;get_identity

	public	@cpifil		;initialize file processing
	public	@cptfil		;terminate file processing
	public	@cpconn		;connect a file
	public	@cpdcon		;disconnect a file

;    External References

	extrn	@cpalfb		;allocate a file buffer
	extrn	@cpfrfb		;free a file buffer
	extrn	@cpinf		;initialize function
	extrn	@cpexf		;exit function
	extrn	@cperr		;error return
	extrn	@cpcopy		;block copy
	extrn	@cpsb16		;16-bit subtract
	extrn	@cpcm16		;16-bit compare
	extrn	@cppba		;parameter block address

;    Macro Definitions
	maclib	mcpmmacs	  ;include MOSI-CPM macros

	page
;;	SYMBOL DEFINITIONS


;    ACCESS CONTROL CODES
DELPERM	equ	1		;delete permission
RDPERM	equ	2		;read permission
WRPERM	equ	4		;write permission
EXTPERM	equ	8		;extend permission
EXEPERM	equ	16		;execute permission
CHAPERM	equ	32		;change access permission
EXAPERM	equ	64		;exclusive access permission

MODPERM	equ	DELPERM OR WRPERM OR EXTPERM
ROFPERM	equ	RDPERM OR EXEPERM OR CHAPERM OR EXAPERM
RWFPERM equ	ROFPERM OR MODPERM
RODPERM	equ	RDPERM OR CHAPERM OR EXAPERM
WODPERM equ	WRPERM OR EXTPERM OR CHAPERM OR EXAPERM
RWDPERM equ	RODPERM OR WODPERM

;    ORGANIZATION AND ACCESS CODES
FORGMIN	equ	1		;lowest file org. code
FORGMAX	equ	3		;highest file org. code
FORGSEQ	equ	1		;file org. sequential
FORGDIR	equ	2		;file org. direct
FORGDIRY equ	3		;file org. directory
RORGMIN	equ	1		;lowest record org. code
RORGMAX	equ	3		;highest record org. code
RORGFLEN equ	1		;record org. fixed length
RORGVLEN equ	2		;record org. var. length
RORGSTRM equ	3		;record org. stream
ACMTMIN	equ	1		;lowest access method code
ACMTMAX equ	3		;highest access method code
ACMTSTRM equ	1		;access method stream
ACMTSEQ	equ	2		;access method sequential
ACMTDIR	equ	3		;access method direct
SORGMIN	equ	1		;lowest seek origin code
SORGMAX equ	3		;highest seek origin code
SORGBOF	equ	1		;beginning of file
SORGEOF	equ	2		;end of file
SORGCUR	equ	3		;current position

;    MFCB FLAG BITS
MFINUSE	equ	10000000b	;block in use
MFOPEN	equ	01000000b	;file is open
MFTRUE	equ	00100000b	;file is a true file
MFTEMP	equ	00010000b	;file is a temporary file
MFBVAL	equ	00001000b	;buffer is valid
MFBMOD	equ	00000100b	;buffer has been modified
MFEOF	equ	00000010b	;end-of-file
MFTEXT	equ	00000001b	;file is a text file

;    BDOS FUNCTION CODES
CONOUT	equ	2		;console output
RDRIN	equ	3		;reader input
PUNOUT	equ	4		;punch output
LSTOUT	equ	5		;list output
DCONIO	equ	6		;direct console I/O
RDCONB	equ	10		;read console buffer
SELDSK	equ	14		;select disk
OPNFIL	equ	15		;open a file
CLSFIL	equ	16		;close a file
DELFIL	equ	19		;delete a file
MAKFIL	equ	22		;create a file
RENFIL	equ	23		;rename a file
GCDSK	equ	25		;get current disk
SETDMA	equ	26		;set DMA buffer
SETFA	equ	30		;set file attributes
RDRAN	equ	33		;read random file block
WRRAN	equ	34		;write random file block
GFILSZ	equ	35		;get file size

	page
;    Error Codes
ERR3IVCN equ	1		;invalid connection
ERR3FNF  equ	2		;file not found
ERR3IVNM equ	3		;invalid file name
ERR3INSR equ	4		;insufficient resources
ERR3ACDN equ	5		;access denied
ERR3IVAC equ	6		;invalid access control
ERR3FEX	 equ	7		;file already exists
ERR3DFUL equ	8		;device full
ERR3OFB	 equ	9		;out of file bounds
ERR3DFN	 equ	10		;duplicate file name
ERR3XER	 equ	13		;transmission error
ERR3SKNS equ	19		;seeks not supported
ERR3NSO	 equ	20		;organization not supported
ERR3FNR	 equ	21		;file not renamed
ERR3UCRE equ	22		;unable to create
ERR3NSD	 equ	24		;no such directory
ERR3FNO	 equ	25		;file not open
ERR3IVID equ	26		;invalid identity
ERR3FAO	 equ	27		;file already open
ERR3IVMD equ	28		;invalid mode
ERR3IVIC equ	29		;invalid identity code
ERR3IVRO equ	31		;invalid record organization

;    Miscellaneous
BDOS	equ	5		;BDOS entry point
CURDSK	equ	4		;current disk code address
ROFLAG	equ	10000000b	;CP/M readonly status flag
BLKSIZE	equ	128		;standard file block size
FINFSZ 	equ	43		;size of file info block
FNAMLEN equ	12		;file name length
CTRLZ	equ	1Ah		;CP/M end-of-file code
CR	equ	0Dh		;ASCII return
LF	equ	0Ah		;ASCII linefeed

;    Tunable parameters
MAXFCB	equ	8		;no. of FCB's permitted
MAXDEV	equ	5		;no. of device types supported
MAXDRV	equ	16		;max drive number
VRSZMAX equ	255		;max var. record size

	page
;;;	CONNECT
;
;	Input parameters:
;		file_name	string		(2 bytes)
;
;	Output parameters:
;		connect_id	systemtag	(2 bytes)
;
;	Connects a "file", which may be any CP/M file or the
;	device names CON:,LST:,RDR:,PUN:, or TRM:.  Since CP/M
;	maintains limited directory information, the following
;	characteristics are assumed: devices have sequential
;	organization, with record size & efficient size of 1 byte.
;	Files allow direct organization but are initialized to
;	stream, with record size 1 byte.  Their efficient size is
;	1 block (128 bytes).
;
;	All files and devices have CHANGE-ACCESS and EXCLUSIVE-
;	ACCESS permission.  Devices also have READ permission
;	if readable, and WRITE permission if writeable.  Read-
;	only files have	READ and EXECUTE permission.  Read-write
;	files have all possible permissions.
;
cpconn:
	call	finit3	;initialize, class 3

	getwi	0	;clear return args
	putwx	@cppba,2

	getwx	@cppba	;get file name
	call	@cpconn	;connect the file
	jnz	@cperr	;error on connect

	; return connect id
	putwx	@cppba,2

	jmp	@cpexf

	page
;;	@CPCONN - CONNECT A FILE
;
;	    called by CONNECT
;	      also callable from other modules
;
;	Entry: HL points to filename string
;
;	Exit: MOSI error code in A, zero set if no error
;	      connect_id in HL
;
@cpconn:
	putw	fnamp	;save file name pointer

	; find a free FCB, init workspace
	call	findfcb
	jc	connxe1	; error - no room

	; allocate a buffer
	lda	connid
	call	@cpalfb
	jc	connxe1
	putw	mfcb+mfcbbfad

	; lookup in device table
	call	lkupdev
	jc	conn1	;not a device

; File is a Device
;
	lxi	h,fcb+fcbfnam	; copy name to FCB (DE is ptr)
	mvi	a,4		;(all device names are 4 bytes)
	call	@cpcopy

	; Get access permission from table
	lxi	h,devacc-1
	lda	fcb+fcbdrv
	mov	e,a
	mvi	d,0
	dad	d
	mov	a,m
	sta	mfcb+mfcbaccn

	; Set remaining device parameters
	mvi	a,MFINUSE
	sta	mfcb		;set flags
	getwi	0
	putw	mfcb+mfcbfsiz	;file size = 0 (meaningless)
	getwi	1
	putw	mfcb+mfcbesiz	;efficient record size = 1 byte
	mvi	a,FORGSEQ
	sta	mfcb+mfcbforg	;file org = sequential

	jmp	conn3		;on to common process

; File is a true file
;
conn1:
	; parse file name
	getw	fnamp
	call	parsefn
	jc	connxe2	;invalid name

	; Make current disk explicit
	lda	fcb+fcbdrv
	ora	a
	jnz	conn1a
	syscall	GCDSK
	inr	a
	sta	fcb+fcbdrv

	; Try to open the file
conn1a:
	call	cpmopen
	jz	connxe3	;file not found

	; Determine file size
	lxi	d,fcb
	syscall	GFILSZ
	copyw	fcb+fcbblkn,mfcb+mfcbfsiz
	getwi	0
	putw	fcb+fcbblkn

	; Check CP/M R/O flag, set access permission
	lda	fcb+fcbftyp
	ora	a
	mvi	a,ROFPERM  ;access permission if read-only
	jm	conn2
	mvi	a,RWFPERM  ;access permission if read-write
conn2:
	sta	mfcb+mfcbaccn

	; Set remaining file parameters
	mvi	a,MFTRUE+MFINUSE
	sta	mfcb	;set flags
	getwi	BLKSIZE
	putw	mfcb+mfcbesiz	;efficient record size = 1 block
	mvi	a,FORGDIR
	sta	mfcb+mfcbforg	;file org = direct

; Common processing for files and devices
;
conn3:
	; Set remaining fields, copy data
	getwi	1
	putw	mfcb+mfcbrsiz	;record size = 1 byte
	mvi	a,RORGSTRM
	sta	mfcb+mfcbrorg	;record org = stream
	mvi	a,BLKSIZE-1
	sta	mfcb+mfeofbyt	;eof byte last in block
	call	fcpfrw		;copy workspace to FCB

	; normal return
	getw	connid	;connect id to HL
	xra	a	;set zero flag
	ret		

	; error returns
connxe1:
	mvi	a,ERR3INSR	;insufficient resources
	ora	a
	ret
connxe2:
	mvi	a,ERR3IVNM	;invalid file name
	ora	a
	ret
connxe3:
	mvi	a,ERR3FNF	;file not found
	ora	a
	ret

	page
;;;	DISCONNECT
;
;	Input parameters:
;		connect_id	systemtag	(2 bytes)
;
;	Output parameters:
;		(none)
;
;	Disconnects a file.  The file is closed if open, and
;	deleted if it is temporary.
;
cpdconn:
	call	finit3	;initialize, class 3

	getwx	@cppba
	mov	a,l
	call	@cpdcon

	jmp	@cpexf

	page
;;	@CPDCON - Disconnect a file
;
;	  called by DISCONNECT
;	    also callable by other modules
;
;	Entry: Connect id in A
;
;	Exit: MOSI error code in A, zero set if no error
;
@cpdcon:
	call	valcon	;validate connect id
	mvi	a,ERR3IVCN
	jc	dconx	;error - invalid

	; close file, if open
	lda	mfcb
	ani	MFOPEN
	jz	dconn2
	call	close
	jnz	dconx	;error during close

	; delete file, if temporary
dconn2:
	lda	mfcb
	ani	MFTEMP
	jz	dconn3
	lxi	d,fcb
	syscall	DELFIL

	; release the buffer (ignores errors)
dconn3:
	getw	mfcb+mfcbbfad
	call	@cpfrfb

	; clear flags & restore data
	xra	a
	sta	mfcb
	call	fcpfrw

	;return
	xra	a	;clear A if no error
dconx:
	ora	a	;set zero flag as required
	ret

	page
;;;	CREATE
;
;	Input Parameters:
;		file_name	string		(2 bytes)
;		file_org	integer		(2 bytes)
;		record_org	integer		(2 bytes)
;		record_size	integer		(2 bytes)
;		text_file	flag		(1 byte)
;		initial_size	integer		(2 bytes)
;
;	Output Parameters:
;		connect_id	systemtag	(2 bytes)
;
;	Creates a file with the given name and specified
;	characteristics. The name must be a valid CP/M file
;	name. Device names may not be used.  A file with the
;	specified name must not already exist.
;
;	The file is created with the R/W and non-SYS attributes.
;	The file is placed in the current directory (drive) if no
;	explicit directory is specified. The initial_size
;	parameter is ignored; all files are created with zero
;	size.
;
;	The file is initially connected with the characteristics
;	specified by the input arguments and all possible
;	access controls. When disconnected, some of this
;	information will be lost. CP/M does not retain record or
;	file organization, record size, or text status.  Access 
;	control is reduced to R/W or R/O. When the file is next
;	connected or opened, appropriate characteristics are
;	assumed	(see CONNECT and OPEN).
;
;
cpcreat:
	call	finit3	;initialize, class 3

	getwi	0	;clear return argument
	putwx	@cppba,11

	; find a free FCB
	call	findfcb
	jc	er3insr	; error - no room

	; allocate a buffer
	lda	connid
	call	@cpalfb
	jc	er3insr
	putw	mfcb+mfcbbfad

	; get and validate file organization
	lhld	@cppba
	inx	h
	inx	h
	mov	a,m
	cpi	FORGSEQ	;must be sequential or direct
	jz	creat0
	cpi	FORGDIR
	jnz	er3nso	;not valid
	sta	mfcb+mfcbforg

creat0:
	; get and validate record organization
	inx	h
	inx	h
	mov	a,m
	cpi	RORGMIN
	jc	er3ivro	;not valid
	cpi	RORGMAX+1
	jnc	er3ivro	;not valid
	sta	mfcb+mfcbrorg

	; get and validate record size
	inx	h
	inx	h
	getwx
	cmpwi	0	;must be >= 0
	jc	er3ivro	;not valid
	putw	mfcb+mfcbrsiz

	; get text flag
	getw	@cppba
	lxi	d,8
	dad	d
	mov	a,m
	sta	textflg
	ora	a	; if nontext, var. len. illegal
	jnz	creat2
	lda	mfcb+mfcbrorg
	cpi	RORGVLEN
	jz	er3ivro

	; Get file name, test for null
creat2:
	getwx	@cppba
	putw	fnamp
	mov	a,m
	ora	a
	jnz	creat4	;name is not null

; Null filename; create a temporary file
;
	lxi	d,tname	;copy first temp name
	lxi	h,fcb+1
	mvi	a,11
	call	@cpcopy
	mvi	a,MFTEMP+MFTRUE+MFINUSE	;set flags
	sta	mfcb

	; repeat until unused name found
creat3:
	call	cpmopen	;try to open
	jz	creat5	;not found - ok to use

	lda	fcb+8	;increment low digit
	inr	a
	sta	fcb+8
	cpi	'9'+1
	jc	creat3	;keep trying

	mvi	a,'0'	;overflow
	sta	fcb+8
	lda	fcb+7	;increment high digit
	inr	a
	sta	fcb+7
	cpi	'9'+1
	jc	creat3	;keep trying
	jmp	er3ucre	;names exhausted

; Name was not null - ordinary file
;
creat4:
	call	lkupdev	;is it a device name?
	jnc	er3ucre	;yes - can't create

	; parse file name
	getw	fnamp
	call	parsefn
	jc	er3ivnm	;invalid name

	; Make current disk explicit
	lda	fcb+fcbdrv
	ora	a
	jnz	creat4a
	syscall	GCDSK
	inr	a
	sta	fcb+fcbdrv

	; check for existing file
creat4a:
	call	cpmopen	;try to open
	mvi	a,ERR3DFN
	jnz	@cperr	;duplicate name

	mvi	a,MFTRUE+MFINUSE	;set flags
	sta	mfcb

; Continue processing, temporary or not
;
	; Set access permissions
creat5:
	mvi	a,RWFPERM
	sta	mfcb+mfcbaccn

	; Create the file, if possible
creat6:
	lxi	d,fcb	;try to create
	syscall	MAKFIL
	inr	a
	jz	er3ucre	;failed
	call	cpmopen	;try to open
	jz	er3ucre	;failed

	; Set remaining fields, copy data
	getwi	BLKSIZE
	putw	mfcb+mfcbesiz	;eff. record size = 1 block
	getwi	0
	putw	mfcb+mfcbfsiz	;file size = 0
	lda	textflg		;set text flag
	ora	a
	jz	creat7
	lda	mfcb
	ori	MFTEXT
	sta	mfcb
creat7:
	mvi	a,BLKSIZE-1	;set eof byte
	sta	mfcb+mfeofbyt
	call	fcpfrw		;copy workspace to FCB

	; return output argument
	getw	connid
	putwx	@cppba,11

	jmp	@cpexf

	; temporary file name template
tname:	db	'$$MOSI00$$$'

	page
;;;	EXTEND
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		extend_length	longinteger	(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Checks validity of call, but performs no other action.
;	CP/M files are automatically extended on writes.

cpexten:
	call	finit3	;initialize, class 3

	call	gvalcon	;fetch & validate connect id

	; ensure file is open
	lda	mfcb
	ani	MFOPEN
	jz	er3fno	;file not open

	; check for extend permission
	lda	mfcb+mfcbaccn
	ani	EXTPERM
	jz	er3acdn	;no permission

	jmp	@cpexf

	page
;;;	TRUNCATE
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Checks for permissions, but performs no other action.

cptrunc:
	call	finit3	;initialize, class 3

	call	gvalcon	;fetch & validate connect id
	jc	er3ivcn	;error - invalid

	; ensure file is open
	lda	mfcb
	ani	MFOPEN
	jz	er3fno	;file is not open

	; check for (write) permission
	lda	mfcb+mfcbaccn
	ani	WRPERM
	jz	er3acdn	;no permission

	jmp	@cpexf

	page
;;;	OPEN
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		access_permission integer	(2 bytes)
;		access_method	integer		(2 bytes)
;		expected_record_size integer	(2 bytes)
;		text_file	flag		(1 byte)
;
;	Output Parameters:
;		record_size	integer		(2 bytes)
;		efficient_size	integer		(2 bytes)
;
;	Opens a connected file.  The specified record size is
;	accepted, since CP/M files have no permanent record size.
;	If this size is zero, record organization is assumed to
;	be variable length; in this case the file must be a
;	textfile.  Other attributes are set as specified.

cpopen:
	call	finit3	;initialize, class 3

	getwi	0	;clear return arguments
	putwx	@cppba,9
	getwi	0
	putwx	@cppba,11

	call	gvalcon	;fetch & validate connect id
	jc	er3ivcn	;error - invalid

	; ensure file not open
	lda	mfcb
	ani	MFOPEN
	mvi	a,ERR3FAO	;file already open
	jnz	@cperr

	; Fetch & validate input arguments
	lhld	@cppba
	inx	h
	inx	h
	lda	mfcb+mfcbaccn	;compare access control
	cma
	ana	m
	jnz	er3acdn		;not consistent
	mov	a,m
	sta	mfcb+mfcbacpm	;ok - save it
	inx	h
	inx	h
	mov	a,m	;access method
	sta	mfcb+mfcbacmt
	cpi	ACMTMIN
	jc	er3acdn
	cpi	ACMTMAX+1
	jnc	er3acdn
	inx	h
	inx	h
	getwx		;record size
	cmpwi	0
	jc	er3acdn	;must be >=0
	putw	mfcb+mfcbrsiz
	getwx	@cppba,8
	mov	a,l
	sta	textflg

	; adjust other file data
	lda	mfcb+mfcbacmt
	cpi	ACMTSTRM ;is access method stream?
	jnz	open2	;no
	mvi	a,RORGSTRM ;yes - set record org to stream
	sta	mfcb+mfcbrorg
	getwi	1	;and record size to 1
	putw	mfcb+mfcbrsiz
	jmp	open3

open2:
	getw	mfcb+mfcbrsiz	;is record size 0?
	cmpwi	0
	jnz	open2a		;no
	lda	textflg		;yes - textfile?
	ora	a
	jz	er3acdn		;no - illegal
	mvi	a,RORGVLEN
	sta	mfcb+mfcbrorg	;yes - set rec. org. to var.
	jmp	open3
open2a:
	mvi	a,RORGFLEN ;set record org to fixed length
	sta	mfcb+mfcbrorg

	; initialize MFCB open file data
open3:
	getwi	0
	putw	mfcb+mfcbrecn	;MOSI record no. (4 bytes)
	putw	mfcb+mfcbrecn+2
	xra	a
	sta	mfcb+mfcbcpos	;MOSI buffer position

	; if device, exclude direct access
	lda	mfcb
	ani	MFTRUE
	jnz	open4	;not a device
	lda	mfcb+mfcbacmt
	cpi	ACMTDIR
	jz	er3acdn	;direct access - illegal
	jmp	open5	;otherwise continue

	; if not device, open if we can
open4:
	call	cpmopen
	jz	er3insr	;failed

	; if textfile, find eofbyte
	mvi	a,BLKSIZE-1
	sta	mfcb+mfeofbyt
	lda	textflg
	ora	a
	jz	open4b	;not a textfile
	getw	mfcb+mfcbfsiz
	cmpwi	0
	jz	open4b	;skip if file empty
	dcx	h
	putw	fcb+fcbblkn
	call	bread	;read the last block
	call	seteofb ;set eof byte

open4b:
	getwi	0	;restore start block no.
	putw	fcb+fcbblkn

	; set flags, copy data
open5:
	lda	mfcb
	ani	not (MFEOF + MFBVAL + MFBMOD)
	ori	MFOPEN
	sta	mfcb
	lda	textflg	;set textfile flag
	ora	a
	jz	open6
	lda	mfcb
	ori	MFTEXT
	sta	mfcb
open6:
	call	fcpfrw	;copy workspace to FCB

	;return output arguments
	getw	mfcb+mfcbrsiz
	putwx	@cppba,9	;record size
	getw	mfcb+mfcbesiz
	putwx	@cppba,11	;efficient size

	jmp	@cpexf

	page
;;;	CLOSE
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;
;	Output Parameters:
;		(none)

cpclose:
	call	finit3	;initialize, class 3

	call	gvalcon	;fetch & validate connect id
	jc	er3ivcn	;error - invalid

	; ensure file is open
	lda	mfcb
	ani	MFOPEN
	jz	er3fno

	call	close	;close the file
	jnz	@cperr	;error during close
	call	fcpfrw	;copy in data

	jmp	@cpexf

	page
;;	CLOSE - Close a file
;
;	   called by various routines in sfio
;
;	ENTRY: FCB-MFCB in workspace
;
;	EXIT: MOSI error code in A, zero set if no error
;	      FCB-MFCB still in workspace
;
close:
	; test for device
	lda	mfcb
	ani	MFTRUE
	jz	close1

	; true file - flush buffer, do CP/M close
	call	bflush
	jnz	closex	;error on flush
	lxi	d,fcb	;close
	syscall	CLSFIL

	; adjust mfcb info
close1:
	getwi	1	;reset to stream
	putw	mfcb+mfcbrsiz
	mvi	a,RORGSTRM
	sta	mfcb+mfcbrorg
	lda	mfcb
	ani	not (MFOPEN+MFBVAL+MFBMOD+MFEOF)
	sta	mfcb
	xra	a	;signal no error

closex:
	ora	a	;test A
	ret

	page
;;;	READ
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		data		storageid	(2 bytes)
;		data_length	integer		(2 bytes)
;
;	Output Parameters:
;		amount		integer		(2 bytes)
;
;	Read from the specified file, or from the devices CON:,
;	TRM:, or RDR:.  Devices and files may be read in stream
;	mode or in sequential record, with fixed length record
;	size as specified by OPEN.  True files with fixed length
;	records may also be read in direct access mode.
;
;	Devices and files with text attribute may be read as
;	variable length records (lines).  In this case Return
;	is ignored, and Linefeed is ignored but ends the record.
;	The input record size is limited to 255 bytes.
;
;	Any attempt to read past end of file sets the eof flag
;	and returns no data, in sequential modes.  Reading a
;	record that was never written but is not past the end
;	of the file will produce no error and return a record
;	filled with zeroes.  A true read failure will produce
;	a BDOS error and system halt which is not controllable
;	by the MOSI interface.

cpread:
	call	finit3	;initialize, class 3

	getwi	0	; clear return argument
	putwx	@cppba,6

	;fetch & validate connect id
	call	gvalcon
	jc	er3ivcn	;error - invalid

	; ensure file is open
	lda	mfcb
	ani	MFOPEN
	jz	er3fno	;file not open

	; check permission
	lda	mfcb+mfcbacpm
	ani	RDPERM
	jz	er3acdn	;no permission

	;fetch input arguments
	getwx	@cppba,2
	putw	abptr	;application buffer ptr
	getwx	@cppba,4
	putw	rwnrec	;amount requested (fix len or strm)
	lda	mfcb+mfcbrorg
	cpi	RORGVLEN	;var. len?
	jnz	read00
	getwi	VRSZMAX	;yes - set transfer limit
	putw	rwnrec

	;initialize transfer count
read00:
	getwi	0
	putw	amtxfr

	; determine record length for transfers
	getwi	1	;assume 1
	lda	mfcb+mfcbrorg
	cpi	RORGFLEN ;fixed length records?
	jnz	read01
	getw	mfcb+mfcbrsiz	;yes - get size
read01:
	putw	rwrlen	;save it

	; setup control variables (for files)
	call	rwsetp

	; test for end of file, if sequential
	lda	mfcb+mfcbacmt	;check access method
	cpi	ACMTDIR
	jz	readbor	;skip check if direct
	lda	mfcb
	ani	MFEOF
	jnz	readeof	;at eof

	; repeat for each record
readbor:
	; test for completion, reset counter
	getw	rwnrec	;all records transferred?
	cmpwi	0
	jz	readx	;yes - exit
	dcx	h
	putw	rwnrec	;no - update count
	getw	rwrlen
	putw	rwbrem	;reset byte count

	; repeat for each byte
readbob:
	getw	rwbrem	;record complete?
	cmpwi	0
	jz	readeor	;yes
	dcx	h
	putw	rwbrem	;no - update count
readbb1:
	call rdbyte	;read a byte
	jc	readeof	;exit if end of file
	sta	rwbyte
	lda	mfcb	;if text, check for eof
	ani	MFTEXT
	jz	read02	;non text
	lda	rwbyte
	cpi	CTRLZ
	jz	readeof	;text - CTRL-Z means end of file
read02:
	lda	mfcb+mfcbrorg	;if reading text lines,
	cpi	RORGVLEN	;don't store LF
	jnz	read03
	lda	rwbyte
	cpi	LF
	jz	readeob
read03:
	getw	abptr
	lda	rwbyte
	mov	m,a	;store char in application buffer
	inx	h
	putw	abptr

	; end of byte processing
readeob:
	call	rdckbuf	;cleanup after file read
	lda	mfcb+mfcbrorg
	cpi	RORGVLEN	;reading text by lines?
	jnz	readbob
	lda	rwbyte
	cpi	LF	;yes - end transfer on LF
	jnz	readbob
	getw	abptr	;is preceding char CR?
	dcx	h
	mov	a,m
	cpi	CR
	jnz	readx	;no - retain it
	getw	amtxfr	;yes - reduce count
	dcx	h
	putw	amtxfr
	jmp	readx

	; record done
readeor:
	getw	amtxfr	;increment transfer count
	inx	h
	putw	amtxfr

	; if not var. len, increment record num.
	lda	mfcb+mfcbrorg
	cpi	RORGVLEN
	jz	readbor
	lxi	h,mfcb+mfcbrecn
	call	inc32
	jmp	readbor

; End of file reached
;
readeof:
	getw	amtxfr
	cmpwi	0	;anything transferred?
	jnz	readx
	getwi	-1	;if not, return -1
	putw	amtxfr

; End of read process
;
readx:
	; update position if file
	lda	mfcb
	ani	MFTRUE
	jz	readx1
	lda	rwbufc
	mov	c,a
	mvi	a,BLKSIZE
	sub	c
	sta	mfcb+mfcbcpos

	; copy back data from workspace
readx1:
	call	fcpfrw

	;return output argument
	getw	amtxfr
	putwx	@cppba,6

	jmp	@cpexf

	page
;;	RDBYTE - Read a byte from input source
;
;	  reads one byte from file or selected device
;
;	Exit: input byte in A
;	      carry set if end of file
;
rdbyte:
	lda	mfcb	;file or device?
	ani	MFTRUE
	jz	readdv	;device

; read from a file
;
	; check buffer, fill if needed
	lda	mfcb
	ani	MFBVAL
	jnz	rdbyf2	;buffer is ok
	call	bread	;read to the buffer
	lda	mfcb	;test end of file
	ani	MFEOF
	jnz	cret	;at end of file
	call	rwsetp	;reset buffer variables
rdbyf2:
	getw	rwbufp	;get next byte
	mov	c,m
	inx	h	;reset buffer pointer
	putw	rwbufp
	lda	rwbufc	;decrement buffer count
	dcr	a
	sta	rwbufc
	mov	a,c
	jmp	ncret	;normal return

;  Read from a device
;
readdv:
	lda	fcb+fcbdrv	;get device code
	add	a
	mov	c,a
	mvi	b,0
	lxi	h,rdevtbl-2	;set table index
	dad	b
	getwx		;get routine address
	pchl		;go


;;	Device read transfer table
rdevtbl:
	dw	readcon	;CON
	dw	er3acdn	;LST - illegal
	dw	readrdr	;RDR
	dw	er3acdn	;PUN - illegal
	dw	readtrm	;TRM

;;	Read from the reader
;
readrdr:
	syscall	RDRIN
	jmp	ncret

;;	Read from the terminal (direct)
;
readtrm:
	mvi	e,0FFh
	syscall	DCONIO
	ora	a
	jz	readtrm
	jmp	ncret

;;	Read from the terminal (buffered lines)
readcon:
	; is buffer empty?
	lda	mfcb+mfcbcpos
	ora	a
	jnz	readc1	;no

	; read a text line to buffer
	getw	mfcb+mfcbbfad
	mvi	m,BLKSIZE-3	;set max count
	xchg		;buffer addr to DE
	syscall	RDCONB	;read a line from terminal
	mvi	e,LF	;echo LF
	syscall	DCONIO
	getw	mfcb+mfcbbfad	;find end position
	inx	h
	mov	e,m
	mvi	d,0
	dad	d
	inx	h
	mvi	m,LF	;insert linefeed
	mvi	a,2	;init buffer position
	sta	mfcb+mfcbcpos

readc1:
	; fetch next char from buffer
	getw	mfcb+mfcbbfad
	lda	mfcb+mfcbcpos	;find position
	mov	e,a
	mvi	d,0
	dad	d
	inr	a
	sta	mfcb+mfcbcpos	;update position
	mov	a,m	;get char to A
	cpi	LF	;is it linefeed?
	jnz	readc2	;no
	xra	a	;yes - setup for new buffer
	sta	mfcb+mfcbcpos
	mov	a,m
readc2:
	jmp	ncret

	page
;;	RDCKBUF - Cleanup after byte processing
;
rdckbuf:
	; test for device
	lda	mfcb
	ani	MFTRUE
	jz	rdckbx	;device - exit

	; file. test buffer count
	lda	rwbufc
	ora	a
	jnz	rdckbx	;not empty

	; file buffer empty; setup for refill
	lda	mfcb
	ani	not MFBVAL
	sta	mfcb
	call	bflush	;flush in case modified
	jnz	@cperr	;error during flush
	getw	fcb+fcbblkn	;select next CPM block
	inx	h
	putw	fcb+fcbblkn
	xra	a
	sta	mfcb+mfcbcpos	;reset relative buffer pointer
	mvi	a,BLKSIZE
	sta	rwbufc
rdckbx:
	ret

	page
;;	WRITE
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		data		storageid	(2 bytes)
;		data_length	integer		(2 bytes)
;
;	Output Parameters:
;		amount		integer		(2 bytes)
;
;	Writes the specified amount of data to a file or to the
;	devices CON:, TRM:, LST:, or PUN:.  The file or device
;	must be	open with write permission.  File transfers are
;	buffered, and the final block may not be written until
;	the file is CLOSEd.  Device transfers proceed byte by
;	byte.
;
;	Output to devices and files may be in stream mode or
;	sequential record mode, with fixed length records whose
;	size is specified by OPEN. For text files or devices,
;	output may also be in variable length records, which
;	will be automatically terminated with CR-LF.
;	Output to files may also be in direct access mode,
;	in which case the fixed length records may be written
;	in any order.
;
;	If a write request would increase the file size, the
;	file must be open with EXTEND permission as well as WRITE
;	permission.  However, no explicit call to EXTEND is
;	necessary.
;
;	In some cases, a write request requires a read of the
;	appropriate block.  Any actual read or write failure
;	will result in a BDOS error and program halt which is
;	not under the control of the MOSI interface.
;
cpwrite:
	call	finit3	;initialize, class 3

	nop
	nop
	getwi	0	;clear return argument
	putwx	@cppba,6

	; fetch & validate connect id
	call	gvalcon
	jc	er3ivcn	;error - invalid

	; ensure that file is open
	lda	mfcb
	ani	MFOPEN
	jz	er3fno	;error - not open

	; check for write permission
	lda	mfcb+mfcbacpm
	ani	WRPERM
	jz	er3acdn	;no permission

	; get arguments
	getwx	@cppba,2
	putw	abptr	;application buffer
	getwx	@cppba,4
	putw	rwnrec	;amount requested

	;initialize transfer count
	getwi	0
	putw	amtxfr

	; determine record length for transfers
	getwi	1	;assume 1
	lda	mfcb+mfcbrorg
	cpi	RORGFLEN ;fixed length records?
	jnz	write01
	getw	mfcb+mfcbrsiz	;yes - get size
write01:
	putw	rwrlen	;save it

	; setup buffer index & count (files only)
	call	rwsetp

	; repeat for each record
writbor:
	; test for completion, reset counter
	getw	rwnrec	;all records transferred?
	cmpwi	0
	jz	writex	;yes - done
	dcx	h
	putw	rwnrec	;no - update count
	getw	rwrlen
	putw	rwbrem	;reset byte count

	; repeat for each byte
writbob:
	getw	rwbrem	;record complete?
	cmpwi	0
	jz	writeor	;yes
	dcx	h
	putw	rwbrem	;no - update count

	; fetch and output next byte
	getw	abptr
	mov	a,m
	inx	h
	putw	abptr
	call	wrbyte
	jmp	writbob	;on to next byte

	; process end of record
writeor:
	getw	amtxfr	;increment transfer count
	inx	h
	putw	amtxfr
	lda	mfcb+mfcbrorg	; var. length?
	cpi	RORGVLEN
	jz	writbor
	lxi	h,mfcb+mfcbrecn ;no - update rec. num.
	call	inc32
	jmp	writbor

	; transfer complete
writex:
	; if writing text lines, end with CR-LF
	lda	mfcb+mfcbrorg
	cpi	RORGVLEN
	jnz	writex1
	mvi	a,CR
	call	wrbyte
	mvi	a,LF
	call	wrbyte

writex1:
	; update buffer position
	lda	rwbufc
	mov	c,a
	mvi	a,BLKSIZE
	sub	c
	sta	mfcb+mfcbcpos

	; update eof byte, if required
	lda	mfcb	;check for text file
	ani	MFTEXT
	jz	writex2	;not text
	getw	fcb+fcbblkn	;in last block?
	cmpw	mfcb+mfcbfsiz
	jnz	writex2	;no
	call	seteofb	;yes - set eof byte

writex2:
	call	fcpfrw	;copy workspace to FCB

	getw	amtxfr	;return result
	putwx	@cppba,6

	jmp	@cpexf	;return

	page
;;	WRBYTE - Write a byte to output destination
;
;	Entry: byte to write in A
;
wrbyte:
	sta	rwbyte	;save byte

	; test for device
	lda	mfcb
	ani	MFTRUE
	jz	writedv	;write to device

	; check if buffer is valid
	lda	mfcb
	ani	MFBVAL
	jnz	write5

	; not valid. Is extend required?
	getw	fcb+fcbblkn
	cmpw	mfcb+mfcbfsiz
	jc	write3  ;no extend needed

	; extend needed.  Check permission
	lda	mfcb+mfcbacpm
	ani	EXTPERM
	jz	er3acdn	;no permission

	; Update file size
	getw	fcb+fcbblkn
	inx	h
	putw	mfcb+mfcbfsiz

	; initialize buffer
	lda	mfcb
	ani	MFTEXT
	mvi	a,CTRLZ	;if text, fill with CTRL-Z
	jnz	write2a
	xra	a	;if nontext, fill with nulls
write2a:
	call	bfill
	jmp	write4

	; not extending. Read existing block.
write3:
	call	bread

	; initialize block control info
write4:
	lda	mfcb
	ori	MFBVAL+MFBMOD
	sta	mfcb
	call	rwsetp	;reset buffer variables

	; store the byte
write5:
	getw	rwbufp	;insert the byte
	lda	rwbyte
	mov	m,a
	inx	h
	putw	rwbufp
	lda	mfcb	;flag buffer as modified
	ori	MFBMOD
	sta	mfcb
	lda	rwbufc	;adjust byte counter
	dcr	a
	sta	rwbufc
	jnz	write6	;continue unless buffer full

	; buffer full; write & reset
	call	bflush
	jnz	@cperr	;error during flush
	getw	fcb+fcbblkn	;select next block
	inx	h
	putw	fcb+fcbblkn
	xra	a	;reset count
	sta	mfcb+mfcbcpos
	mvi	a,BLKSIZE
	sta	rwbufc
	lda	mfcb
	ani	not MFBVAL
	sta	mfcb

write6:
	ret	;return

;  Write to a Device
;
	; get transfer address from table
writedv:
	lda	fcb+fcbdrv
	add	a
	mov	c,a
	mvi	b,0
	lxi	h,wdevtbl-2
	dad	b
	getwx
	pchl	; go to device routine

;   Device write transfer table
wdevtbl:
	dw	writcon	;CON
	dw	writlst	;LST
	dw	er3acdn	;RDR - illegal
	dw	writpun	;PUN
	dw	writtrm	;TRM

;    Device routine entry points
writcon:
	mvi	c,CONOUT	;CON
	jmp	writdev
writlst:
	mvi	c,LSTOUT	;LST
	jmp	writdev
writpun:
	mvi	c,PUNOUT	;PUN
	jmp	writdev
writtrm:
	mvi	c,DCONIO	;TRM

;; General output routine for devices
;
writdev:
	lda	rwbyte
	mov	e,a
	call	BDOS	;system call
	ret

	page
;;	SEEK
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		seek_origin	integer		(2 bytes)
;		seek_forward	flag		(1 byte)
;		seek_record	long integer	(4 bytes)
;
;	Output Parameters:
;		current-position long integer	(4 bytes)
;
;	Seek to specified record, from specified origin,
;	in specified direction.  In files open for sequential
;	access modes, seeks may be forward only and not past the
;	end-of-file position.  Seek on a device is permitted
;	to end-of-file only.
;
;	On devices and variable-length record (text) files,
;	seek is permitted to end of file only. For devices this
;	causes no action.  The current position is returned as
;	zero and is meaningless.  
;
;	A seek may cause the current buffer to be written if it
;	has been modified.  A seek past the end of file will not
;	invoke a check for EXTEND permission, but a subsequent
;	WRITE may fail if the permission is not	present.
;
cpseek:
	call	finit3	;initialize, class 3

	; clear return arguments
	getwi	0
	putwx	@cppba,9
	getwi	0
	putwx	@cppba,11

	; fetch and validate connect id
	call	gvalcon
	jc	er3ivcn	;error - invalid

	;ensure file is open
	lda	mfcb
	ani	MFOPEN
	jz	er3fno	;not open

	; get origin, check range
	getwx	@cppba,2
	putw	seekorg
	cmpwi	SORGMIN
	jc	er3ivmd
	cmpwi	SORGMAX+1
	jnc	er3ivmd

	; get seek-forward flag
	getw	@cppba
	lxi	d,4
	dad	d
	mov	a,m
	sta	skfwd

	; get specified new position in records
	getwx	@cppba,5
	putw	newpos
	getwx	@cppba,7
	putw	newpos+2

	; convert to bytes, and adjust sign, if not VL records.
	; for VL records, the only allowed input value
	; is newpos=0.
	getw 	mfcb+mfcbrsiz
	cmpwi	0
	jz	seek0
	lxi	d,newpos
	call	mul32
	lda	skfwd	;negate if seek backward
	ora	a
	jnz	seek0
	lxi	h,newpos
	call	neg32

	; get current position in bytes
	;  (meaningless but not used if VL records)
seek0:
	getw	mfcb+mfcbrecn
	putw	curpos
	getwi	0
	putw	curpos+2
	getw	mfcb+mfcbrsiz
	lxi	d,curpos
	call	mul32


	; determine if seek is to eof position
	call	findeof	;find eof pos'n in bytes
	xra	a
	mov	c,a
	getw	seekorg
	cmpwi	SORGEOF
	jnz	seek1
	getw	newpos
	cmpwi	0
	jnz	seek1
	getw	newpos+2
	cmpwi	0
	jnz	seek1
	inr	c	;c=1 if seeking eof

seek1:
	; check for device
	lda	mfcb
	ani	MFTRUE
	jnz	seek1a	;not a device
	mov	a,c
	ora	a
	jz	er3skns	;error - not eof
	jmp	seekx	;eof - ignore & return

seek1a:
	; check for variable length records
	lda	mfcb+mfcbrorg
	cpi	RORGVLEN
	jnz	seek1b	;not variable length
	mov	a,c
	ora	a
	jz	er3skns	;error - not eof

	; check seek origin
seek1b:
	lda	seekorg
	cpi	SORGBOF
	jz	seek3	;origin is start of file

	; add relative position to origin
	cpi	SORGEOF
	lxi	h,eofpos
	jz	seek2
	lxi	h,curpos
seek2:
	lxi	d,newpos
	call	add32

	; validate desired position
seek3:
	lda	newpos+3
	ora	a
	jm	er3ofb	;position negative
	lda	mfcb+mfcbacmt
	cpi	ACMTDIR	;direct access?
	jz	seek4	;yes
	lxi	h,newpos	;sequential or stream
	lxi	d,curpos
	call	cmp32
	jc	er3skns  ;error - backwards seek
	lxi	h,eofpos
	lxi	d,newpos
	call	cmp32
	jc	er3ofb	;error - beyond eof

	; check for extend permission, if needed
seek4:
	lda	mfcb+mfcbacpm
	ani	EXTPERM
	jnz	seek5	;permission ok
	lxi	h,newpos
	lxi	d,eofpos
	call	cmp32
	jnc	er3ofb	;extending but no permission

	; determine desired block
seek5:
	lda	newpos
	ral
	lda	newpos+1
	adc	a
	mov	l,a
	lda	newpos+2
	adc	a
	mov	h,a
	putw	newblk
	cmpw	fcb+fcbblkn
	jz	seek6	;already there

	; seek to new block
	call	bflush
	jnz	@cperr	;error during flush
	lda	mfcb
	ani	not MFBVAL
	sta	mfcb
	getw	newblk
	putw	fcb+fcbblkn

	; update cur. position & rec. number
seek6:
	lda	newpos
	ani	7Fh
	sta	mfcb+mfcbcpos
	lda	mfcb+mfcbrorg
	cpi	RORGVLEN	;var. length records?
	jz	seek7	;yes - skip recnum update
	getw	newpos
	putw	mfcb+mfcbrecn
	getw	newpos+2
	putw	mfcb+mfcbrecn+2
	lxi	d,mfcb+mfcbrecn	;position in bytes
	getw	mfcb+mfcbrsiz	;divide by record size
	call	div32

	; adjust eof flag
seek7:
	lda	mfcb	;clear eof flag
	ani	not MFEOF
	sta	mfcb
	lxi	h,newpos	;test position
	lxi	d,eofpos
	call	cmp32
	jc	seekx	;not at eof
	lda	mfcb
	ori	MFEOF	;set eof flag
	sta	mfcb

seekx:
	call	fcpfrw	;copy workspace to FCB

	;return output argument
	getw	mfcb+mfcbrecn
	putwx	@cppba,9
	getw	mfcb+mfcbrecn+2
	putwx	@cppba,11

	jmp	@cpexf	;return

	page
;;;	GET_FILE_INFORMATION
;
;	Input Parameters:
;		connect_id	integer		(2 bytes)
;
;	Output Parameters:
;		file_name	string		(2 bytes)
;		open_flag	flag		(1 byte)
;		temporary_file	flag		(1 byte)
;		text_file	flag		(1 byte)
;		record_size	integer		(2 bytes)
;		record_org	integer		(2 bytes)
;		file_length	long integer	(4 bytes)
;		current_position long integer	(4 bytes)
;		efficient_size	integer		(2 bytes)
;		access_permission integer	(2 bytes)
;		access_method	integer		(2 bytes)
;		file_org	integer		(2 bytes)
;		create_time	long integer	(4 bytes)
;		create_date	integer		(2 bytes)
;		last_modified_time long integer (4 bytes)
;		last_modified_date integer	(2 bytes)
;		last_access_time long integer	(4 bytes)
;		last_access_date integer	(2 bytes)

cpgfinf:
	call	finit3	;initialize, class 3

	; initialize info block
	mvi	c,FINFSZ
	lxi	h,finfo
	xra	a
	sta	fnbuf
gfinf0:
	mov	m,a
	inx	h
	dcr	c
	jnz	gfinf0
	lxi	h,fnbuf
	putw	finfo

	; copy info block to output args
	lxi	d,finfo
	lhld	@cppba
	inx	h
	inx	h
	mvi	a,FINFSZ
	call	@cpcopy

	call	gvalcon	;fetch & validate connect id
	jc	er3ivcn	;error - invalid

	call	buildfn  ;build file name

	; process OPEN flag
	lda	mfcb
	ani	MFOPEN
	mvi	a,0
	jz	gfinf1
	inr	a
gfinf1:
	sta	finfo+2

	; process TEMP flag
	lda	mfcb
	ani	MFTEMP
	mvi	a,0
	jz	gfinf2
	inr	a
gfinf2:
	sta	finfo+3

	; process TEXT flag
	lda	mfcb
	ani	MFTEXT
	mvi	a,0
	jz	gfinf3
	inr	a
gfinf3:
	sta	finfo+4

	; determine file size in records
	call	findeof	;find eof pos in bytes (= file size)
	getw	mfcb+mfcbrsiz	;get record size to HL
	lda	mfcb+mfcbrorg	;check record org
	cpi	RORGFLEN
	jz	gfinf3a
	getwi	1		;if not fixed len, size=1
gfinf3a:
	lxi	d,eofpos	;divide file size by rec size
	call	div32		;result in eofpos

	; copy permanent file data to info block
	getw	mfcb+mfcbrsiz	;record size
	putw	finfo+5
	lda	mfcb+mfcbrorg	;record organization
	sta	finfo+7
	getw	eofpos		;file size
	putw	finfo+9
	getw	eofpos+2
	putw	finfo+11
	getw	mfcb+mfcbesiz	;efficient size
	putw	finfo+17
	lda	mfcb+mfcbforg	;file organization
	sta	finfo+23

	; copy additional data only if file is open
	lda	mfcb
	ani	MFOPEN
	jz	gfinf4
	getw	mfcb+mfcbrecn	;current record number
	putw	finfo+13
	getw	mfcb+mfcbrecn+2
	putw	finfo+15
	lda	mfcb+mfcbacpm	;access permission requested
	sta	finfo+19
	lda	mfcb+mfcbacmt	;access method
	sta	finfo+21

	; copy info block to output arguments
gfinf4:
	lxi	d,finfo
	lhld	@cppba
	inx	h
	inx	h
	mvi	a,FINFSZ
	call	@cpcopy

	jmp	@cpexf

	page
;;	GET_ACCESS_CONTROL
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		identity	systemtag	(2 bytes)
;
;	Output Parameters:
;		access_control	integer		(2 bytes)
;
;	Returns the permanent access control for the file.  Valid
;	identity codes are 0 (current user) and -1 (public).
;	However, the same access information is returned for both
;	categories.

cpgtacc:
	call	finit3	;initialize, class 3

	getwi	0	;clear return argument
	putwx	@cppba,4

	call	gvalcon	;fetch & validate connect id
	jc	er3ivcn	;error - invalid

	; get identity, check range
	getwx	@cppba,2
	cmpwi	-1
	jm	er3ivid
	cmpwi	1
	jp	er3ivid

	; return permanent access control
	lda	mfcb+mfcbaccn
	mov	l,a
	mvi	h,0
	putwx	@cppba,4

	jmp	@cpexf	;return

	page
;;	CHANGE_ACCESS_CONTROL
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		identity	systemtag	(2 bytes)
;		access_control	integer		(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Sets the specified access_control.  Valid identities are 0 (current
;	user) and -1 (public user).  However, since a CP/M file has no
;	provision for varying access control according to user, a call
;	specifying the public user is ignored.  A call specifying the
;	current user establishes new permanent access control for the
;	file.  It is assummed that this will not be more restrictive
;	than that requested for the public user.
;
;	The access control is checked for consistency with the device or
;	file type.  The caller must have CHANGE ACCESS permission.
;	The file's read-only status is set to reflect the new controls.

cpchacc:
	call	finit3	;initialize, class 3

	call	gvalcon	;fetch and validate connect id
	jc	er3ivcn	;error - invalid

	; fetch & validate identity code
	getwx	@cppba,2
	cmpwi	-1
	jm	er3ivid
	cmpwi	1
	jp	er3ivid
	putw	ident

	;check for CHANGE ACCESS permission
	lda	mfcb+mfcbaccn
	ani	CHAPERM
	jz	er3acdn

	; get requested control, see if allowed
	lda	mfcb
	ani	MFTRUE
	mvi	a,RWFPERM	;true file controls
	jnz	chacc1	;if true file
	lxi	h,devacc
	lda	fcb+fcbdrv
	mov	e,a
	mvi	d,0
	dad	d
	mov	a,m
chacc1:
	getwx	@cppba,4	;get requested control
	cma
	ana	l
	jnz	er3ivac	;not valid
	mov	a,l
	sta	acctrl	;save it
	ani	CHAPERM+DELPERM
	jz	er3ivac	;must allow change or delete

	; test identity
	lda	ident
	ora	a
	jnz	chacc4	;public user - ignore

	; modify file access control
	lda	acctrl
	sta	mfcb+mfcbaccn
	ani	MODPERM		;setup R/O bit
	lda	fcb+fcbftyp
	jnz	chacc2
	ori	ROFLAG		;set R/O
	jmp	chacc3
chacc2:
	ani	7Fh		;set R/W
chacc3:
	sta	fcb+fcbftyp	;restore flag
	lxi	d,fcb		;set in directory
	syscall	SETFA

chacc4:
	call	fcpfrw	;copy out fcb
	jmp	@cpexf	;return

	page
;;	DELETE
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;
;	Output Parameters:
;		(none)

cpdelet:
	call	finit3	;initialize, class 3

	call	gvalcon	;fetch & validate connect id
	jc	er3ivcn	;error - invalid

	; check for delete permission
	lda	mfcb+mfcbaccn
	ani	DELPERM
	jz	er3acdn	;no permission

	; flag as temporary to force delete
	lda	mfcb
	ori	MFTEMP
	sta	mfcb
	call	fcpfrw

	; call @cpdcon to do the work
	lda	connid
	call	@cpdcon
	jnz	@cperr

	jmp	@cpexf	;return

	page
;;	RENAME
;
;	Input Parameters:
;		connect_id	systemtag	(2 bytes)
;		new_name	string		(2 bytes)
;
;	Output Parameters:
;		(none)

cprenam:
	call	finit3	;initialize, class 3

	call	gvalcon	;fetch & validate connect_id
	jc	er3ivcn	;error - invalid

	; copy current name to oldname buffer
	lxi	d,fcb
	lxi	h,oldname
	mvi	a,FNAMLEN
	call	@cpcopy

	; fetch & parse new file name
	getwx	@cppba,2
	putw	fnamp
	call	parsefn
	jc	er3ivnm	;invalid name

	; be sure it's a real file
	lda	mfcb
	ani	MFTRUE
	jz	er3acdn	;device - can't rename

	; check for write permission
	lda	mfcb+mfcbaccn
	ani	WRPERM
	jz	er3acdn

	; check new drive same as old, if given
	lda	fcb+fcbdrv
	ora	a
	jz	renam1
	mov	c,a
	lda	oldname
	cmp	c
	jnz	er3fnr	;error - different drive

	; setup for open
renam1:
	lda	oldname	;ensure drive code set
	sta	fcb+fcbdrv

	; check for new name already in use
	call	cpmopen
	jnz	er3fex

	; all ok - rename file
	lxi	d,oldname
	syscall	RENFIL
	inr	a
	jz	er3fnr	;operation failed

	; copy name (only) to actual fcb
	lxi	d,fcb
	lhld	fcba
	mvi	a,FNAMLEN
	call	@cpcopy

	jmp	@cpexf	;return

	page
;;	GET_WORKING_DIRECTORY
;
;	Input Parameters:
;		(none)
;
;	Output Parameters:
;		directory_name	string		(2 bytes)
;
;	Returns the string name of the current working directory,
;	which in CP/M is the current drive.
;

cpgtwkd:
	call	finit3	;initialize, class 3

	syscall	GCDSK	;get disk code
	adi	'A'	;convert to letter
	sta	wdir+1
	mvi	a,':'	;add colon
	sta	wdir+2
	mvi	a,2	;string length = 2
	sta	wdir
	getwi	wdir	;return string as result
	putwx	@cppba

	jmp	@cpexf	;return

	page
;;	CHANGE_WORKING_DIRECTORY
;
;	Input Parameters:
;		directory_name	string		(2 bytes)
;
;	Output Parameters:
;		(none)
;
;	Accepts a drive name of the form "A:" through "P:", and
;	sets its value as the current drive. There is no immediate
;	check that the drive exists.

cpchwkd:
	call	finit3	;initialize, class 3

	getwx	@cppba	;get string address
	mov	a,m
	cpi	2
	jnz	er3nsd	;length must be 2
	inx	h
	mov	c,m	;save presumed drive letter
	inx	h
	mov	a,m
	cpi	':'	;2nd char must be ':'
	jnz	er3nsd
	mov	a,c
	call	valchar	;validate, make upper case
	sui	'A'
	cpi	MAXDRV
	jnc	er3nsd	;too big
	mov	e,a
	lda	CURDSK	;store as current disk
	ani	0F0h
	ora	e
	sta	CURDSK
	syscall	SELDSK	;select it

	jmp	@cpexf	;return

	page
;;	GET_IDENTITY
;
;	Input Parameters:
;		identity_code	integer		(2 bytes)
;
;	Output Parameters:
;		identity	integer		(2 bytes)
;
;	Returns the identity systemtag, which is identical to the
;	identity for 0 (current user) and -1 (public user).  Any other
;	value causes an error.

cpgtidn:
	call	finit3	;initialize, class 3

	getwx	@cppba	;get code
	putwx	@cppba,2	;return as result

	getwx	@cppba
	cmpwi	-1	;test for 0 or -1
	jm	er3ivic
	cmpwi	1
	jp	er3ivic

	jmp	@cpexf	;return

	page
;;;	SUPPORT ROUTINES

;	@CPIFIL: Initialize File Processing

@cpifil:

;  clear MFCB status flags
	mvi	c,MAXFCB
	lxi	h,mfcb+mfcblen ;1st flag addr
	lxi	d,mfcblen ;increment
initf1:
	mvi	m,0	;set flags to zero
	dad	d
	dcr	c
	jnz	initf1
	ret

	page
;	@CPTFIL: Terminate File Processing
;
;	    Check all fcb's, disconnect where necessary

@cptfil:
	; initialize counts
	mvi	c,0
	lxi	h,mfcb
	lxi	d,mfcblen

	; repeat for all fcb's
termf1:
	inr	c
	mov	a,c
	cpi	MAXFCB+1
	jnc	termf2	;all fcb's processed

	; point to next file, check for fcb in use
	dad	d
	mov	a,m
	ani	MFINUSE
	jz	termf1

	; file is connected. Disconnect it.
	push	b
	push	d
	push	h
	mov	a,c
	call	@cpdcon
	pop	h
	pop	d
	pop	b
	jmp	termf1

	;return
termf2:
	ret

	page
;;	FINDFCB: Find a free FCB, if any
;
;	  Locates a free FCB; error if none
;	  Initializes workspace
;
;	Exit: carry set if error
;
findfcb:
	mvi	a,0
	lxi	d,fcb
	lxi	h,mfcb
ffcb1:
	cpi	MAXFCB
	jnc	cret	;not found

	; Update pointers
	inr	a
	sta	connid	;increment id #
	lxi	b,mfcblen	;point to next MFCB
	dad	b
	xchg		;point to next FCB
	lxi	b,fcblen
	dad	b
	xchg

	; Test MFCB in-use flag
	mov	a,m
	ora	a
	lda	connid
	jm	ffcb1	;not free - continue

	; Found a free one
	shld	mfcba
	xchg
	shld	fcba
	lxi	d,blanks	;set file name to blanks
	lxi	h,fcb+1
	mvi	a,11
	call	@cpcopy

	; initialize FCB
	xra	a
	sta	fcb+fcbext
	sta	fcb+fcbrecn
	sta	fcb+fcbs2

	jmp	ncret	;normal return

	page
;;	GVALCON - Fetch & validate connect id
;	VALCON  - Validate a specified connid
;
;	    get connid from first argument (GVALCON)
;	    validate connid
;	    set connid, fcba & mfcba
;	    copy data to workspace
;
;	Exit: carry set if invalid
;
gvalcon:
	; fetch connid, see if valid
	getwx	@cppba
	mov	a,l

;	Enter with id code in A
valcon:
	sta	connid	;save id
	cpi	MAXFCB+1
	jnc	cret	;not valid

	; find fcb and mfcb addresses
	lxi	d,fcb
	lxi	h,mfcb
valcon1:
	lxi	b,mfcblen
	dad	b
	xchg
	lxi	b,fcblen
	dad	b
	xchg
	dcr	a
	jnz	valcon1

	; ensure block is in use
	mov	a,m
	ani	MFINUSE
	jz	cret

	; save pointers
	shld	mfcba
	xchg
	shld	fcba

	; copy blocks to workspace
	call	fcptow

	jmp	ncret	;normal return

	page
;;	LKUPDEV - Lookup name in device table
;
;	  If found, sets device no. in drive code
;
;	Exit: carry set if name not found
;
lkupdev:
	lhld	fnamp
	mov	a,m
	cpi	4
	jnz	cret	;not found
	mvi	a,1
	lxi	d,devtab
lkupdv1:
	push	a	;save name counter
	push	d	;save table pointer
	mvi	b,4
	lhld	fnamp
	inx	h
lkupdv2:
	mov	a,m
	call	valchar
	jc	lkupdv3	;not found yet
	mov	c,a
	ldax	d
	cmp	c
	jnz	lkupdv3	;not found yet
	inx	h
	inx	d
	dcr	b
	jnz	lkupdv2

	; found a match
	pop	d	;recover name pointer
	pop	a	;get count
	sta	fcb+fcbdrv	;save as index
	jmp	ncret	;normal return

	; no match this name
lkupdv3:
	pop	d	;get table pointer
	inx	d	;update it
	inx	d
	inx	d
	inx	d
	pop	a	;get and test count
	cpi	MAXDEV
	jz	cret	;not found
	inr	a
	jmp	lkupdv1	;keep looking

	page
;;	PARSEFN - Parse File Name
;
;	  parses file or device name string
;	  stores result in fcb workspace
;
;	Entry: HL points to count byte of string
;	Exit: carry set if invalid
;
parsefn:
	xra	a	;clear drive code in fcb
	sta	fcb+fcbdrv
	mov	a,m	;get name length
	inx	h
	mov	c,a	;save as count

	; Check for drive name
	cpi	2
	jc	parse2	;too short for drive name
	inx	h
	mov	a,m
	dcx	h
	cpi	':'
	jnz	parse2	;no drive name

	; Found a drive name. process it.
	mov	a,m	;get drive letter
	call	valchar	;make it upper case
	sui	'A'-1	;convert to code
	jz	cret	;0 - not valid
	cpi	MAXDRV+1
	jnc	cret	;too large - not valid
	sta	fcb+fcbdrv	;store it in FCB
	inx	h	;adjust index
	inx	h
	dcr	c	;adjust count
	dcr	c

	; Process file name string
parse2:
	lxi	d,fcb+fcbfnam	;set store index
	mvi	b,8	;set limit count
parse3:
	dcr	c
	jm	ncret	;all done
	mov	a,m
	inx	h
	cpi	'.'
	jz	parse4	;on to filetype
	dcr	b
	jm	cret	;too long - invalid
	call	valchar	;check char, make upper case
	jc	cret	;invalid
	stax	d	;store it
	inx	d
	jmp	parse3	;continue

	; Process file type string
parse4:
	lxi	d,fcb+fcbftyp	;set store index
	mvi	b,3	;set limit count
parse5:
	dcr	c
	jm	ncret	;all done
	dcr	b
	jm	cret	;too long - invalid
	mov	a,m
	inx	h
	call	valchar	;check char, make upper case
	jc	cret	;invalid
	stax	d	;store it
	inx	d
	jmp	parse5

	page
;;  BUILDFN - Build a MOSI string filename from current fcb
;
;	Exit: string is in buffer fnbuf
;
buildfn:
	lxi	d,fnbuf+1	;initialize buffer ptr
	xra	a
	mov	b,a

	; check for device
	lda	mfcb
	ani	MFTRUE
	jz	bldfn2

	; Process drive code
	lda	fcb+fcbdrv
	adi	'A'-1
	call	putfn
	mvi	a,':'
	call	putfn

	; Process file name
bldfn2:
	lxi	h,fcb+fcbfnam
	mvi	c,8
bldfn3:
	mov	a,m
	inx	h
	cpi	' '
	jz	bldfn4
	call	putfn
	dcr	c
	jnz	bldfn3

	;process file type
bldfn4:
	lda	mfcb
	ani	MFTRUE
	jz	bldfn6	;skip if device
	mvi	a,'.'
	call	putfn
	lxi	h,fcb+fcbftyp
	mvi	c,3
bldfn5:
	mov	a,m
	inx	h
	cpi	' '
	jz	bldfn6
	call	putfn
	dcr	c
	jnz	bldfn5

	;complete the string
bldfn6:
	mov	a,b
	sta	fnbuf	;insert count

	ret

putfn:
	stax	d
	inx	d
	inr	b
	ret

	page
;;	CPMOPEN - open a CPM file
;
cpmopen:
	; initialize fcb entries
	xra	a
	sta	fcb+fcbext
	sta	fcb+fcbs2
	sta	fcb+fcbrecn
	sta	fcb+fcbblkn
	sta	fcb+fcbblkn+1
	sta	fcb+fcbblkn+2

	; open the file
	lxi	d,fcb
	syscall	OPNFIL
	inr	a	;set zero flag if error
	ret


;;	SETEOFB - set eofbyte from current buffer

seteofb:
	getw	mfcb+mfcbbfad	;point to end of buffer
	lxi	d,BLKSIZE
	dad	d
	mvi	c,BLKSIZE-1	;initialize counter
seteof1:
	dcx	h	;scan backward for non eof byte
	mov	a,m
	cpi	CTRLZ
	jnz	seteof2	;found the position
	dcr	c
	jnz	seteof1	;quit at beginning
seteof2:
	mov	a,c
	sta	mfcb+mfeofbyt	;save count as byte
	ret

	page
;;	BREAD - Read data to file buffer

bread:

	; check for end of file
	getw	fcb+fcbblkn
	cmpw	mfcb+mfcbfsiz
	jc	bread1
	lda	mfcb	;eof - set flag & exit
	ori	MFEOF
	sta	mfcb
	jmp	breadbob

	; set DMA address & try to read
bread1:
	lhld	mfcb+mfcbbfad
	xchg
	syscall	SETDMA
	lxi	d,fcb
	syscall	RDRAN
	ora	a
	jz	breadbor

	; error. Assume unwritten, return zero data.
	xra	a
	call	bfill

	; reset control variables
breadbor:
	lda	mfcb
	ani	not MFBMOD
	ori	MFBVAL
	sta	mfcb

breadbob:
	ret

	page
;;	BFLUSH - Write buffer if modified
;
;	Exit: MOSI error code in A, zero set if no error
;
bflush:
	; check if buffer is modified
	lda	mfcb
	ani	MFBMOD
	jz	bflushx	;not modified - exit

	; set DMA address
	lhld	mfcb+mfcbbfad
	xchg
	syscall	SETDMA

	; write the current block
	lxi	d,fcb
	syscall	WRRAN
	ora	a
	jz	bflush1	;no error

	; error on write
	cpi	5	; check for disk full code
	mvi	a,ERR3DFUL
	jz	bflushx	;disk full
	mvi	a,ERR3XER
	jmp	bflushx	;transmission error

	; clear modified flag
bflush1:
	lda	mfcb
	ani	not MFBMOD
	sta	mfcb

	xra	a	;no error

	;return
bflushx:
	ora	a	;set flags to sense A
	ret		;return

	page
;;	VALCH - Validate & convert a filename character
;
;	   Checks for printing char, converts to upper case
;	   Further checking is left to CP/M
;
valchar:
	ani	127	;strip high bit
	cpi	33
	jc	valch2	;too small
	cpi	127
	jnc	valch2	;too big
	cpi	'a'
	jc	valch1	;not a lc letter
	cpi	'z'+1
	jnc	valch1
	sui	'a'-'A'	;adjust if lc letter
valch1:
	ora	a	;return without carry
	ret
valch2:
	stc		;return with carry
	ret

	page
;;	BFILL - Fill file buffer with specified byte
;
;	Entry: fill byte in A
;
bfill:
	lhld	mfcb+mfcbbfad
	mvi	c,BLKSIZE
bfill1:
	mov	m,a
	inx	h
	dcr	c
	jnz	bfill1
	ret


;;	RWSETP - Set buffer index & count for read, write

rwsetp:
	getw	mfcb+mfcbbfad
	lda	mfcb+mfcbcpos
	mov	c,a
	mvi	b,0
	dad	b
	putw	rwbufp
	mvi	a,BLKSIZE
	sub	c
	sta	rwbufc
	ret

;;	FINDEOF - determine eof position in bytes

findeof:
	getwi	BLKSIZE	;initalize buffer to block size
	putw	eofpos
	getwi	0
	putw	eofpos+2
	getw	mfcb+mfcbfsiz	;multiply by file size in blocks
	lxi	d,eofpos
	call	mul32
	lda	mfcb+mfeofbyt	;adjust for eof byte
	mov	c,a
	mvi	a,BLKSIZE-1
	sub	c
	sta	ltemp
	xra	a
	sta	ltemp+1
	sta	ltemp+2
	sta	ltemp+3
	lxi	d,eofpos
	lxi	h,ltemp
	call	sub32	;subtract bytes to be ignored
	ret

	page
;;	MUL32 - Specialized unsigned 32-bit multiply
;
;	Entry:
;		DE - addr of 4-byte multiplicand
;		HL - value of 2-byte multiplier
;	Exit:
;		unsigned product replaces multiplicand
;		overflow ignored
;
mul32:
	; initialize variables
	shld	mplier	;save multiplier
	xchg		;set DE to end of mc buffer
	lxi	d,4
	dad	d
	xchg
	lxi	h,0	;clear temporary buffer
	shld	mtemp
	shld	mtemp+2
	mvi	c,33	;set bit counter

	; Rotate temp buffer right one bit with carry
mul32a:
	ora	a	;clear initial carry
	mvi	b,4
	lxi	h,mtemp+4
mul32b:
	dcx	h
	mov	a,m
	rar
	mov	m,a
	dcr	b
	jnz	mul32b

	; Rotate multiplicand as above
	mov	l,e
	mov	h,d
	mvi	b,4
mul32c:
	dcx	h
	mov	a,m
	rar
	mov	m,a
	dcr	b
	jnz	mul32c

	; if bit shifted out is a 1,
	; add multiplier to temporary
	jnc	mul32d	;skip if bit is zero
	lxi	h,mtemp
	lda	mplier
	add	m
	mov	m,a
	inx	h
	lda	mplier+1
	adc	m
	mov	m,a
	jnc	mul32d
	inx	h
	inr	m

	; update count, test for completion
mul32d:
	dcr	c
	jnz	mul32a
	ret

	page
;;	DIV32 - Specialized unsigned 32-bit divide
;
;	Entry:
;		DE - addr of 4-byte dividend, assumed >0
;		HL - value of 2-byte divisor
;	Exit:
;		unsigned quotient replaces dividend
;		remainder discarded
;
div32:
	;initialize variables
	putw	dvsor	;save divisor
	xchg
	putw	dvdena	;save dividend address
	mvi	a,33	;set count to # of bits + 1
	sta	dvcnt
	getwi	dvbuf2	;set ptrs to work buffers
	putw	dvaltbp
	getwi	dvbuf1
	putw	dvcurbp
	mvi	c,8	;clear work buffers
	xra	a
div32a:
	mov	m,a
	inx	h
	dcr	c
	jnz	div32a

;  main loop - repeat for each bit

div32b:
	; shift dividend left one place
	getw	dvdena
	mvi	c,4
div32c:
	mov	a,m
	ral
	mov	m,a
	inx	h
	dcr	c
	jnz	div32c

	; check for completion (don't disturb carry)
	lda	dvcnt
	dcr	a
	sta	dvcnt
	jz	div32x	;done

	; shift work buffer left, pickup carry
	getw	dvcurbp
	mvi	c,4
div32d:
	mov	a,m
	ral
	mov	m,a
	inx	h
	dcr	c
	jnz	div32d

	;subtract divisor from current buffer,
	;store result in alternate buffer
	getw	dvaltbp
	mov	c,l
	mov	b,h
	getw	dvcurbp
	xchg
	getw	dvsor
	xra	a
	ldax	d
	sub	l
	stax	b
	inx	d
	inx	b
	ldax	d
	sbb	h
	stax	b
	inx	d
	inx	b
	ldax	d
	sbb	a
	stax	b
	inx	d
	inx	b
	ldax	d
	sbb	a
	stax	b

	; if difference is positive or zero,
	; make carry 1 for quotient and switch buffers
	cmc
	jnc	div32b
	getw	dvcurbp
	xchg
	getw	dvaltbp
	putw	dvcurbp
	xchg
	putw	dvaltbp
	jmp	div32b

	; exit when done
div32x:
	ret

	page
;;	CMP32 - 32 bit unsigned compare
;
;	Entry:
;		HL - address of 1st 4-byte value
;		DE - address of 2nd 4-byte value
;	Exit:
;		zero set iff 1st value = 2nd value
;		carry set iff 1st value < 2nd value
;
cmp32:
	lxi	b,4
	dad	b
	xchg
	dad	b
	ora	a
cmp32a:
	dcx	h
	dcx	d
	ldax	d
	sbb	m
	rnz
	dcr	c
	jnz	cmp32a
	ret

	page
;;	ADD32 - 32 bit addition
;
;	Entry: DE contains addr of 1st 4-byte value
;	       HL contains addr of 2nd 4-byte value
;
;	Exit:  signed sum replaces 1st value
;
add32:
	ora	a	;clear carry
	mvi	c,4	;set byte count
add32a:
	ldax	d
	adc	m
	stax	d
	inx	h
	inx	d
	dcr	c
	jnz	add32a

	ret

;;	SUB32 - 32 bit subtraction
;
;	Entry: DE contains addr of 4-byte subtrahend
;	       HL contains addr of 4-byte minuend
;
;	Exit: signed difference replaces subtrahend
;
sub32:
	ora	a	;clear carry
	mvi	c,4	;set byte count
sub32a:
	ldax	d
	sbb	m
	stax	d
	inx	h
	inx	d
	dcr	c
	jnz	sub32a

	ret	

	page
;;	NEG32 - 4 byte negation
;
;	Entry: HL contains addr of 4-byte value
;
;	Exit: value has been negated
;
neg32:
	xchg		;copy pointer to DE
	lxi	h,0
	dad	d	;restore to HL
	mvi	c,4	;set byte count
neg32a:
	mov	a,m	;complement each byte
	cma
	mov	m,a
	inx	h
	dcr	c
	jnz	neg32a
	xchg		;restore pointer
	call	inc32	;increment result

	ret

;;	INC32 - 4 byte increment
;
;	Entry: HL contains addr of 4-byte value
;
;	Exit: value has been incremented
;
inc32:
	mvi	c,4	;set byte count
inc32a:
	inr	m
	jnz	inc32b
	inx	h
	dcr	c
	jnz	inc32a
inc32b:
	ret

	page
;;  FCPTOW - Copy FCB & MFCB to workspace

fcptow:
	lhld	fcba
	xchg
	lxi	h,fcb
	mvi	a,fcblen
	call	@cpcopy
	lhld	mfcba
	xchg
	lxi	h,mfcb
	mvi	a,mfcblen
	call	@cpcopy
	ret


;;  FCPFRW - Copy FCB & MFCB from workspace

fcpfrw:
	lxi	d,fcb
	lhld	fcba
	mvi	a,fcblen
	call	@cpcopy
	lxi	d,mfcb
	lhld	mfcba
	mvi	a,mfcblen
	call	@cpcopy
	ret

	page
;;   ERROR TRANSFERS

er3ivcn:
	mvi	a,ERR3IVCN	;invalid connection
	jmp	@cperr
er3ivnm:
	mvi	a,ERR3IVNM	;invalid file name
	jmp	@cperr
er3insr:
	mvi	a,ERR3INSR	;insufficient resources
	jmp	@cperr
er3acdn:
	mvi	a,ERR3ACDN	;access denied
	jmp	@cperr
er3ivac:
	mvi	a,ERR3IVAC	;invalid access control
	jmp	@cperr
er3fex:
	mvi	a,ERR3FEX	;file already exists
	jmp	@cperr
er3dful:
	mvi	a,ERR3DFUL	;device full
	jmp	@cperr
er3ofb:
	mvi	a,ERR3OFB	;out of file bounds
	jmp	@cperr
er3skns:
	mvi	a,ERR3SKNS	;seeks not supported
	jmp	@cperr
er3xer:
	mvi	a,ERR3XER	;transmission error
	jmp	@cperr
er3nso:
	mvi	a,ERR3NSO	;file organization not supported
	jmp	@cperr
er3fnr:
	mvi	a,ERR3FNR	;file not renamed
	jmp	@cperr
er3ucre:
	mvi	a,ERR3UCRE	;unable to create
	jmp	@cperr
er3nsd:
	mvi	a,ERR3NSD	;no such directory
	jmp	@cperr
er3fno:
	mvi	a,ERR3FNO	;file not open
	jmp	@cperr
er3ivid:
	mvi	a,ERR3IVID	;invalid identity
	jmp	@cperr
er3ivmd:
	mvi	a,ERR3IVMD	;invalid mode
	jmp	@cperr
er3ivic:
	mvi	a,ERR3IVIC	;invalid identity code
	jmp	@cperr
er3ivro:
	mvi	a,ERR3IVRO	;invalid record organization
	jmp	@cperr


;;	INITIALIZATION TRANSFER
finit3:
	mvi	a,3	;set class to 3
	jmp	@cpinf	;go initialize

;;	UNIVERSAL RETURNS

	; Return with carry set
cret:
	stc
	ret

	; Return with carry clear
ncret:
	ora	a
	ret

	page
;;;	DATA AREA


;	INITIALIZED DATA

; Device Name Table
devtab:
	db	'CON:'	;console
	db	'LST:'	;printer
	db	'RDR:'	;reader
	db	'PUN:'	;punch
	db	'TRM:'	;terminal (unbuffered)

; Device Access Permission Table
devacc:
	db	RWDPERM	;console
	db	WODPERM	;printer
	db	RODPERM	;reader
	db	WODPERM	;punch
	db	RWDPERM	;terminal

blanks:
	db	'             '

	page
;;	UNINITIALIZED DATA

	dseg

;; LOCAL VARIABLES
;
;  used by many routines
connid	ds	2	;connection id
fcba	ds	2	;address of FCB
mfcba	ds	2	;address of MFCB
eofpos	ds	4	;eof position in bytes
ltemp	ds	4	;long temporary

;  used by READ and WRITE
amtxfr	ds	2	;transfer amount actual
rwbufp	ds	2	;system buffer pointer
abptr	ds	2	;application buffer pointer
rwbufc	ds	2	;bytes left in buffer
rwnrec	ds	2	;no. of records
rwrlen	ds	2	;record length
rwbrem	ds	2	;bytes remaining
rwbyte	ds	1	;current byte

;  used by SEEK
newblk	ds	2	;new block to seek
seekorg	ds	2	;seek origin
skfwd	ds	1	;seek forward flag
curpos	ds	4	;current position in bytes
newpos	ds	4	;desired position in bytes

;  used by MUL32
mtemp	ds	4	;temporary for mul32
mplier	ds	4	;multiplier for mul32

;  used by DIV32
dvsor	ds	2	;divisor
dvdena	ds	2	;dividend address
dvcnt	ds	1	;bit counter
dvcurbp	ds	2	;current work buffer ptr
dvaltbp	ds	2	;alternate work buffer ptr
dvbuf1	ds	4	;work buffer 1
dvbuf2	ds	4	;work buffer 2

;  miscellaneous
fnamp	ds	2	;file name pointer
textflg	ds	1	;textfile flag
ident	ds	2	;identity code
acctrl	ds	2	;access control

; File Information Block
finfo:	ds	FINFSZ

; File name buffer
fnbuf:	ds	15

; Working Directory (drive) name buffer
wdir:	ds	3

; Old name buffer for rename
;   (must immediately precede fcb)
oldname: ds	16

	page
; File Control Blocks (standard CP/M)
;
;	Workspace
fcb:
fcbdrv	equ	$-fcb
	ds	1	;drive code
fcbfnam	equ	$-fcb
	ds	8	;file name
fcbftyp	equ	$-fcb
	ds	3	;file type
fcbext	equ	$-fcb
	ds	1	;current extent number
fcbs1	equ	$-fcb
	ds	1	;reserved for CP/M
fcbs2	equ	$-fcb
	ds	1	;reserved for CP/M
fcbnrec	equ	$-fcb
	ds	1	;no. of records in current extent
	ds	16	;disk map
fcbrecn	equ	$-fcb
	ds	1	;current record no.
fcbblkn	equ	$-fcb
	ds	3	;current random block no.
fcblen	equ	$-fcb

; actual fcbs
	ds	fcblen * (MAXFCB)

	page
; Auxiliary File Control Blocks
;
;	Workspace
mfcb:
	; Status flags
mfcbstat equ	$-mfcb
	ds	1	;bit 7 = fcb in use; bit 6 = file open;
			;bit 5 = true file; bit 4 = temp file;
			;bit 3 = buffer valid; bit 2 = buf. modified;
			;bit 1 = eof;  bit 0 = textfile
	; Permanent file characteristics
mfcbrsiz equ	$-mfcb
	ds	2	;record size in bytes
mfcbesiz equ	$-mfcb
	ds	2	;efficient transfer size
mfcbfsiz equ	$-mfcb
	ds	2	;file size in blocks
mfeofbyt equ	$-mfcb
	ds	1	;end of file position
mfcbforg equ	$-mfcb
	ds	1	;file organization code
mfcbrorg equ	$-mfcb
	ds	1	;record organization code
mfcbaccn equ	$-mfcb
	ds	1	;access control code

	; Information for open files
mfcbacpm equ	$-mfcb
	ds	1	;access requested, if open
mfcbacmt equ	$-mfcb
	ds	1	;access method, if open
mfcbrecn equ	$-mfcb
	ds	4	;current record number
mfcbbfad equ	$-mfcb
	ds	2	;buffer address
mfcbcpos equ	$-mfcb
	ds	1	;current position in buffer
mfcblen	equ	$-mfcb

;  actual mfcb's
	ds	mfcblen * (MAXFCB)

	end
