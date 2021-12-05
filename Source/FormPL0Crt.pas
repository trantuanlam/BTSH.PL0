{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                     }
{-------------------------------------------------------}
{       Unit FormPL0Crt                                 }
{       Form chinh cua chuong trinh                     }
{*******************************************************}

unit FormPL0Crt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ToolWin, Menus, DrawFunc, ParseTree, Grids,
  ShellAPI,
  PL0Paser, Interpreter, ActnList, ImgList, StdActns, RichEdit,
  Printers, HamDungSan;

type
  TEZoomAction = (actZoomNone, actZoomIn, actZoomOut);
  TFormChinh = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    edCRT: TMemo;
    TabSheet4: TTabSheet;
    StatusBar1: TStatusBar;
    CoolBar1: TCoolBar;
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    PaintBoxX: TPaintBox;
    PaintBoxY: TPaintBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Run1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ScrollBox1: TScrollBox;
    PaintBoxXY: TPaintBox;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Run2: TMenuItem;
    Compile1: TMenuItem;
    ShowTable1: TMenuItem;
    TabSheet5: TTabSheet;
    StringGridFuncResult: TStringGrid;
    Gioithieu1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    ListCode1: TMenuItem;
    ActionListRun: TActionList;
    ActionCompile: TAction;
    ActionGraphic: TAction;
    ActionFillTable: TAction;
    ImageListFile: TImageList;
    ImageListEdit: TImageList;
    Paste1: TMenuItem;
    ActionListEdit: TActionList;
    EditCut: TAction;
    EditCopy: TAction;
    EditPaste: TAction;
    EditDelete: TEditDelete;
    EditSelectAll: TEditSelectAll;
    EditUndo: TEditUndo;
    Undo1: TMenuItem;
    N4: TMenuItem;
    Selectall: TMenuItem;
    Goroi1: TMenuItem;
    N5: TMenuItem;
    Vedothi1: TMenuItem;
    Dienbangketqua1: TMenuItem;
    PhongtoZoomIn1: TMenuItem;
    ThunhoZoomOut1: TMenuItem;
    ActionRun: TAction;
    ActionZoomIn: TAction;
    ActionZoomOut: TAction;
    ActionViewCode: TAction;
    Delete1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton4: TToolButton;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton8: TToolButton;
    ToolBarEdit: TToolBar;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ActionListFile: TActionList;
    FileNew: TAction;
    FileOpen: TAction;
    FileSave: TAction;
    FileSaveAs: TAction;
    mnEdit: TMenuItem;
    ToolButton7: TToolButton;
    edPL0Source: TRichEdit;
    cbXFrom: TComboBox;
    cbXTo: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    ImageListOrg: TImageList;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton15: TToolButton;
    btnShowHideXminXmax: TToolButton;
    ActionShowHideXminXmax: TAction;
    PanelXminXMax: TPanel;
    cbY1: TComboBox;
    cbY2: TComboBox;
    CheckBoxAutoCalcY: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    Panel1_Bottom: TPanel;
    Panel5_GiaiPT: TPanel;
    GroupBox1: TGroupBox;
    X: TLabel;
    lbNghiemPT: TLabel;
    Label6: TLabel;
    cbA: TComboBox;
    cbB: TComboBox;
    cbZero: TComboBox;
    cbSoBuoc: TComboBox;
    CheckBoxScanNghiem: TCheckBox;
    btnGiaiPT: TButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    lbGiatriHam: TLabel;
    cbX: TComboBox;
    BtnTinhGiaTriHam: TButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    FontDialog1: TFontDialog;
    PopupMenu1: TPopupMenu;
    Setfont1: TMenuItem;
    FilePrint: TAction;
    IndothiPrint1: TMenuItem;
    FilePrinterSetup: TAction;
    PrinterSetupDialog1: TPrinterSetupDialog;
    N6: TMenuItem;
    PrinterSetup1: TMenuItem;
    PanelListBox: TPanel;
    ListBox1: TListBox;
    Label7: TLabel;
    ScrollBox2: TScrollBox;
    PaintBox2: TPaintBox;
    ActionThuNhoY: TAction;
    ActionPhongToY: TAction;
    ToolButton16: TToolButton;
    PhongToY1: TMenuItem;
    THuNhoY1: TMenuItem;
    TabSheet6: TTabSheet;
    PanelFormulaDirect: TPanel;
    edFormulaDirect: TEdit;
    Label8: TLabel;
    lbFormulaDirectStatus: TLabel;
    PaintBoxFormulaDirect: TPaintBox;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure CompileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShowGraphicClick(Sender: TObject);
    procedure BtnOpenFileClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxXPaint(Sender: TObject);
    procedure PaintBoxXYPaint(Sender: TObject);
    procedure PaintBoxYPaint(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure PaintBoxXYMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxXYMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxXYMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure UpDateFuncTableClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Gioithieu1Click(Sender: TObject);
    procedure RunClick(Sender: TObject);
    procedure edPL0SourceChange(Sender: TObject);
    procedure btnGiaiPTClick(Sender: TObject);
    procedure BtnTinhGiaTriHamClick(Sender: TObject);
    procedure PaintBox2Paint(Sender: TObject);
    procedure ShowTable1Click(Sender: TObject);
    procedure FileNewClick(Sender: TObject);
    procedure ActionListRunUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure EditCutClick(Sender: TObject);
    procedure EditCopyClick(Sender: TObject);
    procedure EditPasteClick(Sender: TObject);
    procedure EditSelectallClick(Sender: TObject);
    procedure EditDeleteClick(Sender: TObject);
    procedure EditUndoExecute(Sender: TObject);
    procedure ActionListEditUpdate(Action: TBasicAction;
      var Handled: Boolean);
    procedure ActionZoomInExecute(Sender: TObject);
    procedure ActionZoomOutExecute(Sender: TObject);
    procedure ActionShowHideXminXmaxExecute(Sender: TObject);
    procedure Setfont1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FilePrintExecute(Sender: TObject);
    procedure FilePrinterSetupExecute(Sender: TObject);
    procedure ActionViewCodeExecute(Sender: TObject);
    procedure StringGridFuncResultDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure ActionThuNhoYExecute(Sender: TObject);
    procedure ActionPhongToYExecute(Sender: TObject);
    procedure edFormulaDirectChange(Sender: TObject);
    procedure PaintBoxFormulaDirectPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure SaveSoureFile;
  private
    { Private declarations }
    FSourcePL0FileName: string;
    FNewSourceFile: Boolean;
    FCompiler: TCompiler;
    NodeStack: TNodeStack; // Reference to FCompiler.NodeStack
    FCodeValid: Boolean;
    procedure OpenOutPut;
    procedure CloseOutPut;
    procedure ShowMsg(s: string);
    procedure DrawFormula(PaintBox: TPaintBox;Root: TNode);
    procedure SetCaption(s: string);
    procedure InvalidatePaintBoxes;
    function  CreateCPUForSelectedNode: TVirtualCPU;
    function Editor: TCustomEdit;
  private
    FGrid : TGrid;
    FFuncResult: TFuncResultList;
    FMouseDown: boolean;
    FMousePt: TPoint;
    FZoomAction: TEZoomAction;
    procedure ZoomY(ZoomIn: boolean);
    procedure VeDoThi(Canvas: TCanvas);
    procedure UpDateGraph;
    function FloatValue(cb: TComboBox): Double;
    function IntValue(cb: TComboBox): Integer;
    function CanCloseSource: Boolean;
  public
    { Public declarations }
  end;

var
  FormChinh: TFormChinh;

implementation

uses
  MemoProcs, TuVung, GlobalTypes, BTSHAbout,UnitTestTree
  ;
{$R *.DFM}

const
  fnCRT = 'CrtOut.$$$';
  fnNewFile ='BieuThucMoi.Pl0';

procedure TFormChinh.OpenOutPut;
begin
  AssignFile(OutPut, fnCRT);
  ReWrite(OutPut);
end;

procedure TFormChinh.CloseOutPut;
begin
  CloseFile(OutPut);
  edCRT.Lines.LoadFromFile(fnCRT);
end;

function TFormChinh.Editor: TCustomEdit;
begin
  if PageControl1.ActivePageIndex = 0 then
    Result:= edCRT
  else if PageControl1.ActivePageIndex = 1 then
    Result:= edPL0Source
  else
    Result:= nil;
//  raise Exception.Create('Unexpected: No editor in active.');
end;

procedure TFormChinh.Button2Click(Sender: TObject);
var
  Root: TNode;
begin
  OpenOutput;
  try
    Root:= CreatTestNode3;
    Root.UpDateNeedPar;
    Root.UpdateRect(Canvas.Handle);
    Root.MoveTo00;
    Root.Duyet;
    Root.Draw(Canvas.Handle);
    Root.Free;
  finally
    CloseOutput;
  end;
end;

  procedure locDrawRect(DC: hDC; const R: TRect);
  var P: array[0..4] of TPoint;
  begin
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
procedure TFormChinh.CompileClick(Sender: TObject);
var
  B: array[0..50000] of char;
  S: string;
  i: Integer;
  Node: TNode;
const
  cMsg= 'PL/0 Compiler (Compile text in editor)';
begin
  SendMessage(edPL0Source.Handle, WM_GETTEXT, 50000, Integer(@B));
  S:= B;
  OpenOutput;
  try
    Writeln(cMsg);
    ShowMsg(cMsg);
    ListBox1.Clear;
    FCompiler.ParseBuf(S);

    if (NodeStack.Count > 0) and (not NodeStack.HasError) then begin
      for i:= 0 to NodeStack.Count-1 do begin
         Node:= NodeStack.Items[i];
         ListBox1.Items.Add(format('Exp %d : CX:%d-%d', [i, Node.CXFrom, Node.CXTo-1]));
      end;
    end;
    PaintboxXY.Invalidate;
    FCodeValid := True;
  finally
    if FCompiler.HasError then begin
       PageControl1.ActivePage:= TabSheet2;

       edPL0Source.SelStart:= FCompiler.ErrorPos;
       edPL0Source.SelLength:= 0;
       edPL0Source.SetFocus;
       ShowMsg(FCompiler.LastErrorString);

       MakeLineFirstVisible(edPL0Source, FCompiler.ErrorPos);
    end else begin
       ShowMsg('Bien dich thanh cong');
    end;
    CloseOutput;
  end;
end;

procedure TFormChinh.FormCreate(Sender: TObject);
var XMin, XMax, YMin, YMax: TFloat;
begin
  FCompiler:= TCompiler.Create;
  NodeStack:= FCompiler.NodeStack;
  FGrid:= TGrid.Create(50, 50);
  FGrid.MoveXY(300, 300);
  FFuncResult:= TFuncResultList.Create(FGrid, NodeStack, FCompiler.CPU);
  FGrid.GetLogicalMinMax(XMin, XMax, YMin, YMax);
  cbXFrom.Text := Format('%g', [XMin]);
  cbXTo.Text := Format('%g', [XMax]);
  PageControl1Change(nil);

  FSourcePL0FileName:='BTSH.PL0';
  edPL0Source.Lines.LoadFromFile(FSourcePL0FileName);
  edPL0Source.Modified := False;

  SetCaption(FSourcePL0FileName);
  lbFormulaDirectStatus.Caption:='';
end;

procedure TFormChinh.ShowGraphicClick(Sender: TObject);
begin
  OpenOutput;
  try
    NodeStack.UpDateValidCodeForDrawGraph(FCompiler.CPU);
    UpDateGraph;
    PaintBoxXY.Invalidate;
    PageControl1.ActivePageIndex := 3;
  finally
    CloseOutput;
  end;
end;

procedure TFormChinh.DrawFormula(PaintBox: TPaintBox; Root: TNode);
var aDC: hDC;
begin
  if Root <> nil then begin
    with PaintBox do begin
      aDC:= Canvas.Handle;
      Canvas.Pen.Color := Canvas.Font.Color;
      SendMessage(handle, WM_ERASEBKGND, aDC, 0);
      Root.UpDateNeedPar;
      SetCharHW(aDC);
      Root.UpdateRect(aDC);
      Root.MoveTo00;
      Root.Move(10, 10);
      Root.Draw(aDC);
    end;
  end;
end;

procedure TFormChinh.BtnOpenFileClick(Sender: TObject);
begin
  if not CanCloseSource then exit;
  if OpenDialog1.Execute then begin
    FSourcePL0FileName:= OpenDialog1.FileName;
    edPL0Source.Lines.LoadFromFile(FSourcePL0FileName);
    edPL0Source.Modified := false;
    FNewSourceFile:= False;
    SetCaption(FSourcePL0FileName);
    PageControl1.ActivePageIndex :=1;
  end;
end;

procedure TFormChinh.SaveSoureFile;
var st: TStringList;
begin
  if FileExists(FSourcePL0FileName) then
    RenameFile(FSourcePL0FileName, ChangeFileExt(FSourcePL0FileName, '.BAK'));
  st:= TStringList.Create;
  st.Assign(edPL0Source.Lines);
  st.SaveToFile(FSourcePL0FileName);
  st.Free;
  edPL0Source.Modified := False;
  FNewSourceFile:= False;
end;

procedure TFormChinh.BtnSaveClick(Sender: TObject);
begin
  if FNewSourceFile then begin
    SaveAs1Click(nil);
  end else begin
    SaveSoureFile;
  end;
  ShowMsg('File da luu xong');
end;

procedure TFormChinh.ShowMsg(s: string);
var aPanel: TStatusPanel;
begin
  aPanel:= StatusBar1.Panels[1];
  aPanel.Text:= S;
end;

procedure TFormChinh.About1Click(Sender: TObject);
var D:TAboutBox;
begin
  D:= TAboutBox.Create(Self);
  D.ShowModal;
  D.Free;
end;

procedure TFormChinh.FormDestroy(Sender: TObject);
begin
  FGrid.Free;
  FCompiler.Free;
end;

procedure TFormChinh.PaintBoxXPaint(Sender: TObject);
var DC: hDC;
begin
  DC:= PaintBoxX.Canvas.Handle;
  FGrid.DrawTickX(DC, ScrollBox1.HorzScrollBar.Position);
end;

procedure TFormChinh.PaintBoxXYPaint(Sender: TObject);
var
  DC: hDC;
  Node: TNode;
  i, j, DY: Integer;
  P: array[0..1] of TPoint;
begin
  PaintBoxXY.Canvas.Pen.Width:= 2;
  DY:=10;
  j:= 0;  // Dong bo Color
  if (NodeStack <> nil) and (NodeStack.Count > 0) then begin
    for i:= 0 to NodeStack.Count - 1 do begin
      Node:= NodeStack[i];
      if not Node.ValidCodeForDrawGraph then Continue;

      PaintBoxXY.Canvas.Pen.Color:= DrawFunc.GetColor(j);
      DC:= PaintBoxXY.Canvas.Handle;
      Node.UpDateNeedPar;
      SetCharHW(DC);
      Node.UpdateRect(DC);
      Node.MoveTo00;
      Node.Move(50, DY);
      P[0].X:=5;
      P[1].X:=25;
      P[0].Y:= (Node.FormulaRect.Top+Node.FormulaRect.Bottom) div 2 ;
      P[1].Y:= P[0].Y;
      windows.Polyline(DC, P, 2);

      Node.Draw(DC);
      DY:= DY + Node.Height + 5;
      inc(j);
    end;
  end;

  with PaintBoxXY.Canvas do begin
    Pen.Color:= clBlue;
    Pen.Style:= psDot;

    DC:= PaintBoxXY.Canvas.Handle;

    with ScrollBox1 do
      FGrid.Draw(DC, HorzScrollBar.Position, VertScrollBar.Position);

    Pen.Color:= clRed;
    Pen.Width:= 2;
    DC:= PaintBoxXY.Canvas.Handle;
    FFuncResult.Draw(DC);
    Pen.Width:= 1;
  end;

  PaintBoxX.Invalidate;
  PaintBoxY.Invalidate;

end;

procedure TFormChinh.PaintBoxYPaint(Sender: TObject);
var DC: hDC;
begin
  DC:= PaintBoxY.Canvas.Handle;
  FGrid.DrawTickY(DC, ScrollBox1.VertScrollBar.Position);
end;

procedure TFormChinh.Exit1Click(Sender: TObject);
begin
  Close
end;

procedure TFormChinh.SaveAs1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then begin
    FSourcePL0FileName:=SaveDialog1.FileName;
    SaveSoureFile;
    SetCaption(FSourcePL0FileName);
  end
end;

procedure TFormChinh.ListBox1Click(Sender: TObject);
begin
  PaintBox2.Invalidate;
end;

procedure TFormChinh.InvalidatePaintBoxes;
begin
  PaintBoxXY.Invalidate;
  PaintBoxX.Invalidate;
  PaintBoxY.Invalidate;
end;

procedure TFormChinh.PaintBoxXYMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

function locIsZoom: Boolean;
begin
  Result:= btnZoomIn.Down or btnZoomOut.Down;
end;

procedure locZoom;
var S: TFloat;
begin
  if btnZoomIn.Down then
    S:= 2
  else if btnZoomOut.Down then
    S:= 1/2
  else
    S:= 1;

  FGrid.ScaleX := S *  FGrid.ScaleX;
  FGrid.ScaleY := S *  FGrid.ScaleY;
  if not (ssShift in Shift) then begin
    FZoomAction:= actZoomNone;
  end;
  UpDateGraph;
  InvalidatePaintBoxes;
end;

begin
  if locIsZoom then
    locZoom
  else begin
    FMouseDown:= true;
    FMousePt.x := x;
    FMousePt.y := y;
  end;
end;

procedure TFormChinh.PaintBoxXYMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown:= false;
  FMousePt.x := x;
  FMousePt.y := y;
end;

procedure TFormChinh.PaintBoxXYMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var Dx, Dy: integer;
begin
  if FMouseDown then begin
    Dx:= X - FMousePt.x;
    Dy:= y - FMousePt.y;
    FFuncResult.MoveXY(Dx, Dy);
    PaintBoxXY.Invalidate;
//    GridChanged(FGridHorz);
    FMousePt.x := x;
    FMousePt.y := y;
  end;
end;

procedure TFormChinh.UpDateFuncTableClick(Sender: TObject);
  procedure locUpdateExpNumber;
  var  i, j: integer;
  begin
    with StringGridFuncResult do begin
      for i:= 0 to FFuncResult.Count-1 do begin
         if NodeStack.GetValidItemIndex(i, j) then begin
            Cells[i+2,0]:='Exp '+IntToStr(j);
         end;
      end;
    end;
  end;
begin
  OpenOutput;
  try
    NodeStack.UpDateValidCodeForDrawGraph(FCompiler.CPU);
    UpDateGraph;

    FFuncResult.UpDateTables(StringGridFuncResult);
    locUpdateExpNumber;
    StringGridFuncResult.Invalidate;
    PageControl1.ActivePageIndex := 4;
  finally
    CloseOutput;
  end;
end;

procedure TFormChinh.SetCaption(s: string);
begin
  caption:= format('Phan tich BTSH: "%s"',[s]);
end;

procedure TFormChinh.PageControl1Change(Sender: TObject);
begin
  if (PageControl1.ActivePage = TabSheet2) or
     (PageControl1.ActivePage = TabSheet1) then
    mnEdit.Visible := true
  else
    mnEdit.Visible := false;
end;

procedure TFormChinh.Gioithieu1Click(Sender: TObject);
begin
   ShellExecute(
    Handle,
    'open',
    'GIOITHIEU.DOC',
    nil, nil,
    SW_SHOWNORMAL
   );

end;

procedure TFormChinh.RunClick(Sender: TObject);
begin
  OpenOutput;
  try
    FCompiler.CPU.Interpret;
    PageControl1.ActivePageIndex := 0;
  finally
    CloseOutput;
  end;
end;

procedure TFormChinh.edPL0SourceChange(Sender: TObject);
begin
  FCodeValid:= False;
end;

function TFormChinh.CreateCPUForSelectedNode: TVirtualCPU;
var
  Node: TNode;
  N: Integer;
begin
  Result:= nil;
  if (NodeStack <> nil) and (NodeStack.Count > 0) then begin
    N:= ListBox1.ItemIndex;
    if N < 0 then begin
      ShowMsg('Chua chon cong thuc nao.');
      Application.MessageBox('Chua chon cong thuc nao.','BTSH' , MB_OK);
      exit;
    end else begin
      Node:= NodeStack.Items[N];
      if Node.CXFrom*Node.CXTo > 0 then begin
        Result:= TVirtualCPU.Create;
        with Node do
          FCompiler.CPU.PrepareExpressionCode(CXFrom, CXTo, Result);
      end else begin
        ShowMsg('Khong co ma may nao duoc sinh ra cho bieu thuc nay');
        Application.MessageBox('Khong co ma may nao duoc sinh ra cho bieu thuc nay','BTSH' , MB_OK);
      end;
    end;
  end else begin
    ShowMsg('Khong co cong thuc nao.');
    Application.MessageBox('Khong co cong thuc nao.','BTSH' , MB_OK);
  end;

end;

function gStr(F: TFloat; Dec: Integer ): string;
{ Viet F duoi dang ngan de doc.
  Vi du voi Dec = 3
     f= 0.426978523 -> 0.43 (426978523)
     f= 0.42 -> 0.42
}
var s, s1, s2: string;
begin
  S:='%1'+'.'+IntToStr(Dec)+'g';
  s1:= format(s, [f]);
  s2:= format('%g', [f]);
  if s1 <> s2 then
    Result:= s1+' ('+s2+')'
  else
    Result:= s1;
end;

function locCheckCode( NewCPU: TVirtualCPU; var adrX: integer): boolean;
begin
  AdrX:= 3;
  Result:= True;
  if NewCPU.CoCacBienKhac(3, 4) then begin
    Writeln('Bieu thuc chua cac bien khac X, Y');
    Result:= False;
  end;
  if not NewCPU.CoBienYBenTrai(4) then begin
    Writeln('Bieu thuc khong chua Y ben trai');
    Result:= False;
  end;
  if not NewCPU.CoBienXBenPhai(3) then begin
    AdrX:= StackSize -1;
  end;
end;

procedure TFormChinh.btnGiaiPTClick(Sender: TObject);

var
  NewCPU: TVirtualCPU;
  AdrX: Integer;
  function locCheckCode: boolean;
  begin
    AdrX:= 3;
    Result:= True;
    if NewCPU.CoCacBienKhac(AdrX, 4) then begin
      Writeln('Co loi: Bieu thuc chua cac bien khac X, Y.');
      Result:= False;
    end;
    if not NewCPU.CoBienYBenTrai(4) then begin
      Writeln('Co loi: Bieu thuc khong chua Y ben trai.');
      Result:= False;
    end;
    if not NewCPU.CoBienXBenPhai(AdrX) then begin
      Writeln('Co loi: Bieu thuc khong chua X ben phai.');
      Result:= False;
    end;
    if NewCPU.CoBienXBenPhai(4) then begin
      Writeln('Co loi: Bieu thuc co chua Y ben phai.');
      Result:= False;
    end;
  end;

var
  N: integer;
  X: TFloat;
  a, a1, b, b1, zero, Step: TFloat;
  s: string;
  SoNghiem: Integer;
  SoBuoc: integer;
begin
  lbNghiemPT.Caption := '';
  a:= FloatValue(cbA);
  b:= FloatValue(cbB);
  zero:= FloatValue(cbZero);
  NewCPU:= CreateCPUForSelectedNode;
  if NewCPU = nil then exit;

  OpenOutput;
  lbNghiemPT.Caption := 'Dang giai phuong trinh';
  try
    if locCheckCode then begin
      N:= NewCPU.GiaiPhuongTrinh(AdrX,4, a, b,Zero, X) ;
      if not CheckBoxScanNghiem.Checked then begin
        Writeln('========Giai phuong trinh======');
        Writeln(Format('Tim nghiem trong khoang [%g, %g] voi sai so %g (sai so cua Y)',[a,b, Zero]));
        if N > 0 then begin
          S:= format('Nghiem cua phuong trinh: %s', [gStr(x,4)]);
          lbNghiemPT.Font.Color := clBlue;
          lbNghiemPT.Caption := S;
        end else begin
          S:= 'Vo ngiem';
          lbNghiemPT.Font.Color := clRed;
          lbNghiemPT.Caption := S;
        end;
        Writeln(S);
      end else begin
        SoBuoc:= IntValue(cbSoBuoc);
        Step:= (b-a)/SoBuoc;
        Writeln('========Scan Nghiem cua phuong trinh ======');
        Writeln(Format('Tim cac nghiem trong khoang [%g, %g] voi sai so %g (sai so cua Y)',[a,b, Zero]));
        Writeln(Format('bang cach chia khoang tren thanh %d doan de tim nghiem (buoc=%g).',[SoBuoc, Step]));
        SoNghiem:= 0;
        a1:= a;
        b1:= a1+Step;
        while b1 < b do begin
          N:= NewCPU.GiaiPhuongTrinh(AdrX,4, a1, b1,Zero, X) ;
          if N > 0 then begin
            Inc(SoNghiem);
            S:= format('Nghiem so %d : x=%s,  y=%g', [SoNghiem, gStr(x, 4), NewCPU.GiaTriHam(3,4, X)]);
            Writeln(S);
            a1:= X+Step/2;
            b1:= a1+Step;
          end else begin
            b1:= b1+Step;
          end;
        end;
        S:= format('Tim duoc %d nghiem trong khoan [%g, %g]', [SoNghiem, a, b]);
        lbNghiemPT.Font.Color := clBlue;
        lbNghiemPT.Caption := S;
        ShowMsg(S);
      end;
    end else begin
      lbNghiemPT.Caption := 'Khong giai duoc phuong trinh do co loi. Xem CRT.';
      Application.MessageBox('Khong giai duoc phuong trinh do co loi. Xem CRT.','BTSH' , MB_OK);
    end;
  finally
    NewCPU.Free;
    CloseOutput;
  end;
end;


procedure TFormChinh.BtnTinhGiaTriHamClick(Sender: TObject);
var
  NewCPU: TVirtualCPU;
  adrX: integer;

  function locCheckCode: boolean;
  begin
    AdrX:= 3;
    Result:= True;
    if NewCPU.CoCacBienKhac(AdrX, 4) then begin
      Writeln('Co loi: Bieu thuc chua cac bien khac X, Y.');
      Result:= False;
    end;
    if not NewCPU.CoBienYBenTrai(4) then begin
      Writeln('Co loi: Bieu thuc khong chua Y ben trai.');
      Result:= False;
    end;
    if not NewCPU.CoBienXBenPhai(AdrX) then begin
      Writeln('Co loi: Bieu thuc khong chua X ben phai.');
      Result:= False;
    end;
    if NewCPU.CoBienXBenPhai(4) then begin
      Writeln('Co loi: Bieu thuc co chua Y ben phai.');
      Result:= False;
    end;
  end;

var
  x, y: TFloat;
begin
  lbGiatriHam.Caption := '';
  x:= FloatValue(cbX);
  NewCPU:= CreateCPUForSelectedNode;
  if NewCPU = nil then exit;

  OpenOutput;
  try
    if locCheckCode then begin
      y:= NewCPU.GiaTriHam(AdrX,4, X); // Khi X khong co trong bieu thuc gia tri cua no se khong duoc su dung
      Writeln('=========Tinh Gia tri ham');
      Writeln(Format('Gia tri ham tai x=%g la y=%s',[x, gStr(y,4)]));
      lbGiatriHam.Caption := format('la %s', [gStr(y,4)]);
    end else begin
      lbGiatriHam.Caption := 'Khong tinh duoc gia tri do co loi. Xem CRT.';
      Application.MessageBox('Khong giai duoc phuong trinh do co loi. Xem CRT.','BTSH' , MB_OK);
    end;
  finally
    NewCPU.Free;
    CloseOutput;
  end;
end;

procedure TFormChinh.PaintBox2Paint(Sender: TObject);
begin
 if (NodeStack <> nil) and (NodeStack.Count > 0) and (ListBox1.ItemIndex >=0) then begin
    Paintbox2.Canvas.Pen.Color := Paintbox2.Font.Color;
    Paintbox2.Canvas.Pen.Width:= 2;
    DrawFormula(Paintbox2, NodeStack.Items[ListBox1.ItemIndex]);
 end;
end;

procedure TFormChinh.ShowTable1Click(Sender: TObject);
begin
  OpenOutput;
  try
    Writeln('Bang cac danh bieu tong the cua chuong trinh va cua cac chuong trinh con cuoi cung');
    FCompiler.ShowTable;
    Writeln('============================================');
    PageControl1.ActivePageIndex := 0;
  finally
    CloseOutput;
  end;
end;

procedure TFormChinh.FileNewClick(Sender: TObject);
begin
  if not CanCloseSource then exit;
  PageControl1.ActivePageIndex := 1;
  edPL0Source.Clear;
  FSourcePL0FileName:='BieuThucMoi.Pl0';
  SetCaption(FSourcePL0FileName);
  edPL0Source.Lines.Add('const Heso1=1, Heso2=2;');
  edPL0Source.Lines.Add('var x, y;');
  edPL0Source.Lines.Add('begin');
  edPL0Source.Lines.Add('  y:= x;');
  edPL0Source.Lines.Add('  y:= sin(x);');
  edPL0Source.Lines.Add('end.');
  FNewSourceFile:= True;
end;

procedure TFormChinh.ActionListRunUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  ActionGraphic.Enabled := FCodeValid;
  ActionFillTable.Enabled := FCodeValid;
  ActionRun.Enabled := FCodeValid;
  ActionViewCode.Enabled := FCodeValid;

  ActionZoomIn.Enabled := PageControl1.ActivePageIndex = 3;
  ActionZoomOut.Enabled := ActionZoomIn.Enabled;
  ActionShowHideXminXmax.Enabled:= ActionZoomIn.Enabled;
  btnZoomOut.Down := FZoomAction = actZoomOut;
  btnZoomIn.Down := FZoomAction = actZoomIn;
end;

procedure TFormChinh.EditCutClick(Sender: TObject);
begin
  Editor.CutToClipboard;
end;

procedure TFormChinh.EditCopyClick(Sender: TObject);
begin
  Editor.CopyToClipboard;
end;

procedure TFormChinh.EditPasteClick(Sender: TObject);
begin
  Editor.PasteFromClipboard;
end;

procedure TFormChinh.EditSelectallClick(Sender: TObject);
begin
  Editor.SelectAll;
end;

procedure TFormChinh.EditDeleteClick(Sender: TObject);
begin
  Editor.ClearSelection;
end;

procedure TFormChinh.EditUndoExecute(Sender: TObject);
begin
  with Editor do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TFormChinh.ActionListEditUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
 { Update the status of the edit commands }
  if Editor = nil then exit;
  EditCut.Enabled := Editor.SelLength > 0;
  EditCopy.Enabled := EditCut.Enabled;
  if Editor.HandleAllocated then
  begin
    EditUndo.Enabled := Editor.Perform(EM_CANUNDO, 0, 0) <> 0;
    EditPaste.Enabled := Editor.Perform(EM_CANPASTE, 0, 0) <> 0;
  end;
end;

procedure TFormChinh.ActionZoomInExecute(Sender: TObject);
begin
  FZoomAction:= actZoomIn;
end;

procedure TFormChinh.ActionZoomOutExecute(Sender: TObject);
begin
  FZoomAction:= actZoomOut;
end;

procedure TFormChinh.ActionShowHideXminXmaxExecute(Sender: TObject);
begin
  PanelXminXMax.Visible :=   not PanelXminXMax.Visible;
end;

procedure TFormChinh.ZoomY(ZoomIn: boolean);
begin
  if ZoomIn then
    FGrid.ScaleY := FGrid.ScaleY*2
  else
    FGrid.ScaleY := FGrid.ScaleY/2;

  UpdateGraph;
  InvalidatePaintBoxes;
end;

procedure TFormChinh.Setfont1Click(Sender: TObject);
var
  aPaintBox: TPaintBox;
begin
   aPaintBox:= TPaintBox(PopupMenu1.PopupComponent);

   FontDialog1.Font := aPaintBox.Font;
   if FontDialog1.Execute then begin
     aPaintBox.Font := FontDialog1.Font;
   end
end;

function TFormChinh.CanCloseSource: Boolean;
var
  M: integer;
  CanClose: Boolean;
begin
  if edPL0Source.Modified then begin
    M:= Application.MessageBox('Chuong trinh nguon da thay doi. Luu lai?', 'BTSH: Luu thay doi', MB_YESNOCANCEL);
    if M = IDYes then begin
       if FSourcePL0FileName = fnNewFile then begin
         SaveAs1Click(nil)
       end else begin
         BtnSaveClick(nil);
       end;
       CanClose:= true;
    end else if M = IDNo then begin
       CanClose:= true;
    end else
      CanClose:= False;
  end else
    CanClose:= true;

  Result:= CanClose;
end;

procedure TFormChinh.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:= CanCloseSource;
end;


procedure TFormChinh.FilePrintExecute(Sender: TObject);
var
  OldScaleX, OldScaleY: TFloat;
  NewScaleX, NewScaleY: Integer;
  aXMin, aYMin: Integer;
begin

  OldScaleX:= FGrid.ScaleX;
  OldScaleY:= FGrid.ScaleY;

  NewScaleX:= trunc(Printer.PageWidth / FGrid.XRange);
  NewScaleY:= trunc(Printer.PageHeight / FGrid.YRange);
  if NewScaleY < NewScaleX then
     NewScaleX:= NewScaleY;

  if NewScaleX < 1 then NewScaleX:= 1;

  FGrid.ScaleX:= NewScaleX*OldScaleX;
  FGrid.ScaleY:= NewScaleX*OldScaleY;
  FGrid.DX:= FGrid.DX*NewScaleX;
  FGrid.DY:= FGrid.DY*NewScaleX;

  UpdateGraph;
  aXMin:= FGrid.XMin;
  aYMin:= FGrid.YMin;
  //
  FFuncResult.MoveXY(-aXMin, -aYMin);// it call  FGrid.MoveXY(-aXMin, -aYMin);

  Printer.BeginDoc;
//  VeDoThi(PaintBoxXY.Canvas);

  VeDoThi(Printer.Canvas);
  Printer.EndDoc;



  FFuncResult.MoveXY(aXMin, aYMin);

  FGrid.ScaleX:= OldScaleX;
  FGrid.ScaleY:= OldScaleY;
  UpdateGraph;
  FGrid.DX:= FGrid.DX div NewScaleX;
  FGrid.DY:= FGrid.DY div NewScaleX;
end;

procedure TFormChinh.VeDoThi(Canvas: TCanvas);
var
  DC: hDC;
  Node: TNode;
  i, j, DY: Integer;
  P: array[0..1] of TPoint;
begin
  Canvas.Pen.Width:= 2;
  DY:=10;
  j:= 0;  // Dong bo Color
  if (NodeStack <> nil) and (NodeStack.Count > 0) then begin
    for i:= 0 to NodeStack.Count - 1 do begin
      Node:= NodeStack[i];
      if not Node.ValidCodeForDrawGraph then Continue;

      Canvas.Pen.Color:= DrawFunc.GetColor(j);
      DC:= Canvas.Handle;
      Node.UpDateNeedPar;
      SetCharHW(DC);
      Node.UpdateRect(DC);
      Node.MoveTo00;
      Node.Move(50, DY);
      P[0].X:=5;
      P[1].X:=25;
      P[0].Y:= (Node.FormulaRect.Top+Node.FormulaRect.Bottom) div 2 ;
      P[1].Y:= P[0].Y;
      windows.Polyline(DC, P, 2);

      Node.Draw(DC);
      DY:= DY + Node.Height + 5;
      inc(j);
    end;
  end;


  with Canvas do begin
    Pen.Color:= clBlue;
    Pen.Style:= psDot;

    DC:= Canvas.Handle;

    with ScrollBox1 do
      FGrid.Draw(DC, HorzScrollBar.Position, VertScrollBar.Position);

    Pen.Color:= clRed;
    Pen.Width:= 2;
    DC:= Canvas.Handle;
    FFuncResult.Draw(DC);
    Pen.Width:= 1;
  end;
end;

procedure TFormChinh.FilePrinterSetupExecute(Sender: TObject);
begin
   PrinterSetupDialog1.Execute;
end;

procedure TFormChinh.UpDateGraph;
var
  XMin, XMax, YMin, YMax: TFloat;
begin
  FGrid.GetLogicalMinMax(XMin, XMax, YMin, YMax);
  XMin:= FloatValue(cbXFrom);
  XMax:= FloatValue(cbXTo);

  // Chu y: Y bi dao nguoc
  YMax:= FloatValue(cbY2);
  YMin:= FloatValue(cbY1);
  FGrid.SetLogicalMinMax(XMin, XMax, YMin, YMax);

  FFuncResult.UpdateFuncResults;
  if CheckBoxAutoCalcY.Checked then begin
    FFuncResult.GetYMinMax(Ymin, YMax);
    FGrid.SetLogicalMinMax(XMin, XMax, YMin, YMax);
  end;
end;

procedure TFormChinh.ActionViewCodeExecute(Sender: TObject);
begin
  OpenOutput;
  try
    Writeln('Ma may PL/0 sau khi bien dich lan cuoi cung:');
    FCompiler.CPU.ListAllCode;
    PageControl1.ActivePageIndex := 0;
  finally
    CloseOutput;
  end;
end;

procedure TFormChinh.StringGridFuncResultDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);

  procedure locPaintRect;
  var
    Canvas: TCanvas;
    R: TRect;
  begin
    Canvas:= StringGridFuncResult.Canvas;
    Canvas.Brush.Color:= StringGridFuncResult.FixedColor;
    R:= Rect;
    Inc(R.Top);
    Inc(R.Left);
    Canvas.FillRect(R);
  end;
