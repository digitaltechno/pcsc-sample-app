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

unit Main;

interface

uses      Dialogs,
  Windows, SysUtils, Messages, Classes, Forms, Controls, ComCtrls, StdCtrls,
  ExtCtrls, Graphics, XPMan, PCSCRaw, PCSCDef, Reader;

type
  TMainForm = class(TForm)
    XPManifest1: TXPManifest;
    TopPanel: TPanel;
    Panel1: TPanel;
    RichEdit: TRichEdit;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Label2: TLabel;
    Panel3: TPanel;
    Label1: TLabel;
    ReaderListBox: TListBox;
    StatusBar1: TStatusBar;
    ConnectSharedButton: TButton;
    ConnectExclusiveButton: TButton;
    DisconnectButton: TButton;
    Label3: TLabel;
    CommandComboBox: TComboBox;
    TransmitButton: TButton;
    Bevel1: TBevel;
    btnRead: TButton;
    btnAuth: TButton;
    Label4: TLabel;
    auth_block: TEdit;
    btnUID: TButton;
    btnWrite: TButton;
    edWrite: TEdit;
    Label5: TLabel;
    auth_key: TEdit;
    Label6: TLabel;
    RadioGroup1: TRadioGroup;
    Button2: TButton;
    Button1: TButton;
    MarqueeButton: TButton;
    ConnectDirectButton: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ReaderListBoxDrawItem(Control: TWinControl; Index: Integer; RC: TRect; State: TOwnerDrawState);
    procedure ConnectSharedButtonClick(Sender: TObject);
    procedure ConnectExclusiveButtonClick(Sender: TObject);
    procedure DisconnectButtonClick(Sender: TObject);
    procedure TransmitButtonClick(Sender: TObject);
    procedure ReaderListBoxClick(Sender: TObject);
    procedure CommandComboBoxChange(Sender: TObject);
    procedure CommandComboBoxEnter(Sender: TObject);
    procedure CommandComboBoxKeyPress(Sender: TObject; var Key: Char);
    procedure CommandComboBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnReadClick(Sender: TObject);
    procedure btnAuthClick(Sender: TObject);
    procedure btnUIDClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MarqueeButtonClick(Sender: TObject);
    procedure ConnectDirectButtonClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    ReaderType:integer;
    ReaderObject:TReaderObject;
    FPCSCRaw:TPCSCRaw;
    FPCSCDeviceContext:DWORD;
    FReaderListThread:TReaderListThread;
    FMarqueeThread: TScrollTextThread;
    FCardActualEvent: TNotifyEvent;
    procedure InitPCSC;
    procedure UpdatePCSCReaderList;
    procedure GetPCSCReaderList(ReaderList:TStringList);
    procedure AddLog(Msg:string;Color:TColor=clBlack;LineBreak:boolean=true;Bold:boolean=false);
    procedure CardStateChanged(Sender:TObject);
    procedure ReaderUIDChanged(Sender:TObject);
    procedure ThisFormUIDChanged(Sender:TObject);
    procedure ReaderListChanged;
    procedure UpdateButtons;
    procedure LogInBuffer(Buffer:PByteArray;BufferSize:DWORD);
    function LogOutBuffer(Buffer:PByteArray;BufferSize:DWORD):String;
    function StringToBuffer(Command:string;Buffer:PByteArray):DWORD;


  public
  end;

var
  MainForm: TMainForm;

implementation

uses UTag;





