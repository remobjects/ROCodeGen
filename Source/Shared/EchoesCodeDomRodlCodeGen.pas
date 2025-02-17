﻿namespace RemObjects.SDK.CodeGen4;

{$IF ECHOES}

interface

uses
  System.CodeDom,
  System.CodeDom.Compiler;

type
  EchoesCodeDomRodlCodeGen = public class(RodlCodeGen)
  private
    method GenerateCodeFromCompileUnit(aUnit: CodeCompileUnit): not nullable String;

    method ConvertRodlLibrary(aLibrary: RodlLibrary): not nullable RemObjects.SDK.Rodl.RodlLibrary;
    begin
      result := new RemObjects.SDK.Rodl.RodlLibrary();
      result.LoadFromString(aLibrary.ToString());
      result.FileName := aLibrary.Filename;
    end;

  protected
    method GetIncludesNamespace(aLibrary: RodlLibrary): String; override;
    begin
      if assigned(aLibrary.Includes) then exit aLibrary.Includes.NetModule;
      exit inherited GetIncludesNamespace(aLibrary);
    end;
  public
    constructor;

    property Language: String;
    property FullFramework: Boolean := true;
    property AsyncSupport: Boolean := true;
    property CodeUnitSupport: Boolean := False;override;

    method GetCodeDomProviderForLanguage: nullable CodeDomProvider;

    method GetGlobalName(aLibrary: RodlLibrary): String; override;
    method GenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; override;
    method GenerateInvokerFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; override;
    method GenerateLegacyEventsFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
    method GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>; override;
  end;

implementation

uses
  RemObjects.SDK.Rodl,
  RemObjects.SDK.Rodl.CodeGen;

constructor EchoesCodeDomRodlCodeGen;
begin
end;

method EchoesCodeDomRodlCodeGen.GetGlobalName(aLibrary: RodlLibrary): String;
begin
  exit aLibrary.Name+"_Defines";
end;

method EchoesCodeDomRodlCodeGen.GenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  var lCodegen := new CodeGen_Intf();

  var lRodl := self.ConvertRodlLibrary(aLibrary);

  var lUnit := lCodegen.GenerateCompileUnit(lRodl, coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, GetNamespace(aLibrary)), FullFramework, AsyncSupport, false);

  result := GenerateCodeFromCompileUnit(lUnit);
end;

method EchoesCodeDomRodlCodeGen.GenerateInvokerFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String): not nullable String;
begin
  var lCodegen := new CodeGen_Invk();

  var lRodl := self.ConvertRodlLibrary(aLibrary);

  var lUnit := lCodegen.GenerateCompileUnit(lRodl, coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, GetNamespace(aLibrary)), FullFramework, AsyncSupport);

  result := GenerateCodeFromCompileUnit(lUnit);
end;

method EchoesCodeDomRodlCodeGen.GenerateLegacyEventsFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  result := '';
end;

method EchoesCodeDomRodlCodeGen.GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>;
begin
  var lCodegen := new CodeGen_Impl();

  var lRodl := self.ConvertRodlLibrary(aLibrary);
  var lService := RemObjects.SDK.Rodl.RodlService(lRodl.Services.FindEntity(aServiceName));
  var lUnit: CodeCompileUnit;
  if assigned(lService) then
    lUnit := lCodegen.GenerateCompileUnit(lService, coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, GetNamespace(aLibrary)), FullFramework)
  else
    lUnit := lCodegen.GenerateCompileUnit(lRodl, aTargetNamespace, FullFramework, AsyncSupport);

  var lunitname := aServiceName + '_Impl.'+GetCodeDomProviderForLanguage().FileExtension;
  result := new Dictionary<String,String>;
  result.Add(lunitname, GenerateCodeFromCompileUnit(lUnit));
end;


method EchoesCodeDomRodlCodeGen.GetCodeDomProviderForLanguage(): nullable CodeDomProvider;
begin
  var lLookingForCodeDomName: String;
  try
    case Language:ToLowerInvariant() of
      'oxygene','pas': begin
          lLookingForCodeDomName := 'Oxygene';
          result := CodeDomProvider.CreateProvider("Oxygene");
        end;
      'hydrogene','cs','c#', 'standard-c#': begin
          result := new Microsoft.CSharp.CSharpCodeProvider();
        end;
      'silver', 'swift': begin
          lLookingForCodeDomName := 'Silver';
          result := CodeDomProvider.CreateProvider("Silver");
        end;
      'iodide', 'java': begin
          lLookingForCodeDomName := 'Iodine';
          result := CodeDomProvider.CreateProvider("Iodine");
        end;
      'mercury', 'vb','visualbasic','visual basic', 'standard-vb': begin
          result := new Microsoft.VisualBasic.VBCodeProvider();
        end;
    end;
  except
    on E: System.Configuration.ConfigurationException do begin
      result := nil;
    end;
  end;

  if not assigned(result) then begin
    //Console.WriteLine(Language:ToLowerInvariant());
    //Console.WriteLine("Known CodeDom providers:");
    for each p in CodeDomProvider.GetAllCompilerInfo do begin
      //Console.Write("  ");
      for each l in p.GetLanguages {index i} do begin
        //if i > 0 then Console.Write(", ");
        if (result = nil) and (l = lLookingForCodeDomName) then
          result := p.CreateProvider();
        //Console.Write(l);
      end;
      //Console.WriteLine();
    end;
  end;
end;


method EchoesCodeDomRodlCodeGen.GenerateCodeFromCompileUnit(aUnit: CodeCompileUnit): not nullable String;
begin
  var lProvider := GetCodeDomProviderForLanguage();
  if not assigned(lProvider) then
    raise new Exception("CodeDom Provider for "+Language+" not found");
  using lWriter := new System.IO.StringWriter() do begin
    lProvider.GenerateCodeFromCompileUnit(aUnit, lWriter, new CodeGeneratorOptions());
    lWriter.Flush();
    exit lWriter.GetStringBuilder().ToString() as not nullable;
  end;
end;

{$ENDIF}

end.