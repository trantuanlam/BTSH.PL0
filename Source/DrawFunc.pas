{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                      }
{-------------------------------------------------------}
{       Unit Drawfunc                                   }
{       Xu lu ket qua tinh toan ham cho boi bieu thuc   }
{*******************************************************}

unit DrawFunc;

interface

uses
  Windows, classes, Graphics, Grids,
  ParseTree, GlobalTypes, Interpreter;

type

TGrid = class;

{ Ket qua tinh toan gia tri cac diem khac nhau cua ham so
  (thuong la tren mot doan [a, b]) }

TFuncResult = class
private
  FXY: array[0..cMaxArrSize] of TPoint;
  FGrid: TGrid;                // reference to Grid
  FXArr, FYArr: TArrayFloat;
  FCount: Integer;
  procedure FillXArr;
  procedure Draw(DC: hDC);
  procedure GetYMinMax(var Ymin, YMax: TFloat);

  procedure UpdateIntPoints;
public
  constructor Create(aGrid: TGrid);
end;

{ Danh sach cac ket qua tinh toan ham.
  Moi phan tu trong danh sach la 1 TFuncResult
}

TFuncResultList= class(TList)
private
  FGrid: TGrid;
  FNodeStack: TNodeStack;
  FCPU: TVirtualCPU;
  function GetFuncResult(i: Integer): TFuncResult;
  procedure FreeItems;
public
  constructor Create(aGrid: TGrid; NodeStack: TNodeStack; aCPU: TVirtualCPU);
  procedure MoveXY(DX, DY: integer);
  procedure Draw(DC: hDC);
  procedure UpdateIntPoints;
  procedure UpdateFuncResults;
  procedure UpDateTables(S: TStringGrid);
  procedure GetYMinMax(var Ymin, YMax: TFloat);

  property FuncResult[i: Integer]: TFuncResult read GetFuncResult;
  property Grid: TGrid read FGrid;
end;

{  Luoi de ve do thi }

TGrid = class
private
  FDX, FDY: integer; // buoc tang. dung de ve luoi. Theo man hinh
  FXMin, FXMax, FYMin, FYMax: integer; // toa do theo man hinh
  FOrg: TPoint; // diem  (0,0) logic
  FColor: integer;
  FScaleX, FScaleY: TFloat;  // De cac doi tuong khac su dung
public
  constructor Create(DX: TFloat; DY:TFloat);
  procedure Draw(DC: hDC; HorzScrollPos, VertScrollPos: integer); virtual;
  procedure DrawTickX(DC: hDC; ScrollPos: integer);
  procedure DrawTickY(DC: hDC; ScrollPos: integer);
  procedure MoveXY(const X, Y: TFloat);

  procedure MakeVisible;

  function XRange: integer; // toa do man hinh
  function YRange: integer; // toa do man hinh

  procedure GetLogicalMinMax(var XMin, XMax, YMin, YMax: TFloat); // Toa do gia tri that
  procedure SetLogicalMinMax(XMin, XMax, YMin, YMax: TFloat); // Toa do gia tri that

  property ScaleX: TFloat read FScaleX write FScaleX;
  property ScaleY: TFloat read FScaleY write FScaleY;
  property DX: integer read FDX write FDX;
  property DY: integer read FDY write FDY;
  property XMin: integer read FXMin; // device coord
  property YMin: integer read FYMin; // device coord
end;

function GetColor(i:integer): TColor;

implementation {--------------------------------------------------------------}

uses SysUtils;

{ TGrid }

constructor TGrid.Create(DX, DY: TFloat);
begin
  inherited Create;
  FDX:= round(DX);
  FDY:= round(DY);
  FXMin := -500;
  FXMax := 500;
  FYMin := -500;
  FYMax := 500;
  FColor := clBlue;
  FOrg.X:= 0;
  FOrg.Y:= 0;
  FScaleX:= 50;
  FScaleY:= 50;
end;

