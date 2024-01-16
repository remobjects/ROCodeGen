namespace RemObjects.SDK.CodeGen4;

method ExpandVariable(Value: String): String;
begin
  {$IFDEF ECHOES OR WINDOWS}
  if String.IsNullOrEmpty(Value) then exit '';
  var l_key: String := Value;
  if Value.StartsWith('$(') and Value.EndsWith(')') then l_key := Value.Substring(2, Value.Length - 3);
  exit Registry.GetStringValue32(Registry.LocalMachine, 'Software\RemObjects\' + l_key, 'InstallDir', Value);
  {$ELSE}
  exit Value;
  {$ENDIF}
end;

end.