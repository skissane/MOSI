{
	OSEXCH - default exception handler

	MOSI Pascal MT+ CP/M

	Jim Mooney
	Last Edit: Jan. 22, 1985

	This module is to be linked with MOSI Pascal MT+ applications
	that use exception handling but do not provide
	their own user handler.  Note that any applications
	which can invoke @ERR will include exception handling.
}

	module osexch;

const
	OSSTRMAX = 256;
	OSMESMAX = 256;
type
{$I MOSITDCL.PAS}
{$I MOSIPD81.PAS}
{$I MOSIPD82.PAS}

	procedure osexch(hcode: integer);

	var
		excl: integer;	{exception class}
		subcl: integer; {exception subclass}
		errb: errorblock; {error block}

	begin
	  writeln('EXCEPTION: no handler present!');
	  osgtexc(excl,subcl,errb);
	  writeln('     Class: ',excl:1);
	  writeln('     Subclass: ',subcl:1);
	  writeln('     Handler Code:',hcode:1);
	  writeln('PROGRAM ABORTED');
	  osexith(1,errb);
	end {osexch};

modend.
