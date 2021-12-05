
{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                      }
{                                                       }
{       Giao vien huong dan: Pham Dang Hai              }
{-------------------------------------------------------}
{       program BTSH                                    }
{       Chuong trinh chinh.                             }
{*******************************************************}


program BTSH;


{$R *.RES}

uses
  Forms,
  FormPL0Crt in 'FormPL0Crt.pas' {FormChinh},
  BTSHabout in 'BTSHabout.pas' {AboutBox},
  PL0Paser in 'PL0Paser.pas',
  GlobalTypes in 'GlobalTypes.pas',
  Interpreter in 'Interpreter.pas',
  ParseTree in 'ParseTree.pas',
  TuVung in 'TuVung.pas',
  HamDungSan in 'HamDungSan.pas',
  DrawFunc in 'DrawFunc.pas';

begin
  Application.Initialize;
  Application.Title := 'Phan tich BTSH';
  Application.CreateForm(TFormChinh, FormChinh);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
