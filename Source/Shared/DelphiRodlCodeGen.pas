namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

type
  ModeKind = public enum (Plain, &Async, AsyncEx);
  State = public enum (Off, &On, Auto);

  DelphiServerAncestor = public enum (Remotable, RemoteDataModule, Custom);

  DelphiRodlCodeGen = public class(RodlCodeGen)
  private
    fIROTransportChannel_typeref: CGTypeReference;
    fIROTransport_typeref: CGTypeReference;
    fIROMessage_typeref: CGTypeReference;
    fCustomAncestor: String;
    fParamAttributes_typeref: CGNamedTypeReference;
    method isDAProject(aLibrary:RodlLibrary): Boolean;
    method GetRODLName(aLibrary:RodlLibrary): String;
    method GenerateGlobalVarName(aName, aUnitName: String): CGExpression;
    {$REGION CodeFirst attributes}
    property CF_condition: CGConditionalDefine;
    property CF_condition_inverted: CGConditionalDefine;
    property attr_ROSerializeAsAnsiString: CGAttribute;
    property attr_ROSerializeAsUTF8String: CGAttribute;
    property attr_ROServiceMethod: CGAttribute;
    property attr_ROEventSink: CGAttribute;
    property attr_ROSkip: CGAttribute;
    property attr_ROLibraryAttributes: CGAttribute;
    property attr_ROAbstract: CGAttribute;
    property cond_ROUseGenerics: CGConditionalDefine;
    property cond_ROUseGenerics_inverted: CGConditionalDefine;
    method AddCGAttribute(aType: CGEntity; anAttribute:CGAttribute);
    method GenerateCodeFirstDocumentation(aFile: CGCodeUnit; aName: String; aType: CGEntity; aDoc: String);
    method GenerateCodeFirstCustomAttributes(aType: CGEntity; aEntity:RodlEntity; aExcludeServiceGroups: Boolean := true);
    method GetHttpAPIAttribute(aEntity: RodlEntity): CGAttribute;
    {$ENDREGION}
    {$REGION support methods}
    method IsHttpAPIAttribute(aName: String): Boolean;
    method isPresent_SerializeInitializedStructValues_Attribute(aLibrary: RodlLibrary): Boolean;
    method GetServiceAncestor(aLibrary: RodlLibrary;aEntity: RodlService): String;
    {$ENDREGION}
    method Intf_ProcessAttributes(aEntity: RodlEntity; aType: CGClassTypeDefinition; AlwaysWrite: Boolean := false);
    method GenerateAttributes(aLibrary: RodlLibrary; aService: RodlService; aOperation:RodlOperation; out aNames, aValues: List<CGExpression>);
    method set_CustomAncestor(value: String);
    method get_IROTransportChannel_typeref: CGTypeReference;
    method get_IROMessage_typeref: CGTypeReference;
    method get_IROTransport_typeref: CGTypeReference;
    method GenerateParamAttributes(aName: String):CGSetLiteralExpression;
    method IsCodeFirstCompatible: Boolean;
    method IsGenericArrayCompatible: Boolean;
    method GenerateExternalSym(globalvar: CGGlobalVariableDefinition);
    method DoGenerateDFM(service: RodlService): String;
  protected
    fLegacyStrings: Boolean := false;
    method _SetLegacyStrings(value: Boolean); virtual;
    property PureDelphi: Boolean read true; virtual;
    property Intf_name: String;
    property Invk_name: String;
    property Impl_name: String;
    property LibraryAttributes: CGClassTypeDefinition;
    property IROMessage_typeref: CGTypeReference read get_IROMessage_typeref;
    property IROTransportChannel_typeref: CGTypeReference read get_IROTransportChannel_typeref;
    property IROTransport_typeref: CGTypeReference read get_IROTransport_typeref;
    {$REGION support methods}
    method RODLParamFlagToCodegenFlag(aFlag: ParamFlags): CGParameterModifierKind;
    method ResolveDataTypeToTypeRefFullQualified(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String := ""; aCapitalize: Boolean := false): CGTypeReference; virtual;
    method ResolveNamespace(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String := ""; aCapitalize: Boolean := false): String;
    method CapitalizeString(aValue: String):String;virtual;
    method DuplicateType(aTypeRef: CGTypeReference; isClass: Boolean): CGTypeReference;
    method CreateCodeFirstAttributes;
    method GenerateDestroyExpression(aExpr: CGExpression):CGStatement;
    {$ENDREGION}

    method Add_RemObjects_Inc(aFile: CGCodeUnit; aLibrary: RodlLibrary); virtual;
    {$REGION generate _Intf}
    method Intf_GenerateDefaultNamespace(aFile: CGCodeUnit; aLibrary: RodlLibrary);
    method Intf_GenerateInterfaceImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
    method Intf_GenerateImplImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
    method Intf_GenerateLibraryAttributes(aFile: CGCodeUnit; aLibrary: RodlLibrary);
    method Intf_GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
    method Intf_GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
    method Intf_GenerateStructCollection(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);

    method Intf_GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
    method Intf_GenerateArray_Grow: CGMethodDefinition;
    method Intf_GenerateArray_GetItems(aElementType: CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_SetItems(aElementType: CGTypeReference; aComplex: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_GetCount: CGMethodDefinition;
    method Intf_GenerateArray_IntResize(aElementType: CGTypeReference; aComplex: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_GetItemType(aLibrary: RodlLibrary; aElementType: CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_GetItemClass(aElementType: CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_GetItemSize(aElementType: CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_GetItemRef(aComplex: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_SetItemRef(aElementType: CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_Clear(aComplex: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_Delete(aComplex: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_Assign(aLibrary: RodlLibrary; aArrayType, aElementType: CGTypeReference; elType: String; aComplex: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_ReadComplex(aLibrary: RodlLibrary;aElementType: CGTypeReference; elType: String): CGMethodDefinition;
    method Intf_GenerateArray_WriteComplex(aLibrary: RodlLibrary; aArrayType, aElementType: CGTypeReference; elType: String): CGMethodDefinition;
    method Intf_GenerateArray_Add(aElementType: CGTypeReference; aComplex: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_GetIndex(aElementType: CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_GetIndex1: CGMethodDefinition;
    method Intf_GenerateArray_IndexOf(aElementType: CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_Add1(aElementType: CGTypeReference; aIsException: Boolean): CGMethodDefinition;
    method Intf_GenerateArray_GetEnumerator(aEnumeratorType:CGTypeReference): CGMethodDefinition;
    method Intf_GenerateArray_Count: CGPropertyDefinition;
    method Intf_GenerateArray_Items(aElementType: CGTypeReference): CGPropertyDefinition;
    method Intf_GenerateArray_InnerArray(aInnerArrayType: CGTypeReference): CGPropertyDefinition;

    method Intf_GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
    method Intf_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_I(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_I_Async(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_I_AsyncEx(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_Co(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_Co_Async(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_Co_AsyncEx(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_T_Proxy(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_T_AsyncProxy(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateService_T_AsyncProxyEx(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
    method Intf_GenerateRead(aFile: CGCodeUnit; aLibrary: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>;aSerializeInitializedStructValues:Boolean; aSerializer: CGExpression);
    method Intf_GenerateWrite(aFile: CGCodeUnit; aLibrary: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>;aSerializeInitializedStructValues:Boolean; aSerializer: CGExpression);

    method Intf_GenerateAsyncInvoke(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody:  Boolean; isInterface: Boolean): CGMethodDefinition;
    method Intf_GenerateAsyncRetrieve(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody:  Boolean; isInterface: Boolean): CGMethodDefinition;
    method Intf_GenerateAsyncExBegin(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody:  Boolean; aMethod:Boolean; isInterface: Boolean): CGMethodDefinition;
    method Intf_GenerateAsyncExEnd(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody:  Boolean; isInterface: Boolean): CGMethodDefinition;

    method Intf_generateReadStatement(aLibrary: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType: CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
    method Intf_generateWriteStatement(aLibrary: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType:CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
    {$ENDREGION}
    {$REGION generate _Invk}
    method Invk_GenerateInterfaceImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
    method Invk_GenerateImplImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
    method Invk_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Invk_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
    method Invk_GetDefaultServiceRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); virtual;
    method Invk_CheckRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); virtual;
    method Invk_RemapParameters(aMessage: CGParameterAccessExpression; aParamNames:CGArrayLiteralExpression):CGStatement; virtual;
    method NeedsAsyncRetrieveOperationDefinition(aEntity: RodlOperation): Boolean;
    {$ENDREGION}
    {$REGION generate _Impl}
    method Impl_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Impl_GenerateDFMInclude(aFile: CGCodeUnit);virtual;
    method Impl_CreateClassFactory(aLibrary: RodlLibrary; aEntity: RodlService; lvar: CGExpression): List<CGStatement>;virtual;
    method Impl_GenerateCreateService(aMethod: CGMethodDefinition;aCreator: CGNewInstanceExpression);virtual;
    method cpp_Impl_constructor(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); virtual; empty;
    {$ENDREGION}
    {$REGION cpp support}
    method cpp_SetAttributes(aList: List<CGStatement>; aMessage, aChannel: CGLocalVariableAccessExpression;aNames, aValues: List<CGExpression>); virtual;
    begin
      aList.Add(new CGMethodCallExpression(aMessage, "SetAttributes", [aChannel.AsCallParameter,
                                                                      new CGArrayLiteralExpression(aNames,  ResolveStdtypes(CGPredefinedTypeReference.String)).AsCallParameter,
                                                                      new CGArrayLiteralExpression(aValues, ResolveStdtypes(CGPredefinedTypeReference.String)).AsCallParameter].ToList,
                                                    CallSiteKind := CGCallSiteKind.Reference));
    end;
    method cpp_StoreAttributes2(aList: List<CGStatement>; aMessage: CGLocalVariableAccessExpression;aNames, aValues: List<CGExpression>); virtual;
    begin
      aList.Add(new CGMethodCallExpression(aMessage,"StoreAttributes2",[
                                                            new CGArrayLiteralExpression(aNames,  ResolveStdtypes(CGPredefinedTypeReference.String)).AsCallParameter,
                                                            new CGArrayLiteralExpression(aValues, ResolveStdtypes(CGPredefinedTypeReference.String)).AsCallParameter].ToList,
                                          CallSiteKind := CGCallSiteKind.Reference));
    end;
    method cpp_GetTROAsyncCallbackType: String;virtual;
    method cpp_GetTROAsyncCallbackMethodType: String;virtual;
    method cpp_smartInit(aFile: CGCodeUnit);virtual; empty;
    method cpp_GenerateAsyncAncestorMethodCalls(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); virtual; empty;
    method cpp_GenerateAncestorMethodCalls(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition; aMode: ModeKind); virtual; empty;
    method cpp_GenerateProxyConstructors(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); virtual; empty;
    method cppGenerateEnumTypeInfo(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);virtual;
    method cpp_IUnknownSupport(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); virtual; empty;

    method cppGenerateProxyCast(aProxy: CGNewInstanceExpression; aInterface: CGNamedTypeReference):List<CGStatement>;virtual;
    method cpp_generateDoLoginNeeded(aType: CGClassTypeDefinition);virtual;empty;
    method cpp_Pointer(value: CGExpression): CGExpression;virtual;
    method cpp_AddressOf(value: CGExpression): CGExpression;virtual;
    method cpp_GenerateArrayDestructor(anArray: CGTypeDefinition); virtual; empty;
    method cpp_DefaultNamespace:CGExpression;virtual;
    method cpp_GetNamespaceForUses(aUse: RodlUse):String;virtual;
    method cpp_GlobalCondition_ns:CGConditionalDefine;virtual;empty;
    method cpp_GlobalCondition_ns_name: String; virtual; empty;
    {$ENDREGION}
  protected
    //method AddDynamicArrayParameter(aMethod:CGMethodCallExpression; aDynamicArrayParam: CGExpression); virtual;
    method AddMessageDirective(aMessage: String): CGStatement; virtual;
    property CanUseNameSpace: Boolean := false; virtual;
    method GenerateTypeInfoCall(aLibrary: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression; virtual;
    method Array_SetLength(anArray, aValue: CGExpression): CGExpression; virtual;
    method Array_GetLength(anArray: CGExpression): CGExpression; virtual;
    method RaiseError(aMessage:CGExpression; aParams:List<CGExpression>): CGStatement;virtual;
    method AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary); override;
    method GlobalsConst_GenerateServerGuid(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService); virtual;
    method isComplex(aLibrary: RodlLibrary; aDataType: String): Boolean; override;
    method GetIncludesNamespace(aLibrary: RodlLibrary): String; override;
    method GetGlobalName(aLibrary: RodlLibrary): String; override; empty;

    method ResolveInterfaceTypeRef(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String := ""; aCapitalize: Boolean := false): CGNamedTypeReference; virtual;
    /// returns boolean type
    method InterfaceCast(aSource, aType, aDest: CGExpression): CGExpression; virtual;

    method cpp_pragmalink(aFile: CGCodeUnit; aUnitName: String); virtual; empty;
    method cpp_ClassId(anExpression: CGExpression): CGExpression; virtual;
    method cpp_UuidId(anExpression: CGExpression): CGExpression; virtual;
    method GenerateCGImport(aName: String; aCondition: CGConditionalDefine): CGImport;
    method GenerateCGImport(aName: String; aNamespace: String := ""; aExt: String := "hpp"; aCapitalize: Boolean = true): CGImport; virtual;
    method GenerateIsClause(aSource: CGExpression; aType: CGTypeReference):CGExpression;
  public
    constructor;
    // generate full qualified names for own types (not from used rodls)
    property IncludeUnitNameForOwnTypes: Boolean := false;
    // generate full qualified names for not own types (from used rodls)
    property IncludeUnitNameForOtherTypes: Boolean := true;
    // default ancestor is TRORemoteDataModule, also generate .dfm
    property DefaultServerAncestor: DelphiServerAncestor := DelphiServerAncestor.RemoteDataModule;
    property CustomAncestor: String read fCustomAncestor write set_CustomAncestor;
    property CustomUses: String;
    property DontPrefixEnumValues: Boolean := false; override;
    // include {$SCOPEDENUMS ON} into _Intf
    property ScopedEnums: Boolean := false;
    property IsHydra:Boolean := false;
    method isDFMNeeded: Boolean;

    property GenerateDFMs: Boolean := true;
    property LegacyStrings: Boolean read fLegacyStrings write _SetLegacyStrings;

    property DelphiXE2Mode: State := State.Auto; virtual;
    property FPCMode: State := State.Auto; virtual;
    property CodeFirstMode: State := State.Auto; virtual;
    property GenericArrayMode: State := State.Auto; virtual;
    property AsyncSupport: Boolean := true;
    property GenerateServerSideAttributes: Boolean := false;

    method GenerateInterfaceCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
    method GenerateInvokerCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
    method GenerateImplementationCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit; override;
    method GenerateImplementationFiles(aFile: CGCodeUnit; aLibrary: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;override;

    method GenerateInvokerFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; override;
    method GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>; override;
  end;

implementation

constructor DelphiRodlCodeGen;
begin
  fLegacyStrings := false;
  CodeGenTypes.Add("integer", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  CodeGenTypes.Add("datetime", String("DateTime").AsTypeReference);
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeReference.Double));
  CodeGenTypes.Add("currency", String("Currency").AsTypeReference);
  CodeGenTypes.Add("widestring", String("UnicodeString").AsTypeReference);
  CodeGenTypes.Add("ansistring", String("ROAnsiString").AsTypeReference);
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeReference.Int64));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeReference.Boolean));
  CodeGenTypes.Add("variant", String("Variant").AsTypeReference);
  CodeGenTypes.Add("binary", String("Binary").AsTypeReference);
  CodeGenTypes.Add("xml", String("IXmlNode").AsTypeReference);
  CodeGenTypes.Add("guid", String("Guid").AsTypeReference);
  CodeGenTypes.Add("decimal", String("Decimal").AsTypeReference);
  CodeGenTypes.Add("utf8string", String("ROUTF8String").AsTypeReference);
  CodeGenTypes.Add("xsdatetime", String("XsDateTime").AsTypeReference);
  CodeGenTypes.Add("nullableinteger", String("NullableInteger").AsTypeReference);
  CodeGenTypes.Add("nullabledatetime", String("NullableDateTime").AsTypeReference);
  CodeGenTypes.Add("nullabledouble", String("NullableDouble").AsTypeReference);
  CodeGenTypes.Add("nullablecurrency", String("NullableCurrency").AsTypeReference);
  CodeGenTypes.Add("nullableint64", String("NullableInt64").AsTypeReference);
  CodeGenTypes.Add("nullableboolean", String("NullableBoolean").AsTypeReference);
  CodeGenTypes.Add("nullableguid", String("NullableGuid").AsTypeReference);
  CodeGenTypes.Add("nullabledecimal", String("NullableDecimal").AsTypeReference);


  // Delphi Seattle + FPC reserved list
  // http://docwiki.embarcadero.com/RADStudio/Seattle/en/Fundamental_Syntactic_Elements#Reserved_Words
  // http://www.freepascal.org/docs-html/ref/refse3.html
  ReservedWords.Add(["absolute", "abstract", "alias", "and", "array", "as", "asm", "assembler", "at", "automated", "begin",
  "bitpacked", "break", "case", "cdecl", "class", "const", "constructor", "continue", "cppdecl", "cvar", "default",
  "deprecated", "destructor", "dispinterface", "dispose", "div", "do", "downto", "dynamic", "else", "end", "enumerator",
  "except", "exit", "experimental", "export", "exports", "external", "false", "far", "far16", "aFile", "finalization",
  "finally", "for", "forward", "function", "generic", "goto", "helper", "if", "implementation", "implements", "in",
  "index", "inherited", "initialization", "inline", "interface", "interrupt", "iochecks", "is", "label", "aLibrary",
  "local", "message", "mod", "name", "near", "new", "nil", "nodefault", "noreturn", "nostackframe", "not", "object",
  "of", "oldfpccall", "on", "operator", "or", "otherwise", "out", "overload", "override", "packed", "pascal", "platform",
  "private", "procedure", "program", "property", "protected", "public", "published", "raise", "read", "record", "register",
  "reintroduce", "repeat", "resourcestring", "result", "safecall", "saveregisters", "self", "set", "shl", "shr", "softfloat",
  "specialize", "static", "stdcall", "stored", "strict", "string", "then", "threadvar", "to", "true", "try", "type", "unaligned",
  "unimplemented", "unit", "until", "uses", "var", "varargs", "virtual", "while", "with", "write", "xor"]);

  fParamAttributes_typeref := new CGNamedTypeReference("TParamAttributes") isClasstype(false);
end;

method DelphiRodlCodeGen.Add_RemObjects_Inc(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  if isDAProject(aLibrary) then
    aFile.Directives.Add("{$I DataAbstract.inc}".AsCompilerDirective)
  else
    aFile.Directives.Add("{$I RemObjects.inc}".AsCompilerDirective);
end;

method DelphiRodlCodeGen.Intf_GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var lenum := new CGEnumTypeDefinition(aEntity.Name,
                            Visibility := CGTypeVisibilityKind.Public
                            );
  aFile.Types.Add(lenum);
  lenum.XmlDocumentation := GenerateDocumentation(aEntity);
  AddCGAttribute(lenum, attr_ROLibraryAttributes);
  GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name, lenum, aEntity.Documentation);
  GenerateCodeFirstCustomAttributes(lenum,aEntity);

  for rodl_member: RodlEnumValue in aEntity.Items do begin
    var cg4_member := new CGEnumValueDefinition(iif(aEntity.PrefixEnumValues,lenum.Name+"_","") + rodl_member.Name);
    cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    GenerateCodeFirstDocumentation(aFile, "docs_"+aEntity.Name+"_"+rodl_member.Name, cg4_member, rodl_member.Documentation);
    GenerateCodeFirstCustomAttributes(cg4_member,rodl_member);
    if IsCodeFirstCompatible then begin
      if rodl_member.OriginalName <> rodl_member.Name then
        AddCGAttribute(lenum,new CGAttribute("ROEnumSoapName".AsTypeReference,
                                            [rodl_member.Name.AsLiteralExpression.AsCallParameter,
                                             rodl_member.OriginalName.AsLiteralExpression.AsCallParameter],
                                             Condition := CF_condition));
    end;
    lenum.Members.Add(cg4_member);
  end;


  cppGenerateEnumTypeInfo(aFile, aLibrary,aEntity);
  {$REGION initialization/finalization}
  var param2 := GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,aEntity.Name,Intf_name));
  aFile.Initialization:Add(new CGMethodCallExpression(nil, "RegisterROEnum",
                                                    [aEntity.Name.AsLiteralExpression.AsCallParameter,
                                                     param2.AsCallParameter,
                                                     cpp_DefaultNamespace.AsCallParameter].ToList));
  for enumvalue: RodlEnumValue in aEntity.Items do begin
    aFile.Initialization:Add(new CGMethodCallExpression(nil,"RegisterEnumMapping",
                                                 [aEntity.Name.AsLiteralExpression.AsCallParameter,
                                                  enumvalue.Name.AsLiteralExpression.AsCallParameter,
                                                  enumvalue.OriginalName.AsLiteralExpression.AsCallParameter,
                                                  cpp_DefaultNamespace.AsCallParameter].ToList));
  end;
  aFile.Finalization:Add(new CGMethodCallExpression(nil, "UnRegisterEnumMappings",
                                                   [aEntity.Name.AsLiteralExpression.AsCallParameter,
                                                    cpp_DefaultNamespace.AsCallParameter].ToList));
  aFile.Finalization:Add(new CGMethodCallExpression(nil, "UnregisterROEnum",
                                                    [aEntity.Name.AsLiteralExpression.AsCallParameter,
                                                     cpp_DefaultNamespace.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var lAncestorName := aEntity.AncestorName;
  var l_EntityName := aEntity.Name;
  var l_FullEntityTypeRef := ResolveDataTypeToTypeRefFullQualified(aLibrary,l_EntityName,Intf_name);
  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := "TROComplexType";

  var ltype := new CGClassTypeDefinition(l_EntityName,
                                         ResolveDataTypeToTypeRefFullQualified(aLibrary, lAncestorName,Intf_name),
                                         Visibility := CGTypeVisibilityKind.Public
                                         );
  aFile.Types.Add(ltype);
  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  AddCGAttribute(ltype, attr_ROLibraryAttributes);
  GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name,ltype, aEntity.Documentation);
  GenerateCodeFirstCustomAttributes(ltype,aEntity);

  var lclasscnt := 0;
  var lNeedInitSimpleTypeWithDefaultValues := false;

  {$REGION private f%fldname%: %fldtype%}
  for laEntityItem :RodlTypedEntity in aEntity.Items do begin
    ltype.Members.Add(
                        new CGFieldDefinition("f"+laEntityItem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(aLibrary,laEntityItem.DataType,Intf_name),
                                              Visibility := CGMemberVisibilityKind.Private
                                              ));
  end;
  {$ENDREGION}

  {$REGION private Get%fldname%: %fldtype%}
  for laEntityItem :RodlTypedEntity in aEntity.Items do begin
    var laEntityname := laEntityItem.Name;
    var faEntityname := new CGFieldAccessExpression(nil, $"f{laEntityname}");
    if isComplex(aLibrary,laEntityItem.DataType) then begin
      inc(lclasscnt);
      var lm := new CGMethodDefinition("Get"+laEntityname,
                                       ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,laEntityItem.DataType,Intf_name),
                                       Visibility := CGMemberVisibilityKind.Private,
                                       CallingConvention := CGCallingConventionKind.Register);
      ltype.Members.Add(lm);
      if aEntity.AutoCreateProperties then begin
        var ifs_true: CGStatement;
        if isException(aLibrary, laEntityItem.DataType) then
          ifs_true := new CGAssignmentStatement(
                                                faEntityname,
                                                new CGMethodCallExpression(new CGNamedTypeReference(laEntityItem.DataType).AsExpression,"CreateFmt",
                                                                          ["".AsLiteralExpression.AsCallParameter,
                                                                           new CGArrayLiteralExpression().AsCallParameter
                                                                          ].ToList,
                                                                          CallSiteKind := CGCallSiteKind.Reference))
        else
          ifs_true := new CGAssignmentStatement(
                                                faEntityname,
                                                new CGNewInstanceExpression(lm.ReturnType.AsExpression));
        lm.Statements.Add(new CGIfThenElseStatement(new CGAssignedExpression(faEntityname) inverted(true),ifs_true));
      end;
      lm.Statements.Add(faEntityname.AsReturnStatement);
    end
    else begin
      lNeedInitSimpleTypeWithDefaultValues := lNeedInitSimpleTypeWithDefaultValues or laEntityItem.CustomAttributes_lower.ContainsKey("default");
    end;
  end;
  {$ENDREGION}

  var lSerializeInitializedStructValues := isPresent_SerializeInitializedStructValues_Attribute(aLibrary);
  {$REGION protected int%fldname%: %fldtype% read f%fldname%;}
  if not lSerializeInitializedStructValues then begin
    if lclasscnt >0 then begin
      for laEntityItem :RodlTypedEntity in aEntity.Items do begin
        if isComplex(aLibrary,laEntityItem.DataType) then begin
          ltype.Members.Add(new CGPropertyDefinition(
                                              "int_"+laEntityItem.Name,
                                               ResolveDataTypeToTypeRefFullQualified(aLibrary,laEntityItem.DataType,Intf_name),
                                               new CGFieldAccessExpression(nil, $"f{laEntityItem.Name}"),
                                               Visibility := CGMemberVisibilityKind.Protected));
        end;
      end;
    end;
  end;
  {$ENDREGION}

  if (lclasscnt > 0) or (String.IsNullOrEmpty(aEntity.AncestorName)) then begin
    {$REGION protected procedure FreeInternalProperties; override;}
      var lm := new CGMethodDefinition("FreeInternalProperties",
                                       Visibility := CGMemberVisibilityKind.Protected,
                                       Virtuality := CGMemberVirtualityKind.Override,
                                       CallingConvention := CGCallingConventionKind.Register);
      if (not String.IsNullOrEmpty(aEntity.AncestorName)) then
        lm.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited,"FreeInternalProperties"));
      for laEntityItem :RodlTypedEntity in aEntity.Items do begin
        if isComplex(aLibrary,laEntityItem.DataType) then
          lm.Statements.Add(GenerateDestroyExpression( new CGFieldAccessExpression(nil, $"f{laEntityItem.Name}")));
      end;
      ltype.Members.Add(lm);
    {$ENDREGION}
  end;

  {$REGION public constructor Create(aCollection : TCollection); override;}
  if not PureDelphi then begin // c++builder
    var lm := new CGConstructorDefinition(
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, []));
  end;
  {$ENDREGION}

  {$REGION public constructor Create(aCollection : TCollection); override;}
  if lNeedInitSimpleTypeWithDefaultValues or not PureDelphi then begin // we need this for C++Builder
    var par_aCollection := new CGParameterDefinition("aCollection","TCollection".AsTypeReference);
    var lm := new CGConstructorDefinition(
                            Parameters := [par_aCollection].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [par_aCollection.AsCallParameter].ToList));
    for laEntityItem :RodlTypedEntity in aEntity.Items do begin
      if not isComplex(aLibrary,laEntityItem.DataType) and laEntityItem.CustomAttributes_lower.ContainsKey("default") then begin
        var lDefaultValue: CGExpression;
        case laEntityItem.DataType.ToLowerInvariant of
          "widestring",
          "guid",
          "variant",
          "utf8string",
          "ansistring",
          "string": lDefaultValue := laEntityItem.CustomAttributes_lower["default"].AsLiteralExpression;
          "integer",
          "int64",
          "double",
          "boolean",
          "currency",
          "decimal": lDefaultValue := laEntityItem.CustomAttributes_lower["default"].AsNamedIdentifierExpression;
          "datetime": lDefaultValue := new CGMethodCallExpression(nil,
                                                                  "StrToDateTimeDef",
                                                                  [laEntityItem.CustomAttributes_lower["default"].AsLiteralExpression.AsCallParameter,
                                                                   new CGIntegerLiteralExpression(0).AsCallParameter].ToList,
                                                                   CallSiteKind := CGCallSiteKind.Static);
        end;
        if lDefaultValue <> nil then
          lm.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(nil, $"f{laEntityItem.Name}"),lDefaultValue));
      end;
    end;
  end;
  {$ENDREGION}

  Intf_ProcessAttributes(aEntity, ltype);

  if aEntity.Count > 0 then begin
    {$REGION public procedure Assign(Source: TPersistent); override;}
    var par_Source := new CGParameterDefinition("Source","TPersistent".AsTypeReference);
    var lm := new CGMethodDefinition("Assign",
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    lm.Parameters.Add(par_Source);
    ltype.Members.Add(lm);

    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    var var_lSource := new CGVariableDeclarationStatement("lSource",l_FullEntityTypeRef);
    lm.LocalVariables.Add(var_lSource);

    var aSourceExpr := par_Source.AsExpression;
    var lSourceExpr := var_lSource.AsExpression;

    lm.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                 "Assign",
                                                 [aSourceExpr.AsCallParameter].ToList,
                                                 CallSiteKind := CGCallSiteKind.Static));
    var lct := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(GenerateIsClause(aSourceExpr, l_FullEntityTypeRef),
                                                lct));
    lct.Statements.Add(new CGAssignmentStatement(lSourceExpr,
                                                 new CGTypeCastExpression(aSourceExpr, l_FullEntityTypeRef)));
    lct.Statements.Add(new CGEmptyStatement);
    for lprop :RodlTypedEntity in aEntity.Items do begin
      var propname := lprop.Name;
      var fpropname := $"f{lprop.Name}";
      var l_Self_fpropname_Expr := new CGFieldAccessExpression(CGSelfExpression.Self, fpropname, CallSiteKind := CGCallSiteKind.Reference);
      var l_Self_propname_Expr := new CGPropertyAccessExpression(CGSelfExpression.Self, propname, CallSiteKind := CGCallSiteKind.Reference);
      var l_Source_fpropname_Expr := new CGFieldAccessExpression(lSourceExpr, fpropname, CallSiteKind := CGCallSiteKind.Reference);
      var l_Source_propname_Expr := new CGPropertyAccessExpression(lSourceExpr, propname, CallSiteKind := CGCallSiteKind.Reference);
      if isComplex(aLibrary,lprop.DataType) then begin
        var ltemp := lct;

        if not aEntity.AutoCreateProperties then begin
          ltemp := new CGBeginEndBlockStatement();
          lct.Statements.Add(new CGIfThenElseStatement(new CGAssignedExpression(l_Self_fpropname_Expr),ltemp));
        end;

        var lclone_method := new CGAssignmentStatement(l_Self_fpropname_Expr,
                                                       new CGTypeCastExpression(new CGMethodCallExpression(l_Source_fpropname_Expr, "Clone", CallSiteKind := CGCallSiteKind.Reference),
                                                                                ResolveDataTypeToTypeRefFullQualified(aLibrary,lprop.DataType,Intf_name)));
        var lassign_method := new CGMethodCallExpression(l_Self_propname_Expr,
                                                         "Assign",
                                                         [l_Source_fpropname_Expr.AsCallParameter].ToList,
                                                         CallSiteKind := CGCallSiteKind.Reference);
        ltemp.Statements.Add(new CGIfThenElseStatement(new CGAssignedExpression(l_Source_fpropname_Expr),
                                                       new CGIfThenElseStatement(
                                                            new CGAssignedExpression(l_Self_fpropname_Expr),
                                                            lassign_method,
                                                            lclone_method),
                                                       new CGBeginEndBlockStatement(
                                                            [GenerateDestroyExpression(l_Self_fpropname_Expr),
                                                            new CGAssignmentStatement(l_Self_fpropname_Expr, CGNilExpression.Nil)]
                                                       )));
      end
      else begin
        lNeedInitSimpleTypeWithDefaultValues := lNeedInitSimpleTypeWithDefaultValues or (lprop.CustomAttributes_lower.ContainsKey("default"));
        lct.Statements.Add(new CGAssignmentStatement(l_Self_propname_Expr,l_Source_propname_Expr));
      end;
    end;
    {$ENDREGION}

    var TROSerializer_typeref := "TROSerializer".AsTypeReference;
    var par_aSerializer := new CGParameterDefinition("aSerializer", "TObject".AsTypeReference);
    var lSerializer_cast := new CGTypeCastExpression(par_aSerializer.AsExpression, TROSerializer_typeref);

    var litemList := aEntity.GetAllItems;
    var litemList_Sorted := litemList.Sort_OrdinalIgnoreCase(b->b.Name);

    var var__Serializer := new CGVariableDeclarationStatement("__Serializer", TROSerializer_typeref, lSerializer_cast);
    var lSerializer := var__Serializer.AsExpression;

    {$REGION public procedure ReadComplex(aSerializer: TObject); override;}
    lm := new CGMethodDefinition("ReadComplex",
                                  Parameters := [par_aSerializer].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables.Add(var__Serializer);


    for lmem in litemList_Sorted do
      lm.LocalVariables.Add(new CGVariableDeclarationStatement($"l_{lmem.Name}",ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.DataType,Intf_name)));
    var lSorted := new CGBeginEndBlockStatement;
    var lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGPropertyAccessExpression(lSerializer, "RecordStrictOrder", CallSiteKind := CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if aEntity.Count <> litemList.Count then
        lStrict.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, "ReadComplex",[par_aSerializer.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Static));
    Intf_GenerateRead(aFile,aLibrary,aEntity.Items,lStrict.Statements, lSerializeInitializedStructValues,lSerializer);
    Intf_GenerateRead(aFile,aLibrary,litemList_Sorted,lSorted.Statements, lSerializeInitializedStructValues,lSerializer);
    {$ENDREGION}

    {$REGION public procedure WriteComplex(aSerializer: TObject); override;}
    lm := new CGMethodDefinition("WriteComplex",
                                  Parameters :=[par_aSerializer].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables.Add(var__Serializer);
    for lmem in litemList_Sorted do
      lm.LocalVariables.Add(new CGVariableDeclarationStatement($"l_{lmem.Name}", ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.DataType,Intf_name)));
    lSorted := new CGBeginEndBlockStatement;
    lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGPropertyAccessExpression(lSerializer, "RecordStrictOrder", CallSiteKind := CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if aEntity.Count <> litemList.Count then lStrict.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, "WriteComplex",[par_aSerializer.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Static));
    lStrict.Statements.Add(new CGMethodCallExpression(lSerializer,"ChangeClass",[cpp_ClassId(DuplicateType(l_FullEntityTypeRef, false).AsExpression).AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    Intf_GenerateWrite(aFile,aLibrary,aEntity.Items,lStrict.Statements, lSerializeInitializedStructValues,lSerializer);
    Intf_GenerateWrite(aFile,aLibrary,litemList_Sorted,lSorted.Statements, lSerializeInitializedStructValues,lSerializer);
    {$ENDREGION}
  end;

  {$REGION published property %fldname%: %fldtype% read [f|Get]%fldname% write f%fldname%;}
  for rodl_member :RodlTypedEntity in aEntity.Items do begin
    var lp := iif(isComplex(aLibrary, rodl_member.DataType),
                    new CGMethodAccessExpression(nil, $"Get{rodl_member.Name}"),
                    new CGFieldAccessExpression(nil, $"f{rodl_member.Name}")
                  );
    var cg4_member := new CGPropertyDefinition(rodl_member.Name,
                                          ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_member.DataType,Intf_name),
                                          lp,
                                          new CGFieldAccessExpression(nil, $"f{rodl_member.Name}"),
                                          Visibility := CGMemberVisibilityKind.Published);
    cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    GenerateCodeFirstDocumentation(aFile, $"docs_{aEntity.Name}_{rodl_member.Name}",cg4_member, rodl_member.Documentation);
    GenerateCodeFirstCustomAttributes(cg4_member, rodl_member);
    if IsCodeFirstCompatible then begin
      if IsAnsiString(rodl_member.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsAnsiString) else
      if IsUTF8String(rodl_member.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsUTF8String);
    end;
    ltype.Members.Add(cg4_member);
  end;
  {$ENDREGION}

  {$REGION initialization/finalization}
  aFile.Initialization:Add(new CGMethodCallExpression(nil, "RegisterROClass",  [cpp_ClassId(GenerateTypeExpression(l_EntityName)).AsCallParameter, cpp_DefaultNamespace.AsCallParameter].ToList));
  aFile.Finalization:Add(new CGMethodCallExpression(nil, "UnregisterROClass", [cpp_ClassId(GenerateTypeExpression(l_EntityName)).AsCallParameter, cpp_DefaultNamespace.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Grow: CGMethodDefinition;
begin
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var lm := new CGMethodDefinition("Grow",
                                    Virtuality := CGMemberVirtualityKind.Virtual,
                                    Visibility := CGMemberVisibilityKind.Protected,
                                    CallingConvention := CGCallingConventionKind.Register);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  var localvar_lDelta := new CGVariableDeclarationStatement("lDelta", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  lm.LocalVariables.Add(localvar_lDelta);
  var localvar_lCapacity := new CGVariableDeclarationStatement("lCapacity", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  lm.LocalVariables.Add(localvar_lCapacity);
  var lDelta := localvar_lDelta.AsExpression;
  var lCapacity := localvar_lCapacity.AsExpression;
  lm.Statements.Add(new CGAssignmentStatement(lCapacity, Array_GetLength(fItems)));
  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(lCapacity,new CGIntegerLiteralExpression(64), CGBinaryOperatorKind.GreaterThan),
                                              new CGAssignmentStatement(lDelta,new CGBinaryOperatorExpression(lCapacity, new CGIntegerLiteralExpression(4),CGBinaryOperatorKind.LegacyPascalDivision)),
                                              new CGIfThenElseStatement(new CGBinaryOperatorExpression(lCapacity,new CGIntegerLiteralExpression(8), CGBinaryOperatorKind.GreaterThan),
                                                                        new CGAssignmentStatement(lDelta,new CGIntegerLiteralExpression(16)),
                                                                        new CGAssignmentStatement(lDelta,new CGIntegerLiteralExpression(4)))
                                              ));

  lm.Statements.Add(Array_SetLength(fItems, new CGBinaryOperatorExpression(lCapacity,lDelta,CGBinaryOperatorKind.Addition)));
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_GetItems(aElementType: CGTypeReference): CGMethodDefinition;
begin
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var par_aIndex := new CGParameterDefinition("aIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var aIndex: CGExpression := par_aIndex.AsExpression;
  var lm := new CGMethodDefinition("GetItems",
                          Parameters := [par_aIndex].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          ReturnType := aElementType,
                          CallingConvention := CGCallingConventionKind.Register);
  lm.Statements.Add(new CGIfThenElseStatement(
                        new CGBinaryOperatorExpression(
                            new CGBinaryOperatorExpression(aIndex,new CGIntegerLiteralExpression(0),CGBinaryOperatorKind.LessThan),
                            new CGBinaryOperatorExpression(aIndex, fCount, CGBinaryOperatorKind.GreatThanOrEqual),
                            CGBinaryOperatorKind.LogicalOr),
                        RaiseError("err_ArrayIndexOutOfBounds".AsNamedIdentifierExpression, [aIndex].ToList)));
  lm.Statements.Add(new CGArrayElementAccessExpression(fItems, [aIndex].ToList).AsReturnStatement); // result := fItems[aIndex]
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_SetItems(aElementType: CGTypeReference; aComplex: Boolean): CGMethodDefinition;
begin
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var fItems := new CGFieldAccessExpression(nil, "fItems");

  var par_aIndex := new CGParameterDefinition("aIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var par_Value := new CGParameterDefinition("Value", aElementType);
  var Value := par_Value.AsExpression;
  var aIndex: CGExpression := par_aIndex.AsExpression;
  var fItems_aIndex := new CGArrayElementAccessExpression(fItems,[aIndex].ToList);  //fItems[aIndex]

  var lm := new CGMethodDefinition("SetItems",
                          Parameters := [par_aIndex, par_Value].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          CallingConvention := CGCallingConventionKind.Register
                          );
  lm.Statements.Add(new CGIfThenElseStatement(
                        new CGBinaryOperatorExpression(
                                            new CGBinaryOperatorExpression(aIndex,new CGIntegerLiteralExpression(0),CGBinaryOperatorKind.LessThan),
                                            new CGBinaryOperatorExpression(aIndex,fCount, CGBinaryOperatorKind.GreatThanOrEqual),
                                            CGBinaryOperatorKind.LogicalOr),
                        RaiseError("err_ArrayIndexOutOfBounds".AsNamedIdentifierExpression, [aIndex].ToList)));
  if aComplex then begin
    lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(fItems_aIndex, Value, CGBinaryOperatorKind.NotEquals),
                                                new CGBeginEndBlockStatement([GenerateDestroyExpression(fItems_aIndex),
                                                                              new CGAssignmentStatement(fItems_aIndex, Value)].ToList)));
  end
  else begin
    lm.Statements.Add(new CGAssignmentStatement(fItems_aIndex, Value));
  end;
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_GetCount: CGMethodDefinition;
begin
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  exit new CGMethodDefinition("GetCount",
                                [fCount.AsReturnStatement],
                                ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Protected,
                                CallingConvention := CGCallingConventionKind.Register);
end;

method DelphiRodlCodeGen.Intf_GenerateArray_IntResize(aElementType: CGTypeReference; aComplex: Boolean): CGMethodDefinition;
begin
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var localvar_i := new CGVariableDeclarationStatement("i", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var fItems_i := new CGArrayElementAccessExpression(fItems, [localvar_i.AsExpression as CGExpression]);
  var fCount_subtract_1    := new CGBinaryOperatorExpression(fCount,            //fCount-1
                                                            new CGIntegerLiteralExpression(1),
                                                            CGBinaryOperatorKind.Subtraction);

  var par_anElementCount := new CGParameterDefinition("anElementCount",ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var par_AllocItems     := new CGParameterDefinition("AllocItems",ResolveStdtypes(CGPredefinedTypeReference.Boolean));
  var anElementCount     := par_anElementCount.AsExpression;
  var anElementCount_sub_1 := new CGBinaryOperatorExpression(anElementCount,                        // anElementCount-1
                                                             new CGIntegerLiteralExpression(1),
                                                             CGBinaryOperatorKind.Subtraction);
  var lm := new CGMethodDefinition("IntResize",
                            Parameters := [par_anElementCount, par_AllocItems].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Protected,
                            CallingConvention := CGCallingConventionKind.Register);

  if aComplex then begin
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables.Add(localvar_i);
  end;
  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(fCount, anElementCount, CGBinaryOperatorKind.Equals),  new CGReturnStatement()));
  if aComplex then begin
    lm.Statements.Add(new CGForToLoopStatement(localvar_i.Name,
                                               ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                               fCount_subtract_1,
                                               anElementCount,
                                               GenerateDestroyExpression(fItems_i),
                                               Direction := CGLoopDirectionKind.Backward));
  end;
  lm.Statements.Add(Array_SetLength(fItems, anElementCount));
  if aComplex then begin
    lm.Statements.Add(new CGForToLoopStatement(localvar_i.Name,
                          ResolveStdtypes(CGPredefinedTypeReference.Int32),
                          fCount,
                          anElementCount_sub_1,
                          new CGIfThenElseStatement(par_AllocItems.AsExpression,
                              new CGAssignmentStatement(fItems_i, new CGNewInstanceExpression(aElementType)),
                              new CGAssignmentStatement(fItems_i, CGNilExpression.Nil)
                          )));
  end;
  lm.Statements.Add(new CGAssignmentStatement(fCount,anElementCount));
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_GetItemType(aLibrary: RodlLibrary; aElementType: CGTypeReference): CGMethodDefinition;
begin
  exit new CGMethodDefinition("GetItemType",
                               [GenerateTypeInfoCall(aLibrary, aElementType).AsReturnStatement],
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                ReturnType :=  new CGNamedTypeReference("PTypeInfo") isClassType(false),
                                &Static := true,
                                CallingConvention := CGCallingConventionKind.Register);
end;

method DelphiRodlCodeGen.Intf_GenerateArray_GetItemClass(aElementType: CGTypeReference): CGMethodDefinition;
begin
  exit new CGMethodDefinition("GetItemClass",
                             [cpp_ClassId(DuplicateType(aElementType, false).AsExpression).AsReturnStatement],
                              Virtuality := CGMemberVirtualityKind.Override,
                              Visibility := CGMemberVisibilityKind.Public,
                              ReturnType := new CGNamedTypeReference("TClass") &namespace(new CGNamespaceReference("System")) isclasstype(false),
                              &Static := true,
                              CallingConvention := CGCallingConventionKind.Register);
end;

method DelphiRodlCodeGen.Intf_GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
begin
  var lm: CGMethodLikeMemberDefinition;
  var lElementType := aEntity.ElementType;
  var el_typeref := ResolveDataTypeToTypeRefFullQualified(aLibrary, lElementType, Intf_name);
  if not isComplex(aLibrary, lElementType) then
    if el_typeref is CGNamedTypeReference then
      lElementType := CGNamedTypeReference(el_typeref).Name;

  var larrayname := aEntity.Name;
  var array_typeref := ResolveDataTypeToTypeRefFullQualified(aLibrary, larrayname, Intf_name);
  var lEnumerator := $"{larrayname}Enumerator";

  if PureDelphi and IsGenericArrayCompatible then begin
    var ar := new CGClassTypeDefinition(aEntity.Name, ($"TROArray<{lElementType}>").AsTypeReference,
                                       Visibility := CGTypeVisibilityKind.Public,
                                       Condition := cond_ROUseGenerics);
    var x := GenerateParamAttributes(aEntity.ElementType);
    if x.Elements.Count > 0 then begin
      ar.Members.Add( new CGMethodDefinition("ElementAttributes",
                                       [x.AsReturnStatement],
                                       ReturnType := fParamAttributes_typeref,
                                       Virtuality := CGMemberVirtualityKind.Override,
                                       Visibility := CGMemberVisibilityKind.Public));
    end;
    aFile.Types.Add(ar);
  end;
  if GenericArrayMode = State.On then exit;

  // non generic arrays
  var linternalarr := new CGTypeAliasDefinition(larrayname+"_"+lElementType,
                                                new CGArrayTypeReference(el_typeref),
                                                Condition := cond_ROUseGenerics_inverted);

  var linternalarr_typeref := DuplicateType(ResolveDataTypeToTypeRefFullQualified(aLibrary, linternalarr.Name, Intf_name,larrayname), false);
  aFile.Types.Add(linternalarr);
  var ltype := new CGClassTypeDefinition(larrayname,"TROArray".AsTypeReference,
                              Visibility := CGTypeVisibilityKind.Public,
                              Condition := cond_ROUseGenerics_inverted,
                              XmlDocumentation := GenerateDocumentation(aEntity)
                              );
  AddCGAttribute(ltype, attr_ROLibraryAttributes);
  GenerateCodeFirstDocumentation(aFile,$"docs_{aEntity.Name}",ltype, aEntity.Documentation);
  GenerateCodeFirstCustomAttributes(ltype, aEntity);

  if IsCodeFirstCompatible then begin
    if IsAnsiString(aEntity.ElementType) then AddCGAttribute(ltype, attr_ROSerializeAsAnsiString) else
    if IsUTF8String(aEntity.ElementType) then AddCGAttribute(ltype, attr_ROSerializeAsUTF8String);
  end;

  aFile.Types.Add(ltype);

  // private fCount: Integer
  ltype.Members.Add(new CGFieldDefinition("fCount",
                                          ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                          Visibility := CGMemberVisibilityKind.Private
                                          ));

  // private fItems: %arrayname%_%elementtype%}
  ltype.Members.Add(new CGFieldDefinition("fItems",
                                          linternalarr_typeref,
                                          Visibility := CGMemberVisibilityKind.Private
                                          ));

  var l_isComplex := isComplex(aLibrary,lElementType);
  //protected procedure Grow; virtual;
  ltype.Members.Add(Intf_GenerateArray_Grow);
  // protected function GetItems(aIndex: Integer): %elementtype%
  ltype.Members.Add(Intf_GenerateArray_GetItems(el_typeref));
  // protected procedure SetItems(aIndex: Integer; const Value: %elementtypetype%)
  ltype.Members.Add(Intf_GenerateArray_SetItems(el_typeref, l_isComplex));
  // protected function GetCount: Integer;
  ltype.Members.Add(Intf_GenerateArray_GetCount);
  // protected IntResize(ElementCount: Integer; AllocItems: Boolean); override;
  ltype.Members.Add(Intf_GenerateArray_IntResize(el_typeref, l_isComplex));

  Intf_ProcessAttributes(aEntity,ltype);
  // public class function GetItemType: PTypeInfo; override;
  ltype.Members.Add(Intf_GenerateArray_GetItemType(aLibrary, el_typeref));

  if l_isComplex then begin
    // public class function GetItemClass: System.TClass; override;
    ltype.Members.Add(Intf_GenerateArray_GetItemClass(el_typeref));
  end;
  // public class function GetItemSize: Integer; override;
  ltype.Members.Add(Intf_GenerateArray_GetItemSize(el_typeref));
  // public function GetItemRef(aIndex: Integer): pointer; override;
  ltype.Members.Add(Intf_GenerateArray_GetItemRef(l_isComplex));

  if l_isComplex then begin
    // procedure SetItemRef(aIndex: Integer; Ref: pointer); override;
    ltype.Members.Add(Intf_GenerateArray_SetItemRef(el_typeref));
  end;
  // public procedure Clear; override;
  ltype.Members.Add(Intf_GenerateArray_Clear(l_isComplex));
  // public procedure Delete(aIndex: Integer); override;
  ltype.Members.Add(Intf_GenerateArray_Delete(l_isComplex));
  // public procedure Assign(aSource: TPersistent); override;
  ltype.Members.Add(Intf_GenerateArray_Assign(aLibrary, array_typeref, el_typeref, lElementType, l_isComplex));
  // public procedure ReadComplex(aSerializer: TObject); override;
  ltype.Members.Add(Intf_GenerateArray_ReadComplex(aLibrary,el_typeref, aEntity.ElementType));
  // public procedure WriteComplex(aSerializer: TObject); override;
  ltype.Members.Add(Intf_GenerateArray_WriteComplex(aLibrary, array_typeref, el_typeref, aEntity.ElementType));
  // public function Add(const Value: %elementtype%): Integer;
  ltype.Members.Add(Intf_GenerateArray_Add(el_typeref, l_isComplex));

  if not l_isComplex then begin
    // public function GetIndex(const aValue: %elementtype%;const aStartFrom: Integer = 0): Integer;overload;
    ltype.Members.Add(Intf_GenerateArray_GetIndex(el_typeref));
    // public function GetIndex(const aPropertyName : string; const aPropertyValue : Variant; StartFrom : Integer = 0; Options : TROSearchOptions = [soIgnoreCase]): Integer; override;
    ltype.Members.Add(Intf_GenerateArray_GetIndex1);
    // public function IndexOf(const aValue: %elementtype%; const aStartFrom: Integer = 0): Integer;
    ltype.Members.Add(Intf_GenerateArray_IndexOf(el_typeref));
  end
  else begin
    // public function Add: %elementtype%;overload;
    ltype.Members.Add(Intf_GenerateArray_Add1(el_typeref, isException(aLibrary,lElementType)));
  end;

  // public function GetEnumerator: %array%Enumerator;
  ltype.Members.Add(Intf_GenerateArray_GetEnumerator(ResolveDataTypeToTypeRefFullQualified(aLibrary, lEnumerator, Intf_name, larrayname)));
  // public property Count: Integer read GetCount;
  ltype.Members.Add(Intf_GenerateArray_Count);
  // public property Items[Index: Integer]: %elementtype% read GetItems write SetItems; default;
  ltype.Members.Add(Intf_GenerateArray_Items(el_typeref));

  // public property InnerArray: %s_%s read fItems;
  ltype.Members.Add(Intf_GenerateArray_InnerArray(linternalarr_typeref));

  cpp_GenerateArrayDestructor(ltype);

  {$REGION initialization/finalization}
  aFile.Initialization.Add(new CGMethodCallExpression(nil, "RegisterROClass",[cpp_ClassId(GenerateTypeExpression(larrayname)).AsCallParameter, cpp_DefaultNamespace.AsCallParameter].ToList));
  aFile.Finalization.Add(new CGMethodCallExpression(nil, "UnregisterROClass",[cpp_ClassId(GenerateTypeExpression(larrayname)).AsCallParameter, cpp_DefaultNamespace.AsCallParameter].ToList));
  {$ENDREGION}

  {$REGION %arrayname%Enumerator}
  var lenumtype := new CGClassTypeDefinition(lEnumerator, "TObject".AsTypeReference,
                                             Visibility := CGTypeVisibilityKind.Public,
                                             Condition := cond_ROUseGenerics_inverted);
  aFile.Types.Add(lenumtype);
  {$REGION private fArray: %arrayname%}
  var fld_fArray := new CGFieldDefinition("fArray",
                                  array_typeref,
                                  Visibility := CGMemberVisibilityKind.Private);
  lenumtype.Members.Add(fld_fArray);
  {$ENDREGION}
  {$REGION private fCurrentIndex: Integer;}
  var fld_fCurrentIndex := new CGFieldDefinition("fCurrentIndex",
                                  ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                  Visibility := CGMemberVisibilityKind.Private);
  lenumtype.Members.Add(fld_fCurrentIndex);
  {$ENDREGION}
  var fCurrentIndex := fld_fCurrentIndex.AsExpression;
  var fCurrentIndex_add_1 := new CGBinaryOperatorExpression(fCurrentIndex, new CGIntegerLiteralExpression(1), CGBinaryOperatorKind.Addition);
  var fArray := fld_fArray.AsExpression;
  {$REGION private function GetCurrent: %elementtype%}
  lm := new CGMethodDefinition("GetCurrent",
                                Visibility := CGMemberVisibilityKind.Private,
                                ReturnType := el_typeref,
                                CallingConvention := CGCallingConventionKind.Register
                                );
  lenumtype.Members.Add(lm);
  lm.Statements.Add(new CGPropertyAccessExpression(fArray,"Items",[fCurrentIndex.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference).AsReturnStatement);
  {$ENDREGION}

  {$REGION public constructor Create(const anArray: %arrayname%);}
  var param_anArray := new CGParameterDefinition("anArray", array_typeref);
  lm := new CGConstructorDefinition(Parameters := [param_anArray].ToList,
                                    Visibility := CGMemberVisibilityKind.Public,
                                    CallingConvention := CGCallingConventionKind.Register
                                    );
  lenumtype.Members.Add(lm);
  lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));
  lm.Statements.Add(new CGAssignmentStatement(fArray, param_anArray.AsExpression));
  lm.Statements.Add(new CGAssignmentStatement(fCurrentIndex, new CGIntegerLiteralExpression(-1)));
  {$ENDREGION}

  {$REGION public function MoveNext: Boolean;}
  var localvar_lResult := new CGVariableDeclarationStatement( "lResult", ResolveStdtypes(CGPredefinedTypeReference.Boolean));
  var lResult: CGExpression := localvar_lResult.AsExpression;
  lm := new CGMethodDefinition("MoveNext",
                                LocalVariables := [localvar_lResult].ToList,
                                Visibility := CGMemberVisibilityKind.Public,
                                ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Boolean),
                                CallingConvention := CGCallingConventionKind.Register);
  lenumtype.Members.Add(lm);

  lm.Statements.Add(new CGAssignmentStatement(lResult, new CGBinaryOperatorExpression(fCurrentIndex,
                                                                                       new CGBinaryOperatorExpression(new CGPropertyAccessExpression(fArray,"Count",CallSiteKind := CGCallSiteKind.Reference),
                                                                                                                      new CGIntegerLiteralExpression(1),
                                                                                                                      CGBinaryOperatorKind.Subtraction),
                                                                                       CGBinaryOperatorKind.LessThan)));
  lm.Statements.Add(new CGIfThenElseStatement(lResult,new CGAssignmentStatement(fCurrentIndex, fCurrentIndex_add_1)));
  lm.Statements.Add(lResult.AsReturnStatement);
  {$ENDREGION}

  {$REGION public property Current: %elementtype% read GetCurrent;}
  lenumtype.Members.Add( new CGPropertyDefinition("Current",
                                                  el_typeref,
                                                  new CGMethodAccessExpression(nil, "GetCurrent"),
                                                  Visibility := CGMemberVisibilityKind.Public
                                                  ));
  {$ENDREGION}
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
begin
  var lAncestorName := aEntity.AncestorName;
  var l_EntityName := aEntity.Name;
  var exception_typeref := ResolveDataTypeToTypeRefFullQualified(aLibrary,l_EntityName,Intf_name);

  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := "EROException";

  var ltype := new CGClassTypeDefinition(l_EntityName,
                                         ResolveDataTypeToTypeRefFullQualified(aLibrary, lAncestorName, Intf_name),
                                         Visibility := CGTypeVisibilityKind.Public
                                         );
  aFile.Types.Add(ltype);
  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  AddCGAttribute(ltype, attr_ROLibraryAttributes);
  GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name,ltype, aEntity.Documentation);
  GenerateCodeFirstCustomAttributes(ltype, aEntity);

  var lclasscnt := 0;
  var lNeedInitSimpleTypeWithDefaultValues := false;

  {$REGION private f%fldname%: %fldtype%}
  for laEntityItem :RodlTypedEntity in aEntity.Items do begin
    ltype.Members.Add(
                        new CGFieldDefinition("f"+laEntityItem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(aLibrary,laEntityItem.DataType, Intf_name),
                                              Visibility := CGMemberVisibilityKind.Private
                                              ));
  end;
  {$ENDREGION}


  {$REGION private Get%fldname%: %fldtype%}
  for laEntityItem :RodlTypedEntity in aEntity.Items do begin
    var laEntityname := laEntityItem.Name;
    var f_name := new CGFieldAccessExpression(nil, $"f{laEntityname}");
    if isComplex(aLibrary,laEntityItem.DataType) then begin
      inc(lclasscnt);
      var lm := new CGMethodDefinition("Get"+laEntityname,
                                       ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,laEntityItem.DataType, Intf_name),
                                       Visibility := CGMemberVisibilityKind.Private,
                                       CallingConvention := CGCallingConventionKind.Register);
      ltype.Members.Add(lm);
      if aEntity.AutoCreateProperties then begin
        var ifs_true: CGStatement;
        if isException(aLibrary, laEntityItem.DataType) then
          ifs_true := new CGAssignmentStatement(
                                                f_name,
                                                new CGMethodCallExpression(new CGNamedTypeReference(laEntityItem.DataType).AsExpression,"CreateFmt",
                                                                          ["".AsLiteralExpression.AsCallParameter, new CGArrayLiteralExpression().AsCallParameter].ToList,
                                                                           CallSiteKind := CGCallSiteKind.Reference))
        else
          ifs_true := new CGAssignmentStatement(
                                                f_name,
                                                new CGNewInstanceExpression(laEntityItem.DataType.AsTypeReference));
        lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(f_name,CGNilExpression.Nil,CGBinaryOperatorKind.Equals),ifs_true));
      end;
      lm.Statements.Add(f_name.AsReturnStatement);
    end
    else begin
      lNeedInitSimpleTypeWithDefaultValues := lNeedInitSimpleTypeWithDefaultValues or laEntityItem.CustomAttributes_lower.ContainsKey("default");
    end;
  end;
  {$ENDREGION}

  var lSerializeInitializedStructValues := isPresent_SerializeInitializedStructValues_Attribute(aLibrary);
  {$REGION protected int_%fldname%: %fldtype% read f%fldname%;}
  if not lSerializeInitializedStructValues then begin
    if lclasscnt >0 then begin
      for laEntityItem :RodlTypedEntity in aEntity.Items do begin
        if isComplex(aLibrary,laEntityItem.DataType) then begin
          ltype.Members.Add(new CGPropertyDefinition(
                                              "int_"+laEntityItem.Name,
                                               ResolveDataTypeToTypeRefFullQualified(aLibrary,laEntityItem.DataType, Intf_name),
                                               new CGFieldAccessExpression(nil, $"f{laEntityItem.Name}"),
                                              Visibility := CGMemberVisibilityKind.Protected));
        end;
      end;
    end;
  end;
  {$ENDREGION}

  if aEntity.Count > 0 then begin
  {$REGION public constructor Create(anExceptionMessage : string;%flds%);}
  var param_anExceptionMessage := new CGParameterDefinition("anExceptionMessage", ResolveStdtypes(CGPredefinedTypeReference.String));
  var lmc := new CGConstructorDefinition(
                          Parameters :=[param_anExceptionMessage].ToList,
                          Visibility := CGMemberVisibilityKind.Public,
                          CallingConvention := CGCallingConventionKind.Register
                          );
  var lif :=aEntity.GetInheritedItems;
  for fld in lif do
    lmc.Parameters.Add(new CGParameterDefinition($"a{fld.Name}", ResolveDataTypeToTypeRefFullQualified(aLibrary,fld.DataType, Intf_name)));
  for fld in aEntity.Items do
    lmc.Parameters.Add(new CGParameterDefinition($"a{fld.Name}", ResolveDataTypeToTypeRefFullQualified(aLibrary,fld.DataType, Intf_name)));
  ltype.Members.Add(lmc);
  var lmcc := new CGConstructorCallStatement(CGInheritedExpression.Inherited, [param_anExceptionMessage.AsCallParameter].ToList);
  lmc.Statements.Add(lmcc);
  for fld in lif do
    lmcc.Parameters.Add(new CGParameterAccessExpression($"a{fld.Name}").AsCallParameter);

  for laEntityItem :RodlTypedEntity in aEntity.Items do
    lmc.Statements.Add(new CGAssignmentStatement(
                          new CGFieldAccessExpression(nil, $"f{laEntityItem.Name}"),
                          new CGParameterAccessExpression($"a{laEntityItem.Name}")
                          ));
  {$ENDREGION}
  end;

  Intf_ProcessAttributes(aEntity, ltype);

  if aEntity.Count > 0 then begin
    {$REGION public procedure Assign(Source: EROException); override;}
    var param_Source := new CGParameterDefinition("Source","EROException".AsTypeReference);
    var lm := new CGMethodDefinition("Assign",
                            Parameters := [param_Source].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    var localvar_lSource := new CGVariableDeclarationStatement("lSource",exception_typeref);
    lm.LocalVariables.Add(localvar_lSource);
    var l_lSource := localvar_lSource.AsExpression;

    lm.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited,"Assign", [param_Source.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Static));
    var lct := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(GenerateIsClause(param_Source.AsExpression,exception_typeref),
                                          lct));

    lct.Statements.Add(new CGAssignmentStatement(l_lSource,
                                                 new CGTypeCastExpression(param_Source.AsExpression, exception_typeref)));
    for lprop :RodlTypedEntity in aEntity.Items do begin
      var l_prop := lprop.Name;

      var l_lSource_prop_Expr := new CGPropertyAccessExpression(l_lSource, l_prop, CallSiteKind := CGCallSiteKind.Reference);
      var l_Self_prop_Expr := new CGPropertyAccessExpression(CGSelfExpression.Self, l_prop, CallSiteKind := CGCallSiteKind.Reference);
      if isComplex(aLibrary,lprop.DataType) then begin

        var l_fprop := $"f{l_prop}";

        var l_Self_fprop_Expr := new CGFieldAccessExpression(CGSelfExpression.Self, l_fprop, CallSiteKind := CGCallSiteKind.Reference);
        var l_lSource_fprop_Expr := new CGFieldAccessExpression(l_lSource, l_fprop, CallSiteKind := CGCallSiteKind.Reference);
        var lassign_method := new CGMethodCallExpression(l_Self_prop_Expr,
                                                         "Assign",
                                                         [l_lSource_fprop_Expr.AsCallParameter].ToList,
                                                         CallSiteKind := CGCallSiteKind.Reference);
        var lclone_method := new CGAssignmentStatement(l_Self_fprop_Expr,
                                                        new CGTypeCastExpression(new CGMethodCallExpression(l_lSource_fprop_Expr,"Clone",CallSiteKind := CGCallSiteKind.Reference),
                                                                                 ResolveDataTypeToTypeRefFullQualified(aLibrary,lprop.DataType,Intf_name)));

        var ifs := new CGIfThenElseStatement(new CGAssignedExpression(l_lSource_fprop_Expr),
                                             new CGIfThenElseStatement(
                                                            new CGAssignedExpression(l_Self_fprop_Expr),
                                                            lassign_method,
                                                            lclone_method),
                                             new CGBeginEndBlockStatement([
                                                                            GenerateDestroyExpression(l_Self_fprop_Expr),
                                                                            new CGAssignmentStatement(l_Self_fprop_Expr, CGNilExpression.Nil)]));
        if aEntity.AutoCreateProperties then
          lct.Statements.Add(new CGIfThenElseStatement(new CGAssignedExpression(l_Self_fprop_Expr), ifs))
        else
          lct.Statements.Add(ifs);
      end
      else begin
        lct.Statements.Add(new CGAssignmentStatement(l_Self_prop_Expr, l_lSource_prop_Expr));
      end;
    end;
    {$ENDREGION}

    var litemList := aEntity.GetAllItems;
    var litemList_Sorted := litemList.ToList.Sort_OrdinalIgnoreCase(b->b.Name);
    var TROSerializer_typeref := "TROSerializer".AsTypeReference;
    var param_aSerializer := new CGParameterDefinition("aSerializer","TROBaseSerializer".AsTypeReference);
    var lSerializer_cast := new CGTypeCastExpression(param_aSerializer.AsExpression,TROSerializer_typeref);
    var localvar__Serializer := new CGVariableDeclarationStatement("__Serializer",TROSerializer_typeref, lSerializer_cast);
    var lSerializer := localvar__Serializer.AsExpression;


    {$REGION public procedure ReadException(aSerializer: TROBaseSerializer); override;}
    lm := new CGMethodDefinition("ReadException",
                                  Parameters := [param_aSerializer].ToList,
                                  LocalVariables := [localvar__Serializer].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);

    for lmem in litemList_Sorted do
      lm.LocalVariables.Add(new CGVariableDeclarationStatement($"l_{lmem.Name}",ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.DataType,Intf_name)));
    var lSorted := new CGBeginEndBlockStatement;
    var lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGPropertyAccessExpression(lSerializer,"RecordStrictOrder",CallSiteKind := CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if aEntity.Count <> litemList.Count then begin
      lStrict.Statements.Add(
        new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                   "ReadException",
                                   [param_aSerializer.AsCallParameter].ToList,
                                   CallSiteKind := CGCallSiteKind.Static));
    end;
    Intf_GenerateRead(aFile, aLibrary, aEntity.Items, lStrict.Statements, lSerializeInitializedStructValues, lSerializer);
    Intf_GenerateRead(aFile, aLibrary, litemList_Sorted, lSorted.Statements, lSerializeInitializedStructValues, lSerializer);
    {$ENDREGION}

    {$REGION public procedure WriteException(aSerializer: TROBaseSerializer); override;}
    lm := new CGMethodDefinition("WriteException",
                                  Parameters := [param_aSerializer].ToList,
                                  LocalVariables := [localvar__Serializer].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);
    for lmem in litemList_Sorted do
      lm.LocalVariables.Add(new CGVariableDeclarationStatement($"l_{lmem.Name}",ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.DataType,Intf_name)));
    lSorted := new CGBeginEndBlockStatement;
    lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGPropertyAccessExpression(lSerializer,"RecordStrictOrder",CallSiteKind := CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if aEntity.Count <> litemList.Count then begin
      lStrict.Statements.Add(
        new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                   "WriteException",
                                   [param_aSerializer.AsCallParameter].ToList,
                                   CallSiteKind := CGCallSiteKind.Static));
    end;
    lStrict.Statements.Add(new CGMethodCallExpression(lSerializer,"ChangeClass",[cpp_ClassId(DuplicateType(exception_typeref, false).AsExpression).AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    Intf_GenerateWrite(aFile,aLibrary,aEntity.Items,lStrict.Statements, lSerializeInitializedStructValues,lSerializer);
    Intf_GenerateWrite(aFile,aLibrary,litemList_Sorted,lSorted.Statements, lSerializeInitializedStructValues,lSerializer);
    {$ENDREGION}
  end;

  {$REGION published property %fldname%: %fldtype% read [f|Get]%fldname% write f%fldname%;}
  for rodl_member :RodlTypedEntity in aEntity.Items do begin
    var getter :=
      if isComplex(aLibrary, rodl_member.DataType) then
        new CGMethodAccessExpression(nil, $"Get{rodl_member.Name}")
      else
        new CGFieldAccessExpression(nil, $"f{rodl_member.Name}");

    var cg4_member := new CGPropertyDefinition(rodl_member.Name,
                                          ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_member.DataType, Intf_name),
                                          getter,
                                          new CGFieldAccessExpression(nil, $"f{rodl_member.Name}"),
                                          Visibility := CGMemberVisibilityKind.Published);
    cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name+"_"+rodl_member.Name,cg4_member, rodl_member.Documentation);
    GenerateCodeFirstCustomAttributes(cg4_member, rodl_member);
    if IsCodeFirstCompatible then begin
      if IsAnsiString(rodl_member.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsAnsiString) else
      if IsUTF8String(rodl_member.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsUTF8String);
    end;

    ltype.Members.Add(cg4_member);
  end;
  {$ENDREGION}
  {$REGION initialization/finalization}
  aFile.Initialization:Add(new CGMethodCallExpression(nil, "RegisterExceptionClass",[cpp_ClassId(GenerateTypeExpression(l_EntityName)).AsCallParameter, cpp_DefaultNamespace.AsCallParameter].ToList));
  aFile.Finalization:Add(new CGMethodCallExpression(nil, "UnregisterExceptionClass",[cpp_ClassId(GenerateTypeExpression(l_EntityName)).AsCallParameter, cpp_DefaultNamespace.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  // I%service%
  Intf_GenerateService_I(aFile, aLibrary, aEntity);

  if AsyncSupport then begin
    //I%service%_Async
    Intf_GenerateService_I_Async(aFile, aLibrary, aEntity);

    //I%service%_AsyncEx
    Intf_GenerateService_I_AsyncEx(aFile, aLibrary, aEntity);
  end;

  //Co%service%
  Intf_GenerateService_Co(aFile, aLibrary, aEntity);

  if AsyncSupport then begin
    //Co%service%_Async
    Intf_GenerateService_Co_Async(aFile, aLibrary, aEntity);

    //Co%service%_AsyncEx
    Intf_GenerateService_Co_AsyncEx(aFile, aLibrary, aEntity);
  end;

  // T%service%_Proxy
  Intf_GenerateService_T_Proxy(aFile, aLibrary, aEntity);

  if AsyncSupport then begin
    // T%service%_AsyncProxy
    Intf_GenerateService_T_AsyncProxy(aFile, aLibrary, aEntity);

    // T%service%_AsyncProxyEx
    Intf_GenerateService_T_AsyncProxyEx(aFile, aLibrary, aEntity);
  end;

end;

method DelphiRodlCodeGen.Intf_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  var l_EntityName := aEntity.Name;
  var l_IName := "I"+l_EntityName;
  var l_EID := "EID_"+l_EntityName;
  var l_invoker := "T"+l_EntityName+"_Invoker";
  var lancestorName := aEntity.AncestorName;
  var l_IName_typeref := ResolveInterfaceTypeRef(aLibrary,l_IName,Intf_name,l_EntityName);

  {$REGION I%eventsink%}
  var ltype := new CGInterfaceTypeDefinition(l_IName);
  AddCGAttribute(ltype, attr_ROEventSink);
  AddCGAttribute(ltype, attr_ROLibraryAttributes);
  if not String.IsNullOrEmpty(lancestorName) then
    ltype.Ancestors.Add(ResolveDataTypeToTypeRefFullQualified(aLibrary, "I"+lancestorName,Intf_name,lancestorName))
  else
    ltype.Ancestors.Add("IROEventSink".AsTypeReference);


  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name,ltype, aEntity.Documentation);
  GenerateCodeFirstCustomAttributes(ltype, aEntity, false);

  ltype.InterfaceGuid := aEntity.DefaultInterface.GetOrGenerateEntityID;
  aFile.Types.Add(ltype);

  for rodl_member in aEntity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var cg4_member := new CGMethodDefinition(rodl_member.Name,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);
    cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name+"_"+rodl_member.Name,cg4_member, rodl_member.Documentation);
    GenerateCodeFirstCustomAttributes(cg4_member, rodl_member);
    for rodl_param in rodl_member.Items do begin
      if rodl_param.ParamFlag <> ParamFlags.Result then begin

        var cg4_param := new CGParameterDefinition(rodl_param.Name, ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_param.DataType, Intf_name),Modifier := RODLParamFlagToCodegenFlag(rodl_param.ParamFlag));
        if IsCodeFirstCompatible then begin
          if IsAnsiString(rodl_param.DataType) then AddCGAttribute(cg4_param,attr_ROSerializeAsAnsiString) else
          if IsUTF8String(rodl_param.DataType) then AddCGAttribute(cg4_param,attr_ROSerializeAsUTF8String);
        end;
        GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name+"_"+rodl_member.Name+"_"+rodl_param.Name, cg4_param, rodl_param.Documentation);
        GenerateCodeFirstCustomAttributes(cg4_param, rodl_param);
        cg4_member.Parameters.Add(cg4_param);
      end;
    end;
    if assigned(rodl_member.Result) then begin
      if IsCodeFirstCompatible then begin
        if IsAnsiString(rodl_member.Result.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsAnsiString) else
        if IsUTF8String(rodl_member.Result.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsUTF8String);
      end;
      cg4_member.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_member.Result.DataType, Intf_name);
    end;
    ltype.Members.Add(cg4_member);
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION "T%eventsink%_Invoker"}
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, "T"+lancestorName+"_Invoker",Intf_name,lancestorName)
  else
    lancestor := "TROEventInvoker".AsTypeReference;

  var ltype1 := new CGClassTypeDefinition(l_invoker, lancestor,
                                          Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype1);
  var IUnknown_typeref := ResolveInterfaceTypeRef(nil, "IInterface","");

  var param___EventReceiver := new CGParameterDefinition("__EventReceiver", "TROEventReceiver".AsTypeReference);
  var param___Message := new CGParameterDefinition("__Message", IROMessage_typeref, Modifier := CGParameterModifierKind.Const);
  var param___Target := new CGParameterDefinition("__Target", IUnknown_typeref, Modifier := CGParameterModifierKind.Const) ;
  var localvar___lintf := new CGVariableDeclarationStatement("__lintf", l_IName_typeref);
  for lmem in aEntity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var mem := new CGMethodDefinition("Invoke_"+lmem.Name,
                                      Parameters := [param___EventReceiver, param___Message, param___Target].ToList,
                                      LocalVariables := [localvar___lintf].ToList,
                                      Visibility := CGMemberVisibilityKind.Published,
                                      CallingConvention := CGCallingConventionKind.Register);

    var lcast := InterfaceCast(param___Target.AsExpression,
                               new CGNamedTypeReference(l_IName).AsExpression,
                               localvar___lintf.AsExpression);
    var ltry_10 := new List<CGStatement>;
    var lfin_10 := new List<CGStatement>;
    mem.Statements.Add(new CGIfThenElseStatement(
                  new CGUnaryOperatorExpression(lcast, CGUnaryOperatorKind.Not),
                  new CGThrowExpression(new CGNewInstanceExpression(new CGNamedTypeReference("EIntfCastError"),
                                              [String.Format("Critical error in {0}.{1}: __Target does not support {2} interface",[l_invoker, mem.Name, l_IName]).AsLiteralExpression.AsCallParameter]))));

    var lcall := new CGMethodCallExpression(localvar___lintf.AsExpression, lmem.Name, CallSiteKind := CGCallSiteKind.Reference);
    if lmem.Items.Count > 0 then begin
      var lNeedDisposer := false;
      for lmemparam in lmem.Items do begin
        lNeedDisposer := isComplex(aLibrary, lmemparam.DataType);
        if lNeedDisposer then break;
      end;
      var localvar___lObjectDisposer := new CGVariableDeclarationStatement("__lObjectDisposer", "TROObjectDisposer".AsTypeReference);
      var lObjectDisposer := localvar___lObjectDisposer.AsExpression;
      if lNeedDisposer then
        mem.LocalVariables.Add(localvar___lObjectDisposer);

      for lmemparam in lmem.Items do
        mem.LocalVariables.Add(new CGVariableDeclarationStatement("l_"+lmemparam.Name, ResolveDataTypeToTypeRefFullQualified(aLibrary,lmemparam.DataType, Intf_name)));

      mem.Statements.Add(new CGEmptyStatement);

      mem.Statements.Add(new CGEmptyStatement);
      var list := new List<CGStatement>;
      for litem in lmem.Items do
        list.Add(new CGMethodCallExpression(param___Message.AsExpression,
                                            "Read",
                                            [litem.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType, Intf_name)).AsCallParameter,
                                            new CGLocalVariableAccessExpression($"l_{litem.Name}").AsCallParameter(CGParameterModifierKind.Var),
                                            GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                            CallSiteKind:= CGCallSiteKind.Reference));
      for lmemparam in lmem.Items do
        lcall.Parameters.Add(new CGLocalVariableAccessExpression($"l_{lmemparam.Name}").AsCallParameter);

      list.Add(lcall);
      if lNeedDisposer then begin
        var finList := new List<CGStatement>;
        var finList2 := new List<CGStatement>;
        var List2 := new List<CGStatement>;
        var k := new CGTypeCastExpression(param___EventReceiver.AsExpression, "IROObjectRetainer".AsTypeReference, ThrowsException := true, CastKind := CGTypeCastKind.Interface);
        finList.Add(new CGAssignmentStatement(lObjectDisposer,new CGNewInstanceExpression("TROObjectDisposer".AsTypeReference,[k.AsCallParameter].ToList)));
        for lmemparam in lmem.Items do
          if isComplex(aLibrary, lmemparam.DataType) then
            List2.Add(new CGMethodCallExpression(lObjectDisposer,"Add",[new CGLocalVariableAccessExpression($"l_{lmemparam.Name}").AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));

        finList2.Add(GenerateDestroyExpression(lObjectDisposer));
        finList.Add(new CGTryFinallyCatchStatement(List2, FinallyStatements := finList2));
        ltry_10.Add(list);
        lfin_10.Add(finList);
      end
      else begin
        ltry_10.Add(list);
      end;
    end
    else begin
      ltry_10.Add(lcall);
    end;
    lfin_10.Add(new CGAssignmentStatement(localvar___lintf.AsExpression, CGNilExpression.Nil));
    mem.Statements.Add(new CGTryFinallyCatchStatement(ltry_10, FinallyStatements := lfin_10));

    ltype1.Members.Add(mem);
    {$ENDREGION}
  end;

  {$ENDREGION}


  {$REGION initialization/finalization}
  aFile.Initialization:Add(new CGMethodCallExpression(nil, "RegisterEventInvokerClass",
                                                               [l_EID.AsNamedIdentifierExpression.AsCallParameter,
                                                               cpp_ClassId(GenerateTypeExpression(l_invoker)).AsCallParameter].ToList));
  aFile.Finalization:Add(new CGMethodCallExpression(nil,"UnregisterEventInvokerClass",[l_EID.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.isComplex(aLibrary: RodlLibrary; aDataType: String): Boolean;
begin
  result := (aDataType.ToLowerInvariant in ["binary","xsdatetime"]) or
            inherited isComplex(aLibrary, aDataType);
end;

method DelphiRodlCodeGen.isPresent_SerializeInitializedStructValues_Attribute(aLibrary: RodlLibrary): Boolean;
begin
  Result :=
    aLibrary.CustomAttributes_lower.ContainsKey("serializeinitializedstructvalues") and
    (aLibrary.CustomAttributes_lower["serializeinitializedstructvalues"] = "1");
end;

method DelphiRodlCodeGen.Intf_ProcessAttributes(aEntity: RodlEntity; aType: CGClassTypeDefinition; AlwaysWrite: Boolean := false);
begin
  if not AlwaysWrite and (aEntity.CustomAttributes.Count = 0) then exit;

  var l_dict := new Dictionary<String, String>;
  for each key in aEntity.CustomAttributes.Keys do
    if GenerateServerSideAttributes or not IsServerSideAttribute(key) then
      l_dict.Add(key, aEntity.CustomAttributes[key]);


  {$REGION GetAttributeCount}
  var m1 := new CGMethodDefinition("GetAttributeCount",
                                  [new CGIntegerLiteralExpression(l_dict.Count).AsReturnStatement],
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                  Visibility := CGMemberVisibilityKind.Public,
                                  &Static := true,
                                  CallingConvention := CGCallingConventionKind.Register);
  if not AlwaysWrite then m1.Virtuality := CGMemberVirtualityKind.Override;
  aType.Members.Add(m1);
  {$ENDREGION}

  var param_aIndex := new CGParameterDefinition("aIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  {$REGION GetAttributeName}
  var lcase: CGStatement;
  if l_dict.Count > 0 then begin
    var lcases := new List<CGSwitchStatementCase>;
    for item in l_dict.Keys index i do
      lcases.Add(new CGSwitchStatementCase(new CGIntegerLiteralExpression(i),[CGStatement(item.AsLiteralExpression.AsReturnStatement)].ToList));

    lcase := new CGSwitchStatement(param_aIndex.AsExpression, lcases);
  end
  else begin
    lcase := "".AsLiteralExpression.AsReturnStatement;
  end;
  var m2 := new CGMethodDefinition("GetAttributeName",[lcase],
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                  Parameters := [param_aIndex].ToList,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  &Static := true,
                                  CallingConvention := CGCallingConventionKind.Register);
  if not AlwaysWrite then m2.Virtuality := CGMemberVirtualityKind.Override;
  aType.Members.Add(m2);
  {$ENDREGION}

  {$REGION GetAttributeValue}
  if l_dict.Count > 0 then begin
    var lcases1 := new List<CGSwitchStatementCase>;
    for item in l_dict.Values index i do
      lcases1.Add(new CGSwitchStatementCase(new CGIntegerLiteralExpression(i),[CGStatement(item.AsLiteralExpression.AsReturnStatement)].ToList));

    lcase := new CGSwitchStatement(param_aIndex.AsExpression,lcases1);
  end
  else begin
    lcase := "".AsLiteralExpression.AsReturnStatement;
  end;

  var m3 := new CGMethodDefinition("GetAttributeValue",[lcase],
                                  Parameters := [param_aIndex].ToList,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                  Visibility := CGMemberVisibilityKind.Public,
                                  &Static := true,
                                  CallingConvention := CGCallingConventionKind.Register);
  if not AlwaysWrite then m3.Virtuality := CGMemberVirtualityKind.Override;
  aType.Members.Add(m3);
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateStructCollection(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var lancestorName := aEntity.AncestorName;
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, $"{lancestorName}Collection",Intf_name,lancestorName)
  else
    lancestor := "TROCollection".AsTypeReference;

  var ltype := new CGClassTypeDefinition($"{aEntity.Name}Collection",
                                         lancestor,
                                         Visibility := CGTypeVisibilityKind.Public
                                         );
  aFile.Types.Add(ltype);

  var lm: CGMethodLikeMemberDefinition;
  {$REGION protected constructor Create(aItemClass : TCollectionItemClass); overload;}
  var param_aItemClass := new CGParameterDefinition("aItemClass", new CGNamedTypeReference("TCollectionItemClass") isclasstype(false));
  lm := new CGConstructorDefinition(
                            Parameters := [param_aItemClass].ToList,
                            Overloaded := true,
                            Visibility := CGMemberVisibilityKind.Protected,
                            CallingConvention := CGCallingConventionKind.Register
                          );
  ltype.Members.Add(lm);
  lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [param_aItemClass.AsCallParameter].ToList));
  {$ENDREGION}
  var ltyperef := ResolveDataTypeToTypeRefFullQualified(aLibrary, aEntity.Name,Intf_name);
  var param_aIndex := new CGParameterDefinition("aIndex",ResolveStdtypes(CGPredefinedTypeReference.Int32));
  {$REGION protected function GetItems(aIndex: Integer): %structtype%}
  lm := new CGMethodDefinition("GetItems",
                          Parameters := [param_aIndex].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          ReturnType := ltyperef,
                          CallingConvention := CGCallingConventionKind.Register
                          );
  ltype.Members.Add(lm);
  lm.Statements.Add(new CGTypeCastExpression(new CGPropertyAccessExpression(CGInheritedExpression.Inherited,
                                                                            "Items",
                                                                            [param_aIndex.AsCallParameter].ToList,
                                                                            CallSiteKind := CGCallSiteKind.Static),
                                             ltyperef).AsReturnStatement);
  {$ENDREGION}

  {$REGION protected procedure SetItems(aIndex: Integer; const Value: %structtype%);}
  var param_Value := new CGParameterDefinition("Value", ltyperef,Modifier := CGParameterModifierKind.Const);
  lm := new CGMethodDefinition("SetItems",
                          Parameters := [param_aIndex, param_Value].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  var localvar_lvalue := new CGVariableDeclarationStatement("lvalue",
                                                            ltyperef,
                                                            new CGTypeCastExpression(
                                                               new CGPropertyAccessExpression(CGInheritedExpression.Inherited,
                                                                                              "Items",
                                                                                              [param_aIndex.AsCallParameter].ToList,
                                                                                              CallSiteKind := CGCallSiteKind.Static),
                                                               ltyperef));
  lm.LocalVariables.Add(localvar_lvalue);
  var value_param: CGExpression := param_Value.AsExpression;
  if not PureDelphi then
    value_param := new CGTypeCastExpression(value_param, "TPersistent".AsTypeReference());

  lm.Statements.Add(new CGMethodCallExpression(
                                        localvar_lvalue.AsExpression,
                                        "Assign",
                                        [value_param.AsCallParameter].ToList,
                                        CallSiteKind := CGCallSiteKind.Reference
                                        ));
  {$ENDREGION}

  {$REGION public constructor Create; overload;}
  lm := new CGConstructorDefinition(
                            Overloaded := true,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                          );
  lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [cpp_ClassId(GenerateTypeExpression(aEntity.Name)).AsCallParameter].ToList));
  ltype.Members.Add(lm);
  {$ENDREGION}

  {$REGION public function Add: %structtype%; reintroduce;}
  lm := new CGMethodDefinition("Add",
                            ReturnType := ltyperef,
                            Visibility := CGMemberVisibilityKind.Public,
                            Reintroduced := true,
                            CallingConvention := CGCallingConventionKind.Register
                        );
  ltype.Members.Add(lm);
  lm.Statements.Add(new CGTypeCastExpression( new CGMethodCallExpression(CGInheritedExpression.Inherited,"Add",CallSiteKind := CGCallSiteKind.Static),ltyperef).AsReturnStatement);
  {$ENDREGION}

  var arr := aLibrary.Arrays.Items.Where(ar-> ar.ElementType.EqualsIgnoringCaseInvariant(aEntity.Name)).ToList;
  var localvar_i := new CGVariableDeclarationStatement("i",ResolveStdtypes(CGPredefinedTypeReference.Int32));
  for mem in arr do begin
    var param_anArray := new CGParameterDefinition("anArray",ResolveDataTypeToTypeRefFullQualified(aLibrary, mem.Name, Intf_name));
    {$REGION public procedure LoadFromArray(anArray: %arraytype%);}
    lm := new CGMethodDefinition("LoadFromArray",
                            Parameters := [param_anArray].ToList,
                            LocalVariables := [localvar_i].ToList,
                            Overloaded := arr.Count>1,
                            Visibility := CGMemberVisibilityKind.Public,

                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, "Clear",CallSiteKind := CGCallSiteKind.Reference));
    var larritem := new CGPropertyAccessExpression(nil, param_anArray.Name, [localvar_i.AsCallParameter].ToList);
    lm.Statements.Add(
      new CGForToLoopStatement(localvar_i.Name,
                               ResolveStdtypes(CGPredefinedTypeReference.Int32),
                               new CGIntegerLiteralExpression(0),
                               new CGBinaryOperatorExpression(
                                 new CGPropertyAccessExpression(param_anArray.AsExpression,
                                                             "Count",
                                                             CallSiteKind := CGCallSiteKind.Reference),
                                 new CGIntegerLiteralExpression(1),
                                 CGBinaryOperatorKind.Subtraction),
                               new CGIfThenElseStatement(
                                 new CGAssignedExpression(cpp_AddressOf(larritem)),
                                 new CGAssignmentStatement(
                                     new CGPropertyAccessExpression(
                                        new CGMethodCallExpression(larritem,
                                                                   "Clone",
                                                                   CallSiteKind := CGCallSiteKind.Instance),
                                        "Collection",
                                        CallSiteKind := CGCallSiteKind.Reference),
                                     CGSelfExpression.Self)
                                 )));
    {$ENDREGION}

    {$REGION public procedure SaveToArray(anArray: %arraytype%);}
    lm := new CGMethodDefinition("SaveToArray",
                            Parameters := [param_anArray].ToList,
                            LocalVariables := [localvar_i].ToList,
                            Overloaded := arr.Count > 1,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.Statements.Add(new CGMethodCallExpression(param_anArray.AsExpression, "Clear",CallSiteKind := CGCallSiteKind.Reference));
    larritem := new CGPropertyAccessExpression(CGSelfExpression.Self,"Items",[localvar_i.AsCallParameter].ToList, CallSiteKind := CGCallSiteKind.Reference);

    lm.Statements.Add(new CGForToLoopStatement(localvar_i.Name,
                                               ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                               new CGIntegerLiteralExpression(0),
                                               new CGBinaryOperatorExpression(new CGPropertyAccessExpression(CGSelfExpression.Self, "Count",CallSiteKind := CGCallSiteKind.Reference),
                                                                              new CGIntegerLiteralExpression(1),
                                                                              CGBinaryOperatorKind.Subtraction),
                                               new CGIfThenElseStatement(
                                                                         new CGAssignedExpression(larritem),
                                                                         new CGMethodCallExpression(param_anArray.AsExpression,"Add",[new CGTypeCastExpression(new CGMethodCallExpression(larritem,"Clone",CallSiteKind := CGCallSiteKind.Reference),ltyperef).AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference),
                                                                         new CGMethodCallExpression(param_anArray.AsExpression,"Add",[CGNilExpression.Nil.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference)
                                                                         )));

    {$ENDREGION}
  end;

  {$REGION public property Items[Index: Integer]:%structtype% read GetItems write SetItems; default;}
  ltype.Members.Add(new CGPropertyDefinition("Items",
                                    ltyperef,
                                    new CGMethodAccessExpression(nil, "GetItems"),
                                    new CGMethodAccessExpression(nil, "SetItems"),
                                    Visibility := CGMemberVisibilityKind.Public,
                                    Parameters := [new CGParameterDefinition("Index", ResolveStdtypes(CGPredefinedTypeReference.Int32))].ToList,
                                    &Default := true));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  //var lnamespace := GetNamespace(aLibrary);
  var cond := cpp_GlobalCondition_ns();
  var globalvar := new CGFieldDefinition("LibraryUID", ResolveStdtypes(CGPredefinedTypeReference.String),
                                          Constant := true,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Condition := cond,
                                          Initializer := ("{"+String(aLibrary.GetOrGenerateEntityID.ToString).ToUpperInvariant+"}").AsLiteralExpression).AsGlobal();
  aFile.Globals.Add(globalvar);
  GenerateExternalSym(globalvar);
  if aLibrary.CustomAttributes_lower.ContainsKey("wsdl") then begin
    globalvar := new CGFieldDefinition("WSDLLocation",ResolveStdtypes(CGPredefinedTypeReference.String),
                                            Constant := true,
                                            Visibility := CGMemberVisibilityKind.Public,
                                            Condition := cond,
                                            Initializer := ($"'{aLibrary.CustomAttributes_lower.Item["wsdl"]}'").AsLiteralExpression).AsGlobal();
    aFile.Globals.Add(globalvar);
    GenerateExternalSym(globalvar);
  end;
  globalvar := new CGFieldDefinition("DefaultNamespace",ResolveStdtypes(CGPredefinedTypeReference.String),
                                          Constant := true,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Condition := cond,
                                          Initializer := targetNamespace.AsLiteralExpression).AsGlobal();
  aFile.Globals.Add(globalvar);
  GenerateExternalSym(globalvar);
  var ltargetnamespace: String := "";
  if aLibrary.CustomAttributes_lower.ContainsKey("targetnamespace") then
    ltargetnamespace := aLibrary.CustomAttributes_lower.Item["targetnamespace"];
  if String.IsNullOrEmpty(ltargetnamespace ) then ltargetnamespace := targetNamespace;

  globalvar := new CGFieldDefinition("TargetNamespace", ResolveStdtypes(CGPredefinedTypeReference.String),
                                          Constant := true,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Condition := cond,
                                          Initializer :=  ltargetnamespace.AsLiteralExpression).AsGlobal();
  aFile.Globals.Add(globalvar);
  GenerateExternalSym(globalvar);
  if assigned(cond) then begin
    aFile.Globals.Add(new CGFieldDefinition(cpp_GlobalCondition_ns_name,
                                           Visibility := CGMemberVisibilityKind.Public,
                                           Condition := cond).AsGlobal());
  end;
  if not ExcludeServices then begin
    for lEntity : RodlService in aLibrary.Services.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
      if not EntityNeedsCodeGen(lEntity) then Continue;
      GlobalsConst_GenerateServerGuid(aFile, aLibrary, lEntity);
    end;
  end;

  if not ExcludeEventSinks then begin
    for lEntity : RodlEventSink in aLibrary.EventSinks.Items.Sort_OrdinalIgnoreCase(b->b.Name)  do begin
      if not EntityNeedsCodeGen(lEntity) then Continue;
      var lName := lEntity.Name;
      aFile.Globals.Add(new CGFieldDefinition(String.Format("EID_{0}",[lName]), ResolveStdtypes(CGPredefinedTypeReference.String),
                                  Constant := true,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  Initializer := (lEntity.Name).AsLiteralExpression).AsGlobal);
    end;
  end;

  for lEntity : RodlService in aLibrary.Services.Items.Sort_OrdinalIgnoreCase(b->b.Name)  do begin
    if not EntityNeedsCodeGen(lEntity) then Continue;
    var lName := lEntity.Name;
    if lEntity.CustomAttributes_lower.ContainsKey("type") and
       lEntity.CustomAttributes_lower["type"]:EqualsIgnoringCaseInvariant("SOAP") then begin
      var loc :="";
      if lEntity.CustomAttributes_lower.ContainsKey("location") then loc := lEntity.CustomAttributes_lower["location"];
      aFile.Globals.Add(new CGFieldDefinition(String.Format("{0}_EndPointURI",[lName]),ResolveStdtypes(CGPredefinedTypeReference.String),
                                              Constant := true,
                                              Visibility := CGMemberVisibilityKind.Public,
                                              Initializer := loc.AsLiteralExpression).AsGlobal);
    end;
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateRead(aFile: CGCodeUnit; aLibrary: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>;aSerializeInitializedStructValues:Boolean; aSerializer: CGExpression);
begin
  for lmem in ItemList do begin
    var local_name := new CGPropertyAccessExpression(CGSelfExpression.Self, lmem.Name, CallSiteKind := CGCallSiteKind.Reference);
    var local_int_name := new CGPropertyAccessExpression(CGSelfExpression.Self, $"int_{lmem.Name}", CallSiteKind := CGCallSiteKind.Reference);
    var local_l_name := new CGLocalVariableAccessExpression($"l_{lmem.Name}");

    var lName := lmem.OriginalName.AsLiteralExpression.AsCallParameter;
    var lValue := local_l_name.AsCallParameter;
    var lDataType := ResolveDataTypeToTypeRefFullQualified(aLibrary, lmem.DataType,Intf_name);
    aStatements.Add(Intf_generateReadStatement(aLibrary,lmem.DataType,aSerializer,lName,lValue,lDataType,nil));
    if isComplex(aLibrary,lmem.DataType)  and not isEnum(aLibrary,lmem.DataType) then begin
      var ldest := GenerateDestroyExpression(local_int_name);
      if aSerializeInitializedStructValues then
        aStatements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(local_name,local_l_name, CGBinaryOperatorKind.NotEquals), ldest))
      else
        aStatements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(local_int_name,local_l_name, CGBinaryOperatorKind.NotEquals), ldest));
    end;
    aStatements.Add(new CGAssignmentStatement(local_name, local_l_name));
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateWrite(aFile: CGCodeUnit; aLibrary: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>; aSerializeInitializedStructValues: Boolean; aSerializer: CGExpression);
begin
  for lmem in ItemList do begin
    var lt1 := new CGPropertyAccessExpression(CGSelfExpression.Self, lmem.Name,CallSiteKind := CGCallSiteKind.Reference);
    var lt2 := new CGPropertyAccessExpression(CGSelfExpression.Self, "int_"+lmem.Name,CallSiteKind := CGCallSiteKind.Reference);
    var lt3 := new CGLocalVariableAccessExpression($"l_{lmem.Name}");
    if isComplex(aLibrary, lmem.DataType) and not aSerializeInitializedStructValues then
      aStatements.Add(new CGAssignmentStatement(lt3,lt2))
    else
      aStatements.Add(new CGAssignmentStatement(lt3,lt1));

    var lName := lmem.OriginalName.AsLiteralExpression.AsCallParameter;
    var lValue := lt3.AsCallParameter;
    var lDataType := ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.DataType,Intf_name);
    aStatements.Add(Intf_generateWriteStatement(aLibrary,lmem.DataType,aSerializer,lName,lValue,lDataType,nil));
  end;
end;

method DelphiRodlCodeGen.Intf_generateReadStatement(aLibrary: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType: CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
begin
  // %aSerializer%.ReadInt64WithErrorHandling(%aName%, %aValue%);
  // %aSerializer%.ReadInt64WithErrorHandling(%aName%, %aValue%, %aIndex%);
  result := new List<CGStatement>;
  aName.Modifier := CGParameterModifierKind.Const;
  aValue.Modifier := CGParameterModifierKind.In;
  var k: CGMethodCallExpression;
  case aElementType.ToLowerInvariant of
    "integer":    k := new CGMethodCallExpression(aSerializer, "ReadInt32WithErrorHandling",[aName, aValue].ToList);
    "datetime":   k := new CGMethodCallExpression(aSerializer, "ReadDateTimeWithErrorHandling",[aName, aValue].ToList);
    "double":     k := new CGMethodCallExpression(aSerializer, "ReadDoubleWithErrorHandling",[aName, aValue].ToList);
    "currency":   k := new CGMethodCallExpression(aSerializer, "ReadCurrencyWithErrorHandling",[aName, aValue].ToList);
    "ansistring": if fLegacyStrings then
                    k := new CGMethodCallExpression(aSerializer, "ReadAnsiStringWithErrorHandling",[aName, aValue].ToList)
                  else
                    k := new CGMethodCallExpression(aSerializer, "ReadLegacyStringWithErrorHandling",[aName, aValue, GenerateParamAttributes(aElementType).AsCallParameter].ToList);
    "utf8string": if fLegacyStrings then
                    k := new CGMethodCallExpression(aSerializer, "ReadUTF8StringWithErrorHandling",[aName, aValue].ToList)
                  else
                    k := new CGMethodCallExpression(aSerializer, "ReadLegacyStringWithErrorHandling",[aName, aValue, GenerateParamAttributes(aElementType).AsCallParameter].ToList);
    "int64":      k := new CGMethodCallExpression(aSerializer, "ReadInt64WithErrorHandling",[aName, aValue].ToList);
    "boolean":    k := new CGMethodCallExpression(aSerializer, "ReadBooleanWithErrorHandling",[aName, aValue].ToList);
    "variant":    k := new CGMethodCallExpression(aSerializer, "ReadVariantWithErrorHandling",[aName, aValue].ToList);
    "binary":     k := new CGMethodCallExpression(aSerializer, "ReadBinaryWithErrorHandling",[aName, aValue].ToList);
    "xml":        k := new CGMethodCallExpression(aSerializer, "ReadXmlWithErrorHandling",[aName, aValue].ToList);
    "guid":       k := new CGMethodCallExpression(aSerializer, "ReadGuidWithErrorHandling",[aName, aValue].ToList);
    "decimal":    begin
                    k := new CGMethodCallExpression(aSerializer, "ReadDecimalWithErrorHandling",[aName, aValue].ToList);
                    if not PureDelphi then k.Name := "ReadDecimalWithErrorHandling_cpp";
                  end;
    "xsdatetime": begin aValue.Modifier := CGParameterModifierKind.Var; k := new CGMethodCallExpression(aSerializer, "ReadStructWithErrorHandling",[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList);end;
    "widestring": k := new CGMethodCallExpression(aSerializer, "ReadUnicodeStringWithErrorHandling",[aName, aValue].ToList, CallSiteKind := CGCallSiteKind.Reference);
    "nullableboolean": k := new CGMethodCallExpression(aSerializer, "ReadNullableBooleanWithErrorHandling",[aName, aValue].ToList);
    "nullablecurrency": k := new CGMethodCallExpression(aSerializer, "ReadNullableCurrencyWithErrorHandling",[aName, aValue].ToList);
    "nullabledatetime": k := new CGMethodCallExpression(aSerializer, "ReadNullableDateTimeWithErrorHandling",[aName, aValue].ToList);
    "nullabledecimal": k := new CGMethodCallExpression(aSerializer, "ReadNullableDecimalWithErrorHandling",[aName, aValue].ToList);
    "nullabledouble": k := new CGMethodCallExpression(aSerializer, "ReadNullableDoubleWithErrorHandling",[aName, aValue].ToList);
    "nullableguid": k := new CGMethodCallExpression(aSerializer, "ReadNullableGuidWithErrorHandling",[aName, aValue].ToList);
    "nullableint64": k := new CGMethodCallExpression(aSerializer, "ReadNullableInt64WithErrorHandling",[aName, aValue].ToList);
    "nullableinteger": k := new CGMethodCallExpression(aSerializer, "ReadNullableIntegerWithErrorHandling",[aName, aValue].ToList);
  else
    aValue.Modifier := CGParameterModifierKind.Var;
    if isArray(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "ReadArrayWithErrorHandling",[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList)
    else if isStruct(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "ReadStructWithErrorHandling",[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList)
    else if isException(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "ReadExceptionWithErrorHandling",[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList)
    else if isEnum(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "ReadEnumeratedWithErrorHandling",
                                                                                                            [aName,
                                                                                                            GenerateTypeInfoCall(aLibrary,aDataType).AsCallParameter,
                                                                                                            aValue].ToList)
    else
      raise new Exception(String.Format("unknown type: {0}",[aElementType]));
  end;
  if assigned(aIndex) then k.Parameters.Add(aIndex);
  k.CallSiteKind := CGCallSiteKind.Reference;
  result.Add(k);
end;

method DelphiRodlCodeGen.Intf_generateWriteStatement(aLibrary: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType: CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
begin
  // %aSerializer%.WriteInt64(%aName%, %aValue%);
  // %aSerializer%.WriteInt64(%aName%, %aValue%, %aIndex%);
  result := new List<CGStatement>;
  aName.Modifier := CGParameterModifierKind.Const;
  aValue.Modifier := CGParameterModifierKind.Var; //c++ builder should pass it by reference
  var k: CGMethodCallExpression;
  case aElementType.ToLowerInvariant of
    "integer":    k := new CGMethodCallExpression(aSerializer, "WriteInt32",[aName, aValue].ToList);
    "datetime":   k := new CGMethodCallExpression(aSerializer, "WriteDateTime",[aName, aValue].ToList);
    "double":     k := new CGMethodCallExpression(aSerializer, "WriteDouble_",[aName, aValue].ToList);
    "currency":   k := new CGMethodCallExpression(aSerializer, "WriteCurrency",[aName, aValue].ToList);
    "ansistring": if fLegacyStrings then
                    k := new CGMethodCallExpression(aSerializer, "WriteAnsiString",[aName, aValue].ToList)
                  else
                    k := new CGMethodCallExpression(aSerializer, "WriteLegacyString",[aName, aValue, GenerateParamAttributes(aElementType).AsCallParameter].ToList);
    "utf8string": if fLegacyStrings then
                    k := new CGMethodCallExpression(aSerializer, "WriteUTF8String",[aName, aValue].ToList)
                  else
                    k := new CGMethodCallExpression(aSerializer, "WriteLegacyString",[aName, aValue, GenerateParamAttributes(aElementType).AsCallParameter].ToList);
    "int64":      k := new CGMethodCallExpression(aSerializer, "WriteInt64",[aName, aValue].ToList);
    "boolean":    k := new CGMethodCallExpression(aSerializer, "WriteBoolean",[aName, aValue].ToList);
    "variant":    k := new CGMethodCallExpression(aSerializer, "WriteVariant",[aName, aValue].ToList);
    "binary":     k := new CGMethodCallExpression(aSerializer, "WriteBinary",[aName, aValue].ToList);
    "xml":        k := new CGMethodCallExpression(aSerializer, "WriteXml",[aName, aValue].ToList);
    "guid":       k := new CGMethodCallExpression(aSerializer, "WriteGuid",[aName, aValue].ToList);
    "decimal":    k := new CGMethodCallExpression(aSerializer, "WriteDecimal",[aName, aValue].ToList);
    "xsdatetime": k := new CGMethodCallExpression(aSerializer, "WriteStruct",[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList);
    "widestring": k := new CGMethodCallExpression(aSerializer, "WriteUnicodeString",[aName, aValue].ToList,CallSiteKind := CGCallSiteKind.Reference);
    "nullableboolean": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableBoolean",[aName, aValue].ToList);end;
    "nullablecurrency": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableCurrency",[aName, aValue].ToList);end;
    "nullabledatetime": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableDateTime",[aName, aValue].ToList);end;
    "nullabledecimal": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableDecimal",[aName, aValue].ToList);end;
    "nullabledouble": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableDouble",[aName, aValue].ToList);end;
    "nullableguid": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableGuid",[aName, aValue].ToList);end;
    "nullableint64": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableInt64",[aName, aValue].ToList);end;
    "nullableinteger": begin aValue.Modifier := CGParameterModifierKind.In; k := new CGMethodCallExpression(aSerializer, "WriteNullableInteger",[aName, aValue].ToList);end;

  else
    if isArray(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "WriteArray",[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList)
    else if isStruct(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "WriteStruct",[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList)
    else if isException(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "WriteException",[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList)
    else if isEnum(aLibrary,aElementType) then k := new CGMethodCallExpression(aSerializer, "WriteEnumerated",[aName,
                                                                                                              GenerateTypeInfoCall(aLibrary,aDataType).AsCallParameter,
                                                                                                              aValue].ToList);
  end;
  if k <> nil then begin
    if assigned(aIndex) then k.Parameters.Add(aIndex);
    k.CallSiteKind := CGCallSiteKind.Reference;
    result.Add(k);
  end;
end;

method DelphiRodlCodeGen.ResolveNamespace(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String := "";aCapitalize: Boolean := false): String;
begin
  try
    if not (IncludeUnitNameForOtherTypes or IncludeUnitNameForOwnTypes) then exit "";
    if String.IsNullOrEmpty(aOrigDataType) then aOrigDataType := aDataType;
    if not assigned(aLibrary) then exit "";
    var aEntity: RodlEntity := aLibrary.FindEntity(aOrigDataType);
    if assigned(aEntity) then begin
      if not EntityNeedsCodeGen(aEntity) and aEntity.IsFromUsedRodl and IncludeUnitNameForOtherTypes then begin
        var suffix: String;
        case aDefaultUnitName of
          Intf_name: suffix := "Intf";
          Invk_name: suffix := "Invk";
          Impl_name: suffix := "Impl";
        end;
        if String.IsNullOrEmpty(aEntity.FromUsedRodl:Includes:DelphiModule) then begin
          if CanUseNameSpace and not String.IsNullOrEmpty(aEntity.FromUsedRodl:&Namespace) then
            exit aEntity.FromUsedRodl:&Namespace
          else
            if CanUseNameSpace then
              exit aEntity.FromUsedRodl.Name   //c++builder
            else
              exit aEntity.FromUsedRodl.Name + "_"+suffix; //delphi
        end
        else begin
          aCapitalize := true; // delphi rodl is detected!
          exit aEntity.FromUsedRodl:Includes:DelphiModule + "_"+suffix;
        end;
      end
      else begin
        if IncludeUnitNameForOwnTypes or
            ((aEntity is RodlStructEntity) and (RodlStructEntity(aEntity).Items.Where(b->aDataType.EqualsIgnoringCaseInvariant(b.Name)).ToList.Count>0)) then begin
          if CanUseNameSpace then
            exit targetNamespace
          else
            exit aDefaultUnitName;
        end
        else
          exit "";
      end;
    end
    else begin
      exit "";
    end;
  finally
    // C++ Builder
    if (CanUseNameSpace) and not String.IsNullOrEmpty(result) and aCapitalize and (result <> targetNamespace) then begin
      result := CapitalizeString(result);
    end;
  end;
end;

method DelphiRodlCodeGen.ResolveDataTypeToTypeRefFullQualified(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String := ""; aCapitalize: Boolean := false): CGTypeReference;
begin
  var ltype := iif(String.IsNullOrEmpty(aOrigDataType), aDataType, aOrigDataType);
  var lLower := ltype.ToLowerInvariant();
  if  CodeGenTypes.ContainsKey(lLower) then
    exit CodeGenTypes[lLower]
  else begin
    var namesp := ResolveNamespace(aLibrary,aDataType,aDefaultUnitName,aOrigDataType,aCapitalize);
    if String.IsNullOrEmpty(namesp) then
      exit new CGNamedTypeReference(aDataType)
                              isClassType(isComplex(aLibrary, ltype))
    else
      exit new CGNamedTypeReference(aDataType)
                              &namespace(new CGNamespaceReference(namesp))
                              isClassType(isComplex(aLibrary, ltype));
  end;
end;

method DelphiRodlCodeGen.GenerateInvokerFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  CreateCodeFirstAttributes;
  if CodeFirstMode = State.On then
    exit ""
  else
    exit Generator.GenerateUnit(GenerateInvokerCodeUnit(aLibrary, aTargetNamespace, aUnitName));
end;

{$REGION generate _Invk}
method DelphiRodlCodeGen.Invk_GenerateInterfaceImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  aFile.Imports.Add(GenerateCGImport("SysUtils","System"));
  aFile.Imports.Add(GenerateCGImport("Classes","System"));
  aFile.Imports.Add(GenerateCGImport("TypInfo","System"));
  aFile.Imports.Add(GenerateCGImport("uROEncoding"));
  aFile.Imports.Add(GenerateCGImport("uRONullable"));
  aFile.Imports.Add(GenerateCGImport("uROXMLIntf"));
  aFile.Imports.Add(GenerateCGImport("uROServer"));
  aFile.Imports.Add(GenerateCGImport("uROServerIntf"));
  aFile.Imports.Add(GenerateCGImport("uROClasses"));
  aFile.Imports.Add(GenerateCGImport("uROTypes"));
  aFile.Imports.Add(GenerateCGImport("uROClientIntf"));
  aFile.Imports.Add(GenerateCGImport("uROEventRepository"));
  var list := new List<String>;
  for lu: RodlUse in aLibrary.Uses.Items do begin
    if not lu.DontCodegen then continue;
    var s1 := lu.Includes:DelphiModule;
    var lext := "hpp";
    if String.IsNullOrEmpty(s1) then begin
      lext := "h";
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ "_Intf";
    if not list.Contains(s1) then begin
      aFile.Imports.Add(GenerateCGImport(s1,"",lext));
      list.Add(s1);
    end;
  end;

  list := new List<String>;
  for lu: RodlUse in aLibrary.Uses.Items do begin
    if not lu.DontCodegen then continue;
    var s1 := lu.Includes:DelphiModule;
    var lext := "hpp";
    if String.IsNullOrEmpty(s1) then begin
      lext := "h";
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ "_Invk";
    if not list.Contains(s1) then begin
      aFile.Imports.Add(GenerateCGImport(s1,"",lext));
      cpp_pragmalink(aFile,CapitalizeString(s1));
      list.Add(s1);
    end;
  end;
  aFile.Imports.Add(GenerateCGImport(Intf_name,"","h", false));
end;

method DelphiRodlCodeGen.Invk_GenerateImplImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  aFile.ImplementationImports.Add(GenerateCGImport("uROSystem"));
  aFile.ImplementationImports.Add(GenerateCGImport("uRORes"));
  aFile.ImplementationImports.Add(GenerateCGImport("uROClient"));
end;

method DelphiRodlCodeGen.Invk_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_EntityName := aEntity.Name;
  var l_Iname := "I"+l_EntityName;
  var l_TInvoker := "T"+l_EntityName+"_Invoker";

  var lancestorName := aEntity.AncestorName;
  var lancestor: CGTypeReference := nil;
  {$REGION T%service%_Invoker}
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, "T"+lancestorName+"_Invoker",Invk_name,lancestorName)
  else
    lancestor := "TROInvoker".AsTypeReference;
  var ltype := new CGClassTypeDefinition(l_TInvoker,
                                         lancestor,
                                         Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype);

  var mem: CGMethodLikeMemberDefinition;
  {$REGION public  constructor Create; override;}
  mem := new CGConstructorDefinition(
                                    Visibility :=  CGMemberVisibilityKind.Public,
                                    Virtuality := CGMemberVirtualityKind.Override,
                                    CallingConvention := CGCallingConventionKind.Register);
  mem.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));
  mem.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(nil, "fAbstract"),new CGBooleanLiteralExpression(aEntity.Abstract)));
  ltype.Members.Add(mem);
  {$ENDREGION}
  var TStringArray_typeref := new CGNamedTypeReference("TStringArray") isclasstype(false);
  {$REGION protected function GetDefaultServiceRoles: TStringArray; override;}
  if aEntity.Roles.Roles.Count >0 then begin
    mem := new CGMethodDefinition("GetDefaultServiceRoles",
                                      ReturnType := TStringArray_typeref,
                                      Visibility :=  CGMemberVisibilityKind.Protected,
                                      Virtuality := CGMemberVirtualityKind.Override,
                                      CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(mem);
    var ar := new CGArrayLiteralExpression(ElementType := ResolveStdtypes(CGPredefinedTypeReference.String));
    for lr in aEntity.Roles.Roles do
      ar.Elements.Add((iif(lr.Not,"!","")+ lr.Role).AsLiteralExpression);
    Invk_GetDefaultServiceRoles(CGMethodDefinition(mem), ar);
  end;
  {$ENDREGION}
  {$REGION service methods}
  var plist := new List<CGParameterDefinition>;
  var TROResponseOptions_typeref := new CGNamedTypeReference("TROResponseOptions") isClasstype(false);

  var param__Instance := new CGParameterDefinition("__Instance", ResolveInterfaceTypeRef(nil, "IInterface","System"), Modifier := CGParameterModifierKind.Const);
  var param__Message := new CGParameterDefinition("__Message", IROMessage_typeref, Modifier := CGParameterModifierKind.Const);
  var param__Transport := new CGParameterDefinition("__Transport", IROTransport_typeref, Modifier := CGParameterModifierKind.Const);
  var param__oResponseOptions := new CGParameterDefinition("__oResponseOptions", TROResponseOptions_typeref, Modifier := CGParameterModifierKind.Out);
  plist.Add(param__Instance);
  plist.Add(param__Message);
  plist.Add(param__Transport);
  plist.Add(param__oResponseOptions);
  var lMessage := param__Message.AsExpression;
  for lmem in aEntity.DefaultInterface.Items do begin

    mem := new CGMethodDefinition("Invoke_"+lmem.Name,
                                  Parameters := plist,
                                  Visibility := CGMemberVisibilityKind.Published,
                                  CallingConvention := CGCallingConventionKind.Register);
    var lHasObjectDisposer := false;
    for lmemparam in lmem.Items do begin
      lHasObjectDisposer := isComplex(aLibrary, lmemparam.DataType);
      if lHasObjectDisposer then break;
    end;
    if assigned(lmem.Result) and isComplex(aLibrary, lmem.Result:DataType) then lHasObjectDisposer := true;

    mem.LocalVariables := new List<CGVariableDeclarationStatement>;
    for lmemparam in lmem.Items do begin
      var dt := ResolveDataTypeToTypeRefFullQualified(aLibrary,lmemparam.DataType,Intf_name);
      mem.LocalVariables.Add(new CGVariableDeclarationStatement("l_"+lmemparam.Name,dt));
      if (lmemparam.ParamFlag = ParamFlags.InOut) and isComplex(aLibrary, lmemparam.DataType) then
        mem.LocalVariables.Add(new CGVariableDeclarationStatement("__in_"+lmemparam.Name,dt));
    end;
    var localvar_lResult: CGVariableDeclarationStatement;
    if assigned(lmem.Result) then begin
      localvar_lResult := new CGVariableDeclarationStatement("lResult",ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType,Intf_name));
      mem.LocalVariables.Add(localvar_lResult);
    end;
    var localvar__lObjectDisposer := new CGVariableDeclarationStatement("__lObjectDisposer","TROObjectDisposer".AsTypeReference);
    if lHasObjectDisposer then
      mem.LocalVariables.Add(localvar__lObjectDisposer);

    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        mem.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "CheckForOutputParameters",
                                                      CallSiteKind := CGCallSiteKind.Reference
                                                      ));
        break;
      end;
    end;

    var ar := new CGArrayLiteralExpression(ElementType := ResolveStdtypes(CGPredefinedTypeReference.String));
    if lmem.Roles.Roles.Count >0 then
      for lr in lmem.Roles.Roles do
        ar.Elements.Add((iif(lr.Not,"!","")+ lr.Role).AsLiteralExpression);

    Invk_CheckRoles(CGMethodDefinition(mem),ar);

    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(aLibrary, aEntity, lmem,out p1, out p2);
    var transport_callparameter := param__Transport.AsCallParameter;
    if p1.Count > 0 then
      cpp_SetAttributes(mem.Statements, lMessage, param__Transport.AsExpression, p1, p2);
    mem.Statements.Add(new CGMethodCallExpression(lMessage,"ApplyAttributes2_Transport",[transport_callparameter].ToList,
                                                  CallSiteKind := CGCallSiteKind.Reference));
    for lmemparam in lmem.Items do begin
      if isComplex(aLibrary, lmemparam.DataType) then begin
        mem.Statements.Add(new CGAssignmentStatement(new CGLocalVariableAccessExpression("l_"+lmemparam.Name), CGNilExpression.Nil));
        if (lmemparam.ParamFlag = ParamFlags.InOut) then
          mem.Statements.Add(new CGAssignmentStatement(new CGLocalVariableAccessExpression("__in_"+lmemparam.Name), CGNilExpression.Nil));
      end;
    end;
    if assigned(lmem.Result) and isComplex(aLibrary, lmem.Result.DataType) then
      mem.Statements.Add(new CGAssignmentStatement(localvar_lResult.AsExpression,CGNilExpression.Nil));

    var localvar__lintf := new CGVariableDeclarationStatement("__lintf", ResolveInterfaceTypeRef(aLibrary,l_Iname,Intf_name,l_EntityName));
    mem.LocalVariables.Add(localvar__lintf);

    var lcast := InterfaceCast(param__Instance.AsExpression,
                               l_Iname.AsTypeReferenceExpression,
                               localvar__lintf.AsExpression);

    var ltry := new List<CGStatement>;
    var lfin := new List<CGStatement>;
    ltry.Add(new CGIfThenElseStatement(
                  new CGUnaryOperatorExpression(lcast,CGUnaryOperatorKind.Not),
                  new CGThrowExpression(new CGNewInstanceExpression("EIntfCastError".AsTypeReference,
                                              [String.Format("Critical error in {0}.{1}: __Instance does not support {2} interface",[l_TInvoker,mem.Name,l_EntityName]).AsLiteralExpression.AsCallParameter]))));
    ltry.Add(new CGEmptyStatement);
    var l_paramnames := new CGArrayLiteralExpression(ElementType := ResolveStdtypes(CGPredefinedTypeReference.String));
    for litem in lmem.Items do
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then
        l_paramnames.Elements.Add(litem.Name.AsLiteralExpression);
    if l_paramnames.Elements.Count > 0 then begin
      ltry.Add(new CGIfThenElseStatement(
                  new CGMethodCallExpression(lMessage,"CanRemapParameters", CallSiteKind := CGCallSiteKind.Reference),
                  Invk_RemapParameters(lMessage, l_paramnames)
              ));
    end;

    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        var l_param := new CGLocalVariableAccessExpression($"l_{litem.Name}");

        ltry.Add(new CGMethodCallExpression(lMessage,
                                            "Read",
                                            [litem.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                            l_param.AsCallParameter(CGParameterModifierKind.Var),
                                            GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                            CallSiteKind := CGCallSiteKind.Reference));

        if (litem.ParamFlag = ParamFlags.InOut) and isComplex(aLibrary, litem.DataType) then begin
          var localvar_in_field := new CGLocalVariableAccessExpression($"__in_{litem.Name}");
          ltry.Add(new CGAssignmentStatement(localvar_in_field, l_param));
        end;
      end;
    end;
    if lmem.Count>0 then ltry.Add(new CGEmptyStatement);
    var k := new CGMethodCallExpression(localvar__lintf.AsExpression, lmem.Name, CallSiteKind := CGCallSiteKind.Reference);
    if assigned(lmem.Result) then
      ltry.Add(new CGAssignmentStatement(localvar_lResult.AsExpression,k))
    else
      ltry.Add(k);
    for lmemparam in lmem.Items do
      if lmemparam.ParamFlag <> ParamFlags.Result then
        k.Parameters.Add(new CGLocalVariableAccessExpression("l_"+lmemparam.Name).AsCallParameter);
    ltry.Add(new CGEmptyStatement);
    ltry.Add(new CGMethodCallExpression(lMessage,
                                        "InitializeResponseMessage",
                                        [transport_callparameter,
                                        iif(aLibrary.DataSnap,"",aLibrary.Name).AsLiteralExpression.AsCallParameter,
                                        iif(aLibrary.DataSnap,
                                            l_Iname.AsLiteralExpression,
                                            new CGPropertyAccessExpression(lMessage,"InterfaceName",CallSiteKind := CGCallSiteKind.Reference)
                                            ).AsCallParameter,
                                        (lmem.Name+"Response").AsLiteralExpression.AsCallParameter
                                        ].ToList,
                                        CallSiteKind := CGCallSiteKind.Reference));
    if p1.Count > 0 then
      cpp_SetAttributes(ltry, lMessage, param__Transport.AsExpression, p1, p2);

    ltry.Add(new CGMethodCallExpression(lMessage,"ApplyAttributes2_Transport",[transport_callparameter].ToList,
                                                  CallSiteKind := CGCallSiteKind.Reference));
    {$REGION ! DataSnap}
    if not aLibrary.DataSnap then
      if assigned(lmem.Result) then begin
        ltry.Add(new CGMethodCallExpression(lMessage,
                                            "Write",
                                            [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                            localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                            GenerateParamAttributes(lmem.Result.DataType).AsCallParameter].ToList,
                                            CallSiteKind := CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        ltry.Add(new CGMethodCallExpression(lMessage,
                                            "Write",
                                            [litem.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                            new CGLocalVariableAccessExpression($"l_{litem.Name}").AsCallParameter(CGParameterModifierKind.Var),
                                            GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                            CallSiteKind := CGCallSiteKind.Reference));
      end;
    end;
    {$REGION DataSnap}
    if aLibrary.DataSnap then
      if assigned(lmem.Result) then begin
        ltry.Add(new CGMethodCallExpression(lMessage,
                                            "Write",
                                            [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                            localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                            GenerateParamAttributes(lmem.Result.DataType).AsCallParameter].ToList,
                                            CallSiteKind := CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    ltry.Add(new CGMethodCallExpression(lMessage, "Finalize", CallSiteKind := CGCallSiteKind.Reference));
    ltry.Add(new CGEmptyStatement);


    if not NeedsAsyncRetrieveOperationDefinition(lmem) then begin
      ltry.Add(new CGAssignmentStatement(param__oResponseOptions.AsExpression,
                                         new CGSetLiteralExpression([CGExpression("roNoResponse".AsNamedIdentifierExpression)].ToList,TROResponseOptions_typeref)));
      ltry.Add(new CGEmptyStatement);
    end;

    lfin.Add(new CGAssignmentStatement(localvar__lintf.AsExpression, CGNilExpression.Nil));
    if lHasObjectDisposer then begin
      var ltry2 :=new  List<CGStatement>;
      var lfin2 :=new  List<CGStatement>;
      var lObjectDisposer := localvar__lObjectDisposer.AsExpression;
      lfin.Add(new CGAssignmentStatement(lObjectDisposer, new CGNewInstanceExpression("TROObjectDisposer".AsTypeReference,[param__Instance.AsCallParameter].ToList)));

      for lmemparam in lmem.Items do
        if isComplex(aLibrary, lmemparam.DataType) then begin
          if lmemparam.ParamFlag = ParamFlags.InOut then
            ltry2.Add(new CGMethodCallExpression(lObjectDisposer,"Add",[new CGLocalVariableAccessExpression("__in_"+lmemparam.Name).AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
          ltry2.Add(new CGMethodCallExpression(lObjectDisposer,"Add",[new CGLocalVariableAccessExpression("l_"+lmemparam.Name).AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
        end;
      if assigned(lmem.Result) then
        if isComplex(aLibrary,lmem.Result.DataType) then
          ltry2.Add(new CGMethodCallExpression(lObjectDisposer,"Add",[localvar_lResult.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));


      lfin2.Add(GenerateDestroyExpression(lObjectDisposer));
      lfin.Add(new CGTryFinallyCatchStatement(ltry2, FinallyStatements := lfin2));
    end;

    mem.Statements.Add(new CGTryFinallyCatchStatement(ltry, FinallyStatements := lfin));
    ltype.Members.Add(mem);
  end;
  {$ENDREGION}
  {$ENDREGION}
  {$REGION initialization}
  for latr in aEntity.CustomAttributes.Keys do begin
    aFile.Initialization.Add(new CGMethodCallExpression(nil, "RegisterServiceAttribute",[
                                                                      l_EntityName.AsLiteralExpression.AsCallParameter,
                                                                      latr.AsLiteralExpression.AsCallParameter,
                                                                      aEntity.CustomAttributes[latr].AsLiteralExpression.AsCallParameter].ToList));
  end;
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Invk_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  var l_EntityName := aEntity.Name;
  var l_Twriter := "T"+l_EntityName+"_Writer";
  var l_IWriter := "I"+l_EntityName+"_Writer";
  var l_EID := "EID_"+l_EntityName;

  {$REGION I%eventsink%_Writer}
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, "I"+aEntity.AncestorName+"_Writer",Invk_name,aEntity.AncestorName)
  else
    lancestor := "IROEventWriter".AsTypeReference;

  var ltype := new CGInterfaceTypeDefinition(l_IWriter, lancestor);

  ltype.InterfaceGuid := aEntity.DefaultInterface.GetOrGenerateEntityID;
  aFile.Types.Add(ltype);

  var l_guidtype: CGTypeReference := new CGNamedTypeReference("TGUID") isClassType(false);
  if not PureDelphi then begin
    l_guidtype := new CGPointerTypeReference(l_guidtype) &reference(true);
  end;

  for lmem in aEntity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);
    mem.Parameters.Add(new CGParameterDefinition("__Sender", l_guidtype, Modifier := CGParameterModifierKind.Const));
    for lmemparam in lmem.Items do begin
      if lmemparam.ParamFlag <> ParamFlags.Result then
        mem.Parameters.Add(new CGParameterDefinition(lmemparam.Name, ResolveDataTypeToTypeRefFullQualified(aLibrary,lmemparam.DataType, Intf_name),Modifier := RODLParamFlagToCodegenFlag(lmemparam.ParamFlag)));
    end;
    if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType, Intf_name);
    ltype.Members.Add(mem);
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION T%eventsink%_Writer}
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, "T"+aEntity.AncestorName+"_Writer",Invk_name,aEntity.AncestorName)
  else
    lancestor := "TROEventWriter".AsTypeReference;
  var ltype1 := new CGClassTypeDefinition(l_Twriter,
                                          lancestor,
                                          [ResolveDataTypeToTypeRefFullQualified(aLibrary, l_IWriter, Invk_name, l_EntityName)].ToList,
                                          Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype1);
  var param__Sender := new CGParameterDefinition("__Sender", l_guidtype , Modifier := CGParameterModifierKind.Const);
  for lmem in aEntity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      Parameters := [param__Sender].ToList,
                                      Visibility := CGMemberVisibilityKind.Protected,
                                      CallingConvention := CGCallingConventionKind.Register);
    for lmemparam in lmem.Items do begin
      if lmemparam.ParamFlag <> ParamFlags.Result then
        mem.Parameters.Add(new CGParameterDefinition(lmemparam.Name, ResolveDataTypeToTypeRefFullQualified(aLibrary,lmemparam.DataType, Intf_name),Modifier := RODLParamFlagToCodegenFlag(lmemparam.ParamFlag)));
    end;
    if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType, Intf_name);
    ltype1.Members.Add(mem);
    mem.LocalVariables := new List<CGVariableDeclarationStatement>;
    var lbinarytype := ResolveDataTypeToTypeRefFullQualified(aLibrary,"Binary", Intf_name);
    var localvar__eventdata := new CGVariableDeclarationStatement("__eventdata", lbinarytype, new CGNewInstanceExpression(lbinarytype));
    mem.LocalVariables.Add(localvar__eventdata);
    var localvar_lMessage := new CGVariableDeclarationStatement("lMessage", IROMessage_typeref, new CGPropertyAccessExpression(nil,"__Message"));
    mem.LocalVariables.Add(localvar_lMessage);
    var l__eventdata  := localvar__eventdata.AsExpression;
    var lmessage := localvar_lMessage.AsExpression;
    var ltry := new List<CGStatement>;
    var lfin := new List<CGStatement>;
    ltry.Add(new CGMethodCallExpression(lmessage,"InitializeEventMessage",[CGNilExpression.Nil.AsCallParameter,
                                                                           aLibrary.Name.AsLiteralExpression.AsCallParameter,
                                                                           l_EID.AsNamedIdentifierExpression.AsCallParameter,
                                                                           lmem.Name.AsLiteralExpression.AsCallParameter].ToList,
                                        CallSiteKind := CGCallSiteKind.Reference));
    for litem in lmem.Items do begin
      ltry.Add(new CGMethodCallExpression(lmessage,
                                          "Write",
                                          [litem.Name.AsLiteralExpression.AsCallParameter,
                                          GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                          new CGLocalVariableAccessExpression(litem.Name).AsCallParameter(CGParameterModifierKind.Var),
                                          GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                          CallSiteKind:= CGCallSiteKind.Reference));
    end;
    ltry.Add(new CGMethodCallExpression(lmessage,"Finalize",CallSiteKind := CGCallSiteKind.Reference));
    ltry.Add(new CGEmptyStatement);
    ltry.Add(new CGMethodCallExpression(lmessage,"WriteToStream",[l__eventdata.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    ltry.Add(new CGEmptyStatement);

    var l_eventwriter: CGExpression := nil;
    var l_sender: CGExpression := param__Sender.AsExpression;

    if not PureDelphi then begin
      // for c++builder we should use interface
      var localvar_l_writer := new CGVariableDeclarationStatement(
                                      "l_writer",
                                      ResolveInterfaceTypeRef(nil, "IROEventWriter","uROClientIntf","", true),
                                      new CGTypeCastExpression(CGSelfExpression.Self,
                                                               "IROEventWriter".AsTypeReference,
                                                               ThrowsException := true,
                                                               CastKind := CGTypeCastKind.Interface));

      ltry.Add(localvar_l_writer);
      l_eventwriter := localvar_l_writer.AsExpression;
    end;

    ltry.Add(new CGMethodCallExpression(new CGPropertyAccessExpression(nil,"Repository"),
                                        "StoreEventData",
                                        [l_sender.AsCallParameter,
                                         l__eventdata.AsCallParameter,
                                         new CGPropertyAccessExpression(l_eventwriter,"ExcludeSender", CallSiteKind := CGCallSiteKind.Reference).AsCallParameter,
                                         new CGPropertyAccessExpression(l_eventwriter,"ExcludeSessionList", CallSiteKind := CGCallSiteKind.Reference).AsCallParameter,
                                         new CGPropertyAccessExpression(new CGPropertyAccessExpression(l_eventwriter, "SessionList", CallSiteKind := CGCallSiteKind.Reference),
                                                     "CommaText",CallSiteKind := CGCallSiteKind.Reference).AsCallParameter,
                                         l_EID.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                        CallSiteKind := CGCallSiteKind.Reference));
    if not PureDelphi then begin
      ltry.Add(new CGAssignmentStatement(l_eventwriter, new CGNilExpression));
    end;
    lfin.Add(GenerateDestroyExpression(l__eventdata));
    lfin.Add(new CGAssignmentStatement(lmessage,CGNilExpression.Nil));

    mem.Statements.Add(new CGTryFinallyCatchStatement(ltry, FinallyStatements := lfin));
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION initialization/finalization}
  var invk_expr:= cpp_UuidId(ResolveInterfaceTypeRef(aLibrary, l_IWriter, Invk_name, l_EntityName).AsExpression);
  aFile.Initialization:&Add(new CGMethodCallExpression(nil, "RegisterEventWriterClass",
                                                               [invk_expr.AsCallParameter,
                                                                cpp_ClassId(GenerateTypeExpression(l_Twriter)).AsCallParameter].ToList));
  aFile.Finalization:&Add(new CGMethodCallExpression(nil,"UnregisterEventWriterClass",[invk_expr.AsCallParameter].ToList));
  {$ENDREGION}

end;

method DelphiRodlCodeGen.NeedsAsyncRetrieveOperationDefinition(aEntity: RodlOperation): Boolean;
begin
  Result := assigned(aEntity.Result) or (aEntity.ForceAsyncResponse);
  if not Result then
    for lm in aEntity.Items do begin
      result := lm.ParamFlag <> ParamFlags.In;
      if result then exit;
    end;
end;

method DelphiRodlCodeGen.Invk_GetDefaultServiceRoles(&method: CGMethodDefinition; roles: CGArrayLiteralExpression);
begin
  var mce := new CGMethodCallExpression(nil,
                                        "CombineStringArrays",
                                        [new CGMethodCallExpression(CGInheritedExpression.Inherited,"GetDefaultServiceRoles").AsCallParameter,
                                        roles.AsCallParameter].ToList);
  &method.Statements.Add(mce.AsReturnStatement);
end;

method DelphiRodlCodeGen.Invk_CheckRoles(&method: CGMethodDefinition; roles: CGArrayLiteralExpression);
begin
  var mce := new CGMethodCallExpression(nil,"CheckRoles",[(new CGParameterAccessExpression("__Instance")).AsCallParameter].ToList);
  var GetDefaultServiceRoles := new CGMethodCallExpression(nil,"GetDefaultServiceRoles").AsCallParameter;
  if roles.Elements.Count >0 then begin
    mce.Parameters.Add(new CGMethodCallExpression(nil,
                                                  "CombineStringArrays",
                                                  [GetDefaultServiceRoles,
                                                  roles.AsCallParameter].ToList).AsCallParameter);
  end
  else begin
    mce.Parameters.Add(GetDefaultServiceRoles);
  end;
  &method.Statements.Add(mce);
end;
{$ENDREGION}

method DelphiRodlCodeGen.GenerateAttributes(aLibrary: RodlLibrary; aService: RodlService; aOperation: RodlOperation; out aNames: List<CGExpression>; out aValues: List<CGExpression>);
begin
  aNames := new List<CGExpression>;
  aValues := new List<CGExpression>;

  var lsa := new Dictionary<String,String>;
  var lsa_lower := new Dictionary<String,String>;
  for li in aOperation.CustomAttributes.Keys do
    if GenerateServerSideAttributes or not IsServerSideAttribute(li) then
      if not lsa_lower.ContainsKey(li.ToLowerInvariant) then begin
        lsa.Add(li, aOperation.CustomAttributes[li]);
        lsa_lower.Add(li.ToLowerInvariant, aOperation.CustomAttributes[li]);
      end;
  for li in aService.CustomAttributes.Keys do
    if GenerateServerSideAttributes or not IsServerSideAttribute(li) then
      if not lsa_lower.ContainsKey(li.ToLowerInvariant) then begin
        lsa.Add(li, aService.CustomAttributes[li]);
        lsa_lower.Add(li.ToLowerInvariant, aService.CustomAttributes[li]);
      end;
  for li in aLibrary.CustomAttributes.Keys do
    if GenerateServerSideAttributes or not IsServerSideAttribute(li) then
      if not lsa_lower.ContainsKey(li.ToLowerInvariant) then begin
        lsa.Add(li, aLibrary.CustomAttributes[li]);
        lsa_lower.Add(li.ToLowerInvariant, aLibrary.CustomAttributes[li]);
      end;

  var lsa1 := new Dictionary<String,String>;
  for li in lsa.Keys.OrderBy(b->b) do
    lsa1.Add(li, lsa[li]);
  for li in lsa1.Keys do begin
    aNames.Add(li.AsLiteralExpression);
    if li.EqualsIgnoringCaseInvariant("TargetNamespace") then aValues.Add("TargetNamespace".AsNamedIdentifierExpression)
    else if li.EqualsIgnoringCaseInvariant("Wsdl") then aValues.Add("WSDLLocation".AsNamedIdentifierExpression)
    else aValues.Add(lsa1[li].AsLiteralExpression);
  end;
end;

{$REGION generate _Async}


method DelphiRodlCodeGen.Intf_GenerateAsyncInvoke(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody:  Boolean; isInterface: Boolean): CGMethodDefinition;
begin
  result := new CGMethodDefinition("Invoke_"+aOperation.Name,
                                    CallingConvention := CGCallingConventionKind.Register);
  if not isInterface then
    result.Visibility := CGMemberVisibilityKind.Protected
  else
    result.Visibility := CGMemberVisibilityKind.Unspecified;

  for mem in aOperation.Items do begin
    if mem.ParamFlag in [ParamFlags.In, ParamFlags.InOut] then begin
      var lparam := new CGParameterDefinition(mem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(aLibrary,mem.DataType, Intf_name));
      if isComplex(aLibrary, mem.DataType) and (mem.ParamFlag = ParamFlags.In) then
        lparam.Type := new CGConstantTypeReference(lparam.Type)
      else
        lparam.Modifier := RODLParamFlagToCodegenFlag(mem.ParamFlag);
      result.Parameters.Add(lparam);
    end;
  end;
  if aNeedBody then begin
    var param_lMessage := new CGVariableDeclarationStatement("lMessage",IROMessage_typeref);
    var param_lTransportChannel := new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref);
    var lMessage := param_lMessage.AsExpression;
    var lTransportChannel := param_lTransportChannel.AsExpression;
    result.LocalVariables := [param_lMessage,param_lTransportChannel].ToList;
    result.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, "__GetMessage")));
    result.Statements.Add(new CGMethodCallExpression(lMessage,"SetAutoGeneratedNamespaces",[new CGMethodCallExpression(nil,"DefaultNamespaces").AsCallParameter],CallSiteKind := CGCallSiteKind.Reference));
    result.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGPropertyAccessExpression(nil, "__TransportChannel")));
    var ltry :=new CGTryFinallyCatchStatement();
    ////
    ltry.Statements.Add(new CGMethodCallExpression(nil,"__AssertProxyNotBusy",[aOperation.Name.AsLiteralExpression.AsCallParameter].ToList));
    ltry.Statements.Add(new CGEmptyStatement);
    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(aLibrary, aEntity, aOperation,out p1, out p2);
    if p1.Count > 0 then begin
      cpp_SetAttributes(ltry.Statements, lMessage, lTransportChannel, p1, p2);
      //ltry.Statements.Add(new CGMethodCallExpression(lMessage,"SetAttributes",[lTransportChannel.AsCallParameter,
                                                                              //new CGArrayLiteralExpression(p1, ResolveStdtypes(CGPredefinedTypeReference.String)).AsCallParameter,
                                                                              //new CGArrayLiteralExpression(p2, ResolveStdtypes(CGPredefinedTypeReference.String)).AsCallParameter].ToList,
                                                                              //CallSiteKind := CGCallSiteKind.Reference));
    end;
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                    "InitializeRequestMessage",
                                                    [lTransportChannel.AsCallParameter,
                                                    iif(aLibrary.DataSnap,"",aLibrary.Name).AsLiteralExpression.AsCallParameter,
                                                    new CGPropertyAccessExpression(nil, "__InterfaceName").AsCallParameter,
                                                    aOperation.Name.AsLiteralExpression.AsCallParameter
                                                    ].ToList,
                                                    CallSiteKind := CGCallSiteKind.Reference));
    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        "Write",
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGLocalVariableAccessExpression(litem.Name).AsCallParameter(CGParameterModifierKind.Var),
                                                        GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                                        CallSiteKind := CGCallSiteKind.Reference));
      end;
    end;

    var ld := new CGMethodCallExpression(nil,"__DispatchAsyncRequest", [aOperation.Name.AsLiteralExpression.AsCallParameter,lMessage.AsCallParameter].ToList);
    if not NeedsAsyncRetrieveOperationDefinition(aOperation) then
      ld.Parameters.Add(new CGBooleanLiteralExpression(false).AsCallParameter);
    ltry.Statements.Add(ld);
    ltry.FinallyStatements.Add(new CGMethodCallExpression(lMessage,"UnsetAttributes",[lTransportChannel.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    result.Statements.Add(ltry);
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateAsyncRetrieve(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody:  Boolean; isInterface: Boolean): CGMethodDefinition;
begin
  result := new CGMethodDefinition("Retrieve_"+aOperation.Name,
                                    CallingConvention := CGCallingConventionKind.Register);
  if not isInterface then
    result.Visibility := CGMemberVisibilityKind.Protected
  else
    result.Visibility := CGMemberVisibilityKind.Unspecified;

  for mem in aOperation.Items do begin
    if mem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out] then begin
      var lparam := new CGParameterDefinition(mem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(aLibrary, mem.DataType,Intf_name),
                                              Modifier := CGParameterModifierKind.Out);
      result.Parameters.Add(lparam);
    end;
  end;
  if assigned(aOperation.Result) then
    result.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary, aOperation.Result.DataType,Intf_name);

  if aNeedBody then begin

    var localvar__response := new CGVariableDeclarationStatement("__response","TStream".AsTypeReference);
    var localvar_tc := new CGVariableDeclarationStatement("tc","TMyTransportChannel".AsTypeReference);
    var localvar_lRetry := new CGVariableDeclarationStatement("lRetry",ResolveStdtypes(CGPredefinedTypeReference.Boolean));
    var localvar_lMessage := new CGVariableDeclarationStatement("lMessage",IROMessage_typeref);
    var localvar_lTransportChannel := new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref);
    var localvar_lFreeStream := new CGVariableDeclarationStatement("lFreeStream",ResolveStdtypes(CGPredefinedTypeReference.Boolean));
    var localvar_lResult := new CGVariableDeclarationStatement("lResult",result.ReturnType);

    var lMessage := localvar_lMessage.AsExpression;
    var lTransportChannel := localvar_lTransportChannel.AsExpression;
    var l__response := localvar__response.AsExpression;
    var lFreeStream := localvar_lFreeStream.AsExpression;
    var lretry := localvar_lRetry.AsExpression;
    var ltc := localvar_tc.AsExpression;
    result.LocalVariables := new List<CGVariableDeclarationStatement>;
    result.LocalVariables.Add(localvar__response);
    result.LocalVariables.Add(localvar_tc);
    result.LocalVariables.Add(localvar_lRetry);
    result.LocalVariables.Add(localvar_lMessage);
    result.LocalVariables.Add(localvar_lTransportChannel);
    result.LocalVariables.Add(localvar_lFreeStream);
    if assigned(aOperation.Result) then
      result.LocalVariables.Add(localvar_lResult);

    result.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, "__GetMessage")));
    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        "CheckForOutputParameters",
                                                        CallSiteKind := CGCallSiteKind.Reference
                                                        ));
        break;
      end;
    end;
    result.Statements.Add(new CGMethodCallExpression(lMessage,"SetAutoGeneratedNamespaces",[new CGMethodCallExpression(nil,"DefaultNamespaces").AsCallParameter],CallSiteKind := CGCallSiteKind.Reference));
    result.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGPropertyAccessExpression(nil, "__TransportChannel")));
    result.Statements.Add(new CGAssignmentStatement(lFreeStream, new CGBooleanLiteralExpression(false)));
