	title 'MOSI CP/M INIT I/O ASSIGNMENTS'

	name	'iioas'

;;	MOSI Interface for CP/M 2.2

;	Last Edit: Feb. 19, 1985

;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506

;	  Assemble with Digital Research RMAC
;	   or compatible assembler

;	This module contains dummy initialization for I/O 
;	assignments, to be loaded when normal I/O assignments
;	is not included.

	public	@cpiioa		;initialize

@cpiioa:
	ret

	end
