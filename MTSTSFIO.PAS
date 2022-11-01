{
	MTSTSFIO.PAS
	Pascal Test Program for the MOSI interface
	Synchronous File I/O tests

	Last Edit: May 28, 1985

	Copyright (C) 1985 by
	  James D. Mooney
	  Dept. of Statistics & Computer Science
	  West Virginia University
	  Morgantown, WV 26506

	This is a Pascal low-level test program
	for the IEEE MOSI (855) Operating Systems Interface.
	This version conforms to the Trial Use Standard IEEE 855-1985

	This Pascal program is adapted for Pascal MT+ by Digital Research.
	The following items may need to be modified for other Pascal
	installations:

		Form of program heading statement
		External procedure declaration
		Compiler directives for listing control
		   and source file inclusion


}

	program mtstsfio(input,output);

	label
		100,999;

	const

{$I MOSICDCL.PAS} {Include MOSI constant declarations}

		VARLEN = 2; {Variable Length record type}
		CHARREC = 5; {Character I/O record type}
{$P}
	type

{$I MOSITDCL.PAS} {Include MOSI type declarations}

		funcname = packed array[1..30] of char;


{$P}

	var
		errblock: ErrorBlock;
		infoblock: InformationBlock;

		iodata: universal;	{I/O transfer buffer}
		filename: osstring;	{File Name}
		dirname: osstring;	{Directory Name}
		textline: osstring;	{I/O text line}


		connid: systemtag;	{connection id}
		errloc: integer;	{error transfer code}
		testnum: integer;	{current test number}
		quit: boolean;		{exit requested}
		pid: systemtag;		{process id}

{$P}

{ Include Applicable MOSI Procedure Declarations }

{$I MOSIPD32.PAS}	{Synchronous File I/O}
{$I MOSIPD51.PAS}	{Single Process Management}

{$I MTSTCOMM.PAS}	{Common procedures for test programs}
{$I MOSISUBS.PAS}	{Common support subroutines}
{$P}
{
	CHKERR: Check for errors, abort if error occurs
}
	
	procedure chkerr ( func: funcname);
	  begin
	    with errblock do begin
	      if (Class<>0) or (Reason<>0) then begin
	        writeln('ERROR returned by ',func);
	        writeln('   Class = ',Class:1,
			       '  Reason = ',Reason:1);
	        writeln('TEST ABORTED');
		pause;
		case errloc of
		0: goto 999;	{quit}
		1: goto 100;	{main menu}
		end {case};
	      end
	    end
	  end {chkerr};
{$P}
{
	GETCID: Get connect id
}
	procedure getcid;
	begin
	  write('Connect Id: ');
	  readln(connid);
	end {getcid};