var
  j: integer;
  Root: TNode;
  aDC: hDC;
  Canvas: TCanvas;

begin
  if NodeStack.Count <= 0 then exit;
  if (ARow = 1) and (aCol > 1) then begin
    if not NodeStack.GetValidItemIndex(ACol-2, j) then exit;
    Root:= NodeStack[j];
    Canvas:= StringGridFuncResult.Canvas;
    locPaintRect;
    aDC:= Canvas.Handle;
    Canvas.Pen.Color := Canvas.Font.Color;
    Root.UpDateNeedPar;
    SetCharHW(aDC);
    Root.UpdateRect(aDC);
    Root.MoveTo00;
    Root.Move(Rect.Left+5, Rect.Top+1);
    Root.Draw(aDC);
  end else if (ARow = 1) and (aCol = 1) then begin
    locPaintRect;
  end;
end;

function TFormChinh.FloatValue(cb: TComboBox): Double;
var Code: Integer;
begin
   Val(cb.text, Result, Code);
   if Code <> 0 then begin
     cb.SetFocus;
     raise Exception.Create('Phai nhap gia tri so thuc.');
   end;
end;

function TFormChinh.IntValue(cb: TComboBox): Integer;
var Code: Integer;
begin
   Val(cb.text, Result, Code);
   if Code <> 0 then begin
     cb.SetFocus;
     raise Exception.Create('Phai nhap gia tri so NGUYEN.');
   end;
