{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                      }
{-------------------------------------------------------}
{       Unit Interpreter                                }
{       May ao PL0 de Tinh toan Gia tri bieu thuc       }
{*******************************************************}

{ Sua doi tu chuong trinh dich PL/0 trong giao trinh    }
{ Thuc hanh ky thuat bien dich - Nguyen Van Ba          }

unit Interpreter;

// May ao PL0

interface

uses GlobalTypes;

const
  amax = 2*1024-1; // dia chi lon nhat
  levmax  =5;      // muc cao nhat cua cac block
  cmax = 2000;     // kich thuoc mang code

type
// Cac lenh cua PL0-VM

fct = (lit, opr, lod, sto, cal, int, jmp, jpc);

{
LIT 0, a : nap hang so a len dinh stack
OPR 0, a : thuc hien phep toan a doi voi hai phan tu tren dinh stack
LOD l, a : nap bien l, a len dinh stack // L: muc, a: dia chi
STO l, a : cat gia tri tren dinh stack vao bien l, a
CAL l, a : goi thu tuc co dia chi la a tai muc l
INT 0, a : tang a cho thanh ghi t (danh bo nho cho cac bien...)
JMP 0, a : nhay toi dia chi a
JPC 0, a : nhay co dieu kien toi dia chi a
}

const

mnemonic: array[fct] of string[3]=
  ('LIT', 'OPR', 'LOD', 'STO', 'CAL', 'INT', 'JMP', 'JPC');

const // cac phep toan ung voi ma lenh OPR

 oprTroVe  = 0;
 oprDaoDau = 1;
 oprCong   = 2;
 oprTru    = 3;
 oprNhan   = 4;
 oprChia   = 5;
 oprODD    = 6;
 opr_eql   = 8;
 opr_neq   = 9;
 opr_lss   = 10;
 opr_geq   = 11;
 opr_gtr   = 12;
 opr_leq   = 13;

 opr_CallFunc   = 14;

type

TRInstruction = packed record
  OpCode: fct;        { ma lenh}
  NestedLevel: Byte; // 0..levmax;  { muc } { Cung co the chua ord(func) }
  case Integer of
    0: (a: 0..amax);    { dia chi hay do doi }
    1: (FloatValue: TFloat);
end;


const StackSize = 500;

type

// Don vi du lieu luu trong bo nho du lieu

TData = record
  case integer of
  0: (IValue: Integer);
  1: (FValue: TFloat)
end;

// May ao PL0

TVirtualCPU=class
private
  FCX: Integer;
  s: array[1..StackSize] of TData; { bo nho du lieu }
  FDebug: Boolean;
public
  FCode: array[0..cmax] of TRInstruction;  // Bo nho chua ma chuong trinh PL0

  procedure Init;
  procedure IGen(x: fct; y, z: Integer);
  procedure FGen(x: fct; y: Integer; z: TFloat);
  procedure ListCode(iFrom, iTo: Integer);
  procedure ListAllCode;
  procedure Interpret;

  procedure PrepareExpressionCode(CXFrom, CXTo: integer; aCPU: TVirtualCPU);

  procedure GetYArray(adrX, AdrY: Integer; const X: TArrayFloat; var Y: TArrayFloat; Count: integer);
  function GiaiPhuongTrinh(adrX, AdrY: Integer;a, b, zero: TFloat; var X: TFloat): Integer;
  function GiaTriHam(adrX, AdrY: Integer; X: TFloat): TFloat;
  function CoCacBienKhac(adrX, AdrY: Integer): boolean; // Kiem tra xem co cac biem khac tham du vao bieu thuc hay khong
  function CoBienXBenPhai(adrX: Integer): boolean;
  function CoBienYBenTrai(adrY: Integer): boolean;

  property CX: Integer read FCX;
  property Debug: Boolean read FDebug write FDebug;
end;

implementation {--------------------------------------------------------------}

uses SysUtils, TuVung, HamDungSan;

function OprName(a: integer): string;
begin
 case a of
   oprTroVe : Result := 'Tro ve';
   oprDaoDau: Result := 'Dao dau';
   oprCong  : Result := '+';
   oprTru   : Result := '-';
   oprNhan  : Result := '*';
   oprChia  : Result := '/';
   oprODD   : Result := 'ODD';
   opr_eql  : Result := '==';
   opr_neq  : Result := '<>';
   opr_lss  : Result := '<';
   opr_geq  : Result := '>=';
   opr_gtr  : Result := '>';
   opr_leq  : Result := '<=';
   opr_CallFunc: Result  := 'Goi ham';
 end;
end;

