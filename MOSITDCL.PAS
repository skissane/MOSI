{
	MOSI Type Declarations

	Jim Mooney
	Last Edit: May 15, 1985


	This file contains type declarations
	for the MOSI-Pascal interface.
	This version conforms to IEEE 855-1985.
}

		Systemtag = Integer;
		Processtag = Integer;
		LongInteger = array[1..2] of Integer;


		OsString = record
		  Limit: Integer;
		  Len: Integer;
		  Data: packed array[1..OSSTRMAX] of char
		end;

		OsMessage = record
		  Limit: Integer;
		  Len: Integer;
		  Data: packed array[1..OSMESMAX] of Integer
		end;

		Universal = record
		  case iotype: integer of
		    1: (intval8: 0..255);
		    2: (intval16: -32767..32767);
		    3: (intval: Integer);
		    4: (realval: Real);
		    5: (charval: Char);
		    6: (boolval: Boolean);
		end;

		ErrorBlock = record
		  Class: Integer;
		  Reason: Integer;
		  SystemInfo: array[1..2] of Integer
		end;

		ConfigurationBlock = record
		  ConfCode: Integer;
		  MOSIStandard: Integer;
		  VersionId: OsString;
		  SystemName: OsString;
		  SystemSerialNumber: OsString;
		  GMTDifference: Integer;
		  BitsByte: Integer;
		  BitsAddrUnit: Integer
		end;

		InformationBlock = record
		  FileName: OsString;
		  Open: Boolean;
		  Temporary: Boolean;
		  TextFile: Boolean;
		  RecordSize: Integer;
		  RecordOrg: Integer;
		  FileLength: LongInteger;
		  Position: LongInteger;
		  EfficientSize: Integer;
		  AccessPermission: Integer;
		  AccessMethod: Integer;
		  FileOrg: Integer;
		  CreateTime: LongInteger;
		  CreateDate: Integer;
		  LastModTime: LongInteger;
		  LastModDate: Integer;
		  LastAccTime: LongInteger;
		  LastAccDate: Integer
		end;

{ End of Type Declaration File }
