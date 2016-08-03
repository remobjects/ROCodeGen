namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

uses
  Sugar.*,
  RemObjects.CodeGen4;

type
  ModeKind = public enum (Plain, &Async, AsyncEx);

  DelphiServerAncestor = public enum (Remotable,RemoteDataModule, Custom);

  DelphiRodlCodeGen = public class(RodlCodeGen)
  const
      DFM_template = 'object {0}: T{0}'#13#10+
                     '  OldCreateOrder = True'#13#10+
                     '  Height = 300'#13#10+
                     '  Width = 300'#13#10+
                     'end';
      DFM_template2 = 'inherited {0}: T{0}'#13#10+
                      '  OldCreateOrder = True'#13#10+
                      '  Height = 300'#13#10+
                      '  Width = 300'#13#10+
                      'end';
  private
    fIROTransportChannel_typeref: CGTypeReference;
    fIROTransport_typeref: CGTypeReference;
    fIROMessage_typeref: CGTypeReference;
    fCustomAncestor: String;
    {$REGION support methods}
    method isPresent_SerializeInitializedStructValues_Attribute(library: RodlLibrary): Boolean;
    method GetServiceAncestor(library: RodlLibrary;entity: RodlService): String;
    {$ENDREGION}    
    method ProcessAttributes(entity: RodlEntity; &type: CGClassTypeDefinition);
    method GenerateAttributes(library: RodlLibrary; service: RodlService; operation:RodlOperation; out aNames, aValues: List<CGExpression>);
    method set_CustomAncestor(value: String);
    method get_IROTransportChannel_typeref: CGTypeReference;
    method get_IROMessage_typeref: CGTypeReference;
    method get_IROTransport_typeref: CGTypeReference;
  protected
    property PureDelphi: Boolean;
    property Intf_name: String;
    property Invk_name: String;
    property Impl_name: String;
    property IROMessage_typeref: CGTypeReference read get_IROMessage_typeref;
    property IROTransportChannel_typeref: CGTypeReference read get_IROTransportChannel_typeref;
    property IROTransport_typeref: CGTypeReference read get_IROTransport_typeref;
    {$REGION support methods}
    method RODLParamFlagToCodegenFlag(aFlag: ParamFlags): CGParameterModifierKind;
    method ResolveDataTypeToTypeRefFullQualified(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String := '';aCapitalize: Boolean := False): CGTypeReference; virtual;
    method ResolveNamespace(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String := '';aCapitalize: Boolean := False): String;
    method CapitalizeString(aValue: String):String;virtual;
    method DuplicateType(aTypeRef: CGTypeReference; isClass: Boolean): CGTypeReference;
    {$ENDREGION}

    {$REGION generate _Intf}
    method Add_RemObjects_Inc(file: CGCodeUnit; library: RodlLibrary); virtual;
    method Intf_GenerateEnum(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum);
    method Intf_GenerateStruct(file: CGCodeUnit; library: RodlLibrary; entity: RodlStruct);
    method Intf_GenerateStructCollection(file: CGCodeUnit; library: RodlLibrary; entity: RodlStruct);
    method Intf_GenerateArray(file: CGCodeUnit; library: RodlLibrary; entity: RodlArray);
    method Intf_GenerateException(file: CGCodeUnit; library: RodlLibrary; entity: RodlException);
    method Intf_GenerateService(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);
    method Intf_GenerateEventSink(file: CGCodeUnit; library: RodlLibrary; entity: RodlEventSink);
    method Intf_GenerateRead(file: CGCodeUnit; library: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>;aSerializeInitializedStructValues:Boolean; aSerializer: CGExpression);
    method Intf_GenerateWrite(file: CGCodeUnit; library: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>;aSerializeInitializedStructValues:Boolean; aSerializer: CGExpression);

    
    method Intf_GenerateAsyncInvoke(library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody:  Boolean): CGMethodDefinition;
    method Intf_GenerateAsyncRetrieve(library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody:  Boolean): CGMethodDefinition;
    method Intf_GenerateAsyncExBegin(library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody:  Boolean): CGMethodDefinition;
    method Intf_GenerateAsyncExEnd(library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody:  Boolean): CGMethodDefinition;

    method Intf_generateReadStatement(library: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType: CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
    method Intf_generateWriteStatement(library: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType:CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
    {$ENDREGION}
    {$REGION generate _Invk}
    method Invk_GenerateService(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);
    method Invk_GenerateEventSink(file: CGCodeUnit; library: RodlLibrary; entity: RodlEventSink);
    method Invk_GetDefaultServiceRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); virtual;
    method Invk_CheckRoles(&method: CGMethodDefinition;roles: CGArrayLiteralExpression); virtual;
    method NeedsAsyncRetrieveOperationDefinition(entity: RodlOperation): Boolean;
    {$ENDREGION}
    {$REGION generate _Impl}
    method Impl_GenerateService(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);
    method Impl_GenerateDFMInclude(file: CGCodeUnit);virtual;
    method Impl_CreateClassFactory(&library: RodlLibrary; entity: RodlService; lvar: CGExpression): CGStatement;virtual;
    method Impl_GenerateCreateService(aMethod: CGMethodDefinition;aCreator: CGExpression);virtual;
    method cpp_Impl_constructor(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); virtual; empty;
    {$ENDREGION}
    {$REGION cpp support}
    method cpp_smartInit(file: CGCodeUnit);virtual; empty;
    method cpp_GenerateAsyncAncestorMethodCalls(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); virtual; empty;
    method cpp_GenerateAncestorMethodCalls(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition; aMode: ModeKind); virtual; empty;
    method cpp_GenerateProxyConstructors(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); virtual; empty;
    method cppGenerateEnumTypeInfo(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum);virtual;
    method cpp_IUnknownSupport(library: RodlLibrary; entity: RodlService; service: CGTypeDefinition); virtual; empty;
    
    method cppGenerateProxyCast(aProxy: CGNewInstanceExpression; aInterface: CGNamedTypeReference):List<CGStatement>;virtual;
    method cpp_generateDoLoginNeeded(aType: CGClassTypeDefinition);virtual;empty;
    method cpp_Pointer(value: CGExpression): CGExpression;virtual;
    method cpp_AddressOf(value: CGExpression): CGExpression;virtual;
    method cpp_GenerateArrayDestructor(anArray: CGTypeDefinition); virtual; empty;
    {$ENDREGION}
  protected
    method AddDynamicArrayParameter(aMethod:CGMethodCallExpression; aDynamicArrayParam: CGExpression); virtual;
    method AddMessageDirective(aMessage: String): CGStatement; virtual;
    property CanUseNameSpace: Boolean := False; virtual;
    method GenerateTypeInfoCall(library: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression; virtual;
    method Array_SetLength(anArray, aValue: CGExpression): CGExpression; virtual;
    method Array_GetLength(anArray: CGExpression): CGExpression; virtual;
    method RaiseError(aMessage:CGExpression; aParams:List<CGExpression>): CGExpression;virtual;
    method AddGlobalConstants(file: CGCodeUnit; library: RodlLibrary); override;
    method GlobalsConst_GenerateServerGuid(file: CGCodeUnit; library: RodlLibrary; entity: RodlService); virtual;
    method isComplex(library: RodlLibrary; dataType: String): Boolean; override;
    method GetNamespace(library: RodlLibrary): String;override;
    method GetGlobalName(library: RodlLibrary): String; override; empty;
    
    method ResolveInterfaceTypeRef(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String := ''; aCapitalize: Boolean := False): CGNamedTypeReference; virtual;
    /// returns boolean type
    method InterfaceCast(aSource, aType, aDest: CGExpression): CGExpression; virtual;
    
    method cpp_pragmalink(file: CGCodeUnit; aUnitName: String); virtual; empty;
    method cpp_ClassId(anExpression: CGExpression): CGExpression; virtual; 
    method GenerateCGImport(aName: String; aNamespace : String := '';aExt: String := 'hpp'): CGImport;virtual;
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
    // include {$SCOPEDENUMS ON} into _Intf
    property ScopedEnums: Boolean := false;
    method isDFMNeeded: Boolean;
    
    property GenerateDFMs: Boolean := true;

    method GenerateInterfaceCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
    method GenerateInvokerCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
    method GenerateImplementationCodeUnit(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit; override;
    method GenerateImplementationFiles(file: CGCodeUnit; library: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;override;

    method GenerateInvokerFile(library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String; override;
    method GenerateImplementationFiles(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>; override;    

  end;

implementation

constructor DelphiRodlCodeGen;
begin
  PureDelphi := True;
  CodeGenTypes.Add("integer", ResolveStdtypes(CGPredefinedTypeKind.Int32));
  CodeGenTypes.Add("datetime", String("DateTime").AsTypeReference);
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeKind.Double));
  CodeGenTypes.Add("currency", String("Currency").AsTypeReference);
  CodeGenTypes.Add("widestring", String("UnicodeString").AsTypeReference);
  CodeGenTypes.Add("ansistring", String("AnsiString").AsTypeReference);
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeKind.Int64));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeKind.Boolean));
  CodeGenTypes.Add("variant", String("Variant").AsTypeReference);
  CodeGenTypes.Add("binary", String("Binary").AsTypeReference);
  CodeGenTypes.Add("xml", String("IXmlNode").AsTypeReference);
  CodeGenTypes.Add("guid", String("Guid").AsTypeReference);
  CodeGenTypes.Add("decimal", String("Decimal").AsTypeReference);
  CodeGenTypes.Add("utf8string", String("UTF8String").AsTypeReference);
  CodeGenTypes.Add("xsdatetime", String("XsDateTime").AsTypeReference);

  // Delphi Seattle + FPC reserved list
  // http://docwiki.embarcadero.com/RADStudio/Seattle/en/Fundamental_Syntactic_Elements#Reserved_Words
  // http://www.freepascal.org/docs-html/ref/refse3.html
  ReservedWords.AddRange(["absolute", "abstract", "alias", "and", "array", "as", "asm", "assembler", "at", "automated", "begin", 
  "bitpacked", "break", "case", "cdecl", "class", "const", "constructor", "continue", "cppdecl", "cvar", "default", 
  "deprecated", "destructor", "dispinterface", "dispose", "div", "do", "downto", "dynamic", "else", "end", "enumerator",
  "except", "exit", "experimental", "export", "exports", "external", "false", "far", "far16", "file", "finalization", 
  "finally", "for", "forward", "function", "generic", "goto", "helper", "if", "implementation", "implements", "in", 
  "index", "inherited", "initialization", "inline", "interface", "interrupt", "iochecks", "is", "label", "library", 
  "local", "message", "mod", "name", "near", "new", "nil", "nodefault", "noreturn", "nostackframe", "not", "object", 
  "of", "oldfpccall", "on", "operator", "or", "otherwise", "out", "overload", "override", "packed", "pascal", "platform", 
  "private", "procedure", "program", "property", "protected", "public", "published", "raise", "read", "record", "register", 
  "reintroduce", "repeat", "resourcestring", "result", "safecall", "saveregisters", "self", "set", "shl", "shr", "softfloat", 
  "specialize", "static", "stdcall", "stored", "strict", "string", "then", "threadvar", "to", "true", "try", "type", "unaligned", 
  "unimplemented", "unit", "until", "uses", "var", "varargs", "virtual", "while", "with", "write", "xor"]); 
end;

method DelphiRodlCodeGen.Add_RemObjects_Inc(file: CGCodeUnit; library: RodlLibrary);
begin
  file.Directives.Add('{$I RemObjects.inc}'.AsCompilerDirective);
end;