{
	GETRTYP: Get record type
}
	function getrtyp: integer;

	var
		rtype: integer; {record type}
		ok: boolean; {valid input flag}

	begin

	  { get file info, check record org & text flag }
	  OsGfinf(connid, infoblock, errblock);
	  chkerr('GET_FILE_INFORMATION          ');
	  if infoblock.recordorg = VARLEN then rtype := 0
	  else if infoblock.textfile then rtype := CHARREC
	  else begin {not text - query for type }
	    repeat
	      ok := true;
	      writeln('Record type (1-8-bit integer, 2-16-bit integer,');
	      write  ('     3-integer, 4-real, 5-char, 6-boolean):');
	      readln(rtype);
	      if (rtype<1) or (rtype>6) then begin
	        writeln('Invalid record type');
	        ok := false;
	      end {if};
	    until ok;
	  end {if};
	  getrtyp := rtype;

	end {getrtyp};
{$P}
{
	DISPFINF: Display file information
}
	procedure dispfinf;

	var
		acperm: integer;

	begin

	  { get connect id }
	  getcid;

	  { get file information, check for errors }
	  OsGFInf(connid,infoblock,errblock);
	  chkerr('GET_FILE_INFORMATION          ');

	  { display file information }
	  with infoblock do begin
	    write('  File Name: "');
	    writestr(FileName);
	    writeln('"');

	    if Open then
	      writeln('  File is open')
	    else
	      writeln('  File is not open');
	    if Temporary then
	      writeln('  File is temporary')
	    else
	      writeln('  File is not temporary');
	    if Textfile then
	      writeln('  File is a textfile')
	    else
	      writeln('  File is not a textfile');

	    writeln('  Record size: ',RecordSize:1);

	    if RecordOrg=1 then
	      writeln('  Record organization: fixed length')
	    else if RecordOrg=2 then
	      writeln('  Record organization: variable length')
	    else if RecordOrg=3 then
	      writeln('  Record Organization: stream')
	    else
	      writeln('  Record Organization: INVALID');

	    write  ('  File length (records): ');
	    writelong(FileLength);
	    writeln;
	    write  ('  Current Position: ');
	    writelong(Position);
	    writeln;
	    writeln('  Efficient Size: ',EfficientSize:1);

	    write('  Access Permission: ');
	    acperm := AccessPermission;
	    if acperm = 0 then write('NONE')
	    else begin
	      acperm := acperm mod 128;
	      if acperm >= 64 then write(' EXCLUSIVE');
	      acperm := acperm mod 64;
	      if acperm >= 32 then write(' CHANGE');
	      acperm := acperm mod 32;
	      if acperm >= 16 then write(' EXECUTE');
	      acperm := acperm mod 16;
	      if acperm >= 8 then write (' EXTEND');
	      acperm := acperm mod 8;
	      if acperm >= 4 then write (' WRITE');
	      acperm := acperm mod 4;
	      if acperm >= 2 then write (' READ');
	      acperm := acperm mod 2;
	      if acperm >= 1 then write (' DELETE');
	    end {if};
	    writeln;

	    if AccessMethod=1 then
	      writeln('  Access Method: stream')
	    else if AccessMethod=2 then
	      writeln('  Access Method: sequential record')
	    else if AccessMethod=3 then
	      writeln('  Access Method: direct record')
	    else
	      writeln('  Access Method: INVALID');

	    if FileOrg=1 then
	      writeln('  File Organization: Sequential')
	    else if FileOrg=2 then
	      writeln('  File Organization: Direct')
	    else if FileOrg=3 then
	      writeln('  File Organization: Directory')
	    else
	      writeln('  File Organization: INVALID');

	    write  ('  Create Time: ');
	    writelong(CreateTime);
	    writeln;
	    writeln('  Create Date: ',CreateDate:1);
	    write  ('  Last Mod Time: ');
	    writelong(LastModTime);
	    writeln;
	    writeln('  Last Mod Date: ',LastModDate:1);
	    write('  Last Access Time: ');
	    writelong(LastAccTime);
	    writeln;
	    writeln('  Last Access Date: ',LastAccDate:1);
	  end {with};
	  pause;

	end {dispfinf};

{$P}
{
	CONNFILE: Connect File
}
	procedure connfile;

	begin

	  { Get file name }
	  write('File Name: ');
	  readstr(FileName);

	  {  Connect the file }
	  OsConn(FileName,connid,errblock);
	  chkerr('CONNECT                       ');

	  { Display returned argument }
	  writeln('  connect id = ',connid:1);
	  pause;

	end {connfile};


