unit OKCardMan;

interface

type
    SCARDHANDLE = cardinal;
    PUCHAR      = array[0..1024] of char; //^byte;

    UCHAR       = array [0..1024] of char;
    ULONG       = cardinal;
    PULONG      = ^cardinal; // array[0..2048] of Byte; //^cardinal;

{SCARD Delphi}
{ *******************************************************
' Common SCard functions
' *******************************************************
{ *******************************************************
' Constants
' *******************************************************

'
' Scopes
}
Const SCARD_SCOPE_USER       : ULONG = 0;    // 'The context is a user context, and any
                                             // ' database operations are performed within the
                                             // ' domain of the user.
Const SCARD_SCOPE_TERMINAL   : ULong = 1;   // 'The context is that of the current terminal,
                                            //  ' and any database operations are performed
                                            //  ' within the domain of that terminal.  (The
                                            //  ' calling application must have appropriate
                                            //  ' access permissions for any database actions.)
Const SCARD_SCOPE_SYSTEM:  ULong = 2;       //  'The context is the system context, and any
                                            //  ' database operations are performed within the
                                            //  ' domain of the system.  (The calling
                                            //  ' application must have appropriate access
                                            //  ' permissions for any database actions.)

{
' Share Modes
}
Const SCARD_SHARE_EXCLUSIVE : ULong = 1; // This application is not willing to share this
                                        // card with other applications.
Const SCARD_SHARE_SHARED    : ULong = 2; // This application is willing to share this
                                        // card with other applications.
Const SCARD_SHARE_DIRECT    : ULong = 3; // This application demands direct control of
                                        // the reader, so it is not available to other
                                        // applications.
Const SCARD_ATTR_ATR_STRING : ULong = 590595;

{
' Protocols
}
Const SCARD_PROTOCOL_UNDEFINED   : ULong = $0;       //' There is no active protocol.
Const SCARD_PROTOCOL_T0          : ULong = $1;       //' T=0 is the active protocol.
Const SCARD_PROTOCOL_T1          : ULong = $2;       //' T=1 is the active protocol.
Const SCARD_PROTOCOL_RAW         : ULong = $10000;   //'&H10000 Raw is the active protocol.


{
' Dispositions (after disconnecting)
}
Const SCARD_LEAVE_CARD   : ULong = 0;   //' Don't do anything special on close
Const SCARD_RESET_CARD   : ULong = 1;   //' Reset the card on close
Const SCARD_UNPOWER_CARD : ULong = 2;   //' Power down the card on close
Const SCARD_EJECT_CARD   : ULong = 3;   //' Eject the card on close

{
' Smart Card Error Codes
' All for SCARD error codes of the resource manager , a OK error code exists.
}
Const OKERR_SCARD__E_CANCELLED                : ULONG = $80100002 ; //@cnst  The action was cancelled by an SCardCancel request
Const OKERR_SCARD__E_INVALID_HANDLE           : ULONG = $80100003 ; //@cnst  The supplied handle was invalid
Const OKERR_SCARD__E_INVALID_PARAMETER        : ULONG = $80100004 ; //@cnst  One or more of the supplied parameters could not be properly interpreted
Const OKERR_SCARD__E_INVALID_TARGET           : ULONG = $80100005 ; //@cnst  Registry startup information is missing or invalid
Const OKERR_SCARD__E_NO_MEMORY                : ULONG = $80100006 ; //@cnst  Not enough memory available to complete this command
Const OKERR_SCARD__F_WAITED_TOO_LONG          : ULONG = $80100007 ; //@cnst  An internal consistency timer has expired
Const OKERR_SCARD__E_INSUFFICIENT_BUFFER      : ULONG = $80100008 ; //@cnst  The data buffer to receive returned data is too small for the returned data
Const OKERR_SCARD__E_UNKNOWN_READER           : ULONG = $80100009 ; //@cnst  The specified reader name is not recognized
Const OKERR_SCARD__E_TIMEOUT                  : ULONG = $8010000A ; //@cnst  The user-specified timeout value has expired
Const OKERR_SCARD__E_SHARING_VIOLATION        : ULONG = $8010000B ; //@cnst  The smart card cannot be accessed because of other connections outstanding
Const OKERR_SCARD__E_NO_SMARTCARD             : ULONG = $8010000C ; //@cnst  The operation requires a Smart Card, but no Smart Card is currently in the device
Const OKERR_SCARD__E_UNKNOWN_CARD             : ULONG = $8010000D ; //@cnst  The specified smart card name is not recognized
Const OKERR_SCARD__E_CANT_DISPOSE             : ULONG = $8010000E ; //@cnst  The system could not dispose of the media in the requested manner
Const OKERR_SCARD__E_PROTO_MISMATCH           : ULONG = $8010000F ; //@cnst  The requested protocols are incompatible with the protocol currently in use with the smart card
Const OKERR_SCARD__E_NOT_READY                : ULONG = $80100010 ; //@cnst  The reader or smart card is not ready to accept commands
Const OKERR_SCARD__E_INVALID_VALUE            : ULONG = $80100011 ; //@cnst  One or more of the supplied parameters values could not be properly interpreted
Const OKERR_SCARD__E_SYSTEM_CANCELLED         : ULONG = $80100012 ; //@cnst  The action was cancelled by the system, presumably to log off or shut down
Const OKERR_SCARD__F_COMM_ERROR               : ULONG = $80100013 ; //@cnst  An internal communications error has been detected
Const OKERR_SCARD__F_UNKNOWN_ERROR            : ULONG = $80100014 ; //@cnst  An internal error has been detected, but the source is unknown
Const OKERR_SCARD__E_INVALID_ATR              : ULONG = $80100015 ; //@cnst  An ATR obtained from the registry is not a valid ATR string
Const OKERR_SCARD__E_NOT_TRANSACTED           : ULONG = $80100016 ; //@cnst  An attempt was made to end a non-existent transaction
Const OKERR_SCARD__E_READER_UNAVAILABLE       : ULONG = $80100017 ; //@cnst  The specified reader is not currently available for use
Const OKERR_SCARD__P_SHUTDOWN                 : ULONG = $80100018 ; //@cnst  The operation has been aborted to allow the server application to exit
Const OKERR_SCARD__E_PCI_TOO_SMALL            : ULONG = $80100019 ; //@cnst  The PCI Receive buffer was too small
Const OKERR_SCARD__E_READER_UNSUPPORTED       : ULONG = $8010001A ; //@cnst  The reader driver does not meet minimal requirements for support
Const OKERR_SCARD__E_DUPLICATE_READER         : ULONG = $8010001B ; //@cnst  The reader driver did not produce a unique reader name
Const OKERR_SCARD__E_CARD_UNSUPPORTED         : ULONG = $8010001C ; //@cnst  The smart card does not meet minimal requirements for support
Const OKERR_SCARD__E_NO_SERVICE               : ULONG = $8010001D ; //@cnst  The Smart card resource manager is not running
Const OKERR_SCARD__E_SERVICE_STOPPED          : ULONG = $8010001E ; //@cnst  The Smart card resource manager has shut down
Const OKERR_SCARD__E_UNEXPECTED               : ULONG = $8010001F ; //@cnst  An unexpected card error has occurred
Const OKERR_SCARD__E_ICC_INSTALLATION         : ULONG = $80100020 ; //@cnst  No Primary Provider can be found for the smart card
Const OKERR_SCARD__E_ICC_CREATEORDER          : ULONG = $80100021 ; //@cnst  The requested order of object creation is not supported
Const OKERR_SCARD__E_UNSUPPORTED_FEATURE      : ULONG = $80100022 ; //@cnst  This smart card does not support the requested feature
Const OKERR_SCARD__E_DIR_NOT_FOUND            : ULONG = $80100023 ; //@cnst  The identified directory does not exist in the smart card
Const OKERR_SCARD__E_FILE_NOT_FOUND           : ULONG = $80100024 ; //@cnst  The identified file does not exist in the smart card
Const OKERR_SCARD__E_NO_DIR                   : ULONG = $80100025 ; //@cnst  The supplied path does not represent a smart card directory
Const OKERR_SCARD__E_NO_FILE                  : ULONG = $80100026 ; //@cnst  The supplied path does not represent a smart card file
Const OKERR_SCARD__E_NO_ACCESS                : ULONG = $80100027 ; //@cnst  Access is denied to this file
Const OKERR_SCARD__E_WRITE_TOO_MANY           : ULONG = $80100028 ; //@cnst  An attempt was made to write more data than would fit in the target object
Const OKERR_SCARD__E_BAD_SEEK                 : ULONG = $80100029 ; //@cnst  There was an error trying to set the smart card file object pointer
Const OKERR_SCARD__E_INVALID_CHV              : ULONG = $8010002A ; //@cnst  The supplied PIN is incorrect
Const OKERR_SCARD__E_UNKNOWN_RES_MNG          : ULONG = $8010002B ; //@cnst  An unrecognized error code was returned from a layered component
Const OKERR_SCARD__E_NO_SUCH_CERTIFICATE      : ULONG = $8010002C ; //@cnst  The requested certificate does not exist
Const OKERR_SCARD__E_CERTIFICATE_UNAVAILABLE  : ULONG = $8010002D ; //@cnst  The requested certificate could not be obtained
Const OKERR_SCARD__E_NO_READERS_AVAILABLE     : ULONG = $8010002E ; //@cnst  Cannot find a smart card reader
Const OKERR_SCARD__E_COMM_DATA_LOST           : ULONG = $8010002F ; //@cnst  A communications error with the smart card has been detected
Const OKERR_SCARD__W_UNSUPPORTED_CARD         : ULONG = $80100065 ; //@cnst  The reader cannot communicate with the smart card, due to ATR configuration conflicts
Const OKERR_SCARD__W_UNRESPONSIVE_CARD        : ULONG = $80100066 ; //@cnst  The smart card is not responding to a reset
Const OKERR_SCARD__W_UNPOWERED_CARD           : ULONG = $80100067 ; //@cnst  Power has been removed from the smart card, so that further communication is not possible
Const OKERR_SCARD__W_RESET_CARD               : ULONG = $80100068 ; //@cnst  The smart card has been reset, so any shared state information is invalid
Const OKERR_SCARD__W_REMOVED_CARD             : ULONG = $80100069 ; //@cnst  The smart card has been removed, so that further communication is not possible
Const OKERR_SCARD__W_SECURITY_VIOLATION       : ULONG = $8010006A ; //@cnst  Access was denied because of a security violation
Const OKERR_SCARD__W_WRONG_CHV                : ULONG = $8010006B ; //@cnst  The card cannot be accessed because the wrong PIN was presented
Const OKERR_SCARD__W_CHV_BLOCKED              : ULONG = $8010006C ; //@cnst  The card cannot be accessed because the maximum number of PIN entry attempts has been reached
Const OKERR_SCARD__W_EOF                      : ULONG = $8010006D ; //@cnst  The end of the smart card file has been reached
Const OKERR_SCARD__W_CANCELLED_BY_USER        : ULONG = $8010006E ; //@cnst  The action was cancelled by the user
Const OKERR_PARM1                : ULONG = $81000000 ; //Error in parameter 1
Const OKERR_PARM2                : ULONG = $81000001 ; //Error in parameter 2
Const OKERR_PARM3                : ULONG = $81000002 ; //Error in parameter 3
Const OKERR_PARM4                : ULONG = $81000003 ; //Error in parameter 4
Const OKERR_PARM5                : ULONG = $81000004 ; //Error in parameter 5
Const OKERR_PARM6                : ULONG = $81000005 ; //Error in parameter 6
Const OKERR_PARM7                : ULONG = $81000006 ; //Error in parameter 7
Const OKERR_PARM8                : ULONG = $81000007 ; //Error in parameter 8
Const OKERR_PARM9                : ULONG = $81000008 ; //Error in parameter 9
Const OKERR_PARM10               : ULONG = $81000009 ; //Error in parameter 10
Const OKERR_PARM11               : ULONG = $8100000A ; //Error in parameter 11
Const OKERR_PARM12               : ULONG = $8100000B ; //Error in parameter 12
Const OKERR_PARM13               : ULONG = $8100000C ; //Error in parameter 13
Const OKERR_PARM14               : ULONG = $8100000D ; //Error in parameter 14
Const OKERR_PARM15               : ULONG = $8100000E ; //Error in parameter 15
Const OKERR_PARM16               : ULONG = $8100000F ; //Error in parameter 16
Const OKERR_PARM17               : ULONG = $81000010 ; //Error in parameter 17
Const OKERR_PARM18               : ULONG = $81000011 ; //Error in parameter 18
Const OKERR_PARM19               : ULONG = $81000012 ; //Error in parameter 19
Const OKERR_INSUFFICIENT_PRIV    : ULONG = $81100000 ; //You currently do not have the rights to execute the requested action. Usually a password has to be presented in advance.
Const OKERR_PW_WRONG             : ULONG = $81100001 ; //The presented password is wrong
Const OKERR_PW_LOCKED            : ULONG = $81100002 ; //The password has been presented several times wrong and is therefore locked. Usually use some administrator tool to unblock it.
Const OKERR_PW_TOO_SHORT         : ULONG = $81100003 ; //The lenght of the password was too short.
Const OKERR_PW_TOO_LONG          : ULONG = $81100004 ; //The length of the password was too long.
Const OKERR_PW_NOT_LOCKED        : ULONG = $81100005 ; //The password is not locked
Const OKERR_ITEM_NOT_FOUND       : ULONG = $81200000 ; //An item (e.g. a key of a specific name) could not be found
Const OKERR_ITEMS_LEFT           : ULONG = $81200001 ; //There are still items left, therefore e.g. the directory / structure etc. can; //t be deleted.
Const OKERR_INVALID_CFG_FILE     : ULONG = $81200002 ; //Invalid configuration file
Const OKERR_SECTION_NOT_FOUND    : ULONG = $81200003 ; //Section not found
Const OKERR_ENTRY_NOT_FOUND      : ULONG = $81200004 ; //Entry not found
Const OKERR_NO_MORE_SECTIONS     : ULONG = $81200005 ; //No more sections
Const OKERR_ITEM_ALREADY_EXISTS  : ULONG = $81200006 ; //The specified item alread exists.
Const OKERR_ITEM_EXPIRED         : ULONG = $81200007 ; //Some item (e.g. a certificate) has expired.
Const OKERR_UNEXPECTED_RET_VALUE : ULONG = $81300000 ; //Unexpected return value
Const OKERR_COMMUNICATE          : ULONG = $81300001 ; //General communication error
Const OKERR_NOT_ENOUGH_MEMORY    : ULONG = $81300002 ; //Not enough memory
Const OKERR_BUFFER_OVERFLOW      : ULONG = $81300003 ; //Buffer overflow
Const OKERR_TIMEOUT              : ULONG = $81300004 ; //A timeout has occurred
Const OKERR_NOT_SUPPORTED        : ULONG = $81300005 ; //The requested functionality is not supported at this time / under this OS / in this situation etc.
Const OKERR_ILLEGAL_ARGUMENT     : ULONG = $81300006 ; //Illegal argument
Const OKERR_READ_FIO             : ULONG = $81300007 ; //File IO read error
Const OKERR_WRITE_FIO            : ULONG = $81300008 ; //File IO write error
Const OKERR_INVALID_HANDLE       : ULONG = $81300009 ; //Invalid handle
Const OKERR_GENERAL_FAILURE      : ULONG = $8130000A ; //General failure. Use this error code in cases where no other errors match and it is not worth to define a new error code.
Const OKERR_FILE_NOT_FOUND       : ULONG = $8130000B ; //File not found
Const OKERR_OPEN_FILE            : ULONG = $8130000C ; //File opening failed
Const OKERR_SEM_USED             : ULONG = $8130000D ; //The semaphore is currently use by an other process
Const OKERR_NOP                  : ULONG = $81F00001 ; //No operation done
Const OKERR_NOK                  : ULONG = $81F00002 ; //Function not executed
Const OKERR_FWBUG                : ULONG = $81F00003 ; //Internal error detected
Const OKERR_INIT                 : ULONG = $81F00004 ; //Module not initialized
Const OKERR_FIO                  : ULONG = $81F00005 ; //File IO error detected
Const OKERR_ALLOC                : ULONG = $81F00006 ; //Cannot allocate memory
Const OKERR_SESSION_ERR          : ULONG = $81F00007 ; //General error
Const OKERR_ACCESS_ERR           : ULONG = $81F00008 ; //Access not allowed
Const OKERR_OPEN_FAILURE         : ULONG = $81F00009 ; //An open command was not successful
Const OKERR_CARD_NOT_POWERED     : ULONG = $81F0000A ; //Card is not powered
Const OKERR_ILLEGAL_CARDTYPE     : ULONG = $81F0000B ; //Illegal cardtype
Const OKERR_CARD_NOT_INSERTED    : ULONG = $81F0000C ; //Card not inserted
Const OKERR_NO_DRIVER            : ULONG = $81F0000D ; //No device driver installed
Const OKERR_OUT_OF_SERVICE       : ULONG = $81F0000E ; //The service is currently not available
Const OKERR_EOF_REACHED          : ULONG = $81F0000F ; //End of file reached
Const OKERR_ON_BLACKLIST         : ULONG = $81F00010 ; //The ID is on a blacklist, the requested action is therefore not allowed.
Const OKERR_CONSISTENCY_CHECK    : ULONG = $81F00011 ; //Error during consistency check
Const OKERR_IDENTITY_MISMATCH    : ULONG = $81F00012 ; //The identity does not match a defined cross-check identity
Const OKERR_MULTIPLE_ERRORS      : ULONG = $81F00013 ; //Multiple errors have occurred. Use this if there is only the possibility to return one error code, but there happened different errors before (e.g. each thread returned a different error and the controlling thread may only report one).
Const OKERR_ILLEGAL_DRIVER       : ULONG = $81F00014 ; //Illegal driver
Const OKERR_ILLEGAL_FW_RELEASE   : ULONG = $81F00015 ; //The connected hardware whose firmware is not useable by this software
Const OKERR_NO_CARDREADER        : ULONG = $81F00016 ; //No cardreader attached
Const OKERR_IPC_FAULT            : ULONG = $81F00017 ; //General failure of inter process communication
Const OKERR_WAIT_AND_RETRY       : ULONG = $81F00018 ; //The service currently does not take calls. The task has to go back to the message loop and try again at a later time (Windows 3.1 only). The code may also be used, in every situation where a ‘  wait and retry ’  action is requested.


Function SCardCLWriteMifareKeyToReader (
  ulHandleCard: SCARDHANDLE;
  hContext: LongInt;
  pcCardReader: PCHAR;
  ulMifareKeyNr: ULONG;
  ulMifareKeyLen: ULONG;
  out pucMifareKey: PUCHAR;
  fSecuredTransmission: Boolean;
  ulTransmissionKeyNr: ULONG): ULONG; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLWriteMifareKeyToReader(
                                        IN SCARDHANDLE    ulHandleCard,
                                        IN SCARDCONTEXT   hContext,
                                        IN PCHAR          pcCardReader,
                                        IN ULONG          ulMifareKeyNr,
                                        IN ULONG          ulMifareKeyLen,
                                        IN PUCHAR         pucMifareKey,
                                        IN BOOLEAN        fSecuredTransmission,
                                        IN ULONG          ulTransmissionKeyNr);
}



