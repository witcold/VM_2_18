unit UIO;

interface

  procedure PrepareOutput;
  procedure Print (X: Extended);
  procedure PrintRight (X, Y: Extended);
  procedure PrintMessage (S: String);
  procedure CloseOutput;
   
var   
  OutputFile: TextFile;

implementation

uses
  SysUtils;

var   
  FS: TFormatSettings;

  procedure PrepareOutput;
  var
    Filename: String;
  begin
    Filename := 'output_' + TimeToStr(GetTime, FS) + '.txt';
    AssignFile(OutputFile, Filename);
    Rewrite(OutputFile);
  end;

  procedure CloseOutput;
  begin
    CloseFile(OutputFile);
  end;

  procedure Print (X: Extended);
  begin
    if X = 0 then begin
      Write('     ', 0, '');
      Write(OutputFile,'     ', 0, '')
    end
    else begin
      Write(X:6:2, '');
      Write(OutputFile, X:6:2, '')
    end;
  end;

  procedure PrintRight (X, Y: Extended);
  begin
    Writeln(#9'| ', X:8:4, #10#9#9#9#9#9#9#9'| ',Y:8:4);
    Writeln(OutputFile, #9'| ', X:8:4, #13#10#9#9#9#9#9#9#9'| ',Y:8:4, ' ', (X-Y):0:18);
  end;

  procedure PrintMessage(S: String);
  begin
    Writeln(S);
    Write(OutputFile, S);
  end;

begin
  GetLocaleFormatSettings(1251, FS);
  FS.TimeSeparator := '-';
end.
