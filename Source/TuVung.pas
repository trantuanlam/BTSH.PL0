{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                      }
{-------------------------------------------------------}
{       Unit  TuVung                                    }
{       Bo phan tich tu vung                            }
{*******************************************************}

{ Sua doi tu chuong trinh dich PL/0 trong giao trinh    }
{ Thuc hanh ky thuat bien dich - Nguyen Van Ba          }


unit TuVung;
{ Bo phan tich tu vung }

interface

const al = 10;   { do dai danh bieu }

const
  nrow = 11; { so tu khoa reserved words }
  txmax=100; { do dai bang ky hieu }
  nmax = 5;  { so toi da cac con so trong 1 so }

type


alpha = string[al];
object_ = (constant, variable, procedure_);

type

symbol = ( null, ident, number, plus, minus, times, slash, oddsym, eql, neq, lss,
          leq, gtr, geq, lparent, rparent, colon, comma, semicolon, period, becomes,
          beginsym, endsym, ifsym, thensym, whilesym, dosym, callsym,
          constsym, varsym, procsym
          );
const
symbolName : array[Symbol] of string[10] =
          ( 'null', 'ident', 'number', 'plus', 'minus', 'times', 'slash', 'oddsym', 'eql', 'neq', 'lss',
          'leq', 'gtr', 'geq', 'lparent', 'rparent', 'colon', 'comma', 'semicolon', 'period', 'becomes',
          'beginsym', 'endsym', 'ifsym', 'thensym', 'whilesym', 'dosym', 'callsym',
          'constsym', 'varsym','procsym'
          );

type
  symSet = set of symbol;

var
  declbegsys, ststbegsys, facbesys: symSet;

type

TPhanTichTuVung = class
private
  FOrgLine: string; // Chua UpperCaase
  Line: string;     // Da Uppercase
  CC: Integer;      // CurrentChar
  LastChar: integer;
  Ch: Char;
  FOrgCh: Char;
  procedure SetLine(L: string);
private
  FSym: symbol;
  FId: Alpha;
  FNum: Double;
  FOrgId: Alpha; // Chinh la FId chua duoc UpperCase
private
  ErrorCount: integer;
  FErrorPos: integer;
  FLastErrorString: string;
public
  constructor Create;
  procedure InitBuf(S: string);
  procedure Error(ErrCode: integer);
  procedure GetSym;
  function HasError: Boolean;

  procedure LoadSourceFromFile(FN: string);

  property Sym: symbol read FSym;
  property id: Alpha read FId;
  property Num: Double read FNum;
  property OrgId: Alpha read FOrgId;
  property ErrorPos: Integer read FErrorPos;
  property LasErrorString: string read FLastErrorString;
end;

implementation {--------------------------------------------------------------}

uses SysUtils, Classes;

var
  word: array[1..nrow] of alpha;  {reserved word}
  wsym: array[1..nrow] of symbol;
  ssym: array[char] of symbol;


const
  sErr1='Dung = thay vi :=';
  sErr2='Sau = phai la mot so';
  sErr3='Sau ten phai la =';
  sErr4='Sau CONST, VAR, PROCEDURE phai la mot ten';
  sErr5='Bo sot dau cham phay hay dau phay';
  sErr6='Ky hieu khong dung sau dinh nghia thu tuc';
  sErr7='Dang cho cau lenh';
  sErr8='Ky hieu khong dung trong phan cau lenh trong BLOCK';
  sErr9='Dang cho dau cham "."';
  sErr10='Bo sot dau cham phay giua cac cau lenh';
  sErr11='Ten khong khai bao';
  sErr12='Khong duoc gan cho hang cho chuong trinh con';
  sErr13='Dang cho :=';
  sErr14='Sau CALL phai la mot ten thu tuc';
  sErr15='Goi mot hang hay mot bien la vo nghia';
  sErr16='Dang cho THEN';
  sErr17='Dang cho dau cham phay hay END';
  sErr18='Dang cho DO';
  sErr19='Ky hieu khong dung theo sau cau lenh';
  sErr20='Dang cho toan tu quan he';
  sErr21='Trong bieu thuc khong the co ten thu tuc';
  sErr22='Bo sot dau ngoac don phai';
  sErr23='Ky hieu nay khong the theo sau nhan thuc o truoc';
  sErr24='Ky hieu nay khong the dung dau bieu thuc';
  sErr30='So nay qua lon';


  sErr31='So dau phay dong bi sai';
  sErr32='Bieu thuc doi so ham bi sai';
  sErr33='Loi goi ham sai:Can dau "(" sau ten ham';
  sErr34='Loi goi ham sai: Dang cho ")"';

function ErrMsg(ErrCode: integer): string;
begin
  case ErrCode of
    1: ErrMsg := sErr1;
    2: ErrMsg := sErr2;
    3: ErrMsg := sErr3;
    4: ErrMsg := sErr4;
    5: ErrMsg := sErr5;
    6: ErrMsg := sErr6;
    7: ErrMsg := sErr7;
    8: ErrMsg := sErr8;
    9: ErrMsg := sErr9;
    10: ErrMsg:= sErr10;
    11: ErrMsg:= sErr11;
    12: ErrMsg:= sErr12;
    13: ErrMsg:= sErr13;
    14: ErrMsg:= sErr14;
    15: ErrMsg:= sErr15;
    16: ErrMsg:= sErr16;
    17: ErrMsg:= sErr17;
    18: ErrMsg:= sErr18;
    19: ErrMsg:= sErr19;
    20: ErrMsg:= sErr20;
    21: ErrMsg:= sErr21;
    22: ErrMsg:= sErr22;
    23: ErrMsg:= sErr23;
    24: ErrMsg:= sErr24;
    30: ErrMsg:= sErr30;
    31: ErrMsg:= sErr31;
    32: ErrMsg:= sErr32;
    33: ErrMsg:= sErr33;
    34: ErrMsg:= sErr34;
    else ErrMsg:= format('Loi so %d chua co ten', [ErrCode]);
  end;