method DelphiRodlCodeGen.Intf_GenerateEnum(file: CGCodeUnit; &library: RodlLibrary; entity: RodlEnum);
begin
  var lenum := new CGEnumTypeDefinition(entity.Name,
                            Visibility := CGTypeVisibilityKind.Public
                            );
 file.Types.Add(lenum);
 lenum.Comment := GenerateDocumentation(entity);
 for enummember: RodlEnumValue in entity.Items do begin
   var lenummember := new CGEnumValueDefinition(iif(entity.PrefixEnumValues,lenum.Name+'_','') + enummember.Name); 
   lenummember.Comment :=  GenerateDocumentation(enummember);
   lenum.Members.Add(lenummember);
 end;


 cppGenerateEnumTypeInfo(file, library,entity);
  {$REGION initialization/finalization}
  var param2 := GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,entity.Name,Intf_name));
  file.Initialization:Add(new CGMethodCallExpression(nil, 'RegisterROEnum',
                                                    [entity.Name.AsLiteralExpression.AsCallParameter,
                                                     param2.AsCallParameter, 
                                                     'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  for enumvalue: RodlEnumValue in entity.Items do begin
    file.Initialization:Add(new CGMethodCallExpression(nil,'RegisterEnumMapping',
                                                 [entity.Name.AsLiteralExpression.AsCallParameter,
                                                  enumvalue.Name.AsLiteralExpression.AsCallParameter,
                                                  enumvalue.OriginalName.AsLiteralExpression.AsCallParameter, 
                                                  'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  end;
  file.Finalization:Add(new CGMethodCallExpression(nil, 'UnRegisterEnumMappings',
                                                   [entity.Name.AsLiteralExpression.AsCallParameter, 
                                                    'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  file.Finalization:Add(new CGMethodCallExpression(nil, 'UnregisterROEnum',
                                                    [entity.Name.AsLiteralExpression.AsCallParameter, 
                                                     'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateStruct(file: CGCodeUnit; &library: RodlLibrary; entity: RodlStruct);
begin
  var lAncestorName := entity.AncestorName;
  var l_EntityName := entity.Name;
  var l_FullEntityTypeRef := ResolveDataTypeToTypeRefFullQualified(library,l_EntityName,Intf_name);
  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := "TROComplexType";

  var ltype := new CGClassTypeDefinition(l_EntityName,
                                         ResolveDataTypeToTypeRefFullQualified(library, lAncestorName,Intf_name),
                                         Visibility := CGTypeVisibilityKind.Public
                                         );
  file.Types.Add(ltype);
  ltype.Comment := GenerateDocumentation(entity);
  var lclasscnt:= 0;
  var lNeedInitSimpleTypeWithDefaultValues := False;

  {$REGION private f%fldname%: %fldtype%}
  for lentityItem :RodlTypedEntity in entity.Items do begin
    ltype.Members.Add(
                        new CGFieldDefinition("f"+lentityItem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(&library,lentityItem.DataType,Intf_name),
                                              Visibility := CGMemberVisibilityKind.Private
                                              ));
  end;
  {$ENDREGION}

  {$REGION private Get%fldname%: %fldtype%}
  for lentityItem :RodlTypedEntity in entity.Items do begin
    var lentityname:= lentityItem.Name;
    var fentityname := new CGFieldAccessExpression(nil, 'f'+lentityname);
    if isComplex(library,lentityItem.DataType) then begin
      inc(lclasscnt);
      var lm := new CGMethodDefinition('Get'+lentityname,
                                       ReturnType := ResolveDataTypeToTypeRefFullQualified(&library,lentityItem.DataType,Intf_name),
                                       Visibility := CGMemberVisibilityKind.Private,
                                       CallingConvention := CGCallingConventionKind.Register);
      ltype.Members.Add(lm);
      if entity.AutoCreateProperties then begin
        var ifs_true: CGStatement;
        if isException(library, lentityItem.DataType) then
          ifs_true := new CGAssignmentStatement(
                                                fentityname,
                                                new CGMethodCallExpression(lentityItem.DataType.AsNamedIdentifierExpression,'CreateFmt',
                                                                          [''.AsLiteralExpression.AsCallParameter, new CGArrayLiteralExpression().AsCallParameter].ToList,
                                                                          CallSiteKind:= CGCallSiteKind.Reference))
        else
          ifs_true := new CGAssignmentStatement(
                                                fentityname,
                                                new CGNewInstanceExpression(lentityItem.DataType.AsTypeReference));
        lm.Statements.Add(new CGIfThenElseStatement(new CGUnaryOperatorExpression(new CGAssignedExpression(fentityname),CGUnaryOperatorKind.Not),ifs_true));
      end;
      lm.Statements.Add(fentityname.AsReturnStatement);
    end
    else begin
      lNeedInitSimpleTypeWithDefaultValues := lNeedInitSimpleTypeWithDefaultValues or lentityItem.CustomAttributes_lower.ContainsKey('default');
    end;
  end;
  {$ENDREGION}

  var lSerializeInitializedStructValues := isPresent_SerializeInitializedStructValues_Attribute(library);
  {$REGION protected int%fldname%: %fldtype% read f%fldname%;}
  if not lSerializeInitializedStructValues then begin
    if lclasscnt >0 then begin
      for lentityItem :RodlTypedEntity in entity.Items do begin
        if isComplex(library,lentityItem.DataType) then begin
          ltype.Members.Add(new CGPropertyDefinition(
                                              'int_'+lentityItem.Name,
                                               ResolveDataTypeToTypeRefFullQualified(&library,lentityItem.DataType,Intf_name),
                                               ('f'+lentityItem.Name).AsNamedIdentifierExpression,
                                              Visibility := CGMemberVisibilityKind.Protected));
        end;
      end;
    end;
  end;
  {$ENDREGION}

  if (lclasscnt > 0) or (String.IsNullOrEmpty(entity.AncestorName)) then begin
    {$REGION protected procedure FreeInternalProperties; override;}
      var lm := new CGMethodDefinition('FreeInternalProperties',
                                       Visibility := CGMemberVisibilityKind.Protected,
                                       Virtuality := CGMemberVirtualityKind.Override,
                                       CallingConvention := CGCallingConventionKind.Register);
      if (not String.IsNullOrEmpty(entity.AncestorName)) then 
        lm.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited,'FreeInternalProperties'));
      for lentityItem :RodlTypedEntity in entity.Items do begin
        if isComplex(library,lentityItem.DataType) then
          lm.Statements.Add(new CGDestroyInstanceExpression(('f'+lentityItem.Name).AsNamedIdentifierExpression));
      end;
      ltype.Members.Add(lm);
    {$ENDREGION}
  end;

  {$REGION public constructor Create(aCollection : TCollection); override;}
  if lNeedInitSimpleTypeWithDefaultValues then begin
    var lm := new CGConstructorDefinition(
                            Parameters:=[new CGParameterDefinition('aCollection','TCollection'.AsTypeReference)].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, ['aCollection'.AsNamedIdentifierExpression.AsCallParameter].ToList));
    for lentityItem :RodlTypedEntity in entity.Items do begin
      if not isComplex(library,lentityItem.DataType) and lentityItem.CustomAttributes_lower.ContainsKey('default') then begin
        var lDefaultValue: CGExpression;
        case lentityItem.DataType.ToLowerInvariant of
          "widestring",
          "guid",
          "variant",
          "utf8string",
          "ansistring",
          "string": lDefaultValue := lentityItem.CustomAttributes_lower['default'].AsLiteralExpression;
          "integer",
          "int64",
          "double",
          "boolean",
          "currency",
          "decimal": lDefaultValue := lentityItem.CustomAttributes_lower['default'].AsNamedIdentifierExpression;
          "datetime": lDefaultValue := new CGMethodCallExpression(nil,
                                                                  "StrToDateTimeDef",
                                                                  [lentityItem.CustomAttributes_lower['default'].AsLiteralExpression.AsCallParameter,
                                                                   new CGIntegerLiteralExpression(0).AsCallParameter].ToList,
                                                                   CallSiteKind:= CGCallSiteKind.Static);
        end;
        if lDefaultValue <> nil then
          lm.Statements.Add(new CGAssignmentStatement(('f'+lentityItem.Name).AsNamedIdentifierExpression,lDefaultValue));
      end;
    end;
  end;
  {$ENDREGION}

  ProcessAttributes(entity, ltype);

  if entity.Count > 0 then begin
    {$REGION public procedure Assign(aSource: TPersistent); override;}
    var lm := new CGMethodDefinition('Assign',
                            Parameters:=[new CGParameterDefinition('aSource','TPersistent'.AsTypeReference)].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement("lSource",l_FullEntityTypeRef));

    var aSourceExpr := 'aSource'.AsNamedIdentifierExpression;
    lm.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited,'Assign', [aSourceExpr.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Static));
    var lct := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(GenerateIsClause(aSourceExpr, l_FullEntityTypeRef),
                                                lct));
    var lSourceExpr := 'lSource'.AsNamedIdentifierExpression;
    lct.Statements.Add(new CGAssignmentStatement(lSourceExpr,
                                                 new CGTypeCastExpression(aSourceExpr, l_FullEntityTypeRef)));
    lct.Statements.Add(new CGEmptyStatement);
    for lentityItem :RodlTypedEntity in entity.Items do begin
      var entityname := lentityItem.Name;
      var fentityname := 'f'+lentityItem.Name;
      if isComplex(library,lentityItem.DataType) then begin
        var ltemp := lct;
        var lSourcefentitynameExpr := new CGFieldAccessExpression(lSourceExpr,fentityname,CallSiteKind:= CGCallSiteKind.Reference);
        if not entity.AutoCreateProperties then begin
          ltemp := new CGBeginEndBlockStatement();
          lct.Statements.Add(new CGIfThenElseStatement(new CGAssignedExpression(fentityname.AsNamedIdentifierExpression),ltemp));
        end;
        ltemp.Statements.Add(new CGIfThenElseStatement(new CGAssignedExpression(lSourcefentitynameExpr),
                                                       new CGMethodCallExpression(new CGFieldAccessExpression(CGSelfExpression.Self,entityname, CallSiteKind := CGCallSiteKind.Reference),'Assign',[lSourcefentitynameExpr.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference),
                                                       new CGBeginEndBlockStatement(
                                                            [new CGDestroyInstanceExpression(fentityname.AsNamedIdentifierExpression),
                                                            new CGAssignmentStatement(fentityname.AsNamedIdentifierExpression,CGNilExpression.Nil)]
                                                       )));

      end
      else begin
        lNeedInitSimpleTypeWithDefaultValues := lNeedInitSimpleTypeWithDefaultValues or (lentityItem.CustomAttributes_lower.ContainsKey('default'));
        lct.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(CGSelfExpression.Self, entityname, CallSiteKind:= CGCallSiteKind.Reference),
                                                     new CGFieldAccessExpression(lSourceExpr, entityname, CallSiteKind := CGCallSiteKind.Reference)));
      end;
    end;
    {$ENDREGION}

    var litemList := entity.GetAllItems;
    var litemList_Sorted := litemList.Sort_OrdinalIgnoreCase(b->b.Name);
    var TROSerializer_typeref := 'TROSerializer'.AsTypeReference;
    var lSerializer_cast := new CGTypeCastExpression('aSerializer'.AsNamedIdentifierExpression,TROSerializer_typeref);
    var lSerializer := '__Serializer'.AsNamedIdentifierExpression;
    {$REGION public procedure ReadComplex(aSerializer: TObject); override;}
    lm := new CGMethodDefinition('ReadComplex',
                                  Parameters:=[new CGParameterDefinition('aSerializer','TObject'.AsTypeReference)].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement('__Serializer',TROSerializer_typeref, lSerializer_cast));
    
    for lmem in litemList_Sorted do
      lm.LocalVariables:Add(new CGVariableDeclarationStatement('l_'+lmem.Name,ResolveDataTypeToTypeRefFullQualified(library,lmem.DataType,Intf_name)));    
    var lSorted := new CGBeginEndBlockStatement;
    var lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGFieldAccessExpression(lSerializer,'RecordStrictOrder',CallSiteKind:= CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if entity.Count <> litemList.Count then
        lStrict.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, 'ReadComplex',['aSerializer'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Static));
    Intf_GenerateRead(file,library,entity.Items,lStrict.Statements, lSerializeInitializedStructValues,lSerializer);
    Intf_GenerateRead(file,library,litemList_Sorted,lSorted.Statements, lSerializeInitializedStructValues,lSerializer);
    {$ENDREGION}

    {$REGION public procedure WriteComplex(aSerializer: TObject); override;}
    lm := new CGMethodDefinition('WriteComplex',
                                  Parameters:=[new CGParameterDefinition('aSerializer','TObject'.AsTypeReference)].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement('__Serializer',TROSerializer_typeref, lSerializer_cast));
    for lmem in litemList_Sorted do
      lm.LocalVariables:Add(new CGVariableDeclarationStatement('l_'+lmem.Name,ResolveDataTypeToTypeRefFullQualified(library,lmem.DataType,Intf_name)));
    lSorted := new CGBeginEndBlockStatement;
    lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGFieldAccessExpression(lSerializer,'RecordStrictOrder',CallSiteKind:= CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if entity.Count <> litemList.Count then lStrict.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, 'WriteComplex',['aSerializer'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Static));
    lStrict.Statements.Add(new CGMethodCallExpression(lSerializer,'ChangeClass',[cpp_ClassId(l_EntityName.AsNamedIdentifierExpression).AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    Intf_GenerateWrite(file,library,entity.Items,lStrict.Statements, lSerializeInitializedStructValues,lSerializer);
    Intf_GenerateWrite(file,library,litemList_Sorted,lSorted.Statements, lSerializeInitializedStructValues,lSerializer);
    {$ENDREGION}
  end;

  {$REGION published property %fldname%: %fldtype% read [f|Get]%fldname% write f%fldname%;}
  for l_entityItem :RodlTypedEntity in entity.Items do begin
    var lp := iif(isComplex(library,l_entityItem.DataType), 'Get','f');
    var lprop := new CGPropertyDefinition(l_entityItem.Name,
                                          ResolveDataTypeToTypeRefFullQualified(&library,l_entityItem.DataType,Intf_name),
                                          (lp+l_entityItem.Name).AsNamedIdentifierExpression,
                                          ('f'+l_entityItem.Name).AsNamedIdentifierExpression,
                                          Visibility := CGMemberVisibilityKind.Published);
    lprop.Comment := GenerateDocumentation(l_entityItem);
    ltype.Members.Add(lprop);
  end;
  {$ENDREGION}

  {$REGION initialization/finalization}
  file.Initialization:Add(new CGMethodCallExpression(nil, 'RegisterROClass',  [cpp_ClassId(l_EntityName.AsNamedIdentifierExpression).AsCallParameter, 'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  file.Finalization:Add(new CGMethodCallExpression(nil, 'UnregisterROClass', [cpp_ClassId(l_EntityName.AsNamedIdentifierExpression).AsCallParameter, 'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateArray(file: CGCodeUnit; &library: RodlLibrary; entity: RodlArray);
begin
  var l_Result: CGExpression := new CGLocalVariableAccessExpression('lResult');

  var lm: CGMethodLikeMemberDefinition;
  var lElementType := entity.ElementType;
  var el_typeref := ResolveDataTypeToTypeRefFullQualified(library, lElementType, Intf_name);
  if not isComplex(library, lElementType) then
    if el_typeref is CGNamedTypeReference then
      lElementType := CGNamedTypeReference(el_typeref).Name;

  var larrayname := entity.Name;
  var array_typeref := ResolveDataTypeToTypeRefFullQualified(library, larrayname, Intf_name);
  var lEnumerator := larrayname +'Enumerator';

  var linternalarr := new CGTypeAliasDefinition(larrayname+"_"+lElementType, new CGArrayTypeReference(el_typeref));
  var linternalarr_typeref := DuplicateType(ResolveDataTypeToTypeRefFullQualified(library, linternalarr.Name, Intf_name,larrayname), false);


  file.Types.Add(linternalarr);

  var ltype := new CGClassTypeDefinition(larrayname,'TROArray'.AsTypeReference,
                              Visibility := CGTypeVisibilityKind.Public
                              );
  ltype.Comment := GenerateDocumentation(entity);
  file.Types.Add(ltype);

  var aIndex: CGExpression := 'aIndex'.AsNamedIdentifierExpression;             //aIndex
  var fCount: CGExpression := 'fCount'.AsNamedIdentifierExpression;             //fCount
  var fCount_subtract_1    := new CGBinaryOperatorExpression(fCount,            //fCount-1
                                                              new CGIntegerLiteralExpression(1),
                                                              CGBinaryOperatorKind.Subtraction);
  var fCount_add_1    := new CGBinaryOperatorExpression(fCount,                 //fCount+1
                                                        new CGIntegerLiteralExpression(1),
                                                        CGBinaryOperatorKind.Addition);

  var fItems:='fItems'.AsNamedIdentifierExpression;                             //fItems
  var Self_Items := new CGFieldAccessExpression(CGSelfExpression.Self, 'Items',CallSiteKind:= CGCallSiteKind.Reference);        //Self.Items
  var fItems_i:=new CGArrayElementAccessExpression(fItems,[CGExpression('i'.AsNamedIdentifierExpression)].ToList);  //fItems[i]
  var Self_Items_i:=new CGArrayElementAccessExpression(Self_Items,[CGExpression('i'.AsNamedIdentifierExpression)].ToList);    //Self.Items[i]
  var fItems_aIndex:=new CGArrayElementAccessExpression(fItems,[aIndex].ToList);  //fItems[aIndex]
  var fItems_Result:=new CGArrayElementAccessExpression(fItems,[l_Result].ToList);  //fItems[Result]
  //  if (aIndex < 0) or (aIndex >= Self.Count) then uROClasses.RaiseError(err_ArrayIndexOutOfBounds,[aIndex]);
  var err_ArrayIndexOutOfBounds := new CGIfThenElseStatement(new CGBinaryOperatorExpression(
                                                                                            new CGBinaryOperatorExpression(aIndex,new CGIntegerLiteralExpression(0),CGBinaryOperatorKind.LessThan),
                                                                                            new CGBinaryOperatorExpression(aIndex,fCount, CGBinaryOperatorKind.GreatThanOrEqual),
                                                                                            CGBinaryOperatorKind.LogicalOr),
                                                            RaiseError('err_ArrayIndexOutOfBounds'.AsNamedIdentifierExpression,[aIndex].ToList)
//                                                             new CGMethodCallExpression(nil, 'uROClasses.RaiseError',['err_ArrayIndexOutOfBounds'.AsNamedIdentifierExpression.AsCallParameter,
//                                                                                                                      new CGArrayLiteralExpression([aIndex].ToList).AsCallParameter].ToList)
                                                             );


  {$REGION private fCount: Integer}
  ltype.Members.Add(new CGFieldDefinition("fCount",
                                          ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                          Visibility := CGMemberVisibilityKind.Private
                                          ));
  {$ENDREGION}

  {$REGION private fItems: %arrayname%_%elementtype%}
  ltype.Members.Add(new CGFieldDefinition("fItems",
                                          linternalarr_typeref,
                                          Visibility := CGMemberVisibilityKind.Private
                                          ));
  {$ENDREGION}

  {$REGION protected procedure Grow; virtual}
  lm := new CGMethodDefinition('Grow',
                            Virtuality := CGMemberVirtualityKind.Virtual,
                            Visibility := CGMemberVisibilityKind.Protected,
                            CallingConvention := CGCallingConventionKind.Register
                      );
  ltype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:Add(new CGVariableDeclarationStatement("lDelta",ResolveStdtypes(CGPredefinedTypeKind.Int32)));
  lm.LocalVariables:Add(new CGVariableDeclarationStatement("lCapacity",ResolveStdtypes(CGPredefinedTypeKind.Int32)));
  var lDelta := "lDelta".AsNamedIdentifierExpression;
  var lCapacity := "lCapacity".AsNamedIdentifierExpression;
  lm.Statements.Add(new CGAssignmentStatement(lCapacity, Array_GetLength(fItems)));
  //lm.Statements.Add(new CGAssignmentStatement(lCapacity, new CGMethodCallExpression(nil,"System.Length",[fItems.AsCallParameter].ToList)));
  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(lCapacity,new CGIntegerLiteralExpression(64), CGBinaryOperatorKind.GreaterThan),
                                              new CGAssignmentStatement(lDelta,new CGBinaryOperatorExpression(lCapacity, new CGIntegerLiteralExpression(4),CGBinaryOperatorKind.LegacyPascalDivision)),
                                              new CGIfThenElseStatement(new CGBinaryOperatorExpression(lCapacity,new CGIntegerLiteralExpression(8), CGBinaryOperatorKind.GreaterThan),
                                                                        new CGAssignmentStatement(lDelta,new CGIntegerLiteralExpression(16)),
                                                                        new CGAssignmentStatement(lDelta,new CGIntegerLiteralExpression(4)))
                                              ));

  lm.Statements.Add(Array_SetLength(fItems, new CGBinaryOperatorExpression(lCapacity,lDelta,CGBinaryOperatorKind.Addition)));
  //lm.Statements.Add(new CGMethodCallExpression(nil,'System.SetLength',[fItems.AsCallParameter, new CGBinaryOperatorExpression(lCapacity,lDelta,CGBinaryOperatorKind.Addition).AsCallParameter].ToList));
  {$ENDREGION}

  {$REGION protected function GetItems(aIndex: Integer): %elementtype%}
  lm := new CGMethodDefinition('GetItems',
                          Parameters := [new CGParameterDefinition('aIndex',ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          ReturnType := el_typeref,
                          CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.Statements.Add(err_ArrayIndexOutOfBounds);
  lm.Statements.Add(fItems_aIndex.AsReturnStatement);
  {$ENDREGION}

  {$REGION protected procedure SetItems(aIndex: Integer; const Value: %structtype%);}
  lm := new CGMethodDefinition('SetItems',
                          Parameters := [new CGParameterDefinition('aIndex',ResolveStdtypes(CGPredefinedTypeKind.Int32)),
                                         new CGParameterDefinition('Value',el_typeref {,Modifier := CGParameterModifierKind.Const})].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          CallingConvention := CGCallingConventionKind.Register
                          );
  ltype.Members.Add(lm);
  lm.Statements.Add(err_ArrayIndexOutOfBounds);
  if isComplex(library,lElementType) then begin
    lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(fItems_aIndex, 'Value'.AsNamedIdentifierExpression, CGBinaryOperatorKind.NotEquals),
                                                new CGBeginEndBlockStatement([new CGDestroyInstanceExpression(fItems_aIndex),
                                                                              new CGAssignmentStatement(fItems_aIndex, 'Value'.AsNamedIdentifierExpression)].ToList)));
  end
  else begin
    lm.Statements.Add(new CGAssignmentStatement(fItems_aIndex, 'Value'.AsNamedIdentifierExpression));
  end;
  {$ENDREGION}

  {$REGION protected function GetCount: Integer; override}
  lm := new CGMethodDefinition(
                    'GetCount',
                    [fCount.AsReturnStatement],
                    ReturnType := ResolveStdtypes((CGPredefinedTypeKind.Int32)),
                    Virtuality := CGMemberVirtualityKind.Override,
                    Visibility := CGMemberVisibilityKind.Protected,
                    CallingConvention := CGCallingConventionKind.Register
);
  ltype.Members.Add(lm);
  {$ENDREGION}

  ProcessAttributes(entity,ltype);

  {$REGION public class function GetItemType: PTypeInfo; override;}
  lm := new CGMethodDefinition('GetItemType',
                               [GenerateTypeInfoCall(library,el_typeref).AsReturnStatement],
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                ReturnType :=  new CGNamedTypeReference('PTypeInfo') isClassType(False),
                                &Static := true,
                                CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  {$ENDREGION}

  if isComplex(library,lElementType) then begin
    {$REGION public class function GetItemClass: System.TClass; override;}
    lm := new CGMethodDefinition('GetItemClass',
                                 [cpp_ClassId(DuplicateType(el_typeref, false).AsExpression).AsReturnStatement],
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  ReturnType := new CGNamedTypeReference('TClass') &namespace(new CGNamespaceReference('System')) isclasstype(false),
                                  &Static := true,
                                  CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(lm);
    {$ENDREGION}
  end;

  {$REGION public class function GetItemSize: Integer; override;}
  lm := new CGMethodDefinition('GetItemSize',
                              [new CGSizeOfExpression(el_typeref.AsExpression).AsReturnStatement],
                                ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                &Static := true,
                                CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  {$ENDREGION}

  {$REGION public function GetItemRef(aIndex: Integer): pointer; override;}
  lm := new CGMethodDefinition('GetItemRef',
                                Parameters := [new CGParameterDefinition('aIndex',ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                ReturnType := CGPointerTypeReference.VoidPointer,
                                CallingConvention := CGCallingConventionKind.Register
                                );
  ltype.Members.Add(lm);
  lm.Statements.Add(err_ArrayIndexOutOfBounds);
  if isComplex(library, lElementType) then
    lm.Statements.Add(fItems_aIndex.AsReturnStatement)
  else
    lm.Statements.Add(new CGUnaryOperatorExpression(fItems_aIndex, CGUnaryOperatorKind.AddressOf).AsReturnStatement);
  {$ENDREGION}

  if isComplex(library,lElementType) then begin
    {$REGION procedure SetItemRef(aIndex: Integer; Ref: pointer); override;}
    lm := new CGMethodDefinition('SetItemRef',
                                  Parameters := [new CGParameterDefinition('aIndex',ResolveStdtypes(CGPredefinedTypeKind.Int32)),
                                                 new CGParameterDefinition('Ref',CGPointerTypeReference.VoidPointer)].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(lm);

    lm.Statements.Add(err_ArrayIndexOutOfBounds);
    lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression('Ref'.AsNamedIdentifierExpression,  fItems_aIndex, CGBinaryOperatorKind.NotEquals),
                                                new CGBeginEndBlockStatement([
                                                                            new CGIfThenElseStatement(new CGAssignedExpression(fItems_aIndex),
                                                                                                      new CGDestroyInstanceExpression(fItems_aIndex)),
                                                                            new CGAssignmentStatement(fItems_aIndex, 
                                                                                                      new CGTypeCastExpression('Ref'.AsNamedIdentifierExpression, el_typeref))].ToList)));
    {$ENDREGION}
  end;

  {$REGION public procedure Clear; override;}
  lm := new CGMethodDefinition('Clear',
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  if isComplex(library, lElementType) then begin
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement("i",ResolveStdtypes(CGPredefinedTypeKind.Int32)));
    lm.Statements.Add(new CGForToLoopStatement('i',
                                              ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                              new CGIntegerLiteralExpression(0),
                                              fCount_subtract_1,
                                              new CGDestroyInstanceExpression(fItems_i)
                                              ));

  end;
  lm.Statements.Add(Array_SetLength(fItems, new CGIntegerLiteralExpression(0)));
  //lm.Statements.Add(new CGMethodCallExpression(nil,'System.SetLength',[fItems.AsCallParameter, new CGIntegerLiteralExpression(0).AsCallParameter].ToList));
  lm.Statements.Add(new CGAssignmentStatement(fCount,new CGIntegerLiteralExpression(0)));
  {$ENDREGION}

  {$REGION public procedure Delete(aIndex: Integer); override;}
  lm := new CGMethodDefinition('Delete',
                                Parameters := [new CGParameterDefinition('aIndex',ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                                Virtuality := CGMemberVirtualityKind.Override,
                                Visibility := CGMemberVisibilityKind.Public,
                                CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);

  var fItems_i_add_1:=new CGArrayElementAccessExpression(fItems,                                                    //fItems[i+1]
                                                        [CGExpression(new CGBinaryOperatorExpression(
                                                                                                    'i'.AsNamedIdentifierExpression,
                                                                                                    new CGIntegerLiteralExpression(1),
                                                                                                    CGBinaryOperatorKind.Addition))
                                                                                                    ].ToList);
  var lSelfCount_subtract_2 := new CGBinaryOperatorExpression(fCount,                                           //Self.Count-2
                                                              new CGIntegerLiteralExpression(2),
                                                              CGBinaryOperatorKind.Subtraction);


  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:Add(new CGVariableDeclarationStatement("i",ResolveStdtypes(CGPredefinedTypeKind.Int32)));
  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(aIndex,fCount,CGBinaryOperatorKind.GreatThanOrEqual),
                                              RaiseError('err_InvalidIndex'.AsNamedIdentifierExpression, [aIndex].ToList)
//                                              new CGMethodCallExpression(nil, 'uROClasses.RaiseError',['err_InvalidIndex'.AsNamedIdentifierExpression.AsCallParameter,
//                                                                                                       new CGArrayLiteralExpression([aIndex].ToList).AsCallParameter].ToList)
  ));
  lm.Statements.Add(new CGEmptyStatement);
  if isComplex(library, lElementType) then begin
    lm.Statements.Add(new CGDestroyInstanceExpression(new CGArrayElementAccessExpression(fItems,[aIndex].ToList)));
    lm.Statements.Add(new CGEmptyStatement);
  end;



  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(aIndex,
                                                                             fCount_subtract_1,
                                                                             CGBinaryOperatorKind.LessThan),
                                              new CGForToLoopStatement('i',
                                                                      ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                                                      aIndex,
                                                                      lSelfCount_subtract_2,
                                                                      new CGAssignmentStatement(fItems_i,fItems_i_add_1))));
  lm.Statements.Add(Array_SetLength(fItems, fCount_subtract_1));
  //lm.Statements.Add(new CGMethodCallExpression(nil,'System.SetLength',[fItems.AsCallParameter, fCount_subtract_1.AsCallParameter].ToList));
  lm.Statements.Add(new CGAssignmentStatement(fCount, fCount_subtract_1));
  {$ENDREGION}

  {$REGION public procedure Resize(anElementCount: Integer); override;}
  var anElementCount: CGExpression := 'anElementCount'.AsNamedIdentifierExpression;
  var anElementCount_sub_1 := new CGBinaryOperatorExpression(anElementCount,                        // anElementCount-1
                                                             new CGIntegerLiteralExpression(1),
                                                             CGBinaryOperatorKind.Subtraction);
  lm := new CGMethodDefinition('Resize',
                            Parameters := [new CGParameterDefinition('anElementCount',ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  if isComplex(library, lElementType) then begin
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement('i',ResolveStdtypes(CGPredefinedTypeKind.Int32)));
  end;
  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(fCount, anElementCount, CGBinaryOperatorKind.Equals),  new CGReturnStatement()));
  if isComplex(library, lElementType) then begin
    lm.Statements.Add(new CGForToLoopStatement('i',
                                               ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                               fCount_subtract_1,
                                               anElementCount,
                                               new CGDestroyInstanceExpression(fItems_i),
                                               Direction := CGLoopDirectionKind.Backward));
  end;
  lm.Statements.Add(Array_SetLength(fItems, anElementCount));
  //lm.Statements.Add(new CGMethodCallExpression(nil,'System.SetLength',[fItems.AsCallParameter, anElementCount.AsCallParameter].ToList));
  if isComplex(library, lElementType) then begin
    lm.Statements.Add(new CGForToLoopStatement('i',
                                               ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                               fCount,
                                               anElementCount_sub_1,
                                               new CGAssignmentStatement(fItems_i,new CGNewInstanceExpression(el_typeref))));
  end;
  lm.Statements.Add(new CGAssignmentStatement(fCount,anElementCount));
  {$ENDREGION}

  {$REGION public procedure Assign(aSource: TPersistent); override;}
  lm := new CGMethodDefinition('Assign',
                            Parameters := [new CGParameterDefinition('aSource','TPersistent'.AsTypeReference)].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:Add(new CGVariableDeclarationStatement("lSource",array_typeref));
  lm.LocalVariables:Add(new CGVariableDeclarationStatement("i",ResolveStdtypes(CGPredefinedTypeKind.Int32)));
  var lAsClass := isComplex(library,lElementType);
  if lAsClass then
    lm.LocalVariables:Add(new CGVariableDeclarationStatement("lItem",el_typeref));
  var aSourceExpr := 'aSource'.AsNamedIdentifierExpression;                                                                     // aSource
  var lSourceExpr := 'lSource'.AsNamedIdentifierExpression;                                                                     // lSource
  var lSource_Count := new CGFieldAccessExpression(lSourceExpr,'Count',CallSiteKind:= CGCallSiteKind.Reference);                // lSource.Count
  var lSelfitems_i := new CGPropertyAccessExpression(CGSelfExpression.Self,
                                                     'Items',
                                                     ['i'.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                                     CallSiteKind := CGCallSiteKind.Reference); // Self.Items[i]
  var larritem := new CGPropertyAccessExpression(lSourceExpr,
                                                 'Items',
                                                 ['i'.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                                 CallSiteKind:= CGCallSiteKind.Reference); // lSource.Items[i]
  var litem := 'lItem'.AsNamedIdentifierExpression;                                                                             // lItem
  var lct := new CGBeginEndBlockStatement;
  lm.Statements.Add(new CGIfThenElseStatement(GenerateIsClause(aSourceExpr,array_typeref),
                                        lct,
                                        new CGMethodCallExpression(CGInheritedExpression.Inherited,'Assign',[aSourceExpr.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Static)));
  lct.Statements.Add(new CGAssignmentStatement(lSourceExpr,new CGTypeCastExpression(aSourceExpr, array_typeref)));
  lct.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, 'Clear',CallSiteKind:= CGCallSiteKind.Reference));
  lct.Statements.Add(new CGEmptyStatement);

  if lAsClass then begin
    var if_true := new CGBeginEndBlockStatement();
    // lSource.Items[i].ClassType.Create()
    if isArray(library,lElementType) or isComplex(library,lElementType) or isException(library,lElementType) then begin
      // we can use .Clone method
      var lnew := new CGMethodCallExpression(larritem,"Clone", CallSiteKind := CGCallSiteKind.Reference);     //lSource.Items[i].Clone
      if_true.Statements.Add(new CGAssignmentStatement(litem,new CGTypeCastExpression(lnew,el_typeref))); //lItem := AdminProperty(xxx);
    end
    else if isBinary(lElementType) then begin
      //binary
      if_true.Statements.Add(new CGAssignmentStatement(litem,new CGNewInstanceExpression(el_typeref))); //lItem := Binary.Create();
      if_true.Statements.Add(new CGMethodCallExpression(litem,'Assign',[larritem.AsCallParameter].ToList, CallSiteKind:= CGCallSiteKind.Reference));//lItem.Assign(lSource.Items[i]);
    end
    else begin
      // unknown object
      var lnew: CGExpression := new CGNewInstanceExpression(new CGMethodCallExpression(larritem,'ClassType',CallSiteKind:= CGCallSiteKind.Static));//lSource.Items[i].ClassType.Create()
      if_true.Statements.Add(new CGAssignmentStatement(litem,new CGTypeCastExpression(lnew,el_typeref)));//lItem := AdminProperty(xxx);
      if_true.Statements.Add(new CGMethodCallExpression(litem,'Assign',[larritem.AsCallParameter].ToList, CallSiteKind:= CGCallSiteKind.Reference));//lItem.Assign(lSource.Items[i]);
    end;
    if_true.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self,'Add',[litem.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference)); //self.Add(lItem);
    lct.Statements.Add(new CGForToLoopStatement('i', //for i := 0 to lSource.Count-1 do
                                                ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                                new CGIntegerLiteralExpression(0),
                                                new CGBinaryOperatorExpression(lSource_Count,
                                                                              new CGIntegerLiteralExpression(1),
                                                                              CGBinaryOperatorKind.Subtraction),
                                                new CGIfThenElseStatement(
                                                                          new CGAssignedExpression(larritem),
                                                                          if_true,
                                                                          new CGMethodCallExpression(CGSelfExpression.Self,'Add',[CGNilExpression.Nil.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference)
                                                                          )));
  end
  else begin
    lct.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, 'Resize',[lSource_Count.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    lct.Statements.Add(new CGForToLoopStatement('i', //for i := 0 to lSource.Count-1 do
                                                ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                                new CGIntegerLiteralExpression(0),
                                                new CGBinaryOperatorExpression(lSource_Count,
                                                                              new CGIntegerLiteralExpression(1),
                                                                              CGBinaryOperatorKind.Subtraction),
                                                new CGAssignmentStatement(lSelfitems_i,larritem) //Self.Items[i] := lSource.Items[i];
                                                ));
  end;
  {$ENDREGION}

  var TROSerializer_typeref := 'TROSerializer'.AsTypeReference;
  var lSerializer_typeref := new CGTypeCastExpression('aSerializer'.AsNamedIdentifierExpression,'TROSerializer'.AsTypeReference);
  var lSerializer := '__Serializer'.AsNamedIdentifierExpression;
  var ar_element_name := new CGMethodCallExpression(lSerializer,
                                                   'GetArrayElementName',
                                                   [new CGMethodCallExpression(nil, 'GetItemType').AsCallParameter,
                                                    new CGMethodCallExpression(nil, 'GetItemRef',['i'.AsNamedIdentifierExpression.AsCallParameter].ToList).AsCallParameter].ToList,
                                                    CallSiteKind:= CGCallSiteKind.Reference).AsCallParameter;
  //TROSerializer(aSerializer).GetArrayElementName(GetItemType, GetItemRef(i))
  {$REGION public procedure ReadComplex(aSerializer: TObject); override;}
  lm := new CGMethodDefinition('ReadComplex',
                            Parameters := [new CGParameterDefinition('aSerializer','TObject'.AsTypeReference)].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:Add(new CGVariableDeclarationStatement('__Serializer',TROSerializer_typeref,lSerializer_typeref));
  lm.LocalVariables:Add(new CGVariableDeclarationStatement('lval',el_typeref));
  lm.LocalVariables:Add(new CGVariableDeclarationStatement('i',ResolveStdtypes(CGPredefinedTypeKind.Int32)));
  var lforst := new List<CGStatement>;
  lforst.AddRange(Intf_generateReadStatement(library,
                                   entity.ElementType,
                                   lSerializer,
                                   ar_element_name,
                                   'lval'.AsNamedIdentifierExpression.AsCallParameter,
                                   el_typeref,
                                   'i'.AsNamedIdentifierExpression.AsCallParameter));
  lforst.Add(new CGAssignmentStatement(Self_Items_i, 'lval'.AsNamedIdentifierExpression));
  lm.Statements.Add(new CGForToLoopStatement('i',
                                            ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                            new CGIntegerLiteralExpression(0),
                                            fCount_subtract_1,
                                            new CGBeginEndBlockStatement(lforst)
                                            ));

  {$ENDREGION}

  {$REGION public procedure WriteComplex(aSerializer: TObject); override;}
  lm := new CGMethodDefinition('WriteComplex',
                            Parameters := [new CGParameterDefinition('aSerializer','TObject'.AsTypeReference)].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:Add(new CGVariableDeclarationStatement('__Serializer',TROSerializer_typeref,lSerializer_typeref));
  lm.LocalVariables:Add(new CGVariableDeclarationStatement('i',ResolveStdtypes(CGPredefinedTypeKind.Int32)));
  lm.Statements.Add(new CGMethodCallExpression(lSerializer,'ChangeClass',[ cpp_ClassId(DuplicateType(array_typeref, false).AsExpression).AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));

  var ws := Intf_generateWriteStatement(library,
                                  entity.ElementType,
                                  lSerializer,
                                  ar_element_name,
                                  fItems_i.AsCallParameter,
                                  el_typeref,
                                  'i'.AsNamedIdentifierExpression.AsCallParameter);
  lm.Statements.Add(new CGForToLoopStatement('i',
                                            ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                            new CGIntegerLiteralExpression(0),
                                            fCount_subtract_1,
                                            new CGBeginEndBlockStatement(ws)
                                            ));
  {$ENDREGION}

  {$REGION public function Add(const Value: %structtype%): Integer;}
  lm := new CGMethodDefinition('Add',
                          Overloaded := isComplex(library,lElementType),
                          Parameters := [new CGParameterDefinition('Value',el_typeref{,Modifier := CGParameterModifierKind.Const})].ToList,
                          Visibility := CGMemberVisibilityKind.Public,
                          ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Int32),
                          CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:&Add(new CGVariableDeclarationStatement('lResult', lm.ReturnType, fCount));

  lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(Array_GetLength(fItems),
                                                                             //new CGMethodCallExpression(nil, 'System.Length',[fItems.AsCallParameter].ToList),
                                                                             l_Result,
                                                                             CGBinaryOperatorKind.Equals),
                                              new CGMethodCallExpression(CGSelfExpression.Self, 'Grow',CallSiteKind:= CGCallSiteKind.Reference)));
  lm.Statements.Add(new CGAssignmentStatement(fItems_Result, 'Value'.AsNamedIdentifierExpression));
  lm.Statements.Add(new CGAssignmentStatement(fCount, fCount_add_1));
  lm.Statements.Add(l_Result.AsReturnStatement);
  {$ENDREGION}

  if not isComplex(library,lElementType) then begin
    {$REGION public function GetIndex(const aValue: %structtype%;const aStartFrom: Integer = 0): Integer;overload;}
    lm := new CGMethodDefinition('GetIndex',
                            Parameters := [new CGParameterDefinition('aValue',el_typeref,Modifier := CGParameterModifierKind.Const),
                                           new CGParameterDefinition('aStartFrom',ResolveStdtypes(CGPredefinedTypeKind.Int32),Modifier := CGParameterModifierKind.Const, DefaultValue := new CGIntegerLiteralExpression(0))].ToList,
                            Visibility := CGMemberVisibilityKind.Public,
                            Overloaded := true,
                            ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Int32),
                            CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(lm);
    lm.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self,
                                                 'IndexOf',
                                                 ['aValue'.AsNamedIdentifierExpression.AsCallParameter,
                                                  'aStartFrom'.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                                 CallSiteKind:= CGCallSiteKind.Reference).AsReturnStatement);
    {$ENDREGION}

    {$REGION public function GetIndex(const aPropertyName : string;const aPropertyValue : Variant;StartFrom : Integer = 0;Options : TROSearchOptions = [soIgnoreCase]): Integer;override;}
    lm := new CGMethodDefinition('GetIndex',
                        Parameters := [new CGParameterDefinition('aPropertyName',ResolveStdtypes(CGPredefinedTypeKind.String),Modifier := CGParameterModifierKind.Const),
                                        new CGParameterDefinition('aPropertyValue','Variant'.AsTypeReference,Modifier := CGParameterModifierKind.Const),
                                        new CGParameterDefinition('aStartFrom',ResolveStdtypes(CGPredefinedTypeKind.Int32), DefaultValue := new CGIntegerLiteralExpression(0)),
                                        new CGParameterDefinition('Options',new CGNamedTypeReference('TROSearchOptions') isClasstype(false),DefaultValue := new CGSetLiteralExpression([CGExpression('soIgnoreCase'.AsNamedIdentifierExpression)].ToList, 'TROSearchOptions'.AsTypeReference))].ToList,
                        Virtuality := CGMemberVirtualityKind.Override,
                        Visibility := CGMemberVisibilityKind.Public,
                        ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Int32),
                        CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(lm);
    lm.Statements.Add(new CGIntegerLiteralExpression(-1).AsReturnStatement);
    {$ENDREGION}

    {$REGION public function IndexOf(const aValue: %structtype%;const aStartFrom: Integer = 0): Integer;}
    lm := new CGMethodDefinition('IndexOf',
                      Parameters := [new CGParameterDefinition('aValue',el_typeref,Modifier := CGParameterModifierKind.Const),
                                     new CGParameterDefinition('aStartFrom',ResolveStdtypes(CGPredefinedTypeKind.Int32),Modifier := CGParameterModifierKind.Const, DefaultValue := new CGIntegerLiteralExpression(0))].ToList,
                      Visibility := CGMemberVisibilityKind.Public,
                      ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Int32),
                      CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:&Add(new CGVariableDeclarationStatement('lResult', lm.ReturnType));
    lm.Statements.Add(new CGForToLoopStatement('lResult',
                                              ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                              'aStartFrom'.AsNamedIdentifierExpression,
                                              fCount_subtract_1,
                                              new CGIfThenElseStatement(new CGBinaryOperatorExpression(fItems_Result, 'aValue'.AsNamedIdentifierExpression, CGBinaryOperatorKind.Equals),
                                                                        new CGBeginEndBlockStatement(['lResult'.AsNamedIdentifierExpression.AsReturnStatement]))
                                              ));

    lm.Statements.Add(new CGIntegerLiteralExpression(-1).AsReturnStatement);
    {$ENDREGION}
  end
  else begin
    {$REGION public function Add: %structtype%;overload;}
    lm := new CGMethodDefinition('Add',
                                Overloaded := true,
                                Visibility := CGMemberVisibilityKind.Public,
                                ReturnType := el_typeref,
                                CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(lm);
    var lres := "lres".AsNamedIdentifierExpression;
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement("lres",lm.ReturnType));

    if isException(library,lElementType) then
      lm.Statements.Add(new CGAssignmentStatement(lres, new CGNewInstanceExpression(el_typeref,[''.AsLiteralExpression.AsCallParameter, new CGArrayLiteralExpression().AsCallParameter].ToList,ConstructorName := 'CreateFmt')))
    else
      lm.Statements.Add(new CGAssignmentStatement(lres, new CGNewInstanceExpression(el_typeref)));
    lm.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self,'Add',[lres.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    lm.Statements.Add(lres.AsReturnStatement);
    {$ENDREGION}
  end;

  {$REGION public function GetEnumerator: %array%Enumerator;}
  var lReturnType := ResolveDataTypeToTypeRefFullQualified(library, lEnumerator, Intf_name, larrayname);
  lm := new CGMethodDefinition('GetEnumerator',
                               Visibility := CGMemberVisibilityKind.Public,
                               ReturnType := lReturnType,
                               CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.Statements.Add(new CGNewInstanceExpression(lReturnType, [CGSelfExpression.Self.AsCallParameter].ToList).AsReturnStatement);
  {$ENDREGION}

  {$REGION public property Count: Integer read GetCount;}
  ltype.Members.Add(
                  new CGPropertyDefinition("Count",
                                           ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                           'GetCount'.AsNamedIdentifierExpression,
                                           Visibility := CGMemberVisibilityKind.Public
                                          ));
  {$ENDREGION}

  {$REGION public property Items[Index: Integer]:%structtype% read GetItems write SetItems; default;}
  ltype.Members.Add( new CGPropertyDefinition("Items",
                                    el_typeref,
                                    'GetItems'.AsNamedIdentifierExpression,
                                    'SetItems'.AsNamedIdentifierExpression,
                                    Visibility := CGMemberVisibilityKind.Public,
                                    Parameters := [new CGParameterDefinition('Index', ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                                    &Default := true
                      ));
  {$ENDREGION}

  {$REGION public property InnerArray: %s_%s read fItems;}
  ltype.Members.Add( new CGPropertyDefinition("InnerArray",
                                              linternalarr_typeref,
                                              'fItems'.AsNamedIdentifierExpression,
                                              Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}

  cpp_GenerateArrayDestructor(ltype);

  {$REGION initialization/finalization}
  file.Initialization:Add(new CGMethodCallExpression(nil, 'RegisterROClass',[cpp_ClassId(larrayname.AsNamedIdentifierExpression).AsCallParameter, 'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  file.Finalization:Add(new CGMethodCallExpression(nil, 'UnregisterROClass',[cpp_ClassId(larrayname.AsNamedIdentifierExpression).AsCallParameter, 'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}

  {$REGION %arrayname%Enumerator}
  var lenumtype := new CGClassTypeDefinition(lEnumerator, 'TObject'.AsTypeReference,
                                             Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(lenumtype);
  {$REGION private fArray: %arrayname%}
  lenumtype.Members.Add(
                      new CGFieldDefinition("fArray",
                                  array_typeref,
                                  Visibility := CGMemberVisibilityKind.Private
                                  ));
  {$ENDREGION}
  {$REGION private fCurrentIndex: Integer;}
  lenumtype.Members.Add(
                      new CGFieldDefinition("fCurrentIndex",
                                  ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                  Visibility := CGMemberVisibilityKind.Private
                                  ));
  {$ENDREGION}
  var fCurrentIndex := 'fCurrentIndex'.AsNamedIdentifierExpression;
  var fCurrentIndex_add_1 := new CGBinaryOperatorExpression(fCurrentIndex, new CGIntegerLiteralExpression(1), CGBinaryOperatorKind.Addition);
  var fArray := 'fArray'.AsNamedIdentifierExpression;
  {$REGION private function GetCurrent: %elementtype%}
  lm := new CGMethodDefinition('GetCurrent',
                                Visibility := CGMemberVisibilityKind.Private,
                                ReturnType := el_typeref,
                                CallingConvention := CGCallingConventionKind.Register
                                );
  lenumtype.Members.Add(lm);
  lm.Statements.Add(new CGPropertyAccessExpression(fArray,'Items',[fCurrentIndex.AsCallParameter].ToList,CallSiteKind := CGCallSiteKind.Reference).AsReturnStatement);
  {$ENDREGION}

  {$REGION public constructor Create(const anArray: %arrayname%);}
  lm := new CGConstructorDefinition(Parameters := [new CGParameterDefinition('anArray', array_typeref{, Modifier := CGParameterModifierKind.Const})].ToList,
                                    Visibility := CGMemberVisibilityKind.Public,
                                    CallingConvention := CGCallingConventionKind.Register
                                    );
  lenumtype.Members.Add(lm);
  lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));
  lm.Statements.Add(new CGAssignmentStatement(fArray, 'anArray'.AsNamedIdentifierExpression));
  lm.Statements.Add(new CGAssignmentStatement(fCurrentIndex, new CGIntegerLiteralExpression(-1)));
  {$ENDREGION}

  {$REGION public function MoveNext: Boolean;}
  lm := new CGMethodDefinition('MoveNext',
                                Visibility := CGMemberVisibilityKind.Public,
                                ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Boolean),
                                CallingConvention := CGCallingConventionKind.Register);
  lenumtype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:&Add(new CGVariableDeclarationStatement( 'lResult', lm.ReturnType));
  lm.Statements.Add(new CGAssignmentStatement(l_Result, new CGBinaryOperatorExpression(fCurrentIndex,
                                                                                       new CGBinaryOperatorExpression(new CGFieldAccessExpression(fArray,'Count',CallSiteKind:= CGCallSiteKind.Reference),
                                                                                                                      new CGIntegerLiteralExpression(1),
                                                                                                                      CGBinaryOperatorKind.Subtraction),
                                                                                       CGBinaryOperatorKind.LessThan)));
  lm.Statements.Add(new CGIfThenElseStatement(l_Result,new CGAssignmentStatement(fCurrentIndex, fCurrentIndex_add_1)));
  lm.Statements.Add(l_Result.AsReturnStatement);
  {$ENDREGION}

  {$REGION public property Current: %elementtype% read GetCurrent;}
  lenumtype.Members.Add( new CGPropertyDefinition("Current",
                                                  el_typeref,
                                                  'GetCurrent'.AsNamedIdentifierExpression,
                                                  Visibility := CGMemberVisibilityKind.Public
                                                  ));
  {$ENDREGION}
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateException(file: CGCodeUnit; &library: RodlLibrary; entity: RodlException);
begin
  var lAncestorName := entity.AncestorName;
  var l_EntityName := entity.Name;
  var exception_typeref := ResolveDataTypeToTypeRefFullQualified(library,l_EntityName,Intf_name);

  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := "EROException";

  var ltype := new CGClassTypeDefinition(l_EntityName,
                                         ResolveDataTypeToTypeRefFullQualified(library, lAncestorName, Intf_name),
                                         Visibility := CGTypeVisibilityKind.Public
                                         );
  file.Types.Add(ltype);
  ltype.Comment := GenerateDocumentation(entity);
  var lclasscnt:= 0;
  var lNeedInitSimpleTypeWithDefaultValues := False;

  {$REGION private f%fldname%: %fldtype%}
  for lentityItem :RodlTypedEntity in entity.Items do begin
    ltype.Members.Add(
                        new CGFieldDefinition("f"+lentityItem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(&library,lentityItem.DataType, Intf_name),
                                              Visibility := CGMemberVisibilityKind.Private
                                              ));
  end;
  {$ENDREGION}


  {$REGION private Get%fldname%: %fldtype%}
  for lentityItem :RodlTypedEntity in entity.Items do begin
    var lentityname:= lentityItem.Name;
    var f_name :=('f'+lentityname).AsNamedIdentifierExpression;
    if isComplex(library,lentityItem.DataType) then begin
      inc(lclasscnt);
      var lm := new CGMethodDefinition('Get'+lentityname,
                                       ReturnType := ResolveDataTypeToTypeRefFullQualified(&library,lentityItem.DataType, Intf_name),
                                       Visibility := CGMemberVisibilityKind.Private,
                                       CallingConvention := CGCallingConventionKind.Register);
      ltype.Members.Add(lm);
      if entity.AutoCreateProperties then begin
        var ifs_true: CGStatement;
        if isException(library, lentityItem.DataType) then
          ifs_true := new CGAssignmentStatement(
                                                f_name,
                                                new CGMethodCallExpression(lentityItem.DataType.AsNamedIdentifierExpression,'CreateFmt',
                                                                          [''.AsLiteralExpression.AsCallParameter, new CGArrayLiteralExpression().AsCallParameter].ToList,
                                                                           CallSiteKind:= CGCallSiteKind.Reference))
        else
          ifs_true := new CGAssignmentStatement(
                                                f_name,
                                                new CGNewInstanceExpression(lentityItem.DataType.AsTypeReference));
        lm.Statements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(f_name,CGNilExpression.Nil,CGBinaryOperatorKind.Equals),ifs_true));
      end;
      lm.Statements.Add(f_name.AsReturnStatement);
    end
    else begin
      lNeedInitSimpleTypeWithDefaultValues := lNeedInitSimpleTypeWithDefaultValues or lentityItem.CustomAttributes_lower.ContainsKey('default');
    end;
  end;
  {$ENDREGION}

  var lSerializeInitializedStructValues := isPresent_SerializeInitializedStructValues_Attribute(library);
  {$REGION protected int_%fldname%: %fldtype% read f%fldname%;}
  if not lSerializeInitializedStructValues then begin
    if lclasscnt >0 then begin
      for lentityItem :RodlTypedEntity in entity.Items do begin
        if isComplex(library,lentityItem.DataType) then begin
          ltype.Members.Add(new CGPropertyDefinition(
                                              'int_'+lentityItem.Name,
                                               ResolveDataTypeToTypeRefFullQualified(&library,lentityItem.DataType, Intf_name),
                                               ('f'+lentityItem.Name).AsNamedIdentifierExpression,
                                              Visibility := CGMemberVisibilityKind.Protected));
        end;
      end;
    end;
  end;
  {$ENDREGION}

  if entity.Count > 0 then begin
  {$REGION public constructor Create(anExceptionMessage : string;%flds%);}
  var lmc := new CGConstructorDefinition(
                          Parameters:=[new CGParameterDefinition('anExceptionMessage', ResolveStdtypes(CGPredefinedTypeKind.String))].ToList,
                          Visibility := CGMemberVisibilityKind.Public,
                          CallingConvention := CGCallingConventionKind.Register
                          );
  var lif:=entity.GetInheritedItems;
  for fld in lif do
    lmc.Parameters.Add(new CGParameterDefinition('a'+fld.Name, ResolveDataTypeToTypeRefFullQualified(&library,fld.DataType, Intf_name)));
  for fld in entity.Items do
    lmc.Parameters.Add(new CGParameterDefinition('a'+fld.Name, ResolveDataTypeToTypeRefFullQualified(&library,fld.DataType, Intf_name)));
  ltype.Members.Add(lmc);
  var lmcc := new CGConstructorCallStatement(CGInheritedExpression.Inherited, ['anExceptionMessage'.AsNamedIdentifierExpression.AsCallParameter].ToList);
  lmc.Statements.Add(lmcc);
  for fld in lif do
    lmcc.Parameters.Add(('a'+fld.Name).AsNamedIdentifierExpression.AsCallParameter);

  for lentityItem :RodlTypedEntity in entity.Items do
    lmc.Statements.Add(new CGAssignmentStatement(('f'+lentityItem.Name).AsNamedIdentifierExpression,('a'+lentityItem.Name).AsNamedIdentifierExpression));
  {$ENDREGION}
  end;

  ProcessAttributes(entity, ltype);

  if entity.Count > 0 then begin
    {$REGION public procedure Assign(aSource: EROException); override;}
    var lm := new CGMethodDefinition('Assign',
                            Parameters:=[new CGParameterDefinition('aSource','EROException'.AsTypeReference)].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement("lSource",exception_typeref));


    lm.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited,'Assign', ['aSource'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Static));
    var lct := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(GenerateIsClause('aSource'.AsNamedIdentifierExpression,exception_typeref),
                                          lct));

    lct.Statements.Add(new CGAssignmentStatement('lSource'.AsNamedIdentifierExpression,
                                                 new CGTypeCastExpression('aSource'.AsNamedIdentifierExpression, exception_typeref)));
    for lentityItem :RodlTypedEntity in entity.Items do begin
      if isComplex(library,lentityItem.DataType) then begin
        var fname := 'f'+lentityItem.Name;
        var flde := new CGFieldAccessExpression('lSource'.AsNamedIdentifierExpression,fname,CallSiteKind:= CGCallSiteKind.Reference);
        var ifs := new CGIfThenElseStatement(new CGAssignedExpression(flde),
                                             new CGMethodCallExpression(new CGFieldAccessExpression(CGSelfExpression.Self, lentityItem.Name,CallSiteKind:= CGCallSiteKind.Reference),
                                                                        'Assign',
                                                                        [flde.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference),
                                             new CGBeginEndBlockStatement([
                                                                            new CGDestroyInstanceExpression(fname.AsNamedIdentifierExpression),
                                                                            new CGAssignmentStatement(fname.AsNamedIdentifierExpression,CGNilExpression.Nil)]));
        if entity.AutoCreateProperties then
          lct.Statements.Add(new CGIfThenElseStatement(new CGAssignedExpression(new CGFieldAccessExpression(CGSelfExpression.Self,fname,CallSiteKind:= CGCallSiteKind.Reference)),
                                                       ifs))
        else
          lct.Statements.Add(ifs);
      end
      else begin
        lct.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(CGSelfExpression.Self, lentityItem.Name,CallSiteKind:= CGCallSiteKind.Reference),
                                                     new CGFieldAccessExpression('lSource'.AsNamedIdentifierExpression,lentityItem.Name,CallSiteKind:= CGCallSiteKind.Reference)));
      end;
    end;
(*
    if aStruct.Count >0 then WriteEmptyLine;

    for i := 0 to (aStruct.Count-1) do begin
      if IsImplementedAsClass(aStruct.Items[i].DataType, aLibrary) then begin
        if not aStruct.AutoCreateParams then Write(Format('    if System.Assigned(f%s) then begin'#13#10, [aStruct.Items[i].Name]));
        Write(Format('    if System.Assigned(lSource.f%0:s) then ',[aStruct.Items[i].Name]));
        Write(Format('      Self.%s.Assign(lSource.f%0:s)',[aStruct.Items[i].Name]));
        Write(       '    else');
        Write(Format('      {$IFDEF DELPHIXE2UP}System.{$ENDIF}SysUtils.FreeAndNil(f%s);',[aStruct.Items[i].Name]));
        if not aStruct.AutoCreateParams then Write('    end;'#13#10);
      end
      else begin
        lNeedInitSimpleTypeWithDefaultValues := lNeedInitSimpleTypeWithDefaultValues or (aStruct.Items[i].Attributes.IndexOfName('Default') <> -1);
        Write(Format('    Self.%s := lSource.%0:s;',[aStruct.Items[i].Name]));
      end;
    end;
    Write('  end;');
*)
    {$ENDREGION}

    var litemList := entity.GetAllItems;
    var litemList_Sorted := litemList.ToList.Sort_OrdinalIgnoreCase(b->b.Name);
    var TROSerializer_typeref := 'TROSerializer'.AsTypeReference;
    var lSerializer_cast := new CGTypeCastExpression('aSerializer'.AsNamedIdentifierExpression,TROSerializer_typeref);
    var lSerializer := '__Serializer'.AsNamedIdentifierExpression;


    {$REGION public procedure ReadException(aSerializer: TROBaseSerializer); override;}
    lm := new CGMethodDefinition('ReadException',
                                  Parameters:=[new CGParameterDefinition('aSerializer','TROBaseSerializer'.AsTypeReference)].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement('__Serializer',TROSerializer_typeref, lSerializer_cast));

    for lmem in litemList_Sorted do
      lm.LocalVariables:Add(new CGVariableDeclarationStatement('l_'+lmem.Name,ResolveDataTypeToTypeRefFullQualified(library,lmem.DataType,Intf_name)));
    var lSorted := new CGBeginEndBlockStatement;
    var lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGFieldAccessExpression(lSerializer,'RecordStrictOrder',CallSiteKind:= CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if entity.Count <> litemList.Count then lStrict.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, 'ReadException',['aSerializer'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Static));
    Intf_GenerateRead(file,library,entity.Items,lStrict.Statements, lSerializeInitializedStructValues,lSerializer);
    Intf_GenerateRead(file,library,litemList_Sorted,lSorted.Statements, lSerializeInitializedStructValues,lSerializer);
    {$ENDREGION}

    {$REGION public procedure WriteException(aSerializer: TROBaseSerializer); override;}
    lm := new CGMethodDefinition('WriteException',
                                  Parameters:=[new CGParameterDefinition('aSerializer','TROBaseSerializer'.AsTypeReference)].ToList,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register
                        );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement('__Serializer',TROSerializer_typeref, lSerializer_cast));
    for lmem in litemList_Sorted do
      lm.LocalVariables:Add(new CGVariableDeclarationStatement('l_'+lmem.Name,ResolveDataTypeToTypeRefFullQualified(library,lmem.DataType,Intf_name)));
    lSorted := new CGBeginEndBlockStatement;
    lStrict := new CGBeginEndBlockStatement;
    lm.Statements.Add(new CGIfThenElseStatement(new CGFieldAccessExpression(lSerializer,'RecordStrictOrder',CallSiteKind:= CGCallSiteKind.Reference),
                                                lStrict,
                                                lSorted));

    if entity.Count <> litemList.Count then lStrict.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, 'WriteException',['aSerializer'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Static));
    lStrict.Statements.Add(new CGMethodCallExpression(lSerializer,'ChangeClass',[cpp_ClassId(l_EntityName.AsNamedIdentifierExpression).AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    Intf_GenerateWrite(file,library,entity.Items,lStrict.Statements, lSerializeInitializedStructValues,lSerializer);
    Intf_GenerateWrite(file,library,litemList_Sorted,lSorted.Statements, lSerializeInitializedStructValues,lSerializer);
    {$ENDREGION}
  end;

  {$REGION published property %fldname%: %fldtype% read [f|Get]%fldname% write f%fldname%;}
  for lentityItem :RodlTypedEntity in entity.Items do begin
    var lp := iif(isComplex(library,lentityItem.DataType), 'Get','f');
    var lprop := new CGPropertyDefinition(lentityItem.Name,
                                          ResolveDataTypeToTypeRefFullQualified(&library,lentityItem.DataType, Intf_name),
                                          (lp+lentityItem.Name).AsNamedIdentifierExpression,
                                          ('f'+lentityItem.Name).AsNamedIdentifierExpression,
                                          Visibility := CGMemberVisibilityKind.Published);
    lprop.Comment := GenerateDocumentation(lentityItem);
    ltype.Members.Add(lprop);
  end;
  {$ENDREGION}
  {$REGION initialization/finalization}
  file.Initialization:Add(new CGMethodCallExpression(nil, 'RegisterExceptionClass',[cpp_ClassId(l_EntityName.AsNamedIdentifierExpression).AsCallParameter, 'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  file.Finalization:Add(new CGMethodCallExpression(nil, 'UnregisterExceptionClass',[cpp_ClassId(l_EntityName.AsNamedIdentifierExpression).AsCallParameter, 'DefaultNamespace'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateService(file: CGCodeUnit; &library: RodlLibrary; entity: RodlService);
begin
  var l_EntityName := entity.Name;
  var l_IName := 'I'+l_EntityName;
  var l_IName_Async := 'I'+l_EntityName+'_Async';
  var l_IName_AsyncEx := 'I'+l_EntityName+'_AsyncEx';

  var l_CoName := 'Co'+l_EntityName;
  var l_CoName_Async := 'Co'+l_EntityName+'_Async';
  var l_CoName_AsyncEx := 'Co'+l_EntityName+'_AsyncEx';
  
  var l_Tname_Proxy := 'T'+l_EntityName+'_Proxy';                                                                  //T%service%Proxy
  var l_Tname_AsyncProxy := 'T'+l_EntityName+'_AsyncProxy';
  var l_Tname_AsyncProxyEx := 'T'+l_EntityName+'_AsyncProxyEx';

  var l_Tname_Proxy_typeref := ResolveDataTypeToTypeRefFullQualified(library,l_Tname_Proxy,Intf_name,l_EntityName); //T%service%Proxy
  var l_Tname_AsyncProxy_typeref := ResolveDataTypeToTypeRefFullQualified(library,l_Tname_AsyncProxy,Intf_name,l_EntityName);
  var l_Tname_AsyncProxyEx_typeref := ResolveDataTypeToTypeRefFullQualified(library,l_Tname_AsyncProxyEx,Intf_name,l_EntityName);

  var l_IName_typeref := ResolveInterfaceTypeRef(library,l_IName,Intf_name,l_EntityName); // I%service% (delphi) or _di_I%service% (c++Builder)
  var l_IName_Async_typeref := ResolveInterfaceTypeRef(library,l_IName_Async,Intf_name,l_EntityName); // I%service%_Async or _di_I%service%_Async
  var l_IName_AsyncEx_typeref := ResolveInterfaceTypeRef(library,l_IName_AsyncEx,Intf_name,l_EntityName); // I%service%_AsyncEx or _di_I%service%_AsyncEx

  var TParamAttributes_typeref := new CGNamedTypeReference('TParamAttributes') isClasstype(False);
  
  var lancestorName := entity.AncestorName;
  var lancestor: CGTypeReference;
  var lmember: CGMethodDefinition;


  {$REGION I%service%}
  var ltype := new CGInterfaceTypeDefinition(l_IName,
                                             Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(entity.AncestorName) then
    ltype.Ancestors.Add(ResolveDataTypeToTypeRefFullQualified(library, 'I'+entity.AncestorName,Intf_name,entity.AncestorName))  //I%service%
  else
    ltype.Ancestors.Add("IROService".AsTypeReference);


  ltype.Comment := GenerateDocumentation(entity);
  ltype.InterfaceGuid := entity.DefaultInterface.EntityID;
  file.Types.Add(ltype);

  for lmem in entity.DefaultInterface.Items do begin
    {$REGION service methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      //Virtuality := CGMemberVirtualityKind.Virtual,
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
    mem.Comment := GenerateDocumentation(lmem, true);
    ltype.Members.Add(mem);
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION I%service%_Async}
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'I'+lancestorName+'_Async',Intf_name,lancestorName)
  else
    lancestor := 'IROAsyncInterface'.AsTypeReference;
  ltype := new CGInterfaceTypeDefinition(l_IName_Async,lancestor,
                                         Visibility := CGTypeVisibilityKind.Public);
  ltype.InterfaceGuid := Guid.NewGuid;
  file.Types.Add(ltype);

  {$REGION Invoke_%service_method%}
  for lmem in entity.DefaultInterface.Items do
    ltype.Members.Add(Intf_GenerateAsyncInvoke(library, entity, lmem, false));
  {$ENDREGION}

  {$REGION Retrieve_%service_method%}
  for lmem in entity.DefaultInterface.Items do
    if NeedsAsyncRetrieveOperationDefinition(lmem) then
      ltype.Members.Add(Intf_GenerateAsyncRetrieve(library, entity, lmem, false));
  {$ENDREGION}


  {$ENDREGION}

  {$REGION I%service%_AsyncEx}
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'I'+lancestorName+'_AsyncEx',Intf_name,lancestorName)
  else
    lancestor := 'IROAsyncInterfaceEx'.AsTypeReference;
  ltype := new CGInterfaceTypeDefinition(l_IName_AsyncEx,lancestor,InterfaceGuid := Guid.NewGuid,
                                      Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype);

  {$REGION Invoke_%service_method%}
  for lmem in entity.DefaultInterface.Items do
    ltype.Members.Add(Intf_GenerateAsyncExBegin(library, entity, lmem, false));
  {$ENDREGION}

  {$REGION Retrieve_%service_method%}
  for lmem in entity.DefaultInterface.Items do
    ltype.Members.Add(Intf_GenerateAsyncExEnd(library, entity, lmem, false));
  {$ENDREGION}


  {$ENDREGION}

  var ldef := 'aDefaultNamespaces'.AsNamedIdentifierExpression.AsCallParameter;

  {$REGION Co%service%}
  var ltype1 := new CGClassTypeDefinition(l_CoName,
                                          new CGNamedTypeReference("TObject") &namespace(new CGNamespaceReference("System")),
                                          Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype1);


  {$REGION public class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): I%service%; overload;}
  var lmember_ct:= new CGMethodDefinition("Create",
                                          &Static := true,
                                          Overloaded := true,
                                          ReturnType := l_IName_typeref,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then
    lmember_ct.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aMessage',IROMessage_typeref, Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aTransportChannel',IROTransportChannel_typeref));

  var l_new := new CGNewInstanceExpression(l_Tname_Proxy_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aMessage'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aTransportChannel'.AsNamedIdentifierExpression.AsCallParameter);

  lmember_ct.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_typeref));
  ltype1.Members.Add(lmember_ct);
  {$ENDREGION}

  {$REGION public class function Create(aUri: TROUri; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember_ct:= new CGMethodDefinition("Create",
                                      &Static := true,
                                      Overloaded := true,
                                      ReturnType := l_IName_typeref,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then 
    lmember_ct.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aUri',new CGConstantTypeReference('TROUri'.AsTypeReference)));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));

  l_new := new CGNewInstanceExpression(l_Tname_Proxy_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aUri'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add(ldef);

  lmember_ct.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_typeref));
  ltype1.Members.Add(lmember_ct);
  {$ENDREGION}

  {$REGION public class function Create(const aUrl: string; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember_ct:= new CGMethodDefinition("Create",
                                      &Static := true,
                                      Overloaded := true,
                                      ReturnType := l_IName_typeref,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then 
    lmember_ct.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aUrl',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember_ct.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));

  l_new := new CGNewInstanceExpression(l_Tname_Proxy_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aUrl'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add(ldef);

  lmember_ct.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_typeref));
  ltype1.Members.Add(lmember_ct);
  {$ENDREGION}

  {$ENDREGION}
  
  {$REGION Co%service%_Async}
  ltype1 := new CGClassTypeDefinition(l_CoName_Async,
                                          new CGNamedTypeReference("TObject") &namespace(new CGNamespaceReference("System")),
                                          Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype1);

  {$REGION public class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): I%service%_Async; overload;}
  lmember:= new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_Async_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then
    lmember.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));

  lmember.Parameters.Add(new CGParameterDefinition('aMessage',IROMessage_typeref, Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aTransportChannel',IROTransportChannel_typeref));

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxy_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aMessage'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aTransportChannel'.AsNamedIdentifierExpression.AsCallParameter);

  lmember.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_Async_typeref));
  ltype1.Members.Add(lmember);
  {$ENDREGION}


  {$REGION public class function Create(aUri: TROUri; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember:= new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_Async_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then
    lmember.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aUri',new CGConstantTypeReference('TROUri'.AsTypeReference)));
  lmember.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxy_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aUri'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add(ldef);

  lmember.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_Async_typeref));
  ltype1.Members.Add(lmember);
  {$ENDREGION}

  {$REGION public class function Create(const aUrl: string; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember:= new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_Async_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then
    lmember.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aUrl',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));
  
  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxy_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aUrl'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add(ldef);
  
  lmember.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_Async_typeref));
  ltype1.Members.Add(lmember);
  {$ENDREGION}

  {$ENDREGION}

  {$REGION Co%service%_AsyncEx}
  ltype1 := new CGClassTypeDefinition(l_CoName_AsyncEx,
                                      new CGNamedTypeReference("TObject") &namespace(new CGNamespaceReference("System")),
                                      Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype1);

  {$REGION public class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): I%service%_AsyncEx; overload;}
  lmember:= new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_AsyncEx_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then
    lmember.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aMessage',IROMessage_typeref, Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aTransportChannel',IROTransportChannel_typeref));

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxyEx_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aMessage'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aTransportChannel'.AsNamedIdentifierExpression.AsCallParameter);

  lmember.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_AsyncEx_typeref));
  ltype1.Members.Add(lmember);
  {$ENDREGION}

  {$REGION public class function Create(aUri: TROUri; aDefaultNamespaces: string = ''): I%service%; overload;}
  lmember:= new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_AsyncEx_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then
    lmember.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aUri',new CGConstantTypeReference('TROUri'.AsTypeReference)));
  lmember.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxyEx_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aUri'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add(ldef);

  lmember.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_AsyncEx_typeref));
  ltype1.Members.Add(lmember);
  {$ENDREGION}

  {$REGION public class function Create(const aUrl: string): I%service%; overload;}
  lmember:= new CGMethodDefinition("Create",
                                  &Static := true,
                                  Overloaded := true,
                                  ReturnType := l_IName_AsyncEx_typeref,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);
  if library.DataSnap then
    lmember.Parameters.Add(new CGParameterDefinition('anAppServerName',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aUrl',ResolveStdtypes(CGPredefinedTypeKind.String), Modifier := CGParameterModifierKind.Const));
  lmember.Parameters.Add(new CGParameterDefinition('aDefaultNamespaces',ResolveStdtypes(CGPredefinedTypeKind.String), DefaultValue := ''.AsLiteralExpression));

  l_new := new CGNewInstanceExpression(l_Tname_AsyncProxyEx_typeref);
  if library.DataSnap then 
    l_new.Parameters.Add('anAppServerName'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add('aUrl'.AsNamedIdentifierExpression.AsCallParameter);
  l_new.Parameters.Add(ldef);

  lmember.Statements.AddRange(cppGenerateProxyCast(l_new,l_IName_AsyncEx_typeref));

  ltype1.Members.Add(lmember);
  {$ENDREGION}

  {$ENDREGION}

  {$REGION T%service%_Proxy}
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'T'+lancestorName+'_Proxy',Intf_name, lancestorName)
  else
    lancestor := 'TROProxy'.AsTypeReference;


  ltype1 := new CGClassTypeDefinition(l_Tname_Proxy,
                                      lancestor,
                                      Visibility := CGTypeVisibilityKind.Public);  //TROProxy or T%service%Proxy
  ltype1.ImplementedInterfaces.Add(ResolveDataTypeToTypeRefFullQualified(library, l_IName,Intf_name, l_EntityName));  //I%service%
  file.Types.Add(ltype1);
  {$REGION protected function __GetInterfaceName:string; override;}
  lmember:= new CGMethodDefinition('__GetInterfaceName',
                                  [l_EntityName.AsLiteralExpression.AsReturnStatement],
                                  Virtuality:= CGMemberVirtualityKind.Override,
                                  ReturnType:= ResolveStdtypes(CGPredefinedTypeKind.String),
                                  Visibility := CGMemberVisibilityKind.Protected,
                                  CallingConvention := CGCallingConventionKind.Register);
  ltype1.Members.Add(lmember);
  {$ENDREGION}
  var lMessage := 'lMessage'.AsNamedIdentifierExpression;
  var lTransportChannel := 'lTransportChannel'.AsNamedIdentifierExpression;

  cpp_IUnknownSupport(library, entity, ltype1);
  cpp_GenerateAncestorMethodCalls(library, entity, ltype1, ModeKind.Plain);

  for lmem in entity.DefaultInterface.Items do begin
    {$REGION service methods}
    var mem := new CGMethodDefinition(lmem.Name,
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
    if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType,Intf_name);
    ltype1.Members.Add(mem);
    mem.LocalVariables := new List<CGVariableDeclarationStatement>;
    mem.LocalVariables:Add(new CGVariableDeclarationStatement("lMessage",IROMessage_typeref));
    mem.LocalVariables:Add(new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref));
    if assigned(lmem.Result) then
      mem.LocalVariables:Add(new CGVariableDeclarationStatement("lResult",mem.ReturnType));

    mem.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, '__GetMessage')));
    mem.Statements.Add(new CGMethodCallExpression(lMessage,'SetAutoGeneratedNamespaces',[new CGMethodCallExpression(nil,'DefaultNamespaces').AsCallParameter]));
    mem.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGFieldAccessExpression(nil, '__TransportChannel')));
    ////
    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(library, entity, lmem,out p1, out p2);
    if p1.Count > 0 then begin
      mem.Statements.Add(new CGMethodCallExpression(lMessage,'SetAttributes',[lTransportChannel.AsCallParameter,
                                                                              new CGArrayLiteralExpression(p1).AsCallParameter,
                                                                              new CGArrayLiteralExpression(p2).AsCallParameter].ToList,
                                                    CallSiteKind:= CGCallSiteKind.Reference));
    end;
    var ltry:=new CGTryFinallyCatchStatement();


    for litem in lmem.Items do begin
      if (litem.ParamFlag = ParamFlags.Out) and isComplex(library, litem.DataType) then
        ltry.Statements.Add(new CGAssignmentStatement(litem.Name.AsNamedIdentifierExpression, CGNilExpression.Nil));
    end;
    if assigned(lmem.Result) and isComplex(library, lmem.Result.DataType) then
      ltry.Statements.Add(new CGAssignmentStatement('lResult'.AsNamedIdentifierExpression, CGNilExpression.Nil));
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                    'InitializeRequestMessage',
                                                    [lTransportChannel.AsCallParameter,
                                                    iif(library.DataSnap,'',library.Name).AsLiteralExpression.AsCallParameter,
                                                    '__InterfaceName'.AsNamedIdentifierExpression.AsCallParameter,
                                                    lmem.Name.AsLiteralExpression.AsCallParameter
                                                    ].ToList,
                                                    CallSiteKind:= CGCallSiteKind.Reference));
    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if litem.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        'Write',
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGCallParameter(litem.Name.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                        sa.AsCallParameter].ToList,
                                                        CallSiteKind:= CGCallSiteKind.Reference));

      end;
    end;
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,'Finalize',CallSiteKind:= CGCallSiteKind.Reference));
    ltry.Statements.Add(new CGEmptyStatement);
    ltry.Statements.Add(new CGMethodCallExpression(lTransportChannel,'Dispatch',[lMessage.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    ltry.Statements.Add(new CGEmptyStatement);
    {$REGION ! DataSnap}
    if not library.DataSnap then 
      if assigned(lmem.Result) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if lmem.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      'Read',
                                                      [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                                      new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                      sa.AsCallParameter].ToList,
                                                      CallSiteKind:= CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for litem in lmem.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if litem.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        'Read',
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGCallParameter(litem.Name.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                        sa.AsCallParameter].ToList,
                                                        CallSiteKind:= CGCallSiteKind.Reference));

      end;

    end;
    {$REGION DataSnap}
    if library.DataSnap then 
      if assigned(lmem.Result) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if lmem.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      'Read',
                                                      [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                                      new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                      sa.AsCallParameter].ToList,
                                                      CallSiteKind:= CGCallSiteKind.Reference));
      end;
  {$ENDREGION}
    ltry.FinallyStatements.Add(new CGMethodCallExpression(lMessage,'UnsetAttributes',[lTransportChannel.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    ltry.FinallyStatements.Add(new CGMethodCallExpression(lMessage,'FreeStream',CallSiteKind:= CGCallSiteKind.Reference));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    mem.Statements.Add(ltry);
    if assigned(lmem.Result) then
      mem.Statements.Add('lResult'.AsNamedIdentifierExpression.AsReturnStatement);
    {$ENDREGION}
  end;
  cpp_GenerateProxyConstructors(library, entity, ltype1);
  {$ENDREGION}

  {$REGION T%service%_AsyncProxy}
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'T'+lancestorName+'_AsyncProxy',Intf_name,lancestorName)
  else
    lancestor := 'TROAsyncProxy'.AsTypeReference;
  ltype1 := new CGClassTypeDefinition(l_Tname_AsyncProxy,lancestor, [ResolveDataTypeToTypeRefFullQualified(library, l_IName_Async,Intf_name, l_EntityName)].ToList,
                                      Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype1);
  {$REGION protected function __GetInterfaceName:string; override;}
  var lmember1:= new CGMethodDefinition('__GetInterfaceName',
                                  [l_EntityName.AsLiteralExpression.AsReturnStatement],
                                  Virtuality:= CGMemberVirtualityKind.Override,
                                  ReturnType:= ResolveStdtypes(CGPredefinedTypeKind.String),
                                  Visibility := CGMemberVisibilityKind.Protected,
                                  CallingConvention := CGCallingConventionKind.Register);
  ltype1.Members.Add(lmember1);
  {$ENDREGION}

  cpp_IUnknownSupport(library, entity, ltype1);
  cpp_GenerateAsyncAncestorMethodCalls(library, entity, ltype1);
  cpp_GenerateAncestorMethodCalls(library, entity, ltype1, ModeKind.Async);

  {$REGION Invoke_%service_method%}
  for lmem in entity.DefaultInterface.Items do
    ltype1.Members.Add(Intf_GenerateAsyncInvoke(library, entity, lmem, true));
  {$ENDREGION}

  {$REGION Retrieve_%service_method%}
  for lmem in entity.DefaultInterface.Items do
    if NeedsAsyncRetrieveOperationDefinition(lmem) then
      ltype1.Members.Add(Intf_GenerateAsyncRetrieve(library, entity, lmem, true));
  {$ENDREGION}
  cpp_GenerateProxyConstructors(library, entity, ltype1);
  {$ENDREGION}

  {$REGION T%service%_AsyncProxyEx}
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'T'+lancestorName+'_AsyncProxyEx',Intf_name,lancestorName)
  else
    lancestor := 'TROAsyncProxyEx'.AsTypeReference;
  ltype1 := new CGClassTypeDefinition(l_Tname_AsyncProxyEx,lancestor,[ResolveDataTypeToTypeRefFullQualified(library, l_IName_AsyncEx,Intf_name, l_EntityName)].ToList,
                                      Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype1);
  {$REGION protected function __GetInterfaceName:string; override;}
  lmember1:= new CGMethodDefinition('__GetInterfaceName',
                                  [l_EntityName.AsLiteralExpression.AsReturnStatement],
                                  Virtuality:= CGMemberVirtualityKind.Override,
                                  ReturnType:= ResolveStdtypes(CGPredefinedTypeKind.String),
                                  Visibility := CGMemberVisibilityKind.Protected,
                                  CallingConvention := CGCallingConventionKind.Register);
  ltype1.Members.Add(lmember1);
  {$ENDREGION}

  cpp_IUnknownSupport(library, entity, ltype1);
  cpp_GenerateAncestorMethodCalls(library, entity, ltype1, ModeKind.AsyncEx);

  {$REGION Begin%service_method%}
  for lmem in entity.DefaultInterface.Items do
    ltype1.Members.Add(Intf_GenerateAsyncExBegin(library, entity, lmem, true));
  {$ENDREGION}

  {$REGION End%service_method%}
  for lmem in entity.DefaultInterface.Items do
    ltype1.Members.Add(Intf_GenerateAsyncExEnd(library, entity, lmem, true));
  {$ENDREGION}
  cpp_GenerateProxyConstructors(library, entity, ltype1);
  {$ENDREGION}
  
  {$REGION initialization/finalization}
  file.Initialization:Add(new CGMethodCallExpression(nil, 'RegisterProxyClass',
                                                     [String.Format('I{0}_IID', l_EntityName).AsNamedIdentifierExpression.AsCallParameter,
                                                     cpp_ClassId(String.Format('T{0}_Proxy', l_EntityName).AsNamedIdentifierExpression).AsCallParameter].ToList));

  file.Finalization:Add(new CGMethodCallExpression(nil, 'UnregisterProxyClass', [String.Format('I{0}_IID', l_EntityName).AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateEventSink(file: CGCodeUnit; &library: RodlLibrary; entity: RodlEventSink);
begin
  var l_EntityName := entity.Name;
  var l_IName := 'I'+l_EntityName;
  var l_EID := 'EID_'+l_EntityName;
  var l_invoker := 'T'+l_EntityName+'_Invoker';
  var lancestorName := entity.AncestorName;
  var l_IName_typeref := ResolveInterfaceTypeRef(library,l_IName,Intf_name,l_EntityName);

  {$REGION I%eventsink%}
  var ltype := new CGInterfaceTypeDefinition(l_IName);
  if not String.IsNullOrEmpty(lancestorName) then
    ltype.Ancestors.Add(ResolveDataTypeToTypeRefFullQualified(library, 'I'+lancestorName,Intf_name,lancestorName))
  else
    ltype.Ancestors.Add("IROEventSink".AsTypeReference);


  ltype.Comment := GenerateDocumentation(entity);
  ltype.InterfaceGuid := entity.DefaultInterface.EntityID;
  file.Types.Add(ltype);

  for lmem in entity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      CallingConvention := CGCallingConventionKind.Register);
    for lmemparam in lmem.Items do begin
      if lmemparam.ParamFlag <> ParamFlags.Result then
        mem.Parameters.Add(new CGParameterDefinition(lmemparam.Name, ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType, Intf_name),Modifier := RODLParamFlagToCodegenFlag(lmemparam.ParamFlag)));
    end;
    if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType, Intf_name);
    mem.Comment := GenerateDocumentation(lmem, true);
    ltype.Members.Add(mem);
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION 'T%eventsink%_Invoker'}
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'T'+lancestorName+'_Invoker',Intf_name,lancestorName)
  else
    lancestor := 'TROEventInvoker'.AsTypeReference;

  var ltype1 := new CGClassTypeDefinition(l_invoker, lancestor,
                                          Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype1);
  var IUnknown_typeref := ResolveInterfaceTypeRef(nil, 'IUnknown','');

  for lmem in entity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var mem := new CGMethodDefinition('Invoke_'+lmem.Name,
                                      Visibility:= CGMemberVisibilityKind.Published,
                                      CallingConvention := CGCallingConventionKind.Register);
    mem.Parameters.Add(new CGParameterDefinition('__EventReceiver', 'TROEventReceiver'.AsTypeReference));
    mem.Parameters.Add(new CGParameterDefinition('__Message', IROMessage_typeref, Modifier := CGParameterModifierKind.Const));
    mem.Parameters.Add(new CGParameterDefinition('__Target', IUnknown_typeref, Modifier := CGParameterModifierKind.Const));


    var lcall := new CGMethodCallExpression(new CGTypeCastExpression('__Target'.AsNamedIdentifierExpression,
                                                                      l_IName_typeref,
                                                                      ThrowsException := true),
                                            lmem.Name,
                                            CallSiteKind:= CGCallSiteKind.Reference);
    for lmemparam in lmem.Items do
      lcall.Parameters.Add(('l_'+lmemparam.Name).AsNamedIdentifierExpression.AsCallParameter);

    if lmem.Items.Count > 0 then begin
      mem.LocalVariables := new List<CGVariableDeclarationStatement>;

      var lNeedDisposer := false;
      for lmemparam in lmem.Items do begin
        lNeedDisposer := isComplex(library, lmemparam.DataType);
        if lNeedDisposer then break;
      end;
      var lObjectDisposer := '__lObjectDisposer'.AsNamedIdentifierExpression;
      if lNeedDisposer then
        mem.LocalVariables:Add(new CGVariableDeclarationStatement('__lObjectDisposer','TROObjectDisposer'.AsTypeReference));

      for lmemparam in lmem.Items do
        mem.LocalVariables:Add(new CGVariableDeclarationStatement('l_'+lmemparam.Name,ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType, Intf_name)));

      for lmemparam in lmem.Items do
        if isComplex(library, lmemparam.DataType) then
          mem.Statements.Add(new CGAssignmentStatement(('l_'+lmemparam.Name).AsNamedIdentifierExpression, CGNilExpression.Nil));

      mem.Statements.Add(new CGEmptyStatement);
      var list:= new List<CGStatement>;
      for lmemparam in lmem.Items do
        list.Add(new CGMethodCallExpression('__Message'.AsNamedIdentifierExpression,
                                            'Read',
                                            [lmemparam.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType,Intf_name)).AsCallParameter,                                            
                                            new CGCallParameter(('l_'+lmemparam.Name).AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                            new CGArrayLiteralExpression().AsCallParameter].ToList,
                                            CallSiteKind:= CGCallSiteKind.Reference));
      list.Add(lcall);
      list.Add(new CGEmptyStatement);
      if lNeedDisposer then begin
        var finList:= new List<CGStatement>;
        var finList2:= new List<CGStatement>;
        var List2:= new List<CGStatement>;
        finList.Add(new CGAssignmentStatement(lObjectDisposer,new CGNewInstanceExpression('TROObjectDisposer'.AsTypeReference,['__EventReceiver'.AsNamedIdentifierExpression.AsCallParameter].ToList)));
        for lmemparam in lmem.Items do
          if isComplex(library, lmemparam.DataType) then
            List2.Add(new CGMethodCallExpression(lObjectDisposer,'Add',[('l_'+lmemparam.Name).AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));

        finList2.Add(new CGDestroyInstanceExpression(lObjectDisposer));
        finList.Add(new CGTryFinallyCatchStatement(List2, FinallyStatements:= finList2));
        mem.Statements.Add(new CGTryFinallyCatchStatement(list, FinallyStatements:= finList));
      end
      else begin
        mem.Statements.AddRange(list);
      end;
    end
    else begin
      mem.Statements.Add(lcall);
    end;
    ltype1.Members.Add(mem);
    {$ENDREGION}
  end;

  {$ENDREGION}


  {$REGION initialization/finalization}
  file.Initialization:Add(new CGMethodCallExpression(nil, 'RegisterEventInvokerClass',
                                                               [l_EID.AsNamedIdentifierExpression.AsCallParameter,
                                                                l_invoker.AsNamedIdentifierExpression.AsCallParameter].ToList));
  file.Finalization:Add(new CGMethodCallExpression(nil,'UnregisterEventInvokerClass',[l_EID.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.isComplex(&library: RodlLibrary; dataType: String): Boolean;
begin
  result := (dataType.ToLowerInvariant in ['binary','xsdatetime']) or
            inherited isComplex(library,dataType);
end;

method DelphiRodlCodeGen.isPresent_SerializeInitializedStructValues_Attribute(&library: RodlLibrary): Boolean;
begin
  Result :=
    library.CustomAttributes_lower.ContainsKey('serializeinitializedstructvalues') and
    (library.CustomAttributes_lower['serializeinitializedstructvalues'] = '1');
end;

method DelphiRodlCodeGen.ProcessAttributes(entity: RodlEntity; &type: CGClassTypeDefinition);
begin
  if entity.CustomAttributes.Count = 0 then exit;
  {$REGION GetAttributeCount}
  &type.Members.Add(new CGMethodDefinition("GetAttributeCount",
                                           [new CGIntegerLiteralExpression(entity.CustomAttributes.Count).AsReturnStatement],
                                            ReturnType := ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                            Virtuality := CGMemberVirtualityKind.Override,
                                            Visibility := CGMemberVisibilityKind.Public,
                                            &Static := true,
                                            CallingConvention := CGCallingConventionKind.Register));
  {$ENDREGION}

  {$REGION GetAttributeName}
  var lcases := new List<CGSwitchStatementCase>;
  for item in entity.CustomAttributes.Keys index i do
    lcases.Add(new CGSwitchStatementCase(new CGIntegerLiteralExpression(i),[CGStatement(item.AsLiteralExpression.AsReturnStatement)].ToList));

  var lcase := new CGSwitchStatement('aIndex'.AsNamedIdentifierExpression, lcases);
  &type.Members.Add(new CGMethodDefinition("GetAttributeName",[lcase],
                        ReturnType := ResolveStdtypes(CGPredefinedTypeKind.String),
                        Parameters := [new CGParameterDefinition('aIndex', ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                        Virtuality := CGMemberVirtualityKind.Override,
                        Visibility := CGMemberVisibilityKind.Public,
                        &Static := true,
                        CallingConvention := CGCallingConventionKind.Register));
  {$ENDREGION}

  {$REGION GetAttributeValue}
  var lcases1 := new List<CGSwitchStatementCase>;
  for item in entity.CustomAttributes.Values index i do
    lcases1.Add(new CGSwitchStatementCase(new CGIntegerLiteralExpression(i),[CGStatement(item.AsLiteralExpression.AsReturnStatement)].ToList));

  lcase := new CGSwitchStatement('aIndex'.AsNamedIdentifierExpression,lcases1);
  &type.Members.Add(new CGMethodDefinition("GetAttributeValue",[lcase],
                                            Parameters := [new CGParameterDefinition('aIndex', ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                                            ReturnType := ResolveStdtypes(CGPredefinedTypeKind.String),
                                            Virtuality := CGMemberVirtualityKind.Override,
                                            Visibility := CGMemberVisibilityKind.Public,
                                            &Static := true,
                                            CallingConvention := CGCallingConventionKind.Register));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Intf_GenerateStructCollection(file: CGCodeUnit; &library: RodlLibrary; entity: RodlStruct);
begin
  var lancestorName := entity.AncestorName;
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, lancestorName + 'Collection',Intf_name,lancestorName)
  else
    lancestor := "TROCollection".AsTypeReference;

  var ltype := new CGClassTypeDefinition(entity.Name+'Collection',
                                         lancestor,
                                         Visibility := CGTypeVisibilityKind.Public
                                         );
  file.Types.Add(ltype);

  var lm: CGMethodLikeMemberDefinition;
  {$REGION protected constructor Create(aItemClass : TCollectionItemClass); overload;}
  lm := new CGConstructorDefinition(
                            Parameters := [new CGParameterDefinition('aItemClass', new CGNamedTypeReference('TCollectionItemClass') isclasstype(false))].ToList,
                            Overloaded := true,
                            Visibility := CGMemberVisibilityKind.Protected,
                            CallingConvention := CGCallingConventionKind.Register
                          );
  ltype.Members.Add(lm);
  lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, ['aItemClass'.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}
  var ltyperef := ResolveDataTypeToTypeRefFullQualified(library, entity.Name,Intf_name);
  {$REGION protected function GetItems(aIndex: Integer): %structtype%}
  lm := new CGMethodDefinition('GetItems',
                          Parameters := [new CGParameterDefinition('aIndex',ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          ReturnType := ltyperef,
                          CallingConvention := CGCallingConventionKind.Register
                          );
  ltype.Members.Add(lm);
  lm.Statements.Add(new CGTypeCastExpression(new CGPropertyAccessExpression(CGInheritedExpression.Inherited,
                                                                            'Items',
                                                                            ['aIndex'.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                                                            CallSiteKind:= CGCallSiteKind.Static),
                                             ltyperef).AsReturnStatement);
  {$ENDREGION}

  {$REGION protected procedure SetItems(aIndex: Integer; const Value: %structtype%);}
  lm := new CGMethodDefinition('SetItems',
                          Parameters := [new CGParameterDefinition('aIndex',ResolveStdtypes(CGPredefinedTypeKind.Int32)),
                                         new CGParameterDefinition('Value', ltyperef,Modifier:= CGParameterModifierKind.Const)].ToList,
                          Visibility := CGMemberVisibilityKind.Protected,
                          CallingConvention := CGCallingConventionKind.Register);
  ltype.Members.Add(lm);
  lm.LocalVariables := new List<CGVariableDeclarationStatement>;
  lm.LocalVariables:&Add(new CGVariableDeclarationStatement('lvalue', ltyperef, new CGTypeCastExpression(
                                                                 new CGPropertyAccessExpression(CGInheritedExpression.Inherited,
                                                                                                'Items',
                                                                                                ['aIndex'.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                                                                                CallSiteKind:= CGCallSiteKind.Static),
                                                                 ltyperef)));
  lm.Statements.Add(new CGMethodCallExpression(
                                        new CGLocalVariableAccessExpression('lvalue'),
                                        'Assign',
                                        ['Value'.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                        CallSiteKind:= CGCallSiteKind.Reference
                                        ));
  {$ENDREGION}

  {$REGION public constructor Create; overload;}
  lm := new CGConstructorDefinition(
                            Overloaded := true,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                          );
  lm.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [cpp_ClassId(entity.Name.AsNamedIdentifierExpression).AsCallParameter].ToList));
  ltype.Members.Add(lm);
  {$ENDREGION}

  {$REGION public function Add: %structtype%; reintroduce;}
  lm := new CGMethodDefinition('Add',
                            ReturnType := ltyperef,
                            Virtuality := CGMemberVirtualityKind.Reintroduce,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                        );
  ltype.Members.Add(lm);
  lm.Statements.Add(new CGTypeCastExpression( new CGMethodCallExpression(CGInheritedExpression.Inherited,'Add',CallSiteKind:= CGCallSiteKind.Static),ltyperef).AsReturnStatement);
  {$ENDREGION}

  var arr := library.Arrays.Items.Where(ar-> ar.ElementType.EqualsIgnoringCaseInvariant(entity.Name)).ToList;
  for mem in arr do begin
    {$REGION public procedure LoadFromArray(anArray: %arraytype%);}
    lm := new CGMethodDefinition('LoadFromArray',
                            Parameters := [new CGParameterDefinition('anArray',ResolveDataTypeToTypeRefFullQualified(library, mem.Name,Intf_name))].ToList,
                            Overloaded := arr.Count>1,
                            Visibility := CGMemberVisibilityKind.Public,
                            
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement('i',ResolveStdtypes(CGPredefinedTypeKind.Int32)));
    lm.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, 'Clear',CallSiteKind:= CGCallSiteKind.Reference));
    var larritem := new CGPropertyAccessExpression(nil,'anArray',['i'.AsNamedIdentifierExpression.AsCallParameter].ToList);
    lm.Statements.Add(new CGForToLoopStatement('i',
                                               ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                               new CGIntegerLiteralExpression(0),
                                               new CGBinaryOperatorExpression(new CGFieldAccessExpression('anArray'.AsNamedIdentifierExpression,'Count',CallSiteKind:= CGCallSiteKind.Reference),
                                                                              new CGIntegerLiteralExpression(1),
                                                                              CGBinaryOperatorKind.Subtraction),
                                               new CGIfThenElseStatement(
                                                                         new CGAssignedExpression(cpp_AddressOf(larritem)),
                                                                         new CGAssignmentStatement(
                                                                                                   new CGFieldAccessExpression(new CGMethodCallExpression(larritem,'Clone',CallSiteKind:= CGCallSiteKind.Instance),'Collection',CallSiteKind:= CGCallSiteKind.Reference),
                                                                                                   CGSelfExpression.Self)
                                                                         )));
    {$ENDREGION}

    {$REGION public procedure SaveToArray(anArray: %arraytype%);}
    lm := new CGMethodDefinition('SaveToArray',
                            Parameters := [new CGParameterDefinition('anArray',ResolveDataTypeToTypeRefFullQualified(library, mem.Name, Intf_name))].ToList,
                            Overloaded := arr.Count>1,
                            Visibility := CGMemberVisibilityKind.Public,
                            CallingConvention := CGCallingConventionKind.Register
                            );
    ltype.Members.Add(lm);
    lm.LocalVariables := new List<CGVariableDeclarationStatement>;
    lm.LocalVariables:Add(new CGVariableDeclarationStatement('i',ResolveStdtypes(CGPredefinedTypeKind.Int32)));
    lm.Statements.Add(new CGMethodCallExpression('anArray'.AsNamedIdentifierExpression, 'Clear',CallSiteKind:= CGCallSiteKind.Reference));
    larritem := new CGPropertyAccessExpression(CGSelfExpression.Self,'Items',['i'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference);

    lm.Statements.Add(new CGForToLoopStatement('i',
                                               ResolveStdtypes(CGPredefinedTypeKind.Int32),
                                               new CGIntegerLiteralExpression(0),
                                               new CGBinaryOperatorExpression(new CGFieldAccessExpression(CGSelfExpression.Self,'Count',CallSiteKind:= CGCallSiteKind.Reference),
                                                                              new CGIntegerLiteralExpression(1),
                                                                              CGBinaryOperatorKind.Subtraction),
                                               new CGIfThenElseStatement(
                                                                         new CGAssignedExpression(larritem),
                                                                         new CGMethodCallExpression('anArray'.AsNamedIdentifierExpression,'Add',[new CGTypeCastExpression(new CGMethodCallExpression(larritem,'Clone',CallSiteKind:= CGCallSiteKind.Reference),ltyperef).AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference),
                                                                         new CGMethodCallExpression('anArray'.AsNamedIdentifierExpression,'Add',[CGNilExpression.Nil.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference)
                                                                         )));

    {$ENDREGION}
  end;

  {$REGION public property Items[Index: Integer]:%structtype% read GetItems write SetItems; default;}
  ltype.Members.Add(new CGPropertyDefinition('Items',
                                    ltyperef,
                                    'GetItems'.AsNamedIdentifierExpression,
                                    'SetItems'.AsNamedIdentifierExpression,
                                    Visibility:= CGMemberVisibilityKind.Public,
                                    Parameters := [new CGParameterDefinition('Index', ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                                    &Default := true));
  {$ENDREGION}
end;

method DelphiRodlCodeGen.AddGlobalConstants(file: CGCodeUnit; &library: RodlLibrary);
begin
  //var lnamespace := GetNamespace(library);

  file.Globals.Add(new CGFieldDefinition("LibraryUID",
                  Constant := true,
                  Visibility := CGMemberVisibilityKind.Public,
                  Initializer := ('{'+library.EntityID.ToString.ToUpperInvariant+'}').AsLiteralExpression).AsGlobal());
  if library.CustomAttributes_lower.ContainsKey('wsdl') then
    file.Globals.Add(new CGFieldDefinition("WSDLLocation",
                    Constant := true,
                    Visibility := CGMemberVisibilityKind.Public,
                    Initializer := ("'"+library.CustomAttributes_lower.Item['wsdl']+"'").AsLiteralExpression).AsGlobal());

  file.Globals.Add(new CGFieldDefinition("DefaultNamespace",
                  Constant := true,
                  Visibility := CGMemberVisibilityKind.Public,
                  Initializer := targetNamespace.AsLiteralExpression).AsGlobal());

  var ltargetnamespace: String := '';
  if library.CustomAttributes_lower.ContainsKey('targetnamespace') then
    ltargetnamespace := library.CustomAttributes_lower.Item['targetnamespace'];
  if String.IsNullOrEmpty(ltargetnamespace ) then ltargetnamespace := targetNamespace;

  file.Globals.Add(new CGFieldDefinition("TargetNamespace",
                  Constant := true,
                  Visibility := CGMemberVisibilityKind.Public,
                  Initializer :=  ltargetnamespace.AsLiteralExpression).AsGlobal());


  for lentity : RodlService in &library.Services.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(lentity) then Continue;
    GlobalsConst_GenerateServerGuid(file, &library,lentity);
  end;

  for lentity : RodlEventSink in &library.EventSinks.Items.Sort_OrdinalIgnoreCase(b->b.Name)  do begin
    if not EntityNeedsCodeGen(lentity) then Continue;
    var lname := lentity.Name;
    file.Globals.Add(new CGFieldDefinition(String.Format("EID_{0}",[lname]), {new CGPredefinedTypeReference(CGPredefinedTypeKind.String),}
                                Constant := true,
                                Visibility := CGMemberVisibilityKind.Public,
                                Initializer := (lentity.Name).AsLiteralExpression).AsGlobal);
  end;

  for lentity : RodlService in &library.Services.Items.Sort_OrdinalIgnoreCase(b->b.Name)  do begin
    if not EntityNeedsCodeGen(lentity) then Continue;
    var lname := lentity.Name;
    if lentity.CustomAttributes_lower.ContainsKey('type') and
       lentity.CustomAttributes_lower['type']:EqualsIgnoringCaseInvariant('SOAP') then begin
      var loc:='';
      if lentity.CustomAttributes_lower.ContainsKey('location') then loc := lentity.CustomAttributes_lower['location'];
      file.Globals.Add(new CGFieldDefinition(String.Format("{0}_EndPointURI",[lname]),
                                              Constant := true,
                                              Visibility := CGMemberVisibilityKind.Public,
                                              Initializer := loc.AsLiteralExpression).AsGlobal);
    end;
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateRead(file: CGCodeUnit; &library: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>;aSerializeInitializedStructValues:Boolean; aSerializer: CGExpression);
begin
  for lmem in ItemList do begin
    var lt1:= new CGFieldAccessExpression(CGSelfExpression.Self, lmem.Name,CallSiteKind:= CGCallSiteKind.Reference);
    var lt2:= new CGFieldAccessExpression(CGSelfExpression.Self, 'int_'+lmem.Name,CallSiteKind:= CGCallSiteKind.Reference);
    var lt3:= ('l_'+lmem.Name).AsNamedIdentifierExpression;
    if isComplex(library, lmem.DataType) and not aSerializeInitializedStructValues then
      aStatements.Add(new CGAssignmentStatement(lt3,lt2))
    else
      aStatements.Add(new CGAssignmentStatement(lt3,lt1));

    var lName := lmem.OriginalName.AsLiteralExpression.AsCallParameter;
    var lValue := ('l_'+ lmem.Name).AsNamedIdentifierExpression.AsCallParameter;
    var lDataType := ResolveDataTypeToTypeRefFullQualified(library, lmem.DataType,Intf_name);
    var trys := new List<CGStatement>;
    trys.AddRange(Intf_generateReadStatement(library,lmem.DataType,aSerializer,lName,lValue,lDataType,nil));
    var lentName: String;
    if not lmem.CustomAttributes_lower.TryGetValue('soapname',out lentName) then lentName := lmem.Name;
    var lexcept := new List<CGCatchBlockStatement>;
    var lexc1 := new CGCatchBlockStatement('E', 'Exception'.AsTypeReference);
{
    var lformat := new CGMethodCallExpression(nil,
                                              'Format',
                                                                                ['Exception "%s" with message "%s" happens during reading field "%s".'.AsLiteralExpression.AsCallParameter,
                                                                                 new CGArrayLiteralExpression([
                                                                            new CGMethodCallExpression('E'.AsNamedIdentifierExpression,'ClassName',CallSiteKind:= CGCallSiteKind.Reference),
                                                                            new CGFieldAccessExpression('E'.AsNamedIdentifierExpression,'Message',CallSiteKind:= CGCallSiteKind.Reference),
                                                                                                              lentName.AsLiteralExpression
                                                                                                              ].ToList).AsCallParameter
                                              ].ToList);
    lexc1.Statements.Add(RaiseError(lformat,nil));
    //lexc1.Statements.Add(new CGMethodCallExpression(nil,'uROClasses.RaiseError',[lformat].ToList));
}
    lexc1.Statements.Add(RaiseError('Exception "%s" with message "%s" happens during reading field "%s".'.AsLiteralExpression,
                         [new CGMethodCallExpression('E'.AsNamedIdentifierExpression,'ClassName',CallSiteKind:= CGCallSiteKind.Reference),
                          new CGFieldAccessExpression('E'.AsNamedIdentifierExpression,'Message',CallSiteKind:= CGCallSiteKind.Reference),
                          lentName.AsLiteralExpression].ToList));
    lexcept.Add(lexc1);
    aStatements.Add(new CGTryFinallyCatchStatement(trys,CatchBlocks := lexcept));
    if isComplex(library,lmem.DataType)  and not isEnum(library,lmem.DataType) then begin
      if aSerializeInitializedStructValues then
        aStatements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(lt1,lt3, CGBinaryOperatorKind.NotEquals), new CGDestroyInstanceExpression(lt1)))
      else
        aStatements.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(lt2,lt3, CGBinaryOperatorKind.NotEquals), new CGDestroyInstanceExpression(lt1)));
    end;
    aStatements.Add(new CGAssignmentStatement(lt1, lt3));
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateWrite(file: CGCodeUnit; &library: RodlLibrary; ItemList: List<RodlField>; aStatements: List<CGStatement>; aSerializeInitializedStructValues: Boolean; aSerializer: CGExpression);
begin
  for lmem in ItemList do begin
    var lt1:= new CGFieldAccessExpression(CGSelfExpression.Self, lmem.Name,CallSiteKind:= CGCallSiteKind.Reference);
    var lt2:= new CGFieldAccessExpression(CGSelfExpression.Self, 'int_'+lmem.Name,CallSiteKind:= CGCallSiteKind.Reference);
    var lt3:= ('l_'+lmem.Name).AsNamedIdentifierExpression;
    if isComplex(library, lmem.DataType) and not aSerializeInitializedStructValues then
      aStatements.Add(new CGAssignmentStatement(lt3,lt2))
    else
      aStatements.Add(new CGAssignmentStatement(lt3,lt1));

    var lName := lmem.OriginalName.AsLiteralExpression.AsCallParameter;
    var lValue := ('l_'+ lmem.Name).AsNamedIdentifierExpression.AsCallParameter;
    var lDataType := ResolveDataTypeToTypeRefFullQualified(library,lmem.DataType,Intf_name);
    aStatements.AddRange(Intf_generateWriteStatement(library,lmem.DataType,aSerializer,lName,lValue,lDataType,nil));
  end;
end;

method DelphiRodlCodeGen.Intf_generateReadStatement(library: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType: CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
begin
  result := new List<CGStatement>;
  aName.Modifier := CGParameterModifierKind.Const;
  aValue.Modifier := CGParameterModifierKind.Var;
  var k: CGMethodCallExpression;
  case aElementType.ToLowerInvariant of
    'integer':    k := new CGMethodCallExpression(aSerializer, 'ReadInteger',[aName, 'otSLong'.AsNamedIdentifierExpression.AsCallParameter,aValue].ToList);
    'datetime':   k := new CGMethodCallExpression(aSerializer, 'ReadDateTime',[aName, aValue].ToList);
    'double':     k := new CGMethodCallExpression(aSerializer, 'ReadDouble',[aName, 'ftDouble'.AsNamedIdentifierExpression.AsCallParameter,aValue].ToList);
    'currency':   k := new CGMethodCallExpression(aSerializer, 'ReadDouble',[aName, 'ftCurr'.AsNamedIdentifierExpression.AsCallParameter,aValue].ToList);
    'ansistring': k := new CGMethodCallExpression(aSerializer, 'ReadAnsiString',[aName, aValue].ToList);
    'utf8string': k := new CGMethodCallExpression(aSerializer, 'ReadUTF8String',[aName, aValue].ToList);
    'int64':      k := new CGMethodCallExpression(aSerializer, 'ReadInt64',[aName, aValue].ToList);
    'boolean':    k := new CGMethodCallExpression(aSerializer, 'ReadEnumerated',[aName,GenerateTypeInfoCall(library,ResolveStdtypes(CGPredefinedTypeKind.Boolean)).AsCallParameter,aValue].ToList);
    'variant':    k := new CGMethodCallExpression(aSerializer, 'ReadVariant',[aName, aValue].ToList);
    'binary':     k := new CGMethodCallExpression(aSerializer, 'ReadBinary',[aName, aValue].ToList);
    'xml':        k := new CGMethodCallExpression(aSerializer, 'ReadXml',[aName, aValue].ToList);
    'guid':       k := new CGMethodCallExpression(aSerializer, 'ReadGuid',[aName, aValue].ToList);
    'decimal':    k := new CGMethodCallExpression(aSerializer, 'ReadDecimal',[aName, aValue].ToList);
    'xsdatetime': k := new CGMethodCallExpression(aSerializer, 'ReadStruct',[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList);
    'widestring': k := new CGMethodCallExpression(aSerializer, 'ReadUnicodeString',[aName, aValue].ToList, CallSiteKind := CGCallSiteKind.Reference);
  else
    if isArray(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'ReadArray',[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList)
    else if isStruct(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'ReadStruct',[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList)
    else if isException(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'ReadException',[aName, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter, aValue].ToList)
    else if isEnum(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'ReadEnumerated',
                                                                                                            [aName,
                                                                                                            GenerateTypeInfoCall(library,aDataType).AsCallParameter,
                                                                                                            aValue].ToList)
    else 
      raise new Exception(String.Format("unknown type: {0}",[aElementType]));
  end;
  if assigned(aIndex) then k.Parameters.Add(aIndex);
  k.CallSiteKind := CGCallSiteKind.Reference;
  result.Add(k);
end;

method DelphiRodlCodeGen.Intf_generateWriteStatement(library: RodlLibrary; aElementType: String; aSerializer: CGExpression; aName, aValue:CGCallParameter; aDataType: CGTypeReference; aIndex: CGCallParameter): List<CGStatement>;
begin
  result := new List<CGStatement>;
  aName.Modifier := CGParameterModifierKind.Const;
  aValue.Modifier := CGParameterModifierKind.Var; //c++ builder should pass it by reference
  var k: CGMethodCallExpression;
  case aElementType.ToLowerInvariant of
    'integer':    k := new CGMethodCallExpression(aSerializer, 'WriteInteger',[aName, 'otSLong'.AsNamedIdentifierExpression.AsCallParameter,aValue].ToList);
    'datetime':   k := new CGMethodCallExpression(aSerializer, 'WriteDateTime',[aName, aValue].ToList);
    'double':     k := new CGMethodCallExpression(aSerializer, 'WriteDouble',[aName, 'ftDouble'.AsNamedIdentifierExpression.AsCallParameter,aValue].ToList);
    'currency':   k := new CGMethodCallExpression(aSerializer, 'WriteDouble',[aName, 'ftCurr'.AsNamedIdentifierExpression.AsCallParameter,aValue].ToList);
    'ansistring': k := new CGMethodCallExpression(aSerializer, 'WriteAnsiString',[aName, aValue].ToList);
    'utf8string': k := new CGMethodCallExpression(aSerializer, 'WriteUTF8String',[aName, aValue].ToList);
    'int64':      k := new CGMethodCallExpression(aSerializer, 'WriteInt64',[aName, aValue].ToList);
    'boolean':    k := new CGMethodCallExpression(aSerializer, 'WriteEnumerated',[aName, GenerateTypeInfoCall(library,ResolveStdtypes(CGPredefinedTypeKind.Boolean)).AsCallParameter,aValue].ToList);
    'variant':    k := new CGMethodCallExpression(aSerializer, 'WriteVariant',[aName, aValue].ToList);
    'binary':     k := new CGMethodCallExpression(aSerializer, 'WriteBinary',[aName, aValue].ToList);
    'xml':        k := new CGMethodCallExpression(aSerializer, 'WriteXml',[aName, aValue].ToList);
    'guid':       k := new CGMethodCallExpression(aSerializer, 'WriteGuid',[aName, aValue].ToList);
    'decimal':    k := new CGMethodCallExpression(aSerializer, 'WriteDecimal',[aName, aValue].ToList);
    'xsdatetime': k := new CGMethodCallExpression(aSerializer, 'WriteStruct',[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList);
    'widestring': k := new CGMethodCallExpression(aSerializer, 'WriteUnicodeString',[aName, aValue].ToList,CallSiteKind := CGCallSiteKind.Reference);
  else
    if isArray(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'WriteArray',[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList)
    else if isStruct(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'WriteStruct',[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList)
    else if isException(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'WriteException',[aName, aValue, cpp_ClassId(DuplicateType(aDataType, false).AsExpression).AsCallParameter].ToList)
    else if isEnum(library,aElementType) then k := new CGMethodCallExpression(aSerializer, 'WriteEnumerated',[aName,
                                                                                                              GenerateTypeInfoCall(library,aDataType).AsCallParameter,
                                                                                                              aValue].ToList);
  end;
  if assigned(aIndex) then k.Parameters.Add(aIndex);
  k.CallSiteKind := CGCallSiteKind.Reference;
  result.Add(k);
end;

method DelphiRodlCodeGen.ResolveNamespace(&library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String := '';aCapitalize: Boolean := False): String;
begin
  try
    if not (IncludeUnitNameForOtherTypes or IncludeUnitNameForOwnTypes) then exit '';
    if String.IsNullOrEmpty(aOrigDataType) then aOrigDataType := dataType;
    if not assigned(library) then exit '';
    var entity: RodlEntity := library.FindEntity(aOrigDataType);
    if assigned(entity) then begin
      if entity.IsFromUsedRodl and IncludeUnitNameForOtherTypes then begin
        var suffix: String;
        case aDefaultUnitName of
          Intf_name: suffix := 'intf';
          Invk_name: suffix := 'invk';
          Impl_name: suffix := 'impl';
        end;
        if String.IsNullOrEmpty(entity.FromUsedRodl:Includes:DelphiModule) then begin
          if CanUseNameSpace and not String.IsNullOrEmpty(entity.FromUsedRodl:&Namespace) then
            exit entity.FromUsedRodl:&Namespace
          else
            if CanUseNameSpace then 
              exit entity.FromUsedRodl.Name   //c++builder
            else
              exit entity.FromUsedRodl.Name + '_'+suffix; //delphi
        end
        else begin
          aCapitalize := True; // delphi rodl is detected!
          exit entity.FromUsedRodl:Includes:DelphiModule + '_'+suffix;
        end;
      end
      else
        if IncludeUnitNameForOwnTypes then begin
          if CanUseNameSpace then
            exit targetNamespace
          else
            exit aDefaultUnitName;
        end
        else
          exit '';
    end
    else begin
      exit '';
    end;
  finally
    // C++ Builder
    if (CanUseNameSpace) and not String.IsNullOrEmpty(result) and aCapitalize then begin
      result := CapitalizeString(result);
    end;
  end;
end;

method DelphiRodlCodeGen.ResolveDataTypeToTypeRefFullQualified(&library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String := '';aCapitalize: Boolean := False): CGTypeReference;
begin

  var ltype := iif(String.IsNullOrEmpty(aOrigDataType), dataType, aOrigDataType);
  var lLower := ltype.ToLowerInvariant();
  if  CodeGenTypes.ContainsKey(lLower) then
    exit CodeGenTypes[lLower]
  else begin
    var namesp := ResolveNamespace(library,dataType,aDefaultUnitName,aOrigDataType,aCapitalize);
    if String.IsNullOrEmpty(namesp) then
      exit new CGNamedTypeReference(dataType)
                              isClassType(isComplex(library, ltype))
    else
      exit new CGNamedTypeReference(dataType)
                              &namespace(new CGNamespaceReference(namesp))
                              isClassType(isComplex(library, ltype));
  end;
end;

method DelphiRodlCodeGen.GenerateInvokerFile(&library: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  exit Generator.GenerateUnit(GenerateInvokerCodeUnit(library, aTargetNamespace, aUnitName));
end;

{$REGION generate _Invk}

method DelphiRodlCodeGen.Invk_GenerateService(file: CGCodeUnit; &library: RodlLibrary; entity: RodlService);
begin
  var l_EntityName := entity.Name;
  var l_Iname := 'I'+l_EntityName;
  var l_TInvoker := 'T'+l_EntityName+'_Invoker';

  var lancestorName := entity.AncestorName;
  var lancestor: CGTypeReference := nil;
  {$REGION T%service%_Invoker}
  if not String.IsNullOrEmpty(lancestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'T'+lancestorName+'_Invoker',Invk_name,lancestorName)
  else
    lancestor := 'TROInvoker'.AsTypeReference;
  var ltype := new CGClassTypeDefinition(l_TInvoker,lancestor,
                                             Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(ltype);

  var mem: CGMethodLikeMemberDefinition;
  {$REGION public  constructor Create; override;}
  mem := new CGConstructorDefinition(
                                    Visibility :=  CGMemberVisibilityKind.Public,
                                    Virtuality := CGMemberVirtualityKind.Override,
                                    CallingConvention := CGCallingConventionKind.Register);
  mem.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));
  mem.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(nil,'FAbstract'),new CGBooleanLiteralExpression(entity.Abstract)));
  ltype.Members.Add(mem);
  {$ENDREGION}
  var TStringArray_typeref := new CGNamedTypeReference('TStringArray') isclasstype(false);
  {$REGION protected function GetDefaultServiceRoles: TStringArray; override;}
  if entity.Roles.Roles.Count >0 then begin
    mem := new CGMethodDefinition('GetDefaultServiceRoles',
                                      ReturnType := TStringArray_typeref,
                                      Visibility :=  CGMemberVisibilityKind.Protected,
                                      Virtuality := CGMemberVirtualityKind.Override,
                                      CallingConvention := CGCallingConventionKind.Register);
    ltype.Members.Add(mem);
    var ar := new CGArrayLiteralExpression(ElementType := ResolveStdtypes(CGPredefinedTypeKind.String));
    for lr in entity.Roles.Roles do
      ar.Elements.Add((iif(lr.Not,'!','')+ lr.Role).AsLiteralExpression);
    Invk_GetDefaultServiceRoles(CGMethodDefinition(mem), ar);
  end;
  {$ENDREGION}
  {$REGION service methods}
  var plist := new List<CGParameterDefinition>;
  var TROResponseOptions_typeref := new CGNamedTypeReference('TROResponseOptions') isClasstype(False);
  var TParamAttributes_typeref := new CGNamedTypeReference('TParamAttributes') isClasstype(False);

  plist.Add(new CGParameterDefinition('__Instance',ResolveInterfaceTypeRef(nil, 'IInterface','System'), Modifier:= CGParameterModifierKind.Const));
  plist.Add(new CGParameterDefinition('__Message', IROMessage_typeref, Modifier:= CGParameterModifierKind.Const));
  plist.Add(new CGParameterDefinition('__Transport', IROTransport_typeref, Modifier:= CGParameterModifierKind.Const));
  plist.Add(new CGParameterDefinition('__oResponseOptions', TROResponseOptions_typeref, Modifier:= CGParameterModifierKind.Out));
  var lMessage := '__Message'.AsNamedIdentifierExpression;
  var sa :CGSetLiteralExpression;
  for lmem in entity.DefaultInterface.Items do begin

    mem := new CGMethodDefinition('Invoke_'+lmem.Name,
                                  Parameters:= plist,
                                  Visibility:= CGMemberVisibilityKind.Published,
                                  CallingConvention := CGCallingConventionKind.Register);
    var lHasObjectDisposer := False;
    for lmemparam in lmem.Items do begin
      lHasObjectDisposer:= isComplex(library, lmemparam.DataType);
      if lHasObjectDisposer then break;
    end;
    if assigned(lmem.Result) and isComplex(library, lmem.Result:DataType) then lHasObjectDisposer := true;
   // if (lmem.Count>0) or assigned(lmem.Result) or lHasObjectDisposer then
    mem.LocalVariables := new List<CGVariableDeclarationStatement>;
    for lmemparam in lmem.Items do begin
      var dt := ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType,Intf_name);
      mem.LocalVariables:Add(new CGVariableDeclarationStatement('l_'+lmemparam.Name,dt));
      if (lmemparam.ParamFlag = ParamFlags.InOut) and isComplex(library, lmemparam.DataType) then
        mem.LocalVariables:Add(new CGVariableDeclarationStatement('__in_'+lmemparam.Name,dt));
    end;
    if assigned(lmem.Result) then begin
      var dt := ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType,Intf_name);
      mem.LocalVariables:Add(new CGVariableDeclarationStatement('lResult',dt));
    end;
    if lHasObjectDisposer then
      mem.LocalVariables:Add(new CGVariableDeclarationStatement('__lObjectDisposer','TROObjectDisposer'.AsTypeReference));

    var ar := new CGArrayLiteralExpression(ElementType := ResolveStdtypes(CGPredefinedTypeKind.String));
    if lmem.Roles.Roles.Count >0 then
      for lr in lmem.Roles.Roles do
        ar.Elements.Add((iif(lr.Not,'!','')+ lr.Role).AsLiteralExpression);

    Invk_CheckRoles(CGMethodDefinition(mem),ar);
    
    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(library, entity, lmem,out p1, out p2);
    if p1.Count > 0 then begin
      mem.Statements.Add(new CGMethodCallExpression(lMessage,'SetAttributes',['__Transport'.AsNamedIdentifierExpression.AsCallParameter,
                                                                              new CGArrayLiteralExpression(p1).AsCallParameter,
                                                                              new CGArrayLiteralExpression(p2).AsCallParameter].ToList,
                                                    CallSiteKind:= CGCallSiteKind.Reference));
    end;
    for lmemparam in lmem.Items do begin
      if isComplex(library, lmemparam.DataType) then begin
        mem.Statements.Add(new CGAssignmentStatement(('l_'+lmemparam.Name).AsNamedIdentifierExpression,CGNilExpression.Nil));
        if (lmemparam.ParamFlag = ParamFlags.InOut) then
          mem.Statements.Add(new CGAssignmentStatement(('__in_'+lmemparam.Name).AsNamedIdentifierExpression,CGNilExpression.Nil));
      end;
    end;
    if assigned(lmem.Result) and isComplex(library, lmem.Result.DataType) then
      mem.Statements.Add(new CGAssignmentStatement('lResult'.AsNamedIdentifierExpression,CGNilExpression.Nil));


    mem.LocalVariables:&Add(new CGVariableDeclarationStatement('__lintf', ResolveInterfaceTypeRef(library,l_Iname,Intf_name,l_EntityName)));

    var lcast := InterfaceCast('__Instance'.AsNamedIdentifierExpression,
                               l_Iname.AsNamedIdentifierExpression,
                               '__lintf'.AsNamedIdentifierExpression);

    var ltry:= new List<CGStatement>;
    var lfin:= new List<CGStatement>;
    ltry.Add(new CGIfThenElseStatement(
                  new CGUnaryOperatorExpression(lcast,CGUnaryOperatorKind.Not),
                  new CGThrowStatement(new CGNewInstanceExpression('EIntfCastError'.AsNamedIdentifierExpression,
                                              [String.Format('Critical error in {0}.{1}: __Instance does not support {2} interface',[l_TInvoker,mem.Name,l_EntityName]).AsLiteralExpression.AsCallParameter]))));
    ltry.Add(new CGEmptyStatement);
    for lmemparam in lmem.Items do begin
      if (lmemparam.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if lmemparam.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Add(new CGMethodCallExpression(lMessage,
                                            'Read',
                                            [lmemparam.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType,Intf_name)).AsCallParameter,
                                            new CGCallParameter(('l_'+lmemparam.Name).AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                            sa.AsCallParameter].ToList,
                                            CallSiteKind:= CGCallSiteKind.Reference));

        if (lmemparam.ParamFlag = ParamFlags.InOut) and isComplex(library, lmemparam.DataType) then
           ltry.Add(new CGAssignmentStatement(('__in_'+lmemparam.Name).AsNamedIdentifierExpression,('l_'+lmemparam.Name).AsNamedIdentifierExpression));
      end;
    end;
    if lmem.Count>0 then ltry.Add(new CGEmptyStatement);
    //var k := new CGMethodCallExpression(new CGTypeCastExpression('__Instance'.AsNamedIdentifierExpression,l_Iname.AsTypeReference,ThrowsException:=True),lmem.Name,CallSiteKind:= CGCallSiteKind.Reference);
    var k := new CGMethodCallExpression('__lintf'.AsNamedIdentifierExpression,lmem.Name,CallSiteKind:= CGCallSiteKind.Reference);
    if assigned(lmem.Result) then
      ltry.Add(new CGAssignmentStatement('lResult'.AsNamedIdentifierExpression,k))
    else
      ltry.Add(k);
    for lmemparam in lmem.Items do
      if lmemparam.ParamFlag <> ParamFlags.Result then
        k.Parameters.Add(('l_'+lmemparam.Name).AsNamedIdentifierExpression.AsCallParameter);
    ltry.Add(new CGEmptyStatement);
    ltry.Add(new CGMethodCallExpression(lMessage,
                                        'InitializeResponseMessage',
                                        ['__Transport'.AsNamedIdentifierExpression.AsCallParameter,
                                        iif(library.DataSnap,'',library.Name).AsLiteralExpression.AsCallParameter,
                                        iif(library.DataSnap,l_Iname,l_EntityName).AsLiteralExpression.AsCallParameter,
                                        (lmem.Name+'Response').AsLiteralExpression.AsCallParameter
                                        ].ToList,
                                        CallSiteKind:= CGCallSiteKind.Reference));
    {$REGION ! DataSnap}
    if not library.DataSnap then
      if assigned(lmem.Result) then begin
        sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if lmem.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Add(new CGMethodCallExpression(lMessage,
                                            'Write',
                                            [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                            new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                            sa.AsCallParameter].ToList,
                                            CallSiteKind:= CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for lmemparam in lmem.Items do begin
      if (lmemparam.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if lmemparam.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Add(new CGMethodCallExpression(lMessage,
                                            'Write',
                                            [lmemparam.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType,Intf_name)).AsCallParameter,
                                            new CGCallParameter(('l_'+lmemparam.Name).AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                            sa.AsCallParameter].ToList,
                                            CallSiteKind:= CGCallSiteKind.Reference));

      end;
    end;
    {$REGION DataSnap}
    if library.DataSnap then
      if assigned(lmem.Result) then begin
        sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if lmem.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Add(new CGMethodCallExpression(lMessage,
                                            'Write',
                                            [lmem.Result.Name.AsLiteralExpression.AsCallParameter,
                                            GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType,Intf_name)).AsCallParameter,
                                            new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                            sa.AsCallParameter].ToList,
                                            CallSiteKind:= CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    ltry.Add(new CGMethodCallExpression(lMessage,'Finalize',CallSiteKind:= CGCallSiteKind.Reference));
    ltry.Add(new CGMethodCallExpression(lMessage,'UnsetAttributes',['__Transport'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    ltry.Add(new CGEmptyStatement);


    if not NeedsAsyncRetrieveOperationDefinition(lmem) then begin
      ltry.Add(new CGAssignmentStatement('__oResponseOptions'.AsNamedIdentifierExpression, new CGSetLiteralExpression([CGExpression('roNoResponse'.AsNamedIdentifierExpression)].ToList,TROResponseOptions_typeref)));
      ltry.Add(new CGEmptyStatement);
    end;

    lfin.Add(new CGAssignmentStatement('__lintf'.AsNamedIdentifierExpression, CGNilExpression.Nil));
    if lHasObjectDisposer then begin
      var ltry2:=new  List<CGStatement>;
      var lfin2:=new  List<CGStatement>;
      var lObjectDisposer := '__lObjectDisposer'.AsNamedIdentifierExpression;
      lfin.Add(new CGAssignmentStatement(lObjectDisposer,new CGNewInstanceExpression('TROObjectDisposer'.AsTypeReference,['__Instance'.AsNamedIdentifierExpression.AsCallParameter].ToList)));

      for lmemparam in lmem.Items do
        if isComplex(library, lmemparam.DataType) then begin
          if lmemparam.ParamFlag = ParamFlags.InOut then
            ltry2.Add(new CGMethodCallExpression(lObjectDisposer,'Add',[('__in_'+lmemparam.Name).AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
          ltry2.Add(new CGMethodCallExpression(lObjectDisposer,'Add',[('l_'+lmemparam.Name).AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
        end;
      if assigned(lmem.Result) then
        if isComplex(library,lmem.Result.DataType) then
          ltry2.Add(new CGMethodCallExpression(lObjectDisposer,'Add',['lResult'.AsNamedIdentifierExpression.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));


      lfin2.Add(new CGDestroyInstanceExpression(lObjectDisposer));
      lfin.Add(new CGTryFinallyCatchStatement(ltry2, FinallyStatements:= lfin2));
    end;

    mem.Statements.Add(new CGTryFinallyCatchStatement(ltry, FinallyStatements:= lfin));
    ltype.Members.Add(mem);
  end;
  {$ENDREGION}
  {$ENDREGION}
  {$REGION initialization}
  for latr in entity.CustomAttributes.Keys do begin
    file.Initialization.Add(new CGMethodCallExpression(nil, 'RegisterServiceAttribute',[
                                                                      l_EntityName.AsLiteralExpression.AsCallParameter,
                                                                      latr.AsLiteralExpression.AsCallParameter,
                                                                      entity.CustomAttributes[latr].AsLiteralExpression.AsCallParameter].ToList));
  end;
  {$ENDREGION}
end;

method DelphiRodlCodeGen.Invk_GenerateEventSink(file: CGCodeUnit; &library: RodlLibrary; entity: RodlEventSink);
begin
  var l_EntityName := entity.Name;
  var l_Twriter := 'T'+l_EntityName+'_Writer';
  var l_IWriter := 'I'+l_EntityName+'_Writer';
  var l_EID := 'EID_'+l_EntityName;

  {$REGION I%eventsink%_Writer}
  var lancestor: CGTypeReference;
  if not String.IsNullOrEmpty(entity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'I'+entity.AncestorName+'_Writer',Invk_name,entity.AncestorName)
  else
    lancestor := 'IROEventWriter'.AsTypeReference;

  var ltype := new CGInterfaceTypeDefinition(l_IWriter, lancestor);

  ltype.InterfaceGuid := entity.DefaultInterface.EntityID;
  file.Types.Add(ltype);

  for lmem in entity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      CallingConvention := CGCallingConventionKind.Register);
    mem.Parameters.Add(new CGParameterDefinition('__Sender', 'TGUID'.AsTypeReference,Modifier := CGParameterModifierKind.Const));
    for lmemparam in lmem.Items do begin
      if lmemparam.ParamFlag <> ParamFlags.Result then
        mem.Parameters.Add(new CGParameterDefinition(lmemparam.Name, ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType, Intf_name),Modifier := RODLParamFlagToCodegenFlag(lmemparam.ParamFlag)));
    end;
    if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType, Intf_name);
    ltype.Members.Add(mem);
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION T%eventsink%_Writer}
  if not String.IsNullOrEmpty(entity.AncestorName) then
    lancestor := ResolveDataTypeToTypeRefFullQualified(library, 'T'+entity.AncestorName+'_Writer',Intf_name,entity.AncestorName)
  else
    lancestor := 'TROEventWriter'.AsTypeReference;
  var ltype1 := new CGClassTypeDefinition(l_Twriter,
                                          lancestor,
                                          [ResolveDataTypeToTypeRefFullQualified(library, l_IWriter, Invk_name, l_EntityName)].ToList,
                                          Visibility := CGTypeVisibilityKind.Unit);
  file.Types.Add(ltype1);

  for lmem in entity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      Visibility := CGMemberVisibilityKind.Protected,
                                      CallingConvention := CGCallingConventionKind.Register);
    mem.Parameters.Add(new CGParameterDefinition('__Sender', 'TGUID'.AsTypeReference, Modifier := CGParameterModifierKind.Const));
    for lmemparam in lmem.Items do begin
      if lmemparam.ParamFlag <> ParamFlags.Result then
        mem.Parameters.Add(new CGParameterDefinition(lmemparam.Name, ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType, Intf_name),Modifier := RODLParamFlagToCodegenFlag(lmemparam.ParamFlag)));
    end;
    if assigned(lmem.Result) then mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType, Intf_name);
    ltype1.Members.Add(mem);
    mem.LocalVariables := new List<CGVariableDeclarationStatement>;
    var lbinarytype := ResolveDataTypeToTypeRefFullQualified(library,'Binary', Intf_name);
    mem.LocalVariables:Add(new CGVariableDeclarationStatement('__eventdata',lbinarytype));
    mem.LocalVariables:Add(new CGVariableDeclarationStatement('lMessage',IROMessage_typeref));
    var l__eventdata  := '__eventdata'.AsNamedIdentifierExpression;
    var lmessage := 'lMessage'.AsNamedIdentifierExpression;
    mem.Statements.Add(new CGAssignmentStatement(l__eventdata, new CGNewInstanceExpression(lbinarytype)));
    mem.Statements.Add(new CGAssignmentStatement(lmessage,new CGFieldAccessExpression(nil,'__Message')));
    var ltry := new List<CGStatement>;
    var lfin := new List<CGStatement>;
    ltry.Add(new CGMethodCallExpression(lmessage,'InitializeEventMessage',[CGNilExpression.Nil.AsCallParameter,
                                                                           library.Name.AsLiteralExpression.AsCallParameter,
                                                                           l_EID.AsNamedIdentifierExpression.AsCallParameter,
                                                                           lmem.Name.AsLiteralExpression.AsCallParameter].ToList,
                                        CallSiteKind:= CGCallSiteKind.Reference));
    for lmemparam in lmem.Items do begin
      ltry.Add(new CGMethodCallExpression(lmessage,
                                          'Write',
                                          [lmemparam.Name.AsLiteralExpression.AsCallParameter,
                                          GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,lmemparam.DataType,Intf_name)).AsCallParameter,
                                          new CGCallParameter(lmemparam.Name.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                          new CGArrayLiteralExpression().AsCallParameter].ToList,
                                          CallSiteKind:= CGCallSiteKind.Reference));
    end;
    ltry.Add(new CGMethodCallExpression(lmessage,'Finalize',CallSiteKind:= CGCallSiteKind.Reference));
    ltry.Add(new CGEmptyStatement);
    ltry.Add(new CGMethodCallExpression(lmessage,'WriteToStream',[l__eventdata.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    ltry.Add(new CGEmptyStatement);
    ltry.Add(new CGMethodCallExpression(new CGFieldAccessExpression(nil,'Repository'),
                                        'StoreEventData',
                                        ['__Sender'.AsNamedIdentifierExpression.AsCallParameter,
                                         l__eventdata.AsCallParameter,
                                         new CGFieldAccessExpression(nil,'ExcludeSender').AsCallParameter,
                                         new CGFieldAccessExpression(nil,'ExcludeSessionList').AsCallParameter,
                                         new CGFieldAccessExpression(new CGFieldAccessExpression(nil,'SessionList'),'CommaText',CallSiteKind:= CGCallSiteKind.Reference).AsCallParameter,
                                         l_EID.AsNamedIdentifierExpression.AsCallParameter].ToList,
                                        CallSiteKind:= CGCallSiteKind.Reference));

    lfin.Add(new CGMethodCallExpression(l__eventdata,'Free',CallSiteKind:= CGCallSiteKind.Reference));
    lfin.Add(new CGAssignmentStatement(lmessage,CGNilExpression.Nil));

    mem.Statements.Add(new CGTryFinallyCatchStatement(ltry, FinallyStatements:=lfin));
    {$ENDREGION}
  end;
  {$ENDREGION}

  {$REGION initialization/finalization}
  file.Initialization:Add(new CGMethodCallExpression(nil, 'RegisterEventWriterClass',
                                                               [l_IWriter.AsNamedIdentifierExpression.AsCallParameter,
                                                                l_Twriter.AsNamedIdentifierExpression.AsCallParameter].ToList));
  file.Finalization:Add(new CGMethodCallExpression(nil,'UnregisterEventWriterClass',[l_IWriter.AsNamedIdentifierExpression.AsCallParameter].ToList));
  {$ENDREGION}

end;

method DelphiRodlCodeGen.NeedsAsyncRetrieveOperationDefinition(entity: RodlOperation): Boolean;
begin
  Result := assigned(entity.Result) or (entity.ForceAsyncResponse);
  if not Result then
    for lm in entity.Items do begin
      result:= lm.ParamFlag <> ParamFlags.In;
      if result then exit;
    end;
end;

method DelphiRodlCodeGen.Invk_GetDefaultServiceRoles(&method: CGMethodDefinition; roles: CGArrayLiteralExpression);
begin
  var mce := new CGMethodCallExpression(nil,
                                        'CombineStringArrays',
                                        [new CGMethodCallExpression(CGInheritedExpression.Inherited,'GetDefaultServiceRoles').AsCallParameter,
                                        roles.AsCallParameter].ToList);
  &method.Statements.Add(mce.AsReturnStatement);
end;

method DelphiRodlCodeGen.Invk_CheckRoles(&method: CGMethodDefinition; roles: CGArrayLiteralExpression);
begin
  var l__Instance := '__Instance'.AsNamedIdentifierExpression;
  var mce := new CGMethodCallExpression(nil,'CheckRoles',[l__Instance.AsCallParameter].ToList);
  var GetDefaultServiceRoles := new CGMethodCallExpression(nil,'GetDefaultServiceRoles').AsCallParameter;
  if roles.Elements.Count >0 then begin
    mce.Parameters.Add(new CGMethodCallExpression(nil,
                                                  'CombineStringArrays',
                                                  [GetDefaultServiceRoles,
                                                  roles.AsCallParameter].ToList).AsCallParameter);
  end
  else begin
    mce.Parameters.Add(GetDefaultServiceRoles);
  end;
  &method.Statements.Add(mce);
end;
{$ENDREGION}

method DelphiRodlCodeGen.GenerateAttributes(&library: RodlLibrary; service: RodlService; operation: RodlOperation; out aNames: List<CGExpression>; out aValues: List<CGExpression>);
begin
  aNames := new List<CGExpression>;
  aValues := new List<CGExpression>;

  var lsa := new Dictionary<String,String>;
  var lsa_lower := new Dictionary<String,String>;
  for li in operation.CustomAttributes.Keys do
    if not lsa_lower.ContainsKey(li.ToLowerInvariant) then begin
      lsa.Add(li, operation.CustomAttributes[li]);
      lsa_lower.Add(li.ToLowerInvariant, operation.CustomAttributes[li]);
    end;
  for li in service.CustomAttributes.Keys do
    if not lsa_lower.ContainsKey(li.ToLowerInvariant) then begin
      lsa.Add(li, service.CustomAttributes[li]);
      lsa_lower.Add(li.ToLowerInvariant, service.CustomAttributes[li]);
    end;
  for li in library.CustomAttributes.Keys do
    if not lsa_lower.ContainsKey(li.ToLowerInvariant) then begin
      lsa.Add(li, library.CustomAttributes[li]);
      lsa_lower.Add(li.ToLowerInvariant, library.CustomAttributes[li]);
    end;

  var lsa1 := new Dictionary<String,String>;
  for li in lsa.Keys.OrderBy(b->b) do
    lsa1.Add(li, lsa[li]);
  for li in lsa1.Keys do begin
    aNames.Add(li.AsLiteralExpression);
    if li.EqualsIgnoringCaseInvariant('TargetNamespace') then aValues.Add('TargetNamespace'.AsNamedIdentifierExpression)
    else if li.EqualsIgnoringCaseInvariant('Wsdl') then aValues.Add('WSDLLocation'.AsNamedIdentifierExpression)
    else aValues.Add(lsa1[li].AsLiteralExpression);
  end;
end;

{$REGION generate _Async}


method DelphiRodlCodeGen.Intf_GenerateAsyncInvoke(&library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody:  Boolean): CGMethodDefinition;
begin
  var TParamAttributes_typeref := new CGNamedTypeReference('TParamAttributes') isClasstype(False);

  result := new CGMethodDefinition('Invoke_'+operation.Name,
                                    Visibility := CGMemberVisibilityKind.Protected,
                                    CallingConvention := CGCallingConventionKind.Register
                                    {Virtuality := CGMemberVirtualityKind.Virtual});
  for mem in operation.Items do begin
    if mem.ParamFlag in [ParamFlags.In, ParamFlags.InOut] then begin
      var lparam := new CGParameterDefinition(mem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(library,mem.DataType, Intf_name));
      if isComplex(library, mem.DataType) and (mem.ParamFlag = ParamFlags.In) then
        lparam.Type := new CGConstantTypeReference(lparam.Type)
      else
        lparam.Modifier := RODLParamFlagToCodegenFlag(mem.ParamFlag);
      result.Parameters.Add(lparam);
    end;
  end;
  if aNeedBody then begin
    var lMessage := 'lMessage'.AsNamedIdentifierExpression;
    var lTransportChannel := 'lTransportChannel'.AsNamedIdentifierExpression;
    result.LocalVariables := new List<CGVariableDeclarationStatement>;
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lMessage",IROMessage_typeref));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref));
    result.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, '__GetMessage')));
    result.Statements.Add(new CGMethodCallExpression(lMessage,'SetAutoGeneratedNamespaces',[new CGMethodCallExpression(nil,'DefaultNamespaces').AsCallParameter]));
    result.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGFieldAccessExpression(nil, '__TransportChannel')));
    var ltry:=new CGTryFinallyCatchStatement();
    ////
    ltry.Statements.Add(new CGMethodCallExpression(nil,'__AssertProxyNotBusy',[operation.Name.AsLiteralExpression.AsCallParameter].ToList));
    ltry.Statements.Add(new CGEmptyStatement);
    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(library, entity, operation,out p1, out p2);
    if p1.Count > 0 then begin
      ltry.Statements.Add(new CGMethodCallExpression(lMessage,'SetAttributes',[lTransportChannel.AsCallParameter,
                                                                              new CGArrayLiteralExpression(p1).AsCallParameter,
                                                                              new CGArrayLiteralExpression(p2).AsCallParameter].ToList,
                                                                              CallSiteKind:= CGCallSiteKind.Reference));
    end;
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                    'InitializeRequestMessage',
                                                    [lTransportChannel.AsCallParameter,
                                                    iif(library.DataSnap,'',library.Name).AsLiteralExpression.AsCallParameter,
                                                    '__InterfaceName'.AsNamedIdentifierExpression.AsCallParameter,
                                                    operation.Name.AsLiteralExpression.AsCallParameter
                                                    ].ToList,
                                                    CallSiteKind:= CGCallSiteKind.Reference));
    for litem in operation.Items do begin
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if litem.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        'Write',
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGCallParameter(litem.Name.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                        sa.AsCallParameter].ToList,
                                                        CallSiteKind:= CGCallSiteKind.Reference));

      end;
    end;

    var ld := new CGMethodCallExpression(nil,'__DispatchAsyncRequest', [operation.Name.AsLiteralExpression.AsCallParameter,lMessage.AsCallParameter].ToList);
    if not NeedsAsyncRetrieveOperationDefinition(operation) then
      ld.Parameters.Add(new CGBooleanLiteralExpression(false).AsCallParameter);
    ltry.Statements.Add(ld);
    ltry.FinallyStatements.Add(new CGMethodCallExpression(lMessage,'UnsetAttributes',[lTransportChannel.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    result.Statements.Add(ltry);
  end;
end;

method DelphiRodlCodeGen.Intf_GenerateAsyncRetrieve(&library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody:  Boolean): CGMethodDefinition;
begin
  var TParamAttributes_typeref := new CGNamedTypeReference('TParamAttributes') isClasstype(False);

  result := new CGMethodDefinition('Retrieve_'+operation.Name,
                                    Visibility := CGMemberVisibilityKind.Protected,
                                    CallingConvention := CGCallingConventionKind.Register
                                    {Virtuality := CGMemberVirtualityKind.Virtual});
  for mem in operation.Items do begin
    if mem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out] then
      result.Parameters.Add(new CGParameterDefinition(mem.Name,
                                                      ResolveDataTypeToTypeRefFullQualified(library, mem.DataType,Intf_name),
                                                      Modifier := CGParameterModifierKind.Out));

  end;
  if assigned(operation.Result) then
    result.ReturnType := ResolveDataTypeToTypeRefFullQualified(library, operation.Result.DataType,Intf_name);

  if aNeedBody then begin
    var lMessage := 'lMessage'.AsNamedIdentifierExpression;
    var lTransportChannel := 'lTransportChannel'.AsNamedIdentifierExpression;
    var l__response := '__response'.AsNamedIdentifierExpression;
    var lFreeStream := 'lFreeStream'.AsNamedIdentifierExpression;
    var lretry := 'lRetry'.AsNamedIdentifierExpression;
    var ltc := 'tc'.AsNamedIdentifierExpression;
    result.LocalVariables := new List<CGVariableDeclarationStatement>;
    result.LocalVariables:Add(new CGVariableDeclarationStatement("__response",'TStream'.AsTypeReference));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("tc",'TMyTransportChannel'.AsTypeReference));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lRetry",ResolveStdtypes(CGPredefinedTypeKind.Boolean)));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lMessage",IROMessage_typeref));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lFreeStream",ResolveStdtypes(CGPredefinedTypeKind.Boolean)));
    if assigned(operation.Result) then 
      result.LocalVariables:Add(new CGVariableDeclarationStatement("lResult",result.ReturnType));

    result.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, '__GetMessage')));
    result.Statements.Add(new CGMethodCallExpression(lMessage,'SetAutoGeneratedNamespaces',[new CGMethodCallExpression(nil,'DefaultNamespaces').AsCallParameter]));
    result.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGFieldAccessExpression(nil, '__TransportChannel')));
    result.Statements.Add(new CGAssignmentStatement(lFreeStream, new CGBooleanLiteralExpression(false)));
////
    var ltry:=new CGTryFinallyCatchStatement();

    for litem in operation.Items do begin
      if (litem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out])  and isComplex(library, litem.DataType) then
        ltry.Statements.Add(new CGAssignmentStatement(litem.Name.AsNamedIdentifierExpression, CGNilExpression.Nil));
    end;
    if assigned(operation.Result) and isComplex(library, operation.Result.DataType) then
      ltry.Statements.Add(new CGAssignmentStatement('lResult'.AsNamedIdentifierExpression, CGNilExpression.Nil));
    ltry.Statements.Add(new CGAssignmentStatement(l__response, new CGMethodCallExpression(nil,'__RetrieveAsyncResponse',[operation.Name.AsLiteralExpression.AsCallParameter].ToList)));

    var ltry4 := new CGTryFinallyCatchStatement();
    ltry4.Statements.Add(new CGMethodCallExpression(lMessage,'ReadFromStream',[l__response.AsCallParameter,lFreeStream.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    var lexcept1 := new CGCatchBlockStatement('E','Exception'.AsTypeReference);
    lexcept1.Statements.Add(new CGAssignmentStatement(lFreeStream, new CGBooleanLiteralExpression(true)));
    lexcept1.Statements.Add(new CGThrowStatement());
    ltry4.CatchBlocks.Add(lexcept1);
    var ltry3 := new CGTryFinallyCatchStatement();
    ltry3.Statements.Add(ltry4);
    ltry3.Statements.Add(new CGEmptyStatement);
    {$REGION ! DataSnap}
    if not library.DataSnap then 
      if assigned(operation.Result) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if operation.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);
        ltry3.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      'Read',
                                                      [operation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,operation.Result.DataType,Intf_name)).AsCallParameter,
                                                      new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                      sa.AsCallParameter].ToList,
                                                      CallSiteKind:= CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for litem in operation.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if litem.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry3.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        'Read',
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGCallParameter(litem.Name.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                        sa.AsCallParameter].ToList,
                                                        CallSiteKind:= CGCallSiteKind.Reference));

      end;
    end;
    {$REGION DataSnap}
    if library.DataSnap then 
      if assigned(operation.Result) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if operation.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);
        ltry3.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      'Read',
                                                      [operation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,operation.Result.DataType,Intf_name)).AsCallParameter,
                                                      new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                      sa.AsCallParameter].ToList,
                                                      CallSiteKind:= CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    var lEROSessionNotFound := new CGCatchBlockStatement('E','EROSessionNotFound'.AsTypeReference);
    lEROSessionNotFound.Statements.Add(new CGAssignmentStatement(ltc,new CGTypeCastExpression(new CGMethodCallExpression(lTransportChannel,'GetTransportObject',CallSiteKind:= CGCallSiteKind.Reference),'TMyTransportChannel'.AsTypeReference)));
    lEROSessionNotFound.Statements.Add(new CGAssignmentStatement(lretry, new CGBooleanLiteralExpression(false)));
    lEROSessionNotFound.Statements.Add(new CGMethodCallExpression(ltc,'DoLoginNeeded',[lMessage.AsCallParameter,'E'.AsNamedIdentifierExpression.AsCallParameter,lretry.AsCallParameter].ToList,CallSiteKind:= CGCallSiteKind.Reference));
    lEROSessionNotFound.Statements.Add(new CGIfThenElseStatement(new CGUnaryOperatorExpression(lretry, CGUnaryOperatorKind.Not),new CGThrowStatement()));
    ltry3.CatchBlocks.Add(lEROSessionNotFound);
    var lexception :=new CGCatchBlockStatement('E','Exception'.AsTypeReference);
    lexception.Statements.Add(new CGThrowStatement());
    ltry3.CatchBlocks.Add(lexception);
    var ltry2 := new CGTryFinallyCatchStatement();
    ltry2.Statements.Add(ltry3);
    ltry2.FinallyStatements.Add(new CGIfThenElseStatement(lFreeStream,
                                                          new CGDestroyInstanceExpression(l__response)                                                               
                                                          ));
    ltry.Statements.Add(ltry2);
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    result.Statements.Add(ltry);
    if assigned(operation.Result) then 
      result.Statements.Add('lResult'.AsNamedIdentifierExpression.AsReturnStatement);

  end;