procedure TGrid.Draw(DC: hDC; HorzScrollPos, VertScrollPos: integer);
var
  Pen, Pen0, OldPen: hPen;
  P: array[0..1] of TPoint;
  X, Y: integer;

begin
  Pen:= CreatePen(PS_DOT,0, FColor);
  Pen0:= CreatePen(PS_SOLID, 0, FColor);

  OldPen:= SelectObject(DC, Pen);

  X:= FXMin;
  while X <= FXMax do begin
    P[0]:= Point(X, FYMin);
    P[1]:= Point(X, FYMax);
    if X = FOrg.X then begin
      SelectObject(DC, Pen0);
      Polyline(DC, P, 2);
      SelectObject(DC, Pen);
    end else
      Polyline(DC, P, 2);
    Inc(X, FDX);
  end;

  Y:= FYMin;
  while Y <= FYMax do begin
    P[0]:= Point(FXMin, Y);
    P[1]:= Point(FXMax, Y);
    if Y = FOrg.Y then begin
      SelectObject(DC, Pen0);
      Polyline(DC, P, 2);
      SelectObject(DC, Pen);
    end else
      Polyline(DC, P, 2);

    Inc(Y, FDY);
  end;

  SelectObject(DC, OldPen);
  DeleteObject(Pen);
  DeleteObject(Pen0);
end;

procedure TGrid.DrawTickX(DC: hDC; ScrollPos: integer);
var
  X: integer;
  P: array[0..1] of TPoint;
var
  aFont, StockFont, aNewFont: HFont;
  LF: TLogFont;
  S: string;
begin
  StockFont:= GetStockObject(ANSI_VAR_FONT);
  aFont:= SelectObject(DC, StockFont);
  GetObject(aFont, SizeOf(LF), @LF);
  LF.lfEscapement:= 900;

  aNewFont:= CreateFontIndirect(LF);
  SelectObject(DC, aNewFont);

  X:= FXMin;

  while X <= FXMax do begin
    P[0]:= Point(X-ScrollPos, 0);
    P[1]:= Point(X-ScrollPos, 10);
    Polyline(DC, P, 2);
    S:= Format('%5.3g',[(X-FOrg.X)/FScaleX]);
    TextOut(DC, X-ScrollPos-6, 38, PChar(S), Length(S));
    Inc(X, FDX);
  end;

  SelectObject(DC, aFont);
  DeleteObject(aNewFont);
end;

procedure TGrid.DrawTickY(DC: hDC; ScrollPos: integer);
var
  Y: integer;
  P: array[0..1] of TPoint;
  S: string;
begin
  Y:= FYMin;
  while Y <= FYMax do begin
    P[0]:= Point(0, Y-ScrollPos);
    P[1]:= Point(10, Y-ScrollPos);
    Polyline(DC, P, 2);
    S:= Format('%5.3g',[-(Y-FOrg.Y)/FScaleY]);
    TextOut(DC,12, Y-ScrollPos-6 , PChar(S), Length(S));
    Inc(Y, FDY);
  end;
end;

procedure TGrid.MakeVisible;
begin
  MoveXY(-FXmin, -FYMin);
end;

procedure TGrid.MoveXY(const X, Y: TFloat);
begin
  FXMin:= FXMin + round(X);
  FXMax:= FXMax + round(X);
  FYMin:= FYMin + round(Y);
  FYMax:= FYMax + round(Y);
  FOrg.X:= FOrg.X + round(X);
  FOrg.Y:= FOrg.Y + round(Y);
end;

function TGrid.XRange: integer;
begin
  result:= FXmax - FXMin;
end;

function TGrid.YRange: integer;
begin
  result:= FYmax - FYMin;
end;

procedure TGrid.GetLogicalMinMax(var XMin, XMax, YMin, YMax: TFloat);
begin
  XMin:= (FXMin-FOrg.X)/FScaleX;
  XMax:= (FXMax-FOrg.X)/FScaleX;
  YMin:= (FYMin-FOrg.Y)/FScaleY;
  YMax:= (FYMax-FOrg.Y)/FScaleY;
end;

