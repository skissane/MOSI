	title 'MOSI CP/M INIT EXCEPTION HANDLING'

	name	'iexch'

;;	MOSI Interface for CP/M 2.2

;	Last Edit: Feb. 19, 1985

;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506

;	  Assemble with Digital Research RMAC
;	    or compatible assembler

;	This module contains dummy initialization for exception
;	handling, to be loaded when normal exception handling
;	is not included.

	public	@cpiexh		;initialize

@cpiexh:
	ret

	end