{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption:='PC/SC Sample Application V1.0';
  Application.Title:=Caption;

  FPCSCDeviceContext:=0;
  FCardActualEvent:=ThisFormUIDChanged;
  RichEdit.Clear;

  // creating PC/SC wrapper object
  FPCSCRaw:=TPCSCRaw.Create;

  InitPCSC;
  ReaderListChanged;
  FReaderListThread:=TReaderListThread.Create(FPCSCRaw);
  FReaderListThread.OnReaderListChanged:=ReaderListChanged;
  FReaderListThread.Resume;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  i:integer;
begin
  FReaderListThread.Terminate;
  for i:=0 to ReaderListBox.Count-1 do TReaderObject(ReaderListBox.Items.Objects[i]).Free;

  if FPCSCDeviceContext<>0 then begin
    FPCSCRaw.SCardCancel(FPCSCDeviceContext);
    FPCSCRaw.SCardReleaseContext(FPCSCDeviceContext);
  end;
  FReaderListThread.Free;
  FPCSCRaw.Shutdown;
  FPCSCRaw.Free;
end;

procedure TMainForm.InitPCSC;
var
  PCSCResult:DWORD;
begin
  if FPCSCRaw.Initialize<>TPCSC_INIT_OK then AddLog('Cannot access Winscard.dll.',clRed,true,true)
  else AddLog('Winscard.dll successfully loaded.',clGreen,true,true);

  // establishing PC/SC context
  PCSCResult:=FPCSCRaw.SCardEstablishContext(SCARD_SCOPE_SYSTEM,nil,nil,FPCSCDeviceContext);
  if PCSCResult=SCARD_S_SUCCESS then AddLog('SCardEstablishContext succeeded.',clGreen,true,true)
  else begin
    AddLog(Format('SCardEstablishContext failed with error code %s ',[IntToHex(PCSCResult,8)]),clRed,false,true);
    AddLog('('+FPCSCRaw.ScErrToSymbol(PCSCResult)+').',clBlack,true,false);
  end;

end;

procedure TMainForm.GetPCSCReaderList(ReaderList:TStringList);
var
  pReaders:PChar;
  PCSCResult:DWORD;
  SizeReaders:DWORD;
begin
  ReaderList.Clear;

  PCSCResult:=FPCSCRaw.SCardListReaders(FPCSCDeviceContext, nil, nil, SizeReaders);
  if PCSCResult = SCARD_S_SUCCESS then begin
    GetMem(pReaders,SizeReaders);
    try
      PCSCResult:=FPCSCRaw.SCardListReaders(FPCSCDeviceContext, nil, pReaders, SizeReaders);
      if PCSCResult=SCARD_S_SUCCESS then begin
        MultiStrToStringList(pReaders,SizeReaders,ReaderList);
        AddLog('SCardListReaders suceeded.',clGreen,true,true);
      end;
    finally
      if pReaders<>nil then FreeMem(pReaders);
    end;
  end
  else begin
    AddLog(Format('SCardListReaders failed with error code %s ',[IntToHex(PCSCResult,8)]),clRed,false,true);
    AddLog('('+FPCSCRaw.ScErrToSymbol(PCSCResult)+').',clBlack,true,false);
  end;
end;

function CardStateName(State: TCardState):string;
begin
  case State of
    csExclusive : Result:='exclusive';
    csShared    : begin
                    Result:='shared';
                 end;
    csAvailable :
               begin
                    Result:='available';
          end;
    csBadCard   : Result:='bad card';
    csNoCard    : Result:='no card';
    else          Result:='unknown';
  end;
end;

procedure TMainForm.CardStateChanged(Sender:TObject);
var
  CardState:TCardState;
  ReaderName:string;
begin
  CardState:=TReaderObject(Sender).CardState;
  ReaderName:=TReaderObject(Sender).ReaderName;
  AddLog('Card State changed in '+ReaderName+' to ',clBlack,false,false);
  AddLog(CardStateName(CardState),clBlue,true,true);
  ReaderListBox.Repaint;
  UpdateButtons;
end;

procedure TMainForm.ReaderListChanged;
begin
  AddLog('Reader list changed',clMaroon);
  UpdatePCSCReaderList;
  if (ReaderListBox.ItemIndex<1) and (ReaderListBox.Items.Count>0) then
  begin
   ReaderListBox.ItemIndex:=0;
   if Pos('ACS',ReaderListBox.Items[ReaderListBox.ItemIndex])>0 then ReaderType:=1 else ReaderType:=0;
  end;
  UpdateButtons;
end;

procedure TMainForm.UpdatePCSCReaderList;
var
  i,j:integer;
  Found:boolean;
  ReaderName:string;
  ReaderList:TStringList;
  ReaderObject:TReaderObject;
begin
  ReaderList:=TStringList.Create;
  try
    GetPCSCReaderList(ReaderList);
    for i:=ReaderListBox.Items.Count-1 downto 0 do begin
      ReaderName:=ReaderListBox.Items[i];
      Found:=false;
      for j:=0 to ReaderList.Count-1 do begin
        if ReaderName=ReaderList[j] then begin
          Found:=true;
          break;
        end;
      end;
      if not Found then begin
        AddLog('Reader removed: '+ReaderName,clMaroon);
        TReaderObject(ReaderListBox.Items.Objects[i]).Free;
        ReaderListBox.Items.Delete(i);
      end;
    end;

    for i:=0 to ReaderList.Count-1 do begin
      Found:=false;
      for j:=0 to ReaderListBox.Items.Count-1 do begin
        ReaderName:=ReaderListBox.Items[j];
        if ReaderName=ReaderList[i] then begin
          Found:=true;
          break;
        end;
      end;
      if not Found then begin
        ReaderName:=ReaderList[i];
        ReaderObject:=TReaderObject.Create(ReaderName,FPCSCDeviceContext,FPCSCRaw);
        ReaderObject.OnCardStateChanged:=CardStateChanged;
        ReaderObject.OnCardUIDChanged:=ReaderUIDChanged;
        ReaderListBox.Items.AddObject(ReaderName,ReaderObject);
        AddLog('New reader found: '+ReaderName,clMaroon);
      end;
    end;
  finally
    ReaderList.Free;
  end;
end;

procedure TMainForm.AddLog(Msg:string;Color:TColor=clBlack;LineBreak:boolean=true;Bold:boolean=false);
begin
  RichEdit.SelAttributes.Color:=Color;
  if Bold then RichEdit.SelAttributes.Style:=[fsBold]
  else RichEdit.SelAttributes.Style:=[];
  RichEdit.SelText:=Msg;
  if LineBreak then RichEdit.SelText:=#13#10;
  RichEdit.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TMainForm.ReaderListBoxDrawItem(Control: TWinControl; Index: Integer; RC: TRect; State: TOwnerDrawState);
var
  sState:string;
  ReaderObject:TReaderObject;
begin
  with ReaderListBox.Canvas do begin
    ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[Index]);

    if odSelected in State then begin
      Brush.Color:=clHighLight;
      Font.Color:=clHighLightText;
    end
    else begin
      Brush.Color:=clWindow;
      Font.Color:=clWindowText;
    end;
    Pen.Color:=Brush.Color;

    Rectangle(RC.Left,RC.Top,RC.Right,RC.Bottom);
    TextOut(RC.Left+4,RC.Top+2,ReaderListBox.Items[Index]);

    if ReaderObject<>nil then begin
      case ReaderObject.CardState of
        csExclusive:
          begin
            Font.Color:=clGreen;
            sState:='Card state = exclusive, ATR = '+ReaderObject.ATR;
          end;
        csShared:
          begin
            Font.Color:=clGreen;
            sState:='Card state = shared, ATR = '+ReaderObject.ATR;
          end;
        csAvailable:
          begin
            Font.Color:=clGreen;
            sState:='Card state = available, ATR = '+ReaderObject.ATR;
          end;
        csBadCard:
          begin
            Font.Color:=$808080;
            sState:='Card state = bad card';
          end;
        csNoCard:
          begin
            Font.Color:=clGray;
            sState:='Card state = no card';
          end;
        else begin
            Font.Color:=clGray;
            sState:='Card state = unknown';
        end;
      end;
      TextOut(RC.Left+20,RC.Top+15,sState);
    end;
  end;