function nDiff(X, DX: integer): integer;
var s: integer;
begin
  if X > 0 then s :=1
  else s := -1;
  X:= abs(X);

  if X mod DX = 0 then begin
 //    X:= X
  end else begin
    X:= ((X + dx div 2) div DX)*DX;
  end;
  result:= X*s;
end;

function nMin(X, ScaleX: TFloat; DX: integer): Integer;
var
  Step: TFloat;
  C: TFloat;
begin
  Step:= DX/ScaleX;
  C:= X/Step;
  if abs(round(x)-x) > 0.01 then begin
    C:= C -0.5;
  end;

  Result:= round(C)*DX;
end;

function nMax(X, ScaleX: TFloat; DX: integer): Integer;
var
  Step: TFloat;
  C: TFloat;
begin
  Step:= DX/ScaleX;
  C:= X/Step;
  if abs(round(x)-x) > 0.01 then begin
    C:= C + 0.5;
  end;

  Result:= round(C)*DX;
end;


procedure TGrid.SetLogicalMinMax(XMin, XMax, YMin, YMax: TFloat); // Toa do gia tri that
var tmp: Integer;
begin
  FXmin:= nMin(XMin, FScaleX, FDX)+ FOrg.X;
  FXmax:= nMax(XMax, FScaleX, FDX)+ FOrg.X;

  FYmax:= -nMin(YMin,FScaleY, FDY)+ FOrg.Y;
  FYmin:= -nMax(YMax,FScaleY, FDY)+ FOrg.Y;
  if FYmin > FYMax then begin
    tmp:= FYMin;
    FYMin:= FYMax;
    FYMax:= tmp;
  end;
end;

{============================================================================}
{                                  FFuncResult                               }
{============================================================================}

constructor TFuncResult.Create(aGrid: TGrid);
var i: Integer;
begin
  inherited Create;
  FGrid:= aGrid;
  FCount:= 500;
  FillXArr;
  for i:= 0 to FCount -1 do begin
    FYArr[i]:= sqr(FXArr[i]);
  end;
  UpdateIntPoints;
end;

procedure TFuncResult.FillXArr;
// Dien gia tri vao mang FXArr dua vao FGrid
var
  i: Integer;
  aDX: TFloat;
begin
  aDX:= (FGrid.FXMax-FGrid.FXMin)/(FGrid.FScaleX*FCount);
  for i:= 0 to FCount-1 do begin
    FXArr[i]:= (FGrid.FXMin-FGrid.FOrg.X)/FGrid.FScaleX + i*aDX;
  end;
end;

procedure TFuncResult.Draw(DC: hDC);
begin
  Windows.Polyline(DC, FXY, FCount);
end;

procedure TFuncResult.GetYMinMax(var Ymin, YMax: TFloat);
var i: Integer;
begin
  YMin:= FYArr[0];
  YMax:= FYArr[0];
  for i := 1 to FCount - 1 do begin
    if FYArr[i] < YMin then YMin:= FYArr[i];
    if FYArr[i] > YMax then YMax:= FYArr[i];
  end;
end;

procedure TFuncResult.UpdateIntPoints;
var i: Integer;
begin
  for i:=0 to FCount -1 do begin
    FXY[i].x := round(FXArr[i]*FGrid.FScaleX + FGrid.FOrg.X);
    FXY[i].y := round(-FYArr[i]*FGrid.FScaleY + FGrid.FOrg.Y);
  end;
end;

{============================================================================}
{                                  TFuncResultList                          }
{============================================================================}

constructor TFuncResultList.Create(aGrid: TGrid; NodeStack: TNodeStack; aCPU: TVirtualCPU);
begin
  inherited Create;
  FGrid:= aGrid;
  FNodeStack:= NodeStack;
  FCPU:= aCPU;
end;

procedure TFuncResultList.FreeItems;
var i: Integer;
begin
  for i := 0 to Count - 1 do begin
    TObject(Items[i]).Free;
  end;
  Clear;
end;