end;

method DelphiRodlCodeGen.Intf_GenerateAsyncExBegin(&library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody: Boolean): CGMethodDefinition;
begin
  var TParamAttributes_typeref := new CGNamedTypeReference('TParamAttributes') isClasstype(False);

  result := new CGMethodDefinition('Begin'+operation.Name,
                                    Visibility := CGMemberVisibilityKind.Protected,
                                    CallingConvention := CGCallingConventionKind.Register
                                    {Virtuality := CGMemberVirtualityKind.Virtual});
  for mem in operation.Items do begin
    if mem.ParamFlag in [ParamFlags.In, ParamFlags.InOut] then begin
      var lparam := new CGParameterDefinition(mem.Name,
                                              ResolveDataTypeToTypeRefFullQualified(library,mem.DataType, Intf_name));
      if isComplex(library, mem.DataType) and (mem.ParamFlag = ParamFlags.In) then
        lparam.Type := new CGConstantTypeReference(lparam.Type)
      else
        lparam.Modifier := RODLParamFlagToCodegenFlag(mem.ParamFlag);
      result.Parameters.Add(lparam);
    end;
  end;
  result.Parameters.Add(new CGParameterDefinition('aCallback',new CGNamedTypeReference('TROAsyncCallback') isclasstype(false), Modifier :=CGParameterModifierKind.Const));
  result.Parameters.Add(new CGParameterDefinition('aUserData', CGPointerTypeReference.VoidPointer, DefaultValue := CGNilExpression.Nil, Modifier :=CGParameterModifierKind.Const));
  result.ReturnType := ResolveInterfaceTypeRef(nil, 'IROAsyncRequest','uROAsync','', true);
  if aNeedBody then begin
    var lMessage := 'lMessage'.AsNamedIdentifierExpression;
    var lTransportChannel := 'lTransportChannel'.AsNamedIdentifierExpression;
    result.LocalVariables := new List<CGVariableDeclarationStatement>;
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lMessage",IROMessage_typeref));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lTransportChannel",IROTransportChannel_typeref));
    result.LocalVariables:Add(new CGVariableDeclarationStatement("lResult",result.ReturnType));
    result.Statements.Add(new CGAssignmentStatement(lMessage, new CGMethodCallExpression(nil, '__GetMessage')));
    result.Statements.Add(new CGMethodCallExpression(lMessage,'SetAutoGeneratedNamespaces',[new CGMethodCallExpression(nil,'DefaultNamespaces').AsCallParameter]));
    result.Statements.Add(new CGAssignmentStatement(lTransportChannel, new CGFieldAccessExpression(nil, '__TransportChannel')));
    var ltry:=new CGTryFinallyCatchStatement();
    var p1: List<CGExpression>;
    var p2: List<CGExpression>;
    GenerateAttributes(library, entity, operation,out p1, out p2);
    if p1.Count > 0 then begin
      ltry.Statements.Add(new CGMethodCallExpression(lMessage,'StoreAttributes2',[
                                                                              new CGArrayLiteralExpression(p1).AsCallParameter,
                                                                              new CGArrayLiteralExpression(p2).AsCallParameter].ToList,
                                                     CallSiteKind:= CGCallSiteKind.Reference));
      ltry.Statements.Add(new CGMethodCallExpression(lMessage,'ApplyAttributes2',CallSiteKind:= CGCallSiteKind.Reference));
    end;
    ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                    'InitializeRequestMessage',
                                                    [lTransportChannel.AsCallParameter,
                                                    iif(library.DataSnap,'',library.Name).AsLiteralExpression.AsCallParameter,
                                                    '__InterfaceName'.AsNamedIdentifierExpression.AsCallParameter,
                                                    operation.Name.AsLiteralExpression.AsCallParameter
                                                    ].ToList,
                                                    CallSiteKind:= CGCallSiteKind.Reference));
    for litem in operation.Items do begin
      if (litem.ParamFlag in [ParamFlags.In,ParamFlags.InOut]) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if litem.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        ltry.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        'Write',
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGCallParameter(litem.Name.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                        sa.AsCallParameter].ToList,
                                                        CallSiteKind:= CGCallSiteKind.Reference));

      end;
    end;

    ltry.Statements.Add(new CGAssignmentStatement('lResult'.AsNamedIdentifierExpression,
                                                  new CGMethodCallExpression(nil,'__DispatchAsyncRequest', [lMessage.AsCallParameter,
                                                                                                            'aCallback'.AsNamedIdentifierExpression.AsCallParameter,
                                                                                                            'aUserData'.AsNamedIdentifierExpression.AsCallParameter].ToList)));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lMessage,CGNilExpression.Nil));
    ltry.FinallyStatements.Add(new CGAssignmentStatement(lTransportChannel,CGNilExpression.Nil));
    result.Statements.Add(ltry);
    result.Statements.Add('lResult'.AsNamedIdentifierExpression.AsReturnStatement);

  end;