end;

procedure TMainForm.UpdateButtons;
var
  ReaderObject:TReaderObject;
begin
 { ConnectDirectButton.Enabled:=false;
  ConnectSharedButton.Enabled:=false;
  ConnectExclusiveButton.Enabled:=false;
  DisconnectButton.Enabled:=false;
  CommandComboBox.Enabled:=false;
  TransmitButton.Enabled:=false;
  btnAuth.Enabled:=false;
  btnRead.Enabled:=false;
  btnUID.Enabled:=false;
  btnWrite.Enabled:=false;
  if ReaderListBox.ItemIndex<0 then exit;
  ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);

  if ReaderObject.CardHandle=INVALID_HANDLE_VALUE then
      ConnectDirectButton.Enabled:=True
  else DisconnectButton.Enabled:=true;
  if (ReaderObject.CardState=csAvailable) or (ReaderObject.CardState=csExclusive) or (ReaderObject.CardState=csShared) then
  begin
    if ReaderObject.CardHandle<>INVALID_HANDLE_VALUE then begin
      CommandComboBox.Enabled:=true;
      TransmitButton.Enabled:=length(trim(CommandComboBox.Text))>1;
      btnAuth.Enabled:=true;
      btnUID.Enabled:=true;
    end
    else begin
      ConnectSharedButton.Enabled:=true;
      ConnectExclusiveButton.Enabled:=true;
    end;
  end; }