procedure TFuncResultList.UpdateFuncResults;
var
  AdrX: Integer;
  NewCPU: TVirtualCPU;

  i: Integer;
  N: TNode;
  F: TFuncResult;
begin

  AdrX:= 3;
  FreeItems; // Xoa bo tat ca cac ket qua roi cap nhat lai
  NewCPU:= TVirtualCPU.Create;
  try
    for i := 0 to FNodeStack.Count - 1 do begin
      N:= FNodeStack[i];
      if not N.ValidCodeForDrawGraph then Continue;

      FCPU.PrepareExpressionCode(N.CXFrom, N.CXTo, NewCPU);

      F:= TFuncResult.Create(FGrid);
      if NewCPU.CoBienYBenTrai(4) then
        NewCPU.GetYArray(AdrX, 4, F.FXArr, F.FYArr, F.FCount);
      F.UpdateIntPoints;
      Add(F);

    end;
  finally
    NewCPU.Free;
  end;
  UpdateIntPoints;
end;

procedure TFuncResultList.GetYMinMax(var Ymin, YMax: TFloat);
var
  i: Integer;
  F: TFuncResult;
  aMin, aMax: TFloat;
begin
  if Count = 0 then
    raise Exception.Create('GetYMinMax: Khong co ham nao Count=0');
  F:= Items[0];
  F.GetYMinMax(Ymin, YMax);
  for i := 1 to Count - 1 do begin
    F:= Items[i];
    F.GetYMinMax(aMin, aMax);
    if aMin < Ymin then Ymin:= aMin;
    if aMax > Ymax then Ymax:= aMax;
  end;
end;

procedure TFuncResultList.UpDateTables(S: TStringGrid);
var
  F: TFuncResult;
  i, j: integer;
begin
  S.ColCount := 2 + Count;
  S.Cells[0,0]:='NN';
  S.Cells[1,0]:='X';

  if Count = 0 then exit;
  F:= Items[0];
  S.RowCount := F.FCount+2;
  for i:= 0 to Count-1 do begin
    S.Cells[i+2,0]:='Exp ??'
  end;

  for i:= 0 to F.FCount-1 do begin
    S.Cells[0,i+2]:= IntToStr(i);
    S.Cells[1,i+2]:= format('%5.3f', [F.FXArr[i]]);
  end;

  for j:= 0 to Count -1 do begin
    F:= Items[j];
    for i:= 0 to F.FCount-1 do begin
      S.Cells[2+j,i+2]:= format('%5.3f', [F.FYArr[i]]);
    end;
  end;
end;

procedure TFuncResultList.MoveXY(DX, DY: integer);
begin
  FGrid.MoveXY(DX, DY);
  UpdateIntPoints;
end;

function GetColor(i:integer): TColor;
const
  clCount = 17;
  Colors: array[0..clCount-1] of TColor=(
  clBlack,
  clMaroon,
  clGreen,
  clOlive,
  clNavy,
  clPurple,
  clTeal,
  clGray,
//  clSilver, mau nen
  clRed,
  clLime,
  clYellow,
  clBlue,
  clFuchsia,
  clAqua,
  clLtGray,
  clDkGray,
  clWhite
);
begin
  i:= i mod clCount;
  Result:= Colors[i];
end;

procedure TFuncResultList.Draw(DC: hDC);
var
  i: Integer;
  F: TFuncResult;
  aPen,
  OldPen: hPen;
begin
  for i := 0 to Count - 1 do begin
    aPen:= CreatePen(PS_SOLID, 2, GetColor(i));
    OldPen:= SelectObject(DC, aPen);
    F:= Items[i];
    F.Draw(DC);
    DeleteObject(SelectObject(DC, OldPen));
  end;
end;

procedure TFuncResultList.UpdateIntPoints;
var
  i: Integer;
  F: TFuncResult;
begin
  for i := 0 to Count - 1 do begin
    F:= Items[i];
    F.UpdateIntPoints;
  end;
end;

function TFuncResultList.GetFuncResult(i: Integer): TFuncResult;
begin
  Result:= Items[i];
end;

end.
