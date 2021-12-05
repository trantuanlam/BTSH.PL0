{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                      }
{-------------------------------------------------------}
{       Unit ParseTree                                  }
{       Cay Bieu thuc so hoc (de ve cong thuc)          }
{*******************************************************}

unit ParseTree;

interface

uses Windows, {RectClass,} SysUtils, Classes, Interpreter;

type

TESymbol = (symNone, symIdent, symNumber,
            //symLeftParent, symRightParent, khong dung vi cay nay khong nhap nhang
            symPlus, symMinus, symTimes, symSlash, symNeg, // synNeg: dao dau
            symFunc,
            symPower);

TNodeLabel = string;


{  TNode : Nut cay cong thuc. Moi cong thuc se chua trong cay
   FormulaCenter: Tam cua cong thuc
   FormulaRect: hinh vuong chua cong thuc
}

TNode = class
private
  FSymbol: TESymbol;
  FNodeLabel: TNodeLabel;

  FLeftNode: TNode;
  FRightNode: TNode;

  FFormulaCenter: TPoint;
  FFormulaRect: TRect;
  FLabelRect: TRect; // hinh vuong dung de ve label
  FNeedPar: Boolean;  // co can dau ngoac bao quanh bieu thuc ?

  FValidCodeForDrawGraph: boolean;

  FCXFrom, FCXTo: Integer; // Vi tri bat dau, ket thuc ma cua bieu thuc

  function GetWidth: Integer;
  function GetHeight: Integer;
public
  constructor Create(const aNodeLabel: TNodeLabel; aSymbol: TESymbol);
  destructor Destroy; override;

  procedure Draw(DC: hDC);

  procedure AddLeft(const aNodeLabel: TNodeLabel; aSymbol: TESymbol);
  procedure AddRight(const aNodeLabel: TNodeLabel; aSymbol: TESymbol);
  procedure AddLeftTree(aTree: TNode);
  procedure AddRightTree(aTree: TNode);

  procedure Move(dx, dy: Integer);
  procedure MoveTo00;
  procedure WideFormulaRect(dx: Integer);
  procedure UpDateNeedPar;
  procedure UpdateRect(DC: hDC);

  procedure ShowNodeInfo; // for debuging
  procedure Duyet;        // for debuging

  property LeftNode: TNode read FLeftNode;
  property RightNode: TNode read FRightNode;
  property FormulaRect: TRect read FFormulaRect;

  property Width: Integer read GetWidth;
  property Height: Integer read GetHeight;

  property ValidCodeForDrawGraph: Boolean read FValidCodeForDrawGraph;
  property CXFrom : integer read FCXFrom write FCXFrom;
  property CXTo : integer read FCXTo write FCXTo;
end;


TNodeStack = class(TList)
private
  FLockCount: Integer;
  FHasError: Boolean;  // Co sai sot khi phan tich
  procedure AddNode(aLabel: string; aSym: TESymbol);
  procedure FreeItems;
  procedure Push(N: TNode);
  function Pop: TNode;

public
  destructor Destroy; override;

  procedure AddIdent(aName: string);
  procedure AddOperation(aLabel: string; aSym: TESymbol);
  procedure AddFunc(aLabel: string);
  procedure AddNeg(aLabel: string);
  procedure LockStack;
  procedure UnLockStack;
  function Disable: Boolean;
  procedure UpDateValidCodeForDrawGraph(aCPU: TVirtualCPU);

  function TOS: TNode;
  function GetValidItemIndex(ValidIndex: Integer; var ListIndex: integer): Boolean;
  procedure Reset;
  property HasError: boolean read FHasError;
end;

procedure SetCharHW(DC: hDC);

implementation  {--------------------------------------------------------------}

const
  cCharWidth : integer = 8;
  cCharHeight : integer = 14;
  cSpace : integer = 2;

procedure SetCharHW(DC: hDC);
var
  Size: TSize;
  S: string;
begin
  S:= 'A';
  GetTextExtentPoint32(DC, PChar(S), Length(S), Size);
  cCharWidth := Size.cx;
  cCharHeight := Size.cy;
  cSpace := cCharWidth div 4;