////
    var ltry :=new CGTryFinallyCatchStatement();

    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out])  and isComplex(aLibrary, litem.DataType) then
        ltry.Statements.Add(new CGAssignmentStatement(new CGParameterAccessExpression(litem.Name), CGNilExpression.Nil));
    end;
    if assigned(aOperation.Result) and isComplex(aLibrary, aOperation.Result.DataType) then
      ltry.Statements.Add(new CGAssignmentStatement(localvar_lResult.AsExpression, CGNilExpression.Nil));
    ltry.Statements.Add(new CGAssignmentStatement(l__response, new CGMethodCallExpression(nil,"__RetrieveAsyncResponse",[aOperation.Name.AsLiteralExpression.AsCallParameter].ToList)));

    var ltry4 := new CGTryFinallyCatchStatement();
    ltry4.Statements.Add(new CGMethodCallExpression(lMessage,"ReadFromStream",[l__response.AsCallParameter,lFreeStream.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    var lexcept1 := new CGCatchBlockStatement("E","Exception".AsTypeReference);
    lexcept1.Statements.Add(new CGAssignmentStatement(lFreeStream, new CGBooleanLiteralExpression(true)));
    lexcept1.Statements.Add(new CGThrowExpression());
    ltry4.CatchBlocks.Add(lexcept1);
    var ltry3 := new CGTryFinallyCatchStatement();
    ltry3.Statements.Add(ltry4);
    ltry3.Statements.Add(new CGEmptyStatement);

    {$REGION ! DataSnap}
    if not aLibrary.DataSnap then
      if assigned(aOperation.Result) then begin
        ltry3.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "Read",
                                                      [aOperation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(aLibrary, ResolveDataTypeToTypeRefFullQualified(aLibrary,aOperation.Result.DataType,Intf_name)).AsCallParameter,
                                                      localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                                      GenerateParamAttributes(aOperation.Result.DataType).AsCallParameter].ToList,
                                                      CallSiteKind := CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        ltry3.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        "Read",
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGLocalVariableAccessExpression(litem.Name).AsCallParameter(CGParameterModifierKind.Var),
                                                        GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                                        CallSiteKind := CGCallSiteKind.Reference));

      end;
    end;
    {$REGION DataSnap}
    if aLibrary.DataSnap then
      if assigned(aOperation.Result) then begin
        ltry3.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "Read",
                                                      [aOperation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(aLibrary, ResolveDataTypeToTypeRefFullQualified(aLibrary,aOperation.Result.DataType,Intf_name)).AsCallParameter,
                                                      localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                                      GenerateParamAttributes(aOperation.Result.DataType).AsCallParameter].ToList,
                                                      CallSiteKind := CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    var lEROSessionNotFound := new CGCatchBlockStatement("E","EROSessionNotFound".AsTypeReference);
    lEROSessionNotFound.Statements.Add(new CGAssignmentStatement(ltc,new CGTypeCastExpression(new CGMethodCallExpression(lTransportChannel,"GetTransportObject",CallSiteKind := CGCallSiteKind.Reference),"TMyTransportChannel".AsTypeReference)));
    lEROSessionNotFound.Statements.Add(new CGAssignmentStatement(lretry, new CGBooleanLiteralExpression(false)));
    lEROSessionNotFound.Statements.Add(new CGMethodCallExpression(ltc,"DoLoginNeeded",[lMessage.AsCallParameter,new CGLocalVariableAccessExpression("E").AsCallParameter,lretry.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    lEROSessionNotFound.Statements.Add(new CGIfThenElseStatement(new CGUnaryOperatorExpression(lretry, CGUnaryOperatorKind.Not),new CGThrowExpression()));
    ltry3.CatchBlocks.Add(lEROSessionNotFound);
    var lexception :=new CGCatchBlockStatement("E","Exception".AsTypeReference);
    lexception.Statements.Add(new CGThrowExpression());
    ltry3.CatchBlocks.Add(lexception);
    var ltry2 := new CGTryFinallyCatchStatement();
    ltry2.Statements.Add(ltry3);
    ltry2.FinallyStatements.Add(new CGIfThenElseStatement(lFreeStream,
                                                          GenerateDestroyExpression(l__response)
                                                          ));
    ltry.Statements.Add(ltry2);
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    result.Statements.Add(ltry);
    if assigned(aOperation.Result) then
      result.Statements.Add(localvar_lResult.AsExpression.AsReturnStatement);

  end;
end;

method DelphiRodlCodeGen.Intf_GenerateAsyncExBegin(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody: Boolean; aMethod:Boolean; isInterface: Boolean): CGMethodDefinition;
begin
  result := new CGMethodDefinition("Begin" + aOperation.Name,
                                    CallingConvention := CGCallingConventionKind.Register,
                                    Overloaded := true);
  if not isInterface then
    result.Visibility := CGMemberVisibilityKind.Protected
  else
    result.Visibility := CGMemberVisibilityKind.Unspecified;

  for mem in aOperation.Items do begin
    if mem.ParamFlag in [ParamFlags.In, ParamFlags.InOut] then begin
      var lparam := new CGParameterDefinition(mem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(aLibrary,mem.DataType, Intf_name));
      if isComplex(aLibrary, mem.DataType) and (mem.ParamFlag = ParamFlags.In) then
        lparam.Type := new CGConstantTypeReference(lparam.Type)
      else
        lparam.Modifier := RODLParamFlagToCodegenFlag(mem.ParamFlag);
      result.Parameters.Add(lparam);
    end;
  end;


  var param_callback :=
    if aMethod then
      new CGParameterDefinition("aCallbackMethod",new CGNamedTypeReference(cpp_GetTROAsyncCallbackMethodType) isclasstype(false), Modifier :=CGParameterModifierKind.Const)
    else
      new CGParameterDefinition("aCallback",new CGNamedTypeReference(cpp_GetTROAsyncCallbackType) isclasstype(false), Modifier :=CGParameterModifierKind.Const);

  result.Parameters.Add(param_callback);

  var param_aUserData := new CGParameterDefinition("aUserData", CGPointerTypeReference.VoidPointer, DefaultValue := CGNilExpression.Nil, Modifier :=CGParameterModifierKind.Const);
  result.Parameters.Add(param_aUserData);
  result.ReturnType := ResolveInterfaceTypeRef(nil, "IROAsyncRequest","uROAsync","", true);
  if aNeedBody then begin
    var localvar_lMessage := new CGVariableDeclarationStatement("lMessage",IROMessage_typeref);
    var localvar_lTransportChannel := new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref);
    var localvar_lResult := new CGVariableDeclarationStatement("lResult",result.ReturnType);
    var lMessage := localvar_lMessage.AsExpression;
    var lTransportChannel := localvar_lTransportChannel.AsExpression;
    result.LocalVariables := new List<CGVariableDeclarationStatement>;
    result.LocalVariables.Add(localvar_lMessage);
    result.LocalVariables.Add(localvar_lTransportChannel);
    result.LocalVariables.Add(localvar_lResult);
    result.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, "__GetMessage")));
    result.Statements.Add(new CGMethodCallExpression(lMessage,"SetAutoGeneratedNamespaces",[new CGMethodCallExpression(nil,"DefaultNamespaces").AsCallParameter],CallSiteKind := CGCallSiteKind.Reference));
    result.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGPropertyAccessExpression(nil, "__TransportChannel")));
    var ltry :=new CGTryFinallyCatchStatement();
    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(aLibrary, aEntity, aOperation,out p1, out p2);
    if p1.Count > 0 then begin
      cpp_StoreAttributes2(ltry.Statements, lMessage,p1, p2);
      ltry.Statements.Add(new CGMethodCallExpression(lMessage,"ApplyAttributes2", CallSiteKind := CGCallSiteKind.Reference));
    end;
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                    "InitializeRequestMessage",
                                                    [lTransportChannel.AsCallParameter,
                                                    iif(aLibrary.DataSnap,"",aLibrary.Name).AsLiteralExpression.AsCallParameter,
                                                    new CGPropertyAccessExpression(nil, "__InterfaceName").AsCallParameter,
                                                    aOperation.Name.AsLiteralExpression.AsCallParameter
                                                    ].ToList,
                                                    CallSiteKind := CGCallSiteKind.Reference));
    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        "Write",
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGLocalVariableAccessExpression(litem.Name).AsCallParameter(CGParameterModifierKind.Var),
                                                        GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                                        CallSiteKind := CGCallSiteKind.Reference));
      end;
    end;

    ltry.Statements.Add(new CGAssignmentStatement(localvar_lResult.AsExpression,
                                                  new CGMethodCallExpression(nil,"__DispatchAsyncRequest", [lMessage.AsCallParameter,
                                                                                                            param_callback.AsCallParameter,
                                                                                                            param_aUserData.AsCallParameter].ToList)));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    result.Statements.Add(ltry);
    result.Statements.Add(localvar_lResult.AsExpression.AsReturnStatement);
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateAsyncExEnd(aLibrary: RodlLibrary; aEntity: RodlService; aOperation: RodlOperation; aNeedBody: Boolean; isInterface: Boolean): CGMethodDefinition;
begin
  result := new CGMethodDefinition("End"+aOperation.Name,
                                   CallingConvention := CGCallingConventionKind.Register);
  if not isInterface then
    result.Visibility := CGMemberVisibilityKind.Protected
  else
    result.Visibility := CGMemberVisibilityKind.Unspecified;

  for mem in aOperation.Items do begin
    if mem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out] then begin
      var lparam := new CGParameterDefinition(mem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(aLibrary, mem.DataType,Intf_name),
                                              Modifier := CGParameterModifierKind.Out);
      result.Parameters.Add(lparam);
    end;

  end;
  var param_aRequest := new CGParameterDefinition("aRequest", ResolveInterfaceTypeRef(nil, "IROAsyncRequest","uROAsync", "", true), Modifier :=CGParameterModifierKind.Const);
  result.Parameters.Add(param_aRequest);
  if assigned(aOperation.Result) then
    result.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary, aOperation.Result.DataType,Intf_name);

  if aNeedBody then begin
    var lMessage := new CGPropertyAccessExpression(param_aRequest.AsExpression, "Message",CallSiteKind := CGCallSiteKind.Reference);
    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                          "CheckForOutputParameters",
                                                          CallSiteKind := CGCallSiteKind.Reference
                                                          ));
        break;
      end;
    end;

    var localvar_lResult := new CGVariableDeclarationStatement("lResult",result.ReturnType);
    if assigned(aOperation.Result) then begin
      result.LocalVariables := new List<CGVariableDeclarationStatement>;
      result.LocalVariables.Add(localvar_lResult);
    end;
    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) and isComplex(aLibrary, litem.DataType) then
        result.Statements.Add(new CGAssignmentStatement(new CGParameterAccessExpression(litem.Name), CGNilExpression.Nil));
    end;
    if assigned(aOperation.Result) and isComplex(aLibrary, aOperation.Result.DataType) then
      result.Statements.Add(new CGAssignmentStatement(localvar_lResult.AsExpression, CGNilExpression.Nil));
    result.Statements.Add(new CGMethodCallExpression(param_aRequest.AsExpression,"ReadResponse",CallSiteKind := CGCallSiteKind.Reference));
    result.Statements.Add(new CGMethodCallExpression(lMessage,"SetAutoGeneratedNamespaces",[new CGMethodCallExpression(nil,"DefaultNamespaces").AsCallParameter],CallSiteKind := CGCallSiteKind.Reference));

    {$REGION ! DataSnap}
    if not aLibrary.DataSnap then
      if assigned(aOperation.Result) then begin
        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "Read",
                                                      [aOperation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,aOperation.Result.DataType,Intf_name)).AsCallParameter,
                                                      localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                                      GenerateParamAttributes(aOperation.Result.DataType).AsCallParameter].ToList,
                                                      CallSiteKind := CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for litem in aOperation.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        "Read",
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGLocalVariableAccessExpression(litem.Name).AsCallParameter(CGParameterModifierKind.Var),
                                                        GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                                        CallSiteKind := CGCallSiteKind.Reference));
      end;
    end;
    {$REGION DataSnap}
    if aLibrary.DataSnap then
      if assigned(aOperation.Result) then begin
        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "Read",
                                                      [aOperation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,aOperation.Result.DataType,Intf_name)).AsCallParameter,
                                                      localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                                      GenerateParamAttributes(aOperation.Result.DataType).AsCallParameter].ToList,
                                                      CallSiteKind := CGCallSiteKind.Reference));
      end;
    {$ENDREGION}

    if assigned(aOperation.Result) then
      result.Statements.Add(localvar_lResult.AsExpression.AsReturnStatement);
  end;