end;

procedure TMainForm.ConnectSharedButtonClick(Sender: TObject);
var
  PCSCResult:DWORD;
  ReaderObject:TReaderObject;
  UID: string;
begin
  try
    if ReaderListBox.ItemIndex<0 then exit;
    ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
    PCSCResult:=ReaderObject.SCConnect(SCARD_SHARE_SHARED);
    if PCSCResult=SCARD_S_SUCCESS then
          AddLog('SCardConnect succeded.'+UID, clGreen,true,true)
    else begin
      AddLog(Format('SCardConnect failed with error code %s ',[IntToHex(PCSCResult,8)]),clRed,false,true);
      AddLog('('+FPCSCRaw.ScErrToSymbol(PCSCResult)+').',clBlack,true,false);
    end;
  finally
    UpdateButtons;
  end;
end;

procedure TMainForm.ConnectExclusiveButtonClick(Sender: TObject);
var
  PCSCResult:DWORD;
  ReaderObject:TReaderObject;
begin
  try
    if ReaderListBox.ItemIndex<0 then exit;
    ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
    PCSCResult:=ReaderObject.SCConnect(SCARD_SHARE_EXCLUSIVE);
    if PCSCResult=SCARD_S_SUCCESS then AddLog('SCardConnect succeeded.',clGreen,true,true)
    else begin
      AddLog(Format('SCardConnect failed with error code %s ',[IntToHex(PCSCResult,8)]),clRed,false,true);
      AddLog('('+FPCSCRaw.ScErrToSymbol(PCSCResult)+').',clBlack,true,false);
    end;
  finally
    UpdateButtons;
  end;
end;

procedure TMainForm.DisconnectButtonClick(Sender: TObject);
var
  PCSCResult:DWORD;
  ReaderObject:TReaderObject;
begin
  try
    if ReaderListBox.ItemIndex<0 then exit;
    ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
    PCSCResult:=ReaderObject.SCDisconnect;
    if PCSCResult=SCARD_S_SUCCESS then AddLog('SCardDisconnect succeeded.',clGreen,true,true)
    else begin
      AddLog(Format('SCardDisconnect failed with error code %s ',[IntToHex(PCSCResult,8)]),clRed,false,true);
      AddLog('('+FPCSCRaw.ScErrToSymbol(PCSCResult)+').',clBlack,true,false);
    end;
  finally
    UpdateButtons;
  end;
end;

procedure TMainForm.TransmitButtonClick(Sender: TObject);
var
  InSize:DWORD;
  OutSize:DWORD;
  PCSCResult:DWORD;
  ReaderObject:TReaderObject;
  InBuffer:array[0..260] of byte;
  OutBuffer:array[0..260] of byte;
begin
    try
    if ReaderListBox.ItemIndex<0 then exit;
    ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
    if CommandComboBox.Items.IndexOf(lowercase(trim(CommandComboBox.Text)))<0 then CommandComboBox.Items.Insert(0,CommandComboBox.Text);
    InSize:=StringToBuffer(CommandComboBox.Text,@InBuffer[0]);
    CommandComboBox.Text:='';
    LogInBuffer(@InBuffer[0],InSize);
    OutSize:=sizeof(OutBuffer);
    PCSCResult:=ReaderObject.SCTransmit(@InBuffer[0],@OutBuffer[0],InSize,OutSize);
    if PCSCResult=SCARD_S_SUCCESS then begin
      AddLog('SCardTransmit succeeded.',clGreen,true,true);
      LogOutBuffer(@OutBuffer[0],OutSize);
    end
    else begin
      AddLog(Format('SCardTransmit failed with error code %s ',[IntToHex(PCSCResult,8)]),clRed,false,true);
      AddLog('('+FPCSCRaw.ScErrToSymbol(PCSCResult)+').',clBlack,true,false);
    end;
  finally
    UpdateButtons;
  end;