end;

function IntMin(i1, i2: integer): integer;
begin
  Result:= i1;
  if i2 < i1 then
    Result:= i2;
end;

function IntMax(i1, i2: integer): integer;
begin
  Result:= i1;
  if i2 > i1 then
    Result:= i2;
end;

constructor TNode.Create(const aNodeLabel: TNodeLabel; aSymbol: TESymbol);
begin
  inherited Create;
  FNodeLabel:= aNodeLabel;
  FSymbol := aSymbol;
end;

destructor TNode.Destroy;
begin
  // huy cac cay con truoc
  FLeftNode.Free;
  FRightNode.Free;
  inherited Destroy;
end;

function TNode.GetWidth: Integer;
begin
  Result:= FFormulaRect.Right - FFormulaRect.Left;
end;

function TNode.GetHeight: Integer;
begin
  Result:= FFormulaRect.Bottom - FFormulaRect.Top;
end;

procedure TNode.UpDateNeedPar;
{
  Xem co can dau ngoac bao quanh bieu thuc hay khong va cap
  nhat FNeedPar
}
begin
  if FSymbol in [symTimes, symNeg] then begin
    if Assigned(FLeftNode) and (FLeftNode.FSymbol in [symPlus, symMinus]) then
      FLeftNode.FNeedPar := true;
    if Assigned(FRightNode)and (FRightNode.FSymbol in [symPlus, symMinus]) then
      FRightNode.FNeedPar := true;
  end;
  if Assigned(FLeftNode) then
    FLeftNode.UpDateNeedPar;
  if Assigned(FRightNode) then
    FRightNode.UpDateNeedPar;
end;

procedure TNode.WideFormulaRect(dx: Integer);
begin
  Move(dx, 0);
  Dec(FFormulaRect.Left, dx);
  Inc(FFormulaRect.Right, dx);
end;

procedure TNode.UpdateRect(DC: hDC);
{ Day la thu tuc quan trong. No cap nhat
    1. FFormulaRect
    2. FLabelRect
    3. FFormulaCenter

  cho tat ca cac nut trong cay.
  Thu tuc nay phai duoc goi truoc khi ve cong thuc
}

  function locGetTextRect(S: string): TRect;
  // Tinh hinh chu nhat bao quanh label
  var
    Size: TSize;
  const
    dx = 0;
    dy = 0;
  begin
     GetTextExtentPoint32(DC, PChar(S), Length(S), Size);
     Result.Left:= 0;
     Result.Top:= 0;
     Result.Right:= Size.cx;
     Result.Bottom:= Size.cy;
     InflateRect(Result, dx, dy);
  end;

var
  Dx, Dy: Integer;
  R: TRect;