end;

method DelphiRodlCodeGen.Intf_GenerateAsyncExEnd(&library: RodlLibrary; entity: RodlService; operation: RodlOperation; aNeedBody: Boolean): CGMethodDefinition;
begin
  var TParamAttributes_typeref := new CGNamedTypeReference('TParamAttributes') isClasstype(False);

  result := new CGMethodDefinition('End'+operation.Name,
                                   Visibility := CGMemberVisibilityKind.Protected,
                                   CallingConvention := CGCallingConventionKind.Register
                                    {Virtuality := CGMemberVirtualityKind.Virtual});
  for mem in operation.Items do begin
    if mem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out] then
      result.Parameters.Add(new CGParameterDefinition(mem.Name,
                                                      ResolveDataTypeToTypeRefFullQualified(library, mem.DataType,Intf_name),
                                                      Modifier := CGParameterModifierKind.Out));

  end;
  result.Parameters.Add(new CGParameterDefinition('aRequest', ResolveInterfaceTypeRef(nil, 'IROAsyncRequest','uROAsync', '', true), Modifier :=CGParameterModifierKind.Const));
  if assigned(operation.Result) then
    result.ReturnType := ResolveDataTypeToTypeRefFullQualified(library, operation.Result.DataType,Intf_name);

  if aNeedBody then begin
    if assigned(operation.Result) then begin
      result.LocalVariables := new List<CGVariableDeclarationStatement>;
      result.LocalVariables:Add(new CGVariableDeclarationStatement("lResult",result.ReturnType));
    end;
    for litem in operation.Items do begin
      if (litem.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) and isComplex(library, litem.DataType) then
        result.Statements.Add(new CGAssignmentStatement(litem.Name.AsNamedIdentifierExpression, CGNilExpression.Nil));
    end;
    if assigned(operation.Result) and isComplex(library, operation.Result.DataType) then
      result.Statements.Add(new CGAssignmentStatement('lResult'.AsNamedIdentifierExpression, CGNilExpression.Nil));
    result.Statements.Add(new CGMethodCallExpression('aRequest'.AsNamedIdentifierExpression,'ReadResponse',CallSiteKind:= CGCallSiteKind.Reference));
    var lMessage := new CGFieldAccessExpression('aRequest'.AsNamedIdentifierExpression, 'Message',CallSiteKind:= CGCallSiteKind.Reference);
    result.Statements.Add(new CGMethodCallExpression(lMessage,'SetAutoGeneratedNamespaces',[new CGMethodCallExpression(nil,'DefaultNamespaces').AsCallParameter]));

    {$REGION ! DataSnap}
    if not library.DataSnap then 
      if assigned(operation.Result) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if operation.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);
        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      'Read',
                                                      [operation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,operation.Result.DataType,Intf_name)).AsCallParameter,
                                                      new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                      sa.AsCallParameter].ToList,
                                                      CallSiteKind:= CGCallSiteKind.Reference));
      end;
    {$ENDREGION}
    for litem in operation.Items do begin
      if (litem.ParamFlag in [ParamFlags.Out,ParamFlags.InOut]) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if litem.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);

        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                        'Read',
                                                        [litem.Name.AsLiteralExpression.AsCallParameter,
                                                        GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,litem.DataType,Intf_name)).AsCallParameter,
                                                        new CGCallParameter(litem.Name.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                        sa.AsCallParameter].ToList,
                                                        CallSiteKind:= CGCallSiteKind.Reference));

      end;
    end;
    {$REGION DataSnap}
    if library.DataSnap then 
      if assigned(operation.Result) then begin
        var sa := new CGSetLiteralExpression(ElementType := TParamAttributes_typeref);
        if operation.Result.DataType.EqualsIgnoringCaseInvariant('DateTime') then sa.Elements.Add('paIsDateTime'.AsNamedIdentifierExpression);
        result.Statements.Add(new CGMethodCallExpression(lMessage,
                                                      'Read',
                                                      [operation.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      GenerateTypeInfoCall(library,ResolveDataTypeToTypeRefFullQualified(library,operation.Result.DataType,Intf_name)).AsCallParameter,
                                                      new CGCallParameter('lResult'.AsNamedIdentifierExpression, Modifier := CGParameterModifierKind.Var),
                                                      sa.AsCallParameter].ToList,
                                                      CallSiteKind:= CGCallSiteKind.Reference));
      end;
    {$ENDREGION}

    if assigned(operation.Result) then
        result.Statements.Add('lResult'.AsNamedIdentifierExpression.AsReturnStatement);
  end;