end;

procedure TMainForm.ReaderListBoxClick(Sender: TObject);
begin
  if (ReaderListBox.Items.Count>0) then
  begin
   if Pos('ACS',ReaderListBox.Items[ReaderListBox.ItemIndex])>0 then ReaderType:=1 else ReaderType:=0;
  end;
  UpdateButtons;
end;

procedure TMainForm.LogInBuffer(Buffer:PByteArray;BufferSize:DWORD);
var
  s:string;
  i:integer;
begin
  AddLog('Sending APDU to card: ',clBlack,false);
  s:='';
  for i:=0 to BufferSize-1 do s:=s+IntToHex(Buffer^[i],2)+' ';
  AddLog(s,clPurple, true, true);
end;

function TMainForm.LogOutBuffer(Buffer:PByteArray;BufferSize:DWORD):String;
var
  s:string;
  i:integer;
  SW12:Word;
begin
  if BufferSize<2 then exit;
  SW12:=(Buffer[BufferSize-2]shl 8) or Buffer[BufferSize-1];
  AddLog('Card response status word: ',clBlack,false);
  AddLog(IntToHex(SW12,4),clPurple,true,true);
  Result:=IntToHex(SW12,4);
  BufferSize:=BufferSize-2;
  if Buffersize>0 then begin
    AddLog('Card response data: ',clBlack,false);
    s:='';
    for i:=0 to BufferSize-1 do s:=s+IntToHex(Buffer^[i],2)+' ';
    AddLog(s,clPurple, true, true);
  end;
end;

procedure TMainForm.CommandComboBoxChange(Sender: TObject);
var
  Changed:boolean;
  s:string;
  i:integer;
  AnzChars:integer;
  SelStart:integer;
const
  HexChars=['A'..'F','0'..'9'];
begin
  Changed:=false;
  s:='';
  AnzChars:=0;
  SelStart:=CommandComboBox.SelStart;
  for i:=1 to length(CommandComboBox.Text) do begin
    if (AnzChars>1) and (AnzChars mod 2=0) then begin
      if (CommandComboBox.Text[i]=' ') then s:=s+UpCase(CommandComboBox.Text[i])
      else begin
        if (UpCase(CommandComboBox.Text[i]) in HexChars) then begin
          s:=s+' '+UpCase(CommandComboBox.Text[i]);
          if i<=Selstart then inc(SelStart);
        end;
        Changed:=true;
      end;
    end
    else begin
      if (UpCase(CommandComboBox.Text[i]) in HexChars) then s:=s+UpCase(CommandComboBox.Text[i])
      else Changed:=true;
    end;
    if (UpCase(CommandComboBox.Text[i]) in HexChars) then inc(AnzChars)
    else if CommandComboBox.Text[i]=' ' then AnzChars:=0;
  end;
  CommandComboBox.Text:=s;
  if Changed then begin
    CommandComboBox.SelStart:=SelStart;
    CommandComboBox.SelLength:=0;
  end;
  TransmitButton.Enabled:=length(trim(CommandComboBox.Text))>1;
end;

procedure TMainForm.CommandComboBoxEnter(Sender: TObject);
begin
  CommandComboBox.SelStart:=length(TEdit(Sender).Text);
  CommandComboBox.SelLength:=0;
end;