end;

procedure TFormChinh.ActionThuNhoYExecute(Sender: TObject);
begin
  ZoomY(false);
end;

procedure TFormChinh.ActionPhongToYExecute(Sender: TObject);
begin
  ZoomY(true);
end;

//============================== TIdentList ==================
type
TIdentList = class(TStringList)
  function HasIdent(id: string; var Index : Integer): Boolean;
  procedure AddIdent(id: string);
  function CreatePL0SourceList(Exp: string): TStringList;
  function CreatePL0Source(Exp: string): string;
  procedure RecordIdent(exp: string);
  procedure RemoveKnownIds;
end;

function TIdentList.HasIdent(id: string; var Index : Integer): Boolean;
var i: Integer;
begin
  Result := False;
  id := UpperCase(id);
  for i:= 0 to Count -1 do begin
    if UpperCase(Strings[i])=id then begin
      Result:= true;
      Index := i;
      Exit;
    end;
  end;
end;

procedure TIdentList.AddIdent(id: string);
// Chi them vao ID list neu nhu id chua co trong danh sach
var i : Integer;
begin
  if not HasIdent(id, i) then
    Add(id);
end;

procedure TIdentList.RemoveKnownIds;
  function locCanDelete(S: string): boolean;
  var aFunc: TEIntrinsicFunction;
  begin
    if (S='X') or (S = 'Y') or IsIntrinsicFunction(S, aFunc) then
      Result := True
    else
      Result := False;
  end;

