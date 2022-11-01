{
			MODREL

	Modify REL format files by editing name fields

	Jim Mooney
	Last Edit: Sept. 17, 1985

	  This program processes a REL file produced by RMAC, and
	extends its entry names from 6 to 7 letters.  It requires the
	SYM file produced by the same RMAC assembly.

	  The REL file format is described in the Digital Research
	"Programmers Guide for the CP/M family of Operating Systems,"
	Sept. 1982, p. 246, which is supplied with RMAC.

	  A name is extended when an existing 6-char name in the
	REL file matches the first six characters of a 7-char name
	in the SYM file.  Ambiguous cases are reported but not
	modified.  See the documentation file MODREL.DOC for further
	information.

	  This program conforms to IEEE 855-1985 (MOSI).  It is
	written in Pascal for the Pascal-MT+ compiler.
}

	program modrel(input,output);

	label
		999;	{end of program}

	const

{$I MOSICDCL.PAS}	{Include MOSI constant definitions}

		MAXSYM = 500; {max no. of symbols accepted}
		TAB = 9;

		ERCSFIO = 3; {Error Class File I/O}
		ERRFNF = 2; {Error reason = File Not Found}
		ACPMREAD = 2; {READ access permission}
		ACPMWREX = 12; {WRITE & EXTEND access permission}
		ACMTSTRM = 1; {Access method = stream}
		ACMTSEQ = 2; {Access method = sequential}
		FORGSEQ = 1; {File organization = sequential}
		RORGFLEN = 1; {Record organization = fixed len}
		IOINT8 = 1; {IO type = 8-bit integer}

	type

{$I MOSITDCL.PAS}	{Include MOSI type declarations}

	var
		errblock: errorblock;	{MOSI error block}
		pid:	integer;	{MOSI process id}

		tempname: osstring;	{temporary input name}
		inname: osstring;	{input file name}
		inid: systemtag;	{input file id}
		inbuf: universal;	{input file buffer}
		outname: osstring;	{output file name}
		outid: systemtag;	{output file id}
		outbuf: universal;	{output file buffer}
		symfname: osstring;	{symbol file name}
		symid: systemtag;	{symbol file id}

		eofin: boolean;		{input file eof flag}
		eofsym: boolean;	{symbol file eof flag}
		amtxfr: integer;	{amount of I/O transfer}

		data1,data2: byte; 	{temporary bytes}
		cbyte: byte;		{current input byte}
		curbit: integer;	{current input bit position}
		obyte: byte;		{current output byte}
		obits: integer; 	{output bit count}
		idone: boolean;		{true when input complete}
		numsym: integer; 	{no. of 7-char symbols in table}
		lastval: integer; 	{last value processed}

		{ value table for saved symbols - not currently used }
		symval: array[1..MAXSYM] of integer;

		{ saved symbol names and extension characters }
		symname: array[1..MAXSYM] of string[8];
		xchar: array[1..MAXSYM] of char;

{	Include MOSI procedure declarations }

{$I MOSIPD32.PAS}	{Synchronous file I/O}
{$I MOSIPD51.PAS}	{Single Process Management}
{$I MOSIPD73.PAS}	{Direct Argument Acquisition}

{$I MOSISUBS.PAS}	{MOSI support procedures}

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
	GETBYTE: Read a data byte
}
	procedure getbyte;

	begin

	  { if at eof, return a 0 }
	  if eofin then begin
	    cbyte := 0;
	    idone := true;
	    end

	  { otherwise, read a byte }
	  else begin
	    osread(inid,inbuf,amtxfr,errblock);
	    chkerr;
	    if amtxfr<=0 then begin
	      eofin := true;
	      cbyte := 0;
	      idone := true;
	    end else begin
	      cbyte := inbuf.intval8;
	      curbit := 8;
	    end {if}
	  end {if}
	end {getbyte};

{
	PUTBYTE: Write a data byte
}
	procedure putbyte;

	begin
	  outbuf.intval8 := obyte;
	  oswrite(outid,outbuf,amtxfr,errblock);
	  chkerr;
	  obyte := 0;
	  obits := 0;
	end {putbyte};


