namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

type
  CPlusPlusBuilderRodlCodeGen = public class(DelphiRodlCodeGen)
  protected
    method _SetLegacyStrings(value: Boolean); override;
    method Add_RemObjects_Inc(file: CGCodeUnit; library: RodlLibrary); empty;override;
    method cpp_GenerateAsyncAncestorMethodCalls(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); override;
    method cpp_GenerateAncestorMethodCalls(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition; aMode: ModeKind); override;
    method cpp_IUnknownSupport(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); override;
    method cpp_Impl_constructor(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); override;
    method cppGenerateProxyCast(aProxy: CGNewInstanceExpression; aInterface: CGNamedTypeReference):List<CGStatement>;override;
    method cpp_GenerateProxyConstructors(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); override;
    method cpp_generateInheritedBody(aMethod: CGMethodDefinition);
    method cpp_generateDoLoginNeeded(aType: CGClassTypeDefinition);override;
    method cpp_pragmalink(file: CGCodeUnit; aUnitName: String); override;
    method cpp_ClassId(anExpression: CGExpression): CGExpression; override;
    method cpp_Pointer(value: CGExpression): CGExpression;override;
    method cpp_AddressOf(value: CGExpression): CGExpression;override;
    method CapitalizeString(aValue: String):String;override;
    method cpp_GenerateArrayDestructor(anArray: CGTypeDefinition); override;
    method cpp_smartInit(file: CGCodeUnit); override;
  protected
    property CanUseNameSpace: Boolean := True; override;
    method Array_SetLength(anArray, aValue: CGExpression): CGExpression; override;
    method Array_GetLength(anArray: CGExpression): CGExpression; override;
    method RaiseError(aMessage:CGExpression; aParams:List<CGExpression>): CGExpression;override;
    method ResolveDataTypeToTypeRefFullQualified(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String := '';aCapitalize: Boolean := True): CGTypeReference; override;
    method ResolveInterfaceTypeRef(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String := ''; aCapitalize: Boolean := True): CGNamedTypeReference; override;
    method InterfaceCast(aSource, aType, aDest: CGExpression): CGExpression; override;
    method GenerateTypeInfoCall(library: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression; override;
    method cppGenerateEnumTypeInfo(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum); override;
    method GlobalsConst_GenerateServerGuid(file: CGCodeUnit; library: RodlLibrary; entity: RodlService); override;
    method AddMessageDirective(aMessage: String): CGStatement; override;
    method Impl_GenerateDFMInclude(file: CGCodeUnit);override;
    method Impl_CreateClassFactory(&library: RodlLibrary; entity: RodlService; lvar: CGExpression): List<CGStatement>;override;
    method Impl_GenerateCreateService(aMethod: CGMethodDefinition;aCreator: CGNewInstanceExpression);override;
    method AddDynamicArrayParameter(aMethod:CGMethodCallExpression; aDynamicArrayParam: CGExpression); override;
    method GenerateCGImport(aName: String; aNamespace : String := '';aExt: String := 'hpp'):CGImport; override;
    method Invk_GetDefaultServiceRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); override;
    method Invk_CheckRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); override;

  public
    constructor;
  end;

implementation

constructor CPlusPlusBuilderRodlCodeGen;
begin
  fLegacyStrings := False;
  PureDelphi := False;
  IncludeUnitNameForOwnTypes := true;
  IncludeUnitNameForOtherTypes := true;
  PredefinedTypes.Add(CGPredefinedTypeKind.String,new CGNamedTypeReference("UnicodeString") &namespace(new CGNamespaceReference("System")) isClasstype(False));

  CodeGenTypes.RemoveAll;
  CodeGenTypes.Add("integer", ResolveStdtypes(CGPredefinedTypeKind.Int32));
  CodeGenTypes.Add("datetime", new CGNamedTypeReference("TDateTime") isClasstype(False));
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeKind.Double));
  CodeGenTypes.Add("currency", new CGNamedTypeReference("Currency") isClasstype(False));
  CodeGenTypes.Add("widestring", new CGNamedTypeReference("UnicodeString") &namespace(new CGNamespaceReference("System")) isClasstype(False));
  CodeGenTypes.Add("ansistring", new CGNamedTypeReference("String") &namespace(new CGNamespaceReference("System")) isClasstype(False));
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeKind.Int64));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeKind.Boolean));
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


