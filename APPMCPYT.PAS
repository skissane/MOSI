{
		COPYTEXT

	Copy one textfile to another
	Using the MOSI interface (IEEE 855-1985)

	Jim Mooney
	Last Edit: June 5, 1985
}

	program copytx(input,output);

	label
		999;	{end of program}

	const

{$I MOSICDCL.PAS}	{MOSI Constant declarations}

		ACPMREAD = 2;	{read access permission}
		ACPMWREX = 12;   {write & extend access perm.}
		ACMTSEQ = 2;	{sequential record access meth.}
		FORGSEQ = 1;	{file org = seq. record}
		RORGVLEN = 2;	{record org = var. len}
		SORGEOF = 2;	{seek origin = eof}
		ERCSFIO = 3;	{Error Class Synch. File I/O}
		ERRFNF = 2;	{Error Reason File not Found}
		ERROFB = 9;	{Error Reason Out of File Bounds}

	type

{$I MOSITDCL.PAS}	{MOSI type declarations}

	var
		errblock: errorblock;	{MOSI error block}
		pid: integer;		{MOSI process id}

		inname: osstring;	{input file name}
		outname: osstring;	{output file name}
		inline: osstring;	{input text buffer}

		incid: systemtag;	{input file id}
		outcid: systemtag;	{output file id}
		argcount: integer;	{no. of command arguments}
		amtxfr: integer;	{no. of bytes transferred}
		endf: boolean;		{end of file flag}
		recsize: integer;	{record size}
		effsize: integer;	{efficient size}
		apflag: boolean;	{append flag}
		repq: boolean;		{repeat query flag}
		ch: char;		{character temporary}
		initsz: integer;	{initial output file size}
		seekrec: longinteger;	{record to seek}
		curpos: longinteger;	{current position}
		extsize: longinteger;	{extend size}

{$I MOSIPD32.PAS}	{Synchronous file I/O}
{$I MOSIPD51.PAS}	{Single Process Management}
{$I MOSIPD73.PAS}	{Direct Argument Acquisition}

{$I MOSISUBS.PAS}	{General subroutines}

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

	  { Initialize strings}
	  inname.limit := OSSTRMAX;
	  outname.limit := OSSTRMAX;
	  inline.limit := OSSTRMAX;

	  { Get file name arguments }
	  osgtcnt(argcount,errblock);
	  chkerr;
	  if argcount>2 then begin
	    writeln('Too many arguments');
	    goto 999;
	  end {if};
	  if argcount<1 then begin
	    write('Input File Name: ');
	    readstr(inname);
	  end
	  else begin
	    osgtarg(inname,errblock);
	    chkerr;
	  end {if};
	  if argcount<2 then begin
	    write('Output File Name: ');
	    readstr(outname);
	  end
	  else begin
	    osgtarg(outname,errblock);
	    chkerr;
	  end {if};

	  { Connect input file and check existence }
	  osconn(inname,incid,errblock);
	  if (errblock.class=ERCSFIO) and (errblock.reason=ERRFNF) then begin
	    writeln('File not found');
	    goto 999;
	  end {if};
	  chkerr;

	  { Open input file for text input }
	  osopen ( incid,	{connect id}
		   ACPMREAD,	{access perm: read }
		   ACMTSEQ,	{access method: seq rec}
		   0,		{record size: 0 (var. len)}
		   true,	{textfile flag}
		   recsize,	{returned record size}
		   effsize,	{returned efficient size}
		   errblock);
	  chkerr;

	  { Connect output file }
	  apflag := false;
	  osconn(outname,outcid,errblock);
	  if (errblock.class <> 0) then begin
	    if (errblock.class<>ERCSFIO) or (errblock.reason<>ERRFNF) then
	      chkerr;
	  end
	  else begin {file exists}
	    write('File "');
	    writestr(outname);
	    writeln('" already exists.');
	    repeat
	      repq := false;
	      write('Replace (R), Append (A), or Quit (Q)? ');
	      readln(ch);
	      if (ch='Q') or (ch='q') then goto 999
	      else if (ch='A') or (ch='a') then apflag := true
	      else if (ch='R') or (ch='r') then begin
	        osdelet(outcid,errblock);
	        chkerr;
	      end
	      else repq := true;
	    until not repq;
	  end {if};

	  { Create output file unless appending }
	  if not apflag then begin
	    initsz := 1000;
	    oscreat ( outname,	{file name}
		      FORGSEQ,	{file org = sequential}
		      RORGVLEN,	{rec org = var. len}
		      0,	{rec size = 0}
		      true,	{text file flag}
		      initsz,	{initial size}
		      outcid,	{connect id}
		      errblock);
	    chkerr;
	  end {if};

	  { Open output file for text output }
	  osopen ( outcid,	{connect id}
		   ACPMWREX,	{access perm: write, extend }
		   ACMTSEQ,	{access method: seq rec}
		   0,		{record size: 0 (var. len)}
		   true,	{textfile flag}
		   recsize,	{returned record size}
		   effsize,	{returned efficient size}
		   errblock);
	  chkerr;

	  { if appending, seek to end }
	  if apflag then begin
	    seekrec[1] := 0;
	    seekrec[2] := 0;
	    osseek ( outcid,	{connect id}
		     SORGEOF,	{origin = end of file}
		     true,	{seek forward}
		     seekrec,	{seek record = 0}
		     curpos,	{returned current position}
		     errblock);
	    chkerr;
	  end {if};

	  endf := false;
	  repeat
	    osrdlin(incid,inline,amtxfr,errblock);
	    chkerr;
	    if amtxfr<0 then endf := true
	    else begin
	      oswrlin(outcid,inline,amtxfr,errblock);
	      if (errblock.class<>0) then begin
	        if (errblock.class=ERCSFIO) and (errblock.reason=ERROFB) then begin
	          extsize[1] := 500;
	          extsize[2] := 0;
	          osexten(outcid,extsize,errblock);
		  chkerr;
	          oswrlin(outcid,inline,amtxfr,errblock);
	          chkerr;
	        end else chkerr;
	      end {if};
	    end {if};
	  until endf;

	  { truncate output file }
	  ostrunc(outcid,errblock);
	  chkerr;

	  { close and disconnect files }
	  osdconn(incid,errblock);
	  chkerr;
	  osdconn(outcid,errblock);
	  chkerr;

	  { terminate program }
999:	  ostrmpg(pid,0,errblock);

	end.
