unit UMain;

interface

uses
  UHelp;

  function Process (var T: TSystem; var X: TComplexVector): TComplexVector;

implementation

uses
  SysUtils;

  function Process (var T: TSystem; var X: TComplexVector): TComplexVector;
  var
    i, j, k, imax: Integer;
    r, max: TType;
    P: TIndex;
    A11, A12, A21, A22: TMatrix;

    procedure Swap (var X, Y: Integer);
    var
      tmp: Integer;
    begin
      tmp := X;
      X := Y;
      Y := tmp;
    end;

    procedure FindMax(var X: TType);
    begin
      if Abs(X) > max then begin
        max := Abs(X);
        imax := i;
      end;
    end;

  begin
    for i := 1 to N do
      for j := 1 to N do begin
        A11[i,j] := T.A.Rl[i,j];
        A12[i,j] := -T.A.Im[i,j];
        A21[i,j] := T.A.Im[i,j];
        A22[i,j] := T.A.Rl[i,j];
      end;
    for i := 1 to 2*N do
      P[i] := i;
    PrintMatrix(A11, A12, A21, A22, X, T.F, 'Initial matrix', P);
    //ЛЕВАЯ ЧАСТЬ
    for j := 1 to N do begin
      // ищем максимальный по модулю в столбце нижнетреугольной матрицы
      max := 0; imax := 0;
      for i := j to 2*N do
        if P[i] > N then
          FindMax(A21[P[i]-N, j])
        else
          FindMax(A11[P[i], j]);
      if imax > j then
        Swap(P[j], P[imax]); // меняем P[j]-ю и P[imax]-ю строки местами

      // делим j-ю строку на диагональный элемент
      if P[j] > N then begin
        r := 1/A21[P[j] - N, j];
        A21[P[j] - N, j] := 1;
        //левая половина снизу = Aim
        for i := j+1 to N do
          A21[P[j]-N, i] := r * A21[P[j]-N, i];
        //правая половина снизу = Arl
        for i := 1 to N do
          A22[P[j]-N, i] := r * A22[P[j]-N, i];
        T.F.Im[P[j]-N] := r * T.F.Im[P[j]-N];
      end
      else begin
        r := 1/A11[P[j], j];
        A11[P[j], j] := 1;
        //левая половина сверху = Arl
        for i := j+1 to N do
          A11[P[j], i] := r * A11[P[j], i];
        //правая половина сверху = -Aim
        for i := 1 to N do
          A12[P[j], i] := r * A12[P[j], i];
        T.F.Rl[P[j]] := r * T.F.Rl[P[j]];
      end;
      PrintMatrix(A11, A12, A21, A22, X, T.F, 'Division by ' + FloatToStr(1/r), P);

      // обнуляем столбец ниже главной диагонали
      for i := j+1 to 2*N do begin
        if P[i] > N then begin
          r := A21[P[i] - N, j];
          A21[P[i] - N, j] := 0;
          //максимум в нижней половине
          if P[j] > N then begin
            //левая половина снизу = Aim
            for k := j+1 to N do
              A21[P[i]-N, k] := A21[P[i]-N, k] - r*A21[P[j]-N, k];
            //правая половина снизу = Arl
            for k := 1 to N do
              A22[P[i]-N, k] := A22[P[i]-N, k] - r*A22[P[j]-N, k];
            T.F.Im[P[i]-N] := T.F.Im[P[i]-N] - r*T.F.Im[P[j]-N];
          end
          //максимум в верхней половине
          else begin
            //левая половина снизу = Aim
            for k := j+1 to N do
              A21[P[i]-N, k] := A21[P[i]-N, k] - r*A11[P[j], k];
            //правая половина снизу = Arl
            for k := 1 to N do
              A22[P[i]-N, k] := A22[P[i]-N, k] - r*A12[P[j], k];
            T.F.Im[P[i]-N] := T.F.Im[P[i]-N] - r*T.F.Rl[P[j]];
          end;
        end
        else begin
          r := A11[P[i], j];
          A11[P[i], j] := 0;
          //максимум в нижней половине
          if P[j] > N then begin
            //левая половина сверху = Arl
            for k := j+1 to N do
              A11[P[i], k] := A11[P[i], k] - r*A21[P[j]-N, k];
            //правая половина сверху = -Aim
            for k := 1 to N do
              A12[P[i], k] := A12[P[i], k] - r*A22[P[j]-N, k];
            T.F.Rl[P[i]] := T.F.Rl[P[i]] - r*T.F.Im[P[j]-N];
          end
          //максимум в верхней половине
          else begin
            //левая половина сверху = Arl
            for k := j+1 to N do
              A11[P[i], k] := A11[P[i], k] - r*A11[P[j], k];
            //правая половина сверху = -Aim
            for k := 1 to N do
              A12[P[i], k] := A12[P[i], k] - r*A12[P[j], k];
            T.F.Rl[P[i]] := T.F.Rl[P[i]] - r*T.F.Rl[P[j]];
          end;
        end;
        PrintMatrix(A11, A12, A21, A22, X, T.F, 'Substraction in ' + IntToStr(i) + ' line', P);
      end;
    end;
    //ПРАВАЯ ЧАСТЬ
    for j := N+1 to 2*N do begin
      // ищем максимальный по модулю в столбце нижнетреугольной матрицы
      max := 0; imax := 0;
      for i := j to 2*N do
        if P[i] > N then
          FindMax(A22[P[i]-N, j-N])
        else
          FindMax(A12[P[i], j-N]);
      if imax > j then
        Swap(P[j], P[imax]); // меняем P[j]-ю и P[imax]-ю строки местами

      // делим j-ю строку на диагональный элемент
      if P[j] > N then begin
        r := 1/A22[P[j] - N, j-N];
        A22[P[j] - N, j-N] := 1;
        //правая половина снизу = Arl
        for i := j-N+1 to N do
          A22[P[j]-N, i] := r * A22[P[j]-N, i];
        T.F.Im[P[j]-N] := r * T.F.Im[P[j]-N];
      end
      else begin
        r := 1/A12[P[j], j-N];
        A12[P[j], j-N] := 1;
        //правая половина сверху = -Aim
        for i := j-N+1 to N do
          A12[P[j], i] := r * A12[P[j], i];
        T.F.Rl[P[j]] := r * T.F.Rl[P[j]];
      end;
      PrintMatrix(A11, A12, A21, A22, X, T.F, 'Division by ' + FloatToStr(1/r), P);

      // обнуляем столбец ниже главной диагонали
      for i := j+1 to 2*N do begin
        if P[i] > N then begin
          r := A22[P[i] - N, j-N];
          A22[P[i]-N, j-N] := 0;
          //максимум в нижней половине
          if P[j] > N then begin
            //правая половина снизу = Arl
            for k := j-N+1 to N do
              A22[P[i]-N, k] := A22[P[i]-N, k] - r*A22[P[j]-N, k];
            T.F.Im[P[i]-N] := T.F.Im[P[i]-N] - r*T.F.Im[P[j]-N];
          end
          //максимум в верхней половине
          else begin
            //правая половина снизу = Arl
            for k := j-N+1 to N do
              A22[P[i]-N, k] := A22[P[i]-N, k] - r*A12[P[j], k];
            T.F.Im[P[i]-N] := T.F.Im[P[i]-N] - r*T.F.Rl[P[j]];
          end;
        end
        else begin
          r := A12[P[i], j-N];
          A12[P[i], j-N] := 0;
          //максимум в нижней половине
          if P[j] > N then begin
            //правая половина сверху = -Aim
            for k := j-N+1 to N do
              A12[P[i], k] := A12[P[i], k] - r*A22[P[j]-N, k];
            T.F.Rl[P[i]] := T.F.Rl[P[i]] - r*T.F.Im[P[j]-N];
          end
          //максимум в верхней половине
          else begin
            //правая половина сверху = -Aim
            for k := j-N+1 to N do
              A12[P[i], k] := A12[P[i], k] - r*A12[P[j], k];
            T.F.Rl[P[i]] := T.F.Rl[P[i]] - r*T.F.Rl[P[j]];
          end;
        end;
        PrintMatrix(A11, A12, A21, A22, X, T.F, 'Substraction in ' + IntToStr(i) + ' line', P);
      end;
    end;
    //ОБРАТНЫЙ ХОД
    //ЛЕВАЯ ЧАСТЬ
    if P[2*N] > N then
      Result.Im[N] := T.F.Im[P[2*N]-N]
    else
      Result.Im[N] := T.F.Rl[P[2*N]];
    for i := 2*N-1 downto N+1 do begin
      if P[i] > N then
        Result.Im[i-N] := T.F.Im[P[i]-N]
      else
        Result.Im[i-N] := T.F.Rl[P[i]];
      for k := i+1 to 2*N do
        if P[i] > N then
          Result.Im[i-N] := Result.Im[i-N] - A22[P[i-N], k-N]*Result.Im[k-N]
        else
          Result.Im[i-N] := Result.Im[i-N] - A12[P[i], k-N]*Result.Im[k-N];
    end;
    //ПРАВАЯ ЧАСТЬ
    for i := N downto 1 do begin
      if P[i] > N then
        Result.Rl[i] := T.F.Im[P[i]-N]
      else
        Result.Rl[i] := T.F.Rl[P[i]];
      for k := N+1 to 2*N do
        if P[i] > N then
          Result.Rl[i] := Result.Rl[i] - A22[P[i-N], k-N]*Result.Im[k-N]
        else
          Result.Rl[i] := Result.Rl[i] - A12[P[i], k-N]*Result.Im[k-N];
      for k := i+1 to N do
        if P[i] > N then
          Result.Rl[i] := Result.Rl[i] - A21[P[i-N], k]*Result.Im[k]
        else
          Result.Rl[i] := Result.Rl[i] - A11[P[i], k]*Result.Im[k];
    end;
    PrintVector(Result.Rl);
    PrintVector(Result.Im);
  end;

end.