end;
{$ENDREGION}

method DelphiRodlCodeGen.GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>;
begin
  var lunit := GenerateImplementationCodeUnit(aLibrary, aTargetNamespace, aServiceName);
  var service := aLibrary.Services.FindEntity(aServiceName);
  result := new Dictionary<String,String>;
  result.Add(Path.ChangeExtension(lunit.FileName, Generator.defaultFileExtension),
             Generator.GenerateUnit(lunit));
  if isDFMNeeded and GenerateDFMs then begin
    result.Add(Path.ChangeExtension(lunit.FileName, "dfm"),
               String.Format(DoGenerateDFM(service),[aServiceName]));
  end;
end;

{$REGION generate _Impl}
method DelphiRodlCodeGen.Impl_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_EntityName := aEntity.Name;
  var l_IName := "I"+l_EntityName;
  var l_TName := "T"+l_EntityName;
  var l_methodName := "Create_"+l_EntityName;
  var l_zeroconf := "_"+l_EntityName+"_rosdk._tcp.";

  var field__ServiceName := new CGFieldDefinition("__ServiceName" ,
                              Constant := true,
                              Visibility := CGMemberVisibilityKind.Public,
                              Initializer := l_EntityName.AsLiteralExpression);
  var field__ServiceID := new CGFieldDefinition("__ServiceID" ,
                              Constant := true,
                              Visibility := CGMemberVisibilityKind.Public,
                              Initializer := ("{"+aEntity.DefaultInterface.GetOrGenerateEntityID.ToString+"}").AsLiteralExpression);
  if not aEntity.Abstract then begin
  {$REGION implementation method + initialization/finalization}
    var l_fClassFactory := "fClassFactory_"+l_EntityName;
    var field_fClassFactory := new CGFieldDefinition(l_fClassFactory,
                                                     ResolveInterfaceTypeRef(nil,"IROClassFactory","uROServerIntf","",true),
                                                     Visibility := CGMemberVisibilityKind.Private);

    var l_fClassFactoryExpr := field_fClassFactory.AsExpression;
    if CodeFirstMode <> State.On then begin
      var lcreator := new CGMethodDefinition(l_methodName,
                                             Parameters := [new CGParameterDefinition("anInstance", ResolveInterfaceTypeRef(nil,"IInterface",""),Modifier := CGParameterModifierKind.Out)].ToList,
                                             Visibility := CGMemberVisibilityKind.Private,
                                             CallingConvention := CGCallingConventionKind.Register);
      Impl_GenerateCreateService(lcreator, new CGNewInstanceExpression(l_TName.AsTypeReference,[CGNilExpression.Nil.AsCallParameter].ToList));
      aFile.Globals.Add(lcreator.AsGlobal);
      aFile.Globals.Add(field_fClassFactory.AsGlobal);
    end;
    aFile.Initialization := new List<CGStatement>;
    aFile.Initialization.Add(Impl_CreateClassFactory(aLibrary, aEntity, l_fClassFactoryExpr));
    if CodeFirstMode <> State.On then begin
      aFile.Initialization.Add(new CGCodeCommentStatement(new CGMethodCallExpression(nil,"RegisterForZeroConf",[l_fClassFactoryExpr.AsCallParameter,l_zeroconf.AsLiteralExpression.AsCallParameter])));
      aFile.Finalization := new List<CGStatement>;
      aFile.Finalization.Add(new CGMethodCallExpression(nil,"UnRegisterClassFactory",[l_fClassFactoryExpr.AsCallParameter].ToList));
      aFile.Finalization.Add(new CGAssignmentStatement(l_fClassFactoryExpr, CGNilExpression.Nil));
    end;
    if IsHydra then
      aFile.Initialization.Add(new CGMethodCallExpression(nil, "RegisterServicePlugin",[field__ServiceName.AsCallParameter]));
  {$ENDREGION}
  end;

  var lancestorName := GetServiceAncestor(aLibrary, aEntity);
  var lservice := new CGClassTypeDefinition(l_TName,lancestorName.AsTypeReference,[l_IName.AsTypeReference].ToList,
                                             Visibility := CGTypeVisibilityKind.Public);
  aFile.Globals.Add(field__ServiceName.AsGlobal());

  if IsCodeFirstCompatible then begin
    AddCGAttribute(lservice, attr_ROLibraryAttributes);
    if aEntity.Abstract then AddCGAttribute(lservice, attr_ROAbstract);

    aFile.Globals.Add(field__ServiceID.AsGlobal());
    AddCGAttribute(lservice,
                   new CGAttribute(
                          "ROService".AsTypeReference,
                          [field__ServiceName.AsCallParameter,
                           field__ServiceID.AsCallParameter].ToList,
                          Condition := CF_condition));
    if aEntity.Private then
      AddCGAttribute(lservice, attr_ROSkip);

    for lr in aEntity.Roles.Roles do
      AddCGAttribute(lservice,
                     new CGAttribute("RORole".AsTypeReference,
                                     [(iif(lr.Not,"!","")+ lr.Role).AsLiteralExpression.AsCallParameter].ToList,
                                     Condition := CF_condition));
  end;

  //lservice.XmlDocumentation := GenerateDocumentation(aEntity);
  GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name,lservice, aEntity.Documentation);
  GenerateCodeFirstCustomAttributes(lservice, aEntity, false);

  aFile.Types.Add(lservice);
  cpp_IUnknownSupport(aLibrary, aEntity, lservice);
  cpp_GenerateAncestorMethodCalls(aLibrary, aEntity, lservice, ModeKind.Plain);
  cpp_Impl_constructor(aLibrary, aEntity, lservice);
  for rodl_member in aEntity.DefaultInterface.Items do begin
    {$REGION service methods}
    var cg4_member := new CGMethodDefinition(rodl_member.Name,
                                      Virtuality := CGMemberVirtualityKind.Virtual,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);
    if IsCodeFirstCompatible then begin
      AddCGAttribute(cg4_member,attr_ROServiceMethod);
      if (rodl_member.Roles.Roles.Count>0) then begin
        for lr in rodl_member.Roles.Roles do
          AddCGAttribute(cg4_member,
                         new CGAttribute("RORole".AsTypeReference,
                                         [(iif(lr.Not,"!","")+ lr.Role).AsLiteralExpression.AsCallParameter].ToList,
                                         Condition := CF_condition));
      end;
    end;

    var httpapi_attr := GetHttpAPIAttribute(rodl_member);
    if assigned(httpapi_attr) then AddCGAttribute(cg4_member, httpapi_attr);
    //cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name+"_"+rodl_member.Name,cg4_member, rodl_member.Documentation);
    GenerateCodeFirstCustomAttributes(cg4_member, rodl_member);

    for rodl_param in rodl_member.Items do begin
      if rodl_param.ParamFlag <> ParamFlags.Result then begin
        var cg4_param := new CGParameterDefinition(rodl_param.Name,
                                                ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_param.DataType, Intf_name));
        if isComplex(aLibrary, rodl_param.DataType) and (rodl_param.ParamFlag = ParamFlags.In) then
          cg4_param.Type := new CGConstantTypeReference(cg4_param.Type)
        else
          cg4_param.Modifier := RODLParamFlagToCodegenFlag(rodl_param.ParamFlag);
        if IsCodeFirstCompatible then begin
          if IsAnsiString(rodl_param.DataType) then AddCGAttribute(cg4_param,attr_ROSerializeAsAnsiString) else
          if IsUTF8String(rodl_param.DataType) then AddCGAttribute(cg4_param,attr_ROSerializeAsUTF8String);
        end;
        httpapi_attr := GetHttpAPIAttribute(rodl_param);
        if assigned(httpapi_attr) then AddCGAttribute(cg4_param, httpapi_attr);
        GenerateCodeFirstDocumentation(aFile,"docs_"+aEntity.Name+"_"+rodl_member.Name+"_"+rodl_param.Name,cg4_param, rodl_param.Documentation);
        GenerateCodeFirstCustomAttributes(cg4_param, rodl_param);
        cg4_member.Parameters.Add(cg4_param);
      end;
    end;

    var lcode: String;
    if rodl_member.Code.ContainsKey("delphi") then
      lcode := rodl_member.Code["delphi"];

    if not String.IsNullOrEmpty(lcode) then
      cg4_member.Statements.Add(new CGRawStatement(lcode))
    else
      cg4_member.Statements.Add(AddMessageDirective(rodl_member.Name+" is not implemented yet!"));
    if assigned(rodl_member.Result) then begin
      if IsCodeFirstCompatible then begin
        if rodl_member.Result.Name <> "Result" then
          AddCGAttribute(cg4_member,
                         new CGAttribute("ROServiceMethodResultName".AsTypeReference,
                                         rodl_member.Result.Name.AsLiteralExpression.AsCallParameter,
                                         Condition := CF_condition));
        if IsAnsiString(rodl_member.Result.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsAnsiString) else
        if IsUTF8String(rodl_member.Result.DataType) then AddCGAttribute(cg4_member,attr_ROSerializeAsUTF8String);
      end;
      cg4_member.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_member.Result.DataType, Intf_name);
      if isComplex(aLibrary, rodl_member.Result.DataType) then
        cg4_member.Statements.Add(CGNilExpression.Nil.AsReturnStatement);
    end;
    lservice.Members.Add(cg4_member);
    {$ENDREGION}
  end;

