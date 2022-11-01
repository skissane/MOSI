{
	MTSTMAIN.PAS
	Pascal Test Program for the MOSI interface
	Main test suite

	Last Edit: May 26, 1985

	Copyright (C) 1985 by
	  James D. Mooney
	  Dept. of Statistics & Computer Science
	  West Virginia University
	  Morgantown, WV 26506

	This is a Pascal low-level test program
	for the IEEE MOSI (855) Operating Systems Interface
	This version conforms to the Trial-use standard IEEE 855-1985

	This Pascal program is adapted for Pascal MT+ by Digital Research.
	The following items may need to be modified for other Pascal
	installations:

		Form of program heading statement
		External procedure declaration
		Compiler directives for listing control
		   and source file inclusion


}

	program mtstmain(input,output);

	label
		100,200,400,500,999;

	const

{$I MOSICDCL.PAS} {Include MOSI constant declarations}

		MAXARG = 10; {Maximum command line args}
		NUMIOC = 7; {No. of I/O Assignment Channels}
		NUMEXC = 3; {No. of exception classes}
{$P}
	type

{$I MOSITDCL.PAS} {Include MOSI type declarations}

		{ current function for error check }
		funcname = packed array[1..30] of char;

		{ big array list for memory test }
		blistep = ^blistelm;
		blistelm = record
			next: blistep;
			data: array[1..100] of integer
			end;

		{ small array list for memory test }
		slistep = ^slistelm;
		slistelm = record
			next: slistep;
			data: array[1..7] of integer
			end;

{$P}

	var
		sysblock: ConfigurationBlock;
		errblock: ErrorBlock;


		{ command line argument array }
		args: array[1..MAXARG] of osstring;

		filename: osstring;	{file name for I/O assignments}

		blistp: blistep;	{big list ptr for mem test}
		blhead: blistep;	{head of big list}
		bltail: blistep;	{tail of big list}
		slistp: slistep;	{small list ptr for mem test}
		slhead: slistep;	{head of small list}
		sltail: slistep;	{tail of small list}

		errloc: integer;	{error transfer code}
		cladone: boolean;	{arguments read}
		testnum: integer;	{current test number}
		quit: boolean;		{exit requested}
		pid: systemtag;		{process id}
		argcount: integer;	{argument count}
		exclass: integer;	{exception class}
		subclass: integer;	{exception subclass}

{$P}

{ Include Applicable MOSI Procedure Declarations }