{
	GETD: Get data bits

	gets the number of input bits specified by nbits,
	right justified in the returned byte.
}
	function getd(nbits: integer): byte;

	var
		mask: byte;
		temp: byte;
		data: byte;
		bnum: integer;

	begin

	  { set mask value }
	  case nbits of
	  1: mask := 1;
	  2: mask := 3;
	  3: mask := 7;
	  4: mask := 15;
	  5: mask := 31;
	  6: mask := 63;
	  7: mask := 127;
	  8: mask := 255;
	  end {case};

	  if curbit=0 then getbyte;

	  { all bits in current byte? }
	  if curbit >= nbits then begin
	    temp := shr(cbyte,curbit-nbits);
	    data := temp & mask;
	    curbit := curbit - nbits;
	    end

	  { get bits from two bytes }
	  else begin
	    temp := shl(cbyte,nbits-curbit);
	    data := temp & mask;
	    bnum := curbit - nbits + 8;
	    getbyte;
	    temp := shr(cbyte,bnum);
	    data := data + (temp & mask);
	    curbit := bnum;
	  end;

	getd := data;
	end {getd};


{
	PUTD: Output data bits

	output the rightmost "nbits" bits from val.
}
	procedure putd(nbits: integer; val: byte);

	var
		temp: byte;
		shcnt: integer;

	begin

	  shcnt := 8 - obits - nbits;

	  if shcnt >= 0 then begin
	    temp := shl(val,shcnt);
	    obyte := obyte | temp;
	    obits := obits + nbits;
	    end

	  { split over two bytes }
	  else begin
	    temp := shr(val,-shcnt);
	    obyte := obyte | temp;
	    nbits := nbits + obits - 8;
	    putbyte;
	    temp := shl(val,8-nbits);
	    obyte := obyte | temp;
	    obits := nbits;
	  end;

	  if obits >= 8 then putbyte;

	end {putd};

	      

{
	RELVAL: Process a relocatable value
}
	procedure relval(seg: string);

	begin
	  data1 := getd(8);
	  putd(8,data1);
	  data2 := getd(8);
	  putd(8,data2);
	end {relval};


{
	VALFLD: Process a value field
}
	procedure valfld;

	var
		vtype: byte;

	begin
	  vtype := getd(2);
	  putd(2,vtype);
	  data1 := getd(8);
	  putd(8,data1);
	  data2 := getd(8);
	  putd(8,data2);
	  lastval := shl(data1,8) | data2;
	end {valfld};


{
	NAMFLD: Process a name field
	  passes name field without change
}
	procedure namfld;

	var
		i,nch: integer;

	begin
	  nch := getd(3);	{get char count}
	  putd(3,nch);
	  for i := 1 to nch do begin
	    data1 := getd(8);
	    putd(8,data1);
	  end {for};
	end {namfld};



{
	LKUPNAM: Lookup a name in the saved name table

	Determines if the test name is present in the name table,
	and how many times it is duplicated.
}
	procedure lkupnam (     tstr: string; {test string}
			    var pos: integer; {position if found}
			    var num: integer); {number of matches}
	var
		low: integer;
		high: integer;
		done: boolean;
		xpos: integer; {temporary position}

	begin

	  { perform binary search for matching string }
	  done := false;
	  num := 0;
	  low := 1;
	  high := numsym;
	  while not done do begin
	    pos := (low + high) div 2;
	    if high < low then done := true
	    else if tstr = symname[pos] then begin
	      done := true;
	      num := 1;
	    end
	    else begin
	      if tstr < symname[pos] then
	        high := pos - 1
	      else
	        low := pos + 1;
	    end {if};
	  end {while};

	  { if no match found, terminate }
	  { otherwise, look for other adjacent matches }
	  if num = 0 then pos := 0
	  else begin

	    { check for matches after current one }
	    done := false;
	    xpos := pos + 1;
	    while not done do begin
	      if xpos > numsym then done := true
	      else if tstr <> symname[xpos] then done := true
	      else begin
	        num := num + 1;
	        xpos := xpos + 1;
	      end {if};
	    end {while};

	    { check for matches before original one }
	    done := false;
	    xpos := pos - 1;
	    while not done do begin
	      if xpos < 1 then done := true
	      else if tstr <> symname[xpos] then done := true
	      else begin
	        num := num + 1;
	        pos := xpos; {keep pos on first match}
	        xpos := xpos - 1;
	      end {if};
	    end {while};

	  end {if};

	end {lkupnam};