function SCardCLGetUID(
   ulHandleCard: SCARDHANDLE;
   out pucUID:  UCHAR;
   ulUIDBufLen: ULONG;
   out pulnByteUID: PULONG ): ULONG; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLGetUID(
                         IN SCARDHANDLE    ulHandleCard,
                         IN OUT PUCHAR     pucUID,
                         IN ULONG          ulUIDBufLen,
                         IN OUT PULONG     pulnByteUID);
}

Function SCardCLMifareStdRead(
  ulHandleCard :SCARDHANDLE ;
  ulMifareBlockNr :ULONG ;
  out pucMifareDataRead : PUCHAR;
  ulMifareDataReadBufLen: ULONG ;
  out pulMifareNumOfDataRead :PULONG):ULONG; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLMifareStdRead(IN SCARDHANDLE ulHandleCard,
                                 IN ULONG       ulMifareBlockNr,
                                 IN OUT PUCHAR  pucMifareDataRead,
                                 IN ULONG       ulMifareDataReadBufLen,
                                 IN OUT PULONG  pulMifareNumOfDataRead);
}

Function SCardCLMifareStdWrite(
  ulHandleCard: SCARDHANDLE;
  ulMifareBlockNr: ULONG;
  out pucMifareDataWrite: PUCHAR;
  ulMifareDataWriteBufLen: ULONG): ULONG; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLMifareStdWrite(IN SCARDHANDLE   ulHandleCard,
                                  IN ULONG         ulMifareBlockNr,
                                  IN PUCHAR        pucMifareDataWrite,
                                  IN ULONG         ulMifareDataWriteBufLen);
}

