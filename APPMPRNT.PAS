{
			PRINT

	Print a file on the printer
	Using the MOSI interface (IEEE 855-1985)

	Jim Mooney
	Last Edit: June 5, 1985
}

	program print(input,output);

	label
		999;	{end of program}

	const

{$I MOSICDCL.PAS}

		ACPMREAD = 2;	{read access permission}
		ACPMWRIT = 4;   {write access perm.}
		ACMTSEQ = 2;	{sequential record access meth.}
		PRCHAN = 7;	{printer channel number}
		ERCSFIO = 3;	{Error Class Synch. File I/O}
		ERRFNF = 2;	{Error Reason File not Found}

	type

{$I MOSITDCL.PAS}

	var
		errblock: errorblock;	{MOSI error block}
		pid: integer;		{MOSI process id}

		inname: osstring;	{input file name}
		prname: osstring;	{printer name}
		inline: osstring;	{input text buffer}

		incid: systemtag;	{input file id}
		prcid: systemtag;	{printer file id}
		prstat: integer;	{printer status code}
		prtype: integer;	{printer type code}
		argcount: integer;	{no. of command arguments}
		amtxfr: integer;	{no. of bytes transferred}
		endf: boolean;		{end of file flag}
		recsize: integer;	{record size}
		effsize: integer;	{efficient size}

{$I MOSIPD32.PAS}	{Synchronous file I/O}
{$I MOSIPD51.PAS}	{Single Process Management}
{$I MOSIPD73.PAS}	{Direct Argument Acquisition}
{$I MOSIPD75.PAS}	{I/O Assignments}

{$I MOSISUBS.PAS}

{
	CHKERR: Check for error after MOSI function call
}

	procedure chkerr;
	begin
	  with errblock do begin
	    if (class<>0) or (reason<>0) then begin
	      writeln('ERROR: Class=',class:1,' Reason=',reason:1);
	      goto 999;
	    end {if};
	  end {with};
	end {chkerr};

{
	MAIN PROGRAM
}

	begin

	  { Initialize interface }
	  osintpg(pid,errblock);
	  chkerr;

	  { Initialize strings }
	  inname.limit := OSSTRMAX;
	  prname.limit := OSSTRMAX;
	  inline.limit := OSSTRMAX;

	  { Get file name argument }
	  osgtcnt(argcount,errblock);
	  chkerr;
	  if argcount>1 then begin
	    writeln('Too many arguments');
	    goto 999;
	  end {if};
	  if argcount<1 then begin
	    write('File Name: ');
	    readstr(inname);
	  end
	  else begin
	    osgtarg(inname,errblock);
	    chkerr;
	  end {if};

	  { Connect file and check existence }
	  osconn(inname,incid,errblock);
	  if (errblock.class=ERCSFIO) and (errblock.reason=ERRFNF) then begin
	    writeln('File not found');
	    goto 999;
	  end {if};
	  chkerr;

	  { Open file for text input }
	  osopen ( incid,	{connect id}
		   ACPMREAD,	{access perm: read }
		   ACMTSEQ,	{access method: seq rec}
		   0,		{record size: 0 (var. len)}
		   true,	{textfile flag}
		   recsize,	{returned record size}
		   effsize,	{returned efficient size}
		   errblock);
	  chkerr;

	  { Locate list device }
	  osgtioa(PRCHAN,prstat,prtype,prname,prcid,errblock);
	  chkerr;
	  if prstat=0 then begin
	    writeln('No printer');
	    goto 999;
	  end {if};

	  { Connect and open list device if necessary }
	  if prstat < 2 then begin
	    osconn(prname,prcid,errblock);
	    chkerr;
	  end {if};
	  if prstat = 3 then begin {close & reopen to set mode }
	    osclose(prcid,errblock);
	    chkerr;
	  end {if};
	  osopen ( prcid,	{connect id}
		   ACPMWRIT,	{access perm: read }
		   ACMTSEQ,	{access method: seq rec}
		   0,		{record size: 0 (var. len)}
		   true,	{textfile flag}
		   recsize,	{returned record size}
		   effsize,	{returned efficient size}
		   errblock);
	  chkerr;

	  endf := false;
	  repeat
	    osrdlin(incid,inline,amtxfr,errblock);
	    chkerr;
	    if amtxfr<0 then endf := true
	    else begin
	      oswrlin(prcid,inline,amtxfr,errblock);
	      chkerr;
	    end {if};
	  until endf;

	  { close and disconnect files }
	  osdconn(incid,errblock);
	  chkerr;
	  osdconn(prcid,errblock);
	  chkerr;

	  { terminate program }
999:	  ostrmpg(pid,0,errblock);

	end.