{
	DCONNFILE: Disconnect a file
}
	procedure dconnfile;

	begin

	  { Get connect id }
	  getcid;

	  { Disconnect, check for errors }
	  OsDconn(connid,errblock);
	  chkerr('DISCONNECT                    ');

	  { Report completion }
	  writeln('Disconnect complete');
	  pause;

	end {dconnfile};
{$P}
{
	CREATFILE: Create a file
}
	procedure creatfile;

	var
		filorg: integer; {file organization}
		recorg: integer; {record organization}
		recsize: integer; {record size}
		initsize: integer; {initial size}
		textf: boolean; {textfile flag}

	begin
	  write('File Name: ');
	  readstr(filename);
	  write('File Organization (1-seq, 2-dir):');
	  readln(filorg);
	  write('Record Organization (1-fixed, 2-var, 3-stream): ');
	  readln(recorg);
	  write('Record Size in bytes: ');
	  readln(recsize);
	  write('Initial file size in records: ');
	  readln(initsize);
	  write('Text file (y or n)? ');
	  textf := getyn;

	  { Create the file, check for errors }
	  OsCreat(filename, filorg, recorg, recsize, textf,
	                    initsize, connid, errblock);
	  chkerr('CREATE                        ');

	  { Display returned argument }
	  writeln('Connect Id = ',connid:1);
	  pause;

	end {creatfile};
{$P}
{
	OPENFILE: Open a file
}
	procedure openfile;

	var
		accpm: integer;
		accmt: integer;
		expsize: integer;
		recsize: integer;
		effsize: integer;
		textf: boolean;

	begin

	  { get input arguments }
	  getcid;

	  { get desired access permission }
	  writeln('Specify desired access permission:');
	  accpm := 0;
	  write('DELETE (y or n)?' );
	  if getyn then accpm := accpm + 1;
	  write('READ (y or n)? ');
	  if getyn then accpm := accpm + 2;
	  write('WRITE (y or n)? ');
	  if getyn then accpm := accpm + 4;
	  write('EXTEND (y or n)? ');
	  if getyn then accpm := accpm + 8;
	  write('EXECUTE (y or n)? ');
	  if getyn then accpm := accpm + 16;
	  write('CHANGE ACCESS (y or n)? ');
	  if getyn then accpm := accpm + 32;
	  write('EXCLUSIVE ACCESS (y or n)? ');
	  if getyn then accpm := accpm + 64;

	  { get remaining attributes }
	  write('Access Method (1-stream, 2-seq rec, 3-dir rec): ');
	  readln(accmt);
	  write('Record Size (0 if var. length): ');
	  readln(expsize);
	  write('Text File (y or n)? ');
	  textf := getyn;

	  { open file, check for errors }
	  OsOpen(connid, accpm, accmt, expsize, textf,
	            recsize, effsize, errblock);
	  chkerr('OPEN                          ');

	  { display result arguments }
	  writeln('  record size = ',recsize:1);
	  writeln('  efficient size = ',effsize:1);
	  pause;

	end {openfile};
{$P}
{
	CLOSFILE: Close a file
}
	procedure closfile;

	begin

	  { get connect id }
	  getcid;

	  { close file, check for error }
	  OsClose(connid,errblock);
	  chkerr('CLOSE                         ');

	  { report completion }
	  writeln('Close complete');
	  pause;

	end {closfile};
{$P}
{
	EXTFILE: Extend a file
}
	procedure extfile;

	var
		exlen: longinteger;
		ok: boolean;

	begin

	  { get input arguments }
	  getcid;
	  write('Extend length (records): ');
	  readlong(exlen,ok);

	  { extend, check for errors }
	  OsExten(connid, exlen, errblock);
	  chkerr('EXTEND                        ');

	  { report completion }
	  writeln('Extend complete');
	  pause;

	end {extfile};

{
	TRUNCFILE: Truncate a file
}
	procedure truncfile;

	begin

	  { get connect id }
	  getcid;

	  { truncate, check for errors }
	  OsTrunc(connid, errblock);
	  chkerr('TRUNCATE                      ');
	  { report completion }
	  writeln('Truncate complete');
	  pause;

	end {truncfile};
{$P}
{
	RDREC: Read a single record
}
	procedure rdrec (     cid: systemtag; {connect id}
			      rectype: integer; {record type}
			  var endf: boolean); {end of file flag}

	var
		amtxfr: integer; {amount transferred}

	begin
	  endf := false;

	  { if record type 0, read and display text line }
	  if rectype = 0 then begin
	    OsRdLin(connid, textline, amtxfr, errblock);
	    chkerr('READ (LINE)                   ');
	    if amtxfr < 0 then endf := true
	    else begin
	      writestr(textline);
	      writeln;
	    end {if};
	  end

	  { if record type 1-6, read and display non-text record }
	  else begin
	    iodata.iotype := rectype;
	    OsRead(connid, iodata, amtxfr, errblock);
	    chkerr('READ (RECORD)                 ');
	    if amtxfr < 0 then endf := true
	    else begin
	      case rectype of
	      1: write(iodata.intval8:1);
	      2: write(iodata.intval16:1);
	      3: write(iodata.intval:1);
	      4: write(iodata.realval);
	      5: write(iodata.charval);
	      6: if iodata.boolval then write('true')
				   else write('false');
	      end {case};
	    end {if};
	  end {if};

	end {rdrec};
{$P}
{
	READREC: Read a record
}
	procedure readrec;

	var
		endf: boolean; {end of file flag}
		rectype: integer; {record type}

	begin

	  { get connect id & record type }
	  getcid;
	  rectype := getrtyp;

	  { read a record, report if end of file }
	  rdrec(connid, rectype, endf);
	  writeln;
	  if endf then writeln('END OF FILE');

	  pause;

	end {readrec};
{$P}
{
	READEOF: Read to end of file
}
	procedure readeof;

	var
		endf: boolean;
		rectype: integer;

	begin

	  { get connect id & record type }
	  getcid;
	  rectype := getrtyp;

	  { read and display records until eof }
	  repeat
	    rdrec(connid, rectype, endf);
	  until endf;

	  pause;

	end {readeof};

