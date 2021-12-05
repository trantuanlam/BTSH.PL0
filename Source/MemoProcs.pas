{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                      }
{-------------------------------------------------------}
{       Unit MemoProcs                                  }
{       Mot so thu tuc/ham xu ly cho editor (memo)      }
{*******************************************************}

unit MemoProcs;

interface

uses windows, Messages, StdCtrls;

function GetFirstVisibleLine(Editor: TCustomEdit): integer;
function GetLineFromChar(Editor: TCustomEdit; CharIndex: integer): integer;
procedure MakeLineFirstVisible(Editor: TCustomEdit; CharIndex: integer);

implementation

function GetFirstVisibleLine(Editor: TCustomEdit): integer;
begin
  result:= SendMessage(Editor.Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
end;

function GetLineFromChar(Editor: TCustomEdit; CharIndex: integer): integer;
begin
  result:= SendMessage(Editor.Handle, EM_LINEFROMCHAR, CharIndex, 0);
end;

procedure MakeLineFirstVisible(Editor: TCustomEdit; CharIndex: integer);
var i, L: integer;
begin
  i:= GetFirstVisibleLine(Editor);
  L:= GetLineFromChar(Editor, CharIndex);
  SendMessage(Editor.Handle, EM_LINESCROLL, 0, l-i);
  Editor.SelStart:= CharIndex;
  Editor.SelLength:= 0;
end;

end.
