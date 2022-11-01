	title 'MOSI CP/M: SYSTEM CHARACTERISTICS'

	name	'sysc'

;;;	MOSI Interface for CP/M 2.2

;;	CAPABILITY: Interface with the Environment
;;	MODULE:     System Characteristics

;	Last Edit: January 9, 1985
;
;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506
;
;
;	   Assemble with Digital Research RMAC
;	      or compatible assembler

;   Exported Procedure Names
	public	cpgtsys		;get_system_characteristics

;   External references
	extrn	@cpinf		;initialize function
	extrn	@cpexf		;exit function
	extrn	@cperr		;error return
	extrn	@cpcopy		;block copy
	extrn	@cpsb16		;16-bit subtract
	extrn	@cpcm16		;16-bit compare
	extrn	@cppba		;parameter block address

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CPM macros

	page

;;;	GET_SYSTEM_CHARACTERISTICS
;
;	Input parameters:
;		(none)
;
;	Output parameters:
;		configuration_code integer	(2 bytes)
;		mosi-standard	integer		(2 bytes)
;		version-id	string		(2 bytes)
;		system_name	string		(2 bytes)
;		system_serial_number string	(2 bytes)
;		gmt_difference	integer		(2 bytes)
;		bits_byte	integer		(2 bytes)
;		bits_address_unit integer	(2 bytes)

;	Returns required information as shown in the
;	table below.  System serial numbers are not supported.
;	The gmt_difference returns zero, since CP/M does not
;	support time of day.  The current MOSI standard number
;	is zero.

cpgtsys:
	mvi	a,7		;set class 7
	call	@cpinf		;initialize

	lhld	@cppba		;point to parameter block
	lxi	d,syschar	;stored system characteristics
	mvi	a,sysclen	;copy whole table
	call	@cpcopy
	jmp	@cpexf

syschar:
	dw	2	;configuration code 2 - Simple Dev.
	dw	0	;MOSI standard number
	dw	versid	;version id
	dw	sysname  ;system name
	dw	sysser	;system serial number
	dw	0	;gmt difference
	dw	8	;byte size
	dw	8	;addressable unit size
sysclen equ	$-syschar 

sysname:
	mstring 'CP/M-80 2.2'
sysser:
	mstring ''
versid:
	mstring 'WVU 1.00'

	end
