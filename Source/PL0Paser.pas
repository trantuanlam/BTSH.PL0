{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                     }
{-------------------------------------------------------}
{       Unit  PL0Paser                                  }
{       Compiler de sinh Ma tinh toan va Cay bieu thuc  }
{*******************************************************}

{ Sua doi tu chuong trinh dich PL/0 trong giao trinh    }
{ Thuc hanh ky thuat bien dich - Nguyen Van Ba          }

unit PL0Paser;

interface

uses SysUtils,
     TuVung, Interpreter, ParseTree, HamDungSan;

type

TIdentInfo = record
  Name: alpha;  { ten danh bieu }
  case kind: object_ of //  kind: object_;{ loai danh bieu }
    constant: (val: Double);
    variable, procedure_ :(level, adr: Integer; LValue, RValue: Boolean); // LValue, RValue : chi dung cho bien
end;


TCompiler = class
private
  Table: array[0..txmax] of TIdentInfo;
  TableCount: Integer; // So pham tu trong bang. Sau khi Compile xong chi con lai so phan tu global
  FVirtualCPU: TVirtualCPU;
  FPhanTichTuVung: TPhanTichTuVung;
  FNodeStack: TNodeStack;
private
  function CX: Integer;
  procedure IGen(x: fct; y, z: Integer);
  procedure FGen(x: fct; y: Integer; z: Double);

  function Sym: symbol;
  function Id: string;
  function OrgId: string;
  function Num: double;
  procedure GetSym;
  procedure Error(ErrCode: integer);

  procedure Block(lev, tx: integer);
  procedure Compile;
public
  constructor Create;
  destructor Destroy; override;

  procedure ParseFile(FN: string);
  procedure ParseBuf(S: string);

  // Map of FPhanTichTuVung Error procs
  function HasError: Boolean;
  function ErrorPos : integer;
  function LastErrorString: string;

  procedure ShowTable;

  property CPU: TVirtualCPU read FVirtualCPU;
  property NodeStack: TNodeStack read FNodeStack;
end;

implementation {--------------------------------------------------------------}

constructor TCompiler.Create;
begin
  inherited Create;
  FVirtualCPU:= TVirtualCPU.Create;
  FVirtualCPU.Debug:= true;
  FNodeStack:= TNodeStack.Create;
//  FNodeStack.LockStack;
  FPhanTichTuVung:= TPhanTichTuVung.Create;
end;

destructor TCompiler.Destroy;
begin
  FPhanTichTuVung.Free;
  FNodeStack.Free;
  FVirtualCPU.Free;
  inherited Destroy;
end;

var CXFrom, CXTo: integer;

  function TCompiler.CX: Integer;
  begin
    Result:= FVirtualCPU.CX;
  end;

procedure TCompiler.ShowTable;
var
  i: Integer;
const cKind : array[object_] of string =('const ', 'var ', 'proc ');
begin
  for i:=1 to TableCount do begin
    with table[i] do begin
      Write(cKind[kind]);
      Write(Name, ' ');
      case Kind of
        constant: Writeln(val:6:1);
        variable: begin
                     Write(Format('Level=%d Adr=%d',[level, adr]));
                     if LValue then Write(' LValue');
                     if RValue then Write(' RValue');
                     if not (LValue or RValue) then Write(' Var not used');
                     Writeln;
                  end;
        procedure_ : Writeln(Format('Level=%d Adr=%d',[level, adr]));
      end;
    end;
  end;
end;


procedure TCompiler.IGen(x: fct; y, z: Integer);
begin
  FVirtualCPU.IGen(x, y, z);
end;

procedure TCompiler.FGen(x: fct; y: Integer; z: Double);
begin
  FVirtualCPU.FGen(x, y, z);
end;

// simulate
function TCompiler.sym: symbol;
begin
  Result:= FPhanTichTuVung.Sym;
end;

function TCompiler.OrgId: string;
begin
  Result:= FPhanTichTuVung.OrgID;
end;

function TCompiler.id: string;
begin
  Result:= FPhanTichTuVung.Id;
end;

function TCompiler.Num: Double;
begin
  Result:= FPhanTichTuVung.Num;
end;

procedure TCompiler.GetSym;
begin
  FPhanTichTuVung.GetSym;
end;

