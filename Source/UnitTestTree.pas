{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                     }
{-------------------------------------------------------}
{       Unit UnitTestTree                               }
{       Sinh ra mot so bieu thuc dung de test           }
{*******************************************************}

unit UnitTestTree;

interface

uses ParseTree;

function CreatTestNode1: TNode;
function CreatTestNode2: TNode;
function CreatTestNode3: TNode;


implementation

function CreatTestNode1: TNode;
var
  N, Root: TNode;
begin
   // K1*K2 /C
  Root:=TNode.Create('/', symSlash);
  Root.AddLeft('*', symTimes);
  Root.AddRight('Costant', symIdent);

  N:=Root.LeftNode;
  N.AddLeft('Koeff1',symIdent);
  N.AddRight('Koeff2', symIdent);

  N:= Root;
  Root:=TNode.Create('+', symPlus);
  Root.AddRightTree(N);
  Root.AddLeft('Const1XXXXXXX', symIdent);


{
  N:= Root;
  Root:=TNode.Create('/', symSlash);
  Root.AddLeftTree(N);
  Root.AddRight('CcnstXHXHL', symIdent);
}
{
  Root:=TNode.Create('+', symPlus);
  Root.AddRightTree(N);
  Root.AddLeft('ConstXXXXXXXXX', symIdent);
}
  Result:= Root;
end;

function CreatTestNode2: TNode;
var
  N1, N2, Root: TNode;
begin
  N1:= CreatTestNode1;
  N2:= CreatTestNode1;
  Root:=TNode.Create('*', symTimes);
//  Root:=TNode.Create('+', symPlus);
  Root.AddLeftTree(N1);
  Root.AddRightTree(N2);

  N1:= Root;
  Root:=TNode.Create('/', symSlash);
  Root.AddRightTree(N1);
//  Root.AddLeft('Tu so', symIdent);
  N1:= CreatTestNode1;
  Root.AddLeftTree(N1);

  Result:= Root;
end;

function CreatTestNode3: TNode;
var
  N, Root: TNode;
begin
  N:= CreatTestNode1;
  Root:=TNode.Create('Sin', symFunc);
//  Root:=TNode.Create('Sin', symPower);
  Root.AddLeftTree(N);

  Result:= Root;
end;

end.
