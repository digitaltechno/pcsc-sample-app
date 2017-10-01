//////////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2008 SCM Microsystems Inc.                                    //
//                                                                              //
//     This source code is provided 'as-is', without any express or implied     //
//     warranty. In no event will SCM Microsystems Inc. be held liable for any  //
//     damages arising from the use of this software.                           //
//                                                                              //
//     SCM Microsystems Inc. does not warrant, that the source code will be     //
//     free from defects in design or workmanship or that operation of the      //
//     source code will be error-free. No implied or statutory warranty of      //
//     merchantability or fitness for a particulat purpose shall apply.         //
//     The entire risk of quality and performance is with the user of this      //
//     source code.                                                             //
//                                                                              //
//     Permission is granted to anyone to use this software for any purpose,    //
//     including commercial applications, and to alter it and redistribute it   //
//     freely, subject to the following restrictions:                           //
//                                                                              //
//     1. The origin of this source code must not be misrepresented; you must   //
//        not claim that you wrote the original source code. If you use this    //
//        source code in a product, an acknowledgment in the product            //
//        documentation would be appreciated but is not required.               //
//                                                                              //
//     2. Altered source versions must be plainly marked as such, and must not  //
//        be misrepresented as being the original source code.                  //
//                                                                              //
//     3. This notice may not be removed or altered from any source             //
//        distribution.                                                         //
//////////////////////////////////////////////////////////////////////////////////
// WARNING!!!
// Do not use 'ConnectReader' and 'ConnectCard'
// at one reader with card on it, or it will cause unfinished state loop
// 'nocard' and 'available'

unit Reader;

interface

uses
  Windows,Dialogs, SysUtils, Classes, PCSCRaw, PCSCDef;