begin
  // Cap nhat cho 2 cay ben trai va phai truoc (goi de qui)
  if Assigned(FLeftNode) then
    FLeftNode.UpdateRect(DC);
  if Assigned(FRightNode) then
    FRightNode.UpdateRect(DC);

  case FSymbol of
    symIdent, symNumber: begin
      // Truong hop la dinh danh hay so
      FFormulaRect.Left:= 0;
      FFormulaRect.Top:= 0;
      FFormulaRect.Right:= cCharWidth*Length(FNodeLabel);
      FFormulaRect.Bottom:= cCharHeight;

      FFormulaRect:= locGetTextRect(FNodeLabel);
      FLabelRect:= FFormulaRect;

      // Tam nam ngay giua hinh vuong
      FFormulaCenter.X:= (FFormulaRect.Left + FFormulaRect.Right) div 2;
      FFormulaCenter.Y:= (FFormulaRect.Top + FFormulaRect.Bottom) div 2;
    end;

    symPlus, symMinus, symTimes: begin
      // cac phep toan Cong, Tru, Nhan
      if not Assigned(FLeftNode) then
        raise Exception.Create('Left Node Must be present');
      if not Assigned(FRightNode) then
        raise Exception.Create('Right Node Must be present');

      Dx:= (FLeftNode.Width + FRightNode.Width) div 2 + cCharWidth+ 2*cSpace;
      Dx:= Dx + FLeftNode.FFormulaCenter.X - FRightNode.FFormulaCenter.X;
      Dy:= FLeftNode.FFormulaCenter.Y - FRightNode.FFormulaCenter.Y;
      FRightNode.Move(Dx, Dy);
      FFormulaRect.Left:= FLeftNode.FFormulaRect.Left;
      FFormulaRect.Right:= FRightNode.FFormulaRect.Right;
      FFormulaRect.Top:= IntMin(FLeftNode.FFormulaRect.Top, FRightNode.FFormulaRect.Top);
      FFormulaRect.Bottom:=IntMax(FLeftNode.FFormulaRect.Bottom, FRightNode.FFormulaRect.Bottom);
      FFormulaCenter.X:= (FFormulaRect.Left + FFormulaRect.Right) div 2;
      FFormulaCenter.Y := FLeftNode.FFormulaCenter.Y;

      FLabelRect.Left:= FLeftNode.FFormulaRect.Right + cSpace ;
      FLabelRect.Right:= FRightNode.FFormulaRect.Left ;
      FLabelRect.Top:= FLeftNode.FFormulaCenter.Y - cCharHeight div 2;
      FLabelRect.Bottom:= FLabelRect.Top + cCharHeight;
      if FNeedPar then
        WideFormulaRect(cCharWidth);
    end;

    symNeg: begin
      // Phep toan Dao dau
      // Chi co cay ben PHAI la dung
      // Cay ben Trai must be = nil
      if FLeftNode <> nil then
        raise Exception.CreateFmt('Dao dau(Neg) %s: Cay ben Trai phai = nil', [FNodeLabel]);

      Dx:= (0 + FRightNode.Width) div 2 + cCharWidth+1;
      Dx:= Dx - FRightNode.FFormulaCenter.X;
      Dy:= 0 - FRightNode.FFormulaCenter.Y;
      FRightNode.Move(Dx, Dy);
      FFormulaRect.Left:= 0;
      FFormulaRect.Right:= FRightNode.FFormulaRect.Right;
      FFormulaRect.Top:= IntMin(0, FRightNode.FFormulaRect.Top);
      FFormulaRect.Bottom:=IntMax(0, FRightNode.FFormulaRect.Bottom);
      FFormulaCenter.X:= (FFormulaRect.Left + FFormulaRect.Right) div 2;
      FFormulaCenter.Y := FRightNode.FFormulaCenter.Y;

      FLabelRect.Left:= 0;
      FLabelRect.Right:= FRightNode.FFormulaRect.Left;
      FLabelRect.Top:= 0 - cCharHeight div 2;
      FLabelRect.Bottom:= FLabelRect.Top + cCharHeight;
      if FNeedPar then
        WideFormulaRect(cCharWidth);
    end;
    symSlash: begin
      // phep chia
      if not Assigned(FLeftNode) then
        raise Exception.Create('Left Node Must be present');
      if not Assigned(FRightNode) then
        raise Exception.Create('Right Node Must be present');
      FLeftNode.MoveTo00;
      FRightNode.MoveTo00;
      Dx:= FLeftNode.FFormulaCenter.x - FRightNode.FFormulaCenter.x;
      Dy:= FLeftNode.Height + cCharHeight;
      FRightNode.Move(Dx, Dy);
      FFormulaRect.Left:= IntMin(FLeftNode.FFormulaRect.Left, FRightNode.FFormulaRect.Left);
      FFormulaRect.Right:= IntMax(FLeftNode.FFormulaRect.Right, FRightNode.FFormulaRect.Right);
      FFormulaRect.Top:= FLeftNode.FFormulaRect.Top;
      FFormulaRect.Bottom:= FRightNode.FFormulaRect.Bottom;
      FFormulaCenter.X:= (FFormulaRect.Left + FFormulaRect.Right) div 2;
      FFormulaCenter.Y := FLeftNode.FFormulaRect.Bottom + cCharHeight div 2;

      FLabelRect.Left:= FFormulaRect.Left;
      FLabelRect.Right:= FFormulaRect.Right;
      FLabelRect.Top:= FLeftNode.FFormulaRect.Bottom;
      FLabelRect.Bottom:= FRightNode.FFormulaRect.Top;
    end;
    symFunc: begin
      // Loi goi ham
      // Chi co cay ben TRAI la dung
      // Cay ben phai must be = nil
      if FRightNode <> nil then
        raise Exception.CreateFmt('Ham so %s: Cay ben phai phai = nil', [FNodeLabel]);
      FLeftNode.MoveTo00;

      // Xu ly rieng cho truong hop ham ABS
      if UpperCase(FNodeLabel)='ABS' then
        SetRect(R, 0,0,0,0)
      else
        R:= locGetTextRect(FNodeLabel);

      dx:= R.Right + cCharWidth + FLeftNode.Width div 2 - FLeftNode.FFormulaCenter.X;
      dy:= cCharHeight div 2 - FLeftNode.FFormulaCenter.Y;
      FLeftNode.Move(dx, dy);
      FLabelRect:= R;
      FFormulaRect := R;

      Inc(FFormulaRect.Right, 2*cCharWidth + FLeftNode.Width);
      FFormulaRect.Top := IntMin(FFormulaRect.Top, FLeftNode.FFormulaRect.Top);
      FFormulaRect.Bottom := IntMax(FFormulaRect.Bottom, FLeftNode.FFormulaRect.Bottom);
      FFormulaCenter.X:= (FFormulaRect.Left + FFormulaRect.Right) div 2;
      FFormulaCenter.Y := FLeftNode.FFormulaCenter.Y;
    end;
    symPower: begin
     R:= locGetTextRect(FNodeLabel);
     FLabelRect:= R;
     dx:= R.Right + FLeftNode.Width div 2 - FLeftNode.FFormulaCenter.X;
     dy:= cCharHeight div 2 - FLeftNode.FFormulaCenter.Y;
     FLeftNode.Move(dx, dy);
     FLeftNode.Move(0, -(2*cCharHeight div 3));
     FFormulaRect:= R;
     Inc(FFormulaRect.Right, LeftNode.Width);
     FFormulaRect.Top := IntMin(FFormulaRect.Top, FLeftNode.FFormulaRect.Top);
     FFormulaRect.Bottom := IntMin(FFormulaRect.Bottom, FLeftNode.FFormulaRect.Bottom);

     FFormulaCenter.X := (FFormulaRect.Left + FFormulaRect.Right) div 2;
     FFormulaCenter.Y := FLeftNode.FFormulaCenter.Y;
    end;
  end;