var
  i: Integer;
  S: string;
begin
  if Count = 0 then exit;
  I:= Count-1;
  while i >=0 do begin
    S:= UpperCase(Strings[i]);
    if locCanDelete(S) then
       Delete(i);
    Dec(i);
  end;
end;

function TIdentList.CreatePL0SourceList(Exp: string): TStringList;
  function locConstStr: string;
  var i: Integer;
  begin
    if Count = 0 then begin
      Result :='';
      Exit;
    end;

    Result:='CONST ';
    for i:= 0 to Count -1 do begin
      Result:= Result + Strings[i]+'=1';
      if i = Count - 1 then
        Result:= Result + ';'
      else
        Result:= Result + ','
    end;
  end;
var
  SourceList: TStringList;
  S: string;
begin
  Clear;
  RecordIdent(Exp);
  SourceList := TStringList.Create;
  RemoveKnownIds;
  S:= locConstStr;
  if S <> '' then SourceList.Add(S);
  
  SourceList.Add('VAR X, Y;');
  SourceList.Add('BEGIN');
  SourceList.Add(' Y :='+exp+';');
  SourceList.Add('END.');
  Result:= SourceList;
end;

function TIdentList.CreatePL0Source(Exp: string): string;
var SourceList:TStringList;
begin
  SourceList:= CreatePL0SourceList(Exp);
  Result:= CreatePL0SourceList(Exp).Text;
  SourceList.Free;