{
	ENAMFLD: Edit a name field
	  extends name if matched in symbol table
}
	procedure enamfld;

	var
		i,nch: integer;
		nstr: string[8];
		pos: integer;
		nmatch: integer;

	begin

	  { read in name string }
	  nch := getd(3);	{get char count}
	  nstr := '';	{clear string}
	  for i := 1 to nch do begin
	    insert(chr(getd(8)),nstr,i);
	  end {for};

	  { modify string if matched }
	  if nch=6 then begin
	    lkupnam(nstr,pos,nmatch);
	    if nmatch = 1 then begin {single match}
	      if xchar[pos] <> ' ' then begin
	        nstr[7] := xchar[pos];
	        nch := 7;
	      end {if};
	    end
	    else if nmatch > 1 then begin {multiple match}
	      writeln('AMBIGUOUS SYMBOL (not changed) : ',nstr);
	      for i := 1 to nmatch do begin
	        writeln(i:3,'. ',symname[pos+i-1],xchar[pos+i-1]);
	      end {for};
	    end {if};
	  end {if};

	  { output and display }
	  putd(3,nch);
	  for i := 1 to nch do begin
	    putd(8,nstr[i]);
	  end {for};

	end {enamfld};


{
	LINKITEM: Process a linkitem
}
	procedure linkitem;

	begin
	  data1 := getd(4);
	  putd(4,data1);

	  case data1 of

	  0: begin {Entry}
	    enamfld;
	    end;

	  1: begin {Common Block}
	    namfld;
	    end;

	  2: begin {Module Name}
	    namfld;
	    end;

	  5: begin {Common Size}
	    valfld;
	    namfld;
	    end;

	  6: begin {External Chain}
	    valfld;
	    enamfld;
	    end;

	  7: begin {Entry Definition}
	    valfld;
	    enamfld;
	    end;

	  9: begin {External plus offset}
	    valfld;
	    end;

	  10: begin {Data Size}
	    valfld;
	    end;

	  11: begin {Set Location Counter}
	    valfld;
	    end;

	  12: begin {Address Chain}
	    valfld;
	    end;

	  13: begin {Program Size}
	    valfld;
	    end;

	  14: begin {End of Module}
	    valfld;
	    curbit := 0; {skip to new input byte}
	    if obits > 0 then putbyte; {finish output byte}
	    end;

	  15: begin  {End of File}
	    idone := true;
	    end;

	  3,4,8: begin
	    writeln('INVALID ITEM:',data1:3);
	    idone := true;
	    end;

	  end {case};

	end {linkitem};


{
	ADDTOSTR: Add character to a string
}
	procedure addtostr (     newch: char; {char to add}
			     var str: osstring); {string to add to}
	begin
	  if str.len < str.limit then begin
	    str.len := str.len + 1;
	    str.data[str.len] := newch;
	  end {if};
	end {addtostr};

{
	COPYSTR: Copy a string
}
	procedure copystr ( var str1: osstring; {source string}
			    var str2: osstring); {destination string}
	var
		i: integer;
	begin
	  for i := 1 to str1.len do
	    str2.data[i] := str1.data[i];
	  str2.len := str1.len;
	end {copystr};