end;

procedure TNode.Draw(DC: hDC);
  procedure locDrawPar(const R: TRect);
  var
    P: array[0..3] of TPoint;
    LF: TLogFont;
    aFont, aF: hFont;
  begin
    aFont:= SelectObject(DC, GetStockObject(SYSTEM_FONT));
    SelectObject(DC, aFont);

    GetObject(aFont, SizeOf(LF), @LF);
    LF.lfHeight:= (R.Bottom - R.Top);
    LF.lfItalic := ord(false);
    LF.lfWidth:= cCharWidth *2 div 3; {cCharWidth}
    LF.lfWeight := FW_LIGHT;
    LF.lfFaceName:='Arial';//Arial

    aFont:= CreateFontIndirect(LF);
    aF:= SelectObject(DC, aFont);

    TextOut(DC, R.Left+cSpace, R.Top, '(', 1);
    TextOut(DC, R.Right-cCharWidth+cSpace, R.Top, ')', 1);

    SelectObject(DC, aF);
    DeleteObject(aFont);
    exit;

    P[0].X:= R.Left+5;
    P[0].Y:= R.Top;
    P[1].X:= R.Left;
    P[1].Y:= R.Top;
    P[2].X:= R.Left;
    P[2].Y:= R.Bottom;
    P[3].X:= R.Left+5;
    P[3].Y:= R.Bottom;
    Polyline(DC, P, 4);

    P[0].X:= R.Right-5;
    P[0].Y:= R.Top;
    P[1].X:= R.Right;
    P[1].Y:= R.Top;
    P[2].X:= R.Right;
    P[2].Y:= R.Bottom;
    P[3].X:= R.Right-5;
    P[3].Y:= R.Bottom;
    Polyline(DC, P, 4);
  end;

  procedure locDrawRect(const R: TRect);
  var P: array[0..4] of TPoint;
  begin
    locDrawPar(R);
    exit;
    P[0].X:= R.Left;
    P[0].Y:= R.Top;
    P[1].X:= R.Right;
    P[1].Y:= R.Top;
    P[2].X:= R.Right;
    P[2].Y:= R.Bottom;
    P[3].X:= R.Left;
    P[3].Y:= R.Bottom;
    P[4]:= P[0];
    Polyline(DC, P, 5);
  end;

  procedure locDrawAbs(const R: TRect);
  // ve dau gia tri tuyet doi
  var P: array[0..4] of TPoint;
  begin
    P[0].X:= R.Left+cCharWidth div 2;
    P[0].Y:= R.Top;
    P[1].X:= R.Left+cCharWidth div 2;
    P[1].Y:= R.Bottom;
    Polyline(DC, P, 2);

    P[0].X:= R.Right-cCharWidth div 2;
    P[0].Y:= R.Top;
    P[1].X:= R.Right-cCharWidth div 2;
    P[1].Y:= R.Bottom;
    Polyline(DC, P, 2);
  end;

  procedure locDrawDiv(const R: TRect);
  var P: array[0..1] of TPoint;
  begin
    P[0].X:= R.Left;
    P[0].Y:= (R.Top + R.Bottom) div 2;
    P[1].X:= R.Right;
    P[1].Y:= P[0].Y;
    Polyline(DC, P, 2);
  end;