{$P}
{
	WRITREC: Write a record
}
	procedure writrec;

	var
		rectype: integer;
		amtxfr: integer;

	begin

	  { get connect id & record type }
	  getcid;
	  rectype := getrtyp;
	
	  { if record type 0, get text line and write }
	  if rectype = 0 then begin
	    writeln('Enter text line to be written');
	    readstr(textline);
	    OsWrLin(connid,textline,amtxfr,errblock);
	    chkerr('WRITE (LINE)                  ');
	  end

	  { if record type 1-6, get nontext record and write }
	  else begin
	    write('Enter data value: ');
	    iodata.iotype := rectype;
	    case rectype of
	    1: read(iodata.intval8);
	    2: read(iodata.intval16);
	    3: read(iodata.intval);
	    4: read(iodata.realval);
	    5: read(iodata.charval);
	    6: begin
	         readstr(textline);
	         if (textline.len=4) and (textline.data[1]='t')
	           then iodata.boolval := true
	           else iodata.boolval := false;
	       end;
	    end {case};
	    if rectype < 6 then readln;
	    OsWrite(connid, iodata, amtxfr, errblock);
	    chkerr('WRITE (RECORD)                ');
	  end {if};

	  writeln('Write complete');
	  pause;

	end {writrec};
{$P}
{
	SEEKREC: Seek a record
}
	procedure seekrec;

	var
		seekorg: integer; {seek organization}
		seekfwd: boolean; {seek direction}
		seekrec: longinteger; {record to seek}
		curpos: longinteger; {position after seek}
		ok: boolean; {true if readlong valid}

	begin

	  { get input arguments }
	  getcid;
	  write('Origin (1-start, 2-end, 3-current): ');
	  readln(seekorg);
	  write('Seek forward (y or n)? ');
	  seekfwd := getyn;
	  write('Record number: ');
	  readlong(seekrec,ok);

	  { Seek record, check for error }
	  OsSeek(connid, seekorg, seekfwd, seekrec, curpos, errblock);
	  chkerr('SEEK                          ');

	  { report completion & position }
	  writeln('Seek complete');
	  write('Current position: ');
	  writelong(curpos);
	  writeln;
	  pause;

	end {seekrec};
{$P}
{
	GETACC: Get access rights
}
	procedure getacc;

	var
		idcode: integer; {identity code}
		ident: systemtag; {identity}
		acctrl: integer; {access control code}

	begin

	  { get connect id & identity code }
	  getcid;
	  writeln('Identity codes: 0 (caller), -1 (public)');
	  write('Identity code: ');
	  readln(idcode);

	  { get identity, check for errors }
	  OsGtIdn(idcode, ident, errblock);
	  chkerr('GET_IDENTITY                  ');

	  { get access rights, check errors }
	  OsGtAcc(connid, ident, acctrl, errblock);
	  chkerr('GET_ACCESS_CONTROL            ');

	  { display result }
	  write('Access permitted: ');
	  if acctrl = 0 then write('NONE')
	  else begin
	    acctrl := acctrl mod 128;
	    if acctrl >= 64 then write(' EXCLUSIVE');
	    acctrl := acctrl mod 64;
	    if acctrl >= 32 then write(' CHANGE');
	    acctrl := acctrl mod 32;
	    if acctrl >= 16 then write(' EXECUTE');
	    acctrl := acctrl mod 16;
	    if acctrl >= 8 then write (' EXTEND');
	    acctrl := acctrl mod 8;
	    if acctrl >= 4 then write (' WRITE');
	    acctrl := acctrl mod 4;
	    if acctrl >= 2 then write (' READ');
	    acctrl := acctrl mod 2;
	    if acctrl >= 1 then write (' DELETE');
	  end {if};
	  writeln;
	  pause;

	end {getacc};
{$P}
{
	CHGACC: Change access rights
}
	procedure chgacc;

	var
		idcode: integer; {identity code}
		ident: systemtag; {identity}
		acctrl: integer; {access control code}

	begin

	  { get connect id & identity code }
	  getcid;
	  writeln('Identity codes: 0 (caller), -1 (public)');
	  write('Identity code: ');
	  readln(idcode);

	  { get identity, check for errors }
	  OsGtIdn(idcode, ident, errblock);
	  chkerr('GET_IDENTITY                  ');

	  { get desired access control }
	  writeln('Specify desired access control:');
	  acctrl := 0;
	  write('DELETE (y or n)?' );
	  if getyn then acctrl := acctrl + 1;
	  write('READ (y or n)? ');
	  if getyn then acctrl := acctrl + 2;
	  write('WRITE (y or n)? ');
	  if getyn then acctrl := acctrl + 4;
	  write('EXTEND (y or n)? ');
	  if getyn then acctrl := acctrl + 8;
	  write('EXECUTE (y or n)? ');
	  if getyn then acctrl := acctrl + 16;
	  write('CHANGE ACCESS (y or n)? ');
	  if getyn then acctrl := acctrl + 32;
	  write('EXCLUSIVE ACCESS (y or n)? ');
	  if getyn then acctrl := acctrl + 64;

	  { Change access, check for errors }
	  OsChAcc(connid, ident, acctrl, errblock);
	  chkerr('CHANGE_ACCESS_CONTROL         ');

	  { report completion }
	  writeln('Access control changed');
	  pause;

	end {chgacc};
{$P}
{
	DELFILE: Delete a file
}
	procedure delfile;

	begin

	  { get connect id }
	  getcid;

	  { delete file, check for error }
	  OsDelet(connid, errblock);
	  chkerr('DELETE                        ');

	  { report completion }
	  writeln('File deleted');
	  pause;

	end {delfile};
{$P}
{
	RENFILE: Rename a file
}
	procedure renfile;

	begin

	  { get connect id & new name }
	  getcid;
	  write('New name: ');
	  readstr(filename);

	  { rename file, check for errors }
	  OsRenam(connid, filename, errblock);
	  chkerr('RENAME                        ');

	  { report completion }
	  writeln('File renamed');
	  pause;

	end {delfile};
{$P}
{
	GETDIR: Get working directory
}
	procedure getdir;

	begin

	  { get directory, check for errors }
	  OsGtWkD(dirname,errblock);
	  chkerr('GET_WORKING_DIRECTORY         ');

	  { report result }
	  write('Directory: "');
	  writestr(dirname);
	  writeln('"');
	  pause;

	end {getdir};

