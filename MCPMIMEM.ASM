	title 'MOSI CP/M INIT MEMORY MANAGEMENT'

	name	'immgt'

;;	MOSI Interface for CP/M 2.2

;	Last Edit: Feb. 19, 1985

;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506

;	  Assemble with Digital Research RMAC
;	   or compatible assembler

;	This module contains dummy initialization for memory
;	management, to be loaded when normal memory management
;	is not included.

	public	@cpimem		;initialize

@cpimem:
	ret

	end