end;

procedure TPhanTichTuVung.Error(ErrCode: integer);
begin
  FErrorPos:= LastChar;
  FLastErrorString:= format('Loi :%d %s', [ErrCode, ErrMsg(ErrCode)]);
  Writeln(FLastErrorString);
  Inc(ErrorCount);
  Abort;
end;

procedure InitTables;
  procedure FillWord(n: integer; const S: string);
  var i:integer;
  begin
    { khong kiem tra vuot chieu dai }
    for i:= 1 to length(s) do
      word[n][i]:= s[i];
  end;

var Ch: char;
begin
  for Ch:= #0 to #127 do ssym[Ch] := null;
  word[ 1]:='BEGIN';
  word[ 2]:='CALL';
  word[ 3]:='CONST';
  word[ 4]:='DO';
  word[ 5]:='END';
  word[ 6]:='IF';
  word[ 7]:='ODD';
  word[ 8]:='PROCEDURE';
  word[ 9]:='THEN';
  word[10]:='VAR';
  word[11]:='WHILE';

  wsym[1] := beginsym;
  wsym[2] := callsym;
  wsym[3] := constsym;
  wsym[4] := dosym;
  wsym[5] := endsym;
  wsym[6] := ifsym;
  wsym[7] := oddsym;
  wsym[8] := procsym;
  wsym[9] := thensym;
  wsym[10] := varsym;
  wsym[11] := whilesym;

  ssym['+'] := plus;
  ssym['-'] := minus;
  ssym['*'] := times;
  ssym['/'] := slash;
  ssym['('] := lparent;
  ssym[')'] := rparent;
  ssym['='] := eql;
  ssym[','] := comma;
  ssym['.'] := period;
  ssym['~'] := neq;
  ssym['<'] := lss;
  ssym['>'] := gtr;
  ssym[';'] := semicolon;
end;


{============================================================================}
{                                 TPhanTichTuVung                            }
{============================================================================}

constructor TPhanTichTuVung.Create;
begin
  inherited Create;
  ErrorCount:= 0;
  FErrorPos:= -1;
end;

procedure TPhanTichTuVung.InitBuf(S: string);
begin
  ErrorCount:= 0;
  FErrorPos:= -1;
  FLastErrorString:= '';
  SetLine(S);
end;

procedure TPhanTichTuVung.GetSym;
  procedure GetCh;
  begin
    if cc = Length(Line) then begin
//      writeln('Program incomlete');
      Ch := #255;
    end else begin
      Inc(cc);
      Ch:= Line[cc];
      FOrgCh := FOrgLine[cc];
    end;
  end;

var
  i, j, k: integer;
  s1, s2: string;
  Code: integer;

begin { GetSym }
  LastChar:= CC;
  while Ch in [' ', #0..#31] do GetCh;  {skip white}
  if Ch in ['A'..'Z'] then begin { danh bieu hay reserved word}
     Fid:= Ch;
     FOrgID:= FOrgCh;
     GetCh;

     while Ch in ['A'..'Z', '0'..'9'] do begin
       Fid:= Fid + Ch;
       FOrgID:= FOrgID + FOrgCh;
       GetCh;
     end;
      i:= 1;
      j:= nrow;

      { binary search }

      repeat
        k:= (i+j) div 2;
        if id <= word[k] then j:= k-1;
        if id >= word[k] then i:= k+1;
      until i > j;

      if i - 1 > j then
        Fsym := wsym[k]
      else
        Fsym := ident;
      //
  end else if Ch in ['0'..'9'] then begin
      { so thuc }
      k := 0;
      Fnum:= 0;
      Fsym:= number;
      S1:= '';
      repeat
        S1:= S1 + Ch;
        k:= k+1;
        GetCh;
      until not( Ch in ['0'..'9']);
      S2:='';

      if Ch='.'then begin
        S2 :='.';
        GetCh;
        repeat
          S2:= S2 + Ch;
          k:= k+1;
          GetCh;
        until not( Ch in ['0'..'9']);
      end;

      Val(S1+S2, FNum, Code);
      if Code <> 0 then begin
        Error(31);
      end;

      if k > nmax then Error(30);
  end else if Ch =':' then begin
      GetCh;
      if Ch = '=' then begin
        Fsym := becomes;
        GetCh;
      end else
        FSym := null
  end else if Ch= '>' then begin
      GetCh;
      if Ch = '=' then begin
        FSym := geq;
        GetCh;
      end else
        FSym := ssym['>'];
  end else if Ch= '<' then begin
      GetCh;
      if Ch = '=' then begin
        FSym := leq;
        GetCh;
      end else
        FSym := ssym['<'];
  end else begin
      FSym := ssym[Ch];
      GetCh;
  end;
end; { GetSym }


procedure TPhanTichTuVung.SetLine(L: string);
begin
  FOrgLine:= L;
  Line:= UpperCase(L);
  CC:= 0;
  Ch:=' ';
end;

procedure TPhanTichTuVung.LoadSourceFromFile(FN: string);
var St: TStringList;
begin
  St:= TStringList.Create;
  St.LoadFromFile(FN);
  InitBuf(St.Text);
  St.Free;
end;

function TPhanTichTuVung.HasError: Boolean;
begin
  Result:= ErrorCount > 0
end;

initialization
  InitTables;
end.