var
  R: TRect;
begin
  if LeftNode <> nil then
    LeftNode.Draw(DC);
  if RightNode <> nil then
    RightNode.Draw(DC);

  if FSymbol in [symIdent, symNumber] then begin
    TextOut(DC, FFormulaRect.Left, FFormulaRect.Top, PChar(FNodeLabel), Length(FNodeLabel));
  end else if FSymbol in [symPlus, symMinus, symTimes, symNeg] then begin
    if FNeedPar then
      locDrawRect(FFormulaRect);
    TextOut(DC, FLabelRect.Left , FLabelRect.Top, PChar(FNodeLabel) , Length(FNodeLabel));
  end else if FSymbol in [symSlash] then begin
    locDrawDiv(FLabelRect);
  end else if FSymbol in [symFunc] then begin
      R:= FLeftNode.FFormulaRect;
      Dec(R.Left, cCharWidth);
      Inc(R.Right, cCharWidth);
    if UpperCase(FNodeLabel)='ABS' then begin
      // xu ly dac biet cho ham abs
      locDrawAbs(R);
    end else begin
      TextOut(DC, FLabelRect.Left+1 , FLabelRect.Top, PChar(FNodeLabel) , Length(FNodeLabel));
      locDrawRect(R);
    end;

  end else if FSymbol in [symPower] then begin
    TextOut(DC, FLabelRect.Left+1 , FLabelRect.Top, PChar(FNodeLabel), Length(FNodeLabel));
{    R:= FLeftNode.FFormulaRect;
    Dec(R.Left, cCharWidth);
    Inc(R.Right, cCharWidth);

    locDrawRect(R);
}
  end;
end;

procedure TNode.AddLeft(const aNodeLabel: TNodeLabel; aSymbol: TESymbol);
var aNode: TNode;
begin
  aNode:= TNode.Create(aNodeLabel, aSymbol);
  FLeftNode:= aNode;
end;

procedure TNode.AddRight(const aNodeLabel: TNodeLabel; aSymbol: TESymbol);
var aNode: TNode;
begin
  aNode:= TNode.Create(aNodeLabel, aSymbol);
  FRightNode:= aNode;
end;

procedure TNode.AddLeftTree(aTree: TNode);
begin
  FLeftNode:= aTree;
