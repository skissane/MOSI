{
	MOSI Pascal Common Subroutines

	Last Edit: May 20, 1985

	Copyright (C) 1985 by
	  James D. Mooney
	  Dept. of Statistics & Computer Science
	  West Virginia University
	  Morgantown, WV 26506

	This file contains common procedures
	for the MOSI-Pascal test programs
}
{$P}
{
	PAUSE: Wait until key typed
}
	procedure pause;

	begin
	  writeln;
	  writeln('TYPE RETURN TO CONTINUE');
	  readln;
	end {pause};

{
	GETYN: Get "y" or "n" from terminal input
}
	function getyn: boolean;

	var
		ans: osstring;
		ok: boolean;

	begin
	  ans.limit := OSSTRMAX; {init string buffer}
	  repeat
	    readstr(ans);
	    ok := true;
	    if (ans.len = 1) and (ans.data[1] = 'y')
	      then getyn := true
	    else if (ans.len = 1) and (ans.data[1] = 'n')
	      then getyn := false
	    else begin	{invalid input}
	      write('Invalid input - enter y or n: ');
	      ok := false;
	    end {if};
	  until ok;
	end {getyn};


{ End of Common Procedures }
