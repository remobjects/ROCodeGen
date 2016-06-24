namespace RemObjects.SDK.CodeGen4;

uses
  Sugar.*;

type
  ResGenerator = public static class
  private
    const
      FirstEmptyResource: array[0..31] of Byte =
      [$00,$00,$00,$00,$20,$00,$00,$00,$FF,$FF,$00,$00,$FF,$FF,$00,
       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
       $00,$00];
      RODLFile = 'RODLFILE';

    class method WriteLong(buf: array of Byte; var pos: Integer; Value: Int32);
    begin
      buf[pos] := Value and $FF;
      buf[pos+1] := (Value shr 8) and $FF;
      buf[pos+2] := (Value shr 16) and $FF;
      buf[pos+3] := (Value shr 24) and $FF;
      inc(pos,4);
    end;

    class method GenerateRes(Content: array of Byte; aName: String): array of Byte;
    begin
      var len_name := length(aName)*2+2; // aName + #0#0
      if len_name mod 4 <> 0 then inc(len_name,2); // extra 0 for dword alignment      

      var len := length(FirstEmptyResource) + 
                 7*4 {sizeOf(Int32)}+
                 len_name+
                 length(Content);
      result := new array of Byte(len);

      FirstEmptyResource.CopyTo(Result, 0);
      var pos := length(FirstEmptyResource);
      var cnt_size: Int32 := length(Content);
      WriteLong(result, var pos, cnt_size); // Resource Size
      WriteLong(result, var pos, 32+length(aName)*2); // Header Size
      WriteLong(result, var pos, $000AFFFF); // RT_RCDATA
      for i: Integer := 0 to length(aName)-1 do begin
        var ch := ord(aName[i]);
        result[pos] := ch and $FF;
        result[pos+1] := (ch shr 8) and $FF;
        inc(pos,2);
      end;
      inc(pos,2); // Null terminater
      if length(aName)*2+2 <> len_name then 
        inc(pos,2); // extra 0 for dword alignment
      WriteLong(result, var pos, 0); // Data Version
      WriteLong(result, var pos, 0); // Flags + Language
      WriteLong(result, var pos, 0); // Resource Version
      WriteLong(result, var pos, 0); // Characteristics
      Content.CopyTo(Result, pos);
    end;
  public
    class method GenerateRes(RODLFileName: String): array of Byte;
    begin      
      {$IFDEF FAKESUGAR}
      if not File.Exists(RODLFileName) then raise new Exception('file is not found: '+RODLFileName);
      var rodl := File.OpenRead(RODLFileName);      
      {$ELSE}
      if not FileUtils.Exists(RODLFileName) then raise new Exception('file is not found: '+RODLFileName);
      var rodl := new FileHandle(RODLFileName, FileOpenMode.ReadOnly);            
      {$ENDIF}
      var cont := new array of Byte(rodl.Length);
      rodl.Read(cont,0, rodl.Length);
      exit GenerateRes(cont, RODLFile);
    end;

    class method GenerateRes(RODLFileName: String; ResFileName: String);
    begin
      var buf := GenerateRes(RODLFileName);
      {$IFDEF FAKESUGAR}
      var res := File.Create(ResFileName);      
      {$ELSE}
      var res := new FileHandle(ResFileName,FileOpenMode.Create);      
      {$ENDIF}
      res.Write(buf, 0, length(buf));
      res.Flush;
      res.Close;
    end;
  end;

end.
