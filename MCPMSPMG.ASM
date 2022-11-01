	title 'MOSI CP/M SINGLE PROCESS MANAGEMENT'

	name	'spmg'

;;;	MOSI Interface for CP/M 2.2

;;	CAPABILITY: Process Management
;;	MODULE:     Single Process

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
	public	cpintpg		;initialize_program
	public	cptrmpg		;terminate_program

;    External references
	extrn	@cpinf		;initialize function
	extrn	@cpexf		;exit function
	extrn	@cperr		;error return
	extrn	@cpcopy		;block copy
	extrn	@cpsb16		;16-bit subtract
	extrn	@cpcm16		;16-bit compare
	extrn	@cppba		;parameter block address

	extrn	@cpifil		;initialize file i/o
	extrn	@cpimem		;initialize memory management
	extrn	@cpiioa		;initialize i/o assignments
	extrn	@cpiarg		;initialize argument processing
	extrn	@cpiexh		;initialize exception handling

	extrn	@cptfil		;terminate file i/o

;    Symbol Definitions
	BDOS	equ	5	;BDOS transfer location
	WBOOT	equ	0	;warm boot BDOS function

;    Macro Definitions
	maclib	mcpmmacs	;include MOSI-CP/M macros

	page

;;;	INITIALIZE_PROGRAM
;
;	Input Parameters:
;		start_heap	storageid	(2 bytes)
;		end_heap	storageid	(2 bytes)
;
;	Output Parameters:
;		process_id	systemtag	(2 bytes)
;
;	Initializes the MOSI interface.  This function MUST
;	be called prior to any other MOSI function.  The input
;	parameters, start_heap and end_heap, are not specified
;	in the standard but are required in this implementation.
;	They specify the first and last location, respectively,
;	within the available heap area.  These locations are
;	assumed to be static.  Since allocation must work in
;	conjunction with the language run-time system, the
;	information can only be determined by the language
;	interface.
;
;	If memory management is not implemented in the language
;	interface, then these values must still be present but
;	are not used.

cpintpg:
	mvi	a,5		;set class 5
	call	@cpinf		;initialize

	getwi	0		;set process id to 0
	putwx	@cppba,4

	; initialize memory management
	getwx	@cppba,2	;get end of heap
	push	h
	getwx	@cppba		;get start of heap
	pop	d		;end to DE
	call	@cpimem

	; initialize other modules
	call	@cpifil		;file processing
	call	@cpiioa		;I/O assignments
	call	@cpiarg		;command line processing
	call	@cpiexh		;exception handling

	jmp	@cpexf		;return

	page

;;;	TERMINATE_PROGRAM
;
;	Input Parameters:
;		process_id	systemtag	(2 bytes)
;		termination_status integer	(2 bytes)
;
;	Closes any open files and returns to CP/M with a warm
;	boot.  The input parameters are ignored.

cptrmpg:
	mvi	a,5		;set class 5
	call	@cpinf		;initialize

	call	@cptfil		;terminate file processing

	syscall	WBOOT		;reboot CP/M


	end