type
  TReaderObject=class;
  TOnReaderListChanged = procedure of object;
  TCardState =(csUnknown=0, csExclusive, csShared, csAvailable, csBadCard, csNoCard);

  TReaderListThread = class(TThread)
  private
    FPCSCRaw:TPCSCRaw;
    FPCSCDeviceContext:DWORD;
    FReaderState:TSCardReaderStateA;
    FOnReaderListChanged:TOnReaderListChanged;
  public
    constructor Create(PCSCRaw:TPCSCRaw);
    procedure Execute; override;

    property OnReaderListChanged:TOnReaderListChanged read FOnReaderListChanged write FOnReaderListChanged;
  end;

  TCardStateThread = class(TThread)
  private
    FParentReader:TReaderObject;
    FReaderName:string;
    FPCSCRaw:TPCSCRaw;
    FPCSCDeviceContext:DWORD;
    FCardState:TCardState;
    FReaderStateArray:array[0..0]of TSCardReaderStateA;
  public
    constructor Create(ParentReader:TReaderObject;PCSCRaw:TPCSCRaw);
    procedure Execute; override;

    property CardState:TCardState read FCardState;
  end;

  TScrollTextThread = class(TThread)
  private
    FReader: TReaderObject;
    FBold:Boolean;
    FFont,
    FLine: Byte;
    FValue:string;
    FStart,
    FDelay: Cardinal;
    FPosition: Integer;
  protected
    procedure Display;
  public
    constructor Create(AReader:TReaderObject;Delay:Cardinal;Bold:Boolean; Font, Line: Byte; Value:string);
    procedure Execute; override;
  end;

  TReaderObject=class
  private
    FContext : DWord;
    FOnCard:TNotifyEvent;
    FOnCardStateChanged:TNotifyEvent;
    FCardStateThread:TCardStateThread;
    FPCSCRaw:TPCSCRaw;
    FSCardReaderState:TSCardReaderStateA;

    FReaderName:string;
    FATRString:string;
    FUIDString:string;

    FCardState:TCardState;

    FCardHandle:DWORD;
    FProtocolType: TPcscProtocol;

    procedure DecodeATR(ATR:PChar;ATRLen:integer);
    procedure CardStateChanged;

    function SendCardTransmit(InHex:string):string;
    procedure SendReaderControl(InHex:string); overload;
    procedure SendReaderControl(InHex,InStr:string); overload;
  public
    constructor Create(AReaderName:string; AContext:DWord; PCSCRaw:TPCSCRaw);
    destructor Destroy;override;

    function SCConnect(ShareMode:DWORD):DWORD;
    function SCTransmit(InBuffer,OutBuffer:Pointer;InSize:DWORD;var OutSize:DWORD):DWORD;
    function SCAuth(blockNr:DWORD;authmode,accessType,keyNr:byte; out mifareKey:byte;mifareKeyLen:dword):DWORD;
    function SCRead(ulMifareBlockNr:DWORD;out inBuffer:PUCHAR;ulMifareDataReadBufLen:DWORD;out pulMifareNumOfDataRead :DWORD):DWORD;
    function SCWrite(ulMifareBlockNr:DWORD;out pucMifareDataWrite:PUCHAR;ulMifareDataWriteBufLen:DWORD):DWORD;
    function SCGetUID(out pucUID: UCHAR;ulUIDBufLen: DWORD; out pulnByteUID: DWORD): DWORD;
    function SCDisconnect:DWORD;

    //card front-end pdu transmit communication
    function ConnectCard:Boolean;
    function IsCardConnected:Boolean;

    //reader front-end pdu control communication
    function ConnectReader:Boolean;
    function IsReaderConnected:Boolean;
    procedure LCDClear;
    procedure LCDBacklight(State: Boolean);
    procedure LCDContrast(Max15: Byte);
    procedure LCDText(Bold:Boolean; Font, Line, Index :Byte; Value: string); overload;
    procedure LCDText(Line, Index :Byte; Value: string); overload;
    procedure LCDTextLeft(Bold:Boolean; Font, Line: Byte; Value: string); overload;
    procedure LCDTextLeft(Line: Byte; Value: string); overload;
    procedure LCDTextCenter(Bold:Boolean; Font, Line:Byte; Value: string);overload;
    procedure LCDTextCenter(Line:Byte; Value: string);overload;
    procedure LCDTextRight(Bold:Boolean; Font, Line:Byte; Value: string);overload;
    procedure LCDTextRight(Line:Byte; Value: string);overload;
    function LCDTextScroll(Delay:Cardinal; Bold:Boolean; Font, Line:Byte; Value: string):TScrollTextThread; overload;
    function LCDTextScroll(Delay:Cardinal; Line:Byte; Value: string):TScrollTextThread; overload;
    procedure Buzz(Duration:Byte);
    procedure Led(Green, Blue:Boolean);overload;
    procedure Led(Green, Blue, Orange, Red:Boolean);overload;

    property ATR:string read FATRString;
    property UID:string read FUIDString;
    property ReaderName:string read FReaderName;
    property CardState:TCardState read FCardState;

    property CardHandle:THandle read FCardHandle;
    property OnCardUIDChanged:TNotifyEvent read FOnCard write FOnCard;
    property OnCardStateChanged:TNotifyEvent read FOnCardStateChanged write FOnCardStateChanged;
  end;

implementation

const IOCTL_READER_COMMAND = (FILE_DEVICE_SMARTCARD shl 16)+(IOCTL_CCID_ESCAPE shl 2);

constructor TReaderListThread.Create(PCSCRaw:TPCSCRaw);
begin
  inherited Create(true);
  FPCSCRaw:=PCSCRaw;
  FPCSCDeviceContext:=0;
  FOnReaderListChanged:=nil;

  FPCSCRaw.SCardEstablishContext(SCARD_SCOPE_SYSTEM,nil,nil,FPCSCDeviceContext);
end;

procedure TReaderListThread.Execute;
var
  PCSCResult:DWORD;
begin
  FReaderState.cbAtr:=0;
  FReaderState.dwEventState:=SCARD_STATE_UNAWARE;
  FReaderState.dwCurrentState:=SCARD_STATE_UNAWARE;
  FReaderState.szReader:='\\?PNP?\Notification';
  FReaderState.pvUserData:=nil;

  while not Terminated do begin
    PCSCResult:=FPCSCRaw.SCardGetStatusChange(FPCSCDeviceContext,250,@FReaderState,1);
    if PCSCResult=SCARD_E_CANCELLED then break;
    if PCSCResult=SCARD_S_SUCCESS then begin
      FReaderState.dwCurrentState:=FReaderState.dwEventState;
      if Assigned(FOnReaderListChanged) then Synchronize(FOnReaderListChanged);
    end;
  end;
  if FPCSCDeviceContext<>0 then FPCSCRaw.SCardReleaseContext(FPCSCDeviceContext);