method CPlusPlusBuilderRodlCodeGen.cpp_GenerateAncestorMethodCalls(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition; aMode: ModeKind);
begin
  if not assigned(entity.AncestorEntity) then exit;
  if not (entity.AncestorEntity is RodlService) then exit;
  var lentity := RodlService(entity.AncestorEntity);
  case aMode of
    ModeKind.Plain: begin
      for lmem in lentity.DefaultInterface.Items do begin
        {$REGION service methods}
        var mem := new CGMethodDefinition(lmem.Name,
                                          Virtuality := CGMemberVirtualityKind.Override,
                                          Visibility := CGMemberVisibilityKind.Protected,
                                          CallingConvention := CGCallingConventionKind.Register);
        for lmemparam in lmem.Items do begin
          if lmemparam.ParamFlag <> ParamFlags.Result then begin
            var lparam := new CGParameterDefinition(lmemparam.Name,
                                                    ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType, Intf_name));
            if isComplex(library, lmemparam.DataType) and (lmemparam.ParamFlag = ParamFlags.In) then
              lparam.Type := new CGConstantTypeReference(lparam.Type)
            else
              lparam.Modifier := RODLParamFlagToCodegenFlag(lmemparam.ParamFlag);

            mem.Parameters.Add(lparam);
          end;
        end;

        if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType, Intf_name);
        cpp_generateInheritedBody(mem);
        service.Members.Add(mem);
        {$ENDREGION}
      end;
    end;
    ModeKind.Async: begin
      {$REGION Invoke_%service_method%}
      for lmem in lentity.DefaultInterface.Items do begin
          var lm := Intf_GenerateAsyncInvoke(library, lentity, lmem, false);
          lm.Virtuality := CGMemberVirtualityKind.Override;

          cpp_generateInheritedBody(lm);
          service.Members.Add(lm);
        end;
      {$ENDREGION}
      {$REGION Retrieve_%service_method%}
      for lmem in lentity.DefaultInterface.Items do
        if NeedsAsyncRetrieveOperationDefinition(lmem) then begin
          var lm := Intf_GenerateAsyncRetrieve(library, lentity, lmem, false);
          lm.Virtuality := CGMemberVirtualityKind.Override;
          cpp_generateInheritedBody(lm);
          service.Members.Add(lm);
        end;
      {$ENDREGION}
    end;
    ModeKind.AsyncEx: begin
      {$REGION Begin%service_method%}
      for lmem in lentity.DefaultInterface.Items do begin
        var lm := Intf_GenerateAsyncExBegin(library, lentity, lmem, false);
        lm.Virtuality := CGMemberVirtualityKind.Override;

        cpp_generateInheritedBody(lm);
        service.Members.Add(lm);
      end;
      {$ENDREGION}

      {$REGION End%service_method%}
      for lmem in lentity.DefaultInterface.Items do begin
        var lm := Intf_GenerateAsyncExEnd(library, lentity, lmem, false);
        lm.Virtuality := CGMemberVirtualityKind.Override;
        cpp_generateInheritedBody(lm);
        service.Members.Add(lm);
      end;
      {$ENDREGION}
    end;
  end;
  cpp_GenerateAncestorMethodCalls(library, lentity, service, aMode);
end;