procedure TCompiler.Block(lev, tx: integer);
  var
    dx: integer;  { chi so cap phat du lieu }
    tx0: integer; { chi so bang luc vao block}
    cx0: integer; { chi so ma dich luc vao block }

  procedure Enter(k: object_; SoDuong: Boolean = True);
  { ghi nhan mot doi tuong moi vao bang}
  begin
    tx:= tx+1;
    TableCount:= tx;
    with table[tx] do begin
      name:= id;
      kind:= k;
      case k of
        constant:
          begin
            if SoDuong then
               val:= Num
            else
               val:= -Num;
          end;

        variable:
          begin
            level:= lev;
            adr:= dx;
            inc(dx);
            LValue:= False;
            RValue:= False;
            if adr > aMax then Error(30);
          end;
        procedure_: level:= lev;
      end;
    end;
  end; { Enter }

  function Position(id: alpha): integer;
  { tim danh bieu id trong bang theo ky thuat linh canh }
  var i: integer;
  begin
    table[0].name:= id;
    i:= tx;
    while table[i].name <> id do
      Dec(i);

    Result:= i;
  end;

  procedure constDeclaration;
  var SoDuong: Boolean;
  begin
    if sym = ident then begin
      GetSym;
      if sym = eql then begin
        GetSym;
        if sym = number then begin
          Enter(constant);
          GetSym
        end else if sym in [plus, minus] then begin
          SoDuong := sym = plus;
          GetSym;
          if sym = number then begin
             Enter(constant, SoDuong);
             GetSym;
          end else
             Error(2);
        end else
          Error(2);
      end else
        Error(3);
    end else begin
      Error(4);
    end;
  end; { constDeclaration }

  procedure varDeclaration;
  begin {varDeclaration}
    if sym = ident then begin
      enter(variable);
      GetSym;
    end else
      Error(4);
  end; {varDeclaration}


  procedure ListCode;
  begin
    FVirtualCPU.ListCode(cx0, cx-1)
  end;

  procedure Statement;
    procedure Expression;
      procedure Term;
        procedure Factor;
        var
          i:integer;
          aFunc: TEIntrinsicFunction;
          FuncName: string;
        begin {Factor}
          if sym = ident then begin
            i:= Position(Id);
            if i= 0 then begin
              // test if this is a intrinsic functions
              if IsIntrinsicFunction(Id, aFunc) then begin
                // loi goi ham phai co dang F(X)
                FuncName:= OrgId;// Save funcName
                GetSym;
                if sym = lparent then begin
                  GetSym;
                  Expression;
                 if sym = rparent then
                   //GetSym : se duoc goi
                 else
                   Error(34);

                  IGen(opr, ord(afunc), opr_CallFunc);
                  FNodeStack.AddFunc(FuncName);
                end else begin
                  Error(33);
                end;
              end else
                Error(11)
            end else begin
              with table[i] do begin
                case kind of
                  constant: begin
                    FGen(lit, 0, val);
                    FNodeStack.AddIdent(OrgID);
                  end;
                  variable: begin
                    IGen(lod, lev-level, adr);
                    FNodeStack.AddIdent(OrgID);
                    table[i].RValue:= True;
                  end;
                  procedure_ : error(21);
                end;
              end;
            end;
            GetSym;
          end else if sym = number then begin
            // if Num > aMax then Error(sErr30);
            FGen(lit, 0, num);
            FNodeStack.AddIdent(Trim(Format('%g', [num*1.0])));
            GetSym;
          end else if sym = lparent then begin
            GetSym;
            Expression;
            if sym = rparent then
              GetSym
            else
              Error(22);
          end else
             Error(23);

        end; {Factor}

      var MulOp: symbol;
      begin {Term}
        Factor;
        while sym in [times, slash] do begin
          MulOp := sym;
          GetSym;
          Factor;
          if MulOp= times then begin
            IGen(opr, 0, oprNhan);  //4
            FNodeStack.AddOperation('*',symTimes);
          end else begin
            IGen(opr, 0, oprChia);  //5
            FNodeStack.AddOperation('/',symSlash);
          end;
        end;
      end; {Term}

    var AddOp: symbol;

    begin {Expresion}
      if sym in [plus, minus] then begin
        AddOp:= Sym;
        GetSym;
        Term;
        if AddOp = minus then begin
          IGen(opr, 0, oprDaoDau); // dao dau 1
          FNodeStack.AddNeg('-');
        end;
      end else
        Term;

      while sym in [plus, minus] do begin
        AddOp:= Sym;
        GetSym;
        Term;
        if AddOp = plus then begin
          IGen(opr, 0, oprCong); {2}
          FNodeStack.AddOperation('+',symPlus);
        end else begin
          IGen(opr, 0, oprTru ); {3}
          FNodeStack.AddOperation('-',symMinus);
        end;
      end;
    end; {Expresion}

    procedure Condition;
    var RelOp: Symbol;
    begin {Condition}
      if sym = oddsym then begin
        GetSym;
        Expression;
        IGen(opr, 0, oprODD);  //6
      end else begin
        Expression;
        if not (sym in [eql, neq, lss, leq, gtr, geq]) then
          Error(20)
        else begin
          RelOp:= Sym;
          GetSym;
          Expression;
          case RelOp of
            eql: IGen(opr, 0, opr_eql);
            neq: IGen(opr, 0, opr_neq);
            lss: IGen(opr, 0, opr_lss);
            geq: IGen(opr, 0, opr_geq);
            gtr: IGen(opr, 0, opr_gtr);
            leq: IGen(opr, 0, opr_leq);
          end;
        end;
      end;
    end; {Condition}

  var i, cx1, cx2: integer;

  begin {Statement}
     if sym = ident then begin
      CXFrom:= FVirtualCPU.CX;
      i:= Position(id);
      if i=0 then begin
        Error(11); { chua khai bao }
      end else begin
        if table[i].kind <> variable then begin
          { khong phai bien ma la hang hay thu tuc }
          error(12);
        end;
        GetSym;

        if Sym = becomes then begin
          table[i].LValue:= True;
          GetSym;
        end else begin
          error(13); { assign expected }
        end;

        // Chi sinh ma cho Level 0 va cau lenh gan
        if lev = 0 then
          FNodeStack.UnLockStack;

        expression;

        if lev = 0 then
          FNodeStack.LockStack;

        if i <> 0 then
          with table[i] do IGen(sto, lev-level, adr);
        CXTo:= FVirtualCPU.CX;
        if lev = 0 then begin
          FNodeStack.TOS.CXFrom := CXFrom;
          FNodeStack.TOS.CXTo := CXTo;
        end;
      end;
    end else if sym = callsym then begin
      GetSym;
      if Sym <> Ident then
         Error(14)
      else begin
        i:= position(id);
        if i = 0 then
          Error(11)
        else begin
          if table[i].kind <> procedure_ then
            Error(15)
          else
            with table[i] do
              IGen(cal, lev-level, adr);
          GetSym;
        end;
      end;
    end else if sym = ifsym then begin
      { cau lenh
      IF C THEN S
      duoc sinh ma nhu sau
      --------------------

          Ma dich cua C
          JPC @N1
          Ma dich cua S

      @N1:........
      }

      GetSym;
      Condition;
      if sym = thensym then
        GetSym
      else
        Error(16);
      cx1:= cx;
      IGen(jpc, 0,0);
      Statement;
      FVirtualCPU.FCode[cx1].a:= cx;

    end else if sym = beginsym then begin
      GetSym;
      Statement;
      while sym = semicolon do begin
        GetSym;
        Statement;
      end;
      if sym = endsym then
        GetSym
      else
        Error(17);
    end else if sym = whilesym then begin
    { cau lenh
      WHILE C DO S
      duoc sinh ma nhu sau
      --------------------

      @N0:Ma dich cua C
          JPC @N1
          Ma dich cua S
          JMP @N0

      @N1:.....
    }
      cx1:= cx;
      GetSym;
      Condition;
      if sym = dosym then
        GetSym
      else
        Error(18);
      cx2:= cx;
      IGen(jpc, 0, 0);
      Statement;
      IGen(jmp, 0, cx1);
      FVirtualCPU.FCode[cx2].a:= cx; // ???
    end;
  end; {Statement}

