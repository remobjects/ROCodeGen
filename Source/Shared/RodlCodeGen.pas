namespace RemObjects.SDK.CodeGen4;

interface

uses
  RemObjects.Elements.RTL;

type
  RodlCodeGen = public abstract class
  protected
    CodeGenTypes := new Dictionary<String, CGTypeReference>;
    CodeGenTypeDefaults := new Dictionary<String, CGExpression>;
    ReaderFunctions: Dictionary<String, String>:= new Dictionary<String, String>;
    ReservedWords: List<String> := new List<String>;
    PredefinedTypes: Dictionary<CGPredefinedTypeKind, CGTypeReference>:= new Dictionary<CGPredefinedTypeKind, CGTypeReference>;
    property targetNamespace: String;

    {$REGION support methods}
    method ResolveDataTypeToTypeRef(aLibrary: RodlLibrary; aDataType: String): CGTypeReference; virtual;
    method ResolveDataTypeToDefaultExpression(aLibrary: RodlLibrary; aDataType: String): CGExpression;
    method ResolveStdtypes(aType: CGPredefinedTypeReference; isNullable: Boolean := false; isNotNullable: Boolean := false; isPointer: Boolean := false): CGTypeReference;
    method EntityNeedsCodeGen(aEntity: RodlEntity): Boolean;
    method PascalCase(name:String):String;
    method isStruct(aLibrary: RodlLibrary; aDataType: String): Boolean;
    method isEnum(aLibrary: RodlLibrary; aDataType: String): Boolean;
    method isArray(aLibrary: RodlLibrary; aDataType: String): Boolean;
    method isException(aLibrary: RodlLibrary; aDataType: String): Boolean;
    method isComplex(aLibrary: RodlLibrary; aDataType: String): Boolean; virtual;
    method isBinary(aDataType: String): Boolean;
    method IsAnsiString(aDataType: String): Boolean;
    method IsUTF8String(aDataType: String): Boolean;

    method FindEnum(aLibrary: RodlLibrary; aDataType: String): nullable RodlEnum;

    method SafeIdentifier(aValue: String): String;
    method EscapeString(aString:String):String;
    method Operation_GetAttributes(aLibrary: RodlLibrary; aOperation: RodlOperation): Dictionary<String,String>;
    method GenerateEnumMemberName(aLibrary: RodlLibrary; aEntity: RodlEnum; member: RodlEnumValue): String;
    method CleanedWsdlName(aName: String): String;
    method IsServerSideAttribute(aName: String): Boolean;
    begin
      case aName.ToLowerInvariant of
        'httpapipath',
        'httpapiresult',
        'httpapimethod',
        'httpapitags',
        'httpapioperationid',
        'httpapirequestname',
        'roservicegroups': exit true;
      else
        exit false;
      end;
    end;
    {$ENDREGION}

    method GenerateDocumentation(aEntity: RodlEntity): CGXmlDocumentationStatement; virtual;
    property DocumentationBeginTag: String := '<summary>'; virtual;
    property DocumentationEndTag: String := '</summary>'; virtual;

    method DoGenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; virtual;
    method AddUsedNamespaces(file: CGCodeUnit; aLibrary: RodlLibrary);virtual; empty;
    method AddGlobalConstants(file: CGCodeUnit; aLibrary: RodlLibrary);virtual; empty;
    method GenerateEnum(file: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum); virtual;
    method GenerateStruct(file: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);virtual; empty;
    method GenerateArray(file: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);virtual; empty;
    method GenerateException(file: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);virtual; empty;
    method GenerateService(file: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);virtual; empty;
    method GenerateEventSink(file: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);virtual; empty;
    method GenerateUnitComment(isImpl: Boolean): CGCommentStatement; virtual;
    method GetNamespace(aLibrary: RodlLibrary): String; virtual;
    method GetIncludesNamespace(aLibrary: RodlLibrary): String; virtual; empty;
    method GetGlobalName(aLibrary: RodlLibrary): String; abstract;

    property EnumBaseType: CGTypeReference read ResolveStdtypes(CGPredefinedTypeReference.UInt32); virtual;

    method GetInOutParameters(aEntity: RodlOperation): tuple of (List<RodlParameter>, List<RodlParameter>);
    begin
      var lInParameters := new List<RodlParameter>;
      var lOutParameters := new List<RodlParameter>;
      for p: RodlParameter in aEntity.Items do begin
        if p.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
          lInParameters.Add(p);
        if p.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
          lOutParameters.Add(p);
      end;
      result := (lInParameters, lOutParameters);
    end;
    method GenerateTypeExpression(aName: String): CGExpression;
    begin
      exit aName.AsNamedIdentifierExpression;
      //exit aName.AsTypeReferenceExpression;
    end;
  public
    class property KnownRODLPaths: Dictionary<String,String> := new Dictionary<String,String>;
    property Generator: CGCodeGenerator; virtual;
    property DontPrefixEnumValues: Boolean := True; virtual;
    property CodeUnitSupport: Boolean := True; virtual;
    property ExcludeServices: Boolean := false; // works for Intf generation only!
    property ExcludeEventSinks: Boolean := false; // works for Intf generation only!
    property ExcludeClasses: Boolean := false; //works for Intf generation only!
    property RodlFileName: String :='';
    property GenerateDocumentation: Boolean := True; virtual;

    method GenerateInterfaceCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; virtual;

    method GenerateInvokerCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; virtual;
    begin
      raise new Exception("not supported");
    end;

    method GenerateImplementationCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit; virtual;
    begin
      raise new Exception("not supported");
    end;


    method GenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; virtual;
    method GenerateInvokerFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; virtual;
    method GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>;virtual;


    method GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; virtual;
    begin
      raise new Exception("not supported");
    end;

    method GenerateInvokerFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; virtual;
    begin
      raise new Exception("not supported");
    end;

    method GenerateImplementationFiles(file: CGCodeUnit; aLibrary: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;virtual;
    begin
      raise new Exception("not supported");
    end;
  end;

  CompareFunc<T,U> = method(Value:T):U;

extension method List<T>.Sort_OrdinalIgnoreCase(cond: CompareFunc<T,String>): List<T>;assembly;
implementation

extension method List<T>.Sort_OrdinalIgnoreCase(cond: CompareFunc<T,String>): List<T>;
begin
  var r:= new List<T>;
  r.Add(Self);
  r.Sort((x,y)-> begin
                  var x1 := cond(x);
                  var y1 := cond(y);
                  if (x1 = nil) and (y1 = nil) then exit 0;
                  if (x1 = nil) then exit -1;
                  if (y1 = nil) then exit 1;
                  x1 := x1.ToUpperInvariant;
                  y1 := y1.ToUpperInvariant;
                  var min_length := iif(x1.Length > y1.Length, y1.Length, x1.Length);
                  for i: Integer :=0 to min_length-1 do begin
                    if x1[i] > y1[i] then exit 1;
                    if x1[i] < y1[i] then exit -1;
                  end;
                  exit x1.Length - y1.Length;
                 end);
  exit r;
end;


method RodlCodeGen.GenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  aLibrary.Validate;
  exit Generator.GenerateUnit(GenerateInterfaceCodeUnit(aLibrary, aTargetNamespace, aUnitName));
end;

{$REGION support methods}

method RodlCodeGen.EntityNeedsCodeGen(aEntity: RodlEntity): Boolean;
begin
  if aEntity.DontCodegen then exit false;
  Result := not (aEntity.IsFromUsedRodl or (aEntity.FromUsedRodlId ≠ Guid.Empty));

  if (not Result) then begin
    Result := (aEntity.FromUsedRodl = nil);
    if (not Result) then Result := not aEntity.FromUsedRodl.DontApplyCodeGen;
  end;

end;

method RodlCodeGen.PascalCase(name: String): String;
begin
  case name:Length of
    0: Result := '';
    1: Result := name.ToUpperInvariant;
  else
    Result := name.Substring(0,1).ToUpperInvariant + name.Substring(1);
  end;
end;

method RodlCodeGen.isStruct(aLibrary: RodlLibrary; aDataType: String): Boolean;
begin
  var lEntity: RodlEntity := aLibrary.FindEntity(aDataType);
  exit assigned(lEntity) and (lEntity is RodlStruct);
end;

method RodlCodeGen.isEnum(aLibrary: RodlLibrary; aDataType: String): Boolean;
begin
  var lEntity: RodlEntity := aLibrary.FindEntity(aDataType);
  exit assigned(lEntity) and (lEntity is RodlEnum);
end;

method RodlCodeGen.FindEnum(aLibrary: RodlLibrary; aDataType: String): nullable RodlEnum;
begin
  var lEntity: RodlEntity := aLibrary.FindEntity(aDataType);
  result := RodlEnum(lEntity);
end;

method RodlCodeGen.isArray(aLibrary: RodlLibrary; aDataType: String): Boolean;
begin
  var lEntity: RodlEntity := aLibrary.FindEntity(aDataType);
  exit (assigned(lEntity) and (lEntity is RodlArray)) or aDataType.ToLowerInvariant.EndsWith("array");
end;

method RodlCodeGen.isException(aLibrary: RodlLibrary; aDataType: String): Boolean;
begin
  var lEntity: RodlEntity := aLibrary.FindEntity(aDataType);
  exit assigned(lEntity) and (lEntity is RodlException);
end;

method RodlCodeGen.isComplex(aLibrary: RodlLibrary; aDataType: String): Boolean;
begin
  if not assigned(aLibrary) then exit false;
  var lEntity: RodlEntity := aLibrary.FindEntity(aDataType);
  exit assigned(lEntity) and (
                              (lEntity is RodlStruct) or
                              (lEntity is RodlArray) or
                              (lEntity is RodlException) or
                              (lEntity is RodlService) or
                              (lEntity is RodlEventSink)
                            );
end;

method RodlCodeGen.SafeIdentifier(aValue: String): String;
begin
  exit iif(ReservedWords.IndexOf(aValue) < 0, aValue , '_' + aValue);
end;

method RodlCodeGen.EscapeString(aString: String): String;
begin
  exit aString.Replace('\','\\').Replace('"','\"');
end;

method RodlCodeGen.ResolveStdtypes(aType: CGPredefinedTypeReference; isNullable: Boolean := false; isNotNullable: Boolean := false; isPointer: Boolean := false): CGTypeReference;
begin
  if PredefinedTypes.ContainsKey(aType.Kind) then
    exit PredefinedTypes[aType.Kind]
  else if isPointer then
    exit new CGPointerTypeReference(aType)
  else if isNullable then
    exit aType.NullableNotUnwrapped
  else if isNotNullable then
    exit aType.NotNullable
  else
    exit aType
end;

method RodlCodeGen.ResolveDataTypeToTypeRef(aLibrary: RodlLibrary; aDataType: String): CGTypeReference;
begin
  var lLower := aDataType.ToLowerInvariant();
  if CodeGenTypes.ContainsKey(lLower) then
    exit CodeGenTypes[lLower]
  else
    exit aDataType.AsTypeReference(not isEnum(aLibrary, aDataType));
end;

method RodlCodeGen.ResolveDataTypeToDefaultExpression(aLibrary: RodlLibrary; aDataType: String): CGExpression;
begin
  var lLower := aDataType.ToLowerInvariant();
  if CodeGenTypeDefaults.ContainsKey(lLower) then
    exit CodeGenTypeDefaults[lLower]
  else if isEnum(aLibrary, aDataType) then
    exit new CGTypeCastExpression(0.AsLiteralExpression, ResolveDataTypeToTypeRef(aLibrary, aDataType))
  else
    exit CGNilExpression.Nil;
end;

method RodlCodeGen.Operation_GetAttributes(aLibrary: RodlLibrary; aOperation: RodlOperation): Dictionary<String, String>;
begin
  result := new Dictionary<String,String>;
  for k: String in aOperation.CustomAttributes.Keys do
    result[k] := aOperation.CustomAttributes[k];

  for k: String in aOperation.Owner.Owner.CustomAttributes.Keys do
    result[k] := aOperation.Owner.Owner.CustomAttributes[k];

  for k: String in aLibrary.CustomAttributes.Keys do
    result[k] := aLibrary.CustomAttributes[k];
end;

method RodlCodeGen.isBinary(aDataType: String): Boolean;
begin
  exit aDataType.EqualsIgnoringCaseInvariant('binary');
end;

method RodlCodeGen.IsAnsiString(aDataType: String): Boolean;
begin
  exit aDataType.EqualsIgnoringCaseInvariant('AnsiString');
end;

method RodlCodeGen.IsUTF8String(aDataType: String): Boolean;
begin
  exit aDataType.EqualsIgnoringCaseInvariant('UTF8String');
end;

method RodlCodeGen.CleanedWsdlName(aName: String): String;
begin
  if aName.StartsWith('___') then aName := aName.Substring(3);
  result := aName;
end;
{$ENDREGION}

method RodlCodeGen.GenerateEnum(file: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var lenum := new CGEnumTypeDefinition(SafeIdentifier(aEntity.Name),
                                       Visibility := CGTypeVisibilityKind.Public,
                                       BaseType := EnumBaseType);
  lenum.XmlDocumentation := GenerateDocumentation(aEntity);
  file.Types.Add(lenum);
  for enummember: RodlEnumValue in aEntity.Items index i do begin
    var lname := GenerateEnumMemberName(aLibrary, aEntity, enummember);
    var lenummember :=new CGEnumValueDefinition(lname, i.AsLiteralExpression);
    lenummember.XmlDocumentation := GenerateDocumentation(enummember);
    lenum.Members.Add(lenummember);
  end;
end;

method RodlCodeGen.GenerateUnitComment(isImpl: Boolean): CGCommentStatement;
begin
  var list:= New List<String>;
  if isImpl then begin
    list.Add("---------------------------------------------------------------------------");
    list.Add(" This file was automatically generated by Remoting SDK from a");
    list.Add(" RODL file downloaded from a server or associated with this project.");
    list.Add("");
    list.Add(" This is where you are supposed to code the implementation of your objects.");
    list.Add("---------------------------------------------------------------------------");
  end
  else begin
    list.Add("---------------------------------------------------------------------------");
    list.Add(" This file was automatically generated by Remoting SDK from a");
    list.Add(" RODL file downloaded from a server or associated with this project.");
    list.Add("");
    list.Add(" Do not modify this file manually, or your changes will be lost when");
    list.Add(" it is regenerated the next time you update your RODL.");
    list.Add("---------------------------------------------------------------------------");
  end;

  exit new CGCommentStatement(list);
end;

method RodlCodeGen.GenerateInvokerFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  aLibrary.Validate;
  exit Generator.GenerateUnit(GenerateInvokerCodeUnit(aLibrary, aTargetNamespace, aUnitName));
end;

method RodlCodeGen.GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String, String>;
begin
  aLibrary.Validate;
  var lunit := GenerateImplementationCodeUnit(aLibrary, aTargetNamespace, aServiceName);
  exit GenerateImplementationFiles(lunit, aLibrary, aServiceName);
end;

method RodlCodeGen.GenerateEnumMemberName(aLibrary: RodlLibrary; aEntity: RodlEnum; member: RodlEnumValue): String;
begin
  if DontPrefixEnumValues then
    exit SafeIdentifier(member.Name)
  else
    exit SafeIdentifier(iif(aEntity.PrefixEnumValues, aEntity.Name+'_','')+ member.Name);
end;

method RodlCodeGen.DoGenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit;
begin
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, GetNamespace(aLibrary));
  result := new CGCodeUnit();
  result.Namespace := new CGNamespaceReference(targetNamespace);
  result.HeaderComment := GenerateUnitComment(False);
  result.FileName := aUnitName;

  AddUsedNamespaces(result, aLibrary);

  AddGlobalConstants(result, aLibrary);

  {$region Collect custom attributes on the rodl level}
  var lLibraryCustomAttributes := new Dictionary<String, String>();
  for key: String  in aLibrary.CustomAttributes.Keys do
    lLibraryCustomAttributes.Add(key, aLibrary.CustomAttributes[key]);
  {$endregion}

  if not ExcludeClasses then begin
    {$region Generate Enums}
    for aEntity: RodlEnum in aLibrary.Enums.Items.OrderBy(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      GenerateEnum(result, aLibrary, aEntity);
    end;
    {$endregion}

    {$region Generate Structs}
    for aEntity: RodlStruct in aLibrary.Structs.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      GenerateStruct(result, aLibrary, aEntity);
    end;
    {$endregion}

    {$region Generate Arrays}
    for aEntity: RodlArray  in aLibrary.Arrays.Items.OrderBy(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      GenerateArray(result, aLibrary, aEntity);
    end;
    {$endregion}

    {$region Generate Exception}
    for aEntity: RodlException in aLibrary.Exceptions.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      GenerateException(result, aLibrary, aEntity);
    end;
    {$endregion}
  end;

  if not ExcludeServices then begin
    {$region Generate Services}
    for aEntity: RodlService in aLibrary.Services.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      GenerateService(result, aLibrary, aEntity);
    end;
    {$endregion}
  end;

  if not ExcludeEventSinks then begin
    {$region Generate EventSinks}
    for aEntity: RodlEventSink in aLibrary.EventSinks.Items.OrderBy(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      GenerateEventSink(result, aLibrary, aEntity);
    end;
    {$endregion}
  end;
end;

method RodlCodeGen.GetNamespace(aLibrary: RodlLibrary): String;
begin
  result := aLibrary.Namespace;
  if String.IsNullOrWhiteSpace(result) then result := aLibrary.Name;
end;

method RodlCodeGen.GenerateInterfaceCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String): CGCodeUnit;
begin
  aLibrary.Validate;
  exit DoGenerateInterfaceFile(aLibrary, coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, GetNamespace(aLibrary)), aUnitName);
end;

method RodlCodeGen.GenerateDocumentation(aEntity: RodlEntity): CGXmlDocumentationStatement;
begin
  if GenerateDocumentation and not String.IsNullOrEmpty(aEntity.Documentation) then begin
    var list := new List<String>;
    if not String.IsNullOrEmpty(DocumentationBeginTag) then list.Add(DocumentationBeginTag);
    list.Add(aEntity.Documentation);
    if not String.IsNullOrEmpty(DocumentationEndTag) then list.Add(DocumentationEndTag);
    exit new CGXmlDocumentationStatement(String.Join(#10, list));
  end
  else
    exit nil;
end;



end.