{
	GETFNAM: Get input file name(s)
	  Get file name root from command line or query
	  construct actual names
}

	procedure getfnam;

	var
		argcount: integer;
		ix: integer;
		ixsav: integer;

	begin

	  { initialize name strings }
	  tempname.limit := OSSTRMAX;
	  tempname.len := 0;
	  inname.limit := OSSTRMAX;
	  inname.len := 0;
	  outname.limit := OSSTRMAX;
	  outname.len := 0;
	  symfname.limit := OSSTRMAX;
	  symfname.len := 0;

	  osgtcnt(argcount,errblock);
	  chkerr;
	  if argcount>1 then begin
	    writeln('Too many arguments');
	    goto 999;
	  end {if};
	  if argcount<1 then begin
	    write('File Name: ');
	    readstr(tempname);
	  end
	  else begin
	    osgtarg(tempname,errblock);
	    chkerr;
	  end {if};

	  { build complete names }
	  ixsav := 0;
	  for ix := 1 to tempname.len do
	    if tempname.data[ix] = '.' then ixsav := ix;
	  copystr(tempname, inname);
	  if ixsav > 0 then tempname.len := ixsav - 1
	  else begin
	    addtostr('.',inname);
	    addtostr('R',inname);
	    addtostr('E',inname);
	    addtostr('L',inname);
	  end;
	  copystr(tempname,outname);
	  addtostr('.',outname);
	  addtostr('$',outname);
	  addtostr('$',outname);
	  addtostr('$',outname);
	  copystr(tempname,symfname);
	  addtostr('.',symfname);
	  addtostr('S',symfname);
	  addtostr('Y',symfname);
	  addtostr('M',symfname);

	end {getfnam};


{
	OPENIO: Connect and open input and output files
}
	procedure openio;

	var
		recsize: integer;
		effsize: integer;
		initsz: integer;

	begin

	  { connect REL file, check existence }
	  osconn(inname,inid,errblock);
	  if (errblock.class=ERCSFIO) and (errblock.reason=ERRFNF) then begin
	    writeln('REL file not found');
	    goto 999;
	  end {if};
	  chkerr;

	  { open REL file for stream input }
	  osopen ( inid,	{connect id}
		   ACPMREAD,	{access perm: read}
		   ACMTSTRM,	{access method: stream}
		   1,		{record size: 1}
		   false,	{not a textfile}
		   recsize,	{returned recordsize}
		   effsize,	{returned efficient size}
		   errblock);
	  chkerr;

	  { check temp file, delete if present }
	  osconn(outname,outid,errblock);
	  if (errblock.class=0) then begin
	    osdelet(outid,errblock);
	    chkerr;
	  end
	  else if (errblock.class<>ERCSFIO) or (errblock.reason<>ERRFNF) then
	    chkerr;

	  { create temp file }
	  initsz := 1000;
	  oscreat ( outname,	{file name}
		    FORGSEQ,	{file org = sequential}
		    RORGFLEN,	{rec org = fixed len}
		    1,		{rec size = 1}
		    false,	{not a text file}
		    initsz,	{initial size}
		    outid,	{connect id}
		    errblock);
	  chkerr;

	  { open temp file for stream output }
	  osopen ( outid,	{connect id}
	  	   ACPMWREX,	{access perm: write, extend}
		   ACMTSTRM,	{access method: stream}
		   1,		{record size: 1}
		   false,	{not a text file }
		   recsize,	{returned record size}
		   effsize,	{returned efficient size}
		   errblock);
	  chkerr;

	  { setup type code in buffer variables }
	  inbuf.iotype := IOINT8;
	  outbuf.iotype := IOINT8;

	end {openio};