Function SCardCLMifareStdAuthent(
  ulHandleCard: Longint;
  ulMifareBlockNr: Cardinal;  //00
  ucMifareAuthMode: byte;  //
  ucMifareAccessType: byte;
  ucMifareKeyNr: byte;
  out pucMifareKey: byte;
  ulMifareKeyLen: Cardinal): Cardinal; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLMifareStdAuthent(IN SCARDHANDLE   ulHandleCard,
                                    IN ULONG         ulMifareBlockNr,
                                    IN UCHAR         ucMifareAuthMode,
                                    IN UCHAR         ucMifareAccessType,
                                    IN UCHAR         ucMifareKeyNr,
                                    IN PUCHAR        pucMifareKey,
                                    IN ULONG         ulMifareKeyLen);
}

Function SCardCLMifareStdIncrementVal(
  ulHandleCard: SCARDHANDLE;
  ulMifareBlockNr: ULONG;
  out pucMifareIncrementValue: PUCHAR;
  ulMifareIncrementValueBufLen: ULONG): ULONG; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLMifareStdIncrementVal(IN SCARDHANDLE  ulHandleCard,
                                         IN ULONG        ulMifareBlockNr,
                                         IN PUCHAR       pucMifareIncrementValue,
                                         IN ULONG        ulMifareIncrementValueBufLen);
}

