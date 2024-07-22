namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

type
  CPlusPlusBuilderRodlCodeGen = public class(DelphiRodlCodeGen)
  private
    fimp_enums: CGImport;
    fimp_Intf_Shared: CGImport;
    method Intf_CreateCodeUnit(aLibrary: RodlLibrary; aName: String; aService: Boolean := false): CGCodeUnit;
    begin
      var lUnit := new CGCodeUnit();
      lUnit.Namespace := new CGNamespaceReference(targetNamespace);

      lUnit.FileName := aName;
      lUnit.Initialization := new List<CGStatement>;
      lUnit.Finalization := new List<CGStatement>;
      lUnit.HeaderComment := GenerateUnitComment(false);
      Add_RemObjects_Inc(lUnit, aLibrary);
      Intf_GenerateInterfaceImports(lUnit, aLibrary);

      cpp_smartInit(lUnit);
      Intf_GenerateImplImports(lUnit, aLibrary);
      if aService then begin
        cpp_pragmalink(lUnit,CapitalizeString('uROProxy'));
        cpp_pragmalink(lUnit,CapitalizeString('uROAsync'));
      end;

      exit lUnit;
    end;
    method Invk_CreateCodeUnit(aLibrary: RodlLibrary; aName: String): CGCodeUnit;
    begin
      var lUnit := new CGCodeUnit();
      lUnit.Namespace := new CGNamespaceReference(targetNamespace);
      lUnit.FileName := aName;
      lUnit.Initialization := new List<CGStatement>;
      lUnit.Finalization := new List<CGStatement>;
      lUnit.HeaderComment := GenerateUnitComment(False);
      Add_RemObjects_Inc(lUnit, aLibrary);
      Invk_GenerateInterfaceImports(lUnit, aLibrary);

      cpp_smartInit(lUnit);
      Invk_GenerateImplImports(lUnit, aLibrary);
      cpp_pragmalink(lUnit,CapitalizeString('uROServer'));
      exit lUnit;
    end;
    method ProcessEntity(aFile: CGCodeUnit; aEntity: RodlEntity);
    method GenerateImportForEntity(aFile: CGCodeUnit; aEntity: nullable RodlEntity);
    method AddImport(aFile: CGCodeUnit; aImport: CGImport);
  protected
    method _SetLegacyStrings(value: Boolean); override;
    method Add_RemObjects_Inc(aFile: CGCodeUnit; aLibrary: RodlLibrary); empty;override;
    method cpp_GenerateAsyncAncestorMethodCalls(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); override;
    method cpp_GenerateAncestorMethodCalls(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition; aMode: ModeKind); override;
    method cpp_IUnknownSupport(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); override;
    method cpp_Impl_constructor(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); override;
    method cppGenerateProxyCast(aProxy: CGNewInstanceExpression; aInterface: CGNamedTypeReference):List<CGStatement>;override;
    method cpp_GenerateProxyConstructors(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition); override;
    method cpp_generateInheritedBody(aMethod: CGMethodDefinition);
    method cpp_generateDoLoginNeeded(aType: CGClassTypeDefinition);override;
    method cpp_pragmalink(aFile: CGCodeUnit; aUnitName: String); override;
    method cpp_ClassId(anExpression: CGExpression): CGExpression; override;
    method cpp_UuidId(anExpression: CGExpression): CGExpression; override;
    method cpp_Pointer(value: CGExpression): CGExpression;override;
    method cpp_AddressOf(value: CGExpression): CGExpression;override;
    method CapitalizeString(aValue: String):String;override;
    method cpp_GenerateArrayDestructor(anArray: CGTypeDefinition); override;
    method cpp_smartInit(aFile: CGCodeUnit); override;
    method cpp_DefaultNamespace:CGExpression; override;
    method cpp_GetNamespaceForUses(aUse: RodlUse):String;override;
    method cpp_GlobalCondition_ns:CGConditionalDefine;override;
    method cpp_GlobalCondition_ns_name: String; override;
    method cpp_GetTROAsyncCallbackType: String; override;
    method cpp_GetTROAsyncCallbackMethodType: String; override;
  protected
    property PureDelphi: Boolean read False; override;
    property CanUseNameSpace: Boolean := True; override;
    method Array_SetLength(anArray, aValue: CGExpression): CGExpression; override;
    method Array_GetLength(anArray: CGExpression): CGExpression; override;
    method RaiseError(aMessage:CGExpression; aParams:List<CGExpression>): CGExpression;override;
    method ResolveDataTypeToTypeRefFullQualified(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String := '';aCapitalize: Boolean := True): CGTypeReference; override;
    method ResolveInterfaceTypeRef(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String := ''; aCapitalize: Boolean := True): CGNamedTypeReference; override;
    method InterfaceCast(aSource, aType, aDest: CGExpression): CGExpression; override;
    method GenerateTypeInfoCall(aLibrary: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression; override;
    method cppGenerateEnumTypeInfo(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum); override;
    method GlobalsConst_GenerateServerGuid(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService); override;
    method AddMessageDirective(aMessage: String): CGStatement; override;
    method Impl_GenerateDFMInclude(aFile: CGCodeUnit);override;
    method Impl_CreateClassFactory(aLibrary: RodlLibrary; aEntity: RodlService; lvar: CGExpression): List<CGStatement>;override;
    method Impl_GenerateCreateService(aMethod: CGMethodDefinition;aCreator: CGNewInstanceExpression);override;
    method AddDynamicArrayParameter(aMethod:CGMethodCallExpression; aDynamicArrayParam: CGExpression); override;
    method GenerateCGImport(aName: String; aNamespace: String := ''; aExt: String := 'hpp'; aCapitalize: Boolean = true): CGImport; override;
    method Invk_GetDefaultServiceRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); override;
    method Invk_CheckRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); override;

  public
    property DelphiXE2Mode: State := State.On; override;
    property FPCMode: State read State.Off; override;
    property CodeFirstMode: State read State.Off; override;
    property GenericArrayMode: State read State.Off; override;
    property SplitTypes: Boolean := false;
    constructor;
    method GenerateInterfaceCodeUnits(aLibrary: RodlLibrary; aTargetNamespace: String): List<CGCodeUnit>;
    method GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; override;
    method GenerateInvokerCodeUnits(aLibrary: RodlLibrary; aTargetNamespace: String): List<CGCodeUnit>;
    method GenerateInvokerFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; override;
  end;

implementation

