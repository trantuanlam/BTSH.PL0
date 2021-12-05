{*******************************************************}
{       Dai hoc bach khoa Ha noi                        }
{       Do an tot nghiep: Phan tich Bieu thuc so hoc... }
{       Sinh vien - Tran Tuan Lam,  tel 064-837087      }
{                              trantuanlam@hotmail.com  }
{                   Vung tau, 2002                     }
{-------------------------------------------------------}
{       Unit GlobalTypes                                }
{       Mot so khai bao tong the                        }
{*******************************************************}

unit GlobalTypes;

interface

type

  TFloat = Double;

const

  cMaxArrSize = 1000;// So phan tu cua mang toa do dung de ve do thi ham so

type

  PArrayFloat = ^TArrayFloat;
  TArrayFloat = array[0..cMaxArrSize] of TFloat;

implementation {--------------------------------------------------------------}

end.