procedure TMainForm.CommandComboBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key>='0') and (Key<='9')) or (Key<=#32) or ((UpCase(Key)>='A') and (UpCase(Key)<='F')) then Key:=UpCase(Key)
  else Key:=#0;
end;

type
  string2=string[2];

function HexStr2ToByte(HexStr2:string2):byte;
begin
  if HexStr2[1] in ['0'..'9'] then result:=(byte(HexStr2[1])-byte('0'))*16
  else result:=(byte(HexStr2[1])-byte('A')+10)*16;
  if HexStr2[2] in ['0'..'9'] then result:=result+(byte(HexStr2[2])-byte('0'))
  else result:=result+(byte(HexStr2[2])-byte('A')+10);
end;

function TMainForm.StringToBuffer(Command:string;Buffer:PByteArray):DWORD;
const
  HexChars=['A'..'F','0'..'9'];
var
  s:string;
  i:integer;
begin
  result:=0;
  if Buffer=nil then exit;
  Command:=UpperCase(Command);
  s:='';
  for i:=1 to length(Command) do if Command[i] in HexChars then s:=s+Command[i];
  if length(s) mod 2<>0 then s:=s+'0';
  result:=length(s) div 2;
  for i:=0 to result-1 do begin
   Buffer[i]:=HexStr2ToByte(copy(s,i*2+1,2));
  end;
end;

procedure TMainForm.CommandComboBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then begin
    if TransmitButton.Enabled then TransmitButton.Click;
  end;
end;

{function Auth: integer;
type
  TSCardCLMifareStdAuthent = function(SCARDHANDLE: cardinal;
    ulMifareBlockNr: ULONG; ucMifareAuthMode, ucMifareAccessType,
    ucMifareKeyNr: byte; pucMifareKey: PAnsiChar;
    ulMifareKeyLen: Cardinal): longint;
var
  SCardCLMifareStdAuthent: TSCardCLMifareStdAuthent;
  hDLL: Integer;
  CardHandle: Cardinal;
  Key: string;
begin
  Result := 1;
  //CardHandle is defined here...
  Key := StringOfChar(Chr($FF), 6);
  hDLL := LoadLibrary('scardsyn.dll');
  if hDLL <> 0 then begin
    @SCardCLMifareStdAuthent := GetProcAddress(hDLL, 'SCardCLMifareStdAuthent');
    if @SCardCLMifareStdAuthent <> nil then begin
      Result := SCardCLMifareStdAuthent(CardHandle, $00, 96, 0, 0,
        PChar(Key), Length(Key));
    end;
    FreeLibrary(hDLL);
  end;
end;  }

{Function UCharToStr(PUChar: puchar; Longueur: Word): string;
const
  Hexa: array[0..15] of Char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
var
  i: Word;
  o: Byte;
begin
  for i:=0 to Longueur-1
  do begin
    o:=PUChar[i];
    Result:=Result+Hexa[o and $F0];
    Result:=Result+Hexa[o and $0F];
  end;
end;  }

procedure TMainForm.btnReadClick(Sender: TObject);
var
  i:integer;
  rec,str,s:WideString;

begin
   ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
   s:=ReaderObject.SCardRead(StrToInt(auth_block.Text));
   if s<>'' then
   begin
        i:=length(s);
        if (i>4) then
        begin
           for i:=0 to 15 do
           begin
               str:=str+chr(StrToInt('$'+Copy(s,I*2+1,2)));
               rec:=rec+Copy(s,I*2+1,2);
               //Result:=IntToHex(OutBuf[I-2],2)+Result;
           end;
           AddLog('SCardRead succeeded Hex: '+rec,clGreen,True,true);
           AddLog('SCardRead succeeded: '+str,clGreen,True,true);
        end else AddLog('SCardRead Failed : '+s,clRed,true,true);

   end;
end;

procedure TMainForm.btnAuthClick(Sender: TObject);
var
  s:string;
begin
   ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
   s:=ReaderObject.SCardLoadKey(auth_key.Text,ReaderType);
   if s='9000' then
   begin
      AddLog('Load Key succeeded: '+auth_key.Text,clGreen,true,true);
      s:=ReaderObject.SCardAuth(StrToInt(auth_block.text),RadioGroup1.ItemIndex);
      if s='9000' then
      begin
        AddLog('SC Auth succeeded: '+s,clGreen,true,true);
      end else
      begin
        AddLog(Format('SC Auth failed with error code %s ',[s]),clRed,true,true);
      end;  
   end else
   begin
     AddLog(Format('Load Key failed with error code %s ',[s]),clRed,true,true);
   end;
end;

procedure TMainForm.btnUIDClick(Sender: TObject);
var
  PCSCResult:DWORD;
  ReaderObject:TReaderObject;
  pucUID:  UCHAR;  //out
  ulUIDBufLen: DWORD;
  pulnByteUID: DWORD; //out

  i:integer;
 Rec,rec2 : Widestring;
begin
     ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);

     PCSCResult:=ReaderObject.SCGetUID(pucUID,ulUIDBufLen,pulnByteUID);
    if PCSCResult=SCARD_S_SUCCESS then
    begin
               caption:=inttostr(pulnByteUID);
                  for i:=0 to pulnByteUID - 1 do begin
              //    if ord(pucUID[i])=0 then continue;
                  Rec := Rec +IntToHex(ord(pucUID[i]),2);
                  Rec2 := Rec2 +IntToStr(ord(pucUID[i]))+' ';
                end;
          AddLog('SCardCLGetUID succeeded. ',clGreen,false,true);
          AddLog('UID: '+rec+'/'+rec2,clBlue,true,true);
          AddLog('ATR: '+ReaderObject.ATR,clBlue,true,true);

    end else
    begin
      AddLog('Failed : '+IntToStr(PCSCResult),clRed,false,true);
    end;