end;

constructor TCardStateThread.Create(ParentReader:TReaderObject;PCSCRaw:TPCSCRaw);
begin
  inherited Create(true);
  FParentReader:=ParentReader;
  FPCSCRaw:=PCSCRaw;
  if FParentReader<>nil then FReaderName:=FParentReader.ReaderName;
  FPCSCDeviceContext:=0;
  FCardState:=csUnknown;

  FPCSCRaw.SCardEstablishContext(SCARD_SCOPE_SYSTEM,nil,nil,FPCSCDeviceContext);
end;

procedure TCardStateThread.Execute;
var
  PCSCResult:DWORD;
begin
  FReaderStateArray[0].cbAtr:=0;
  FReaderStateArray[0].dwEventState:=SCARD_STATE_UNAWARE;
  FReaderStateArray[0].dwCurrentState:=SCARD_STATE_UNAWARE;
  FReaderStateArray[0].szReader:=@FReaderName[1];
  FReaderStateArray[0].pvUserData:=nil;

  while not Terminated do
  begin
    PCSCResult:=FPCSCRaw.SCardGetStatusChange(FPCSCDeviceContext,250,@FReaderStateArray,1);
    if PCSCResult=SCARD_E_CANCELLED then break;
    if PCSCResult=SCARD_S_SUCCESS then begin
      FReaderStateArray[0].dwCurrentState:=FReaderStateArray[0].dwEventState;
      FParentReader.FSCardReaderState:=FReaderStateArray[0];
      Synchronize(FParentReader.CardStateChanged);
    end;
  end;
  if FPCSCDeviceContext<>0 then FPCSCRaw.SCardReleaseContext(FPCSCDeviceContext);
end;

constructor TReaderObject.Create(AReaderName:string; AContext:DWord; PCSCRaw:TPCSCRaw);
begin
  FContext:=AContext;
  FReaderName:=AReaderName;
  FOnCardStateChanged:=nil;
  FPCSCRaw:=PCSCRaw;
  FCardStateThread:=TCardStateThread.Create(self,PCSCRaw);

  FATRString:='';
  FUIDString:='';
  FCardState:=csUnknown;
  FCardHandle:=INVALID_HANDLE_VALUE;

  FCardStateThread.Resume;
end;

destructor TReaderObject.Destroy;
begin
  FCardStateThread.Terminate;
  FCardStateThread.Free;
  inherited;
end;

procedure TReaderObject.DecodeATR(ATR:PChar;ATRLen:integer);
var
  i:integer;
begin
  FATRString:='';
  for i:=0 to ATRLen-1 do FATRString:=FATRString+IntToHex(PByteArray(ATR)[i],2)+' ';
end;

function TReaderObject.ConnectCard: Boolean;
begin
    Result:=SCConnect(SCARD_SHARE_SHARED)=SCARD_S_SUCCESS;
end;

function TReaderObject.IsCardConnected: Boolean;
begin
    Result:=(FCardHandle<>INVALID_HANDLE_VALUE) and (FProtocolType<>prDirect);
end;

function TReaderObject.SCConnect(ShareMode:DWORD):DWORD;
var
  actprot:DWORD;
  rname:shortstring;
begin
  result:=SCARD_S_SUCCESS;
  if FCardHandle<>INVALID_HANDLE_VALUE then
      if ((ShareMode=SCARD_SHARE_DIRECT) and (FProtocolType<>prDirect))
      or ((ShareMode<>SCARD_SHARE_DIRECT) and (FProtocolType=prDirect)) then
          SCDisconnect
      else exit;
  rname:=copy(FReaderName,1,254)+#0;
  if ShareMode=SCARD_SHARE_DIRECT then Result:=FPCSCRaw.SCardConnect(FContext, @rname[1], SCARD_SHARE_DIRECT, 0, FCardHandle, actprot)
  else Result:=FPCSCRaw.SCardConnect(FContext, @rname[1], ShareMode, SCARD_PROTOCOL_Tx, FCardHandle, actprot);
  if result=SCARD_S_SUCCESS then begin
    if actprot=SCARD_PROTOCOL_T0 then FProtocolType:=prT0
    else if actprot=SCARD_PROTOCOL_T1 then FProtocolType:=prT1
    else if actprot=SCARD_PROTOCOL_UNDEFINED then FProtocolType:=prDirect
    else if actprot=SCARD_PROTOCOL_RAW then FProtocolType:=prRaw
    else FProtocolType:=prNC;
  end;
