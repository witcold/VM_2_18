unit UHelp;

interface

const
  N = 4;

type
  TIndex = array [1..2*N] of Integer;
  TType = Extended;
  TVector = array [1..N] of TType;
  TMatrix = array [1..N] of TVector;
  TComplexVector = record
    Rl, Im: TVector;
  end;
  TComplexMatrix = record
    Rl, Im: TMatrix;
  end;
  TSystem = record
    A: TComplexMatrix;
    F: TComplexVector;
  end;

  procedure FillVector (var V: TVector; Min, Max: integer);
  procedure FillMatrix (var M: TMatrix; Min, Max: integer);
  function GetRightValue (var A: TComplexMatrix; var X: TComplexVector): TComplexVector; overload;
  function GetRightValue (var A11, A12, A21, A22: TMatrix; var X: TComplexVector): TComplexVector; overload;
  function GetAccuracy (var X, XA: TComplexVector): TType;
  procedure PrepareData (var T: TSystem; var X: TComplexVector; Range: Integer);
  procedure WriteData (var T: TSystem; var X: TComplexVector);
  procedure LoadData (var T: TSystem; var X: TComplexVector);
  procedure PrintVector (const V: TVector);
  procedure PrintMatrix (var A11, A12, A21, A22: TMatrix; var X, F: TComplexVector; S: String; var P: TIndex);

implementation

uses
  SysUtils, UIO;

  procedure FillVector (var V: TVector; Min, Max: integer);
  var
    i: Integer;
  begin
    for i := 1 to N do
      V[i] := Min + Random * (Max - Min);
      //V[i] := Min + Random(Max - Min);
  end;

  procedure FillMatrix (var M: TMatrix; Min, Max: integer);
  var
    i, j: Integer;
  begin
    for i := 1 to N do
      for j := 1 to N do
        M[i,j] := Min + Random * (Max - Min);
        //M[i,j] := Min + Random(Max - Min);
  end;

  function GetRightValue (var A: TComplexMatrix; var X: TComplexVector): TComplexVector;
  var
    i, j: Integer;
  begin
    for i := 1 to N do begin
      Result.Rl[i] := 0;
      Result.Im[i] := 0;
      for j := 1 to N do begin
        Result.Rl[i] := Result.Rl[i] + A.Rl[i,j]*X.Rl[j] - A.Im[i,j]*X.Im[j];
        Result.Im[i] := Result.Im[i] + A.Im[i,j]*X.Rl[j] + A.Rl[i,j]*X.Im[j];
      end;
    end;
  end;

  function GetRightValue (var A11, A12, A21, A22: TMatrix; var X: TComplexVector): TComplexVector;
  var
    i, j: Integer;
  begin
    for i := 1 to N do begin
      Result.Rl[i] := 0;
      Result.Im[i] := 0;
      for j := 1 to N do begin
        Result.Rl[i] := Result.Rl[i] + A11[i,j]*X.Rl[j] + A12[i,j]*X.Im[j];
        Result.Im[i] := Result.Im[i] + A21[i,j]*X.Rl[j] + A22[i,j]*X.Im[j];
      end;
    end;
  end;

  procedure PrepareData (var T: TSystem; var X: TComplexVector; Range: Integer);
  begin
    with T do begin
      FillMatrix(A.Rl, -Range, Range);
      FillMatrix(A.Im, -Range, Range);
      //FillVector(X.Rl, -Range, Range);
      //FillVector(X.Im, -Range, Range);
      //FillMatrix(A.Rl, -1, 1);
      //FillMatrix(A.Im, -1, 1);
      FillVector(X.Rl, 1, 1);
      FillVector(X.Im, 1, 1);
      F:=GetRightValue(A, X);
    end;
  end;

  function GetAccuracy (var X, XA: TComplexVector): TType;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 1 to N do begin
      if Abs((X.Rl[i] - XA.Rl[i]) / XA.Rl[i]) > Result then
        Result := Abs((X.Rl[i] - XA.Rl[i]) / XA.Rl[i]);
      if Abs((X.Im[i] - XA.Im[i]) / XA.Im[i]) > Result then
        Result := Abs((X.Im[i] - XA.Im[i]) / XA.Im[i]);
    end
  end;

  procedure PrintMatrix (var A11, A12, A21, A22: TMatrix; var X, F: TComplexVector; S: String; var P: TIndex);
  var
    i, j: Integer;
    tmp: TComplexVector;
  begin
    tmp:=GetRightValue(A11, A12, A21, A22, X);
    PrintMessage(S);
    Write(OutputFile, ' [ ');
    for i :=1 to 2*N do
      Write(OutputFile, P[i], ' ');
    Writeln(OutputFile, ']');
    for i := 1 to N do begin
      for j := 1 to N do
        Print(A11[i,j]);
      for j := 1 to N do
        Print(A12[i,j]);
      PrintRight (F.Rl[i], tmp.Rl[i]);
    end;
    for i := 1 to N do begin
      for j := 1 to N do
        Print(A21[i,j]);
      for j := 1 to N do
        Print(A22[i,j]);
      PrintRight (F.Im[i], tmp.Im[i]);
    end;
  end;

  function LoadVector (const F: TextFile; var V: TVector): Integer;
  var
    i: Integer;
  begin
    Readln(F);
    i := 1;
    while i < Length(V) do begin
      read(F, V[i]);
      Inc(i);
    end;
    Readln(F);
    Result := i - 1;
  end;

  procedure WriteData (var T: TSystem; var X: TComplexVector);
  var
    F: TextFile;
    i, j : Integer;
  begin
    AssignFile(F, 'input.txt');
    Rewrite(F);
    Writeln(F, 'Arl');
    for i := 1 to N do begin
      for j := 1 to N do
        Write(F, T.A.Rl[i,j], ' ');
      Writeln(F);
    end;
    Writeln(F, 'Aim');
    for i := 1 to N do begin
      for j := 1 to N do
        Write(F, T.A.Im[i,j], ' ');
      Writeln(F);
    end;
    Writeln(F, 'Xrl');
    for i := 1 to N do
      Writeln(F, X.Rl[i], ' ');
    Writeln(F, 'Xim');
    for i := 1 to N do
      Writeln(F, X.Im[i], ' ');
    Writeln(F, 'Frl');
    for i := 1 to N do
      Writeln(F, T.F.Rl[i], ' ');
    Writeln(F, 'Fim');
    for i := 1 to N do
      Writeln(F, T.F.Im[i], ' ');
    CloseFile(F);
  end;

  procedure LoadData (var T: TSystem; var X: TComplexVector);
  var
    F: TextFile;
    i, j : Integer;
  begin
    AssignFile(F, 'input.txt');
    Reset(F);
    Readln(F);
    for i := 1 to N do begin
      for j := 1 to N do
        Read(F, T.A.Rl[i,j]);
      Readln(F);
    end;
    Readln(F);
    for i := 1 to N do begin
      for j := 1 to N do
        Read(F, T.A.Im[i,j]);
      Readln(F);
    end;
    Readln(F);
    for i := 1 to N do
      Readln(F, X.Rl[i]);
    Readln(F);
    for i := 1 to N do
      Readln(F, X.Im[i]);
    Readln(F);
    for i := 1 to N do
      Readln(F, T.F.Rl[i]);
    Readln(F);
    for i := 1 to N do
      Readln(F, T.F.Im[i]);
    CloseFile(F);
  end;

  procedure PrintVector (const V: TVector);
  var
    i: Integer;
  begin
    for i := 1 to N do
      Print(V[i]);
  end;

end.