Function SCardCLMifareStdDecrementVal(
  ulHandleCard: SCARDHANDLE;
  ulMifareBlockNr: ULONG;
  Out pucMifareDecrementValue: PUCHAR;
  ulMifareDecrementValueBufLen: ULONG): ULONG; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLMifareStdDecrementVal(IN SCARDHANDLE  ulHandleCard,
                                         IN ULONG        ulMifareBlockNr,
                                         IN PUCHAR       pucMifareDecrementValue,
                                         IN ULONG        ulMifareDecrementValueBufLen);
}

Function SCardCLICCTransmit(
  ulHandleCard: SCARDHANDLE;
  out pucSendData: PUCHAR;
  ulSendDataBufLen: ULONG;
  out pucReceivedData: PUCHAR;
  out pulReceivedDataBufLen: PULONG): ULONG; stdcall; external 'scardsyn.dll';

{OKERR ENTRY SCardCLICCTransmit(IN SCARDHANDLE       ulHandleCard,
                                  IN PUCHAR             pucSendData,
                                  IN ULONG              ulSendDataBufLen,
                                  IN OUT PUCHAR         pucReceivedData,
                                  IN OUT PULONG         pulReceivedDataBufLen);
}






{
' Establish a context to resource manager
' Parameters:
'       dwScope         = Scope (see Scopes)
'       pvReserved1     = Reserved for further use
'       pvReserved2     = Reserved for further use
'       phContext       = Pointer to Context
}
Function SCardEstablishContext (
  dwScope: ULong;
  pvReserved1: ULONG;
  pvReserved2: ULONG;
  out phContext: ULONG): ULONG; stdcall; external 'Winscard.dll';