{
	READSYM: Read in the symbol table
	  store values and names for 7-char symbols only
}
	procedure readsym;

	var
		i: integer;
		sval: integer; {temp hex value}
		cval: integer; {value for current digit}
		ch: char; {current input char}
		symstr: string; {symbol string}
		spos: integer; {current pos'n in symbol string}
		symline: osstring; {symbol file line}
		sympos: integer; {position in input line}
		done: boolean; {loop exit flag}
		tname: string[8]; {temp name string to insert}
		tchar: char; {7th character of tname}
		tpos: integer; {position in symbol array}
		recsize: integer; {MOSI record size}
		effsize: integer; {MOSI efficient size}

	{
		nxsymch: get next char from SYM file
	}
	function nxsymch: char;

	  begin
	    if sympos >= symline.len then begin
	      osrdlin(symid,symline,amtxfr,errblock);
	      chkerr;
	      if amtxfr < 0 then eofsym := true;
	      sympos := 0;
	      nxsymch := chr(TAB);
	    end else begin
	      sympos := sympos + 1;
	      nxsymch := symline.data[sympos];
	    end {if};
	  end {nxsymch};


	begin {readsym}

	  symline.limit := OSSTRMAX;
	  symline.len := 0;

	  { connect file, check for existence }
	  osconn ( symfname, symid, errblock );
	  if (errblock.class=ERCSFIO) and (errblock.reason=ERRFNF) then begin
	    writeln('File not found');
	    goto 999;
	  end {if};
	  chkerr;

	  { open file for input by text lines }
	  osopen ( symid,	{file id}
		   ACPMREAD,	{access perm: read}
		   ACMTSEQ,	{access method: seq rec}
		   0,		{record size: 0 (var. len.)}
		   true,	{textfile flag}
		   recsize,	{returned record size}
		   effsize,	{returned efficient size}
		   errblock);
	  chkerr;

	  eofsym := false;
	  numsym := 1;

	  sympos := 0;
	  symline.len := 0;
	  ch := nxsymch;

	  while ((not eofsym) and (numsym<=MAXSYM)) do begin

	    { read in 4-digit hex value }
	    sval := 0;
	    for i := 1 to 4 do begin
	      ch := nxsymch;
	      if ch=chr(TAB) then ch := nxsymch; {skip any extra tab}
	      sval := shl(sval,4);
	      if (ch >= 'A') then cval := ord(ch)-ord('A')+10
	      else cval := ord(ch)-ord('0');
	      sval := sval | cval;
	    end {for};

	    {skip blank}
	    ch := nxsymch;

	    { read in symbol name }
	    symstr := '';
	    spos := 0;
	    ch := nxsymch;
	    while (ch<>chr(TAB)) do begin
	      spos := spos + 1;
	      insert(ch,symstr,spos);
	      ch := nxsymch;
	    end {while};

	    { if at least 6 chars, save it }
	    if length(symstr) >= 6 then begin
	      if length(symstr) = 6 then begin
	        tname := symstr;
	        tchar := ' ';
	      end
	      else begin
	        tname := copy(symstr,1,6);
	        tchar := symstr[7];
	      end {if};

	      { insert saved string and related info
	        into arrays, and ensure that arrays remain
	        in sorted order.
	      }
	      tpos := numsym;
	      done := false;
	      while not done do begin
	        if tpos <= 1 then done := true
	        else if tname >= symname[tpos-1] then done := true
	        else begin
	          symname[tpos] := symname[tpos-1];
	          xchar[tpos] := xchar[tpos-1];
	          symval[tpos] := symval[tpos-1];
	          tpos := tpos - 1;
	        end {if};
	      end {while};
	      symname[tpos] := tname;
	      xchar[tpos] := tchar;
	      symval[tpos] := sval;
	      numsym := numsym + 1;
	    end {if};

	    if numsym>MAXSYM then writeln('SYMBOL TABLE FULL');
	  end {while};
	  numsym := numsym-1;

	  osdconn(symid,errblock);

	end {readsym};


	{
		MODREL: Main Program
	}
	begin

	  writeln('MODREL V1.0');

	  {initialize for MOSI}
	  osintpg(pid,errblock);
	  chkerr;

	  getfnam;	{get file name(s)}
	  openio;	{open input & output files}
	  readsym;	{read symbol file}

	  curbit := 0;
	  obits := 0;
	  obyte := 0;
	  idone := false;

	  while (not idone) do begin

	    data1 := getd(1);
	    putd(1,data1);

	    { code 0: absolute data byte }
	    if (data1 = 0) then begin
	      data1 := getd(8);
	      putd(8,data1);
	      end

	    { otherwise, decode further }
	    else begin
	      data1 := getd(2);
	      putd(2,data1);

	      case data1 of
	      0: linkitem;
	      1: relval('(rp)');
	      2: relval('(rd)');
	      3: relval('(rc)');
	      end {case};
	    end;

	  end {while};
	  if obits > 0 then putbyte;

	  osclose(inid,errblock);
	  chkerr;
	  osdelet(inid,errblock);
	  chkerr;
	  osrenam(outid,inname,errblock);
	  chkerr;
	  osdconn(outid,errblock);
	  chkerr;
	  writeln('File Modification Complete');
	  write('Modified File: ');
	  writestr(inname);
	  writeln;

	  { terminate program }
999:	  ostrmpg(pid,0,errblock);

	end.