method CPlusPlusBuilderRodlCodeGen.cpp_IUnknownSupport(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition);
begin

  var lm := new CGMethodDefinition('QueryInterface',
                                   [new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                               'cppQueryInterface',
                                                               ['IID'.AsNamedIdentifierExpression.AsCallParameter,
                                                                new CGTypeCastExpression('Obj'.AsNamedIdentifierExpression, CGPointerTypeReference.VoidPointer).AsCallParameter].ToList,
                                                                CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                   Parameters := [new CGParameterDefinition('IID', new CGPointerTypeReference(new CGNamedTypeReference('GUID') isClasstype(False)) reference(true),Modifier := CGParameterModifierKind.Const),
                                                  new CGParameterDefinition('Obj', new CGPointerTypeReference(new CGPointerTypeReference(new CGPredefinedTypeReference(CGPredefinedTypeKind.Void))))].ToList(),
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

method CPlusPlusBuilderRodlCodeGen.cpp_Impl_constructor(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition);
begin
  var ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public,
                                          CallingConvention := CGCallingConventionKind.Register);
  if isDFMNeeded then
    ctor.Parameters.Add(new CGParameterDefinition('aOwner', new CGNamedTypeReference('Classes::TComponent')));
  service.Members.Add(ctor);
end;

method CPlusPlusBuilderRodlCodeGen.ResolveInterfaceTypeRef(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String; aCapitalize: Boolean): CGNamedTypeReference;
begin
  var lLower := dataType.ToLowerInvariant();
  if CodeGenTypes.ContainsKey(lLower) then
    exit CGNamedTypeReference(CodeGenTypes[lLower]) // hack, only possibly type is IXMLNode
  else begin
    if assigned(library) then begin
      var namesp := ResolveNamespace(library,dataType,aDefaultUnitName,aOrigDataType);
      if String.IsNullOrEmpty(namesp) then
        exit new CGNamedTypeReference('_di_'+dataType) isClassType(false)
      else
        exit new CGNamedTypeReference('_di_'+dataType)
                                      &namespace(new CGNamespaceReference(namesp))
                                      isClassType(false);
    end
    else begin
      if String.IsNullOrEmpty(aDefaultUnitName) then
        exit new CGNamedTypeReference('_di_'+dataType) isClassType(false)
      else begin
        var lns := iif(aCapitalize and (aDefaultUnitName <> targetNamespace) ,CapitalizeString(aDefaultUnitName), aDefaultUnitName);
        exit new CGNamedTypeReference('_di_'+dataType)
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

method CPlusPlusBuilderRodlCodeGen.GenerateTypeInfoCall(library: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression;
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
    if isComplex(library, l_name) then
      exit new CGMethodCallExpression(nil,'__typeinfo',[l_name.AsNamedIdentifierExpression.AsCallParameter]);
    if isEnum(library, l_name) then begin
      var lnamespace: CGExpression := nil;
      if assigned(CGNamedTypeReference(aTypeInfo).Namespace)then lnamespace := CGNamedTypeReference(aTypeInfo).Namespace.Name.AsNamedIdentifierExpression;
      exit new CGMethodCallExpression(lnamespace, 'GetTypeInfo_'+l_name, CallSiteKind := CGCallSiteKind.Static);
    end;
    raise new Exception(String.Format('GenerateTypeInfoCall: Unsupported datatype: {0}',[l_name]));
  end;
  raise new Exception(String.Format('GenerateTypeInfoCall: Unsupported type reference: {0}',[aTypeInfo.ToString]));
end;

method CPlusPlusBuilderRodlCodeGen.cppGenerateEnumTypeInfo(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum);
begin
  var lenum_typeref := new CGNamedTypeReference(entity.Name) isclasstype(false);
  var lenum := new CGClassTypeDefinition(entity.Name+'TypeHolder','TPersistent'.AsTypeReference,
                                         Visibility := CGTypeVisibilityKind.Public);
  lenum.Members.Add(new CGFieldDefinition('fHolderField',lenum_typeref, Visibility := CGMemberVisibilityKind.Private));
  lenum.Members.Add(new CGPropertyDefinition('HolderField',lenum_typeref,
                                             Visibility := CGMemberVisibilityKind.Published,
                                             GetExpression := 'fHolderField'.AsNamedIdentifierExpression,
                                             SetExpression := 'fHolderField'.AsNamedIdentifierExpression));
  file.Types.Add(lenum);

  file.Globals.Add(new CGMethodDefinition('GetTypeInfo_'+entity.Name,
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

method CPlusPlusBuilderRodlCodeGen.GlobalsConst_GenerateServerGuid(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);
begin
  var lname := entity.Name;
  file.Globals.Add(new CGFieldDefinition(String.Format("I{0}_IID",[lname]),
                                         new CGNamedTypeReference('GUID') isClasstype(false),
                                          Constant := true,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Initializer := new CGMethodCallExpression(
                                                              'Sysutils'.AsNamedIdentifierExpression,
                                                              'StringToGUID',
                                                              [('{'+String(entity.DefaultInterface.EntityID.ToString).ToUpperInvariant+'}').AsLiteralExpression.AsCallParameter],
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
                                            [ new CGDestroyInstanceExpression(lproxy),
                                              new CGThrowStatement(new CGNewInstanceExpression('EIntfCastError'.AsNamedIdentifierExpression,
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

method CPlusPlusBuilderRodlCodeGen.cpp_GenerateProxyConstructors(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition);
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
  lmember_ct.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));
  service.Members.Add(lmember_ct);
  {$ENDREGION}

  {$REGION public class function Create(const aUrl: string; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember_ct:= new CGConstructorDefinition(Overloaded := true,
                                           Visibility := CGMemberVisibilityKind.Public,
                                           Virtuality := CGMemberVirtualityKind.Virtual,
                                           CallingConvention := CGCallingConventionKind.Register);
  lmember_ct.Parameters.Add(new CGParameterDefinition('aUrl',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));
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

method CPlusPlusBuilderRodlCodeGen.Impl_GenerateDFMInclude(file: CGCodeUnit);
begin
  file.ImplementationDirectives.Add(new CGCompilerDirective('#pragma resource "*.dfm"'));
end;

method CPlusPlusBuilderRodlCodeGen.Impl_CreateClassFactory(&library: RodlLibrary; entity: RodlService; lvar: CGExpression): List<CGStatement>;
begin
  var r := new List<CGStatement>;
  var l_EntityName := entity.Name;
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

method CPlusPlusBuilderRodlCodeGen.cpp_pragmalink(file: CGCodeUnit; aUnitName: String);
begin
  file.ImplementationDirectives.Add(new CGCompilerDirective('#pragma link "'+aUnitName+'"'));
end;

method CPlusPlusBuilderRodlCodeGen.AddDynamicArrayParameter(aMethod: CGMethodCallExpression; aDynamicArrayParam: CGExpression);
begin
  aMethod.Parameters.Add(cpp_AddressOf(new CGArrayElementAccessExpression(aDynamicArrayParam,[new CGIntegerLiteralExpression(0)])).AsCallParameter);
  aMethod.Parameters.Add(new CGFieldAccessExpression(aDynamicArrayParam,'Length', CallSiteKind := CGCallSiteKind.Instance).AsCallParameter);
end;

method CPlusPlusBuilderRodlCodeGen.ResolveDataTypeToTypeRefFullQualified(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String; aCapitalize: Boolean): CGTypeReference;
begin
  exit inherited ResolveDataTypeToTypeRefFullQualified(library, dataType, aDefaultUnitName, aOrigDataType, aCapitalize and (aDefaultUnitName <> targetNamespace));
end;

method CPlusPlusBuilderRodlCodeGen.GenerateCGImport(aName: String;aNamespace : String; aExt: String): CGImport;
begin
  var lns := aName+'.'+aExt;
  if aExt = 'hpp' then begin
    if String.IsNullOrEmpty(aNamespace) then
      exit new CGImport(CapitalizeString(lns))
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
    &method.Statements.Add(new CGVariableDeclarationStatement('llen',ResolveStdtypes(CGPredefinedTypeKind.Int), ltemp_len));
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
    &method.Statements.Add(new CGVariableDeclarationStatement('llen',ResolveStdtypes(CGPredefinedTypeKind.Int), ltemp_len));
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
                                 new CGParameterDefinition('aRetry', ResolveStdtypes(CGPredefinedTypeKind.Boolean), Modifier := CGParameterModifierKind.Var)].ToList,
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

method CPlusPlusBuilderRodlCodeGen.cpp_GenerateAsyncAncestorMethodCalls(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition);
begin
      //bool __fastcall GetBusy(void);
      service.Members.Add(new CGMethodDefinition('GetBusy',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'GetBusy', CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                                  ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Boolean),
                                                  Virtuality := CGMemberVirtualityKind.Override,
                                                  CallingConvention := CGCallingConventionKind.Register,
                                                  Visibility := CGMemberVisibilityKind.Protected));
      //System::UnicodeString __fastcall GetMessageID(void);
      service.Members.Add(new CGMethodDefinition('GetMessageID',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'GetMessageID',CallSiteKind := CGCallSiteKind.Static).AsReturnStatement],
                                                  ReturnType := ResolveStdtypes(CGPredefinedTypeKind.String),
                                                  Virtuality := CGMemberVirtualityKind.Override,
                                                  CallingConvention := CGCallingConventionKind.Register,
                                                  Visibility := CGMemberVisibilityKind.Protected));
      //  void __fastcall SetMessageID(System::UnicodeString aMessageID);
      service.Members.Add(new CGMethodDefinition('SetMessageID',
                                                  [new CGMethodCallExpression(CGInheritedExpression.Inherited, 'SetMessageID',
                                                                              ['aMessageID'.AsNamedIdentifierExpression.AsCallParameter],
                                                                              CallSiteKind := CGCallSiteKind.Static)],
                                                  Parameters := [new CGParameterDefinition('aMessageID',ResolveStdtypes(CGPredefinedTypeKind.String))].ToList,
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
                                                  ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Boolean),
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

method CPlusPlusBuilderRodlCodeGen.cpp_smartInit(file: CGCodeUnit);
begin
  file.ImplementationDirectives.Add(new CGCompilerDirective('#pragma package(smart_init)'));
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


end.