begin {Block}
  dx:= 3;  // bo 3 o dau danh cho SL, DL va RA
  tx0:= tx;
  table[tx].adr:= cx;
  IGen(jmp, 0, 0);

  if lev > levmax then Error(32);

  repeat
    if sym = constsym then begin
      GetSym;
      constDeclaration;
      while sym = comma do begin
        GetSym;
        constDeclaration;
      end;
      if sym = semicolon then
        GetSym
      else
        Error(5);
    end;

    if sym = varsym then begin
      GetSym;
      varDeclaration;
      while sym = comma do begin
        GetSym;
        varDeclaration;
      end;
      if sym = semicolon then
        GetSym
      else
        Error(5);
    end;

    if sym = procsym then begin;

      while sym = procsym do begin
        GetSym;
        if sym = ident then begin
          enter(procedure_);
          GetSym;
        end else
          Error(4);

        if sym = semicolon then
          GetSym
        else
          Error(5);

        block(lev+1, tx);

        if sym = semicolon then
          GetSym
        else
          Error(5);
      end;

    end;
  until not (sym in declbegsys);

  FVirtualCPU.FCode[Table[tx0].Adr].a:= cx;

  with Table[tx0] do adr:= cx; {dia chi noi bat dau khoi lenh cua thu tuc}
  cx0:= cx;
  IGen(int, 0, dx);
  statement;
  IGen(opr, 0, oprTroVe); {tro ve}
  ListCode;
end; {Block}

procedure TCompiler.Error(ErrCode: integer);
begin
  FPhanTichTuVung.Error(ErrCode);
end;

procedure TCompiler.Compile;
begin
  FVirtualCPU.Init;
  FNodeStack.Reset;
  GetSym;

  block(0, 0);

  if Sym <> period then
    Error(9);
  Writeln('Compiled successfully');

  if HasError then
    writeln('Loi khi dich');
end;

procedure TCompiler.ParseBuf(S: string);
begin
  FPhanTichTuVung.InitBuf(S);
  Compile;
end;


procedure TCompiler.ParseFile(FN: string);
begin

  FVirtualCPU.Init;
  FPhanTichTuVung.LoadSourceFromFile(FN);

  GetSym;

  block(0, 0);

  if Sym <> period then
    Error(9);
  Writeln('Compiled successfully');

  if HasError then
    writeln('Loi khi dich');

end;

function TCompiler.HasError: Boolean;
begin
  Result:= FPhanTichTuVung.HasError;
end;

function TCompiler.ErrorPos : integer;
begin
  Result:= FPhanTichTuVung.ErrorPos;
end;

function TCompiler.LastErrorString: string;
begin
  Result:= FPhanTichTuVung.LasErrorString;
end;

end.

