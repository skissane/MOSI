{
	MOSI Pascal Common Support Subroutines

	Last Edit: May 28, 1985

	Copyright (C) 1985 by
	  James D. Mooney
	  Dept. of Statistics & Computer Science
	  West Virginia University
	  Morgantown, WV 26506

	This file contains commonly useful subroutines
	to support the use of MOSI in the Pascal Language

{$P}
{
	WRITESTR: Write an OsString
}

	procedure writestr(str: OsString);

	var
		i: integer;

	begin
	  for i := 1 to str.Len do
	    write(str.Data[i]);
	end {writestr};

{
	READSTR: Read an OsString
}
	procedure readstr( var str: OsString);

	var
		ch: char;
		ccnt: integer;

	begin
	  ccnt := 0;
	  while not eoln do begin
	    read(ch);
	    if (ccnt < str.limit) then begin
	      ccnt := ccnt + 1;
	      str.data[ccnt] := ch;
	    end {if};
	  end {while};
	  if ch = ' ' then ccnt := ccnt - 1;
	  str.len := ccnt;
	  readln;
	end {readstr};
{$P}
{
	WRITELONG: Write a LongInteger

	A MOSI long integer is a pair of integers interpreted as a
	2-digit number in base (MAXINT+1).  Negative values are
	represented by negating BOTH parts.

	  lval[1] = low order part
	  lval[2] = high order part
}
	procedure writelong (    lval: longinteger);

	var
		mq, mr: integer;
		hi, hr: integer;
		lo, lr: integer;
		numdig: integer;
		done: boolean;
		neg: boolean;
		i: integer;
		digits: array [1..10] of char;

	begin

	  { initialize variables }
	  done := false;
	  numdig := 0;
	  lo := lval[1];
	  hi := lval[2];

	  { determine sign, get unsigned value }
	  neg := false;
	  if hi < 0 then begin
	    hi := -hi;
	    lo := -lo;
	    neg := true;
	  end;

	  { set mq, mr to quotient and remainder of
	    (MAXINT+1) divided by 10 }
	  mq := MAXINT div 10;
	  mr := (MAXINT mod 10) + 1;
	  if mr=10 then begin
	    mq := mq + 1;
	    mr := 0;
	  end;

	  { divide repeatedly by 10, store in digits array }
	  repeat
	    hr := hi mod 10;
	    hi := hi div 10;
	    lr := (lo mod 10) + (hr*mr);
	    lo := (lo div 10) + (hr*mq) + (lr div 10);
	    lr := lr mod 10;
	    numdig := numdig + 1;
	    digits[numdig] := chr(ord('0')+lr);
	    if (lo=0) and (hi=0) then done := true;
	  until done;

	  { write value with optional sign }
	  if neg then write('-');
	  for i := numdig downto 1 do write(digits[i]);

	end {writelong};

{
	READLONG: Read a LongInteger

	  Reads a long integer with optional sign, skipping
	  leading blanks or tabs.  Reads up to and including the
	  first non-digit character.  No check for overflow.
}
	procedure readlong ( var lval: longinteger; {value returned}
			     var ok: boolean);	    { true if valid}

	const
		TAB = 9;	{ASCII tab character}

	var
		mq, mr: integer; {working variables}
		lo, hi: integer;
		neg: boolean;    {sign flag}
		dval: integer;   {current digit value}
		carry: integer;  {carry to high order}
		ch: char;        {current character}

	begin

	  { initialize flags and values }
	  lo := 0;
	  hi := 0;
	  ok := false;
	  neg := false;

	  { read to non-blank char }
	  repeat
	    read(ch)
	  until (ch <> ' ') and (ch <> chr(TAB));

	  { process leading sign, if any }
	  if ch = '+' then read(ch)
	  else if ch = '-' then begin
	    neg := true;
	    read(ch);
	  end {if};

	  { set mq, mr to quotient and remainder of
	    (MAXINT+1) divided by 10 }
	  mq := MAXINT div 10;
	  mr := (MAXINT mod 10) + 1;
	  if mr=10 then begin
	    mq := mq + 1;
	    mr := 0;
	  end {if};

	  { repeat process for each digit }
	  while (ch>='0') and (ch<='9') do begin

	    { flag ok, init values }
	    ok := true;
	    dval := ord(ch) - ord('0');
	    carry := 0;

	    { multiply lo by 10, determine carry }
	    while (lo > mq) do begin
	      lo := lo - mq;
	      carry := carry + 1;
	    end {while};
	    if (lo=mq) and (mr=0) then begin
	      lo := 0;
	      carry := carry + 1;
	    end else lo := (lo*10) - (carry*mr);

	    { add digit value, adjust carry }
	    if lo > (MAXINT-dval) then begin
	      lo := lo - MAXINT;
	      lo := lo + dval - 1;
	      carry := carry + 1;
	    end else lo := lo + dval;

	    { compute high order part }
	    hi := hi*10 + carry;

	    {read next character & repeat }
	    read(ch);

	  end {while};

	  { adjust sign if negative }
	  if (ok and neg) then begin
	    lo := -lo;
	    hi := -hi;
	  end {if};

	  { copy to output parameter }
	  lval[1] := lo;
	  lval[2] := hi;

	end {readlong};

{ End of Common Subroutines }