end;

procedure TMainForm.btnWriteClick(Sender: TObject);
var
  PCSCResult:DWORD;
  ReaderObject:TReaderObject;
  tmpStr,s : string;
  indx : integer;
  dataBuffer:array of byte;
  i,dataLen:integer;
  pucData:PUCHAR;
  sData:string;
begin

   sData:=edWrite.Text;
   ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
   s:=ReaderObject.SCardWrite(StrToInt(auth_block.Text),sData);
   if s='9000' then
   begin
     AddLog('SC Write succeeded: '+sData,clRed,True,true);
   end else
   begin
     AddLog(Format('SC Write failed with error code %s ',[s]),clRed,True,true);
   end;

end;

procedure TMainForm.Button2Click(Sender: TObject);
var
    ReaderObject: TReaderObject;
begin
    if ReaderListBox.Items.Count>1 then
    with TReaderObject(ReaderListBox.Items.Objects[1]) do
    begin
        if ConnectReader then
        begin
            LCDClear;
            LCDTextCenter(0,'WELCOME TO DUSUN BAMBU');
            LCDTextCenter(1,'KEONG MACAN');
        end;
    end;
end;

procedure TMainForm.RadioGroup1Click(Sender: TObject);
begin
     if RadioGroup1.ItemIndex=0 then RadioGroup1.Tag:=96 else
     RadioGroup1.Tag:=97;
end;



procedure TMainForm.Button1Click(Sender: TObject);
var
    TagID:string;