{
	CHGDIR: Change working directory
}
	procedure chgdir;

	begin

	  { get new directory name }
	  write('New directory: ');
	  readstr(dirname);

	  { change directory, check for error }
	  OsChWkD(dirname, errblock);
	  chkerr('CHANGE_WORKING_DIRECTORY      ');

	  { report completion }
	  writeln('Directory name changed');
	  pause;

	end {chgdir};
{$P}

	{ Main Program }
	begin

	  { Initialize variables }
	  errloc := 0;
	  filename.limit := OSSTRMAX;
	  dirname.limit := OSSTRMAX;
	  textline.limit := OSSTRMAX;

	  { Announce and initialize }
	  writeln('MOSI-Pascal Interface Test Program');
	  writeln('Synchronous File I/O Tests');
	  OsIntPg(pid,errblock);
	  chkerr('INITIALIZE_PROGRAM            ');

	  { Begin main menu loop }
	  quit := false;
	  while (~quit) do begin

100:	    errloc := 1;
	    writeln;
	    writeln(' 1. Display File Information');
	    writeln(' 2. Connect File');
	    writeln(' 3. Disconnect File');
	    writeln(' 4. Create File');
	    writeln(' 5. Open File');
	    writeln(' 6. Close File');
	    writeln(' 7. Extend File');
	    writeln(' 8. Truncate File');
	    writeln(' 9. Read one record');
	    writeln('10. Read to end of file');
	    writeln('11. Write one record');
	    writeln('12. Seek record');
	    writeln('13. Get Access Control');
	    writeln('14. Change Access Control');
	    writeln('15. Delete File');
	    writeln('16. Rename File');
	    writeln('17. Get Working Directory');
	    writeln('18. Change Working Directory');
	    writeln('19. Terminate Program');
	    writeln;
	    write('    Select test: ');
	    readln(testnum);

	    if ((testnum<1) | (testnum>19)) then
	      writeln('    Invalid selection')
	    else begin
	      case testnum of
	      1:  dispfinf;
	      2:  connfile;
	      3:  dconnfile;
	      4:  creatfile;
	      5:  openfile;
	      6:  closfile;
	      7:  extfile;
	      8:  truncfile;
	      9:  readrec;
	      10:  readeof;
	      11: writrec;
	      12: seekrec;
	      13: getacc;
	      14: chgacc;
	      15: delfile;
	      16: renfile;
	      17: getdir;
	      18: chgdir;
	      19: quit := true;
	      end {case};
	    end {if};

	  end {while};

	  errloc := 0;	{quit if error}
	  writeln('Calling TERMINATE_PROGRAM');
	  ostrmpg(pid,0,errblock);
	  writeln('ERROR: Returned from TERMINATE_PROGRAM!');

999:	  writeln('TEST PROGRAM ABORTED');

	end.