{$I MOSIPD00.PAS}	{Get Error}
{$I MOSIPD11.PAS}	{Simple Memory Management}
{$I MOSIPD51.PAS}	{Single Process Management}
{$I MOSIPD71.PAS}	{System Characteristics}
{$I MOSIPD73.PAS}	{Direct Argument Acquisition}
{$I MOSIPD75.PAS}	{I/O Assignments}
{$I MOSIPD81.PAS}	{Default Exception Handler}
{$I MOSIPD82.PAS}	{Single Exception Handler}

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
		2: goto 200;	{memory management test menu}
		4: goto 400;	{i/o assignments test menu}
		5: goto 500;	{exception handling test menu}
		end {case};
	      end
	    end
	  end {chkerr};
{$P}
{
	DISPERR: Display last error
}
	procedure disperr;
	begin
	  osgterr(errblock);
	  writeln('LAST ERROR CODE:');
	  writeln('   Class = ',errblock.class:1);
	  writeln('   Reason = ',errblock.reason:1);
	  pause;
	end;
{$P}
{
	DISPSYSC: Display system characteristics
}
	procedure dispsysc;

	begin

	  { call function, check for error }
	  OsGtSys(sysblock,errblock);
	  chkerr('GET_SYSTEM_CHARACTERISTICS    ');

	  { display system information }
	  with sysblock do begin
	    writeln;
	    writeln('   Configuration: ',ConfCode:1);
	    writeln('   MOSI Standard number: ',MOSIStandard:1);
	    write  ('   Version Id: "');
	    writestr(VersionId);
	    writeln('"');
	    write('   System Name: "');
	    writestr(SystemName);
	    writeln('"');
	    write('   System Serial Number: "');
	    writestr(SystemSerialNumber);
	    writeln('"');
	    writeln('   GMT Difference: ',GMTDifference:1);
	    writeln('   Bits per byte: ',BitsByte:1);
	    writeln('   Bits per addressable unit: ',
		      BitsAddrUnit:1);
	    writeln;
	  end {with};

	  pause;

	end {dispsysc};
{$P}
{
	DISPCLA: Display Command Line Arguments
}
	procedure dispcla;

	var
		i: integer;

	begin

	  { Fetch arguments if not previously done }
	  if not cladone then begin
	    osgtcnt(argcount,errblock);
	    chkerr('GET_ARGUMENT_COUNT            ');
	    writeln('No. of arguments: ',argcount:1);
	    if argcount > MAXARG then argcount := MAXARG;
	    for i := 1 to argcount do begin
	      osgtarg(args[i],errblock);
	      chkerr('GET_ARGUMENT                  ');
	    end {for};
	    cladone := true;
	  end {if};

	  { Display saved arguments }
	  writeln('Command Line Arguments:');
	  for i := 1 to argcount do begin
	    write('    "');
	    writestr(args[i]);
	    writeln('"');
	  end {for};
	  pause;

	end {dispcla};
{$P}
{
	DISPMEM: Display memory status
}
	procedure dispmem;

	var
		alu: integer;	{alu size}
		trem: longinteger;	{total space}
		lrem: longinteger;	{largest block}

	begin

	  { Get ALU size and amount remaining, check errors }
	  osgtalu(alu,errblock);
	  chkerr('GET_ALLOCATION_UNIT           ');
	  osgtamt(trem,lrem,errblock);
	  chkerr('GET_AMOUNT_REMAINING          ');

	  { display returned information }
	  writeln;
	  writeln('Allocation Unit (bytes): ',alu:1);
	  writeln('Total Size (ALU''s): ',trem[1]:1);
	  writeln('Largest Block (ALU''s): ',lrem[1]:1);

	  pause;	

	end {dispmem};
{$P}
{
	ALLOCMB: Allocate a big data array
	     put it on the tail of the big array list
}
	procedure allocmb;
	begin

	  { Allocate list element, check for errors }
	  new(blistp);
	  osgterr(errblock);
	  chkerr('ALLOCATE (BIG)                ');

	  { Add to tail of list }
	  blistp^.next := nil;
	  if blhead=nil then
	    blhead := blistp
	  else
	    bltail^.next := blistp;
	  bltail := blistp;

	  { report completion }
	  writeln('Allocate completed');
	  pause;

	end {allocmb};
{$P}
{
	ALLOCMS: Allocate a small data array
	     put it on the tail of the small array list
}
	procedure allocms;
	begin

	  { Allocate list element, check for errors }
	  new(slistp);
	  osgterr(errblock);
	  chkerr('ALLOCATE (SMALL)              ');

	  { Add to tail of list }
	  slistp^.next := nil;
	  if slhead=nil then
	    slhead := slistp
	  else
	    sltail^.next := slistp;
	  sltail := slistp;

	  { report completion }
	  writeln('Allocate completed');
	  pause;

	end {allocms};
{$P}
{
	FREEMB: Free an allocated big array
}
	procedure freemb;

	begin

	  { check for empty list }
	  if blhead=nil then
	    writeln('NOTHING TO FREE!')
	  else begin

	    { remove element from head of list }
	    blistp := blhead;
	    blhead := blhead^.next;

	    { free element, check for errors }
	    dispose(blistp);
	    osgterr(errblock);
	    chkerr('FREE (BIG)                    ');

	    { report completion }
	    writeln('Free completed');

	  end {if};
	  pause;

	end {freemb};
{$P}
{
	FREEMS: Free an allocated small array
}
	procedure freems;

	begin

	  { check for empty list }
	  if slhead=nil then
	    writeln('NOTHING TO FREE!')
	  else begin

	    { remove element from head of list }
	    slistp := slhead;
	    slhead := slhead^.next;

	    { free element, check for errors }
	    dispose(slistp);
	    osgterr(errblock);
	    chkerr('FREE (SMALL)                  ');

	    { report completion }
	    writeln('Free completed');

	  end {if};
	  pause;

	end {freems};
{$P}
{
	TESTMMGT: Test Memory Management
}
	procedure testmmgt;

	var
		mquit: boolean;

	begin
	  mquit := false;
	  while (~mquit) do begin