end;

function TReaderObject.SCDisconnect:DWORD;
begin
  result:=SCARD_S_SUCCESS;
  if FCardHandle=INVALID_HANDLE_VALUE then exit;
  Result:=FPCSCRaw.SCardDisconnect(FCardHandle, SCARD_UNPOWER_CARD);
  FProtocolType:=prNC;
  FCardHandle:=INVALID_HANDLE_VALUE;
end;

function TReaderObject.SCTransmit(InBuffer,OutBuffer:Pointer;InSize:DWORD;var OutSize:DWORD):DWORD;
var
  pioSendPCI, pioRecvPCI: pSCardIORequest;
begin
  pioRecvPCI:=nil;
  case FProtocolType of
    prT0: pioSendPCI:=@SCARDPCIT0;
    prT1: pioSendPCI:=@SCARDPCIT1;
    else begin
      result:=ERROR_INVALID_PARAMETER;
      exit;
    end;
  end;
  Result:=FPCSCRaw.SCardTransmit(FCardHandle,pioSendPCI,InBuffer,InSize,pioRecvPCI,OutBuffer,OutSize);
end;

procedure TReaderObject.CardStateChanged;
var
  CS: DWord;
  NewUID:string;
  NewCardState:TCardState;
begin
  if FSCardReaderState.cbAtr<>0 then DecodeATR(@(FSCardReaderState.rgbATR)[0],FSCardReaderState.cbATR);
  CS:=FSCardReaderState.dwEventState;

  if (CS and SCARD_STATE_PRESENT <> 0) then begin
    if (CS and SCARD_STATE_EXCLUSIVE <> 0) then NewCardState:=csExclusive
    else if (CS and SCARD_STATE_INUSE <> 0) then NewCardState:=csShared
    else if (CS and SCARD_STATE_MUTE <> 0) then NewCardState:=csBadCard
    else NewCardState:=csAvailable;
  end
  else if (CS and SCARD_STATE_EMPTY) <> 0 then NewCardState:=csNoCard
  else if FSCardReaderState.cbAtr=0 then NewCardState:=csNoCard
  else NewCardState:=csUnknown;
  if NewCardState<>FCardState then begin
    FCardState:=NewCardState;
    NewUID := FUIDString;
    if (NewCardState=csNoCard) or (NewCardState=csBadCard) then
    begin
        FCardHandle:=INVALID_HANDLE_VALUE;
        NewUID:='';
    end else if NewCardState=csAvailable then
    begin
        ConnectCard;
        NewUID:=SendCardTransmit('FFCA000000');
    end;
    if NewUID<>FUIDString then
    begin
        FUIDString:=NewUID;
        if Assigned(FOnCard) then
            FOnCard(Self);
    end;
    if Assigned(FOnCardStateChanged) then FOnCardStateChanged(self);
  end;
end;

function TReaderObject.SCAuth(blockNr:DWORD;authmode,accessType,keyNr:byte; out mifareKey:byte;mifareKeyLen:dword): DWORD;
begin
     result:=FPCSCRaw.SCardAuth(FCardHandle,
    blockNr,// 0,
    authmode,// 96, //uth mode 96=
    accessType,// 0, //access option 0 = key B  1=Key A Number
    keyNr,// 0, //mifareKeyNr
     mifareKey,
    mifareKeyLen);

end;

function TReaderObject.SCRead(ulMifareBlockNr:DWORD;out inBuffer:PUCHAR;ulMifareDataReadBufLen:DWORD;out pulMifareNumOfDataRead :DWORD):DWORD;
begin
    Result:=FPCSCRaw.SCardRead(FCardHandle,ulMifareBlockNr,inBuffer,ulMifareDataReadBufLen,pulMifareNumOfDataRead);
end;