end;

method DelphiRodlCodeGen.Impl_GenerateDFMInclude(aFile: CGCodeUnit);
begin
  case DelphiXE2Mode of
    State.On:   aFile.ImplementationDirectives.Add(new CGCompilerDirective("{%CLASSGROUP 'System.Classes.TPersistent'}"));
    State.Off:;
    State.Auto: aFile.ImplementationDirectives.Add(new CGCompilerDirective("{%CLASSGROUP 'System.Classes.TPersistent'}", new CGConditionalDefine("DELPHIXE2UP")));
  end;
  case FPCMode of
    State.On:  aFile.ImplementationDirectives.Add(new CGCompilerDirective("{$R *.lfm}"));
    State.Off: aFile.ImplementationDirectives.Add(new CGCompilerDirective("{$R *.dfm}"));
    State.Auto: begin
      aFile.ImplementationDirectives.Add(new CGCompilerDirective("{$R *.dfm}",new CGConditionalDefine("FPC") inverted(true)));
      aFile.ImplementationDirectives.Add(new CGCompilerDirective("{$R *.lfm}",new CGConditionalDefine("FPC")));
    end;
  end;
end;

method DelphiRodlCodeGen.Impl_CreateClassFactory(aLibrary: RodlLibrary; aEntity: RodlService; lvar: CGExpression): List<CGStatement>;
begin
  var r := new List<CGStatement>;
  var l_EntityName := aEntity.Name;
  var l_serviceName := "T"+l_EntityName;
  var l_TInvoker := l_serviceName+"_Invoker";
  var l_methodName := "Create_"+l_EntityName;
  var l_FPCPrefix := case FPCMode of
                       State.Auto: "{$IFDEF FPC}@{$ENDIF}";
                       State.On: "@";
                       State.Off: "";
                     end;

  var lRODLCreate := new CGAssignmentStatement(lvar,
                                 new CGNewInstanceExpression("TROClassFactory".AsTypeReference,
                                           [new CGFieldAccessExpression(nil, "__ServiceName").AsCallParameter,
                                            (l_FPCPrefix+l_methodName).AsNamedIdentifierExpression.AsCallParameter,
                                            GenerateTypeExpression(l_TInvoker).AsCallParameter]));

  case CodeFirstMode of
    State.Off: r.Add(lRODLCreate);
    State.On:  r.Add(new CGMethodCallExpression(nil,"RegisterCodeFirstService",[l_serviceName.AsNamedIdentifierExpression.AsCallParameter]));
    State.Auto: begin
      if IsCodeFirstCompatible then begin
        var lbl := new CGConditionalBlockStatement(CF_condition);
        var lCFCreate := new CGAssignmentStatement(lvar,
                                                   new CGNewInstanceExpression("TROClassFactory".AsTypeReference,
                                                   [new CGFieldAccessExpression(nil, "__ServiceName").AsCallParameter,
                                                   new CGMethodAccessExpression(nil, l_methodName).AsCallParameter,
                                                   GenerateTypeExpression("TRORTTIInvoker").AsCallParameter]));
        lbl.Statements.Add(lCFCreate);
        lbl.ElseStatements := new List<CGStatement>;
        lbl.ElseStatements.Add(lRODLCreate);
        r.Add(lbl);
      end
      else begin
        r.Add(lRODLCreate);
      end;
    end;
  end;
  exit r;
