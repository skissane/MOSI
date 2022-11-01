	title 'MOSI CP/M INIT ARGUMENT ACQUISITION'

	name	'iargd'

;;	MOSI Interface for CP/M 2.2

;	Last Edit: Feb. 19, 1985

;	Copyright (C) 1985 by
;	  James D. Mooney
;	  Dept. of Statistics & Computer Science
;	  West Virginia University
;	  Morgantown, WV 26506

;	  Assemble with Digital Research RMAC
;	   or compatible assembler

;	This module contains dummy initialization for argument
;	acquisition, to be loaded when normal argument acquisition
;	is not included.

	public	@cpiarg		;initialize

@cpiarg:
	ret

	end