end;

procedure TIdentList.RecordIdent(exp: string);
var aTuVung: TPhanTichTuVung;
begin
  aTuVung := TPhanTichTuVung.Create ;
  try
    aTuVung.InitBuf(Exp);
    repeat
      aTuVung.GetSym;
      if aTuVung.Sym= ident then begin
        AddIdent(aTuVung.OrgId);
      end;
    until aTuVung.Sym = null;
  finally
    aTuVung.Free;
  end;
end;

//============================================================

procedure TFormChinh.edFormulaDirectChange(Sender: TObject);
var
  S: string;
  IdentList: TIdentList;
  Src: string;
begin
  S:= edFormulaDirect.Text ;
  OpenOutput;
  try
    IdentList:=TIdentList.Create;
    IdentList.RecordIdent(S);
    Src:=IdentList.CreatePL0Source(S);

    ListBox1.Clear;
    S:= Src;
    try
      FCompiler.ParseBuf(S);
    finally
      if FCompiler.HasError then begin
         ShowMsg(FCompiler.LastErrorString);
         PaintBoxFormulaDirect.Refresh;
         lbFormulaDirectStatus.Caption:='Error: Cong thuc chua dung';
         FCodeValid:= False;
      end else begin
         ShowMsg('Bien dich thanh cong');
         lbFormulaDirectStatus.Caption:='';
         PaintBoxFormulaDirect.Invalidate;
         FCodeValid:= True;
      end;
    end;

  finally
    CloseOutput;
   end;

end;

procedure TFormChinh.PaintBoxFormulaDirectPaint(Sender: TObject);
begin
  if (NodeStack <> nil) and (NodeStack.Count > 0)  then begin
     PaintBoxFormulaDirect.Canvas.Pen.Color := PaintBoxFormulaDirect.Font.Color;
     PaintBoxFormulaDirect.Canvas.Pen.Width:= 2;
     DrawFormula(PaintBoxFormulaDirect, NodeStack.Items[0])
  end else begin

  end;
end;

procedure TFormChinh.Button1Click(Sender: TObject);
var
  IdentList: TIdentList;
  SourceList:TStringList;
begin
  if not CanCloseSource then Exit;
  IdentList:= TIdentList.Create;
  SourceList:= IdentList.CreatePL0SourceList(edFormulaDirect.Text);

  PageControl1.ActivePageIndex := 1;
  edPL0Source.Clear;
  FSourcePL0FileName:='BieuThucMoi.Pl0';
  SetCaption(FSourcePL0FileName);
  edPL0Source.Lines := SourceList;
  FNewSourceFile:= True;

  SourceList.Free;
  IdentList.Free;
end;

end.