procedure TVirtualCPU.IGen(x: fct; y, z: Integer);
// sinh ma cho cac cau lenh so nguyen (lien quan toi dia chi)
begin
  if Fcx > cmax then begin
    writeln('Program too long');
    abort;
  end;
  with FCode[Fcx] do begin
    OpCode:= x;
    NestedLevel:= y;
    a:= z;
  end;
  inc(Fcx);
end;

procedure TVirtualCPU.FGen(x: fct; y: Integer; z: TFloat);
// sinh ma cho cac cau lenh lien quan toi tinh toan so thuc
begin
  if Fcx > cmax then begin
    writeln('Program too long');
    abort;
  end;
  with FCode[Fcx] do begin
    OpCode:= x;
    NestedLevel:= y;
    FloatValue:= z;
  end;
  inc(Fcx);
end;

procedure TVirtualCPU.ListCode(iFrom, iTo: Integer);
//  liet ke ma da sinh ra cho khoi lenh
var i: Integer;
begin {ListCode}
  for i:= iFrom to iTo do begin
    with FCode[i] do begin
      case OpCode of
        lit: writeln(i:2, mnemonic[OpCode]:5, NestedLevel:3, FloatValue:6:1);
        opr: begin
          write(i:2, mnemonic[OpCode]:5, NestedLevel:3, a:5, '  (', OprName(a));
          if a = opr_CallFunc then
             write(' '+GetFuncName(TEIntrinsicFunction(NestedLevel)));
          Writeln(')');
        end;
        else
           writeln(i:2, mnemonic[OpCode]:5, NestedLevel:3, a:5);
      end; {case}
    end;
  end;
end; {ListCode}

procedure TVirtualCPU.ListAllCode;
begin
  ListCode(0, FCX-1);
end;

procedure TVirtualCPU.Interpret;
{ cac thanh ghi chuong trinh, day doan du lieu va dinh Stack }
{ b: chi toi day doan du lieu nam tren cung o trong stack }
{ p: lenh se thuc hien trong chuong trinh dich }
{ t: top of stack }

var
  p, b, t: Integer;
  i: TRInstruction;  { thanh ghi lenh }
  { ta khong khoi tao bo nho du lieu o day. Bo nho du lieu duoc khoi tao
    1 lan khi doi tuong duoc khoi tao.
  }


  function Base(l: Integer): Integer;
  { tim day doan du lieu bang cach tut l muc }
  var b1: Integer;
  begin
    b1:= b;
    while l > 0 do begin
      b1:= s[b1].IValue;
      Dec(l);
    end;
    result := b1;
  end;

  procedure locShowTrace(s: string);
  // Viet ra tap tin chuan Output qua trinh thuc hien chuong trinh
  begin
    if FDebug then
      Writeln(format('%2d %s', [p-1, s]));
  end;

  procedure CheckStack(AllocSize: Integer);
  const
    ErrStackOverFlow = 'Stack overflow.'#13#13'Tran stack, co the do goi de qui qua nhieu lan.'#13+
                       'Kiem tra lai thuat giai trong chuong trinh nguon, nhat la nhung cho co goi de qui.';
  begin
    if t +  AllocSize >= StackSize then
       raise Exception.Create(ErrStackOverFlow);
  end;

const
  BoolStr: array[boolean] of string=('False', 'True');
var
  tmp: TFloat;