{
' Release current Context
' Parameters:
'       hContext        = current Context
}
Function SCardReleaseContext(
  hContext: ULONG): ULONG; stdcall; external 'Winscard.dll';

{
' List all availiable Readers
' Parameters:
'       hContext        = current Context
'       mszGroups       = multistring, containing groupnames
'                          if mszGroups is not null only Readers which are
'                          in specified groups are listed
'       mszReaders      = multistring, containing all availiable Readers
'       pcchReaders     = Length of mszReaders in Bytes
}
Function  SCardListReadersA(   //SCardListReaders
     hContext: ULONG;
     mszGroups: UCHAR; //Byte, _
     out mszReaders: UCHAR;  //Byte, _
     out pcchReaders: ULONG): ULONG; stdcall; external 'Winscard.dll';

{
' Connect to one specific Reader
' Parameters:
'       hContext                = current Context
'       szReaders               = name of a Reader
'       dwShareMode             = Share Mode (see ShareModes)
'       dwPreferredProtocols    = Preferred Protocol (see Protocols)
'       hCard                   = Handle to Card
'       dwActiveProtocol        = Returned Protocol
}
Function SCardConnectA( //Alias "SCardConnect" _
  hContext: ULONG;
  szReader: String;
  dwShareMode: ULONG;
  dwPreferredProtocols: ULONG;
  out hCard: ULONG;
  out dwActiveProtocol: ULONG): ULONG; stdcall; external 'Winscard.dll';


Function SCardGetAttrib (
  hCard: ULONG;
  dwAttrId: ULONG;
  out pbAttr: UCHAR; //Byte, _
  out pcbAttrLen: ULONG): ULONG; stdcall; external 'Winscard.dll';


{
' Disconnect from Card
' Parameters:
'       hCard           = Handle to Card
'       dwDisposition   = Action to do with Card (see Dispositions)
}
Function SCardDisconnect(
  hCard: ULONG;
  dwDisposition: ULONG): ULONG; stdcall; external 'Winscard.dll';

implementation

end.