constructor CPlusPlusBuilderRodlCodeGen;
begin
  fLegacyStrings := False;
  IncludeUnitNameForOwnTypes := true;
  IncludeUnitNameForOtherTypes := true;
  PredefinedTypes.Add(CGPredefinedTypeKind.String,new CGNamedTypeReference("UnicodeString") &namespace(new CGNamespaceReference("System")) isClasstype(False));

  CodeGenTypes.RemoveAll;
  CodeGenTypes.Add("integer", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  CodeGenTypes.Add("datetime", new CGNamedTypeReference("TDateTime") isClasstype(False));
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeReference.Double));
  CodeGenTypes.Add("currency", new CGNamedTypeReference("Currency") isClasstype(False));
  CodeGenTypes.Add("widestring", new CGNamedTypeReference("UnicodeString") &namespace(new CGNamespaceReference("System")) isClasstype(False));
  CodeGenTypes.Add("ansistring", new CGNamedTypeReference("String") &namespace(new CGNamespaceReference("System")) isClasstype(False));
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeReference.Int64));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeReference.Boolean));
  CodeGenTypes.Add("variant", new CGNamedTypeReference("Variant") isClasstype(False));
  CodeGenTypes.Add("binary", new CGNamedTypeReference("Binary") isClasstype(True));
  CodeGenTypes.Add("xml", ResolveInterfaceTypeRef(nil,'IXMLNode','',''));
  CodeGenTypes.Add("guid", new CGNamedTypeReference("TGuidString") isClasstype(False));
  CodeGenTypes.Add("decimal", new CGNamedTypeReference("TDecimalVariant") isClasstype(False));
  CodeGenTypes.Add("utf8string", new CGNamedTypeReference("String") &namespace(new CGNamespaceReference("System")) isClasstype(False));
  CodeGenTypes.Add("xsdatetime", new CGNamedTypeReference("XsDateTime") isClasstype(True));

  // from
  // http://docwiki.embarcadero.com/RADStudio/XE8/en/Keywords,_Alphabetical_Listing_Index
  // http://en.cppreference.com/w/cpp/keyword
  ReservedWords.RemoveAll;
  ReservedWords.Add([
    "__asm", "__automated", "__cdecl", "__classid", "__classmethod", "__closure", "__declspec", "__delphirtti", "__dispid",
    "__except", "__export", "__fastcall", "__finally", "__import", "__inline", "__int16", "__int32", "__int64", "__int8",
    "__msfastcall", "__msreturn", "__pascal", "__property", "__published", "__rtti", "__stdcall", "__thread", "__try",
    "_asm", "_Bool", "_cdecl", "_Complex", "_export", "_fastcall", "_Imaginary", "_import", "_pascal", "_stdcall", "alignas",
    "alignof", "and", "and_eq", "asm", "auto", "axiom", "bitand", "bitor", "bool", "break", "case", "catch", "cdecl", "char",
    "char16_t", "char32_t", "class", "compl", "concept", "concept_map", "const", "const_cast", "constexpr", "continue",
    "decltype", "default", "delete", "deprecated", "do", "double", "Dynamic cast", "dynamic_cast", "else", "enum", "explicit",
    "export", "extern", "false", "final", "float", "for", "friend", "goto", "if", "inline", "int", "late_check", "long",
    "mutable", "namespace", "new", "noexcept", "noreturn", "not", "not_eq", "nullptr", "operator", "or", "or_eq", "pascal",
    "private", "protected", "public", "register", "reinterpret_cast", "requires", "restrict", "return", "short", "signed",
    "sizeof", "static", "static_assert", "static_cast", "struct", "switch", "template", "this", "thread_local", "throw",
    "true", "try", "typedef", "typeid", "typename", "typeof", "union", "unsigned", "using", "uuidof", "virtual", "void",
    "volatile", "wchar_t", "while", "xor", "xor_eq"]);
end;

