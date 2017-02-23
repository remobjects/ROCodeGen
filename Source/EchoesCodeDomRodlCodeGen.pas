namespace RemObjects.SDK.CodeGen4;

interface

uses
  System.CodeDom,
  System.CodeDom.Compiler;

type
  EchoesCodeDomRodlCodeGen = public class(RodlCodeGen)
  private
    method GenerateCodeFromCompileUnit(aUnit: CodeCompileUnit): not nullable String;
  protected
  public
    constructor;

    property Language: String;
    property FullFramework: Boolean := true;
    property AsyncSupport: Boolean := true;
    property CodeUnitSupport: Boolean := False;override;

    method GetCodeDomProviderForLanguage: nullable CodeDomProvider;

    method GetGlobalName(library: RodlLibrary): String; override;
    method GenerateInterfaceFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; override;
    method GenerateInvokerFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; override;
    method GenerateLegacyEventsFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
    method GenerateImplementationFiles(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>; override;
  end;

implementation

uses
  RemObjects.SDK.Rodl,
  RemObjects.SDK.Rodl.CodeGen;

constructor EchoesCodeDomRodlCodeGen;
begin
end;

method EchoesCodeDomRodlCodeGen.GetGlobalName(library: RodlLibrary): String;
begin
  exit library.Name+"_Defines";
end;

method EchoesCodeDomRodlCodeGen.GenerateInterfaceFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  var lCodegen := new CodeGen_Intf();

  var lRodl := new RemObjects.SDK.Rodl.RodlLibrary();
  lRodl.LoadFromString(library.ToString);

  var lUnit := lCodegen.GenerateCompileUnit(lRodl, aTargetNamespace, FullFramework, AsyncSupport, false);
  result := GenerateCodeFromCompileUnit(lUnit);
end;

method EchoesCodeDomRodlCodeGen.GenerateInvokerFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String): not nullable String;
begin
  var lCodegen := new CodeGen_Invk();

  var lRodl := new RemObjects.SDK.Rodl.RodlLibrary();
  lRodl.LoadFromString(library.ToString);

  var lUnit := lCodegen.GenerateCompileUnit(lRodl, aTargetNamespace, FullFramework, AsyncSupport);
  result := GenerateCodeFromCompileUnit(lUnit);
end;

method EchoesCodeDomRodlCodeGen.GenerateLegacyEventsFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  result := '';
end;

method EchoesCodeDomRodlCodeGen.GenerateImplementationFiles(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>;
begin
  var lCodegen := new CodeGen_Impl();

  var lRodl := new RemObjects.SDK.Rodl.RodlLibrary();
  lRodl.LoadFromString(library.ToString);

  var lUnit := lCodegen.GenerateCompileUnit(lRodl, aTargetNamespace, FullFramework, AsyncSupport);
  var lunitname := aServiceName + '_Impl.'+GetCodeDomProviderForLanguage().FileExtension;
  result := new Dictionary<String,String>;
  result.Add(lunitname, GenerateCodeFromCompileUnit(lUnit));
end;

method EchoesCodeDomRodlCodeGen.GetCodeDomProviderForLanguage: nullable not nullable CodeDomProvider;
begin
  var lLookingForCodeDomName: String;
  try
    case Language:ToLower() of
      'oxygene','pas': begin
          lLookingForCodeDomName := 'Oxygene';
          result := CodeDomProvider.CreateProvider("pas");
        end;
      'hydrogene','cs','c#': begin
          result := new Microsoft.CSharp.CSharpCodeProvider();
        end;
      'silver', 'swift': begin
          lLookingForCodeDomName := 'Silver';
          result := CodeDomProvider.CreateProvider("Silver");
        end;
      'vb','visualbasic','visual basic': begin
          result := new Microsoft.VisualBasic.VBCodeProvider();
        end;
    end;
  except
    on E: System.Configuration.ConfigurationException do begin
      result := nil;
    end;
    end;
  if not assigned(result) then begin

    //Console.WriteLine(Language:ToLower());
    //Console.WriteLine("Known CodeDom providers:");
    for each p in CodeDomProvider.GetAllCompilerInfo do begin
      //Console.Write("  ");
      for each l in p.GetLanguages index i do begin
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

end.