function TReaderObject.SCGetUID(out pucUID: UCHAR; ulUIDBufLen: DWORD; out pulnByteUID: DWORD): DWORD;
begin
     Result:=FPCSCRaw.SCardCLGetUID(FCardHandle,pucUID,ulUIDBufLen,pulnByteUID);
end;

function TReaderObject.SCWrite(ulMifareBlockNr: DWORD; out pucMifareDataWrite: PUCHAR;
  ulMifareDataWriteBufLen: DWORD): DWORD;
begin
    Result:=FPCSCRaw.SCardWrite(FCardHandle,ulMifareBlockNr,pucMifareDataWrite,ulMifareDataWriteBufLen);
end;

function TReaderObject.ConnectReader: Boolean;
begin
    Result:=SCConnect(SCARD_SHARE_DIRECT)=SCARD_S_SUCCESS;
end;

function TReaderObject.IsReaderConnected: Boolean;
begin
    Result:=(FCardHandle<>INVALID_HANDLE_VALUE) and (FProtocolType=prDirect);
end;

function TReaderObject.SendCardTransmit(InHex: string): string;
var
    I,N:DWord;
    InBuf : array of Byte;
    OutBuf: array[0..255] of Byte;
begin
    Result:='';
    if not IsCardConnected then Exit;
    N:=Length(InHex) div 2;
    SetLength(InBuf,N);
    for I:=0 to N-1 do
        InBuf[I]:=StrToInt('$'+Copy(InHex,I*2+1,2));
    I:=SizeOf(OutBuf);
    if SCARD_S_SUCCESS=SCTransmit(@InBuf[0], @OutBuf[0], N, I) then
    begin
        if (I>2) and (OutBuf[I-1]=0) and (OutBuf[I-2]=$90) then
        while I>2 do
        begin
            dec(I);
            Result:=IntToHex(OutBuf[I-2],2)+Result;
        end;
    end;
end;

procedure TReaderObject.SendReaderControl(InHex: string);
var
    I,N:DWord;
    InBuf : array of Byte;
    OutBuf: array[0..1] of Byte;
begin
    if not IsReaderConnected then Exit;
    N:=Length(InHex) div 2;
    SetLength(InBuf,N);
    for I:=0 to N-1 do
        InBuf[I]:=StrToInt('$'+Copy(InHex,I*2+1,2));
    FPCSCRaw.SCardControl(FCardHandle,IOCTL_READER_COMMAND, @InBuf[0], N, @OutBuf[0], SizeOf(OutBuf), I);
end;

procedure TReaderObject.SendReaderControl(InHex, InStr: string);
var
    I:Integer;
begin
    for I:=1 to Length(InStr) do
        InHex:=InHex+IntToHex(Ord(InStr[I]),2);
    SendReaderControl(InHex);
end;

procedure TReaderObject.LCDBacklight(State: Boolean);
begin
    if State then
        SendReaderControl('FF0064FF00')
    else SendReaderControl('FF00640000');
end;

procedure TReaderObject.LCDClear;
begin
    SendReaderControl('FF00600000');
end;

procedure TReaderObject.LCDContrast(Max15: Byte);
begin
    SendReaderControl('FF006C'+IntToHex(Max15 mod 16, 2)+'00');
end;

procedure TReaderObject.LCDText(Bold:Boolean; Font, Line, Index: Byte; Value: string);
var
    SentLen:Integer;
    FontCmd,XYCmd:Byte;
begin
    FontCmd:=((Font mod 3) shl 4) and $F0;
    if Bold then FontCmd:=FontCmd+1;
    if (Value='') then //clear line
    begin
        SentLen:=0;
        while SentLen<16 do
        begin
            inc(SentLen);
            Value:=Value+' ';
        end;
        Index:=0;
    end else
    begin
        SentLen:=16-Index;
        if Length(Value)>SentLen then
            Value:=Copy(Value, 1, SentLen)
        else SentLen:=Length(Value);
    end;
    XYCmd:=Index mod 16;
    if Font<2 then
    begin
        if Line>0 then
            XYCmd := $40+XYCmd;
    end else XYCmd := (Line mod 4)*2 shl 4+XYCmd;
    SendReaderControl('FF'+IntToHex(FontCmd,2)+'68'+IntToHex(XYCmd,2)+IntToHex(SentLen,2),Value);
end;

