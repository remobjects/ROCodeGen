namespace RemObjects.SDK.CodeGen4;

interface

type
  RodlCodeGen = public abstract class
  protected
    CodeGenTypes: Dictionary<String, CGTypeReference>:= new Dictionary<String, CGTypeReference>;
    ReaderFunctions: Dictionary<String, String>:= new Dictionary<String, String>;
    ReservedWords: List<String> := new List<String>;
    PredefinedTypes: Dictionary<CGPredefinedTypeKind, CGTypeReference>:= new Dictionary<CGPredefinedTypeKind, CGTypeReference>;
    property targetNamespace: String;

    {$REGION support methods}
    method ResolveDataTypeToTypeRef(library: RodlLibrary; dataType: String): CGTypeReference;
    method ResolveStdtypes(&type: CGPredefinedTypeKind; isNullable: Boolean := false; isNotNullable: Boolean := false): CGTypeReference;
    method EntityNeedsCodeGen(entity: RodlEntity): Boolean;
    method PascalCase(name:String):String;
    method isStruct(library: RodlLibrary; dataType: String): Boolean;
    method isEnum(library: RodlLibrary; dataType: String): Boolean;
    method isArray(library: RodlLibrary; dataType: String): Boolean;
    method isException(library: RodlLibrary; dataType: String): Boolean;
    method isComplex(library: RodlLibrary; dataType: String): Boolean; virtual;
    method isBinary(dataType: String): Boolean;
    method IsAnsiString(dataType: String): Boolean;
    method IsUTF8String(dataType: String): Boolean;

    method FindEnum(&library: RodlLibrary; dataType: String): nullable RodlEnum;

    method SafeIdentifier(aValue: String): String;
    method EscapeString(aString:String):String;
    method Operation_GetAttributes(library: RodlLibrary; operation: RodlOperation): Dictionary<String,String>;
    method GenerateEnumMemberName(library: RodlLibrary; entity: RodlEnum; member: RodlEnumValue): String;
    method CleanedWsdlName(aName: String): String;
    {$ENDREGION}

    method GenerateDocumentation(entity: RodlEntity; aGenerateOperationMembersDoc: Boolean := False): CGCommentStatement;
    method DoGenerateInterfaceFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; virtual;
    method AddUsedNamespaces(file: CGCodeUnit; library: RodlLibrary);virtual; empty;
    method AddGlobalConstants(file: CGCodeUnit; library: RodlLibrary);virtual; empty;
    method GenerateEnum(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum); virtual;
    method GenerateStruct(file: CGCodeUnit; library: RodlLibrary; entity: RodlStruct);virtual; empty;
    method GenerateArray(file: CGCodeUnit; library: RodlLibrary; entity: RodlArray);virtual; empty;
    method GenerateException(file: CGCodeUnit; library: RodlLibrary; entity: RodlException);virtual; empty;
    method GenerateService(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);virtual; empty;
    method GenerateEventSink(file: CGCodeUnit; library: RodlLibrary; entity: RodlEventSink);virtual; empty;
    method GenerateUnitComment: CGCommentStatement; virtual;
    method GetNamespace(library: RodlLibrary): String;virtual;
    method GetGlobalName(library: RodlLibrary): String; abstract;

    property EnumBaseType: CGTypeReference read ResolveStdtypes(CGPredefinedTypeKind.UInt32); virtual;
  public
    class property KnownRODLPaths: Dictionary<String,String> := new Dictionary<String,String>;
    property Generator: CGCodeGenerator; virtual;
    property DontPrefixEnumValues: Boolean := false; virtual;
    property CodeUnitSupport: Boolean := True; virtual;

    method GenerateInterfaceCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; virtual;
    method GenerateInvokerCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; virtual;
    method GenerateImplementationCodeUnit(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit; virtual;


    method GenerateInterfaceFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; virtual;
    method GenerateInterfaceFiles(library: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; virtual;
    method GenerateInvokerFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; virtual;
    method GenerateImplementationFiles(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>;virtual;

    method GenerateImplementationFiles(file: CGCodeUnit; library: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;virtual;
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


method RodlCodeGen.GenerateInterfaceFile(&library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  exit Generator.GenerateUnit(GenerateInterfaceCodeUnit(library, aTargetNamespace, aUnitName));
end;


method RodlCodeGen.GenerateInterfaceFiles(library: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>;
begin
  raise new Exception("not supported");
{
  var lunit := DoGenerateInterfaceFile(library, aTargetNamespace);
  result := new Dictionary<String,String>;
  result.Add(lunit.FileName, Generator.GenerateUnit(lunit));
}
end;

{$REGION support methods}

method RodlCodeGen.EntityNeedsCodeGen(entity: RodlEntity): Boolean;
begin
  if entity.DontCodegen then exit false;
  Result := not entity.IsFromUsedRodl;
{
  if (not Result) then begin
    Result := (entity.FromUsedRodl = nil);
    if (not Result) then Result := not entity.FromUsedRodl.DontApplyCodeGen;
  end;
}
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

method RodlCodeGen.isStruct(&library: RodlLibrary; dataType: String): Boolean;
begin
  var lEntity: RodlEntity := library.FindEntity(dataType);
  exit assigned(lEntity) and (lEntity is RodlStruct);
end;

method RodlCodeGen.isEnum(&library: RodlLibrary; dataType: String): Boolean;
begin
  var lEntity: RodlEntity := library.FindEntity(dataType);
  exit assigned(lEntity) and (lEntity is RodlEnum);
end;

method RodlCodeGen.FindEnum(&library: RodlLibrary; dataType: String): nullable RodlEnum;
begin
  var lEntity: RodlEntity := library.FindEntity(dataType);
  result := RodlEnum(lEntity);
end;

method RodlCodeGen.isArray(&library: RodlLibrary; dataType: String): Boolean;
begin
  var lEntity: RodlEntity := library.FindEntity(dataType);
  exit (assigned(lEntity) and (lEntity is RodlArray)) or dataType.ToLowerInvariant.EndsWith("array");
end;

method RodlCodeGen.isException(&library: RodlLibrary; dataType: String): Boolean;
begin
  var lEntity: RodlEntity := library.FindEntity(dataType);
  exit assigned(lEntity) and (lEntity is RodlException);
end;

method RodlCodeGen.isComplex(&library: RodlLibrary; dataType: String): Boolean;
begin
  if not assigned(library) then exit false;
  var lEntity: RodlEntity := library.FindEntity(dataType);
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

method RodlCodeGen.ResolveStdtypes(&type: CGPredefinedTypeKind; isNullable: Boolean := false; isNotNullable: Boolean := false): CGTypeReference;
begin
  if PredefinedTypes.ContainsKey(&type) then
    exit PredefinedTypes[&type]
  else if isNullable then
    exit new CGPredefinedTypeReference(&type).NullableNotUnwrapped
  else if isNotNullable then
    exit new CGPredefinedTypeReference(&type).NotNullable
  else
    exit new CGPredefinedTypeReference(&type)
end;

method RodlCodeGen.ResolveDataTypeToTypeRef(&library: RodlLibrary; dataType: String): CGTypeReference;
begin
  var lLower := dataType.ToLowerInvariant();
  if  CodeGenTypes.ContainsKey(lLower) then
    exit CodeGenTypes[lLower]
  else
    exit dataType.AsTypeReference(not isEnum(library, dataType));
end;

method RodlCodeGen.Operation_GetAttributes(&library: RodlLibrary; operation: RodlOperation): Dictionary<String, String>;
begin
  result := new Dictionary<String,String>;
  for k: String in operation.CustomAttributes.Keys do
    result[k] := operation.CustomAttributes[k];

  for k: String in operation.Owner.Owner.CustomAttributes.Keys do
    result[k] := operation.Owner.Owner.CustomAttributes[k];

  for k: String in library.CustomAttributes.Keys do
    result[k] := library.CustomAttributes[k];
end;

method RodlCodeGen.isBinary(dataType: String): Boolean;
begin
  exit dataType.EqualsIgnoringCaseInvariant('binary');
end;

method RodlCodeGen.IsAnsiString(dataType: String): Boolean;
begin
  exit dataType.EqualsIgnoringCaseInvariant('AnsiString');
end;

method RodlCodeGen.IsUTF8String(dataType: String): Boolean;
begin
  exit dataType.EqualsIgnoringCaseInvariant('UTF8String');
end;

method RodlCodeGen.CleanedWsdlName(aName: String): String;
begin
  if aName.StartsWith('___') then aName := aName.Substring(3);
  result := aName;
end;
{$ENDREGION}

method RodlCodeGen.GenerateEnum(file: CGCodeUnit; &library: RodlLibrary; entity: RodlEnum);
begin
  var lenum := new CGEnumTypeDefinition(SafeIdentifier(entity.Name),
                                       Visibility := CGTypeVisibilityKind.Public,
                                       BaseType := EnumBaseType);
  lenum.Comment := GenerateDocumentation(entity);
  file.Types.Add(lenum);
  for enummember: RodlEnumValue in entity.Items index i do begin
    var lname := GenerateEnumMemberName(library, entity, enummember);
    var lenummember :=new CGEnumValueDefinition(lname, i.AsLiteralExpression);
    lenummember.Comment := GenerateDocumentation(enummember);
    lenum.Members.Add(lenummember);
  end;
end;

method RodlCodeGen.GenerateUnitComment: CGCommentStatement;
begin
  var list:= New List<String>;
  list.Add("----------------------------------------------------------------------");
  list.Add(" This file was automatically generated by Remoting SDK from a");
  list.Add(" RODL file downloaded from a server or associated with this project.");
  list.Add("");
  list.Add(" Do not modify this file manually, or your changes will be lost when");
  list.Add(" it is regenerated the next time you update your RODL.");
  list.Add("----------------------------------------------------------------------");

  exit new CGCommentStatement(list);
end;

method RodlCodeGen.GenerateInvokerFile(&library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  exit Generator.GenerateUnit(GenerateInvokerCodeUnit(library, aTargetNamespace, aUnitName));
end;

method RodlCodeGen.GenerateImplementationFiles(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String, String>;
begin
  var lunit := GenerateImplementationCodeUnit(library, aTargetNamespace, aServiceName);
  exit GenerateImplementationFiles(lunit, library, aServiceName);
end;

method RodlCodeGen.GenerateEnumMemberName(&library: RodlLibrary; entity: RodlEnum; member: RodlEnumValue): String;
begin
  if DontPrefixEnumValues then
    exit SafeIdentifier(member.Name)
  else
    exit SafeIdentifier(iif(entity.PrefixEnumValues,entity.Name+'_','')+ member.Name);
end;

method RodlCodeGen.DoGenerateInterfaceFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit;
begin
  targetNamespace := aTargetNamespace;
  result := new CGCodeUnit();
  result.Namespace := new CGNamespaceReference(targetNamespace);
  result.HeaderComment := GenerateUnitComment;
  result.FileName := aUnitName;
  if String.IsNullOrEmpty(targetNamespace) then targetNamespace := library.Namespace;

  AddUsedNamespaces(result, &library);

  AddGlobalConstants(result, &library);

  {$region Collect custom attributes on the rodl level}
  var lLibraryCustomAttributes := new Dictionary<String, String>();
  for key: String  in library.CustomAttributes.Keys do
    lLibraryCustomAttributes.Add(key, library.CustomAttributes[key]);
  {$endregion}

  {$region Generate Enums}
  for entity: RodlEnum in library.Enums.Items do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    GenerateEnum(result, &library, entity);
  end;
  {$endregion}

  {$region Generate Structs}
  for entity: RodlStruct in library.Structs.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    GenerateStruct(result, &library, entity);
  end;
  {$endregion}

  {$region Generate Arrays}
  for entity: RodlArray  in library.Arrays.Items do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    GenerateArray(result, &library, entity);
  end;
  {$endregion}

  {$region Generate Exception}
  for entity: RodlException in library.Exceptions.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    GenerateException(result, &library, entity);
  end;
  {$endregion}

  {$region Generate Services}
  for entity: RodlService in library.Services.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    GenerateService(result, &library, entity);
  end;
  {$endregion}

  {$region Generate EventSinks}
  for entity: RodlEventSink in library.EventSinks.Items do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    GenerateEventSink(result, &library, entity);
  end;
  {$endregion}
end;

method RodlCodeGen.GetNamespace(library: RodlLibrary): String;
begin
  result := library.Namespace;
  if String.IsNullOrWhiteSpace(result) then result := library.Name;
end;

method RodlCodeGen.GenerateInterfaceCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String): CGCodeUnit;
begin
  var lnamespace := iif(String.IsNullOrEmpty(aTargetNamespace), library.Namespace,aTargetNamespace);
  exit DoGenerateInterfaceFile(library, lnamespace, aUnitName);
end;

method RodlCodeGen.GenerateInvokerCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String): CGCodeUnit;
begin
  raise new Exception("not supported");
end;

method RodlCodeGen.GenerateImplementationCodeUnit(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit;
begin
  raise new Exception("not supported");
end;

method RodlCodeGen.GenerateImplementationFiles(file: CGCodeUnit; library: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;
begin
  raise new Exception("not supported");
end;

method RodlCodeGen.GenerateDocumentation(entity: RodlEntity; aGenerateOperationMembersDoc: Boolean := false): CGCommentStatement;
begin
  var lDoc := entity.Documentation;
  if aGenerateOperationMembersDoc and (entity is RodlOperation) then begin
    var lDoc1:= Environment.LineBreak+'Parameters:';
    var ldocPresent: Boolean := false;
    for op in RodlOperation(entity).Items do begin
      lDoc1 := lDoc1 + Environment.LineBreak + op.Name+':';
      if not String.IsNullOrEmpty(op.Documentation) then begin
        ldocPresent := true;
        lDoc1 := lDoc1 + ' '+op.Documentation;
      end;
    end;
    if ldocPresent then lDoc := lDoc + lDoc1;
  end;
  if not String.IsNullOrEmpty(lDoc) then
    exit new CGCommentStatement( 'Description:'+Environment.LineBreak + lDoc)
  else
    exit nil;
end;


end.