end;

method DelphiRodlCodeGen.Impl_GenerateCreateService(aMethod: CGMethodDefinition; aCreator: CGNewInstanceExpression);
begin
  aMethod.Statements.Add(new CGAssignmentStatement(new CGParameterAccessExpression("anInstance"), aCreator));
end;
{$ENDREGION}

method DelphiRodlCodeGen.RODLParamFlagToCodegenFlag(aFlag: ParamFlags): CGParameterModifierKind;
begin
  case aFlag of
    ParamFlags.In: exit CGParameterModifierKind.Const;
    ParamFlags.Out: exit CGParameterModifierKind.Out;
    ParamFlags.InOut: exit CGParameterModifierKind.Var;
  else
    raise new Exception("invalid flag");
  end;
end;

method DelphiRodlCodeGen.GetIncludesNamespace(aLibrary: RodlLibrary): String;
begin
  if assigned(aLibrary.Includes) then exit aLibrary.Includes.DelphiModule;
  exit inherited GetIncludesNamespace(aLibrary);
end;

{$REGION support methods}
method DelphiRodlCodeGen.GetServiceAncestor(aLibrary: RodlLibrary; aEntity: RodlService): String;
begin
  if not String.IsNullOrEmpty(aEntity.AncestorName) then begin
    if assigned(aEntity.AncestorEntity) then
      result := RodlService(aEntity.AncestorEntity).ImplClass;
    if String.IsNullOrEmpty(result) then exit "T"+aEntity.AncestorName
  end
  else begin
    case DefaultServerAncestor of
      DelphiServerAncestor.Remotable: exit "TRORemotable";
      DelphiServerAncestor.RemoteDataModule: exit "TRORemoteDataModule";
      DelphiServerAncestor.Custom: exit CustomAncestor;
    end;
  end;