end;
{$ENDREGION}

method DelphiRodlCodeGen.GenerateImplementationFiles(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>;
begin
  var lunit := GenerateImplementationCodeUnit(library,aTargetNamespace, aServiceName);
  var service := library.Services.FindEntity(aServiceName);
  result := new Dictionary<String,String>;
  result.Add(Path.ChangeExtension(lunit.FileName, Generator.defaultFileExtension),
             Generator.GenerateUnit(lunit));
  if isDFMNeeded and GenerateDFMs then
    result.Add(Path.ChangeExtension(lunit.FileName, 'dfm'),
               String.Format(iif(String.IsNullOrEmpty(service.AncestorName), DFM_template, DFM_template2),[aServiceName]));
end;

{$REGION generate _Impl}
method DelphiRodlCodeGen.Impl_GenerateService(file: CGCodeUnit; &library: RodlLibrary; entity: RodlService);
begin
  var l_EntityName := entity.Name;
  var l_IName := 'I'+l_EntityName;
  var l_TName := 'T'+l_EntityName;
  var l_methodName := 'Create_'+l_EntityName;
  var l_zeroconf := '_'+l_EntityName+'_rosdk._tcp.';

  {$REGION implementation method + initialization/finalization}
  var l_fClassFactory := 'fClassFactory_'+l_EntityName;
  var l_fClassFactoryExpr := l_fClassFactory.AsNamedIdentifierExpression;
  var lcreator := new CGMethodDefinition(l_methodName,                                         
                                         
                                         Parameters := [new CGParameterDefinition('anInstance', ResolveInterfaceTypeRef(nil,'IInterface',''),Modifier:= CGParameterModifierKind.Out)].ToList,
                                         Visibility := CGMemberVisibilityKind.Private,
                                         CallingConvention := CGCallingConventionKind.Register);
  Impl_GenerateCreateService(lcreator, new CGNewInstanceExpression(l_TName.AsTypeReference,[CGNilExpression.Nil.AsCallParameter].ToList));
  file.Globals.Add(lcreator.AsGlobal);
  file.Globals.Add(new CGFieldDefinition(l_fClassFactory,ResolveInterfaceTypeRef(nil,'IROClassFactory','uROServerIntf','',True), Visibility := CGMemberVisibilityKind.Private).AsGlobal);
  file.Initialization := new List<CGStatement>;
  file.Initialization.Add(Impl_CreateClassFactory(library, entity, l_fClassFactoryExpr));
  file.Initialization.Add(new CGCodeCommentStatement(new CGMethodCallExpression(nil,'RegisterForZeroConf',[l_fClassFactoryExpr.AsCallParameter,l_zeroconf.AsLiteralExpression.AsCallParameter])));
  file.Finalization := new List<CGStatement>;
  file.Finalization.Add(new CGMethodCallExpression(nil,'UnRegisterClassFactory',[l_fClassFactoryExpr.AsCallParameter].ToList));
  file.Finalization.Add(new CGAssignmentStatement(l_fClassFactoryExpr, CGNilExpression.Nil));
  {$ENDREGION}


  var lancestorName := GetServiceAncestor(library, entity);
  var lservice := new CGClassTypeDefinition(l_TName,lancestorName.AsTypeReference,[l_IName.AsTypeReference].ToList,
                                             Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(lservice);
  cpp_IUnknownSupport(library, entity, lservice);
  cpp_GenerateAncestorMethodCalls(library, entity, lservice, ModeKind.Plain);
  cpp_Impl_constructor(library, entity, lservice);
  for lmem in entity.DefaultInterface.Items do begin
    {$REGION service methods}
    var mem := new CGMethodDefinition(lmem.Name,
                                      Virtuality := CGMemberVirtualityKind.Virtual,
                                      Visibility := CGMemberVisibilityKind.Public,
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
    mem.Statements.Add(AddMessageDirective(lmem.Name+" is not implemented yet!"));
    if assigned(lmem.Result) then begin
      mem.ReturnType := ResolveDataTypeToTypeRefFullQualified(library,lmem.Result.DataType, Intf_name);
      if isComplex(library, lmem.Result.DataType) then
        mem.Statements.Add(CGNilExpression.Nil.AsReturnStatement);
    end;

    lservice.Members.Add(mem);
    {$ENDREGION}
  end;
end;

method DelphiRodlCodeGen.Impl_GenerateDFMInclude(file: CGCodeUnit);
begin
  file.ImplementationDirectives.Add(new CGCompilerDirective("{%CLASSGROUP 'System.Classes.TPersistent'}", new CGConditionalDefine("DELPHIXE2UP")));
  file.ImplementationDirectives.Add(new CGCompilerDirective("{$R *.dfm}",new CGConditionalDefine("FPC") inverted(true)));
  file.ImplementationDirectives.Add(new CGCompilerDirective("{$R *.lfm}",new CGConditionalDefine("FPC"))); 
end;

method DelphiRodlCodeGen.Impl_CreateClassFactory(library: RodlLibrary; entity: RodlService; lvar: CGExpression): CGStatement;
begin
  var l_EntityName := entity.Name;
  var l_TInvoker := 'T'+l_EntityName+'_Invoker';
  var l_methodName := 'Create_'+l_EntityName;
    
  exit new CGAssignmentStatement(lvar,
                                 new CGNewInstanceExpression('TROClassFactory'.AsTypeReference,
                                           [l_EntityName.AsLiteralExpression.AsCallParameter,
                                            ('{$IFDEF FPC}@{$ENDIF}'+l_methodName).AsNamedIdentifierExpression.AsCallParameter,
                                            l_TInvoker.AsNamedIdentifierExpression.AsCallParameter]));
end;

method DelphiRodlCodeGen.Impl_GenerateCreateService(aMethod: CGMethodDefinition; aCreator: CGExpression);
begin
  aMethod.Statements.Add(new CGAssignmentStatement( 'anInstance'.AsNamedIdentifierExpression, aCreator));
end;
{$ENDREGION}

method DelphiRodlCodeGen.RODLParamFlagToCodegenFlag(aFlag: ParamFlags): CGParameterModifierKind;
begin
  case aFlag of
    ParamFlags.In: exit CGParameterModifierKind.Const;
    ParamFlags.Out: exit CGParameterModifierKind.Out;
    ParamFlags.InOut: exit CGParameterModifierKind.Var;
  else
    raise new Exception('invalid flag');
  end;
end;

method DelphiRodlCodeGen.GetNamespace(library: RodlLibrary): String;
begin
  if assigned(library.Includes) then result := library.Includes.DelphiModule;
  if String.IsNullOrWhiteSpace(result) then result := inherited GetNamespace(library);
end;

{$REGION support methods}
method DelphiRodlCodeGen.GetServiceAncestor(library: RodlLibrary; entity: RodlService): String;
begin
  if not String.IsNullOrEmpty(entity.AncestorName) then begin
    result := RodlService(entity.AncestorEntity).ImplClass;
    if String.IsNullOrEmpty(result) then exit 'T'+entity.AncestorName
  end
  else begin
    case DefaultServerAncestor of
      DelphiServerAncestor.Remotable: exit 'TRORemotable';
      DelphiServerAncestor.RemoteDataModule: exit 'TRORemoteDataModule';
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
{$ENDREGION}

method DelphiRodlCodeGen.set_CustomAncestor(value: String);
begin
  case value of
    '','TRORemoteDataModule': DefaultServerAncestor := DelphiServerAncestor.RemoteDataModule;
    'TRORemotable':           DefaultServerAncestor := DelphiServerAncestor.Remotable;
  else
    DefaultServerAncestor := DelphiServerAncestor.Custom;
  end;
  fCustomAncestor := value;
end;

method DelphiRodlCodeGen.Array_SetLength(anArray: CGExpression; aValue: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression('System'.AsNamedIdentifierExpression,'SetLength',[anArray.AsCallParameter, aValue.AsCallParameter], CallSiteKind := CGCallSiteKind.Static);
end;

method DelphiRodlCodeGen.Array_GetLength(anArray: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression('System'.AsNamedIdentifierExpression,"Length",[anArray.AsCallParameter].ToList, CallSiteKind := CGCallSiteKind.Static);
end;

method DelphiRodlCodeGen.RaiseError(aMessage:CGExpression; aParams:List<CGExpression>): CGExpression;
begin
  var lres := new CGMethodCallExpression('uROClasses'.AsNamedIdentifierExpression, 'RaiseError',[aMessage.AsCallParameter].ToList);
  if aParams <> nil then
    lres.Parameters.Add(new CGArrayLiteralExpression(aParams).AsCallParameter);
  exit lres;
end;

method DelphiRodlCodeGen.isDFMNeeded: Boolean;
begin
  exit DefaultServerAncestor <> DelphiServerAncestor.Remotable;
end;

method DelphiRodlCodeGen.ResolveInterfaceTypeRef(library: RodlLibrary; dataType: String; aDefaultUnitName: String; aOrigDataType: String; aCapitalize: Boolean): CGNamedTypeReference;
begin
  // interfaces always CGNamedTypeReference
  exit CGNamedTypeReference(ResolveDataTypeToTypeRefFullQualified(library, dataType, aDefaultUnitName, aOrigDataType, aCapitalize));
end;

method DelphiRodlCodeGen.get_IROMessage_typeref: CGTypeReference;
begin
  if fIROMessage_typeref = nil then fIROMessage_typeref := ResolveInterfaceTypeRef(nil, 'IROMessage','uROClientIntf','', true);
  exit fIROMessage_typeref;
end;

method DelphiRodlCodeGen.get_IROTransportChannel_typeref: CGTypeReference;
begin
  if fIROTransportChannel_typeref = nil then fIROTransportChannel_typeref := ResolveInterfaceTypeRef(nil, 'IROTransportChannel','uROClientIntf','', true);
  exit fIROTransportChannel_typeref;
end;

method DelphiRodlCodeGen.GenerateTypeInfoCall(library: RodlLibrary; aTypeInfo: CGTypeReference): CGExpression;
begin
  exit new CGMethodCallExpression('System'.AsNamedIdentifierExpression,
                                  'TypeInfo',
                                  [aTypeInfo.AsExpression.AsCallParameter].ToList);
end;

method DelphiRodlCodeGen.InterfaceCast(aSource, aType, aDest: CGExpression): CGExpression;
begin
  exit new CGMethodCallExpression(nil,
                                   'Supports',
                                   [aSource.AsCallParameter,
                                   aType.AsCallParameter,
                                   aDest.AsCallParameter].ToList);
end;

method DelphiRodlCodeGen.cppGenerateEnumTypeInfo(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum);
begin
  var lenum_typeref := new CGNamedTypeReference(entity.Name) isclasstype(false);
  file.Globals.Add(new CGMethodDefinition('GetTypeInfo_'+entity.Name,
                                            [new CGMethodCallExpression(nil, 'TypeInfo',[lenum_typeref.AsExpression.AsCallParameter]).AsReturnStatement],
                                            ReturnType := 'PTypeInfo'.AsTypeReference,
                                            Visibility := CGMemberVisibilityKind.Public,
                                            CallingConvention := CGCallingConventionKind.Register
                                            ).AsGlobal);
end;

method DelphiRodlCodeGen.GlobalsConst_GenerateServerGuid(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);
begin
  var lname := entity.Name;
  file.Globals.Add(new CGFieldDefinition(String.Format("I{0}_IID",[lname]), 'TGUID'.AsTypeReference,
                              Constant := true,
                              Visibility := CGMemberVisibilityKind.Public,
                              Initializer := ('{'+entity.DefaultInterface.EntityID.ToString.ToUpperInvariant+'}').AsLiteralExpression).AsGlobal);
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
{$ENDREGION}

method DelphiRodlCodeGen.get_IROTransport_typeref: CGTypeReference;
begin
  if fIROTransport_typeref = nil then fIROTransport_typeref := ResolveInterfaceTypeRef(nil, 'IROTransport','uROClientIntf','', true);
  exit fIROTransport_typeref;
end;

method DelphiRodlCodeGen.AddMessageDirective(aMessage: String): CGStatement;
begin
  exit new CGRawStatement("{$Message Hint '"+aMessage+"'}");
end;

method DelphiRodlCodeGen.AddDynamicArrayParameter(aMethod: CGMethodCallExpression; aDynamicArrayParam: CGExpression);
begin
  aMethod.Parameters.Add(aDynamicArrayParam.AsCallParameter);
end;

method DelphiRodlCodeGen.GenerateCGImport(aName: String;aNamespace : String; aExt: String): CGImport;
begin
  if String.IsNullOrEmpty(aNamespace) then 
    exit new CGImport(new CGNamedTypeReference(aName))
  else
    exit new CGImport(String.Format('{{$IFDEF DELPHIXE2UP}}{0}.{1}{{$ELSE}}{1}{{$ENDIF}}',[aNamespace, aName]));
end;

method DelphiRodlCodeGen.cpp_ClassId(anExpression: CGExpression): CGExpression;
begin
  exit anExpression;
end;

method DelphiRodlCodeGen.GenerateIsClause(aSource: CGExpression; aType: CGTypeReference): CGExpression;
begin
  exit new CGMethodCallExpression(aSource,'InheritsFrom',[cpp_ClassId(DuplicateType(aType, false).AsExpression).AsCallParameter],CallSiteKind := CGCallSiteKind.Reference);
end;

method DelphiRodlCodeGen.GenerateInterfaceCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String): CGCodeUnit;
begin
  ScopedEnums := ScopedEnums or library.ScopedEnums;
  //special mode, only if library.ScopedEnums is set 
  IncludeUnitNameForOwnTypes := IncludeUnitNameForOwnTypes or library.ScopedEnums;
  targetNamespace := aTargetNamespace;
  if String.IsNullOrEmpty(targetNamespace) then targetNamespace := library.Namespace;
  if String.IsNullOrEmpty(targetNamespace) then targetNamespace := library.Name;
  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  if String.IsNullOrEmpty(aUnitName) then begin
    var lunitname: String;
    try
      if assigned(library.Includes) then lunitname := library.Includes.DelphiModule;
      if String.IsNullOrEmpty(lunitname) then lunitname := library.Name;
    except
      lunitname := 'Unknown';
    end;
    lUnit.FileName := lunitname+ '_Intf';
  end
  else begin
    lUnit.FileName := Path.GetFileNameWithoutExtension(aUnitName);
  end;
  Intf_name := lUnit.FileName;


  lUnit.Initialization := new List<CGStatement>;
  lUnit.Finalization := new List<CGStatement>;
  lUnit.HeaderComment := GenerateUnitComment;
  Add_RemObjects_Inc(lUnit, &library);

  {$REGION interface uses}

  lUnit.Imports.Add(GenerateCGImport('SysUtils','System'));
  lUnit.Imports.Add(GenerateCGImport('Classes','System'));
  lUnit.Imports.Add(GenerateCGImport('TypInfo','System'));
  lUnit.Imports.Add(GenerateCGImport('uROUri'));
  lUnit.Imports.Add(GenerateCGImport('uROProxy'));
  lUnit.Imports.Add(GenerateCGImport('uROExceptions'));
  lUnit.Imports.Add(GenerateCGImport('uROXMLIntf'));
  lUnit.Imports.Add(GenerateCGImport('uROClasses'));
  lUnit.Imports.Add(GenerateCGImport('uROTypes'));
  lUnit.Imports.Add(GenerateCGImport('uROClientIntf'));
  lUnit.Imports.Add(GenerateCGImport('uROAsync'));
  lUnit.Imports.Add(GenerateCGImport('uROEventReceiver'));

  var list := new List<String>;
  for lu: RodlUse in library.Uses.Items do begin
    var s1 := lu.Includes:DelphiModule;
    var lExt := 'hpp';
    if String.IsNullOrEmpty(s1) then begin
      lExt := 'h';
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ '_Intf';
    if not list.Contains(s1) then begin
      lUnit.Imports.Add(GenerateCGImport(s1,'',lExt));
      list.Add(s1);
    end;
  end;
  {$ENDREGION}


  {$REGION 'function DefaultNamespaces:string;'}
  var m:= new CGMethodDefinition('DefaultNamespaces',
                                  ReturnType :=ResolveStdtypes(CGPredefinedTypeKind.String),
                                  Visibility := CGMemberVisibilityKind.Public,
                                  CallingConvention := CGCallingConventionKind.Register);

  m.LocalVariables := new List<CGVariableDeclarationStatement>;
  m.LocalVariables.Add(new CGVariableDeclarationStatement('lres',ResolveStdtypes(CGPredefinedTypeKind.String), new CGLocalVariableAccessExpression('DefaultNamespace')));

  var lres := new CGLocalVariableAccessExpression('lres');
  var lres1 := new CGBinaryOperatorExpression(lres, ';'.AsLiteralExpression, CGBinaryOperatorKind.Addition);
  for k in list do begin
    m.Statements.Add(new CGAssignmentStatement(lres, 
                                               new CGBinaryOperatorExpression(lres1, 
                                                                              new CGFieldAccessExpression(k.AsNamedIdentifierExpression,'DefaultNamespace',CallSiteKind := CGCallSiteKind.Static), 
                                                                              CGBinaryOperatorKind.Addition)
                                                ));
  end;
  m.Statements.Add(lres.AsReturnStatement);
  lUnit.Globals.Add(m.AsGlobal);
  {$ENDREGION}


  cpp_smartInit(lUnit);
  {$REGION implementation uses}
  lUnit.ImplementationImports.Add(GenerateCGImport('uROSerializer'));
  lUnit.ImplementationImports.Add(GenerateCGImport('uROClient'));
  lUnit.ImplementationImports.Add(GenerateCGImport('uROTransportChannel'));
  lUnit.ImplementationImports.Add(GenerateCGImport('uRORes'));
  {$ENDREGION}

  cpp_pragmalink(lUnit,CapitalizeString('uROProxy'));
  cpp_pragmalink(lUnit,CapitalizeString('uROAsync'));
  AddGlobalConstants(lUnit, &library);

  if library.Enums.Count >0 then begin
    if PureDelphi and ScopedEnums then 
      lUnit.Directives.Add(new CGCompilerDirective('{$SCOPEDENUMS ON}'));
  
    for entity: RodlEnum in library.Enums.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
      if not EntityNeedsCodeGen(entity) then Continue;
      Intf_GenerateEnum(lUnit, &library, entity);
    end;
  end;

  for entity: RodlStruct in library.Structs.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    Intf_GenerateStruct(lUnit, &library, entity);
    Intf_GenerateStructCollection(lUnit, &library, entity);
  end;

  for entity: RodlArray in library.Arrays.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    Intf_GenerateArray(lUnit, &library, entity);
  end;

  for entity: RodlException in library.Exceptions.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    Intf_GenerateException(lUnit, &library, entity);
  end;

  if library.Services.Items.Count > 0 then begin
    var ltype := new CGClassTypeDefinition('TMyTransportChannel',
                                       'TROTransportChannel'.AsTypeReference, 
                                       Visibility := CGTypeVisibilityKind.Unit);
    cpp_generateDoLoginNeeded(ltype);
    lUnit.Types.Add(ltype);
  end;
  for entity: RodlService in library.Services.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    Intf_GenerateService(lUnit, &library, entity);
  end;

  for entity: RodlEventSink in library.EventSinks.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    Intf_GenerateEventSink(lUnit, &library, entity);
  end;

  exit lUnit;
end;

method DelphiRodlCodeGen.GenerateInvokerCodeUnit(library: RodlLibrary; aTargetNamespace: String; aUnitName: String): CGCodeUnit;
begin
  IncludeUnitNameForOwnTypes := true;
  targetNamespace := aTargetNamespace;
  if String.IsNullOrEmpty(targetNamespace) then targetNamespace := library.Namespace;
  if String.IsNullOrEmpty(targetNamespace) then targetNamespace := library.Name;
  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  if String.IsNullOrEmpty(aUnitName) then begin
    var lunitname: String;
    try
      if assigned(library.Includes) then lunitname := library.Includes.DelphiModule;
      if String.IsNullOrEmpty(lunitname) then lunitname := library.Name;
    except
      lunitname := 'Unknown';
    end;
    lUnit.FileName := lunitname+ '_Invk';
  end
  else begin
    lUnit.FileName := Path.GetFileNameWithoutExtension(aUnitName);
  end;
  Invk_name := lUnit.FileName;
  Intf_name := Invk_name.Substring(0,Invk_name.Length-5)+'_Intf';
  lUnit.Initialization := new List<CGStatement>;
  lUnit.Finalization := new List<CGStatement>;
  lUnit.HeaderComment := GenerateUnitComment;
  Add_RemObjects_Inc(lUnit, library);  
  
  {$REGION interface uses}
  lUnit.Imports.Add(GenerateCGImport('SysUtils','System'));
  lUnit.Imports.Add(GenerateCGImport('Classes','System'));
  lUnit.Imports.Add(GenerateCGImport('uROXMLIntf'));
  lUnit.Imports.Add(GenerateCGImport('uROServer'));
  lUnit.Imports.Add(GenerateCGImport('uROServerIntf'));
  lUnit.Imports.Add(GenerateCGImport('uROClasses'));
  lUnit.Imports.Add(GenerateCGImport('uROTypes'));
  lUnit.Imports.Add(GenerateCGImport('uROClientIntf'));
  var list := new List<String>;
  for lu: RodlUse in library.Uses.Items do begin
    var s1 := lu.Includes:DelphiModule;
    var lext := 'hpp';
    if String.IsNullOrEmpty(s1) then begin
      lext := 'h';
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ '_Intf';
    if not list.Contains(s1) then begin
      lUnit.Imports.Add(GenerateCGImport(s1,'',lext));
      list.Add(s1);
    end;
  end;

  list := new List<String>;
  for lu: RodlUse in library.Uses.Items do begin
    var s1 := lu.Includes:DelphiModule;
    var lext := 'hpp';
    if String.IsNullOrEmpty(s1) then begin
      lext := 'h';
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ '_Invk';
    if not list.Contains(s1) then begin
      lUnit.Imports.Add(GenerateCGImport(s1,'',lext));
      cpp_pragmalink(lUnit,CapitalizeString(s1));
      list.Add(s1);
    end;
  end;
  lUnit.Imports.Add(GenerateCGImport(Intf_name,'','h'));

  {$ENDREGION}

  cpp_smartInit(lUnit);
  {$REGION implementation uses}
  lUnit.ImplementationImports.Add(GenerateCGImport('uROEventRepository'));
  lUnit.ImplementationImports.Add(GenerateCGImport('uRORes'));
  lUnit.ImplementationImports.Add(GenerateCGImport('uROClient'));
  {$ENDREGION}
  cpp_pragmalink(lUnit,CapitalizeString('uROServer'));

  for entity: RodlService in library.Services.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    Invk_GenerateService(lUnit, &library, entity);
  end;

  for entity: RodlEventSink in library.EventSinks.SortedByAncestor do begin
    if not EntityNeedsCodeGen(entity) then Continue;
    Invk_GenerateEventSink(lUnit, &library, entity);
  end;

  {$REGION initialization}
  if (library.Services.Count > 0) or (library.EventSinks.Count > 0) then begin
    for latr in library.CustomAttributes.Keys do begin
      var latr1 := latr.ToLowerInvariant;
      lUnit.Initialization.Add(new CGMethodCallExpression(nil, 'RegisterServiceAttribute',
                                                               [''.AsLiteralExpression.AsCallParameter,
                                                                latr.AsLiteralExpression.AsCallParameter,
                                                               (if latr1 = 'wsdl' then 'WSDLLocation'.AsNamedIdentifierExpression
                                                                else if latr1 = 'targetnamespace' then 'TargetNamespace'.AsNamedIdentifierExpression
                                                                else library.CustomAttributes[latr].AsLiteralExpression).AsCallParameter].ToList));
    end;
  end;
  {$ENDREGION}
  exit lUnit;
end;

method DelphiRodlCodeGen.GenerateImplementationCodeUnit(library: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit;
begin
  var service := library.Services.FindEntity(aServiceName);
  if service = nil then raise new Exception(String.Format('{0} wasn''t found!',[aServiceName]));
  if service.IsFromUsedRodl then begin
    library := service.FromUsedRodl.OwnerLibrary;
  end;
  targetNamespace := aTargetNamespace;
  if String.IsNullOrEmpty(targetNamespace) then targetNamespace := library.Namespace;
  if String.IsNullOrEmpty(targetNamespace) then targetNamespace := library.Name;
  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  lUnit.FileName := aServiceName+ '_Impl';
  Impl_name := lUnit.FileName;

  var lunitname: String;
  try
    if assigned(library.Includes) then lunitname := library.Includes.DelphiModule;
    if String.IsNullOrEmpty(lunitname) then lunitname := library.Name;
  except
    lunitname := 'Unknown';
  end;
  Intf_name := lunitname+ '_Intf';
  Invk_name := lunitname+ '_Invk';


  lUnit.HeaderComment := GenerateUnitComment;
  Add_RemObjects_Inc(lUnit, library);
  {$REGION interface uses}
  lUnit.Imports.Add(GenerateCGImport('SysUtils','System'));
  lUnit.Imports.Add(GenerateCGImport('Classes','System'));
  lUnit.Imports.Add(GenerateCGImport('TypInfo','System'));
  lUnit.Imports.Add(GenerateCGImport('uROXMLIntf'));
  lUnit.Imports.Add(GenerateCGImport('uROClientIntf'));
  lUnit.Imports.Add(GenerateCGImport('uROClasses'));
  lUnit.Imports.Add(GenerateCGImport('uROTypes'));
  lUnit.Imports.Add(GenerateCGImport('uROServer'));
  lUnit.Imports.Add(GenerateCGImport('uROServerIntf'));
  lUnit.Imports.Add(GenerateCGImport('uROSessions'));
  case DefaultServerAncestor of
    DelphiServerAncestor.Remotable: ;
    DelphiServerAncestor.RemoteDataModule: lUnit.Imports.Add(GenerateCGImport('uRORemoteDataModule'));
    DelphiServerAncestor.Custom: lUnit.Imports.Add(GenerateCGImport(CustomUses));
  end;

  if service.AncestorEntity <> nil then begin
    var anc_unit := RodlService(service.AncestorEntity).ImplUnit;
    if String.IsNullOrEmpty(anc_unit) then anc_unit := service.AncestorName+'_Impl';
    lUnit.Imports.Add(GenerateCGImport(anc_unit));
    cpp_pragmalink(lUnit,CapitalizeString(anc_unit));
  end;

  var list := new List<String>;
  for lu: RodlUse in library.Uses.Items do begin
    var s1 := lu.Includes:DelphiModule;
    var lext := 'hpp';
    if String.IsNullOrEmpty(s1) then begin
      lext := 'h';
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ '_Intf';
    if not list.Contains(s1) then begin
      lUnit.Imports.Add(GenerateCGImport(s1,'',lext));
      list.Add(s1);
    end;
  end;

  lUnit.Imports.Add(GenerateCGImport(Intf_name,'','h'));
  {$ENDREGION}
  cpp_smartInit(lUnit);
  cpp_pragmalink(lUnit,CapitalizeString('uRORemoteDataModule'));
  cpp_pragmalink(lUnit,CapitalizeString('uROServer'));
  if isDFMNeeded then Impl_GenerateDFMInclude(lUnit);

  {$REGION implementation uses}
  list := new List<String>;
  for lu: RodlUse in library.Uses.Items do begin
    var s1 := lu.Includes:DelphiModule;
    var lext := 'hpp';
    if String.IsNullOrEmpty(s1) then begin
      lext := 'h';
      s1 := lu.Name;
      if String.IsNullOrEmpty(s1) then
        s1 := Path.GetFileNameWithoutExtension(lu.FileName);
    end;
    s1 := s1+ '_Invk';
    if not list.Contains(s1) then begin
      lUnit.ImplementationImports.Add(GenerateCGImport(s1,'',lext));
      list.Add(s1);
    end;
  end;
  lUnit.ImplementationImports.Add(GenerateCGImport(Invk_name,'','h'));
  {$ENDREGION}
  Impl_GenerateService(lUnit, &library, service);
  exit lUnit;
end;

method DelphiRodlCodeGen.GenerateImplementationFiles(file: CGCodeUnit; library: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;
begin
  var service := library.Services.FindEntity(aServiceName);
  result := new Dictionary<String,String>;
  result.Add(Path.ChangeExtension(file.FileName, Generator.defaultFileExtension),
             Generator.GenerateUnit(file));
  if isDFMNeeded then
    result.Add(Path.ChangeExtension(file.FileName, 'dfm'),
               String.Format(iif(String.IsNullOrEmpty(service.AncestorName), DFM_template, DFM_template2),[aServiceName]));
end;

end.