begin
    if ReaderListBox.Items.Count>1 then
    with TReaderObject(ReaderListBox.Items.Objects[1]) do
    begin
        if ConnectReader then
        begin
            AddLog('Backlight Test...');
            Application.ProcessMessages;
            LCDClear;
            LCDBacklight(False);
            LCDTextCenter(0,'Back Light Off');
            Sleep(1000);
            LCDBacklight(True);
            LCDTextCenter(1,'Back Light On');
            Sleep(1000);
            AddLog('Contrast Test...');
            Application.ProcessMessages;
            LCDClear;
            LCDContrast(15);
            LCDTextLeft(False,2,0,'Contrast');
            LCDTextRight(False,2,0,'15');
            Sleep(1000);
            LCDContrast(10);
            LCDTextLeft(False,2,1,'Contrast');
            LCDTextRight(False,2,1,'10');
            Sleep(1000);
            LCDContrast(5);
            LCDTextLeft(False,2,2,'Contrast');
            LCDTextRight(False,2,2,'5');
            Sleep(1000);
            LCDContrast(10);
            LCDTextLeft(False,2,3,'Contrast');
            LCDTextRight(False,2,3,'10');
            Sleep(1000);
            AddLog('Led Test...');
            Application.ProcessMessages;
            LCDClear;
            Led(True, True, True, True);
            LCDTextLeft(0,'G   B   O   R');
            LCDTextLeft(1,'On  On  On  On');
            Sleep(1000);
            Led(True, True, True, False);
            LCDTextLeft(1,'On  On  On  Off');
            Sleep(1000);
            Led(True, True, False, False);
            LCDTextLeft(1,'On  On  Off Off');
            Sleep(1000);
            Led(True, False, False, False);
            LCDTextLeft(1,'On  Off Off Off');
            Sleep(1000);
            Led(False, False, False, False);
            LCDTextLeft(1,'Off Off Off Off');
            Sleep(1000);
            Led(True, True, False, False);
            LCDTextLeft(0,'Default');
            LCDTextLeft(1,'On  On  Off Off');
            Sleep(1000);
            AddLog('Text Style and Alignment Test...');
            Application.ProcessMessages;
            LCDClear;
            LCDTextLeft(0,'Left Font A');
            //atau LCDTextCenter(False, 0, 1, 'Left Font A');
            LCDTextLeft(True, 0, 1, 'Bold Font A');
            Sleep(1000);
            LCDClear;
            LCDTextRight(False, 1, 0,'Right Font B');
            LCDTextRight(True, 1, 1, 'Bold Font B');
            Sleep(1000);
            LCDClear;
            LCDTextCenter(False, 0, 0,'Centered');
            //atau LCDTextCenter(0,'Centered');
            LCDTextCenter(True, 0, 1, 'Bold Centered');
            Sleep(1000);
            AddLog('Clear Line Test...');
            Application.ProcessMessages;
            LCDTextLeft(0,'');
            LCDTextLeft(1, 'Line 0 Cleared');
            Sleep(1000);
        end else AddLog('Failed : Direct Connect to Reader',clRed);
    end;
end;

procedure TMainForm.MarqueeButtonClick(Sender: TObject);
begin
    if ReaderListBox.Items.Count>1 then
    with TReaderObject(ReaderListBox.Items.Objects[1]) do
    begin
        if FMarqueeThread<>nil then
        begin
           FMarqueeThread.Terminate;
           FMarqueeThread:=nil;
           MarqueeButton.Caption:='Start Marquee';
        end else
        if ConnectReader then
        begin
            AddLog('Marquee Test...');
            LCDClear;
            LCDTextCenter(1,'Marquee');
            FMarqueeThread:=LCDTextScroll(300, 0, 'This is marquee sample for long text');
            MarqueeButton.Caption:='Stop Marquee';
        end else AddLog('Failed : Direct Connect to Reader',clRed);
    end;
end;

procedure TMainForm.ConnectDirectButtonClick(Sender: TObject);
var
    ReaderObject: TReaderObject;
begin
  try
    if ReaderListBox.ItemIndex<0 then exit;
    ReaderObject:=TReaderObject(ReaderListBox.Items.Objects[ReaderListBox.ItemIndex]);
    if ReaderObject.ConnectReader then
          AddLog('SCardConnect succeded.', clGreen,true,true)
    else AddLog('SCardConnect failed.', clRed,true,true)
  finally
    UpdateButtons;
  end;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
    FCardActualEvent:=FTagDisplay.OnTagID;
    if TReaderObject(ReaderListBox.Items.Objects[0]).UID<>'' then
    FTagDisplay.OnTagID(ReaderListBox.Items.Objects[0]);
    FTagDisplay.ShowModal;
    FCardActualEvent:=ThisFormUIDChanged;
end;

procedure TMainForm.ReaderUIDChanged(Sender: TObject);
begin
    FCardActualEvent(Sender);
end;

procedure TMainForm.ThisFormUIDChanged(Sender: TObject);
var
    Tag:string;
begin
    Tag:=TReaderObject(Sender).UID;
    if ReaderListBox.Items.Count>1 then
    with TReaderObject(ReaderListBox.Items.Objects[1]) do
    begin

        if ConnectReader then
        begin
            LCDClear;
            LCDTextLeft(0,'Tag ID :');
            LCDTextRight(1,Tag);
        end;
    end;
end;


end.