begin { Interpret }
  if FCX = 0 then begin
    Writeln('Chua co ma nao duoc sinh ra');
    raise Exception.Create('Chua co ma nao duoc sinh ra');
  end;

  if FDebug then
    writeln('Start PL/0 interpreter');

  t:= 0;
  b:= 1;
  p:= 0;
  s[1].IValue:=0;  // 3 o dau danh cho SL, DL, RA - Static link, Dynamic link va Return Address
  s[2].IValue:=0;
  s[3].IValue:=0;

  repeat
    i:= FCode[p];
    inc(p);
    with i do begin
      case OpCode of
        lit: // nap hang so len dinh stack
          begin
            CheckStack(1);
            inc(t);
            s[t].FValue := FloatValue;
            locShowTrace(Format('LID %2.2f',[FloatValue]));
          end;
        opr: {cac phep toan }
          case a of
            oprTroVe:
               begin  // tro ve
                t:= b-1;
                locShowTrace(format('Return to @%d', [s[t+3].IValue]));
                p:= s[t+3].IValue;
                b:= s[t+2].IValue;
              end;
            oprDaoDau: s[t].FValue := -s[t].FValue;  // dao dau
            oprCong:
              begin // phep cong
                Dec(t);
                s[t].FValue:= s[t].FValue + s[t+1].FValue;
                locShowTrace(Format('+ : %2.2f=%2.2f + %2.2f',[s[t].FValue, s[t].FValue-s[t+1].FValue, s[t+1].FValue]));
              end;
            oprTru:
              begin // phep tru
                Dec(t);
                s[t].FValue:= s[t].FValue - s[t+1].FValue;
                  locShowTrace(Format('- : %2.2f=%2.2f - %2.2f',[s[t].FValue, s[t].FValue+s[t+1].FValue, s[t+1].FValue]));
              end;
            oprNhan:
              begin // phep nhan
                Dec(t);
                locShowTrace(Format('* : %2.2f=%2.2f * %2.2f',[s[t].FValue*s[t+1].FValue, s[t].FValue, s[t+1].FValue]));
                s[t].FValue:= s[t].FValue * s[t+1].FValue;
              end;
            oprChia:
              begin // phep chia
                Dec(t);
                s[t].FValue:= s[t].FValue / s[t+1].FValue;
                locShowTrace(Format('/ : %2.2f=%8.2f / %2.2f',[s[t].FValue, s[t].FValue*s[t+1].FValue, s[t+1].FValue]));
              end;
            oprODD: begin
                s[t].IValue:= ord(odd(round(s[t].FValue)));  // ODD
                locShowTrace(format('ODD %s', [BoolStr[s[t].IValue=1]]));
              end;

            7: begin end; // nothing

            opr_eql:
              begin // phep so sanh bang eql
                Dec(t);
                s[t].IValue:= ord(s[t].FValue= s[t+1].FValue);
                locShowTrace(format('= : %s (opr_eql)', [BoolStr[s[t].IValue=1]]));
              end;
            opr_neq:
              begin // phep so sanh <> neq
                Dec(t);
                s[t].IValue:= ord(s[t].FValue <> s[t+1].FValue);
                locShowTrace(format('<>: %s (opr_nql)', [BoolStr[s[t].IValue=1]]));
              end;
            opr_lss:begin // phep so sanh < lss
                Dec(t);
                s[t].IValue:= ord(s[t].FValue < s[t+1].FValue);
                locShowTrace(format('< : %s (opr_lss)', [BoolStr[s[t].IValue=1]]));
              end;

            opr_geq:begin // phep so sanh >= geq
                Dec(t);
                s[t].IValue:= ord(s[t].FValue >= s[t+1].FValue);
                locShowTrace(format('>=: %s (opr_geq)', [BoolStr[s[t].IValue=1]]));
              end;
            opr_gtr:begin // phep so sanh > gtr
                Dec(t);
                s[t].IValue:= ord(s[t].FValue > s[t+1].FValue);
                locShowTrace(format('> : %s (opr_gtr)', [BoolStr[s[t].IValue=1]]));
              end;
            opr_leq:begin // phep so sanh leq <=
                Dec(t);
                s[t].IValue:= ord(s[t].FValue <= s[t+1].FValue);
                locShowTrace(format('<=: %s (opr_leq)', [BoolStr[s[t].IValue=1]]));
              end;

            opr_CallFunc:begin // Tinh gia tri ham
                tmp:= s[t].FValue;
                s[t].FValue:= CalcFunc(TEIntrinsicFunction(NestedLevel), s[t].FValue);
                locShowTrace(Format('%2.2f=%s(%2.2f)',[s[t].FValue, GetFuncName(TEIntrinsicFunction(NestedLevel)), tmp]));
              end;
          end;
        lod:
          begin
            Inc(t);
            s[t].FValue:= s[base(NestedLevel)+a].FValue; // dua 1 bien len dinh stack
            locShowTrace(Format('LOD @%d %2.2f', [base(NestedLevel)+a, s[t].FValue]));
          end;
        sto:
          begin // cat gia tri tren dinh ngan xep vao 1 bien
            locShowTrace(Format('STO @%d %2.2f', [base(NestedLevel)+a, s[t].FValue]));
            s[base(NestedLevel)+a].FValue:= s[t].FValue;
            Dec(t);
          end;
        cal: // soan sua de chuyen toi chuong trinh con
          begin
            locShowTrace(Format('Call sub @%d ', [a]));
            s[t+1].IValue:= base(NestedLevel);
            s[t+2].IValue:= b;
            s[t+3].IValue:= p;
            b:= t+1;
            p:= a;
          end;
        int: begin
            CheckStack(a);
            t:= t+a;  // bo a don vi bo nho trong de danh cho du lieu
            locShowTrace(format('INT %d (tang con tro ngan xep)', [a]));
          end;
        jmp: begin
            locShowTrace(format('JMP to @%d', [a]));
            p:= a;
          end;
        jpc:
          begin
            locShowTrace(format('JPC to @%d', [a]));
            if s[t].IValue = 0 then begin
              p:= a;
            end;
            Dec(t); // bo phan ket qua so sanh tren stack
          end;
      else
        raise Exception.Create('Unexpected: Trinh Bien dich sai???. Ma lenh nay khong the co');
      end;
    end; { with }
  until p =0;
  if FDebug then
    writeln('End PL/0');