end;

procedure TNode.AddRightTree(aTree: TNode);
begin
  FRightNode:= aTree;
end;

procedure TNode.ShowNodeInfo;
// for debuging
const
  c = '%s  : Rect (%d %d %d %d), Center (%d %d)';
begin
  with   FFormulaCenter, FFormulaRect do
    Writeln(Format(c, [FNodeLabel, Left, Top, Right, Bottom, X, Y]));
end;

procedure TNode.Duyet;
begin
  ShowNodeInfo;
  if assigned(FLeftNode) then
    FLeftNode.Duyet;

  if assigned(FRightNode) then
    FRightNode.Duyet;
end;

procedure TNode.Move(dx, dy: Integer);
begin
  if Assigned(FLeftNode) then
    FLeftNode.Move(dx,dy);
  if Assigned(FRightNode) then
    FRightNode.Move(dx,dy);

  FFormulaCenter.X:= FFormulaCenter.X + dx;
  FFormulaCenter.Y:= FFormulaCenter.Y + dy;

  FFormulaRect.Left:= FFormulaRect.Left + dx;
  FFormulaRect.Right:= FFormulaRect.Right+ dx;
  FFormulaRect.Top:= FFormulaRect.Top+ dy;
  FFormulaRect.Bottom:= FFormulaRect.Bottom+ dy;

  FLabelRect.Left:= FLabelRect.Left + dx;
  FLabelRect.Right:= FLabelRect.Right+ dx;
  FLabelRect.Top:= FLabelRect.Top+ dy;
  FLabelRect.Bottom:= FLabelRect.Bottom+ dy;
end;

procedure TNode.MoveTo00;
begin
  Move(-FFormulaRect.Left, -FFormulaRect.Top);
end;

{============================================================================}
{                                  TNodeStack                                }
{============================================================================}
procedure TNodeStack.Push(N: TNode);
begin
  Add(N)
end;

function TNodeStack.Pop: TNode;
begin
  if Count = 0 then begin
    FHasError:= true;
    Result:= nil;
    exit;
  end;


  Result := Last;
  Remove(result);
end;

function TNodeStack.TOS: TNode;
// Top Of Stack = Dinh cua stack
begin
  if Count = 0 then begin
    FHasError:= true;
    Result:= nil;
    exit;
  end;

  Result := Last;
end;

procedure TNodeStack.FreeItems;
{
  huy bo tat ca cac Node trong danh sach va
  xoa danh sach ve rong
}
var i: Integer;
begin
  for i := 0 to Count - 1 do begin
    TObject(Items[i]).Free;
  end;
  Clear;
end;

destructor TNodeStack.Destroy;
begin
  FreeItems;
  inherited Destroy;
end;

procedure TNodeStack.AddNode(aLabel: string; aSym: TESymbol);
var N: TNode;
begin
  N:= TNode.Create(aLabel, aSym);
  Push(N);
end;

procedure TNodeStack.LockStack;
begin
  Inc(FLockCount);
end;

procedure TNodeStack.UnLockStack;
begin
  Dec(FLockCount);
end;

function TNodeStack.Disable: Boolean;
begin
  Result:= (FLockCount > 0) and not FHasError;
end;

procedure TNodeStack.AddOperation(aLabel: string; aSym: TESymbol);
{ thuc hien:
  - Tao 1 node moi;
  - Neu la cac phep tinh hai ngoi thi
    + Gan cac nut Left, Right bang hai nut tren dinh stack
    + Thao cac nut nay ra khoi stack
    + Them nut moi vao
}
var
  N: TNode;
begin
  if Disable then Exit;
  N:= TNode.Create(aLabel, aSym);
  if aSym in [symPlus, symMinus, symTimes, symSlash] then begin
    N.FRightNode:= Pop;
    N.FLeftNode:= Pop;
    Push(N);
  end;
end;

procedure TNodeStack.AddIdent(aName: string);
begin
  if Disable then Exit;
  AddNode(aName, symIdent);
end;