end;

method DelphiRodlCodeGen.CapitalizeString(aValue: String): String;
begin
  exit aValue;
end;

method DelphiRodlCodeGen.DuplicateType(aTypeRef: CGTypeReference; isClass: Boolean): CGTypeReference;
begin
  if aTypeRef is CGNamedTypeReference then begin
    var lt :=  CGNamedTypeReference(aTypeRef);
    if assigned(lt.&Namespace) then
      exit new CGNamedTypeReference(lt.Name) &namespace(lt.&Namespace) isclasstype(isClass)
    else
      exit new CGNamedTypeReference(lt.Name) isclasstype(isClass)
  end
  else begin
    exit aTypeRef;
  end;
end;

method DelphiRodlCodeGen.GenerateDestroyExpression(aExpr: CGExpression): CGStatement;
begin
  exit new CGMethodCallExpression(nil, "FreeOrDisposeOf",[aExpr.AsCallParameter], CallSiteKind := CGCallSiteKind.Reference);
end;
{$ENDREGION}

method DelphiRodlCodeGen.set_CustomAncestor(value: String);
begin
  case value of
    "","TRORemoteDataModule": DefaultServerAncestor := DelphiServerAncestor.RemoteDataModule;
    "TRORemotable":           DefaultServerAncestor := DelphiServerAncestor.Remotable;
  else
    DefaultServerAncestor := DelphiServerAncestor.Custom;
  end;
  fCustomAncestor := value;
end;

method DelphiRodlCodeGen.Array_SetLength(anArray: CGExpression; aValue: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression("System".AsNamedIdentifierExpression,"SetLength",[anArray.AsCallParameter, aValue.AsCallParameter], CallSiteKind := CGCallSiteKind.Static);
end;

method DelphiRodlCodeGen.Array_GetLength(anArray: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression("System".AsNamedIdentifierExpression,"Length",[anArray.AsCallParameter].ToList, CallSiteKind := CGCallSiteKind.Static);
end;

method DelphiRodlCodeGen.RaiseError(aMessage:CGExpression; aParams:List<CGExpression>): CGStatement;
begin
  var lres := new CGMethodCallExpression("uROClasses".AsNamedIdentifierExpression, "RaiseError",[aMessage.AsCallParameter].ToList);
  if aParams <> nil then
    lres.Parameters.Add(new CGArrayLiteralExpression(aParams, ResolveStdtypes(CGPredefinedTypeReference.String)).AsCallParameter);
  exit lres;
end;

method DelphiRodlCodeGen.isDFMNeeded: Boolean;
begin
  exit DefaultServerAncestor <> DelphiServerAncestor.Remotable;
end;

method DelphiRodlCodeGen.ResolveInterfaceTypeRef(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String; aCapitalize: Boolean): CGNamedTypeReference;
begin
  // interfaces always CGNamedTypeReference
  exit CGNamedTypeReference(ResolveDataTypeToTypeRefFullQualified(aLibrary, aDataType, aDefaultUnitName, aOrigDataType, aCapitalize));
end;

method DelphiRodlCodeGen.get_IROMessage_typeref: CGTypeReference;
begin
  if fIROMessage_typeref = nil then fIROMessage_typeref := ResolveInterfaceTypeRef(nil, "IROMessage","uROClientIntf","", true);
  exit fIROMessage_typeref;
end;

method DelphiRodlCodeGen.get_IROTransportChannel_typeref: CGTypeReference;
begin
  if fIROTransportChannel_typeref = nil then fIROTransportChannel_typeref := ResolveInterfaceTypeRef(nil, "IROTransportChannel","uROClientIntf","", true);
  exit fIROTransportChannel_typeref;
end;

method DelphiRodlCodeGen.GenerateTypeInfoCall(aLibrary: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression;
begin
  exit new CGMethodCallExpression("System".AsNamedIdentifierExpression,
                                  "TypeInfo",
                                  [aTypeInfo.AsExpression.AsCallParameter].ToList);
end;

method DelphiRodlCodeGen.InterfaceCast(aSource, aType, aDest: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression(nil,
                                   "Supports",
                                   [aSource.AsCallParameter,
                                   aType.AsCallParameter,
                                   aDest.AsCallParameter].ToList);
end;

method DelphiRodlCodeGen.cppGenerateEnumTypeInfo(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var lenum_typeref := new CGNamedTypeReference(aEntity.Name) isclasstype(false);
  aFile.Globals.Add(new CGMethodDefinition("GetTypeInfo_"+aEntity.Name,
                                            [new CGMethodCallExpression(nil, "TypeInfo",[lenum_typeref.AsExpression.AsCallParameter]).AsReturnStatement],
                                            ReturnType := "PTypeInfo".AsTypeReference,
                                            Visibility := CGMemberVisibilityKind.Public,
                                            CallingConvention := CGCallingConventionKind.Register
                                            ).AsGlobal);
end;

method DelphiRodlCodeGen.GlobalsConst_GenerateServerGuid(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lname := aEntity.Name;
  aFile.Globals.Add(new CGFieldDefinition(String.Format("I{0}_IID",[lname]), "TGUID".AsTypeReference,
                              Constant := true,
                              Visibility := CGMemberVisibilityKind.Public,
                              Initializer := ("{"+String(aEntity.DefaultInterface.GetOrGenerateEntityID.ToString).ToUpperInvariant+"}").AsLiteralExpression).AsGlobal);
end;

{$REGION cpp support}

method DelphiRodlCodeGen.cppGenerateProxyCast(aProxy: CGNewInstanceExpression; aInterface: CGNamedTypeReference): List<CGStatement>;
begin
  result := new List<CGStatement>;
  result.Add(aProxy.AsReturnStatement);
end;

method DelphiRodlCodeGen.cpp_Pointer(value: CGExpression): CGExpression;
begin
  exit value;
end;

method DelphiRodlCodeGen.cpp_AddressOf(value: CGExpression): CGExpression;
begin
  exit value;
end;

method DelphiRodlCodeGen.cpp_GetTROAsyncCallbackType: String;
begin
  Result := "TROAsyncCallback";
end;

method DelphiRodlCodeGen.cpp_GetTROAsyncCallbackMethodType: String;
begin
  Result := "TROAsyncCallbackMethod";
end;

{$ENDREGION}

method DelphiRodlCodeGen.get_IROTransport_typeref: CGTypeReference;
begin
  if fIROTransport_typeref = nil then fIROTransport_typeref := ResolveInterfaceTypeRef(nil, "IROTransport","uROClientIntf","", true);
  exit fIROTransport_typeref;
end;

method DelphiRodlCodeGen.AddMessageDirective(aMessage: String): CGStatement;
begin
  exit new CGRawStatement("{$Message Hint '"+aMessage+"'}");
end;

//method DelphiRodlCodeGen.AddDynamicArrayParameter(aMethod: CGMethodCallExpression; aDynamicArrayParam: CGExpression);
//begin
  //aMethod.Parameters.Add(aDynamicArrayParam.AsCallParameter);
//end;

method DelphiRodlCodeGen.GenerateCGImport(aName: String; aCondition: CGConditionalDefine): CGImport;
begin
  exit new CGImport(new CGNamedTypeReference(aName), Condition := aCondition)
end;

method DelphiRodlCodeGen.GenerateCGImport(aName: String;aNamespace : String; aExt: String; aCapitalize: Boolean): CGImport;
begin
  if String.IsNullOrEmpty(aNamespace) then
    exit new CGImport(new CGNamedTypeReference(aName))
  else begin
    case DelphiXE2Mode of
      State.Auto: exit new CGImport(String.Format("{{$IFDEF DELPHIXE2UP}}{0}.{1}{{$ELSE}}{1}{{$ENDIF}}",[aNamespace, aName]));
      State.Off: exit new CGImport(aName);
      State.On: exit new CGImport(String.Format("{0}.{1}",[aNamespace, aName]));
    end;
  end;
end;

method DelphiRodlCodeGen.cpp_ClassId(anExpression: CGExpression): CGExpression;
begin
  exit anExpression;
end;

method DelphiRodlCodeGen.GenerateIsClause(aSource: CGExpression; aType: CGTypeReference): CGExpression;
begin
  exit new CGMethodCallExpression(aSource,"InheritsFrom",[cpp_ClassId(DuplicateType(aType, false).AsExpression).AsCallParameter],CallSiteKind := CGCallSiteKind.Reference);
end;

method DelphiRodlCodeGen.GenerateInterfaceCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String): CGCodeUnit;
begin
  CreateCodeFirstAttributes;
  ScopedEnums := ScopedEnums or aLibrary.ScopedEnums;
  //special mode, only if aLibrary.ScopedEnums is set
  IncludeUnitNameForOwnTypes := IncludeUnitNameForOwnTypes or aLibrary.ScopedEnums;
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, iif(CanUseNameSpace, aLibrary.Namespace,aLibrary.Name), aLibrary.Name, "Unknown");
  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);

  if String.IsNullOrEmpty(aUnitName) then
    lUnit.FileName := coalesce(GetIncludesNamespace(aLibrary), aLibrary.Name, "Unknown") + "_Intf"
  else
    lUnit.FileName := Path.GetFileNameWithoutExtension(aUnitName);
  Intf_name := lUnit.FileName;


  lUnit.Initialization := new List<CGStatement>;
  lUnit.Finalization := new List<CGStatement>;
  lUnit.HeaderComment := GenerateUnitComment(false);
  Add_RemObjects_Inc(lUnit, aLibrary);
  cpp_smartInit(lUnit);
  cpp_pragmalink(lUnit,CapitalizeString("uROProxy"));
  cpp_pragmalink(lUnit,CapitalizeString("uROAsync"));

  Intf_GenerateInterfaceImports(lUnit, aLibrary);
  Intf_GenerateImplImports(lUnit, aLibrary);

  AddGlobalConstants(lUnit, aLibrary);
  Intf_GenerateDefaultNamespace(lUnit, aLibrary);

  var la: CGNamedTypeReference;
  if PureDelphi then begin
    if IncludeUnitNameForOwnTypes then
      la := new CGNamedTypeReference("TLibraryAttributes") &namespace(new CGNamespaceReference(Intf_name)) isclasstype(true)
    else
      la := new CGNamedTypeReference("TLibraryAttributes") isclasstype(true);
    attr_ROLibraryAttributes := new CGAttribute("ROLibraryAttributes".AsTypeReference,
                                                [la.AsExpression.AsCallParameter],
                                                Condition := CF_condition);
    Intf_GenerateLibraryAttributes(lUnit, aLibrary);
  end;

  if not ExcludeClasses then begin
    if aLibrary.Enums.Count >0 then begin
      if PureDelphi and ScopedEnums then
        lUnit.Directives.Add(new CGCompilerDirective("{$SCOPEDENUMS ON}"));

      for aEntity: RodlEnum in aLibrary.Enums.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
        if not EntityNeedsCodeGen(aEntity) then Continue;
        Intf_GenerateEnum(lUnit, aLibrary, aEntity);
      end;
    end;

    for aEntity: RodlStruct in aLibrary.Structs.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      Intf_GenerateStruct(lUnit, aLibrary, aEntity);
      Intf_GenerateStructCollection(lUnit, aLibrary, aEntity);
    end;

    for aEntity: RodlArray in aLibrary.Arrays.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      Intf_GenerateArray(lUnit, aLibrary, aEntity);
    end;

    for aEntity: RodlException in aLibrary.Exceptions.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      Intf_GenerateException(lUnit, aLibrary, aEntity);
    end;
  end;

  if not ExcludeServices then begin

    if aLibrary.Services.Items.Count > 0 then begin
      var ltype := new CGClassTypeDefinition("TMyTransportChannel",
                                         "TROTransportChannel".AsTypeReference,
                                         Visibility := CGTypeVisibilityKind.Unit);
      cpp_generateDoLoginNeeded(ltype);
      lUnit.Types.Add(ltype);
    end;

    for aEntity: RodlService in aLibrary.Services.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      Intf_GenerateService(lUnit, aLibrary, aEntity);
    end;
  end;

  if not ExcludeEventSinks then begin
    for aEntity: RodlEventSink in aLibrary.EventSinks.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then Continue;
      Intf_GenerateEventSink(lUnit, aLibrary, aEntity);
    end;
  end;

  exit lUnit;
end;

method DelphiRodlCodeGen.GenerateInvokerCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String): CGCodeUnit;
begin
  CreateCodeFirstAttributes;
  if CodeFirstMode = State.On then exit nil;
  IncludeUnitNameForOwnTypes := true;
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, iif(CanUseNameSpace, aLibrary.Namespace,aLibrary.Name), aLibrary.Name, "Unknown");
  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  if String.IsNullOrEmpty(aUnitName) then
    lUnit.FileName := coalesce(GetIncludesNamespace(aLibrary), aLibrary.Name, "Unknown") + "_Invk"
  else
    lUnit.FileName := Path.GetFileNameWithoutExtension(aUnitName);

  Invk_name := lUnit.FileName;
  Intf_name := Invk_name.Substring(0,Invk_name.Length-5)+"_Intf";
  lUnit.Initialization := new List<CGStatement>;
  lUnit.Finalization := new List<CGStatement>;
  lUnit.HeaderComment := GenerateUnitComment(false);
  Add_RemObjects_Inc(lUnit, aLibrary);
  Invk_GenerateInterfaceImports(lUnit, aLibrary);
  cpp_smartInit(lUnit);
  Invk_GenerateImplImports(lUnit, aLibrary);
  cpp_pragmalink(lUnit,CapitalizeString("uROServer"));

  for aEntity: RodlService in aLibrary.Services.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then Continue;
    Invk_GenerateService(lUnit, aLibrary, aEntity);
  end;

  for aEntity: RodlEventSink in aLibrary.EventSinks.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then Continue;
    Invk_GenerateEventSink(lUnit, aLibrary, aEntity);
  end;

  {$REGION initialization}
  if (aLibrary.Services.Count > 0) or (aLibrary.EventSinks.Count > 0) then begin
    for latr in aLibrary.CustomAttributes.Keys do begin
      var latr1 := latr.ToLowerInvariant;
      lUnit.Initialization.Add(new CGMethodCallExpression(nil, "RegisterServiceAttribute",
                                                               ["".AsLiteralExpression.AsCallParameter,
                                                                latr.AsLiteralExpression.AsCallParameter,
                                                               (if latr1 = "wsdl" then "WSDLLocation".AsNamedIdentifierExpression
                                                                else if latr1 = "targetnamespace" then "TargetNamespace".AsNamedIdentifierExpression
                                                                else aLibrary.CustomAttributes[latr].AsLiteralExpression).AsCallParameter].ToList));
    end;
  end;
  {$ENDREGION}
  exit lUnit;
end;

method DelphiRodlCodeGen.GenerateImplementationCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit;
begin
  CreateCodeFirstAttributes;
  var service := aLibrary.Services.FindEntity(aServiceName);
  if service = nil then raise new Exception(String.Format("{0} wasn""t found!",[aServiceName]));
  if service.IsFromUsedRodl then begin
    aLibrary := service.FromUsedRodl.OwnerLibrary;
  end;
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, iif(CanUseNameSpace, aLibrary.Namespace,aLibrary.Name), aLibrary.Name, "Unknown");
  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  lUnit.FileName := aServiceName+ "_Impl";
  Impl_name := lUnit.FileName;

  var lunitname: String := coalesce(GetIncludesNamespace(aLibrary), aLibrary.Name, "Unknown");
  Intf_name := lunitname+ "_Intf";
  Invk_name := lunitname+ "_Invk";

  attr_ROLibraryAttributes := new CGAttribute("ROLibraryAttributes".AsTypeReference,
                                              [(new CGNamedTypeReference("TLibraryAttributes") &namespace(new CGNamespaceReference(Intf_name)) isclasstype(false)).AsExpression.AsCallParameter],
                                              Condition := CF_condition);

  lUnit.HeaderComment := GenerateUnitComment(true);
  Add_RemObjects_Inc(lUnit, aLibrary);
  {$REGION interface uses}
  lUnit.Imports.Add(GenerateCGImport("SysUtils","System"));
  lUnit.Imports.Add(GenerateCGImport("Classes","System"));
  lUnit.Imports.Add(GenerateCGImport("TypInfo","System"));
  if PureDelphi then begin
    if IsCodeFirstCompatible then lUnit.Imports.Add(GenerateCGImport("uRORTTIAttributes", CF_condition));
    if IsGenericArrayCompatible then lUnit.Imports.Add(GenerateCGImport("uROArray", cond_ROUseGenerics));
  end;
  lUnit.Imports.Add(GenerateCGImport("uROEncoding"));
  lUnit.Imports.Add(GenerateCGImport("uROXMLIntf"));
  lUnit.Imports.Add(GenerateCGImport("uROClientIntf"));
  lUnit.Imports.Add(GenerateCGImport("uRONullable"));
  lUnit.Imports.Add(GenerateCGImport("uROClasses"));
  lUnit.Imports.Add(GenerateCGImport("uROTypes"));
  lUnit.Imports.Add(GenerateCGImport("uROServer"));
  lUnit.Imports.Add(GenerateCGImport("uROServerIntf"));
  lUnit.Imports.Add(GenerateCGImport("uROSessions"));
  case DefaultServerAncestor of
    DelphiServerAncestor.Remotable: ;
    DelphiServerAncestor.RemoteDataModule: lUnit.Imports.Add(GenerateCGImport("uRORemoteDataModule"));
    DelphiServerAncestor.Custom: begin
      for each it in CustomUses.Split(",", true) do
        lUnit.Imports.Add(GenerateCGImport(it.Trim()));
    end;
  end;

  if IsHydra then begin
    lUnit.Imports.Add(GenerateCGImport("Hydra.Core.ModuleController"));
  end;
  if service.AncestorEntity <> nil then begin
    var anc_unit := RodlService(service.AncestorEntity).ImplUnit;
    if String.IsNullOrEmpty(anc_unit) then anc_unit := service.AncestorName+"_Impl";

    {$REGION generate uses for DA service }
    var da_Service := new Guid("{709489E3-3AFE-4449-84C3-305C2862B348}");
    var isDAFound := false;
    var ls: RodlEntityWithAncestor := service;
    while ls.AncestorEntity <> nil do begin
      isDAFound := ls.AncestorEntity.GetOrGenerateEntityID.Equals(da_Service);
      if isDAFound then Break;
      ls := ls.AncestorEntity as RodlEntityWithAncestor;
    end;
    if isDAFound then begin
      lUnit.Imports.Add(GenerateCGImport("uDAInterfaces"));
      lUnit.Imports.Add(GenerateCGImport("uDAServerInterfaces"));
      lUnit.Imports.Add(GenerateCGImport("uDADelta"));
      lUnit.Imports.Add(GenerateCGImport("uDABusinessProcessor"));
      lUnit.Imports.Add(GenerateCGImport("uDASchema"));
    end;
    {$ENDREGION}
    var lext := "hpp";
    if assigned(service.AncestorEntity.FromUsedRodl) then begin
      var s1 := service.AncestorEntity.FromUsedRodl.Includes:DelphiModule;
      if String.IsNullOrEmpty(s1) then
        lext := "h";
    end
    else begin
      if service.AncestorEntity.OwnerLibrary = aLibrary then lext := "h";
    end;


    lUnit.Imports.Add(GenerateCGImport(anc_unit, "", lext, service.AncestorEntity:OwnerLibrary <> aLibrary));
    cpp_pragmalink(lUnit, CapitalizeString(anc_unit));
  end;

  var list := new List<String>;
  for lu: RodlUse in aLibrary.Uses.Items do begin
    if not lu.DontCodegen then continue;
    var s1 := lu.Includes:DelphiModule;
    var lext := "hpp";
    if String.IsNullOrEmpty(s1) then begin
      lext := "h";
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ "_Intf";
    if not list.Contains(s1) then begin
      lUnit.Imports.Add(GenerateCGImport(s1,"",lext));
      list.Add(s1);
    end;
  end;

  lUnit.Imports.Add(GenerateCGImport(Intf_name,"","h", false));
  {$ENDREGION}
  cpp_smartInit(lUnit);
  cpp_pragmalink(lUnit,CapitalizeString("uRORemoteDataModule"));
  cpp_pragmalink(lUnit,CapitalizeString("uROServer"));
  if isDFMNeeded then Impl_GenerateDFMInclude(lUnit);

  if not service.Abstract then begin
  {$REGION implementation uses}
    list := new List<String>;
    for lu: RodlUse in aLibrary.Uses.Items do begin
      if not lu.DontCodegen then continue;
      var s1 := lu.Includes:DelphiModule;
      var lext := "hpp";
      if String.IsNullOrEmpty(s1) then begin
        lext := "h";
        s1 := lu.Name;
        if String.IsNullOrEmpty(s1) then
          s1 := Path.GetFileNameWithoutExtension(lu.FileName);
      end;
      s1 := s1+ "_Invk";
      if not list.Contains(s1) then begin
        case CodeFirstMode of
          State.Auto: lUnit.ImplementationImports.Add(GenerateCGImport(s1, CF_condition_inverted));
          State.Off: lUnit.ImplementationImports.Add(GenerateCGImport(s1,"",lext));
          State.On: ;
        end;
        list.Add(s1);
      end;
    end;
    case CodeFirstMode of
      State.Auto: lUnit.ImplementationImports.Add(GenerateCGImport("{$IFDEF RO_RTTI_Support}uRORTTIServerSupport{$ELSE}"+Invk_name+"{$ENDIF}", nil));
      State.Off:  lUnit.ImplementationImports.Add(GenerateCGImport(Invk_name,"","h", false));
      State.On:   ;
    end;
  {$ENDREGION}
  end;
  Impl_GenerateService(lUnit, aLibrary, service);
  exit lUnit;
end;


method DelphiRodlCodeGen.DoGenerateDFM(service: RodlService): String;
begin
    var dfm: String := (if String.IsNullOrEmpty(service.AncestorName) then
                        "object {0}: T{0}"
                       else
                        "inherited {0}: T{0}")+ #13#10;
    if service.RequireSession then
      dfm := dfm + "  RequireSession = True"#13#10;
    exit dfm+
               "  OldCreateOrder = True"#13#10+
               "  Height = 300"#13#10+
               "  Width = 300"#13#10+
               "end";

end;