end; { Interpret }

procedure TVirtualCPU.Init;
// khoi tao may ao
begin
  FCX:= 0;
end;

function TVirtualCPU.CoCacBienKhac(adrX, AdrY: Integer): boolean;
// Kiem tra xem co cac biem khac tham du vao bieu thuc hay khong
var i: Integer;
begin
  Result:= False;
  for i:= 0 to FCX-1 do begin
    with FCode[i] do begin
      if ((OpCode = sto)or(OpCode = lod)) and ((a <> adrX) and (a <> adrY)) then begin
        Result:= True;
        Exit;
      end;
    end;
  end;
end;


function TVirtualCPU.CoBienYBenTrai(adrY: Integer): boolean;
// Kiem tra xem co bien Y tham du vao bieu thuc phia ben trai hay khong (Y:=... ?)
var i: Integer;
begin
  Result:= false;
  for i:= 0 to FCX-1 do begin
    with FCode[i] do begin
      if (OpCode = sto) and (a = adrY) then begin
        Result:= True;
        Exit;
      end;
    end;
  end;
end;

function TVirtualCPU.CoBienXBenPhai(adrX: Integer): boolean;
// Kiem tra xem co bien X tham du vao bieu thuc phia ben phai hay khong (..:=...X... ?)
var i: Integer;
begin
  Result:= false;
  for i:= 0 to FCX-1 do begin
    with FCode[i] do begin
      if (OpCode = lod) and (a = adrX) then begin
        Result:= true;
        Exit;
      end;
    end;
  end;
end;

procedure TVirtualCPU.PrepareExpressionCode(CXFrom, CXTo: integer; aCPU: TVirtualCPU);
// tao ra May ao moi co Ma thuc thi la pham ma cua mot Bieu thuc
var i, j: integer;
begin
  aCPU.Init;
  aCPU.IGen(JMP, 0, 1);
  aCPU.IGen(INT, 0, 5); // 3 o nho cho RA, SL, DL va 2 bien X, Y
  j:= 2;
  for i:= CXfrom to CXto-1 do begin
    aCPU.FCode[j]:= FCode[i];
    Inc(j);
  end;
  aCPU.FCX:= J;
  aCPU.IGen(opr, 0, oprTroVe);
end;

procedure TVirtualCPU.GetYArray(adrX, AdrY: Integer; const X: TArrayFloat; var Y: TArrayFloat; Count: integer);
// Tinh toan hang loat gia tri cua Y theo cac gia tri tuong ung cua X
// Thuong dung khi ve do thi
var
  i: integer;
begin
  if not CoBienXBenPhai(AdrX) then
    AdrX:= StackSize -1;

  for i:= 0 to Count-1 do begin
    S[adrX+1].FValue := X[i];
    Interpret;
    Y[i]:= S[adrY+1].FValue; //1: base cua level 0
  end;
end;

function TVirtualCPU.GiaTriHam(adrX, AdrY: Integer; X: TFloat): TFloat;
begin
  S[adrX+1].FValue := X;
  Interpret;
  Result:= S[adrY+1].FValue; //1: base cua level 0
end;

function TVirtualCPU.GiaiPhuongTrinh(adrX, AdrY: Integer;a, b, zero: TFloat; var X: TFloat): Integer;
// Giai phuong trinh gan dung bang phuong phap chia doi
// gia tri ham tai a va b phai khac dau
  function F(X: TFloat): TFloat;
  begin
    S[adrX+1].FValue := X;
    Interpret;
    Result:= S[adrY+1].FValue; //1: base cua level 0
  end;

var
  Y1, Y2, Y, M: TFloat;
begin
  Result:= -1; // vo nghiem
  Y1:= F(a);
  if abs(y1) < Zero then begin
    X:= a;
    Result:= 1;
    Exit;
  end;

  Y2:= F(b);
  if abs(y2) < Zero then begin
    X:= b;
    Result:= 1;
    Exit;
  end;

  if Y1*Y2 > 0 then exit; // Vo nghiem

  while abs(a-b) > Zero/10 do begin
    M:= 0.5*(a+b);
    Y:= F(M);
    if abs(y) < Zero then begin
      X:= M;
      Result:= 1;
      Exit;
    end;
    if Y*Y1 < 0 then
      b:= M
    else
      a:= M;
  end;
end;

end.