procedure TNodeStack.AddFunc(aLabel: string);
var N: TNode;
begin
  if Disable then Exit;
  N:= TNode.Create(aLabel, symFunc);
  N.FLeftNode:= Pop; // Dua expression lam doi so cua ham
  Push(N);
end;

procedure TNodeStack.AddNeg(aLabel: string);
var N: TNode;
begin
  if Disable then Exit;
  N:= TNode.Create(aLabel, symNeg);
  N.FRightNode:= Pop; // Dua expression lam doi so cua ham
  Push(N);
end;

procedure TNodeStack.Reset;
begin
  FreeItems;
  FLockCount:= 1;
  FHasError:= False;
end;

procedure TNodeStack.UpDateValidCodeForDrawGraph(aCPU: TVirtualCPU);
{ Kiem tra xem ma cua bieu thuc cua cay co the dung
  nhu Ham so de ve Do thi ham so hay khong.

  Chu y la ve do thi ham so va ve cong thuc la hai cong doan tach biet nhau.
  Ta co the ve duoc cong thuc nhung KHONG the ve duoc do thi (vi du do
  cong thuc co chua Y hay cac bien khac X o ben phai).
}

var
  NewCPU: TVirtualCPU;
  AdrX: Integer;

  function locCheckCode(i: Integer): boolean;
  begin
    AdrX:= 3;
    Result:= True;
    if NewCPU.CoCacBienKhac(AdrX, 4) then begin
      Writeln('Bieu thuc so ',i, ' ?: Bieu thuc chua cac bien khac X, Y.');
      Result:= False;
    end;
    if not NewCPU.CoBienYBenTrai(4) then begin
      Writeln('Bieu thuc so ',i, ' ?: Bieu thuc khong chua Y ben trai.');
      Result:= False;
    end;
    if not NewCPU.CoBienXBenPhai(AdrX) then begin
      Writeln('Bieu thuc so ',i, ' ?: Bieu thuc khong chua X ben phai.');
      Result:= False;
    end;
    if NewCPU.CoBienXBenPhai(4) then begin
      Writeln('Bieu thuc so ',i, ' ?: Bieu thuc co chua Y ben phai.');
      Result:= False;
    end;
  end;

var
  i: Integer;
  N: TNode;
  HasError: Boolean;
begin
  HasError:= False;
  NewCPU:= TVirtualCPU.Create;
  for i := 0 to Count - 1 do begin
    N:= Items[i];
    aCPU.PrepareExpressionCode(N.FCXFrom, N.FCXTo, NewCPU);
    N.FValidCodeForDrawGraph := locCheckCode(i);
    if not N.FValidCodeForDrawGraph then begin
      if not HasError then
         HasError:= true;
    end;
  end;
  NewCPU.Free;

  if HasError then begin
    Writeln;
    Writeln('MOT SO BIEU THUC KHONG HOP LE DE VE DO THI.');
    Writeln('Nhung bieu thuc tren se khong duoc ve len do thi.');
    Writeln('do chung khong duoc viet trong chuong trinh PL/0 theo nguyen tac :');
    Writeln(' 1. Phai khai bao hai bien X, Y dau tien (theo thu tu do).');
    Writeln(' 2. Bieu thuc phai co dang Y=f(X).');
    Writeln('     (Bien X chi xuat hien o ben phai bieu thuc, Bien Y chi xuat hien o ben trai.)');
    Writeln(' 3. Khong co bien nao khac than gia vao bieu thuc. (Nhung cac Hang thi co the)');
  end;
end;

function TNodeStack.GetValidItemIndex(ValidIndex: Integer; var ListIndex: integer): Boolean;
{ Tra lai chi so cua Bieu thuc "hop le de ve" co so thu tu la ValidIndex.}
var
  i, j: Integer;
  Node: TNode;
begin
  Result:= False;
  j:= 0;
  for i := 0 to Count - 1 do begin
    Node:= Items[i];
    if Node.ValidCodeForDrawGraph then begin
       if j = ValidIndex then begin
          ListIndex:= i;
          Result:= true;
          Exit;
       end else
         Inc(j);
    end;
  end;
end;

end.