method DelphiRodlCodeGen.GenerateImplementationFiles(aFile: CGCodeUnit; aLibrary: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;
begin
  CreateCodeFirstAttributes;
  var service := aLibrary.Services.FindEntity(aServiceName);
  result := new Dictionary<String,String>;
  result.Add(Path.ChangeExtension(aFile.FileName, Generator.defaultFileExtension),
             Generator.GenerateUnit(aFile));
  if isDFMNeeded and GenerateDFMs then begin
    result.Add(Path.ChangeExtension(aFile.FileName, "dfm"),
               String.Format(DoGenerateDFM(service),[aServiceName]));
  end;
end;

method DelphiRodlCodeGen.GenerateParamAttributes(aName: String): CGSetLiteralExpression;
begin
  var sa := new CGSetLiteralExpression(ElementType := fParamAttributes_typeref);
  if aName.EqualsIgnoringCaseInvariant("DateTime") then sa.Elements.Add("paIsDateTime".AsNamedIdentifierExpression);
  if not fLegacyStrings then begin
    if IsAnsiString(aName) then sa.Elements.Add("paAsAnsiString".AsNamedIdentifierExpression) else
    if IsUTF8String(aName) then sa.Elements.Add("paAsUTF8String".AsNamedIdentifierExpression);
  end;
  exit sa;
end;

method DelphiRodlCodeGen._SetLegacyStrings(value: Boolean);
begin
  if fLegacyStrings <> value then begin
    fLegacyStrings := value;
    if fLegacyStrings then begin
      CodeGenTypes.Item["ansistring"] := String("AnsiString").AsTypeReference;
      CodeGenTypes.Item["utf8string"] := String("UTF8String").AsTypeReference;
    end
    else begin
      CodeGenTypes.Item["ansistring"] := String("ROAnsiString").AsTypeReference;
      CodeGenTypes.Item["utf8string"] := String("ROUTF8String").AsTypeReference;
    end;
  end;
end;

method DelphiRodlCodeGen.cpp_DefaultNamespace:CGExpression;
begin
  exit new CGFieldAccessExpression(Intf_name.AsNamedIdentifierExpression, "DefaultNamespace", CallSiteKind := CGCallSiteKind.Static);
end;

method DelphiRodlCodeGen.CreateCodeFirstAttributes;
begin
  if PureDelphi then begin
    if FPCMode = State.On then begin
      DelphiXE2Mode := State.Off;
      CodeFirstMode := State.Off;
      GenericArrayMode := State.Off;
    end;
    if DelphiXE2Mode = State.Off then begin
      CodeFirstMode := State.Off;
      GenericArrayMode := State.Off;
    end;
    if CodeFirstMode = State.On then
      DelphiXE2Mode := State.On;
    //if CodeFirstMode = State.Off then
      //GenericArrayMode := State.Off;
    if GenericArrayMode = State.On then begin
      DelphiXE2Mode := State.On;
      //CodeFirstMode := State.On;
    end;
    if DelphiXE2Mode = State.On then
      FPCMode := State.Off;

    if (CodeFirstMode = State.Auto) then begin
      CF_condition := new CGConditionalDefine("RO_RTTI_Support");
      CF_condition_inverted := new CGConditionalDefine("RO_RTTI_Support") inverted(true);
    end;
    if (GenericArrayMode = State.Auto) then begin
      cond_ROUseGenerics := new CGConditionalDefine("ROUseGenerics");
      cond_ROUseGenerics_inverted := new CGConditionalDefine("ROUseGenerics") inverted(true);
    end;
  end;

  attr_ROSerializeAsAnsiString := new CGAttribute("ROStreamAs".AsTypeReference,
                                                  "emAnsi".AsNamedIdentifierExpression.AsCallParameter,
                                                  Condition := CF_condition);
  attr_ROSerializeAsUTF8String := new CGAttribute("ROStreamAs".AsTypeReference,
                                                  "emUTF8".AsNamedIdentifierExpression.AsCallParameter,
                                                  Condition := CF_condition);

  attr_ROServiceMethod := new CGAttribute("ROServiceMethod".AsTypeReference,
                                          Condition := CF_condition);
  attr_ROEventSink := new CGAttribute("ROEventSink".AsTypeReference,
                                      Condition := CF_condition);
  attr_ROSkip := new CGAttribute("ROSkip".AsTypeReference,
                                 Condition := CF_condition);
  attr_ROAbstract := new CGAttribute("ROAbstract".AsTypeReference,
                                     Condition := CF_condition);

end;

method DelphiRodlCodeGen.AddCGAttribute(aType: CGEntity; anAttribute:CGAttribute);
begin
  if IsCodeFirstCompatible then begin
    if aType is CGTypeDefinition then begin
      var ltype :=  CGTypeDefinition(aType);
      ltype.Attributes.Add(anAttribute);
      ltype.Comment := nil;
    end
    else if aType is CGMemberDefinition then begin
      var ltype :=  CGMemberDefinition(aType);
      ltype.Attributes.Add(anAttribute);
      ltype.Comment := nil;
    end
    else if aType is CGParameterDefinition then begin
      var ltype :=  CGParameterDefinition(aType);
      ltype.Attributes.Add(anAttribute);
    end
    else begin
      raise new Exception("unknown type");
    end;
  end;
end;

method DelphiRodlCodeGen.GenerateCodeFirstDocumentation(aFile: CGCodeUnit; aName: String; aType: CGEntity; aDoc: String);
begin
  if GenerateDocumentation and IsCodeFirstCompatible and not String.IsNullOrEmpty(aDoc) then begin
    aFile.Globals.Add(new CGFieldDefinition(aName,
                    Constant := true,
                    Visibility := CGMemberVisibilityKind.Public,
                    Initializer := aDoc.AsLiteralExpression,
                    Condition := CF_condition).AsGlobal());
    var attr := new CGAttribute("RODocumentation".AsTypeReference,
                                [new CGLocalVariableAccessExpression(aName).AsCallParameter],
                                Condition := CF_condition);
    AddCGAttribute(aType, attr);
  end;
end;

method GetAttributeValue(aEntity: RodlEntity; aKey: String): String;
begin
  if aEntity.CustomAttributes_lower.ContainsKey(aKey) then
    exit aEntity.CustomAttributes_lower[aKey]
  else
    exit nil;
end;

method DelphiRodlCodeGen.GetHttpAPIAttribute(aEntity: RodlEntity): CGAttribute;
begin
  result := nil;
  if aEntity is RodlOperation then begin
    var l_path := GetAttributeValue(aEntity, "httpapipath");
    if not String.IsNullOrEmpty(l_path) then begin
      var l_method := GetAttributeValue(aEntity, "httpapimethod");
      var l_resultcode := GetAttributeValue(aEntity, "httpapiresult");
      var l_result_int: Integer := 200;
      if not String.IsNullOrEmpty(l_resultcode) then begin
        var temp := Convert.TryToInt32(l_resultcode);
        if not assigned(temp) then begin
          l_resultcode := nil;
          l_result_int := 200;
        end
        else begin
          l_result_int := temp;
        end;
      end;
      var l_tags := GetAttributeValue(aEntity, "httpapitags");
      var l_operationId := GetAttributeValue(aEntity, "httpapioperationid");
      var l_requestName := GetAttributeValue(aEntity, "httpapirequestname");

      var attr := new CGAttribute("ROHttpAPIMethod".AsTypeReference,
                                  l_path.AsLiteralExpression.AsCallParameter,
                                  Condition := CF_condition);

      var l_need_RequestName := not String.IsNullOrEmpty(l_requestName);
      var l_need_OperationId := not String.IsNullOrEmpty(l_operationId) or l_need_RequestName;
      var l_need_Tags := not String.IsNullOrEmpty(l_tags) or l_need_OperationId;
      var l_need_ResultCode := not String.IsNullOrEmpty(l_resultcode) or l_need_Tags;
      var l_need_Method := not String.IsNullOrEmpty(l_method) or l_need_ResultCode;

      if l_need_Method then begin
        if String.IsNullOrEmpty(l_method) then l_method := "POST";
        attr.Parameters.Add(l_method.AsLiteralExpression.AsCallParameter);
        if l_need_ResultCode then begin
          attr.Parameters.Add(l_result_int.AsLiteralExpression.AsCallParameter);
          if l_need_Tags then begin
            if String.IsNullOrEmpty(l_tags) then l_tags := "";
            attr.Parameters.Add(l_tags.AsLiteralExpression.AsCallParameter);
            if l_need_OperationId then begin
              if String.IsNullOrEmpty(l_operationId) then l_operationId := "";
              attr.Parameters.Add(l_operationId.AsLiteralExpression.AsCallParameter);
              if l_need_RequestName then
                attr.Parameters.Add(l_requestName.AsLiteralExpression.AsCallParameter);
            end;
          end;
        end;
      end;
      exit attr;
    end;
  end
  else if aEntity is RodlParameter then begin
    if GetAttributeValue(aEntity, "httpapiqueryparameter") = "1" then
      exit new CGAttribute("ROHttpAPIQueryParameter".AsTypeReference,
                           Condition := CF_condition)
    else if GetAttributeValue(aEntity, "httpapiheaderparameter") = "1" then
      exit new CGAttribute("ROHttpAPIHeaderParameter".AsTypeReference,
                           Condition := CF_condition)
  end;
end;

method DelphiRodlCodeGen.GenerateCodeFirstCustomAttributes(aType: CGEntity; aEntity:RodlEntity; aExcludeServiceGroups: Boolean := true);
begin
  if IsCodeFirstCompatible then begin
    for k in aEntity.CustomAttributes.Keys do begin

      if IsHttpAPIAttribute(k) then continue;
      if aExcludeServiceGroups and k.EqualsIgnoringCase("ROServiceGroups") then continue;
      if k.EqualsIgnoringCase("ROServiceGroups") then begin
        for it in aEntity.CustomAttributes[k].Split(",", true) do begin
          var attr := new CGAttribute("ROServiceGroup".AsTypeReference,
                                      [it.AsLiteralExpression.AsCallParameter]);
          if CodeFirstMode = State.Auto then attr.Condition := CF_condition;
          AddCGAttribute(aType, attr);
        end;
      end
      else begin
        var attr := new CGAttribute("ROCustom".AsTypeReference,
                                    [k.AsLiteralExpression.AsCallParameter,
                                     aEntity.CustomAttributes[k].AsLiteralExpression.AsCallParameter]);
        if CodeFirstMode = State.Auto then attr.Condition := CF_condition;
        AddCGAttribute(aType, attr);
      end;
    end;
  end;
end;

method DelphiRodlCodeGen.cpp_GetNamespaceForUses(aUse: RodlUse):String;
begin
  if not String.IsNullOrEmpty(aUse.Includes:DelphiModule) then
    exit aUse.Includes.DelphiModule + "_Intf" // std RODL like DA, DA_simple => delphi mode
  else
    exit aUse.Name+"_Intf";
end;

method DelphiRodlCodeGen.isDAProject(aLibrary: RodlLibrary): Boolean;
begin
  case caseInsensitive(aLibrary.GetOrGenerateEntityID:ToString) of
    "DC8B7BE2-14AF-402D-B1F8-E1008B6FA4F6": exit true; //"DataAbstract4.RODL"
    "367FA81F-09B7-4294-85AD-68C140EF1FA7": exit true; //"DataAbstract-Simple.RODL"
  end;
  for k: RodlUse in aLibrary.Uses:Items do
    if Path.GetFileName(k.FileName).ToUpperInvariant in ["DATAABSTRACT4.RODL", "DATAABSTRACT-SIMPLE.RODL"] then exit true;
  exit false;
end;

method DelphiRodlCodeGen.GetRODLName(aLibrary: RodlLibrary): String;
begin
  if not String.IsNullOrWhiteSpace(RodlFileName) then exit RodlFileName;

  case caseInsensitive(aLibrary.GetOrGenerateEntityID:ToString) of
    //"DC8B7BE2-14AF-402D-B1F8-E1008B6FA4F6": exit "DataAbstract4.RODL";       //Name="DataAbstract4"
    "367FA81F-09B7-4294-85AD-68C140EF1FA7": exit "DataAbstract-Simple.RODL"; //Name="DataAbstractSimple"
    "943975A3-664A-4F07-AD0F-7357744276BF": exit "ROServiceDiscovery.rodl";  //Name="ROServerDiscovery"
    //"9EC7C50C-DAC2-48A9-9A0F-CBAA29A11EF7": exit "uRODataSnap.rodl";         //Name="uRODataSnap"
    else exit aLibrary.Name+".RODL";
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateDefaultNamespace(aFile: CGCodeUnit; aLibrary:RodlLibrary);
begin
  var list_use := new List<RodlUse>;
  for lu: RodlUse in aLibrary.Uses.Items do begin
    if not lu.DontCodegen then continue;
    var s1 := lu.Includes:DelphiModule;
    //var lExt := "hpp";
    if String.IsNullOrEmpty(s1) then begin
      //lExt := "h";
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ "_Intf";
    if not list_use.Contains(lu) then
      list_use.Add(lu);
  end;

  {$REGION function DefaultNamespaces:string;}
  var localvar_lres := new CGVariableDeclarationStatement("lres",ResolveStdtypes(CGPredefinedTypeReference.String), cpp_DefaultNamespace);
  var m := new CGMethodDefinition("DefaultNamespaces",
                                  LocalVariables := [localvar_lres].ToList,
                                  ReturnType :=ResolveStdtypes(CGPredefinedTypeReference.String),
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);

  var lres := localvar_lres.AsExpression;
  var lres1 := new CGBinaryOperatorExpression(lres, ";".AsLiteralExpression, CGBinaryOperatorKind.Addition);
  for k in list_use do begin
    if cpp_GetNamespaceForUses(k) = targetNamespace then continue;
    m.Statements.Add(new CGAssignmentStatement(lres,
                                               new CGBinaryOperatorExpression(lres1,
                                                                              new CGMethodCallExpression(CapitalizeString(cpp_GetNamespaceForUses(k)).AsNamedIdentifierExpression,
                                                                                  "DefaultNamespaces",
                                                                                  CallSiteKind := CGCallSiteKind.Static),
                                                                              CGBinaryOperatorKind.Addition)
                                                ));
  end;
  m.Statements.Add(lres.AsReturnStatement);
  aFile.Globals.Add(m.AsGlobal);
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateInterfaceImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  aFile.Imports.Add(GenerateCGImport("SysUtils","System"));
  aFile.Imports.Add(GenerateCGImport("Classes","System"));
  aFile.Imports.Add(GenerateCGImport("TypInfo","System"));
  if PureDelphi then begin
    if IsCodeFirstCompatible    then aFile.Imports.Add(GenerateCGImport("uRORTTIAttributes", CF_condition));
    if IsGenericArrayCompatible then aFile.Imports.Add(GenerateCGImport("uROArray",cond_ROUseGenerics));
  end;

  aFile.Imports.Add(GenerateCGImport("uROEncoding"));
  aFile.Imports.Add(GenerateCGImport("uROUri"));
  aFile.Imports.Add(GenerateCGImport("uROProxy"));
  aFile.Imports.Add(GenerateCGImport("uROExceptions"));
  aFile.Imports.Add(GenerateCGImport("uROXMLIntf"));
  aFile.Imports.Add(GenerateCGImport("uRONullable"));
  aFile.Imports.Add(GenerateCGImport("uROClasses"));
  aFile.Imports.Add(GenerateCGImport("uROTypes"));
  aFile.Imports.Add(GenerateCGImport("uROClientIntf"));
  aFile.Imports.Add(GenerateCGImport("uROAsync"));
  aFile.Imports.Add(GenerateCGImport("uROEventReceiver"));

  var list := new List<String>;
  for lu: RodlUse in aLibrary.Uses.Items do begin
    if not lu.DontCodegen then continue;
    var s1 := lu.Includes:DelphiModule;
    var lExt := "hpp";
    if String.IsNullOrEmpty(s1) then begin
      lExt := "h";
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ "_Intf";
    if not list.Contains(s1) then begin
      aFile.Imports.Add(GenerateCGImport(s1, "", lExt));
      cpp_pragmalink(aFile,CapitalizeString(s1));
      list.Add(s1);
    end;
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateImplImports(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  {$REGION implementation uses}
  aFile.ImplementationImports.Add(GenerateCGImport("uROSystem"));
  aFile.ImplementationImports.Add(GenerateCGImport("uROSerializer"));
  aFile.ImplementationImports.Add(GenerateCGImport("uROClient"));
  aFile.ImplementationImports.Add(GenerateCGImport("uROTransportChannel"));
  aFile.ImplementationImports.Add(GenerateCGImport("uRORes"));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateLibraryAttributes(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  LibraryAttributes := new CGClassTypeDefinition("TLibraryAttributes",
                                                 "TObject".AsTypeReference,
                                                 Visibility := CGTypeVisibilityKind.Public);
  //AddCGAttribute(LibraryAttributes, attr_ROSkip);
  Intf_ProcessAttributes(aLibrary, LibraryAttributes, true);
  var ldefaultnamespace := if CanUseNameSpace then
                              targetNamespace
                            else
                              Intf_name;
  LibraryAttributes.Members.Add(new CGMethodDefinition("DefaultNamespace",
                                                        [GenerateGlobalVarName("DefaultNamespace", ldefaultnamespace).AsReturnStatement],
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        &Static := true,
                                                        ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                                        CallingConvention := CGCallingConventionKind.Register));
  LibraryAttributes.Members.Add(new CGMethodDefinition("Documentation",
                                                        [coalesce(aLibrary.Documentation,"").AsLiteralExpression.AsReturnStatement],
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        &Static := true,
                                                        ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                                        CallingConvention := CGCallingConventionKind.Register));

  LibraryAttributes.Members.Add(new CGMethodDefinition("LibraryName",
                                                        [aLibrary.Name.AsLiteralExpression.AsReturnStatement],
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        &Static := true,
                                                        ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                                        CallingConvention := CGCallingConventionKind.Register));
  LibraryAttributes.Members.Add(new CGMethodDefinition("LibraryUID",
                                                        [GenerateGlobalVarName("LibraryUID", ldefaultnamespace).AsReturnStatement],
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        &Static := true,
                                                        ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                                        CallingConvention := CGCallingConventionKind.Register));
  LibraryAttributes.Members.Add(new CGMethodDefinition("RodlName",
                                                        [GetRODLName(aLibrary).AsLiteralExpression.AsReturnStatement],
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        &Static := true,
                                                        ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                                        CallingConvention := CGCallingConventionKind.Register));
  LibraryAttributes.Members.Add(new CGMethodDefinition("TargetNamespace",
                                                        [GenerateGlobalVarName("TargetNamespace", ldefaultnamespace).AsReturnStatement],
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        &Static := true,
                                                        ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                                        CallingConvention := CGCallingConventionKind.Register));
  aFile.Types.Add(LibraryAttributes);
end;

method DelphiRodlCodeGen.cpp_UuidId(anExpression: CGExpression): CGExpression;
begin
  exit anExpression;
end;

method DelphiRodlCodeGen.GenerateExternalSym(globalvar: CGGlobalVariableDefinition);
begin
   if PureDelphi then begin
     globalvar.RawFooter := new List<not nullable String>;
     globalvar.RawFooter.Add("{$EXTERNALSYM "+globalvar.Variable.Name+"}");
   end;
end;


method DelphiRodlCodeGen.IsGenericArrayCompatible: Boolean;
begin
  exit GenericArrayMode in [State.On, State.Auto];
end;


method DelphiRodlCodeGen.IsCodeFirstCompatible: Boolean;
begin
  exit CodeFirstMode in [State.On, State.Auto];
end;

method DelphiRodlCodeGen.IsHttpAPIAttribute(aName: String): Boolean;
begin
  exit aName.ToLowerInvariant in
    ["httpapipath", "httpapimethod", "httpapiresult", "httpapitags",
     "httpapioperationid", "httpapirequestname", "httpapiqueryparameter",
     "httpapiheaderparameter"];
end;

method DelphiRodlCodeGen.GenerateGlobalVarName(aName: String; aUnitName: String): CGExpression;
begin
  exit new CGFieldAccessExpression(aUnitName.AsNamedIdentifierExpression, aName, CallSiteKind := CGCallSiteKind.Static);
end;

method DelphiRodlCodeGen.Intf_GenerateArray_SetItemRef(aElementType: CGTypeReference): CGMethodDefinition;
begin
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var par_aIndex := new CGParameterDefinition("aIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var par_Ref := new CGParameterDefinition("Ref",CGPointerTypeReference.VoidPointer);
  var aIndex: CGExpression := par_aIndex.AsExpression;
  var fItems_aIndex := new CGArrayElementAccessExpression(fItems,[aIndex].ToList);  //fItems[aIndex]

  var lm := new CGMethodDefinition("SetItemRef",
                                Parameters := [par_aIndex, par_Ref].ToList,
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                CallingConvention := CGCallingConventionKind.Register);

  lm.Statements.Add(new CGIfThenElseStatement(
                       new CGBinaryOperatorExpression(
                                                      new CGBinaryOperatorExpression(aIndex,new CGIntegerLiteralExpression(0),CGBinaryOperatorKind.LessThan),
                                                      new CGBinaryOperatorExpression(aIndex, fCount, CGBinaryOperatorKind.GreatThanOrEqual),
                                                      CGBinaryOperatorKind.LogicalOr),
                      RaiseError("err_ArrayIndexOutOfBounds".AsNamedIdentifierExpression,[aIndex].ToList)));
  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(par_Ref.AsExpression, fItems_aIndex, CGBinaryOperatorKind.NotEquals),
                                              new CGBeginEndBlockStatement([
                                                                          new CGIfThenElseStatement(new CGAssignedExpression(fItems_aIndex),
                                                                                                    GenerateDestroyExpression(fItems_aIndex)),
                                                                          new CGAssignmentStatement(fItems_aIndex,
                                                                                                    new CGTypeCastExpression(par_Ref.AsExpression, aElementType))].ToList)));
  exit lm;
end;


method DelphiRodlCodeGen.Intf_GenerateArray_GetItemRef(aComplex: Boolean): CGMethodDefinition;
begin
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var par_aIndex := new CGParameterDefinition("aIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var aIndex: CGExpression := par_aIndex.AsExpression;
  var fItems_aIndex := new CGArrayElementAccessExpression(fItems,[aIndex].ToList);  //fItems[aIndex]

  var lm := new CGMethodDefinition("GetItemRef",
                                Parameters := [par_aIndex].ToList,
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                ReturnType := CGPointerTypeReference.VoidPointer,
                                CallingConvention := CGCallingConventionKind.Register
                                );
  lm.Statements.Add(new CGIfThenElseStatement(
                       new CGBinaryOperatorExpression(
                                                      new CGBinaryOperatorExpression(aIndex,new CGIntegerLiteralExpression(0),CGBinaryOperatorKind.LessThan),
                                                      new CGBinaryOperatorExpression(aIndex, fCount, CGBinaryOperatorKind.GreatThanOrEqual),
                                                      CGBinaryOperatorKind.LogicalOr),
                      RaiseError("err_ArrayIndexOutOfBounds".AsNamedIdentifierExpression,[aIndex].ToList)));
  if aComplex then
    lm.Statements.Add(fItems_aIndex.AsReturnStatement)
  else
    lm.Statements.Add(new CGUnaryOperatorExpression(fItems_aIndex, CGUnaryOperatorKind.AddressOf).AsReturnStatement);
  exit lm;
end;


method DelphiRodlCodeGen.Intf_GenerateArray_GetItemSize(aElementType: CGTypeReference): CGMethodDefinition;
begin
  exit new CGMethodDefinition("GetItemSize",
                              [new CGSizeOfExpression(aElementType.AsExpression).AsReturnStatement],
                                ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                &Static := true,
                                CallingConvention := CGCallingConventionKind.Register);
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Clear(aComplex: Boolean): CGMethodDefinition;
begin
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var lm := new CGMethodDefinition("Clear",
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                CallingConvention := CGCallingConventionKind.Register);

  if aComplex then begin
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    var localvar_i := new CGVariableDeclarationStatement("i", ResolveStdtypes(CGPredefinedTypeReference.Int32));
    lm.LocalVariables.Add(localvar_i);
    var fItems_i := new CGArrayElementAccessExpression(fItems, [localvar_i.AsExpression]);  //fItems[i]
    var fCount_subtract_1 := new CGBinaryOperatorExpression(fCount,            //fCount-1
                                                            new CGIntegerLiteralExpression(1),
                                                            CGBinaryOperatorKind.Subtraction);
    lm.Statements.Add(new CGForToLoopStatement(localvar_i.Name,
                                              ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                              new CGIntegerLiteralExpression(0),
                                              fCount_subtract_1,
                                              GenerateDestroyExpression(fItems_i)
                                              ));

  end;
  lm.Statements.Add(Array_SetLength(fItems, new CGIntegerLiteralExpression(0)));
  lm.Statements.Add(new CGAssignmentStatement(fCount, new CGIntegerLiteralExpression(0)));
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Delete(aComplex: Boolean): CGMethodDefinition;
begin
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var par_aIndex := new CGParameterDefinition("aIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var aIndex: CGExpression := par_aIndex.AsExpression;
  var localvar_i := new CGVariableDeclarationStatement("i", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var fItems_i := new CGArrayElementAccessExpression(fItems, [localvar_i.AsExpression as CGExpression]);
  var fCount_subtract_1    := new CGBinaryOperatorExpression(fCount,            //fCount-1
                                                            new CGIntegerLiteralExpression(1),
                                                            CGBinaryOperatorKind.Subtraction);

  var lm := new CGMethodDefinition("Delete",
                                Parameters := [par_aIndex].ToList,
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                CallingConvention := CGCallingConventionKind.Register);

  lm.LocalVariables := new List<CGVariableDeclarationStatement>;

  lm.LocalVariables.Add(localvar_i);
  var fItems_i_add_1 :=new CGArrayElementAccessExpression(fItems, //fItems[i + 1]
                                                        [CGExpression(new CGBinaryOperatorExpression(
                                                                                                    localvar_i.AsExpression,
                                                                                                    new CGIntegerLiteralExpression(1),
                                                                                                    CGBinaryOperatorKind.Addition))
                                                                                                    ].ToList);
  var lSelfCount_subtract_2 := new CGBinaryOperatorExpression(fCount, //Self.Count - 2
                                                              new CGIntegerLiteralExpression(2),
                                                              CGBinaryOperatorKind.Subtraction);


  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(aIndex, fCount, CGBinaryOperatorKind.GreatThanOrEqual),
                                              RaiseError("err_InvalidIndex".AsNamedIdentifierExpression, [aIndex].ToList)));
  lm.Statements.Add(new CGEmptyStatement);
  if aComplex then begin
    lm.Statements.Add(GenerateDestroyExpression(new CGArrayElementAccessExpression(fItems,[aIndex].ToList)));
    lm.Statements.Add(new CGEmptyStatement);
  end;



  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(aIndex,
                                                                             fCount_subtract_1,
                                                                             CGBinaryOperatorKind.LessThan),
                                              new CGForToLoopStatement(localvar_i.Name,
                                                                      ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                                                      aIndex,
                                                                      lSelfCount_subtract_2,
                                                                      new CGAssignmentStatement(fItems_i,fItems_i_add_1))));
  lm.Statements.Add(Array_SetLength(fItems, fCount_subtract_1));
  lm.Statements.Add(new CGAssignmentStatement(fCount, fCount_subtract_1));
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Assign(aLibrary: RodlLibrary; aArrayType: CGTypeReference; aElementType: CGTypeReference; elType: String; aComplex: Boolean): CGMethodDefinition;
begin
  var par_Source := new CGParameterDefinition("Source","TPersistent".AsTypeReference);
  var lm := new CGMethodDefinition("Assign",
                            Parameters := [par_Source].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  var localvar_lSource := new CGVariableDeclarationStatement("lSource",aArrayType);
  lm.LocalVariables.Add(localvar_lSource);
  var localvar_i := new CGVariableDeclarationStatement("i", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  lm.LocalVariables.Add(localvar_i);
  var localvar_lItem := new CGVariableDeclarationStatement("lItem",aElementType);
  if aComplex then
    lm.LocalVariables.Add(localvar_lItem);
  var aSourceExpr := par_Source.AsExpression;                                                                     // aSource
  var lSourceExpr := localvar_lSource.AsExpression;                                                                     // lSource
  var lSource_Count := new CGPropertyAccessExpression(lSourceExpr, "Count", CallSiteKind := CGCallSiteKind.Reference);                // lSource.Count
  var lSelfitems_i := new CGPropertyAccessExpression(CGSelfExpression.Self,
                                                     "Items",
                                                     [localvar_i.AsCallParameter].ToList,
                                                     CallSiteKind := CGCallSiteKind.Reference); // Self.Items[i]
  var larritem := new CGPropertyAccessExpression(lSourceExpr,
                                                 "Items",
                                                 [localvar_i.AsCallParameter].ToList,
                                                 CallSiteKind := CGCallSiteKind.Reference); // lSource.Items[i]
  var litem := localvar_lItem.AsExpression;                                                                             // lItem
  var lct := new CGBeginEndBlockStatement;
  lm.Statements.Add(new CGIfThenElseStatement(GenerateIsClause(aSourceExpr,aArrayType),
                                        lct,
                                        new CGMethodCallExpression(CGInheritedExpression.Inherited,"Assign",[aSourceExpr.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Static)));
  lct.Statements.Add(new CGAssignmentStatement(lSourceExpr,new CGTypeCastExpression(aSourceExpr, aArrayType)));
  lct.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, "Clear",CallSiteKind := CGCallSiteKind.Reference));
  lct.Statements.Add(new CGEmptyStatement);

  if aComplex then begin
    var if_true := new CGBeginEndBlockStatement();
    // lSource.Items[i].ClassType.Create()
    if isArray(aLibrary,elType) or isComplex(aLibrary,elType) or isException(aLibrary,elType) then begin
      // we can use .Clone method
      var lnew := new CGMethodCallExpression(larritem,"Clone", CallSiteKind := CGCallSiteKind.Reference);     //lSource.Items[i].Clone
      if_true.Statements.Add(new CGAssignmentStatement(litem,new CGTypeCastExpression(lnew,aElementType))); //lItem := AdminProperty(xxx);
    end
    else if isBinary(elType) then begin
      //binary
      if_true.Statements.Add(new CGAssignmentStatement(litem,new CGNewInstanceExpression(aElementType))); //lItem := Binary.Create();
      if_true.Statements.Add(new CGMethodCallExpression(litem,"Assign",[larritem.AsCallParameter].ToList, CallSiteKind := CGCallSiteKind.Reference));//lItem.Assign(lSource.Items[i]);
    end
    else begin
      // unknown object
      var lnew: CGExpression := new CGNewInstanceExpression(new CGMethodCallExpression(larritem,"ClassType",CallSiteKind := CGCallSiteKind.Static));//lSource.Items[i].ClassType.Create()
      if_true.Statements.Add(new CGAssignmentStatement(litem,new CGTypeCastExpression(lnew,aElementType)));//lItem := AdminProperty(xxx);
      if_true.Statements.Add(new CGMethodCallExpression(litem,"Assign",[larritem.AsCallParameter].ToList, CallSiteKind := CGCallSiteKind.Reference));//lItem.Assign(lSource.Items[i]);
    end;
    if_true.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self,"Add",[litem.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference)); //self.Add(lItem);
    lct.Statements.Add(new CGForToLoopStatement(localvar_i.Name, //for i := 0 to lSource.Count-1 do
                                                ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                                new CGIntegerLiteralExpression(0),
                                                new CGBinaryOperatorExpression(lSource_Count,
                                                                              new CGIntegerLiteralExpression(1),
                                                                              CGBinaryOperatorKind.Subtraction),
                                                new CGIfThenElseStatement(
                                                                          new CGAssignedExpression(larritem),
                                                                          if_true,
                                                                          new CGMethodCallExpression(CGSelfExpression.Self,"Add",[CGNilExpression.Nil.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference)
                                                                          )));
  end
  else begin
    lct.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, "Resize",[lSource_Count.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    lct.Statements.Add(new CGForToLoopStatement(localvar_i.Name, //for i := 0 to lSource.Count-1 do
                                                ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                                new CGIntegerLiteralExpression(0),
                                                new CGBinaryOperatorExpression(lSource_Count,
                                                                              new CGIntegerLiteralExpression(1),
                                                                              CGBinaryOperatorKind.Subtraction),
                                                new CGAssignmentStatement(lSelfitems_i,larritem) //Self.Items[i] := lSource.Items[i];
                                                ));
  end;
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_WriteComplex(aLibrary: RodlLibrary; aArrayType: CGTypeReference; aElementType: CGTypeReference; elType: String): CGMethodDefinition;
begin
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var fCount_subtract_1 := new CGBinaryOperatorExpression(fCount,            //fCount-1
                                                            new CGIntegerLiteralExpression(1),
                                                            CGBinaryOperatorKind.Subtraction);
  var par_aSerializer := new CGParameterDefinition("aSerializer","TObject".AsTypeReference);
  var lm := new CGMethodDefinition("WriteComplex",
                            Parameters := [par_aSerializer].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  var TROSerializer_typeref := "TROSerializer".AsTypeReference;
  var lSerializer_typeref := new CGTypeCastExpression(par_aSerializer.AsExpression, TROSerializer_typeref);
  var localvar__Serializer := new CGVariableDeclarationStatement("__Serializer",TROSerializer_typeref, lSerializer_typeref);
  lm.LocalVariables.Add(localvar__Serializer);
  var lSerializer := localvar__Serializer.AsExpression;
  var localvar_i := new CGVariableDeclarationStatement("i", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  lm.LocalVariables.Add(localvar_i);
  var fItems_i := new CGArrayElementAccessExpression(fItems, [localvar_i.AsExpression as CGExpression]);
  lm.Statements.Add(new CGMethodCallExpression(lSerializer,"ChangeClass",[ cpp_ClassId(DuplicateType(aArrayType, false).AsExpression).AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
  var array__element_name := new CGMethodCallExpression(lSerializer,
                                                   "GetArrayElementName",
                                                   [new CGMethodCallExpression(nil, "GetItemType").AsCallParameter,
                                                    new CGMethodCallExpression(nil, "GetItemRef",[localvar_i.AsCallParameter].ToList).AsCallParameter].ToList,
                                                    CallSiteKind := CGCallSiteKind.Reference).AsCallParameter;
  var ws := Intf_generateWriteStatement(aLibrary,
                                  elType,
                                  lSerializer,
                                  array__element_name,
                                  fItems_i.AsCallParameter,
                                  aElementType,
                                  localvar_i.AsCallParameter);
  lm.Statements.Add(new CGForToLoopStatement(localvar_i.Name,
                                            ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                            new CGIntegerLiteralExpression(0),
                                            fCount_subtract_1,
                                            new CGBeginEndBlockStatement(ws)
                                            ));
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_ReadComplex(aLibrary: RodlLibrary; aElementType: CGTypeReference; elType: String): CGMethodDefinition;
begin
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var Self_Items := new CGPropertyAccessExpression(CGSelfExpression.Self, "Items", CallSiteKind := CGCallSiteKind.Reference);//Self.Items
  var fCount_subtract_1 := new CGBinaryOperatorExpression(fCount,            //fCount-1
                                                            new CGIntegerLiteralExpression(1),
                                                            CGBinaryOperatorKind.Subtraction);
  var TROSerializer_typeref := "TROSerializer".AsTypeReference;

  var par_aSerializer := new CGParameterDefinition("aSerializer","TObject".AsTypeReference);

  var lSerializer_typeref := new CGTypeCastExpression(par_aSerializer.AsExpression, TROSerializer_typeref);

  var lm := new CGMethodDefinition("ReadComplex",
                            Parameters := [par_aSerializer].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  var localvar__Serializer := new CGVariableDeclarationStatement("__Serializer",TROSerializer_typeref, lSerializer_typeref);
  var lSerializer := localvar__Serializer.AsExpression;
  lm.LocalVariables.Add(localvar__Serializer);
  var localvar_lval := new CGVariableDeclarationStatement("lval", aElementType);
  lm.LocalVariables.Add(localvar_lval);
  var localvar_i := new CGVariableDeclarationStatement("i", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  lm.LocalVariables.Add(localvar_i); // var i: integer;
  var Self_Items_i := new CGArrayElementAccessExpression(Self_Items, [localvar_i.AsExpression]);    //Self.Items[i]
  var array__element_name := new CGMethodCallExpression(lSerializer,
                                                   "GetArrayElementName",
                                                   [new CGMethodCallExpression(nil, "GetItemType").AsCallParameter,
                                                    new CGMethodCallExpression(nil, "GetItemRef",[localvar_i.AsCallParameter].ToList).AsCallParameter].ToList,
                                                    CallSiteKind := CGCallSiteKind.Reference).AsCallParameter;
  var lforst := new List<CGStatement>;
  lforst.Add(Intf_generateReadStatement(aLibrary,
                                   elType,
                                   lSerializer,
                                   array__element_name,
                                   localvar_lval.AsCallParameter,
                                   aElementType,
                                   localvar_i.AsCallParameter));
  lforst.Add(new CGAssignmentStatement(Self_Items_i, localvar_lval.AsExpression));
  lm.Statements.Add(new CGForToLoopStatement(localvar_i.Name,
                                            ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                            new CGIntegerLiteralExpression(0),
                                            fCount_subtract_1,
                                            new CGBeginEndBlockStatement(lforst)
                                            ));
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Add(aElementType: CGTypeReference; aComplex: Boolean): CGMethodDefinition;
begin
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var fCount_add_1 := new CGBinaryOperatorExpression(fCount, //fCount+1
                                                     new CGIntegerLiteralExpression(1),
                                                     CGBinaryOperatorKind.Addition);
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var par_Value := new CGParameterDefinition("Value", aElementType);
  var lm := new CGMethodDefinition("Add",
                          Overloaded := aComplex,
                          Parameters := [par_Value].ToList,
                          Visibility := CGMemberVisibilityKind.Public,
                          ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                          CallingConvention := CGCallingConventionKind.Register);

  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  var localvar_lResult := new CGVariableDeclarationStatement("lResult", lm.ReturnType, fCount);
  lm.LocalVariables.Add(localvar_lResult);
  var lResult := localvar_lResult.AsExpression;
  var fItems_Result := new CGArrayElementAccessExpression(fItems, [lResult]);  //fItems[lResult]

  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(Array_GetLength(fItems),
                                                                             lResult,
                                                                             CGBinaryOperatorKind.Equals),
                                              new CGMethodCallExpression(CGSelfExpression.Self, "Grow",CallSiteKind := CGCallSiteKind.Reference)));
  lm.Statements.Add(new CGAssignmentStatement(fItems_Result, par_Value.AsExpression));
  lm.Statements.Add(new CGAssignmentStatement(fCount, fCount_add_1));
  lm.Statements.Add(lResult.AsReturnStatement);

  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_GetIndex(aElementType: CGTypeReference): CGMethodDefinition;
begin
  var par_aValue := new CGParameterDefinition("aValue",
                                              aElementType,
                                              Modifier := CGParameterModifierKind.Const);
  var par_aStartFrom := new CGParameterDefinition("aStartFrom",
                                                  ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                                  Modifier := CGParameterModifierKind.Const,
                                                  DefaultValue := new CGIntegerLiteralExpression(0));
  var lm := new CGMethodDefinition("GetIndex",
                          Parameters := [par_aValue, par_aStartFrom].ToList,
                          Visibility := CGMemberVisibilityKind.Public,
                          Overloaded := true,
                          ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                          CallingConvention := CGCallingConventionKind.Register);
  lm.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self,
                                               "IndexOf",
                                               [par_aValue.AsCallParameter,
                                                par_aStartFrom.AsCallParameter].ToList,
                                               CallSiteKind := CGCallSiteKind.Reference).AsReturnStatement);
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_GetIndex1: CGMethodDefinition;
begin
  var par_aPropertyName := new CGParameterDefinition("aPropertyName",
                                                     ResolveStdtypes(CGPredefinedTypeReference.String),
                                                     Modifier := CGParameterModifierKind.Const);
  var par_aPropertyValue := new CGParameterDefinition("aPropertyValue",
                                                      "Variant".AsTypeReference,
                                                      Modifier := CGParameterModifierKind.Const);
  var par_aStartFrom := new CGParameterDefinition("aStartFrom",
                                                  ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                                  DefaultValue := new CGIntegerLiteralExpression(0));
  var par_Options := new CGParameterDefinition("Options",
                                               new CGNamedTypeReference("TROSearchOptions") isClasstype(false),
                                               DefaultValue := new CGSetLiteralExpression([CGExpression("soIgnoreCase".AsNamedIdentifierExpression)].ToList,
                                                                                          "TROSearchOptions".AsTypeReference));
  exit new CGMethodDefinition("GetIndex",
                              [new CGIntegerLiteralExpression(-1).AsReturnStatement],
                              Parameters := [par_aPropertyName, par_aPropertyValue, par_aStartFrom, par_Options].ToList,
                              Virtuality := CGMemberVirtualityKind.Override,
                              Visibility := CGMemberVisibilityKind.Public,
                              ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                              CallingConvention := CGCallingConventionKind.Register);
end;

method DelphiRodlCodeGen.Intf_GenerateArray_IndexOf(aElementType: CGTypeReference): CGMethodDefinition;
begin
  var fItems := new CGFieldAccessExpression(nil, "fItems");
  var fCount := new CGFieldAccessExpression(nil, "fCount");
  var fCount_subtract_1    := new CGBinaryOperatorExpression(fCount,            //fCount-1
                                                          new CGIntegerLiteralExpression(1),
                                                          CGBinaryOperatorKind.Subtraction);
  var par_aValue := new CGParameterDefinition("aValue",
                                              aElementType,
                                              Modifier := CGParameterModifierKind.Const);
  var par_aStartFrom := new CGParameterDefinition("aStartFrom",
                                                  ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                                  Modifier := CGParameterModifierKind.Const,
                                                  DefaultValue := new CGIntegerLiteralExpression(0));
  var localvar_lResult := new CGVariableDeclarationStatement("lResult", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var fItems_Result := new CGArrayElementAccessExpression(fItems,[localvar_lResult.AsExpression]);  //fItems[Result]
  var lm := new CGMethodDefinition("IndexOf",
                                  Parameters := [par_aValue, par_aStartFrom].ToList,
                                  LocalVariables := [localvar_lResult].ToList,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                  CallingConvention := CGCallingConventionKind.Register);
  lm.Statements.Add(new CGForToLoopStatement(localvar_lResult.Name,
                                            ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                            par_aStartFrom.AsExpression,
                                            fCount_subtract_1,
                                            new CGIfThenElseStatement(new CGBinaryOperatorExpression(fItems_Result, par_aValue.AsExpression, CGBinaryOperatorKind.Equals),
                                                                      new CGBeginEndBlockStatement([localvar_lResult.AsExpression.AsReturnStatement]))
                                            ));

  lm.Statements.Add(new CGIntegerLiteralExpression(-1).AsReturnStatement);
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Add1(aElementType: CGTypeReference; aIsException: Boolean): CGMethodDefinition;
begin
  var localvar_lres := new CGVariableDeclarationStatement("lres", aElementType);
  var lres := localvar_lres.AsExpression;
  var lm := new CGMethodDefinition("Add",
                              Overloaded := true,
                              LocalVariables := [localvar_lres].ToList,
                              Visibility := CGMemberVisibilityKind.Public,
                              ReturnType := aElementType,
                              CallingConvention := CGCallingConventionKind.Register);

  if aIsException then
    lm.Statements.Add(new CGAssignmentStatement(lres, new CGNewInstanceExpression(aElementType,
                                                                                  ["".AsLiteralExpression.AsCallParameter,
                                                                                   new CGArrayLiteralExpression().AsCallParameter].ToList,
                                                                                   ConstructorName := "CreateFmt")))
  else
    lm.Statements.Add(new CGAssignmentStatement(lres, new CGNewInstanceExpression(aElementType)));
  lm.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, "Add",[localvar_lres.AsCallParameter],CallSiteKind := CGCallSiteKind.Reference));
  lm.Statements.Add(lres.AsReturnStatement);
  exit lm;
end;

method DelphiRodlCodeGen.Intf_GenerateArray_GetEnumerator(aEnumeratorType: CGTypeReference): CGMethodDefinition;
begin
  exit new CGMethodDefinition("GetEnumerator",
                               [new CGNewInstanceExpression(aEnumeratorType, [CGSelfExpression.Self.AsCallParameter]).AsReturnStatement],
                               Visibility := CGMemberVisibilityKind.Public,
                               ReturnType := aEnumeratorType,
                               CallingConvention := CGCallingConventionKind.Register);
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Count: CGPropertyDefinition;
begin
  exit new CGPropertyDefinition("Count",
                                 ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                 new CGMethodAccessExpression(nil, "GetCount"),
                                 Visibility := CGMemberVisibilityKind.Public
                                );
end;

method DelphiRodlCodeGen.Intf_GenerateArray_Items(aElementType: CGTypeReference): CGPropertyDefinition;
begin
  exit new CGPropertyDefinition("Items",
                                aElementType,
                                new CGMethodAccessExpression(nil, "GetItems"),
                                new CGMethodAccessExpression(nil, "SetItems"),
                                Visibility := CGMemberVisibilityKind.Public,
                                Parameters := [new CGParameterDefinition("Index", ResolveStdtypes(CGPredefinedTypeReference.Int32))].ToList,
                                &Default := true
                    );
end;

method DelphiRodlCodeGen.Intf_GenerateArray_InnerArray(aInnerArrayType: CGTypeReference): CGPropertyDefinition;
begin
  exit new CGPropertyDefinition("InnerArray",
                                aInnerArrayType,
                                new CGFieldAccessExpression(nil, "fItems"),
                                Visibility := CGMemberVisibilityKind.Public);
end;

method DelphiRodlCodeGen.Intf_GenerateService_T_Proxy(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lmember: CGMethodDefinition;
  var lancestor: CGTypeReference;

  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, $"T{aEntity.AncestorName}_Proxy",Intf_name, aEntity.AncestorName)
  else
    lancestor := "TROProxy".AsTypeReference;


  var ltype := new CGClassTypeDefinition($"T{aEntity.Name}_Proxy",
                                      lancestor,
                                      Visibility := CGTypeVisibilityKind.Public);  //TROProxy or T%service%Proxy
  ltype.ImplementedInterfaces.Add(ResolveDataTypeToTypeRefFullQualified(aLibrary, $"I{aEntity.Name}", Intf_name, aEntity.Name));  //I%service%
  aFile.Types.Add(ltype);
  {$REGION protected function __GetInterfaceName:string; override;}
  lmember := new CGMethodDefinition("__GetInterfaceName",
                                  [aEntity.Name.AsLiteralExpression.AsReturnStatement],
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                  Visibility := CGMemberVisibilityKind.Protected,
                                  CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lmember);
  {$ENDREGION}

  cpp_IUnknownSupport(aLibrary, aEntity, ltype);
  cpp_GenerateAncestorMethodCalls(aLibrary, aEntity, ltype, ModeKind.Plain);

  for lmem in aEntity.DefaultInterface.Items do begin
    {$REGION service methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      Visibility := CGMemberVisibilityKind.Protected,
                                      CallingConvention := CGCallingConventionKind.Register);
    for lmemparam in lmem.Items do begin
      if lmemparam.ParamFlag <> ParamFlags.Result then begin
        var lparam := new CGParameterDefinition(lmemparam.Name,
                                                ResolveDataTypeToTypeRefFullQualified(aLibrary,lmemparam.DataType, Intf_name));
        if isComplex(aLibrary, lmemparam.DataType) and (lmemparam.ParamFlag = ParamFlags.In) then
          lparam.Type := new CGConstantTypeReference(lparam.Type)
        else
          lparam.Modifier := RODLParamFlagToCodegenFlag(lmemparam.ParamFlag);
        mem.Parameters.Add(lparam);
      end;
    end;
    if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType,Intf_name);
    ltype.Members.Add(mem);
    mem.LocalVariables := new List<CGVariableDeclarationStatement>;
    var localvar_lMessage := new CGVariableDeclarationStatement("lMessage",IROMessage_typeref);
    mem.LocalVariables.Add(localvar_lMessage);
    var localvar_lTransportChannel := new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref);
    mem.LocalVariables.Add(localvar_lTransportChannel);
    var localvar_lResult := new CGVariableDeclarationStatement("lResult",mem.ReturnType);
    if assigned(lmem.Result) then
      mem.LocalVariables.Add(localvar_lResult);

    var lMessage := localvar_lMessage.AsExpression;
    var lTransportChannel := localvar_lTransportChannel.AsExpression;

    mem.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, "__GetMessage")));
    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        mem.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "CheckForOutputParameters",
                                                      CallSiteKind := CGCallSiteKind.Reference
                                                      ));
        break;
      end;
    end;
    mem.Statements.Add(new CGMethodCallExpression(lMessage,"SetAutoGeneratedNamespaces",[new CGMethodCallExpression(nil,"DefaultNamespaces").AsCallParameter],CallSiteKind := CGCallSiteKind.Reference));
    mem.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGPropertyAccessExpression(nil, "__TransportChannel")));
    ////
    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(aLibrary, aEntity, lmem,out p1, out p2);

    if p1.Count > 0 then
      cpp_SetAttributes(mem.Statements, lMessage, lTransportChannel, p1, p2);

    var ltry :=new CGTryFinallyCatchStatement();


    for litem in lmem.Items do begin
      if (litem.ParamFlag = ParamFlags.Out) and isComplex(aLibrary, litem.DataType) then
        ltry.Statements.Add(new CGAssignmentStatement(new CGParameterAccessExpression(litem.Name), CGNilExpression.Nil));
    end;
    if assigned(lmem.Result) and isComplex(aLibrary, lmem.Result.DataType) then
      ltry.Statements.Add(new CGAssignmentStatement(localvar_lResult.AsExpression, CGNilExpression.Nil));
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                    "InitializeRequestMessage",
                                                    [lTransportChannel.AsCallParameter,
                                                    iif(aLibrary.DataSnap,"",aLibrary.Name).AsLiteralExpression.AsCallParameter,
                                                    new CGPropertyAccessExpression(nil, "__InterfaceName").AsCallParameter,
                                                    lmem.Name.AsLiteralExpression.AsCallParameter
                                                    ].ToList,
                                                    CallSiteKind := CGCallSiteKind.Reference));
    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        "Write",
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGLocalVariableAccessExpression(litem.Name).AsCallParameter(CGParameterModifierKind.Var),
                                                        GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                                        CallSiteKind := CGCallSiteKind.Reference));
      end;
    end;
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,"Finalize",CallSiteKind := CGCallSiteKind.Reference));
    ltry.Statements.Add(new CGEmptyStatement);
    ltry.Statements.Add(new CGMethodCallExpression(lTransportChannel,"Dispatch",[lMessage.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    ltry.Statements.Add(new CGEmptyStatement);

    {$REGION ! DataSnap}
    if not aLibrary.DataSnap then
      if assigned(lmem.Result) then begin
        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "Read",
                                                      [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                                      localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                                      GenerateParamAttributes(lmem.Result.DataType).AsCallParameter].ToList,
                                                      CallSiteKind := CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        "Read",
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGLocalVariableAccessExpression(litem.Name).AsCallParameter(CGParameterModifierKind.Var),
                                                        GenerateParamAttributes(litem.DataType).AsCallParameter].ToList,
                                                        CallSiteKind := CGCallSiteKind.Reference));
      end;

    end;
    {$REGION DataSnap}
    if aLibrary.DataSnap then
      if assigned(lmem.Result) then begin
        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      "Read",
                                                      [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(aLibrary,ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                                      localvar_lResult.AsExpression.AsCallParameter(CGParameterModifierKind.Var),
                                                      GenerateParamAttributes(lmem.Result.DataType).AsCallParameter].ToList,
                                                      CallSiteKind := CGCallSiteKind.Reference));

      end;
  {$ENDREGION}
    ltry.FinallyStatements.Add(new CGMethodCallExpression(lMessage,"UnsetAttributes",[lTransportChannel.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference));
    ltry.FinallyStatements.Add(new CGMethodCallExpression(lMessage,"FreeStream",CallSiteKind := CGCallSiteKind.Reference));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    mem.Statements.Add(ltry);
    if assigned(lmem.Result) then
      mem.Statements.Add(localvar_lResult.AsExpression.AsReturnStatement);
    {$ENDREGION}
  end;
  cpp_GenerateProxyConstructors(aLibrary, aEntity, ltype);

  {$REGION initialization/finalization}
  aFile.Initialization.Add(new CGMethodCallExpression(nil, "RegisterProxyClass",
                                                     [$"I{aEntity.Name}_IID".AsNamedIdentifierExpression.AsCallParameter,
                                                     cpp_ClassId(GenerateTypeExpression($"T{aEntity.Name}_Proxy")).AsCallParameter].ToList));

  aFile.Finalization.Add(new CGMethodCallExpression(nil, "UnregisterProxyClass", [$"I{aEntity.Name}_IID".AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
end;


method DelphiRodlCodeGen.Intf_GenerateService_Co_AsyncEx(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var param_anAppServerName := new CGParameterDefinition("anAppServerName", ResolveStdtypes(CGPredefinedTypeReference.String), Modifier := CGParameterModifierKind.Const);
  var param_aMessage := new CGParameterDefinition("aMessage",IROMessage_typeref, Modifier := CGParameterModifierKind.Const);
  var param_aTransportChannel := new CGParameterDefinition("aTransportChannel",IROTransportChannel_typeref);
  var param_aUri := new CGParameterDefinition("aUri",new CGConstantTypeReference("TROUri".AsTypeReference));
  var param_aUrl := new CGParameterDefinition("aUrl",
                                              ResolveStdtypes(CGPredefinedTypeReference.String),
                                              Modifier := CGParameterModifierKind.Const);
  var param_aDefaultNamespaces := new CGParameterDefinition("aDefaultNamespaces",
                                                            ResolveStdtypes(CGPredefinedTypeReference.String),
                                                            DefaultValue := "".AsLiteralExpression);
  var l_IName_AsyncEx_typeref := ResolveInterfaceTypeRef(aLibrary,$"I{aEntity.Name}_AsyncEx",Intf_name,aEntity.Name); // I%service%_AsyncEx or _di_I%service%_AsyncEx
  var l_Tname_AsyncProxyEx_typeref := ResolveDataTypeToTypeRefFullQualified(aLibrary,$"T{aEntity.Name}_AsyncProxyEx",Intf_name,aEntity.Name);
  var lmember: CGMethodDefinition;
  var ltype := new CGClassTypeDefinition($"Co{aEntity.Name}_AsyncEx",
                                      new CGNamedTypeReference("TObject") &namespace(new CGNamespaceReference("System")),
                                      Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype);

  {$REGION public class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): I%service%_AsyncEx; overload;}
  lmember := new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_AsyncEx_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if aLibrary.DataSnap then
    lmember.Parameters.Add(param_anAppServerName);
  lmember.Parameters.Add(param_aMessage);
  lmember.Parameters.Add(param_aTransportChannel);

  var l_new := new CGNewInstanceExpression(l_Tname_AsyncProxyEx_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aMessage.AsCallParameter);
  l_new.Parameters.Add(param_aTransportChannel.AsCallParameter);

  lmember.Statements.Add(cppGenerateProxyCast(l_new,l_IName_AsyncEx_typeref));
  ltype.Members.Add(lmember);
  {$ENDREGION}

  {$REGION public class function Create(aUri: TROUri; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember := new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_AsyncEx_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if aLibrary.DataSnap then
    lmember.Parameters.Add(param_anAppServerName);
  lmember.Parameters.Add(param_aUri);
  lmember.Parameters.Add(param_aDefaultNamespaces);

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxyEx_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aUri.AsCallParameter);
  l_new.Parameters.Add(param_aDefaultNamespaces.AsCallParameter);

  lmember.Statements.Add(cppGenerateProxyCast(l_new,l_IName_AsyncEx_typeref));
  ltype.Members.Add(lmember);
  {$ENDREGION}

  {$REGION public class function Create(const aUrl: string): I%service%; overload;}
  lmember := new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_AsyncEx_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if aLibrary.DataSnap then
    lmember.Parameters.Add(param_anAppServerName);
  lmember.Parameters.Add(param_aUrl);
  lmember.Parameters.Add(param_aDefaultNamespaces);

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxyEx_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aUrl.AsCallParameter);
  l_new.Parameters.Add(param_aDefaultNamespaces.AsCallParameter);

  lmember.Statements.Add(cppGenerateProxyCast(l_new,l_IName_AsyncEx_typeref));

  ltype.Members.Add(lmember);
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Invk_RemapParameters(aMessage: CGParameterAccessExpression; aParamNames: CGArrayLiteralExpression): CGStatement;
begin
  exit new CGMethodCallExpression(aMessage,
                                   "RemapParameters",
                                   [aParamNames.AsCallParameter],
                                   CallSiteKind := CGCallSiteKind.Reference);
end;

method DelphiRodlCodeGen.Intf_GenerateService_T_AsyncProxyEx(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, $"T{aEntity.AncestorName}_AsyncProxyEx",Intf_name,aEntity.AncestorName)
  else
    lancestor := "TROAsyncProxyEx".AsTypeReference;
  var ltype := new CGClassTypeDefinition($"T{aEntity.Name}_AsyncProxyEx",
                                         lancestor,
                                         [ResolveDataTypeToTypeRefFullQualified(aLibrary, $"I{aEntity.Name}_AsyncEx",Intf_name, aEntity.Name)].ToList,
                                         Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype);
  {$REGION protected function __GetInterfaceName:string; override;}
  var lmember := new CGMethodDefinition("__GetInterfaceName",
                                  [aEntity.Name.AsLiteralExpression.AsReturnStatement],
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                  Visibility := CGMemberVisibilityKind.Protected,
                                  CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lmember);
  {$ENDREGION}

  cpp_IUnknownSupport(aLibrary, aEntity, ltype);
  cpp_GenerateAncestorMethodCalls(aLibrary, aEntity, ltype, ModeKind.AsyncEx);

  {$REGION Begin%service_method%}
  for lmem in aEntity.DefaultInterface.Items do begin
    ltype.Members.Add(Intf_GenerateAsyncExBegin(aLibrary, aEntity, lmem, true, false, false));
    ltype.Members.Add(Intf_GenerateAsyncExBegin(aLibrary, aEntity, lmem, true, true, false));
  end;
  {$ENDREGION}

  {$REGION End%service_method%}
  for lmem in aEntity.DefaultInterface.Items do
    ltype.Members.Add(Intf_GenerateAsyncExEnd(aLibrary, aEntity, lmem, true, false));
  {$ENDREGION}
  cpp_GenerateProxyConstructors(aLibrary, aEntity, ltype);
end;


method DelphiRodlCodeGen.Intf_GenerateService_T_AsyncProxy(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, $"T{aEntity.AncestorName}_AsyncProxy",Intf_name,aEntity.AncestorName)
  else
    lancestor := "TROAsyncProxy".AsTypeReference;
  var ltype := new CGClassTypeDefinition($"T{aEntity.Name}_AsyncProxy",
                                          lancestor,
                                          [ResolveDataTypeToTypeRefFullQualified(aLibrary, $"I{aEntity.Name}_Async",Intf_name, aEntity.Name)].ToList,
                                          Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype);
  {$REGION protected function __GetInterfaceName:string; override;}
  var lmember1 := new CGMethodDefinition("__GetInterfaceName",
                                  [aEntity.Name.AsLiteralExpression.AsReturnStatement],
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                  Visibility := CGMemberVisibilityKind.Protected,
                                  CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lmember1);
  {$ENDREGION}

  cpp_IUnknownSupport(aLibrary, aEntity, ltype);
  cpp_GenerateAsyncAncestorMethodCalls(aLibrary, aEntity, ltype);
  cpp_GenerateAncestorMethodCalls(aLibrary, aEntity, ltype, ModeKind.Async);

  {$REGION Invoke_%service_method%}
  for lmem in aEntity.DefaultInterface.Items do
    ltype.Members.Add(Intf_GenerateAsyncInvoke(aLibrary, aEntity, lmem, true, false));
  {$ENDREGION}

  {$REGION Retrieve_%service_method%}
  for lmem in aEntity.DefaultInterface.Items do
    if NeedsAsyncRetrieveOperationDefinition(lmem) then
      ltype.Members.Add(Intf_GenerateAsyncRetrieve(aLibrary, aEntity, lmem, true, false));
  {$ENDREGION}
  cpp_GenerateProxyConstructors(aLibrary, aEntity, ltype);

end;


method DelphiRodlCodeGen.Intf_GenerateService_Co_Async(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var param_anAppServerName := new CGParameterDefinition("anAppServerName", ResolveStdtypes(CGPredefinedTypeReference.String), Modifier := CGParameterModifierKind.Const);
  var param_aMessage := new CGParameterDefinition("aMessage",IROMessage_typeref, Modifier := CGParameterModifierKind.Const);
  var param_aTransportChannel := new CGParameterDefinition("aTransportChannel",IROTransportChannel_typeref);
  var param_aUri := new CGParameterDefinition("aUri",new CGConstantTypeReference("TROUri".AsTypeReference));
  var param_aUrl := new CGParameterDefinition("aUrl",
                                              ResolveStdtypes(CGPredefinedTypeReference.String),
                                              Modifier := CGParameterModifierKind.Const);
  var param_aDefaultNamespaces := new CGParameterDefinition("aDefaultNamespaces",
                                                            ResolveStdtypes(CGPredefinedTypeReference.String),
                                                            DefaultValue := "".AsLiteralExpression);

  var l_IName_Async_typeref := ResolveInterfaceTypeRef(aLibrary, $"I{aEntity.Name}_Async",Intf_name,aEntity.Name); // I%service%_Async or _di_I%service%_Async
  var l_Tname_AsyncProxy_typeref := ResolveDataTypeToTypeRefFullQualified(aLibrary,$"T{aEntity.Name}_AsyncProxy",Intf_name,aEntity.Name);

  var lmember: CGMethodDefinition;
  var ltype := new CGClassTypeDefinition($"Co{aEntity.Name}_Async",
                                          new CGNamedTypeReference("TObject") &namespace(new CGNamespaceReference("System")),
                                          Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype);

  {$REGION public class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): I%service%_Async; overload;}
  lmember := new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_Async_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if aLibrary.DataSnap then
    lmember.Parameters.Add(param_anAppServerName);

  lmember.Parameters.Add(param_aMessage);
  lmember.Parameters.Add(param_aTransportChannel);

  var l_new := new CGNewInstanceExpression(l_Tname_AsyncProxy_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aMessage.AsCallParameter);
  l_new.Parameters.Add(param_aTransportChannel.AsCallParameter);

  lmember.Statements.Add(cppGenerateProxyCast(l_new,l_IName_Async_typeref));
  ltype.Members.Add(lmember);
  {$ENDREGION}


  {$REGION public class function Create(aUri: TROUri; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember := new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_Async_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if aLibrary.DataSnap then
    lmember.Parameters.Add(param_anAppServerName);
  lmember.Parameters.Add(param_aUri);
  lmember.Parameters.Add(param_aDefaultNamespaces);

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxy_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aUri.AsCallParameter);
  l_new.Parameters.Add(param_aDefaultNamespaces.AsCallParameter);

  lmember.Statements.Add(cppGenerateProxyCast(l_new,l_IName_Async_typeref));
  ltype.Members.Add(lmember);
  {$ENDREGION}

  {$REGION public class function Create(const aUrl: string; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember := new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_Async_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if aLibrary.DataSnap then
    lmember.Parameters.Add(param_anAppServerName);
  lmember.Parameters.Add(param_aUrl);
  lmember.Parameters.Add(param_aDefaultNamespaces);

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxy_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aUrl.AsCallParameter);
  l_new.Parameters.Add(param_aDefaultNamespaces.AsCallParameter);

  lmember.Statements.Add(cppGenerateProxyCast(l_new,l_IName_Async_typeref));
  ltype.Members.Add(lmember);
  {$ENDREGION}
end;


method DelphiRodlCodeGen.Intf_GenerateService_Co(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var param_anAppServerName := new CGParameterDefinition("anAppServerName", ResolveStdtypes(CGPredefinedTypeReference.String), Modifier := CGParameterModifierKind.Const);
  var param_aMessage := new CGParameterDefinition("aMessage",IROMessage_typeref, Modifier := CGParameterModifierKind.Const);
  var param_aTransportChannel := new CGParameterDefinition("aTransportChannel",IROTransportChannel_typeref);
  var param_aUri := new CGParameterDefinition("aUri",new CGConstantTypeReference("TROUri".AsTypeReference));
  var param_aDefaultNamespaces := new CGParameterDefinition("aDefaultNamespaces",
                                                            ResolveStdtypes(CGPredefinedTypeReference.String),
                                                            DefaultValue := "".AsLiteralExpression);

  var l_IName_typeref := ResolveInterfaceTypeRef(aLibrary, $"I{aEntity.Name}",Intf_name,aEntity.Name); // I%service% (delphi) or _di_I%service% (c++Builder)
  var l_Tname_Proxy_typeref := ResolveDataTypeToTypeRefFullQualified(aLibrary,$"T{aEntity.Name}_Proxy",Intf_name,aEntity.Name); //T%service%Proxy
  var ltype := new CGClassTypeDefinition($"Co{aEntity.Name}",
                                          new CGNamedTypeReference("TObject") &namespace(new CGNamespaceReference("System")),
                                          Visibility := CGTypeVisibilityKind.Public);
  aFile.Types.Add(ltype);



  {$REGION public class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): I%service%; overload;}
  var lmember_ct := new CGMethodDefinition("Create",
                                          &Static := true,
                                          Overloaded := true,
                                          ReturnType := l_IName_typeref,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          CallingConvention := CGCallingConventionKind.Register);

  if aLibrary.DataSnap then
    lmember_ct.Parameters.Add(param_anAppServerName);
  lmember_ct.Parameters.Add(param_aMessage);
  lmember_ct.Parameters.Add(param_aTransportChannel);

  var l_new := new CGNewInstanceExpression(l_Tname_Proxy_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);

  l_new.Parameters.Add(param_aMessage.AsCallParameter);
  l_new.Parameters.Add(param_aTransportChannel.AsCallParameter);

  lmember_ct.Statements.Add(cppGenerateProxyCast(l_new,l_IName_typeref));
  ltype.Members.Add(lmember_ct);
  {$ENDREGION}


  {$REGION public class function Create(aUri: TROUri; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember_ct := new CGMethodDefinition("Create",
                                      &Static := true,
                                      Overloaded := true,
                                      ReturnType := l_IName_typeref,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);


  if aLibrary.DataSnap then
    lmember_ct.Parameters.Add(param_anAppServerName);
  lmember_ct.Parameters.Add(param_aUri);
  lmember_ct.Parameters.Add(param_aDefaultNamespaces);

  l_new := new CGNewInstanceExpression(l_Tname_Proxy_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aUri.AsCallParameter);
  l_new.Parameters.Add(param_aDefaultNamespaces.AsCallParameter);

  lmember_ct.Statements.Add(cppGenerateProxyCast(l_new,l_IName_typeref));
  ltype.Members.Add(lmember_ct);
  {$ENDREGION}

  var param_aUrl := new CGParameterDefinition("aUrl",
                                              ResolveStdtypes(CGPredefinedTypeReference.String),
                                              Modifier := CGParameterModifierKind.Const);

  {$REGION public class function Create(const aUrl: string; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember_ct := new CGMethodDefinition("Create",
                                      &Static := true,
                                      Overloaded := true,
                                      ReturnType := l_IName_typeref,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);
  if aLibrary.DataSnap then
    lmember_ct.Parameters.Add(param_anAppServerName);
  lmember_ct.Parameters.Add(param_aUrl);
  lmember_ct.Parameters.Add(param_aDefaultNamespaces);

  l_new := new CGNewInstanceExpression(l_Tname_Proxy_typeref);
  if aLibrary.DataSnap then
    l_new.Parameters.Add(param_anAppServerName.AsCallParameter);
  l_new.Parameters.Add(param_aUrl.AsCallParameter);
  l_new.Parameters.Add(param_aDefaultNamespaces.AsCallParameter);

  lmember_ct.Statements.Add(cppGenerateProxyCast(l_new,l_IName_typeref));
  ltype.Members.Add(lmember_ct);

  {$ENDREGION}
end;


method DelphiRodlCodeGen.Intf_GenerateService_I_AsyncEx(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, $"I{aEntity.AncestorName}_AsyncEx", Intf_name, aEntity.AncestorName)
  else
    lancestor := "IROAsyncInterfaceEx".AsTypeReference;
  var ltype := new CGInterfaceTypeDefinition($"I{aEntity.Name}_AsyncEx",
                                             lancestor,
                                             Visibility := CGTypeVisibilityKind.Public);
  if not PureDelphi then ltype.InterfaceGuid := Guid.NewGuid;
  aFile.Types.Add(ltype);

  {$REGION Invoke_%service_method%}
  for lmem in aEntity.DefaultInterface.Items do begin
    ltype.Members.Add(Intf_GenerateAsyncExBegin(aLibrary, aEntity, lmem, false, false, true));
    ltype.Members.Add(Intf_GenerateAsyncExBegin(aLibrary, aEntity, lmem, false, true, true));
  end;

  {$ENDREGION}

  {$REGION Retrieve_%service_method%}
  for lmem in aEntity.DefaultInterface.Items do
    ltype.Members.Add(Intf_GenerateAsyncExEnd(aLibrary, aEntity, lmem, false, true));
  {$ENDREGION}
end;


method DelphiRodlCodeGen.Intf_GenerateService_I_Async(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(aLibrary, $"I{aEntity.AncestorName}_Async",Intf_name,aEntity.AncestorName)
  else
    lancestor := "IROAsyncInterface".AsTypeReference;
  var ltype := new CGInterfaceTypeDefinition($"I{aEntity.Name}_Async",
                                             lancestor,
                                             Visibility := CGTypeVisibilityKind.Public);
  if not PureDelphi then ltype.InterfaceGuid := Guid.NewGuid;

  aFile.Types.Add(ltype);

  {$REGION Invoke_%service_method%}
  for lmem in aEntity.DefaultInterface.Items do
    ltype.Members.Add(Intf_GenerateAsyncInvoke(aLibrary, aEntity, lmem, false, true));
  {$ENDREGION}

  {$REGION Retrieve_%service_method%}
  for lmem in aEntity.DefaultInterface.Items do
    if NeedsAsyncRetrieveOperationDefinition(lmem) then
      ltype.Members.Add(Intf_GenerateAsyncRetrieve(aLibrary, aEntity, lmem, false, true));
  {$ENDREGION}
end;


method DelphiRodlCodeGen.Intf_GenerateService_I(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  {$REGION I%service%}
  var ltype := new CGInterfaceTypeDefinition($"I{aEntity.Name}",
                                             Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    ltype.Ancestors.Add(ResolveDataTypeToTypeRefFullQualified(aLibrary, "I"+aEntity.AncestorName,Intf_name,aEntity.AncestorName))  //I%service%
  else
    ltype.Ancestors.Add("IROService".AsTypeReference);


  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  GenerateCodeFirstDocumentation(aFile,$"docs_{aEntity.Name}",ltype, aEntity.Documentation);
  GenerateCodeFirstCustomAttributes(ltype, aEntity);
  ltype.InterfaceGuid := aEntity.DefaultInterface.GetOrGenerateEntityID;
  aFile.Types.Add(ltype);

  for rodl_member in aEntity.DefaultInterface.Items do begin
    {$REGION service methods}
    var cg4_member := new CGMethodDefinition(rodl_member.Name,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);
    cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    GenerateCodeFirstDocumentation(aFile,$"docs_{aEntity.Name}_{rodl_member.Name}",cg4_member, rodl_member.Documentation);
    GenerateCodeFirstCustomAttributes(cg4_member, rodl_member);
    for rodl_param in rodl_member.Items do begin
      if rodl_param.ParamFlag <> ParamFlags.Result then begin
        var cg4_param := new CGParameterDefinition(rodl_param.Name,
                                                ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_param.DataType, Intf_name));
        if isComplex(aLibrary, rodl_param.DataType) and (rodl_param.ParamFlag = ParamFlags.In) then
          cg4_param.Type := new CGConstantTypeReference(cg4_param.Type)
        else
          cg4_param.Modifier := RODLParamFlagToCodegenFlag(rodl_param.ParamFlag);
//        if IsCodeFirstCompatible then begin
//          if IsAnsiString(rodl_param.DataType) then AddCGAttribute(cg4_param,attr_ROSerializeAsAnsiString) else
//          if IsUTF8String(rodl_param.DataType) then AddCGAttribute(cg4_param,attr_ROSerializeAsUTF8String);
//        end;
        GenerateCodeFirstDocumentation(aFile,$"docs_{aEntity.Name}_{rodl_member.Name}_{rodl_param.Name}",cg4_param, rodl_param.Documentation);
        GenerateCodeFirstCustomAttributes(cg4_param, rodl_param);
        cg4_param.XmlDocumentation := GenerateDocumentation(rodl_param);
        cg4_member.Parameters.Add(cg4_param);
      end;
    end;
    if assigned(rodl_member.Result) then cg4_member.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,rodl_member.Result.DataType, Intf_name);
    ltype.Members.Add(cg4_member);
    {$ENDREGION}
  end;
  {$ENDREGION}
end;




end.