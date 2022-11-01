	title 'MOSI CP/M INIT FILE I/O'

	name	'isfio'

;;	MOSI Interface for CP/M 2.2

;	Last Edit: Feb. 19, 1985

;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506

;	  Assemble with Digital Research RMAC
;	    or compatible assembler

;	This module contains dummy initialization for file
;	management, to be loaded when normal file management
;	is not included.

	public	@cpifil		;initialize
	public	@cptfil		;terminate

@cpifil:
	ret

@cptfil:
	ret

	end