200:	    errloc := 2;
	    writeln;
	    writeln(' 1. Display Memory Status');
	    writeln(' 2. Allocate a Big Array');
	    writeln(' 3. Allocate a Small Array');
	    writeln(' 4. Free a Big Array');
	    writeln(' 5. Free a Small Array');
	    writeln(' 6. Resume Main Menu');
	    writeln;
	    write('     Select test: ');
	    readln(testnum);

	    if ((testnum<1) | (testnum>6)) then
	      writeln('     Invalid selection')
	    else begin
	      case testnum of
	      1: dispmem;
	      2: allocmb;
	      3: allocms;
	      4: freemb;
	      5: freems;
	      6: mquit := true;
	      end {case};

	    end {if};

	  end {while};

	end {testmmgt};
{$P}
{
	DISPIOA: Display I/O Assignments
}
	procedure dispioa;

	var
		chan: integer;	{I/O channel code}
		stat: integer;	{status code}
		iotype: integer; {type code}
		cid: systemtag; {connect id}

	begin

	  { display heading }
	  writeln;
	  writeln('CODE  STATUS  TYPE  CONNECT ID  FILE NAME');

	  { fetch and display info for each channel }
	  for chan := 1 to NUMIOC do begin
	    osgtioa(chan,stat,iotype,filename,cid,errblock);
	    chkerr('GET_IO_ASSIGNMENTS            ');
	    write(chan:3,stat:7,iotype:7,cid:8,'      ');
	    writestr(filename);
	    writeln;
	  end {for};

	  pause;

	end {dispioa};
{$P}
{
	CHGIOA: Change an I/O Assignment
}
	procedure chgioa;

	var
		iochan: integer; {I/O Assignment Channel}

	begin

	  { get input arguments }
	  write('I/O channel: ');
	  readln(iochan);
	  write('File Name: ');
	  readstr(filename);

	  { change assignment, check for errors }
	  OsChIOA(iochan, filename, errblock);
	  chkerr('CHANGE_IO_ASSIGNMENTS         ');

	  { report completion }
	  writeln('I/O assignment changed');
	  pause;

	end {chgioa};
{$P}
{
	TESTIOA: Test I/O assignment functions
}
	procedure testioa;

	var
		iquit: boolean;

	begin
	  iquit := false;
	  while (~iquit) do begin

400:	    errloc := 4;
	    writeln;
	    writeln(' 1. Display I/O Assignments');
	    writeln(' 2. Change I/O Assignments');
	    writeln(' 3. Resume Main Menu');
	    writeln;
	    write('     Select test: ');
	    readln(testnum);

	    if ((testnum<1) | (testnum>3)) then
	      writeln('     Invalid selection')
	    else begin
	      case testnum of
	      1: dispioa;
	      2: chgioa;
	      3: iquit := true;
	      end {case};
	    end {if};

	  end {while};

	end {testioa};
{$P}
{
	DISPEXCH: Display exception handler status
}
	procedure dispexch;

	var
		excl: integer; {exception class}
		stat: boolean; {enable status}
		hcode: integer; {handler code}

	begin

	  { display heading }
	  writeln;
	  writeln('CLASS  STATUS');

	  { get and display enable status for each class }
	  for excl := 1 to NUMEXC do begin
	    osgtens(excl,stat,errblock);
	    chkerr('GET_ENABLE_STATUS             ');
	    write(excl:3);
	    if stat then writeln('    enabled')
	            else writeln('    disabled');
	  end {for};

	  { get and display handler code }
	  osgetex(hcode,errblock);
	  chkerr('GET_EXCEPTION_HANDLER         ');
	  writeln;
	  writeln('Handler code: ',hcode:1);

	  pause;

	end {dispexch};
{$P}
{
	DISEXC: Disable exception handler class
}
	procedure disexc;

	var
		excl: integer; {exception class}

	begin

	  { get exception class }
	  write('Exception class: ');
	  readln(excl);

	  { disable class, check for errors }
	  OsDisEx(excl, errblock);
	  chkerr('DISABLE                       ');

	  { report completion }
	  writeln('Exception class disabled');
	  pause;

	end {disexc};

{
	ENAEXC: Enable exception handler class
}
	procedure enaexc;

	var
		excl: integer; {exception class}

	begin

	  { get exception class }
	  write('Exception class: ');
	  readln(excl);

	  { enable exceptions, check for errors }
	  OsEnaEx(excl, errblock);
	  chkerr('ENABLE                        ');

	  { report completion }
	  writeln('Exception class enabled');
	  pause;

	end {enaexc};
{$P}
{
	GETEXH: Get exception handler code
}
	procedure getexh;

	var
		hcode: integer; {handler code}

	begin

	  { get handler code, check for errors }
	  OsGetEx(hcode, errblock);
	  chkerr('GET_EXCEPTION_HANDLER         ');

	  { display result }
	  writeln('Handler code: ',hcode:1);
	  pause;

	end {getexh};