method CPlusPlusBuilderRodlCodeGen.Array_SetLength(anArray: CGExpression; aValue: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression(anArray,"set_length",[aValue.AsCallParameter].ToList, CallSiteKind := CGCallSiteKind.Instance);
end;

method CPlusPlusBuilderRodlCodeGen.Array_GetLength(anArray: CGExpression): CGExpression;
begin
  exit new CGFieldAccessExpression(anArray,"Length", CallSiteKind := CGCallSiteKind.Instance);
end;

method CPlusPlusBuilderRodlCodeGen.RaiseError(aMessage: CGExpression; aParams: List<CGExpression>): CGExpression;
begin
  var lres := new CGMethodCallExpression(CapitalizeString('uROClasses').AsNamedIdentifierExpression,'RaiseError',CallSiteKind := CGCallSiteKind.Static);

  if aMessage is CGNamedIdentifierExpression then begin
      aMessage:=  ('_'+CGNamedIdentifierExpression(aMessage).Name).AsNamedIdentifierExpression;
    lres.Parameters.Add(new CGMethodCallExpression(nil, 'LoadResourceString',[new CGCallParameter(aMessage, Modifier := CGParameterModifierKind.Var)]).AsCallParameter)
  end
  else
    lres.Parameters.Add(aMessage.AsCallParameter);
  if aParams <> nil then
    lres.Parameters.Add(new CGArrayLiteralExpression(aParams).AsCallParameter);
  exit lres;
end;


method CPlusPlusBuilderRodlCodeGen.cpp_GenerateAncestorMethodCalls(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition; aMode: ModeKind);
begin
  if not assigned(aEntity.AncestorEntity) then exit;
  if not (aEntity.AncestorEntity is RodlService) then exit;
  var laEntity := RodlService(aEntity.AncestorEntity);
  case aMode of
    ModeKind.Plain: begin
      for lmem in laEntity.DefaultInterface.Items do begin
        {$REGION service methods}
        var mem := new CGMethodDefinition(lmem.Name,
                                          Virtuality := CGMemberVirtualityKind.Override,
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

        if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(aLibrary,lmem.Result.DataType, Intf_name);
        cpp_generateInheritedBody(mem);
        service.Members.Add(mem);
        {$ENDREGION}
      end;
    end;
    ModeKind.Async: begin
      {$REGION Invoke_%service_method%}
      for lmem in laEntity.DefaultInterface.Items do begin
          var lm := Intf_GenerateAsyncInvoke(aLibrary, laEntity, lmem, false);
          lm.Virtuality := CGMemberVirtualityKind.Override;

          cpp_generateInheritedBody(lm);
          service.Members.Add(lm);
        end;
      {$ENDREGION}
      {$REGION Retrieve_%service_method%}
      for lmem in laEntity.DefaultInterface.Items do
        if NeedsAsyncRetrieveOperationDefinition(lmem) then begin
          var lm := Intf_GenerateAsyncRetrieve(aLibrary, laEntity, lmem, false);
          lm.Virtuality := CGMemberVirtualityKind.Override;
          cpp_generateInheritedBody(lm);
          service.Members.Add(lm);
        end;
      {$ENDREGION}
    end;
    ModeKind.AsyncEx: begin
      {$REGION Begin%service_method%}
      for lmem in laEntity.DefaultInterface.Items do begin
        var lm := Intf_GenerateAsyncExBegin(aLibrary, laEntity, lmem, false, false);
        lm.Virtuality := CGMemberVirtualityKind.Override;

        cpp_generateInheritedBody(lm);
        service.Members.Add(lm);

        lm := Intf_GenerateAsyncExBegin(aLibrary, laEntity, lmem, false, true);
        lm.Virtuality := CGMemberVirtualityKind.Override;

        cpp_generateInheritedBody(lm);
        service.Members.Add(lm);
      end;
      {$ENDREGION}

      {$REGION End%service_method%}
      for lmem in laEntity.DefaultInterface.Items do begin
        var lm := Intf_GenerateAsyncExEnd(aLibrary, laEntity, lmem, false);
        lm.Virtuality := CGMemberVirtualityKind.Override;
        cpp_generateInheritedBody(lm);
        service.Members.Add(lm);
      end;
      {$ENDREGION}
    end;
  end;
  cpp_GenerateAncestorMethodCalls(aLibrary, laEntity, service, aMode);
end;

method CPlusPlusBuilderRodlCodeGen.cpp_IUnknownSupport(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition);
begin

  var lm := new CGMethodDefinition('QueryInterface',
                                   [new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                               'cppQueryInterface',
                                                               ['IID'.AsNamedIdentifierExpression.AsCallParameter,
                                                                new CGTypeCastExpression('Obj'.AsNamedIdentifierExpression, CGPointerTypeReference.VoidPointer).AsCallParameter].ToList,
                                                                CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                   Parameters := [new CGParameterDefinition('IID', new CGPointerTypeReference(new CGNamedTypeReference('GUID') isClasstype(False)) &reference(true), Modifier := CGParameterModifierKind.Const),
                                                  new CGParameterDefinition('Obj', new CGPointerTypeReference(new CGPointerTypeReference(CGPredefinedTypeReference.Void)))].ToList(),
                                   Virtuality := CGMemberVirtualityKind.Override,
                                   Visibility := CGMemberVisibilityKind.Protected,
                                   ReturnType := new CGNamedTypeReference('HRESULT') isClasstype(False),
                                   CallingConvention := CGCallingConventionKind.StdCall);
  service.Members.Add(lm);

  lm := new CGMethodDefinition('AddRef',
                                [new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                            '_AddRef',
                                                            CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Protected,
                                ReturnType := new CGNamedTypeReference('ULONG') isClasstype(False),
                                CallingConvention := CGCallingConventionKind.StdCall);
  service.Members.Add(lm);

  lm := new CGMethodDefinition('Release',
                              [new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                          '_Release',
                                                          CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                              Virtuality := CGMemberVirtualityKind.Override,
                              Visibility := CGMemberVisibilityKind.Protected,
                              ReturnType := new CGNamedTypeReference('ULONG') isClasstype(False),
                              CallingConvention := CGCallingConventionKind.StdCall);
  service.Members.Add(lm);
end;

method CPlusPlusBuilderRodlCodeGen.cpp_Impl_constructor(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition);
begin
  var ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public,
                                          CallingConvention := CGCallingConventionKind.Register);
  if isDFMNeeded then
    ctor.Parameters.Add(new CGParameterDefinition('aOwner', new CGNamedTypeReference('Classes::TComponent')));
  service.Members.Add(ctor);
end;

method CPlusPlusBuilderRodlCodeGen.ResolveInterfaceTypeRef(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String; aCapitalize: Boolean): CGNamedTypeReference;
begin
  var lLower := aDataType.ToLowerInvariant();
  if CodeGenTypes.ContainsKey(lLower) then
    exit CGNamedTypeReference(CodeGenTypes[lLower]) // hack, only possibly type is IXMLNode
  else begin
    if assigned(aLibrary) then begin
      var namesp := ResolveNamespace(aLibrary,aDataType,aDefaultUnitName,aOrigDataType);
      if String.IsNullOrEmpty(namesp) then
        exit new CGNamedTypeReference('_di_'+aDataType) isClassType(false)
      else
        exit new CGNamedTypeReference('_di_'+aDataType)
                                      &namespace(new CGNamespaceReference(namesp))
                                      isClassType(false);
    end
    else begin
      if String.IsNullOrEmpty(aDefaultUnitName) then
        exit new CGNamedTypeReference('_di_'+aDataType) isClassType(false)
      else begin
        var lns := iif(aCapitalize and (aDefaultUnitName <> targetNamespace) ,CapitalizeString(aDefaultUnitName), aDefaultUnitName);
        exit new CGNamedTypeReference('_di_'+aDataType)
                                      &namespace(new CGNamespaceReference(lns))
                                      isClassType(false);
      end;
    end;
  end;

end;

method CPlusPlusBuilderRodlCodeGen.InterfaceCast(aSource: CGExpression; aType: CGExpression; aDest: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression(aSource,'Supports',[aDest.AsCallParameter], CallSiteKind := CGCallSiteKind.Reference);
end;

method CPlusPlusBuilderRodlCodeGen.GenerateTypeInfoCall(aLibrary: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression;
begin
  if aTypeInfo is CGPredefinedTypeReference then begin
    var l_method: String;
    case CGPredefinedTypeReference(aTypeInfo).Kind of
      CGPredefinedTypeKind.Int32:  l_method := 'GetTypeInfo_int';
      CGPredefinedTypeKind.Double: l_method := 'GetTypeInfo_double';
      CGPredefinedTypeKind.Int64:  l_method := 'GetTypeInfo_int64';
      CGPredefinedTypeKind.Boolean:l_method := 'GetTypeInfo_bool';
    else
      raise new Exception(String.Format('GenerateTypeInfoCall: Unsupported predefined type: {0}',[CGPredefinedTypeReference(aTypeInfo).Kind.ToString]))
    end;
    exit new CGMethodCallExpression('Urotypes'.AsNamedIdentifierExpression, l_method, CallSiteKind := CGCallSiteKind.Static);
  end;

  if aTypeInfo is CGNamedTypeReference then begin
    var l_method: String;
    var l_name := CGNamedTypeReference(aTypeInfo).Name;
    case l_name of
      'TDateTime':        l_method := 'GetTypeInfo_TDateTime';
      'Currency':         l_method := 'GetTypeInfo_Currency';
      'UnicodeString':    l_method := 'GetTypeInfo_UnicodeString';
      'AnsiString':       l_method := 'GetTypeInfo_AnsiString';
      'Variant':          l_method := 'GetTypeInfo_Variant';
      'TGuidString':      l_method := 'GetTypeInfo_TGuidString';
      'TDecimalVariant':  l_method := 'GetTypeInfo_TDecimalVariant';
      'UTF8String':       l_method := 'GetTypeInfo_UTF8String';
      'String':           l_method := 'GetTypeInfo_String';
      '_di_IXMLNode':     l_method := 'GetTypeInfo_Xml';
    else
    end;
    if not String.IsNullOrEmpty(l_method) then
      exit new CGMethodCallExpression('Urotypes'.AsNamedIdentifierExpression, l_method, CallSiteKind := CGCallSiteKind.Static);
    if isComplex(aLibrary, l_name) then
      exit new CGMethodCallExpression(nil,'__typeinfo',[l_name.AsNamedIdentifierExpression.AsCallParameter]);
    if isEnum(aLibrary, l_name) then begin
      var lnamespace: CGExpression := nil;
      if assigned(CGNamedTypeReference(aTypeInfo).Namespace)then lnamespace := CGNamedTypeReference(aTypeInfo).Namespace.Name.AsNamedIdentifierExpression;
      exit new CGMethodCallExpression(lnamespace, 'GetTypeInfo_'+l_name, CallSiteKind := CGCallSiteKind.Static);
    end;
    raise new Exception(String.Format('GenerateTypeInfoCall: Unsupported datatype: {0}',[l_name]));
  end;
  raise new Exception(String.Format('GenerateTypeInfoCall: Unsupported type reference: {0}',[aTypeInfo.ToString]));
end;

method CPlusPlusBuilderRodlCodeGen.cppGenerateEnumTypeInfo(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var lenum_typeref := new CGNamedTypeReference(aEntity.Name) isclasstype(false);
  var lenum := new CGClassTypeDefinition(aEntity.Name+'TypeHolder','TPersistent'.AsTypeReference,
                                         Visibility := CGTypeVisibilityKind.Public);
  lenum.Members.Add(new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public,
                                                CallingConvention := CGCallingConventionKind.Register));

  lenum.Members.Add(new CGFieldDefinition('fHolderField',lenum_typeref, Visibility := CGMemberVisibilityKind.Private));
  lenum.Members.Add(new CGPropertyDefinition('HolderField',lenum_typeref,
                                             Visibility := CGMemberVisibilityKind.Published,
                                             GetExpression := 'fHolderField'.AsNamedIdentifierExpression,
                                             SetExpression := 'fHolderField'.AsNamedIdentifierExpression));
  aFile.Types.Add(lenum);

  aFile.Globals.Add(new CGMethodDefinition('GetTypeInfo_'+aEntity.Name,
                                            [new CGPointerDereferenceExpression(new CGFieldAccessExpression(
                                                  new CGMethodCallExpression(nil, 'GetPropInfo',
                                                                            [new CGMethodCallExpression(nil, '__typeinfo',[lenum.Name.AsNamedIdentifierExpression.AsCallParameter]).AsCallParameter,
                                                                             'HolderField'.AsLiteralExpression.AsCallParameter]),
                                             'PropType',
                                             CallSiteKind := CGCallSiteKind.Reference
                                            )).AsReturnStatement],
                                            ReturnType := ResolveDataTypeToTypeRefFullQualified(nil,'PTypeInfo',''),
                                            CallingConvention := CGCallingConventionKind.Register,
                                            Visibility := CGMemberVisibilityKind.Public
                                            ).AsGlobal);
end;

method CPlusPlusBuilderRodlCodeGen.GlobalsConst_GenerateServerGuid(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lname := aEntity.Name;
  aFile.Globals.Add(new CGFieldDefinition(String.Format("I{0}_IID",[lname]),
                                         new CGNamedTypeReference('GUID') isClasstype(false),
                                          Constant := true,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Initializer := new CGMethodCallExpression(
                                                              'Sysutils'.AsNamedIdentifierExpression,
                                                              'StringToGUID',
                                                              [('{'+String(aEntity.DefaultInterface.EntityID.ToString).ToUpperInvariant+'}').AsLiteralExpression.AsCallParameter],
                                                              CallSiteKind := CGCallSiteKind.Static)
                                       ).AsGlobal);
end;

method CPlusPlusBuilderRodlCodeGen.cppGenerateProxyCast(aProxy: CGNewInstanceExpression; aInterface: CGNamedTypeReference): List<CGStatement>;
begin
  result := new List<CGStatement>;
  result.Add(new CGVariableDeclarationStatement('lresult',aInterface));
  result.Add(new CGVariableDeclarationStatement('lproxy',CGTypeReferenceExpression(aProxy.Type).Type,aProxy));

  var lresult := new CGLocalVariableAccessExpression('lresult');
  var lproxy :=  'lproxy'.AsNamedIdentifierExpression;
  var lQuery := new CGMethodCallExpression(lproxy, 'GetInterface',
                                           [lresult.AsCallParameter],
                                            CallSiteKind := CGCallSiteKind.Reference);

  result.Add(new CGIfThenElseStatement( new CGUnaryOperatorExpression(lQuery,CGUnaryOperatorKind.Not),
                                        new CGBeginEndBlockStatement(
                                            [ GenerateDestroyExpression(lproxy),
                                              new CGThrowExpression(new CGNewInstanceExpression('EIntfCastError'.AsNamedIdentifierExpression,
                                              [String.Format('{0} interface not supported',[aInterface.Name]).AsLiteralExpression.AsCallParameter]))
                                            ]),
                                        lresult.AsReturnStatement));

//    _di_INewService result;
//    TNewService_Proxy* proxy = new TNewService_Proxy(aMessage, aTransportChannel);
//    if (proxy->QueryInterface(INewService_IID, reinterpret_cast<void**>(&result)) != S_OK)
//    {
//      delete proxy;
//      throw EIntfCastError::EIntfCastError("INewService not supported");
//    }
//    return result;

end;

method CPlusPlusBuilderRodlCodeGen.cpp_GenerateProxyConstructors(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition);
begin

  {$REGION public class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): I%service%; overload;}
  var lmember_ct:= new CGConstructorDefinition(Overloaded := true,
                                               Visibility := CGMemberVisibilityKind.Public,
                                               Virtuality := CGMemberVirtualityKind.Virtual,
                                               CallingConvention := CGCallingConventionKind.Register);
  lmember_ct.Parameters.Add(new CGParameterDefinition('aMessage',IROMessage_typeref, Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aTransportChannel',IROTransportChannel_typeref, Modifier := CGParameterModifierKind.Const));
  service.Members.Add(lmember_ct);
  {$ENDREGION}

  {$REGION public class function Create(const aUri: TROUri; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember_ct:= new CGConstructorDefinition(Overloaded := true,
                                           Visibility := CGMemberVisibilityKind.Public,
                                           Virtuality := CGMemberVirtualityKind.Virtual,
                                           CallingConvention := CGCallingConventionKind.Register);
  lmember_ct.Parameters.Add(new CGParameterDefinition('aUri', new CGConstantTypeReference('TROUri'.AsTypeReference)));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeReference.String), DefaultValue := ''.AsLiteralExpression));
  service.Members.Add(lmember_ct);
  {$ENDREGION}

  {$REGION public class function Create(const aUrl: string; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember_ct:= new CGConstructorDefinition(Overloaded := true,
                                           Visibility := CGMemberVisibilityKind.Public,
                                           Virtuality := CGMemberVirtualityKind.Virtual,
                                           CallingConvention := CGCallingConventionKind.Register);
  lmember_ct.Parameters.Add(new CGParameterDefinition('aUrl',ResolveStdtypes(CGPredefinedTypeReference.String), Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeReference.String), DefaultValue := ''.AsLiteralExpression));
  service.Members.Add(lmember_ct);
  {$ENDREGION}
end;

method CPlusPlusBuilderRodlCodeGen.cpp_generateInheritedBody(aMethod: CGMethodDefinition);
begin
  var ls :=new CGMethodCallExpression(CGInheritedExpression.Inherited, aMethod.Name);
  for p in aMethod.Parameters do
    ls.Parameters.Add(p.Name.AsNamedIdentifierExpression.AsCallParameter);
  if assigned(aMethod.ReturnType)then
    aMethod.Statements.Add(ls.AsReturnStatement)
  else
    aMethod.Statements.Add(ls);
end;

method CPlusPlusBuilderRodlCodeGen.AddMessageDirective(aMessage: String): CGStatement;
begin
  exit new CGRawStatement('#pragma message("'+aMessage+'")');
end;

method CPlusPlusBuilderRodlCodeGen.Impl_GenerateDFMInclude(aFile: CGCodeUnit);
begin
  aFile.ImplementationDirectives.Add(new CGCompilerDirective('#pragma resource "*.dfm"'));
end;

method CPlusPlusBuilderRodlCodeGen.Impl_CreateClassFactory(aLibrary: RodlLibrary; aEntity: RodlService; lvar: CGExpression): List<CGStatement>;
begin
  var r := new List<CGStatement>;
  var l_EntityName := aEntity.Name;
  var l_TInvoker := 'T'+l_EntityName+'_Invoker';
  var l_methodName := 'Create_'+l_EntityName;

  var l_creator:= new CGNewInstanceExpression('TROClassFactory'.AsTypeReference,
                                   [l_EntityName.AsLiteralExpression.AsCallParameter,
                                    l_methodName.AsNamedIdentifierExpression.AsCallParameter,
                                    cpp_ClassId(l_TInvoker.AsNamedIdentifierExpression).AsCallParameter]);
  r.Add(new CGVariableDeclarationStatement('lfactory','TROClassFactory'.AsTypeReference,l_creator));
  r.Add(new CGMethodCallExpression('lfactory'.AsNamedIdentifierExpression,'GetInterface',
                                    [lvar.AsCallParameter],
                                    CallSiteKind := CGCallSiteKind.Reference));
  exit r;
  //new TROClassFactory("NewService", Create_NewService, __classid(TNewService_Invoker));
end;

method CPlusPlusBuilderRodlCodeGen.Impl_GenerateCreateService(aMethod: CGMethodDefinition; aCreator: CGNewInstanceExpression);
begin
  aMethod.Statements.Add(new CGVariableDeclarationStatement('lservice', CGTypeReferenceExpression(aCreator.Type).Type, aCreator));
  aMethod.Statements.Add(new CGMethodCallExpression('lservice'.AsNamedIdentifierExpression,'GetInterface',
                        ['anInstance'.AsNamedIdentifierExpression.AsCallParameter],
                          CallSiteKind := CGCallSiteKind.Reference));

end;

method CPlusPlusBuilderRodlCodeGen.cpp_pragmalink(aFile: CGCodeUnit; aUnitName: String);
begin
  aFile.ImplementationDirectives.Add(new CGCompilerDirective('#pragma link "'+aUnitName+'"'));
end;

method CPlusPlusBuilderRodlCodeGen.AddDynamicArrayParameter(aMethod: CGMethodCallExpression; aDynamicArrayParam: CGExpression);
begin
  aMethod.Parameters.Add(cpp_AddressOf(new CGArrayElementAccessExpression(aDynamicArrayParam,[new CGIntegerLiteralExpression(0)])).AsCallParameter);
  aMethod.Parameters.Add(new CGFieldAccessExpression(aDynamicArrayParam,'Length', CallSiteKind := CGCallSiteKind.Instance).AsCallParameter);
end;

method CPlusPlusBuilderRodlCodeGen.ResolveDataTypeToTypeRefFullQualified(aLibrary: RodlLibrary; aDataType: String; aDefaultUnitName: String; aOrigDataType: String; aCapitalize: Boolean): CGTypeReference;
begin
  exit inherited ResolveDataTypeToTypeRefFullQualified(aLibrary, aDataType, aDefaultUnitName, aOrigDataType, aCapitalize and (aDefaultUnitName <> targetNamespace));
end;

method CPlusPlusBuilderRodlCodeGen.GenerateCGImport(aName: String;aNamespace : String; aExt: String; aCapitalize: Boolean): CGImport;
begin
  var lns := aName+'.'+aExt;
  if aExt in ['h', 'hpp'] then begin
    if String.IsNullOrEmpty(aNamespace) then begin
      if aCapitalize then
        exit new CGImport(CapitalizeString(lns))
      else
        exit new CGImport(lns);
    end
    else
      exit new CGImport(new CGNamedTypeReference(aNamespace+'.'+lns))
  end
  else
    exit new CGImport(new CGNamespaceReference(iif(String.IsNullOrEmpty(aNamespace), '',aNamespace+'.')+lns))
end;

method CPlusPlusBuilderRodlCodeGen.Invk_GetDefaultServiceRoles(&method: CGMethodDefinition; roles: CGArrayLiteralExpression);
begin
  &method.Statements.Add(new CGVariableDeclarationStatement('ltemp',new CGNamedTypeReference('TStringArray') isclasstype(false),new CGMethodCallExpression(CGInheritedExpression.Inherited,'GetDefaultServiceRoles',CallSiteKind:= CGCallSiteKind.Static)));
  var ltemp := new CGLocalVariableAccessExpression('ltemp');
  if roles.Elements.Count > 0 then begin
    var ltemp_len := new CGFieldAccessExpression(ltemp,'Length', CallSiteKind := CGCallSiteKind.Instance);
    &method.Statements.Add(new CGVariableDeclarationStatement('llen',ResolveStdtypes(CGPredefinedTypeReference.Int), ltemp_len));
    &method.Statements.Add(new CGAssignmentStatement(ltemp_len, new CGBinaryOperatorExpression(ltemp_len, new CGIntegerLiteralExpression(roles.Elements.Count), CGBinaryOperatorKind.Addition)));
    var llen :=new CGLocalVariableAccessExpression('llen');
    for i: Integer := 0 to roles.Elements.Count-1 do begin
      var lind: CGExpression := llen;
      if i > 0 then lind := new CGBinaryOperatorExpression(lind, new CGIntegerLiteralExpression(i), CGBinaryOperatorKind.Addition);
      &method.Statements.Add(new CGAssignmentStatement(new CGArrayElementAccessExpression(ltemp,[lind]),roles.Elements[i]));
    end;
  end;
  &method.Statements.Add(ltemp.AsReturnStatement);
end;

method CPlusPlusBuilderRodlCodeGen.Invk_CheckRoles(&method: CGMethodDefinition; roles: CGArrayLiteralExpression);
begin
  var l__Instance := '__Instance'.AsNamedIdentifierExpression;
  &method.Statements.Add(new CGVariableDeclarationStatement('ltemp',new CGNamedTypeReference('TStringArray') isclasstype(false),new CGMethodCallExpression(nil, 'GetDefaultServiceRoles')));
  var ltemp := new CGLocalVariableAccessExpression('ltemp');
  var ltemp_len := new CGFieldAccessExpression(ltemp,'Length', CallSiteKind := CGCallSiteKind.Instance);
  if roles.Elements.Count > 0 then begin
    &method.Statements.Add(new CGVariableDeclarationStatement('llen',ResolveStdtypes(CGPredefinedTypeReference.Int), ltemp_len));
    &method.Statements.Add(new CGAssignmentStatement(ltemp_len, new CGBinaryOperatorExpression(ltemp_len, new CGIntegerLiteralExpression(roles.Elements.Count), CGBinaryOperatorKind.Addition)));
    var llen :=new CGLocalVariableAccessExpression('llen');
    for i: Integer := 0 to roles.Elements.Count-1 do begin
      var lind: CGExpression := llen;
      if i > 0 then lind := new CGBinaryOperatorExpression(lind, new CGIntegerLiteralExpression(i), CGBinaryOperatorKind.Addition);
      &method.Statements.Add(new CGAssignmentStatement(new CGArrayElementAccessExpression(ltemp,[lind]),roles.Elements[i]));
    end;
  end;
  var zero := new CGIntegerLiteralExpression(0);
  &method.Statements.Add(
    new CGIfThenElseStatement(
      new CGBinaryOperatorExpression(ltemp_len, zero,CGBinaryOperatorKind.GreaterThan),
      new CGMethodCallExpression(nil,'CheckRoles',
                                  [l__Instance.AsCallParameter,
                                   new CGCallParameter( new CGArrayElementAccessExpression(ltemp,[zero]), Modifier := CGParameterModifierKind.Var),
                                   ltemp_len.AsCallParameter ].ToList)
  ));
end;

method CPlusPlusBuilderRodlCodeGen.cpp_generateDoLoginNeeded(aType: CGClassTypeDefinition);
begin
  //virtual void __fastcall DoLoginNeeded(Uroclientintf::_di_IROMessage aMessage, System::Sysutils::Exception* anException, bool &aRetry);
  aType.Members.Add(new CGMethodDefinition('DoLoginNeeded',
                  [new CGMethodCallExpression(CGInheritedExpression.Inherited,'DoLoginNeeded',
                                              ['aMessage'.AsNamedIdentifierExpression.AsCallParameter,
                                              'anException'.AsNamedIdentifierExpression.AsCallParameter,
                                              'aRetry'.AsNamedIdentifierExpression.AsCallParameter],
                                              CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                  Parameters := [new CGParameterDefinition('aMessage', IROMessage_typeref),
                                 new CGParameterDefinition('anException', new CGNamedTypeReference('Exception') &namespace(new CGNamespaceReference('System::Sysutils')) isclasstype(true)),
                                 new CGParameterDefinition('aRetry', ResolveStdtypes(CGPredefinedTypeReference.Boolean), Modifier := CGParameterModifierKind.Var)].ToList,
                  CallingConvention := CGCallingConventionKind.Register,
                  Visibility := CGMemberVisibilityKind.Public,
                  Virtuality := CGMemberVirtualityKind.Virtual));
end;

method CPlusPlusBuilderRodlCodeGen.cpp_ClassId(anExpression: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression(nil, '__classid',[anExpression.AsCallParameter])
end;

method CPlusPlusBuilderRodlCodeGen.cpp_Pointer(value: CGExpression): CGExpression;
begin
  exit new CGPointerDereferenceExpression(value);
end;

method CPlusPlusBuilderRodlCodeGen.cpp_AddressOf(value: CGExpression): CGExpression;
begin
  exit new CGUnaryOperatorExpression(value, CGUnaryOperatorKind.AddressOf);
end;

method CPlusPlusBuilderRodlCodeGen.cpp_GenerateAsyncAncestorMethodCalls(aLibrary: RodlLibrary; aEntity: RodlService; service: CGTypeDefinition);
begin
      //bool __fastcall GetBusy(void);
      service.Members.Add(new CGMethodDefinition('GetBusy',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'GetBusy', CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Boolean),
                                                  Virtuality := CGMemberVirtualityKind.Override,
                                                  CallingConvention := CGCallingConventionKind.Register,
                                                  Visibility := CGMemberVisibilityKind.Protected));
      //System::UnicodeString __fastcall GetMessageID(void);
      service.Members.Add(new CGMethodDefinition('GetMessageID',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'GetMessageID',CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                                  Virtuality := CGMemberVirtualityKind.Override,
                                                  CallingConvention := CGCallingConventionKind.Register,
                                                  Visibility := CGMemberVisibilityKind.Protected));
      //  void __fastcall SetMessageID(System::UnicodeString aMessageID);
      service.Members.Add(new CGMethodDefinition('SetMessageID',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'SetMessageID',
                                                                              ['aMessageID'.AsNamedIdentifierExpression.AsCallParameter],
                                                                              CallSiteKind := CGCallSiteKind.Static)],
                                                  Parameters := [new CGParameterDefinition('aMessageID',ResolveStdtypes(CGPredefinedTypeReference.String))].ToList,
                                                  Virtuality := CGMemberVirtualityKind.Override,
                                                  CallingConvention := CGCallingConventionKind.Register,
                                                  Visibility := CGMemberVisibilityKind.Protected));
      //  System::Syncobjs::TEvent* __fastcall GetAnswerReceivedEvent(void);
      service.Members.Add(new CGMethodDefinition('GetAnswerReceivedEvent',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'GetAnswerReceivedEvent',CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                                  ReturnType := new CGNamedTypeReference('TEvent') &namespace(new CGNamespaceReference('System::Syncobjs')) isClasstype(true),
                                                  Virtuality := CGMemberVirtualityKind.Override,
                                                  CallingConvention := CGCallingConventionKind.Register,
                                                  Visibility := CGMemberVisibilityKind.Protected));
      //bool __fastcall GetAnswerReceived(void);
      service.Members.Add(new CGMethodDefinition('GetAnswerReceived',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'GetAnswerReceived', CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Boolean),
                                                  Virtuality := CGMemberVirtualityKind.Override,
                                                  CallingConvention := CGCallingConventionKind.Register,
                                                  Visibility := CGMemberVisibilityKind.Protected));
end;

method CPlusPlusBuilderRodlCodeGen.CapitalizeString(aValue: String): String;
begin
  if String.IsNullOrEmpty(aValue) then
    exit aValue
  else
    exit aValue.Substring(0,1).ToUpperInvariant+aValue.Substring(1).ToLowerInvariant
end;

method CPlusPlusBuilderRodlCodeGen.cpp_GenerateArrayDestructor(anArray: CGTypeDefinition);
begin
  anArray.Members.Add(new CGDestructorDefinition('',
                                                 [new CGMethodCallExpression(CGSelfExpression.Self,'Clear',CallSiteKind:= CGCallSiteKind.Reference)],
                                                 Virtuality := CGMemberVirtualityKind.Virtual,
                                                 Visibility := CGMemberVisibilityKind.Public,
                                                 CallingConvention := CGCallingConventionKind.Register));
end;

method CPlusPlusBuilderRodlCodeGen.cpp_smartInit(aFile: CGCodeUnit);
begin
  aFile.ImplementationDirectives.Add(new CGCompilerDirective('#pragma package(smart_init)'));
end;

method CPlusPlusBuilderRodlCodeGen._SetLegacyStrings(value: Boolean);
begin
  if fLegacyStrings <> value then begin
    fLegacyStrings := value;
    if fLegacyStrings then begin
      CodeGenTypes.Item["ansistring"] := new CGNamedTypeReference("AnsiString") &namespace(new CGNamespaceReference("System")) isClasstype(False);
      CodeGenTypes.Item["utf8string"] := new CGNamedTypeReference("UTF8String") isClasstype(False);
    end
    else begin
      CodeGenTypes.Item["ansistring"] := new CGNamedTypeReference("String") &namespace(new CGNamespaceReference("System")) isClasstype(False);
      CodeGenTypes.Item["utf8string"] := new CGNamedTypeReference("String") &namespace(new CGNamespaceReference("System")) isClasstype(False);
    end;
  end;
end;

method CPlusPlusBuilderRodlCodeGen.cpp_DefaultNamespace:CGExpression;
begin
  exit new CGFieldAccessExpression(targetNamespace.AsNamedIdentifierExpression, 'DefaultNamespace', CallSiteKind := CGCallSiteKind.Static);
end;

method CPlusPlusBuilderRodlCodeGen.cpp_GetNamespaceForUses(aUse: RodlUse): String;
begin
  if not String.IsNullOrEmpty(aUse.Includes:DelphiModule) then
    exit aUse.Includes:DelphiModule + '_Intf' // std RODL like DA, DA_simple => delphi mode
  else if not String.IsNullOrEmpty(aUse.Namespace) then
    exit aUse.Namespace
  else
    exit aUse.Name;
end;

method CPlusPlusBuilderRodlCodeGen.cpp_GlobalCondition_ns: CGConditionalDefine;
begin
  exit new CGConditionalDefine(cpp_GlobalCondition_ns_name) inverted(true);
end;

method CPlusPlusBuilderRodlCodeGen.cpp_GlobalCondition_ns_name: String;
begin
  exit targetNamespace+'_define';
end;

method CPlusPlusBuilderRodlCodeGen.cpp_GetTROAsyncCallbackType: String;
begin
  result := '_di_'+inherited cpp_GetTROAsyncCallbackType;
end;

method CPlusPlusBuilderRodlCodeGen.cpp_GetTROAsyncCallbackMethodType: String;
begin
  result := inherited cpp_GetTROAsyncCallbackMethodType;
end;

method CPlusPlusBuilderRodlCodeGen.cpp_UuidId(anExpression: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression(nil, '__uuidof',[anExpression.AsCallParameter])
end;

method CPlusPlusBuilderRodlCodeGen.GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>;
begin
  result := new Dictionary<String,String>;
  var list := GenerateInterfaceCodeUnits(aLibrary, aTargetNamespace);
  for each f in list do begin
    if f.Initialization.Count = 0 then f.Initialization := nil;
    if f.Finalization.Count = 0 then f.Finalization := nil;
    result.Add(Path.ChangeExtension(f.FileName, Generator.defaultFileExtension),
               Generator.GenerateUnit(f));
  end;
end;

method CPlusPlusBuilderRodlCodeGen.GenerateInterfaceCodeUnits(aLibrary: RodlLibrary; aTargetNamespace: String): List<CGCodeUnit>;
begin
  result := new List<CGCodeUnit>;
  CreateCodeFirstAttributes;
  ScopedEnums := ScopedEnums or aLibrary.ScopedEnums;
  //special mode, only if aLibrary.ScopedEnums is set
  IncludeUnitNameForOwnTypes := IncludeUnitNameForOwnTypes or aLibrary.ScopedEnums;
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, aLibrary.Namespace, aLibrary.Name, 'Unknown');
  var lUnit := new CGCodeUnit();
  result.add(lUnit);
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);

  lUnit.FileName := coalesce(GetIncludesNamespace(aLibrary), aLibrary.Name, 'Unknown') + '_Intf';
  Intf_name := lUnit.FileName;

  var lunit_enums := coalesce(GetIncludesNamespace(aLibrary), aLibrary.Name, 'Unknown') + '_Enums';
  fimp_enums := GenerateCGImport(lunit_enums, '', 'h', false);

  lUnit.Initialization := new List<CGStatement>;
  lUnit.Finalization := new List<CGStatement>;
  lUnit.HeaderComment := GenerateUnitComment(False);
  Add_RemObjects_Inc(lUnit, aLibrary);
  Intf_GenerateInterfaceImports(lUnit, aLibrary);

  cpp_smartInit(lUnit);
  //Intf_GenerateImplImports(lUnit, aLibrary);

  //cpp_pragmalink(lUnit,CapitalizeString('uROProxy'));
  //cpp_pragmalink(lUnit,CapitalizeString('uROAsync'));

  var lunit_Intf_Shared := coalesce(aLibrary.Name, 'Unknown') + '_Intf_Shared';
  fimp_Intf_Shared := GenerateCGImport(lunit_Intf_Shared, '', 'h', false);
  var l_sh_unit := Intf_CreateCodeUnit(aLibrary, lunit_Intf_Shared, false);
  result.Add(l_sh_unit); AddImport(lUnit, fimp_Intf_Shared);
  AddGlobalConstants(l_sh_unit, aLibrary);
  Intf_GenerateDefaultNamespace(l_sh_unit, aLibrary);

  if aLibrary.Enums.Count > 0 then begin
    var l_unit := Intf_CreateCodeUnit(aLibrary, lunit_enums, false);
    result.Add(l_unit); AddImport(lUnit, fimp_enums);
    AddImport(l_unit, fimp_Intf_Shared);
    for aEntity: RodlEnum in aLibrary.Enums.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      Intf_GenerateEnum(l_unit, aLibrary, aEntity);
    end;
  end;

  for aEntity: RodlStruct in aLibrary.Structs.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    var l_unit := Intf_CreateCodeUnit(aLibrary, aEntity.Name, false);
    result.Add(l_unit); AddImport(lUnit, GenerateCGImport(l_unit.FileName, '', 'h', false));
    AddImport(l_unit, fimp_Intf_Shared);
    ProcessEntity(l_unit, aEntity);
    Intf_GenerateStruct(l_unit, aLibrary, aEntity);

    var l_unitCol := Intf_CreateCodeUnit(aLibrary, aEntity.Name + 'Collection', false);
    l_unitCol.Imports.Add(GenerateCGImport(l_unit.FileName,'','h', false));
    if (aEntity.AncestorEntity <> nil) and (not aEntity.AncestorEntity.IsFromUsedRodl) then
      AddImport(l_unitCol, GenerateCGImport(aEntity.AncestorName + 'Collection', '', 'h', false));
    var arr := aLibrary.Arrays.Items.Where(ar-> ar.ElementType.EqualsIgnoringCaseInvariant(aEntity.Name)).ToList;
    for each ar in arr do
      GenerateImportForEntity(l_unitCol, ar);
    result.Add(l_unitCol); AddImport(lUnit, GenerateCGImport(l_unitCol.FileName, '', 'h', false));
    Intf_GenerateStructCollection(l_unitCol, aLibrary, aEntity);
  end;

  for aEntity: RodlArray in aLibrary.Arrays.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    var l_unit := Intf_CreateCodeUnit(aLibrary, aEntity.Name, false);
    AddImport(l_unit, fimp_Intf_Shared);
    ProcessEntity(l_unit, aEntity);
    result.Add(l_unit); AddImport(lUnit, GenerateCGImport(l_unit.FileName, '', 'h', false));

    Intf_GenerateArray(l_unit, aLibrary, aEntity);
  end;

  for aEntity: RodlException in aLibrary.Exceptions.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then Continue;
    var l_unit := Intf_CreateCodeUnit(aLibrary, aEntity.Name, false);
    AddImport(l_unit, fimp_Intf_Shared);
    ProcessEntity(l_unit, aEntity);
    result.Add(l_unit); AddImport(lUnit, GenerateCGImport(l_unit.FileName, '', 'h', false));
    Intf_GenerateException(l_unit, aLibrary, aEntity);
  end;

  if aLibrary.Services.Items.Count > 0 then begin
    var ltype := new CGClassTypeDefinition('TMyTransportChannel',
                                       'TROTransportChannel'.AsTypeReference,
                                       Visibility := CGTypeVisibilityKind.Unit);
    cpp_generateDoLoginNeeded(ltype);
    l_sh_unit.Types.Add(ltype);
  end;

  for aEntity: RodlService in aLibrary.Services.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then Continue;
    var l_unit := Intf_CreateCodeUnit(aLibrary, 'I' + aEntity.Name, true);
    AddImport(l_unit, fimp_Intf_Shared);
    ProcessEntity(l_unit, aEntity);
    result.Add(l_unit); AddImport(lUnit, GenerateCGImport(l_unit.FileName, '', 'h', false));
    Intf_GenerateService(l_unit, aLibrary, aEntity);
  end;

  for aEntity: RodlEventSink in aLibrary.EventSinks.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    var l_unit := Intf_CreateCodeUnit(aLibrary, 'I' + aEntity.Name, false);
    AddImport(l_unit, fimp_Intf_Shared);
    ProcessEntity(l_unit, aEntity);
    result.Add(l_unit); AddImport(lUnit, GenerateCGImport(l_unit.FileName, '', 'h', false));
    Intf_GenerateEventSink(l_unit, aLibrary, aEntity);
  end;
end;

method CPlusPlusBuilderRodlCodeGen.ProcessEntity(aFile: CGCodeUnit; aEntity: RodlEntity);
begin
  if aEntity is RodlArray then begin
    GenerateImportForEntity(aFile, aEntity.OwnerLibrary.FindEntity(RodlArray(aEntity).ElementType));
  end
  else if aEntity is RodlStructEntity then begin
    if assigned(RodlStructEntity(aEntity).AncestorEntity) then
      GenerateImportForEntity(aFile, RodlStructEntity(aEntity).AncestorEntity);
    for each it in RodlStructEntity(aEntity).Items do
      GenerateImportForEntity(aFile, aEntity.OwnerLibrary.FindEntity(it.DataType));
  end
  else if aEntity is RodlServiceEntity then begin
    if assigned(RodlServiceEntity(aEntity).AncestorEntity) then
      GenerateImportForEntity(aFile, RodlStructEntity(aEntity).AncestorEntity);
    for each op in RodlServiceEntity(aEntity).DefaultInterface.Items do begin
      for each p in op.Items do
        GenerateImportForEntity(aFile, aEntity.OwnerLibrary.FindEntity(p.DataType));
    end;
    if aEntity is RodlService then
      AddImport(aFile, fimp_Intf_Shared);
  end;
end;

method CPlusPlusBuilderRodlCodeGen.GenerateImportForEntity(aFile: CGCodeUnit; aEntity: nullable RodlEntity);
begin
  if aEntity = nil then exit;
  var lrodlUse: RodlUse := aEntity.FromUsedRodl;
  if aEntity.IsFromUsedRodl then begin
    if lrodlUse = nil then begin // workaround
      for each t in aEntity.OwnerLibrary.Uses.Items do
        if t.EntityID = aEntity.FromUsedRodlId then begin
          lrodlUse := t;
          break;
        end;
    end;
    var s1 := lrodlUse.Includes:DelphiModule; // DA.RODL case
    if not String.IsNullOrEmpty(s1) then begin
      AddImport(aFile, GenerateCGImport(s1, '', 'hpp', false));
      exit;
    end;
  end;
  if aEntity is RodlEnum then begin
    if aEntity.IsFromUsedRodl then
      AddImport(aFile,GenerateCGImport(coalesce(lrodlUse.Name, 'Unknown') + '_Enums', '', 'h', false))
    else
      AddImport(aFile,fimp_enums);
  end
  else
    AddImport(aFile,GenerateCGImport(aEntity.Name, '', 'h', false));
end;

method CPlusPlusBuilderRodlCodeGen.AddImport(aFile: CGCodeUnit; aImport: CGImport);
begin
  for each imp in aFile.Imports do begin
    if imp.Name = aImport.Name then exit;
  end;
  aFile.Imports.Add(aImport);
end;

method CPlusPlusBuilderRodlCodeGen.GenerateInvokerCodeUnits(aLibrary: RodlLibrary; aTargetNamespace: String): List<CGCodeUnit>;
begin
  result := new List<CGCodeUnit>;
  CreateCodeFirstAttributes;
  if CodeFirstMode = State.On then exit nil;
  IncludeUnitNameForOwnTypes := true;
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, aLibrary.Namespace, aLibrary.Name, 'Unknown');
  var lUnit := new CGCodeUnit();
  result.Add(lUnit);
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  lUnit.FileName := coalesce(GetIncludesNamespace(aLibrary), aLibrary.Name, 'Unknown') + '_Invk';


  Invk_name := lUnit.FileName;
  Intf_name := Invk_name.Substring(0, Invk_name.Length - 5) + '_Intf';
  lUnit.Initialization := new List<CGStatement>;
  lUnit.Finalization := new List<CGStatement>;
  lUnit.HeaderComment := GenerateUnitComment(False);
  Add_RemObjects_Inc(lUnit, aLibrary);
  Invk_GenerateInterfaceImports(lUnit, aLibrary);

  cpp_smartInit(lUnit);
//  Invk_GenerateImplImports(lUnit, aLibrary);
//  cpp_pragmalink(lUnit,CapitalizeString('uROServer'));

  for aEntity: RodlService in aLibrary.Services.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then Continue;
    var l_unit := Invk_CreateCodeUnit(aLibrary, 'T'+ aEntity.Name +'_Invoker');
    result.Add(l_unit); AddImport(lUnit, GenerateCGImport(l_unit.FileName, '', 'h', false));
    AddImport(lUnit, GenerateCGImport(Intf_name, '', 'h', false));
    Invk_GenerateService(l_unit, aLibrary, aEntity);
  end;

  for aEntity: RodlEventSink in aLibrary.EventSinks.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then Continue;
    var l_unit := Invk_CreateCodeUnit(aLibrary, 'T'+ aEntity.Name +'_Writer');
    result.Add(l_unit); AddImport(lUnit, GenerateCGImport(l_unit.FileName, '', 'h', false));
    AddImport(lUnit, GenerateCGImport(Intf_name, '', 'h', false));
    Invk_GenerateEventSink(lUnit, aLibrary, aEntity);
  end;

  {$REGION initialization}
  if (aLibrary.Services.Count > 0) or (aLibrary.EventSinks.Count > 0) then begin
    for latr in aLibrary.CustomAttributes.Keys do begin
      var latr1 := latr.ToLowerInvariant;
      lUnit.Initialization.Add(new CGMethodCallExpression(nil, 'RegisterServiceAttribute',
                                                               [''.AsLiteralExpression.AsCallParameter,
                                                                latr.AsLiteralExpression.AsCallParameter,
                                                               (if latr1 = 'wsdl' then 'WSDLLocation'.AsNamedIdentifierExpression
                                                                else if latr1 = 'targetnamespace' then 'TargetNamespace'.AsNamedIdentifierExpression
                                                                else aLibrary.CustomAttributes[latr].AsLiteralExpression).AsCallParameter].ToList));
    end;
  end;
  {$ENDREGION}
end;

method CPlusPlusBuilderRodlCodeGen.GenerateInvokerFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>;
begin
  result := new Dictionary<String,String>;
  var list := GenerateInvokerCodeUnits(aLibrary, aTargetNamespace);
  for each f in list do begin
    if f.Initialization.Count = 0 then f.Initialization := nil;
    if f.Finalization.Count = 0 then f.Finalization := nil;
    result.Add(Path.ChangeExtension(f.FileName, Generator.defaultFileExtension),
               Generator.GenerateUnit(f));
  end;

end;

end.