{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                      }
{-------------------------------------------------------}
{       Unit HamDungSan                                 }
{       Xu lu cac Ham dung san.                         }
{*******************************************************}

unit HamDungSan;

interface

{
   May ao PL/0 co the hieu va thuc thi duoc nhung ham dung san duoc khai
   bao duoi day (kieu TEIntrinsicFunction)

   Viec them bot cac ham dung san chi can thuc hien trong unit.
   Tru nhung ham co cach bieu dien dac biet nhu ham abs can phai viet them
   cac phuong thuc lien quan toi viec ve ham ra man hinh.

   De them mot ham ta phai:
   1. Khai bao them hang so cho ham moi trong TEIntrinsicFunction
   2. Tang hang so NFunc (khai bao o duoi, trong phan implementetion)
   3. Sua doi InitFuncTable de them ten ham. Chu y la phai them sao cho
      ten cac ham co thu tu tang dan. Ly do la ta se su dung Tim kiem nhi phan
      (Binary search) de xac dinh xem mot dinh danh co phai la ten ham dung
      san hay khong.
   4. Sua GetFuncName de them tem ham vao.
   5. Sua CalcFunc de them tem ham vao.

   Voi nhung ham co bieu dien dac biet nhu ham abs (ham abs(x) phai duoc ve |x|)
   thi ngoai viec sua doi o day ta con phai sua doi trong TNode (trong ParseTree.pas)
   de ham co the duoc ve chinh xac nhu mong muon .
}

type

TEIntrinsicFunction=(
   funcSin,
   funcCos,
   funcTan,
   funcArcTan,
   funcSQRT,
   funcSQR,
   funcLn,
   funcExp,
   funcAbs
);

function IsIntrinsicFunction(const Name: string; var aFunc: TEIntrinsicFunction): boolean;
function CalcFunc(aFunc: TEIntrinsicFunction; X: double): Double;
function GetFuncName(aFunc:TEIntrinsicFunction): string;

implementation {--------------------------------------------------------------}

uses SysUtils;

type

TFuncRec = record
  FuncName: string;
  Func: TEIntrinsicFunction;
end;

const NFunc = 9;

var
  FuncTable : array[0..NFunc-1] of TFuncRec;

procedure InitFuncTable;
var
  i:integer;
begin
  i:= 0;
// Bang nay phai duoc sort theo Ten ham  
  FuncTable[i].FuncName:= 'ABS';    FuncTable[i].Func:= funcAbs;     Inc(i);
  FuncTable[i].FuncName:= 'ARCTAN'; FuncTable[i].Func:= funcArcTan;  Inc(i);
  FuncTable[i].FuncName:= 'COS';    FuncTable[i].Func:= funcCos;     Inc(i);
  FuncTable[i].FuncName:= 'EXP';    FuncTable[i].Func:= funcExp;     Inc(i);
  FuncTable[i].FuncName:= 'LN';     FuncTable[i].Func:= funcLn;      Inc(i);
  FuncTable[i].FuncName:= 'SIN';    FuncTable[i].Func:= funcSin;     Inc(i);
  FuncTable[i].FuncName:= 'SQR';    FuncTable[i].Func:= funcSQR;     Inc(i);
  FuncTable[i].FuncName:= 'SQRT';   FuncTable[i].Func:= funcSQRT;    Inc(i);
  FuncTable[i].FuncName:= 'TAN';    FuncTable[i].Func:= funcTan;     //Inc(i);
end;

function IsIntrinsicFunction(const Name: string; var aFunc: TEIntrinsicFunction): boolean;
// Tim xem ham voi ten Name co trong bang cac ham dung san hay khong
// Su dung tim kiem nhi phan
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := NFunc - 1;
  while L <= H do  begin
    I := (L + H) shr 1;

    if FuncTable[I].FuncName < Name then begin
      C:= -1
    end else if FuncTable[I].FuncName=Name then begin
      C:= 0
    end else begin
      C := 1;
    end;

    if C = 0 then begin
      Result:= True;
      aFunc:= FuncTable[I].Func;
      Exit;
    end else if C < 0 then begin
      L := I + 1
    end else begin
      H := I - 1;
    end;
  end;
end;


function GetFuncName(aFunc:TEIntrinsicFunction): string;
begin
  case aFunc of
    funcSin     : Result := 'SIN';
    funcCos     : Result := 'COS';
    funcTan     : Result := 'TAN';
    funcArcTan  : Result := 'ARCTAN';
    funcSQR     : Result := 'SQR';
    funcSQRT    : Result := 'SQRT';
    funcLn      : Result := 'LN';
    funcExp     : Result := 'EXP';
    funcAbs     : Result := 'ABS';
    else
      raise Exception.Create('GetFuncName: Khong co ham nay');
  end;
end;

function CalcFunc(aFunc: TEIntrinsicFunction; X: double): Double;
begin
  case aFunc of
    funcSin     : Result := Sin(X);
    funcCos     : Result := Cos(X);
    funcTan     : Result := Sin(X)/Cos(X);
    funcArcTan  : Result := ArcTan(X);
    funcSQR     : Result := SQR(X);
    funcSQRT    : Result := SQRT(X);
    funcLn      : Result := Ln(X);
    funcExp     : Result := Exp(X);
    funcAbs     : Result := Abs(X);
    else
      raise Exception.Create('Ham nay khong tinh duoc.');
  end;
end;

initialization
  InitFuncTable;
finalization

end.