{
	SETEXH: Set exception handler code
}
	procedure setexh;

	var
		hcode: integer;

	begin

	  { get handler code }
	  write('Handler code: ');
	  readln(hcode);

	  { set handler code, check for errors }
	  OsSetEx(hcode,errblock);
	  chkerr('SET_EXCEPTION_HANDLER         ');

	  { report completion }
	  writeln('Handler code set');
	  pause;

	end {setexh};
{$P}
{
	SETDEFH: Setup default exception handler
}
	procedure setdefh;

	begin

	  { reset default handler, check for errors }
	  OsResDf(errblock);
	  chkerr('RESET_DEFAULT_HANDLER         ');

	  { report completion }
	  writeln('Default handler set');
	  pause;

	end {setdefh};
{$P}
{
	RAISEX: Raise an exception
}
	procedure raisex;

	var
		excl: integer; {exception class}
		subcl: integer; {exception subclass}

	begin

	  { get class and subclass }
	  write('Exception class: ');
	  readln(excl);
	  write('Exception subclass: ');
	  readln(subcl);

	  { raise exception, check for error on return }
	  OsRaiEx(excl, subcl, errblock);
	  chkerr('RAISE_EXCEPTION               ');

	  { report completion }
	  writeln('Exception raised and returned');
	  pause;

	end {raisex};
{$P}
{
	CHKRNG: Check response to range error

	Tests exception handling on an out-of-bounds
	array reference detected by runtime checks

	Should raise an exception with class 1, subclass 2
}
{$R+}   { Enable range checking }

	procedure chkrng;

	var
		ary: array[1..10] of integer;
		i,x: integer;
	begin
	  writeln('Test of array range checking');
	  writeln('Should raise exception 1,2 ');
	  i := 20;
	  x := ary[i];
	  pause;
	end;
{$R-}
{$P}
{
	OSEXCH: Application defined exception handler
}
	procedure OsExch ( exhcode: integer);

	var
		excl:	integer; {exception class}
		subcl:	integer; {exception subclass}

	begin

	  { display initial information }
	  writeln('ENTERING EXCEPTION HANDLER');
	  writeln('Handler code: ',exhcode:1);

	  { get and display exception code }
	  OsGtExc(excl, subcl, errblock);
	  writeln('    Class: ',excl:1);
	  writeln('    Subclass: ',subcl:1);

	  { return to calling program }
	  writeln('RESUMING PROGRAM');
	  OsExitH(0,errblock);

	end {osexch};
{$P}
{
	TESTEXCH: Test exception handling
}
	procedure testexch;

	var
		equit: boolean;

	begin
	  equit := false;
	  while (~equit) do begin

500:	    errloc := 5;
	    writeln;
	    writeln(' 1. Display Exception Class status');
	    writeln(' 2. Disable Exception Class');
	    writeln(' 3. Enable Exception Class');
	    writeln(' 4. Get Handler Code');
	    writeln(' 5. Set Handler Code');
	    writeln(' 6. Set Default Handler');
	    writeln(' 7. Raise Exception');
	    writeln(' 8. Test Range Checking');
	    writeln(' 9. Resume Main Menu');
	    writeln;
	    write('     Select test: ');
	    readln(testnum);

	    if ((testnum<1) | (testnum>9)) then
	      writeln('     Invalid selection')
	    else begin
	      case testnum of
	      1: dispexch;
	      2: disexc;
	      3: enaexc;
	      4: getexh;
	      5: setexh;
	      6: setdefh;
	      7: raisex;
	      8: chkrng;
	      9: equit := true;
	      end {case};
	    end {if};

	  end {while};

	end {testexch};
{$P}

	{ Main Program }
	begin

	  { Initialize variables }
	  errloc := 0;
	  blhead := nil;
	  slhead := nil;
	  cladone := false;
	  filename.limit := OSSTRMAX;

	  { Announce and initialize }
	  writeln('MOSI-Pascal Interface Test Program');
	  writeln('Main Test Suite');
	  writeln;
	  OsIntPg(pid,errblock);
	  chkerr('INITIALIZE_PROGRAM            ');

	  { Begin main menu loop }
	  quit := false;
	  while (~quit) do begin

100:	    errloc := 1;
	    writeln;
	    writeln(' 1. Display System Characteristics');
	    writeln(' 2. Display Command Line Arguments');
	    writeln(' 3. Display Memory Status');
	    writeln(' 4. Display I/O Assignments');
	    writeln(' 5. Display Exception Handling Status');
	    writeln(' 6. Display Last Error');
	    writeln(' 7. Select Memory Management Tests');
	    writeln(' 8. Select I/O Assignment Tests');
	    writeln(' 9. Select Exception Handling Tests');
	    writeln('10. Terminate Program');
	    writeln;
	    write('    Select test: ');
	    readln(testnum);

	    if ((testnum<1) | (testnum>10)) then
	      writeln('    Invalid selection')
	    else begin
	      case testnum of
	      1: dispsysc;
	      2: dispcla;
	      3: dispmem;
	      4: dispioa;
	      5: dispexch;
	      6: disperr;
	      7: testmmgt;
	      8: testioa;
	      9: testexch;
	      10: quit := true;
	      end {case};
	    end {if};

	  end {while};

	  errloc := 0;	{quit if error}
	  writeln('Calling TERMINATE_PROGRAM');
	  ostrmpg(pid,0,errblock);
	  writeln('ERROR: Returned from TERMINATE_PROGRAM!');

999:	  writeln('TEST PROGRAM ABORTED');

	end.
