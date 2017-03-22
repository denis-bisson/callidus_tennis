program CallidusRadarLoganalyzer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, StrUtils;

//22:10:19:265 - Rx - <0x83>A    A      3  5@
//12:13:39:160 - Rx - <0x83>C139 C  9   9 22@
//1234567890123456789012345678901234567890
//         1         2         3         4
var
  FichierIn, FichierOut: textfile;
  sPreviousSpeed, sFastestSpeed, sSpeed, sLastLine, sSubLine, sLigneLue: string;
  sHour, sPrecedentHour: string;
  iIndex, iSpeed, iFastestSpeed, iDayNumber: integer;
  iTableSpeed: array[0..250] of integer;
begin
  sPreviousSpeed:='';
  sLastLine := '';
  sPrecedentHour := '00';
  iFastestSpeed := 0;
  iDayNumber := 14;
  for iIndex := 0 to 250 do iTableSpeed[iIndex] := 0;

  AssignFile(FichierIn, 'AllInOne.log');
  filemode := 0;
  Reset(FichierIn);
  try
    AssignFile(FichierOut, 'UniqueLines.log');
    filemode := 1;
    ReWrite(FichierOut);
    try
      while not eof(FichierIn) do
      begin
        ReadLn(FichierIn, sLigneLue);
        sSubLine := RightStr(sLigneLue, (length(sLigneLue) - 16));
        if sLastLine <> sSubLine then
        begin
          sHour := LeftStr(sLigneLue, 2);
          if sHour < sPrecedentHour then inc(iDayNumber);
          sPrecedentHour := sHour;

          sSpeed := copy(sLigneLue, 28, 3);
          sSpeed := StringReplace(sSpeed, ' ', '', [rfReplaceAll]);
          if sSpeed<>sPreviousSpeed then
          begin
            sPreviousSpeed := sSpeed;
            WriteLn(FichierOut, Format('%2.2d: %s', [iDayNumber, sLigneLue]));
            sLastLine := sSubLine;

            iSpeed := StrToIntDef(sSpeed, 0);
            inc(iTableSpeed[iSpeed]);
            if iSpeed > iFastestSpeed then
            begin
              iFastestSpeed := iSpeed;
              sFastestSpeed := Format('%2.2d: %s', [iDayNumber, sLigneLue]);
            end;
          end;
        end;
      end;

      WriteLn(FichierOut, '***************************************************');
      WriteLn(FichierOut, 'FASTEST SPEED: ' + sFastestSpeed);
      WriteLn(FichierOut, '***************************************************');
      for iIndex := 0 to 250 do
        WriteLn(FichierOut, Format('%d;%d', [iIndex, iTableSpeed[iIndex]]));

    finally
      CloseFile(FichierOut);
    end;
  finally
    CloseFile(FichierIn);
  end;

end.