procedure TReaderObject.LCDText(Line, Index: Byte; Value: string);
begin
    LCDText(False, 0, Line, Index, Value);
end;

procedure TReaderObject.LCDTextCenter(Bold: Boolean; Font, Line: Byte;
  Value: string);
begin
    if Length(Value)>16 then
        Value:=Copy(Value, 1 + ((Length(Value)-16) div 2), 16);
    LCDText(Bold, Font, Line, (16-Length(Value)) div 2, Value);
end;

procedure TReaderObject.LCDTextCenter(Line: Byte; Value: string);
begin
    LCDTextCenter(False, 0, Line, Value);
end;

procedure TReaderObject.LCDTextLeft(Bold: Boolean; Font, Line: Byte;
  Value: string);
begin
    LCDText(Bold, Font, Line, 0, Value);
end;

procedure TReaderObject.LCDTextLeft(Line: Byte; Value: string);
begin
    LCDText(False, 0, Line, 0, Value);
end;

procedure TReaderObject.LCDTextRight(Bold: Boolean; Font, Line: Byte;
  Value: string);
begin
    if Length(Value)>16 then
        Value:=Copy(Value,Length(Value)-15,16);
    LCDText(Bold, Font, Line, 16-Length(Value), Value);
end;

procedure TReaderObject.LCDTextRight(Line: Byte; Value: string);
begin
    LCDTextRight(False, 0, Line, Value);
end;

function TReaderObject.LCDTextScroll(Delay:Cardinal; Bold: Boolean; Font, Line:Byte;
  Value: string):TScrollTextThread;
begin
    Result:=TScrollTextThread.Create(Self, Delay, Bold, Font, Line, Value);
end;

function TReaderObject.LCDTextScroll(Delay:Cardinal; Line:Byte; Value: string):TScrollTextThread;
begin
    Result:=LCDTextScroll(Delay, False, 0, Line, Value);
end;

procedure TReaderObject.Buzz(Duration: Byte);
begin
    SendReaderControl('E000002801'+IntToHex(Duration,2));
end;

procedure TReaderObject.Led(Green, Blue: Boolean);
var
    Flags:Byte;
begin
    Flags:=0;
    if Green then Flags:=Flags or $01;
    if Blue then Flags:=Flags or $02;
    SendReaderControl('E000002901'+IntToHex(Flags,2));
end;

procedure TReaderObject.Led(Green, Blue, Orange, Red: Boolean);
var
    Flags:Byte;
begin
    Flags:=0;
    if Green then Flags:=Flags or $01;
    if Blue then Flags:=Flags or $02;
    if Orange then Flags:=Flags or $04;
    if Red then Flags:=Flags or $08;
    SendReaderControl('FF0044'+IntToHex(Flags,2)+'00');
end;


{ TScrollTextThread }

constructor TScrollTextThread.Create(AReader: TReaderObject;
  Delay: Cardinal; Bold: Boolean; Font, Line: Byte; Value: string);
var
    I:Integer;
begin
    inherited Create(True);
    FreeOnTerminate:=True;
    FReader:=AReader;
    FDelay:=Delay;
    FBold:=Bold;
    FFont:=Font;
    FLine:=Line;
    FValue:=Value;
    for I:=1 to 15 do
        FValue:=FValue+' ';
    FPosition:=0;
    FStart:=GetTickCount;
    Display;
    Resume;
end;

procedure TScrollTextThread.Display;
begin
    if FPosition=0 then
        FReader.LCDTextLeft(FBold, FFont, FLine, '')
    else if (FPosition<16) then
        FReader.LCDTextRight(FBold,FFont,FLine,Copy(FValue, 1, FPosition))
    else FReader.LCDTextLeft(FBold,FFont,FLine,Copy(FValue, FPosition-15, 16));
end;

procedure TScrollTextThread.Execute;
var
    FNow:Cardinal;
begin
    while not Terminated do
    try
      if FReader.IsReaderConnected then
      begin
          FNow:=GetTickCount;
          if FNow-FStart>=FDelay then
          begin
              FStart:=FNow;
              FPosition:=FPosition+1;
              if FPosition>Length(FValue) then
                  FPosition:=0;
              Synchronize(Display);
          end;
      end;
    except
      Terminate;
    end;
end;

end.


