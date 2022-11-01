{
	MOSIPD00
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	Miscellaneous procedures which do not correspond
	directly to any MOSI function

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	IEEE 855-1985.

}

	external procedure OsGtErr	{GET_ERROR}
		   ( var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD11
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Memory Management
	MODULE:     Simple Memory Management

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsGtAlu	{GET_ALLOCATION_UNIT}
		   ( var AlUnit: Integer;
		     var EB: ErrorBlock);

	external procedure OsGtAmt	{GET_AMOUNT_REMAINING}
		   ( var TotRem: LongInteger;
		     var LargRem: LongInteger;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD21
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Time Management
	MODULE:     Simple Delay

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsDelay	{DELAY}
		   (     TimeValue: Integer;
			 TimeUnit: Integer;
		     var EB: ErrorBlock);


{ End of Procedure Declaration File }
{
	MOSIPD22
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Time Management
	MODULE:     Timer Management

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsConnT	{CONNECT_TIMER}
		   ( var TimerId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsDconT	{DISCONNECT_TIMER}
		   (     TimerId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsInitT	{INITIALIZE_TIMER}
		   (     TimerId: Systemtag;
			 TimeValue: Integer;
			 TimeUnit: Integer;
			 TimeMode: Integer;
		     var EB: ErrorBlock);

	external procedure OsCtrlT	{CONTROL_TIMER}
		   (     TimerId: Systemtag;
			 TimeControl: Integer;
		     var EB: ErrorBlock);

	external procedure OsReadT	{READ_TIMER}
		   (     TimerId: Systemtag;
		     var TimeValue: Integer;
		     var TimeUnit: Integer;
		     var EB: ErrorBlock);

	external procedure OsGtExT	{GET_EXPIRED_TIMER}
		   ( var TimerId: Systemtag;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD23
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Time Management
	MODULE:     Time of Day

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsGtTim	{GET_TIME}
		   ( var TimeValue: LongInteger;
		     var EB: ErrorBlock);

	external procedure OsGtDat	{GET_DATE}
		   ( var DayValue: Integer;
		     var TimeValue: Integer;
		     var EB: ErrorBlock);

	external procedure OsSlpUn	{SLEEP_UNTIL}
		   (     DayValue: Integer;
		         TimeValue: Integer;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD32
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Data Transfer
	MODULE:     Synchronous File I/O

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}

	external procedure OsConn	{CONNECT}
		   (     FileName: OsString;
		     var ConnectId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsDconn	{DISCONNECT}
		   (     ConnectId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsCreat	{CREATE}
		   (     FileName: OsString;
			 FileOrganization: Integer;
			 RecordOrg: Integer;
			 RecordSize: Integer;
		         TextFile: Boolean;
			 InitialSize: Integer;
		     var ConnectId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsExten	{EXTEND}
		   (     ConnectId: Systemtag;
		         Length: LongInteger;
		     var EB: ErrorBlock);

	external procedure OsTrunc	{TRUNCATE}
		   (     ConnectId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsOpen	{OPEN}
		   (     ConnectId: Systemtag;
			 AccessPermission: Integer;
			 AccessMethod: Integer;
			 ExpectedRecordSz: Integer;
		         TextFile: Boolean;
		     var RecordSz: Integer;
		     var EfficientSz: Integer;
		     var EB: ErrorBlock);

	external procedure OsClose	{CLOSE}
		   (     ConnectId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsRead	{READ}
		   (     ConnectId: Systemtag;
		     var Data: Universal;
		     var Amount: Integer;
		     var EB: ErrorBlock);

	external procedure OsWrite	{WRITE}
		   (     ConnectId: Systemtag;
		         Data: Universal;
		     var Amount: Integer;
		     var EB: ErrorBlock);

	external procedure OsRdLin	{READ a line}
		   (     ConnectId: Systemtag;
		     var Data: OsString;
		     var Amount: Integer;
		     var EB: ErrorBlock);

	external procedure OsWrLin	{WRITE a line}
		   (     ConnectId: Systemtag;
		         Data: OsString;
		     var Amount: Integer;
		     var EB: ErrorBlock);

	external procedure OsSeek	{SEEK}
		   (     ConnectId: Systemtag;
			 SeekOrigin: Integer;
		         SeekForward: Boolean;
			 SeekRecord: LongInteger;
		     var CurrentPosn: LongInteger;
		     var EB: ErrorBlock);

	external procedure OsGFInf	{GET_FILE_INFORMATION}
		   (     ConnectId: Systemtag;
		     var IB: InformationBlock;
		     var EB: ErrorBlock);

	external procedure OsGtAcc	{GET_ACCESS_CONTROL}
		   (     ConnectId: Systemtag;
		         Identity: Systemtag;
		     var AcCtrl: Integer;
		     var EB: errorblock);

	external procedure OsChAcc	{CHANGE_ACCESS_CONTROL}
		   (     ConnectId: Systemtag;
		         Identity: Systemtag;
		         AcCtrl: Integer;
		     var EB: ErrorBlock);

	external procedure OsDelet	{DELETE}
		   (     ConnectId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsRenam	{RENAME}
		   (     ConnectId: Systemtag;
		         NewName: OsString;
		     var EB: ErrorBlock);

	external procedure OsGtWkD	{GET_WORKING_DIRECTORY}
		   ( var DirName: OsString;
		     var EB: ErrorBlock);

	external procedure OsChWkD	{CHANGE_WORKING_DIRECTORY}
		   (     DirName: OsString;
		     var EB: ErrorBlock);

	external procedure OsGtIdn	{GET_IDENTITY}
		   (     IdCode: Integer;
		     var Identity: Systemtag;
		     var EB: Errorblock);

{ End of Procedure Declaration File }
{
	MOSIPD33
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Data Transfer
	MODULE:     Asynchronous File I/O

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsIRead	{INITIATE_READ}
		   (     ConnectId: Systemtag;
		     var Data: Universal;
		     var AsynchopId: Processtag;
		     var EB: ErrorBlock);

	external procedure OsIWrit	{INITIATE_WRITE}
		   (     ConnectId: Systemtag;
		         Data: Universal;
		     var AsynchopId: Processtag;
		     var EB: ErrorBlock);

	external procedure OsIRLin	{INITIATE_READ a line}
		   (     ConnectId: Systemtag;
		     var Data: OsString;
		     var AsynchopId: Processtag;
		     var EB: ErrorBlock);

	external procedure OsIWLin	{INITIATE_WRITE a line}
		   (     ConnectId: Systemtag;
		         Data: OsString;
		     var AsynchopId: Processtag;
		     var EB: ErrorBlock);

	external procedure OsISeek	{INITIATE_SEEK}
		   (     ConnectId: Systemtag;
			 SeekOrigin: Integer;
			 SeekForward: Boolean;
			 SeekRecord: LongInteger;
		     var AsynchopId: Processtag;
		     var EB: ErrorBlock);

	external procedure OsXfrWt	{TRANSFER_WAIT}
		   (     AsynchopId: Processtag;
		         WaitTime: Integer;
		     var Status: Boolean;
		     var Amount: Integer;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD51
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Process Management
	MODULE:     Single Process Management

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}

	external procedure OsIntPg	{INITIALIZE_PROGRAM}
		   ( var ProcessId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsTrmPg	{TERMINATE_PROGRAM}
		   (     ProcessId: Systemtag;
			 Status: Integer;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD52
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Process Management
	MODULE:     Multiple Processes

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsCrePr	{CREATE_PROCESS}
		   (     ProgName: OsString;
			 ActivateFlag: Boolean;
			 Priority: Integer;
			 MemAlloc: LongInteger;
			 ParameterBlock: OsMessage;
		     var ProcessId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsDesPr	{DESTROY_PROCESS}
		   (     ProcessId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsSusPr	{SUSPEND_PROCESS}
		   (     ProcessId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsResPr	{RESUME_PROCESS}
		   (     ProcessId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsGtPSt	{GET_PROCESS_STATUS}
		   (     ProcessId: Systemtag;
		     var ProcessState: Integer;
		     var ProcessTime: Integer;
		     var TermStatus: Integer;
		     var EB: ErrorBlock);

	external procedure OsGtPIn	{GET_PROCESS_INFO}
		   (     ProcessId: Systemtag;
		     var Priority: Integer;
		     var MemAlloc: LongInteger;
		     var ParameterBlock: OsMessage;
		     var EB: ErrorBlock);

	external procedure OsChPri	{CHANGE_PRIORITY}
		   (     ProcessId: Systemtag;
			 NewPriority: Integer;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD61
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Process Synchronization & Communication
	MODULE:     Semaphores

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}

	external procedure OsCreSp	{CREATE_SEMAPHORE}
		   (     InitVal: Integer;
		     var SemaphoreId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsSigSp	{SIGNAL_SEMAPHORE}
		   (     SemaphoreId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsWaiSp	{WAIT_SEMAPHORE}
		   (     SemaphoreId: Systemtag;
			 TimeLimit: Integer;
		     var TimeoutFlag: Boolean;
		     var EB: ErrorBlock);

	external procedure OsDelSp	{DELETE_SEMAPHORE}
		   (     SemaphoreId: Systemtag;
		         UncondDelete: Boolean;
		     var InUseFlag: Boolean;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD62
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Process Synchronization & Communication
	MODULE:     Multiple Semaphores

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsMSigS	{MULTIPLE_SIGNAL_SEMAPHORE}
		   (     SemaphoreId: Systemtag;
		         SignalCount: Integer;
		     var EB: ErrorBlock);

	external procedure OsMWaiS	{MULTIPLE_WAIT_SEMAPHORE}
		   (     SemaphoreId: Systemtag;
		         WaitCount: Integer;
		         TimeLimit: Integer;
		     var TimeoutFlag: Boolean;
		     var EB: ErrorBlock);


{ End of Procedure Declaration File }
{
	MOSIPD63
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Process Synchronization & Communication
	MODULE:     Messages

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsCreRp	{CREATE_REPOSITORY}
		   ( var ReposId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsSenMs	{SEND_MESSAGE}
		   (     ReposId: Systemtag;
		         Message: OsMessage;
		         RespId: Systemtag;
		     var MessageId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsRcvMs	{RECEIVE_MESSAGE}
		   (     ReposId: Systemtag;
			 Timelimit: Integer;
		     var Message: OsMessage;
		     var Status: Boolean;
		     var RespId: Systemtag;
		     var MessageId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsDelRp	{DELETE_REPOSITORY}
		   (     ReposId: Systemtag;
			 UncondDelete: Boolean;
		     var Status: Boolean;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD64
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Process Synchronization & Communication
	MODULE:     Messages With Responses

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsRspMs	{RESPOND_MESSAGE}
		   (     Response: OsMessage;
			 MessageId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsWaiRs	{WAIT_RESPONSE}
		   (     MessageId: Systemtag;
			 TimeLimit: Integer;
		     var Status: Boolean;
		     var Response: OsMessage;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD71
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Interface With the Environment
	MODULE:     System Characteristics

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}

	external procedure OsGtSys	{GET_SYSTEM_CHARACTERISTICS}
		   ( var CB: ConfigurationBlock;
		     var EB: ErrorBlock);


{ End of Procedure Declaration File }
{
	MOSIPD72
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Interface with the Environment
	MODULE:     Command String Acquisition

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsGtCmS	{GET_COMMAND_STRING}
		   ( var Command: OsString;
		     var EB: ErrorBlock);

	external procedure OsGtTok	{GET_TOKEN}
		   (     Command: OsString;
		         TokenPos: Integer;
		     var ValidToken: Boolean;
		     var Token: OsString;
		     var NextTokenPos: Integer;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD73
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Interface With the Environment
	MODULE:     Direct Argument Acquisition

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)
}


	external procedure OsGtCnt	{GET_ARGUMENT_COUNT}
		   ( var ArgCount: Integer;
		     var EB: ErrorBlock);

	external procedure OsGtArg	{GET_ARGUMENT}
		   ( var NextArg: OsString;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD74
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Interface With the Environment
	MODULE:     Overlay Management

	Jim Mooney
	Last Edit: July 11, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}


	external procedure OsLdOvl	{LOAD_OVERLAY}
		   (     OverlayName: OsString;
		     var EB: ErrorBlock);


{ End of Procedure Declaration File }
{
	MOSIPD75
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Interface With the Environment
	MODULE:     I/O Assignments

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}



	external procedure OsGtIOA	{GET_IO_ASSIGNMENTS}
		   (     IOChan: Integer;
		     var IOStat: Integer;
		     var IOType: Integer;
		     var FileName: OsString;
		     var ConnectId: Systemtag;
		     var EB: ErrorBlock);

	external procedure OsChIOA	{CHANGE_IO_ASSIGNMENTS}
		   (     IOChan: Integer;
		         FileName: OsString;
		     var EB: ErrorBlock);

{ End of Procedure Declaration File }
{
	MOSIPD81
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Exception Handling
	MODULE:     Default Exception Handler

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}

	external procedure OsDisEx	{DISABLE}
		   (     ExClass: Integer;
		     var EB: ErrorBlock);

	external procedure OsEnaEx	{ENABLE}
		   (     ExClass: Integer;
		     var EB: ErrorBlock);

	external procedure OsGtEnS	{GET_ENABLE_STATUS}
		   (     ExClass: Integer;
		     var ExStat: Boolean;
		     var EB: ErrorBlock);


{ End of Procedure Declaration File }
{
	MOSIPD82
	EXTERNAL MOSI PASCAL PROCEDURE DECLARATIONS

	CAPABILITY: Exception Handling
	MODULE:     Single Exception Handler

	Jim Mooney
	Last Edit: Aug. 4, 1985

	These declarations conform to the MOSI trial use standard
	(IEEE 855-1985)

}

	external procedure OsGetEx	{GET_EXCEPTION_HANDLER}
		   ( var HandlerCode: Integer;
		     var EB: ErrorBlock);

	external procedure OsSetEx	{SET_EXCEPTION_HANDLER}
		   (     HandlerCode: Integer;
		     var EB: ErrorBlock);

	external procedure OsResDf	{RESET_DEFAULT_HANDLER}
		   ( var EB: ErrorBlock);

	external procedure OsRaiEx	{RAISE_EXCEPTION}
		   (     ExClass: Integer;
		         SubClass: Integer;
		     var EB: ErrorBlock);

	external procedure OsGtExC	{GET_EXCEPTION_CODE}
		   ( var ExClass: Integer;
		     var SubClass: Integer;
		     var EB: ErrorBlock);

	external procedure OsExitH	{EXIT_FROM_HANDLER}
		   (     Disposition: Integer;
		     var EB: ErrorBlock);


{ End of Procedure Declaration File }
