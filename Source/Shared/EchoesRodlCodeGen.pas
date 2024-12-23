namespace RemObjects.SDK.CodeGen4;

interface

type
  EchoesRodlCodeGen = public class(RodlCodeGen)
  private
    class const OBJECT_DISPOSER_NAME: String = "___objectDisposer";
    // interface constants
    class const INTF_FIELD_PREFIX: String = "___";
    class const INTF_EVENT_HANDLERS_PARAMETER: String = "___handlers";
    class const INTF_MESSAGE_PARAMETER: String = "___message";
    class const INTF_INDEX: String = "___i";
    class const INTF_LOCAL_MESSAGE: String = "___localMessage";
    class const INTF_GET_MESSAGE: String = "___GetMessage";
    class const INTF_CLEAR_MESSAGE: String = "___ClearMessage";
    class const INTF_ASYNC_RESULT: String = "___asyncResult";
    class const INTF_CALLBACK: String = "___callback";
    class const INTF_USER_DATA: String = "___userData";
    // invokers constants
    class const INVK_INSTANCE: String = "___Instance";
    class const INVK_MESSAGE: String = "___Message";
    class const INVK_CHANNEL_INFO: String = "___ServerChannelInfo";
    class const INVK_OPTIONS: String = "___oResponseOptions";
    class const INVK_GET_INTERFACE_NAME: String = "___GetInterfaceName";
    class const INVK_GET_EVENT_SINK_TYPE: String = "___GetEventSinkType";
    class const INVK_SERVER_EVENT_CHANNEL: String = "___ServerEventChannel";
    class const INVK_EVENT_TARGETS: String = "___EventTargets";

    var fStreamingFormats  := new Dictionary<String, String>;
    var fDontNeedDisposers := new List<String>;

    method GetStreamingFormat(aLibrary: RodlLibrary; dataType: String): String;
    method GenerateGenericType(aType: String; aGenericParams: array of CGTypeReference): CGTypeReference;
    method GenerateCustomAttributeHandlers(aType: CGTypeDefinition; aRodlEntity: RodlEntity);
    method GenerateEntityActivator(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
    method GenerateServiceActivator(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_generateReadStatement(aLibrary: RodlLibrary; aSerializer: CGExpression; aEntity: RodlTypedEntity): CGExpression;
    method Intf_generateWriteStatement(aLibrary: RodlLibrary; aSerializer: CGExpression; aEntity: RodlTypedEntity): CGExpression;

    method Intf_StructReadMethod(aLibrary: RodlLibrary; aStruct: CGTypeDefinition; aRodlStruct: RodlStruct);
    method Intf_StructWriteMethod(aLibrary: RodlLibrary; aStruct: CGTypeDefinition; aRodlStruct: RodlStruct);
    method IsParameterDisposerNeeded(parameter: RodlParameter): Boolean;
    method Intf_GenerateServiceProxyConstructors(aType: CGClassTypeDefinition);
    method Intf_GenerateServiceProxyInterfaceNameProperty(aType: CGClassTypeDefinition; aRodlService: RodlService);
    method Intf_GenerateCoService(aUnit: CGCodeUnit; aName: String; aIntfName: String; aProxyName: String);
    method GenerateAttributes(aLibrary: RodlLibrary; aService: RodlService; aOperation: RodlOperation; out aNames: List<CGExpression>; out aValues: List<CGExpression>);
    method GenerateObfuscationAttribute: CGAttribute;
  protected
    method ResolveDataTypeToTypeRef(aLibrary: RodlLibrary; aDataType: String; aOrigType: String := nil): CGTypeReference;
    method AddDefaultClientNamespaces(aUnit: CGCodeUnit);
    method AddDefaultServerNamespaces(aUnit: CGCodeUnit);
    method AddUsedNamespaces(file: CGCodeUnit; aLibrary: RodlLibrary); override;
    method GetIncludesNamespace(aLibrary: RodlLibrary): String; override;
    method Intf_GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
    method Intf_GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
    method Intf_GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
    method Intf_GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
    method Intf_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
    method Intf_GenerateServiceSync(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Intf_GenerateServiceAsync(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Impl_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Invk_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method Invk_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);

  public
    constructor;
    property AsyncSupport: Boolean := true;
    method GetGlobalName(aLibrary: RodlLibrary): String; override;
    method GenerateInterfaceCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
    method GenerateInvokerCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
    method GenerateLegacyEventsFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
    method GenerateImplementationCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit; override;
    method GenerateImplementationFiles(aFile: CGCodeUnit; aLibrary: RodlLibrary; aServiceName: String): not nullable Dictionary<String,String>;override;
    begin
      result := new Dictionary<String,String>;
      result.Add(Path.ChangeExtension(aFile.FileName, Generator.defaultFileExtension),
                 Generator.GenerateUnit(aFile));
    end;
    method GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>; override;
  end;

extension method String.AsTypeReference_NotNullable: not nullable CGTypeReference;
extension method String.AsTypeReference_Nullable: not nullable CGTypeReference;
extension method String.AsTypeReference_Nullable2: not nullable CGTypeReference;
implementation

extension method String.AsTypeReference_NotNullable: not nullable CGTypeReference;
begin
  exit self.AsTypeReference(CGTypeNullabilityKind.NotNullable);
end;

extension method String.AsTypeReference_Nullable: not nullable CGTypeReference;
begin
  exit self.AsTypeReference(CGTypeNullabilityKind.NullableUnwrapped);
end;

extension method String.AsTypeReference_Nullable2: not nullable CGTypeReference;
begin
  exit new CGNamedTypeReference(self) defaultNullability(CGTypeNullabilityKind.NotNullable) nullability(CGTypeNullabilityKind.NullableNotUnwrapped);
  //exit self.AsTypeReference(CGTypeNullabilityKind.NullableUnwrapped);
end;

constructor EchoesRodlCodeGen;
begin
  CodeGenTypes.Add("integer",         CGPredefinedTypeReference.Int32);
  CodeGenTypes.Add("datetime",        "System.DateTime".AsTypeReference_NotNullable);
  CodeGenTypes.Add("double",          CGPredefinedTypeReference.Double);
  CodeGenTypes.Add("currency",        "System.Decimal".AsTypeReference_NotNullable);
  CodeGenTypes.Add("widestring",      CGPredefinedTypeReference.String);
  CodeGenTypes.Add("ansistring",      CGPredefinedTypeReference.String);
  CodeGenTypes.Add("int64",           CGPredefinedTypeReference.Int64);
  CodeGenTypes.Add("boolean",         CGPredefinedTypeReference.Boolean);
  CodeGenTypes.Add("variant",         CGPredefinedTypeReference.Object);
  CodeGenTypes.Add("binary",          "RemObjects.SDK.Types.Binary".AsTypeReference_Nullable);
  CodeGenTypes.Add("xml",             "System.Xml.XmlNode".AsTypeReference_Nullable);
  CodeGenTypes.Add("guid",            "System.Guid".AsTypeReference_NotNullable);
  CodeGenTypes.Add("decimal",         "System.Decimal".AsTypeReference_NotNullable);
  CodeGenTypes.Add("utf8string",      CGPredefinedTypeReference.String);
  CodeGenTypes.Add("xsdatetime",      "RemObjects.SDK.Types.XsDateTime".AsTypeReference_Nullable);
  //CodeGenTypes.Add("nullableinteger", GenerateGenericType("System.Nullable", [CGPredefinedTypeReference.Int32]));
  //CodeGenTypes.Add("nullabledatetime",GenerateGenericType("System.Nullable", ["System.DateTime".AsTypeReference_NotNullable]));
  //CodeGenTypes.Add("nullabledouble",  GenerateGenericType("System.Nullable", [CGPredefinedTypeReference.Double]));
  //CodeGenTypes.Add("nullablecurrency",GenerateGenericType("System.Nullable", ["System.Decimal".AsTypeReference_NotNullable]));
  //CodeGenTypes.Add("nullableint64",   GenerateGenericType("System.Nullable", [CGPredefinedTypeReference.Int64]));
  //CodeGenTypes.Add("nullableboolean", GenerateGenericType("System.Nullable", [CGPredefinedTypeReference.Boolean]));
  //CodeGenTypes.Add("nullableguid",    GenerateGenericType("System.Nullable", ["System.Guid".AsTypeReference_NotNullable]));
  //CodeGenTypes.Add("nullabledecimal", GenerateGenericType("System.Nullable", ["System.Decimal".AsTypeReference_NotNullable]));

  CodeGenTypes.Add("nullableinteger", CGPredefinedTypeReference.Int32.copyWithNullability(CGTypeNullabilityKind.NullableNotUnwrapped));
  CodeGenTypes.Add("nullabledatetime","System.DateTime".AsTypeReference_Nullable2);
  CodeGenTypes.Add("nullabledouble",  CGPredefinedTypeReference.Double.copyWithNullability(CGTypeNullabilityKind.NullableNotUnwrapped));
  CodeGenTypes.Add("nullablecurrency","System.Decimal".AsTypeReference_Nullable2);
  CodeGenTypes.Add("nullableint64",   CGPredefinedTypeReference.Int64.copyWithNullability(CGTypeNullabilityKind.NullableNotUnwrapped));
  CodeGenTypes.Add("nullableboolean", CGPredefinedTypeReference.Boolean.copyWithNullability(CGTypeNullabilityKind.NullableNotUnwrapped));
  CodeGenTypes.Add("nullableguid",    "System.Guid".AsTypeReference_Nullable2);
  CodeGenTypes.Add("nullabledecimal", "System.Decimal".AsTypeReference_Nullable2);

  fStreamingFormats.Add("decimal", "Decimal");
  fStreamingFormats.Add("currency", "Currency");
  fStreamingFormats.Add("widestring", "WideString");
  fStreamingFormats.Add("ansistring", "AnsiString");
  fStreamingFormats.Add("utf8string", "Utf8String");
  fStreamingFormats.Add("variant", "Variant");

  fDontNeedDisposers.Add("integer");
  fDontNeedDisposers.Add("datetime");
  fDontNeedDisposers.Add("double");
  fDontNeedDisposers.Add("xsdatetime");
  fDontNeedDisposers.Add("widestring");
  fDontNeedDisposers.Add("ansistring");
  fDontNeedDisposers.Add("utf8string");
  fDontNeedDisposers.Add("currency");
  fDontNeedDisposers.Add("decimal");
  fDontNeedDisposers.Add("guid");
  fDontNeedDisposers.Add("int64");
  fDontNeedDisposers.Add("boolean");
end;

method EchoesRodlCodeGen.GenerateInterfaceCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit;
begin
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace,  aLibrary.Namespace, aLibrary.Name, "Unknown");

  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  lUnit.FileName := $"{aLibrary.Name}_Intf";
  lUnit.HeaderComment := GenerateUnitComment(false);

  AddDefaultClientNamespaces(lUnit);
  AddUsedNamespaces(lUnit, aLibrary);

  for aEntity: RodlArray in aLibrary.Arrays.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    Intf_GenerateArray(lUnit, aLibrary, aEntity);
  end;


  for aEntity: RodlEnum in aLibrary.Enums.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    Intf_GenerateEnum(lUnit, aLibrary, aEntity);
  end;

  for aEntity: RodlStruct in aLibrary.Structs.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    Intf_GenerateStruct(lUnit, aLibrary, aEntity);
    GenerateEntityActivator(lUnit, aLibrary, aEntity);
  end;

  for aEntity: RodlException in aLibrary.Exceptions.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    Intf_GenerateException(lUnit, aLibrary, aEntity);
  end;

  for aEntity: RodlEventSink in aLibrary.EventSinks.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    Intf_GenerateEventSink(lUnit, aLibrary, aEntity);
  end;

  if not ExcludeServices then begin
    for aEntity: RodlService in aLibrary.Services.Items{.Sort_OrdinalIgnoreCase(b->b.Name)} do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      Intf_GenerateServiceSync(lUnit, aLibrary, aEntity);
      Intf_GenerateServiceAsync(lUnit, aLibrary, aEntity);
    end;
  end;

  exit lUnit;
end;

method EchoesRodlCodeGen.GenerateInvokerCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit;
begin
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace,  aLibrary.Namespace, aLibrary.Name, "Unknown");

  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  lUnit.FileName := $"{aLibrary.Name}_Invk";
  lUnit.HeaderComment := GenerateUnitComment(false);

  AddDefaultServerNamespaces(lUnit);
  AddUsedNamespaces(lUnit, aLibrary);

  for aEntity: RodlService in aLibrary.Services.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    Invk_GenerateService(lUnit, aLibrary, aEntity);
    GenerateServiceActivator(lUnit, aLibrary, aEntity);
  end;

  for aEntity: RodlEventSink in aLibrary.EventSinks.SortedByAncestor do begin
    if not EntityNeedsCodeGen(aEntity) then continue;
    Invk_GenerateEventSink(lUnit, aLibrary, aEntity);
  end;

  exit lUnit;
end;

method EchoesRodlCodeGen.GenerateLegacyEventsFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): not nullable String;
begin
  result := "";
end;

method EchoesRodlCodeGen.GenerateImplementationFiles(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): not nullable Dictionary<String,String>;
begin
  var lunit := GenerateImplementationCodeUnit(aLibrary, aTargetNamespace, aServiceName);
  result := new Dictionary<String, String>;
  result.Add(Path.ChangeExtension(lunit.FileName, Generator.defaultFileExtension),
             Generator.GenerateUnit(lunit));
end;

method EchoesRodlCodeGen.GenerateImplementationCodeUnit(aLibrary: RodlLibrary; aTargetNamespace: String; aServiceName: String): CGCodeUnit;
begin
  var service := aLibrary.Services.FindEntity(aServiceName);
  if service = nil then raise new Exception($"{aServiceName} wasn't found!");
  if service.IsFromUsedRodl then begin
    aLibrary := service.FromUsedRodl.OwnerLibrary;
  end;

  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace,  aLibrary.Namespace, aLibrary.Name, "Unknown");
  var lUnit := new CGCodeUnit();
  lUnit.Namespace := new CGNamespaceReference(targetNamespace);
  lUnit.FileName := $"{aServiceName}_Impl";
  lUnit.HeaderComment := GenerateUnitComment(true);

  AddDefaultServerNamespaces(lUnit);
  AddUsedNamespaces(lUnit, aLibrary);

  Impl_GenerateService(lUnit, aLibrary, service);
  exit lUnit;
end;

method EchoesRodlCodeGen.Intf_GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var ltype := new CGEnumTypeDefinition(aEntity.Name,
                            BaseType := CGPredefinedTypeReference.Int32,
                            Visibility := CGTypeVisibilityKind.Public);
  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  ltype.Attributes.Add(new CGAttribute("RemObjects.SDK.Remotable".AsTypeReference_NotNullable));
  ltype.Attributes.Add(GenerateObfuscationAttribute);
  for rodl_member: RodlEnumValue in aEntity.Items index i do begin
    var cg4_member := new CGEnumValueDefinition(rodl_member.Name, i.AsLiteralExpression);
    cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    ltype.Members.Add(cg4_member);
  end;
  aFile.Types.Add(ltype);
end;

method EchoesRodlCodeGen.Intf_GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var lAncestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := "RemObjects.SDK.Types.ComplexType";
  var l_SafeEntityName := SafeIdentifier(aEntity.Name);

  var ltype := new CGClassTypeDefinition(l_SafeEntityName, lAncestorName.AsTypeReference_NotNullable,
                            &Partial := true,
                            Visibility := CGTypeVisibilityKind.Public);
  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  ltype.Attributes.Add(new CGAttribute("System.Serializable".AsTypeReference_NotNullable));
  ltype.Attributes.Add(new CGAttribute("RemObjects.SDK.Remotable".AsTypeReference_NotNullable,
                                         [new CGCallParameter(new CGTypeOfExpression(($"{l_SafeEntityName}_Activator").AsNamedIdentifierExpression), "ActivatorClass")]));
  ltype.Attributes.Add(GenerateObfuscationAttribute);

  {$REGION private ___%fldname%: %fldtype%}
  for laEntityItem: RodlTypedEntity in aEntity.Items do begin
    var l_fld := new CGFieldDefinition(self.INTF_FIELD_PREFIX + SafeIdentifier(laEntityItem.Name) ,
                                        ResolveDataTypeToTypeRef(aLibrary, laEntityItem.DataType),
                                        Visibility := CGMemberVisibilityKind.Private);
    {$REGION default value}
    if laEntityItem.CustomAttributes_lower.ContainsKey("default") then begin
      if CodeGenTypes.ContainsKey(laEntityItem.DataType.ToLowerInvariant) then begin
        var l_val := laEntityItem.CustomAttributes_lower.Item["default"];
        case laEntityItem.DataType.ToLowerInvariant of
          "integer":    l_fld.Initializer := Convert.ToInt32(l_val).AsLiteralExpression;
          //"datetime"
          "double":     l_fld.Initializer := Convert.ToDoubleInvariant(l_val).AsLiteralExpression;
          "currency":   l_fld.Initializer := Convert.ToDoubleInvariant(l_val).AsLiteralExpression;
          "widestring": l_fld.Initializer := l_val.AsLiteralExpression;
          "ansistring": l_fld.Initializer := l_val.AsLiteralExpression;
          "int64":      l_fld.Initializer := Convert.ToInt64(l_val).AsLiteralExpression;
          "boolean":    l_fld.Initializer := Convert.ToBoolean(l_val).AsLiteralExpression;
          //"variant"
          //"binary"
          //"xml"
          "guid":       l_fld.Initializer := new CGNewInstanceExpression("System.Guid".AsTypeReference_NotNullable, [l_val.AsLiteralExpression.AsCallParameter]);
          "decimal":    l_fld.Initializer := Convert.ToDoubleInvariant(l_val).AsLiteralExpression;
          "utf8string": l_fld.Initializer := l_val.AsLiteralExpression;
          //"xsdatetime"
          "nullableinteger": l_fld.Initializer := Convert.ToInt32(l_val).AsLiteralExpression;
          //"nullabledatetime"
          "nullabledouble":  l_fld.Initializer := Convert.ToDoubleInvariant(l_val).AsLiteralExpression;
          "nullablecurrency":l_fld.Initializer := Convert.ToDoubleInvariant(l_val).AsLiteralExpression;
          "nullableint64":   l_fld.Initializer := Convert.ToInt64(l_val).AsLiteralExpression;
          "nullableboolean": l_fld.Initializer := Convert.ToBoolean(l_val).AsLiteralExpression;
          "nullableguid":    l_fld.Initializer := new CGNewInstanceExpression("System.Guid".AsTypeReference_NotNullable,[l_val.AsLiteralExpression.AsCallParameter]);
          "nullabledecimal": l_fld.Initializer := Convert.ToDoubleInvariant(l_val).AsLiteralExpression;
        end;
      end;
    end;
    {$ENDREGION}
    ltype.Members.Add(l_fld);
  end;
  {$ENDREGION}
  {$REGION public %fldname%: %fldtype% read ___%fldname% write set_%fldname%; virtual;}
  for laEntityItem: RodlTypedEntity in aEntity.Items do begin
    var l_safe := laEntityItem.Name;
    var l_fld := self.INTF_FIELD_PREFIX + l_safe;
    var l_prop := new CGPropertyDefinition(l_safe,
                                          ResolveDataTypeToTypeRef(aLibrary, laEntityItem.DataType),
                                          Virtuality := CGMemberVirtualityKind.Virtual,
                                          Visibility := CGMemberVisibilityKind.Public);
    l_prop.XmlDocumentation := GenerateDocumentation(laEntityItem);
    l_prop.GetExpression := l_fld.AsNamedIdentifierExpression;
    l_prop.SetStatements := [new CGAssignmentStatement(l_fld.AsNamedIdentifierExpression, CGPropertyValueExpression.PropertyValue),
                             new CGMethodCallExpression(CGSelfExpression.Self, "TriggerPropertyChanged",[l_safe.AsLiteralExpression.AsCallParameter])].ToList;
    var sf := GetStreamingFormat(aLibrary, laEntityItem.DataType);
    if sf <> nil then begin
      l_prop.Attributes.Add(new CGAttribute("RemObjects.SDK.StreamAs".AsTypeReference_NotNullable,[sf.AsNamedIdentifierExpression.AsCallParameter]));
    end;
    ltype.Members.Add(l_prop);
  end;

  {$ENDREGION}
  Intf_StructReadMethod(aLibrary, ltype, aEntity);
  Intf_StructWriteMethod(aLibrary, ltype, aEntity);
  GenerateCustomAttributeHandlers(ltype, aEntity);
  aFile.Types.Add(ltype);
end;

method EchoesRodlCodeGen.Intf_GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
begin
  var l_safename := SafeIdentifier(aEntity.Name);
  if aEntity.HasCustomAttributes or not String.IsNullOrEmpty(aEntity.Documentation) then begin
    var ltype := new CGClassTypeDefinition(l_safename,
                                             GenerateGenericType("RemObjects.SDK.Types.ArrayType", [ResolveDataTypeToTypeRef(aLibrary, aEntity.ElementType)]),
                                             &Partial := true,
                                             Visibility := CGTypeVisibilityKind.Public);
    ltype.XmlDocumentation := GenerateDocumentation(aEntity);
    ltype.Attributes.Add(new CGAttribute("System.Serializable".AsTypeReference_NotNullable));
    ltype.Attributes.Add(new CGAttribute("RemObjects.SDK.Remotable".AsTypeReference_NotNullable));
    GenerateCustomAttributeHandlers(ltype, aEntity);
    aFile.Types.Add(ltype);
  end;
end;

method EchoesRodlCodeGen.Intf_GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
begin
  const l_Message_paramname: String = "aMessage";
  var l_FromServer_paramname: String := "aFromServer";

  var lAncestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := "RemObjects.SDK.Types.ServerException";
  var l_SafeEntityName := SafeIdentifier(aEntity.Name);

  var ltype := new CGClassTypeDefinition(l_SafeEntityName, lAncestorName.AsTypeReference_NotNullable,
                            &Partial := true,
                            Visibility := CGTypeVisibilityKind.Public);
  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  ltype.Attributes.Add(new CGAttribute("RemObjects.SDK.Remotable".AsTypeReference_NotNullable));
  ltype.Attributes.Add(GenerateObfuscationAttribute);
  {$REGION public constructor(Message: System.String)}
  var l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition(l_Message_paramname, ResolveStdtypes(CGPredefinedTypeReference.String)));
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [l_Message_paramname.AsNamedIdentifierExpression.AsCallParameter]));
  ltype.Members.Add(l_ctor);
  {$ENDREGION}

  {$REGION public constructor(Message: System.String; FromServer: System.Boolean)}
  l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition(l_Message_paramname, ResolveStdtypes(CGPredefinedTypeReference.String)));
  l_ctor.Parameters.Add(new CGParameterDefinition(l_FromServer_paramname, ResolveStdtypes(CGPredefinedTypeReference.Boolean)));

  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                      [l_Message_paramname.AsNamedIdentifierExpression.AsCallParameter,
                                                       l_FromServer_paramname.AsNamedIdentifierExpression.AsCallParameter]));
  ltype.Members.Add(l_ctor);
  {$ENDREGION}

  if aEntity.Items.Count > 0  then begin
    if (aEntity.Items.Count = 1) and (aEntity.Items[0].DataType.ToLower = "boolean") then
      l_ctor := nil
    else begin
      l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
      l_ctor.Parameters.Add(new CGParameterDefinition(l_Message_paramname, ResolveStdtypes(CGPredefinedTypeReference.String)));
      l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [l_Message_paramname.AsNamedIdentifierExpression.AsCallParameter]));
      ltype.Members.Add(l_ctor);
    end;

    {$REGION public %fldname%: %fldtype% read ___%fldname% write ___%fldname%; virtual;}
    for laEntityItem: RodlTypedEntity in aEntity.Items do begin
      var l_name := laEntityItem.Name;
      var l_name_paramname := $"a{laEntityItem.Name}";
      var l_type := ResolveDataTypeToTypeRef(aLibrary, laEntityItem.DataType);
      var l_prop := new CGPropertyDefinition(l_name,
                                             l_type,
                                             Virtuality := CGMemberVirtualityKind.Virtual,
                                             Visibility := CGMemberVisibilityKind.Public);
      var sf := GetStreamingFormat(aLibrary, laEntityItem.DataType);
      if sf <> nil then begin
        l_prop.Attributes.Add(new CGAttribute("RemObjects.SDK.StreamAs".AsTypeReference_NotNullable,[sf.AsNamedIdentifierExpression.AsCallParameter]));
      end;
      ltype.Members.Add(l_prop);

      if l_ctor <> nil then begin
        l_ctor.Parameters.Add(new CGParameterDefinition(l_name_paramname, l_type));
        l_ctor.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(CGSelfExpression.Self, l_name),
                                                        l_name_paramname.AsNamedIdentifierExpression));
      end;
    end;
    {$ENDREGION}
  end;
  GenerateCustomAttributeHandlers(ltype, aEntity);
  aFile.Types.Add(ltype);
end;

method EchoesRodlCodeGen.Intf_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  var lAncestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(aEntity.AncestorName) then
    lAncestorName := "RemObjects.SDK.IROEventSink"
  else
    lAncestorName := $"I{aEntity.AncestorName}";
  var l_SafeEntityName := SafeIdentifier(aEntity.Name);
  var l_eventName := $"I{l_SafeEntityName}";

  var ltype := new CGInterfaceTypeDefinition(l_eventName, lAncestorName.AsTypeReference_NotNullable,
                            Visibility := CGTypeVisibilityKind.Public);
  ltype.XmlDocumentation := GenerateDocumentation(aEntity);
  ltype.Attributes.Add(GenerateObfuscationAttribute);
  var l_invokername := $"{l_SafeEntityName}_EventSinkInvoker";
  ltype.Attributes.Add(new CGAttribute("RemObjects.SDK.EventSink".AsTypeReference_NotNullable,
                                       [new CGCallParameter(l_SafeEntityName.AsLiteralExpression, "Name"),
                                        new CGCallParameter(new CGTypeOfExpression(l_invokername.AsNamedIdentifierExpression), "InvokerClass")]));

  for rodl_member in aEntity.DefaultInterface.Items do begin
    {$REGION eventsink methods}
    var cg4_member := new CGMethodDefinition(rodl_member.Name,
                                      Visibility := CGMemberVisibilityKind.Public);
    cg4_member.XmlDocumentation := GenerateDocumentation(rodl_member);
    for rodl_param in rodl_member.Items do begin
      if rodl_param.ParamFlag <> ParamFlags.Result then begin

        var cg4_param := new CGParameterDefinition(rodl_param.Name,
                                                   ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType));
        if rodl_param.ParamFlag = ParamFlags.In then
          cg4_param.Modifier := CGParameterModifierKind.In
        else
          raise new Exception($"Parameter type {rodl_param.ParamFlag} is not supported for event sinks. Parameter name: {aEntity.Name}.{rodl_param.Name}");
        cg4_member.Parameters.Add(cg4_param);
      end;
    end;
    ltype.Members.Add(cg4_member);
    {$ENDREGION}
  end;

  aFile.Types.Add(ltype);
  {$REGION %eventsink%_EventSinkInvoker}
  lAncestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lAncestorName) then
    lAncestorName := "RemObjects.SDK.EventSinkInvoker"
  else
    lAncestorName := $"{lAncestorName}_EventSinkInvoker";
  var l_invoker := new CGClassTypeDefinition(l_invokername,
                                             lAncestorName.AsTypeReference_NotNullable,
                                             Visibility := CGTypeVisibilityKind.Public);
  l_invoker.Attributes.Add(GenerateObfuscationAttribute);

  aFile.Types.Add(l_invoker);


  {$REGION Invoke_%method%}
  for rodl_member in aEntity.DefaultInterface.Items do begin
    var l_invokermethod := new CGMethodDefinition($"Invoke_{rodl_member.Name}",
                                                  &Static := true,
                                                  Visibility := CGMemberVisibilityKind.Public);
    l_invokermethod.Attributes.Add(GenerateObfuscationAttribute);
    l_invokermethod.Parameters.Add(new CGParameterDefinition(self.INTF_EVENT_HANDLERS_PARAMETER, "RemObjects.SDK.IROEventSinkHandlers".AsTypeReference_NotNullable));
    l_invokermethod.Parameters.Add(new CGParameterDefinition(self.INTF_MESSAGE_PARAMETER, "RemObjects.SDK.IMessage".AsTypeReference_NotNullable));

    var isDisposerNeeded := false;
    for rodl_param in rodl_member.Items do
      if IsParameterDisposerNeeded(rodl_param) then begin
        isDisposerNeeded := true;
        break;
      end;

    var l_body: List<CGStatement> := nil;
    if isDisposerNeeded then begin
      l_invokermethod.Statements.Add(
          new CGVariableDeclarationStatement(self.OBJECT_DISPOSER_NAME,
                                              "RemObjects.SDK.ObjectDisposer".AsTypeReference_NotNullable,
                                              new CGNewInstanceExpression("RemObjects.SDK.ObjectDisposer".AsNamedIdentifierExpression)));
      l_body := new List<CGStatement>;
      var l_try := new CGTryFinallyCatchStatement(l_body);
      l_try.FinallyStatements.Add(new CGMethodCallExpression(self.OBJECT_DISPOSER_NAME.AsNamedIdentifierExpression, "Dispose"));
      l_invokermethod.Statements.Add(l_try);
    end
    else
     l_body := l_invokermethod.Statements;


    for rodl_param in rodl_member.Items do begin
      l_body.Add(new CGVariableDeclarationStatement(rodl_param.Name,
                                                    ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType),
                                                    Value := Intf_generateReadStatement(aLibrary,
                                                                                        self.INTF_MESSAGE_PARAMETER.AsNamedIdentifierExpression,
                                                                                        rodl_param)));
      if IsParameterDisposerNeeded(rodl_param) then
        l_body.Add(new CGMethodCallExpression(self.OBJECT_DISPOSER_NAME.AsNamedIdentifierExpression,
                                              "Add",
                                              [rodl_param.Name.AsNamedIdentifierExpression.AsCallParameter]));
    end;
    var l_cast := new CGTypeCastExpression(new CGArrayElementAccessExpression(self.INTF_EVENT_HANDLERS_PARAMETER.AsNamedIdentifierExpression,
                                                                              [self.INTF_INDEX.AsNamedIdentifierExpression]),
                                           l_eventName.AsTypeReference_NotNullable,
                                           true);
    var l_callmethod := new CGMethodCallExpression(l_cast, rodl_member.Name);
    for rodl_param in rodl_member.Items do
      l_callmethod.Parameters.Add(new CGCallParameter(rodl_param.Name.AsNamedIdentifierExpression));

    var l_cond := new CGBinaryOperatorExpression(new CGPropertyAccessExpression(self.INTF_EVENT_HANDLERS_PARAMETER.AsNamedIdentifierExpression, "Count"),
                                                 1.AsLiteralExpression,
                                                 CGBinaryOperatorKind.Subtraction);
    l_body.Add(new CGForToLoopStatement(self.INTF_INDEX,
                                                            CGPredefinedTypeReference.Int32,
                                                            0.AsLiteralExpression,
                                                            l_cond,
                                                            l_callmethod));
    l_invoker.Members.Add(l_invokermethod);
  end;
  {$ENDREGION}
  {$ENDREGION}

end;

method EchoesRodlCodeGen.Intf_GenerateServiceSync(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_EntityName := aEntity.Name;
  var l_IName := $"I{l_EntityName}";

  var l_intf := new CGInterfaceTypeDefinition(l_IName,
                                             Visibility := CGTypeVisibilityKind.Public);
  l_intf.XmlDocumentation := GenerateDocumentation(aEntity);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    l_intf.Ancestors.Add(ResolveDataTypeToTypeRef(aLibrary, $"I{aEntity.AncestorName}", aEntity.AncestorName))  //I%ancestor%
  else
    l_intf.Ancestors.Add("RemObjects.SDK.IROService".AsTypeReference_NotNullable);

  aFile.Types.Add(l_intf);
  var l_proxy := new CGClassTypeDefinition($"{aEntity.Name}_Proxy", //%service%_Proxy
                                           &Partial := true,
                                           Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    l_proxy.Ancestors.Add(ResolveDataTypeToTypeRef(aLibrary, $"{aEntity.AncestorName}_Proxy", aEntity.AncestorName))  //%ancestor%_Proxy
  else
    l_proxy.Ancestors.Add("RemObjects.SDK.Proxy".AsTypeReference_NotNullable);
  l_proxy.ImplementedInterfaces.Add(l_intf.Name.AsTypeReference_NotNullable);
  aFile.Types.Add(l_proxy);

  Intf_GenerateServiceProxyConstructors(l_proxy);
  Intf_GenerateServiceProxyInterfaceNameProperty(l_proxy, aEntity);


  for rodl_member in aEntity.DefaultInterface.Items do begin
    var l_intfmethod := new CGMethodDefinition(rodl_member.Name,
                                               Visibility := CGMemberVisibilityKind.Public);
    l_intfmethod.XmlDocumentation := GenerateDocumentation(rodl_member);
    var l_proxymethod := new CGMethodDefinition(rodl_member.Name,
                                                ImplementsInterface := $"I{aEntity.Name}".AsTypeReference_NotNullable,
                                                ImplementsInterfaceMember := rodl_member.Name,
                                                Virtuality := CGMemberVirtualityKind.Virtual,
                                                Visibility := CGMemberVisibilityKind.Public);

    for rodl_param in rodl_member.Items do begin
      if rodl_param.ParamFlag <> ParamFlags.Result then begin
        var cg4_param := new CGParameterDefinition(rodl_param.Name, ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType));
        cg4_param.XmlDocumentation := GenerateDocumentation(rodl_param);
        case rodl_param.ParamFlag of
          ParamFlags.In: cg4_param.Modifier := CGParameterModifierKind.In;
          ParamFlags.InOut: cg4_param.Modifier := CGParameterModifierKind.Var;
          ParamFlags.Out: cg4_param.Modifier := CGParameterModifierKind.Out;
        end;
        l_intfmethod.Parameters.Add(cg4_param);
        l_proxymethod.Parameters.Add(cg4_param);
      end;
    end;
    if rodl_member.Result <> nil then begin
      l_intfmethod.ReturnType := ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType);
      l_proxymethod.ReturnType := l_intfmethod.ReturnType;
    end;
    l_intf.Members.Add(l_intfmethod);
    l_proxy.Members.Add(l_proxymethod);
    l_proxymethod.Statements.Add(new CGVariableDeclarationStatement(self.INTF_LOCAL_MESSAGE,
                                                                    "RemObjects.SDK.IMessage".AsTypeReference_NotNullable,
                                                                    new CGMethodCallExpression(CGSelfExpression.Self, self.INTF_GET_MESSAGE)));
    var l_localmessage := self.INTF_LOCAL_MESSAGE.AsNamedIdentifierExpression;
    var l_channel := (new CGPropertyAccessExpression(CGSelfExpression.Self, "ClientChannel"));
    var l_body := new List<CGStatement>;
    var aNames: List<CGExpression>;
    var aValues: List<CGExpression>;
    GenerateAttributes(aLibrary,  aEntity, rodl_member, out aNames, out aValues);
    if aNames.Count > 0 then begin
      l_body.Add(new CGMethodCallExpression(l_localmessage,
                                            "SetAttributes",
                                            [l_channel.AsCallParameter,
                                            new CGArrayLiteralExpression(aNames, CGPredefinedTypeReference.String).AsCallParameter,
                                            new CGArrayLiteralExpression(aValues, CGPredefinedTypeReference.String).AsCallParameter]));

    end;
    l_body.Add(new CGMethodCallExpression(l_localmessage,
                                          "InitializeRequestMessage",
                                          [l_channel.AsCallParameter,
                                           aLibrary.Name.AsLiteralExpression.AsCallParameter,
                                           (new CGPropertyAccessExpression(CGSelfExpression.Self, "ActiveInterfaceName")).AsCallParameter,
                                           rodl_member.Name.AsLiteralExpression.AsCallParameter]));

    for rodl_param in rodl_member.Items do
      if rodl_param.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
        l_body.Add(Intf_generateWriteStatement(aLibrary, l_localmessage, rodl_param));

    l_body.Add(new CGMethodCallExpression(l_localmessage, "FinalizeMessage"));
    l_body.Add(new CGMethodCallExpression(l_channel,"Dispatch",[l_localmessage.AsCallParameter]));
    var l_localResultName: String := nil;
    if rodl_member.Result <> nil then begin
      l_localResultName := $"_{rodl_member.Result.Name}";
      while rodl_member.FindEntity(l_localResultName) <> nil do
        l_localResultName := $"_{l_localResultName}";
      l_body.Add(new CGVariableDeclarationStatement(l_localResultName,
                                                    ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType),
                                                    Intf_generateReadStatement(aLibrary, l_localmessage, rodl_member.Result)));
    end;

    for rodl_param in rodl_member.Items do
      if rodl_param.ParamFlag in [ParamFlags.InOut,ParamFlags.Out] then
        l_body.Add(new CGAssignmentStatement(rodl_param.Name.AsNamedIdentifierExpression, Intf_generateReadStatement(aLibrary, l_localmessage, rodl_param)));

    if rodl_member.Result <> nil then
      l_body.Add(new CGReturnStatement(l_localResultName.AsNamedIdentifierExpression));

    var l_try := new CGTryFinallyCatchStatement(l_body);
    if aNames.Count > 0 then
      l_try.FinallyStatements.Add(new CGMethodCallExpression(l_localmessage, "ClearAttributes",[l_channel.AsCallParameter]));
    l_try.FinallyStatements.Add(new CGMethodCallExpression(CGSelfExpression.Self, self.INTF_CLEAR_MESSAGE,[l_localmessage.AsCallParameter]));
    l_proxymethod.Statements.Add(l_try);
  end;

  Intf_GenerateCoService(aFile, $"Co{l_EntityName}", l_intf.Name, l_proxy.Name);
end;

method EchoesRodlCodeGen.GetIncludesNamespace(aLibrary: RodlLibrary): String;
begin
  if assigned(aLibrary.Includes) then exit aLibrary.Includes.NetModule;
  exit inherited GetIncludesNamespace(aLibrary);
end;


method EchoesRodlCodeGen.AddUsedNamespaces(file: CGCodeUnit; aLibrary: RodlLibrary);
begin
  for each rodl in aLibrary.Uses.Items do begin

    if not String.IsNullOrEmpty(rodl.Namespace) then begin
      file.Imports.Add(new CGImport(rodl.Namespace));
      continue;
    end;

    if rodl.Name.StartsWith("DataAbstract") then begin
      file.Imports.Add(new CGImport("RemObjects.DataAbstract.Server"));
      continue;
    end;

    if file.HeaderComment = nil then file.HeaderComment := new CGCommentStatement;
    file.HeaderComment.Lines.Add($"Requires RODL file {rodl.Name} ({rodl.FileName}) in the same namespace.");
    if not rodl.Loaded then
      file.HeaderComment.Lines.Add($"WARNING! RODL file {rodl.Name} ({rodl.FileName}) was not found by the code generator.");
    file.HeaderComment.Lines.Add("");
  end;
end;


method EchoesRodlCodeGen.AddDefaultServerNamespaces(aUnit: CGCodeUnit);
begin
  AddDefaultClientNamespaces(aUnit);

  aUnit.Imports.Add(new CGImport("RemObjects.SDK.Server"));
  aUnit.Imports.Add(new CGImport("RemObjects.SDK.Server.ClassFactories"));
end;


method EchoesRodlCodeGen.AddDefaultClientNamespaces(aUnit: CGCodeUnit);
begin
  aUnit.Imports.Add(new CGImport("System"));
  aUnit.Imports.Add(new CGImport("System.Collections.Generic"));
  aUnit.Imports.Add(new CGImport("RemObjects.SDK"));
  aUnit.Imports.Add(new CGImport("RemObjects.SDK.Types"));
end;

method EchoesRodlCodeGen.GenerateEntityActivator(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var l_SafeEntityName := SafeIdentifier(aEntity.Name);
  var l_activator := new CGClassTypeDefinition(
                            $"{l_SafeEntityName}_Activator",
                            CGPredefinedTypeReference.Object, // VB.NET workaround
                            ["RemObjects.SDK.ITypeActivator".AsTypeReference_NotNullable].ToList,
                            Visibility := CGTypeVisibilityKind.Public);
  l_activator.Attributes.Add(new CGAttribute("System.Reflection.ObfuscationAttribute".AsTypeReference_NotNullable,
                                             [new CGCallParameter(true.AsLiteralExpression, "Exclude"),
                                              new CGCallParameter(false.AsLiteralExpression, "ApplyToMembers")
                                              ]));
  l_activator.Members.Add(new CGConstructorDefinition(&Empty := true,
                                                      Visibility := CGMemberVisibilityKind.Public));
  var l_method := new CGMethodDefinition("CreateInstance",
                                         [new CGNewInstanceExpression(l_SafeEntityName.AsTypeReference_NotNullable).AsReturnStatement],
                                         ImplementsInterface := "RemObjects.SDK.ITypeActivator".AsTypeReference_NotNullable,
                                         ImplementsInterfaceMember := "CreateInstance",
                                         ReturnType := CGPredefinedTypeReference.Object.copyWithNullability(CGTypeNullabilityKind.NotNullable),
                                        // Virtuality := CGMemberVirtualityKind.Final,
                                         Visibility := CGMemberVisibilityKind.Public);
  l_activator.Members.Add(l_method);
  aFile.Types.Add(l_activator);
end;


method EchoesRodlCodeGen.GenerateCustomAttributeHandlers(aType: CGTypeDefinition; aRodlEntity: RodlEntity);
begin
  if aRodlEntity.HasCustomAttributes then begin
    var l_nameCases := new List<CGSwitchStatementCase>;
    var l_valueCases := new List<CGSwitchStatementCase>;
    var l_default := new List<CGStatement>;
    for each x in aRodlEntity.CustomAttributes index i do begin
      l_nameCases.Add(new CGSwitchStatementCase(i.AsLiteralExpression, x.Key.ToLowerInvariant.AsLiteralExpression.AsReturnStatement));
      l_valueCases.Add(new CGSwitchStatementCase(i.AsLiteralExpression, x.Value.AsLiteralExpression.AsReturnStatement));
    end;
    l_default.Add((new CGNilExpression).AsReturnStatement);

    aType.Members.Add(new CGMethodDefinition("GetAttributeName",
                                             [new CGSwitchStatement("anIndex".AsNamedIdentifierExpression,
                                                                    l_nameCases,
                                                                    l_default)],
                                             Parameters := [new CGParameterDefinition("anIndex", CGPredefinedTypeReference.Int32)].ToList,
                                             ReturnType := CGPredefinedTypeReference.String,
                                             Virtuality := CGMemberVirtualityKind.Override,
                                             Visibility := CGMemberVisibilityKind.Public));

    aType.Members.Add(new CGMethodDefinition("GetAttributeValue",
                                             [new CGSwitchStatement("anIndex".AsNamedIdentifierExpression,
                                                                    l_valueCases,
                                                                    l_default)],
                                             Parameters := [new CGParameterDefinition("anIndex", CGPredefinedTypeReference.Int32)].ToList,
                                             ReturnType := CGPredefinedTypeReference.String,
                                             Virtuality := CGMemberVirtualityKind.Override,
                                             Visibility := CGMemberVisibilityKind.Public));

    aType.Members.Add(new CGMethodDefinition("GetAttributeCount",
                                             [aRodlEntity.CustomAttributes.Count.AsLiteralExpression.AsReturnStatement],
                                             ReturnType := ResolveStdtypes(CGPredefinedTypeReference.Int32),
                                             Virtuality := CGMemberVirtualityKind.Override,
                                             Visibility := CGMemberVisibilityKind.Public));
  end;
end;


method EchoesRodlCodeGen.GenerateGenericType(aType: String; aGenericParams: array of CGTypeReference): CGTypeReference;
begin
  var lResult := new CGNamedTypeReference(aType);
  lResult.DefaultNullability := CGTypeNullabilityKind.NotNullable;
  lResult.GenericArguments := new List<CGTypeReference>;
  lResult.GenericArguments.Add(aGenericParams);
  exit lResult;
end;


method EchoesRodlCodeGen.GetStreamingFormat(aLibrary: RodlLibrary; dataType: String): String;
begin
  var lLower: String := dataType.ToLowerInvariant();
  if fStreamingFormats.ContainsKey(lLower) then
    exit $"RemObjects.SDK.StreamingFormat.{fStreamingFormats[lLower]}";

  var lArray: RodlArray := RodlArray(aLibrary.Arrays.FindEntity(dataType));
  if assigned(lArray) then
    exit GetStreamingFormat(aLibrary, lArray.ElementType);

  exit nil;
end;

method EchoesRodlCodeGen.GetGlobalName(aLibrary: RodlLibrary): String;
begin
  exit $"{aLibrary.Name}_Defines";
end;

method EchoesRodlCodeGen.Intf_StructReadMethod(aLibrary: RodlLibrary; aStruct: CGTypeDefinition; aRodlStruct: RodlStruct);
begin
  var lMethod := new CGMethodDefinition("ReadComplex",
                                        Virtuality := CGMemberVirtualityKind.Override,
                                        Visibility := CGMemberVisibilityKind.Public);
  lMethod.Parameters.Add(new CGParameterDefinition("serializer", "RemObjects.SDK.Serializer".AsTypeReference_NotNullable));

  var ifStatement := new CGBeginEndBlockStatement;
  var elseStatement := new CGBeginEndBlockStatement;
  var l_serializer := "serializer".AsNamedIdentifierExpression;
  var lif := new CGIfThenElseStatement(new CGPropertyAccessExpression(l_serializer, "RecordStrictOrder"),
                                       ifStatement,
                                       elseStatement);
  if aRodlStruct.AncestorEntity <> nil then
    ifStatement.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, "ReadComplex",[l_serializer.AsCallParameter]));


  for each laEntityItem in aRodlStruct.Items do begin
    ifStatement.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(CGSelfExpression.Self, laEntityItem.Name),
                                                         Intf_generateReadStatement(aLibrary, l_serializer, laEntityItem)));
  end;


  for each laEntityItem in aRodlStruct.GetAllItems.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    elseStatement.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(CGSelfExpression.Self, laEntityItem.Name),
                                                           Intf_generateReadStatement(aLibrary, l_serializer, laEntityItem)));
  end;
  lMethod.Statements.Add(lif);
  aStruct.Members.Add(lMethod);
end;

method EchoesRodlCodeGen.Intf_generateReadStatement(aLibrary: RodlLibrary; aSerializer: CGExpression; aEntity: RodlTypedEntity): CGExpression;
begin
  var l_name := aEntity.Name.AsLiteralExpression.AsCallParameter;
  case aEntity.DataType.ToLowerInvariant of
    "integer":          exit new CGMethodCallExpression(aSerializer, "ReadInt32",           [l_name]);
    "datetime":         exit new CGMethodCallExpression(aSerializer, "ReadDateTime",        [l_name]);
    "double":           exit new CGMethodCallExpression(aSerializer, "ReadDouble",          [l_name]);
    "currency":         exit new CGMethodCallExpression(aSerializer, "ReadCurrency",        [l_name]);
    "ansistring":       exit new CGMethodCallExpression(aSerializer, "ReadAnsiString",      [l_name]);
    "utf8string":       exit new CGMethodCallExpression(aSerializer, "ReadUtf8String",      [l_name]);
    "int64":            exit new CGMethodCallExpression(aSerializer, "ReadInt64",           [l_name]);
    "boolean":          exit new CGMethodCallExpression(aSerializer, "ReadBoolean",         [l_name]);
    "variant":          exit new CGMethodCallExpression(aSerializer, "ReadVariant",         [l_name]);
    "xml":              exit new CGMethodCallExpression(aSerializer, "ReadXml",             [l_name]);
    "guid":             exit new CGMethodCallExpression(aSerializer, "ReadGuid",            [l_name]);
    "decimal":          exit new CGMethodCallExpression(aSerializer, "ReadDecimal",         [l_name]);
    "widestring":       exit new CGMethodCallExpression(aSerializer, "ReadWideString",      [l_name]);
    "nullableboolean":  exit new CGMethodCallExpression(aSerializer, "ReadNullableBoolean", [l_name]);
    "nullablecurrency": exit new CGMethodCallExpression(aSerializer, "ReadNullableCurrency",[l_name]);
    "nullabledatetime": exit new CGMethodCallExpression(aSerializer, "ReadNullableDateTime",[l_name]);
    "nullabledecimal":  exit new CGMethodCallExpression(aSerializer, "ReadNullableDecimal", [l_name]);
    "nullabledouble":   exit new CGMethodCallExpression(aSerializer, "ReadNullableDouble",  [l_name]);
    "nullableguid":     exit new CGMethodCallExpression(aSerializer, "ReadNullableGuid",    [l_name]);
    "nullableint64":    exit new CGMethodCallExpression(aSerializer, "ReadNullableInt64",   [l_name]);
    "nullableinteger":  exit new CGMethodCallExpression(aSerializer, "ReadNullableInt32",   [l_name]);
  else
    var ltype: CGTypeReference := self.ResolveDataTypeToTypeRef(aLibrary, aEntity.DataType);
    var le: CGExpression;
    if (ltype is CGNamedTypeReference) and (CGNamedTypeReference(ltype).GenericArguments = nil) then
      le := CGNamedTypeReference(ltype).FullName.AsNamedIdentifierExpression
    else
      le := ltype.AsExpression;
    var lformat := GetStreamingFormat(aLibrary, aEntity.DataType);
    if lformat = nil then lformat := "RemObjects.SDK.StreamingFormat.Default";
    exit new CGTypeCastExpression(
          new CGMethodCallExpression(aSerializer,
                                     "Read",
                                     [l_name,
                                     new CGTypeOfExpression(le).AsCallParameter,
                                     lformat.AsNamedIdentifierExpression.AsCallParameter]),
          ltype,
          true);
  end;
end;

method EchoesRodlCodeGen.Intf_generateWriteStatement(aLibrary: RodlLibrary; aSerializer: CGExpression; aEntity: RodlTypedEntity): CGExpression;
begin
  var l_name := aEntity.Name.AsLiteralExpression.AsCallParameter;
  var l_value :=
    if aEntity is RodlParameter then
      new CGPropertyAccessExpression(nil, aEntity.Name).AsCallParameter
    else
      new CGPropertyAccessExpression(CGSelfExpression.Self, aEntity.Name).AsCallParameter;
  case aEntity.DataType.ToLowerInvariant of
    "integer":          exit new CGMethodCallExpression(aSerializer, "WriteInt32",           [l_name, l_value]);
    "datetime":         exit new CGMethodCallExpression(aSerializer, "WriteDateTime",        [l_name, l_value]);
    "double":           exit new CGMethodCallExpression(aSerializer, "WriteDouble",          [l_name, l_value]);
    "currency":         exit new CGMethodCallExpression(aSerializer, "WriteCurrency",        [l_name, l_value]);
    "ansistring":       exit new CGMethodCallExpression(aSerializer, "WriteAnsiString",      [l_name, l_value]);
    "utf8string":       exit new CGMethodCallExpression(aSerializer, "WriteUtf8String",      [l_name, l_value]);
    "int64":            exit new CGMethodCallExpression(aSerializer, "WriteInt64",           [l_name, l_value]);
    "boolean":          exit new CGMethodCallExpression(aSerializer, "WriteBoolean",         [l_name, l_value]);
    "variant":          exit new CGMethodCallExpression(aSerializer, "WriteVariant",         [l_name, l_value]);
    "xml":              exit new CGMethodCallExpression(aSerializer, "WriteXml",             [l_name, l_value]);
    "guid":             exit new CGMethodCallExpression(aSerializer, "WriteGuid",            [l_name, l_value]);
    "decimal":          exit new CGMethodCallExpression(aSerializer, "WriteDecimal",         [l_name, l_value]);
    "widestring":       exit new CGMethodCallExpression(aSerializer, "WriteWideString",      [l_name, l_value]);
    "nullableboolean":  exit new CGMethodCallExpression(aSerializer, "WriteNullableBoolean", [l_name, l_value]);
    "nullablecurrency": exit new CGMethodCallExpression(aSerializer, "WriteNullableCurrency",[l_name, l_value]);
    "nullabledatetime": exit new CGMethodCallExpression(aSerializer, "WriteNullableDateTime",[l_name, l_value]);
    "nullabledecimal":  exit new CGMethodCallExpression(aSerializer, "WriteNullableDecimal", [l_name, l_value]);
    "nullabledouble":   exit new CGMethodCallExpression(aSerializer, "WriteNullableDouble",  [l_name, l_value]);
    "nullableguid":     exit new CGMethodCallExpression(aSerializer, "WriteNullableGuid",    [l_name, l_value]);
    "nullableint64":    exit new CGMethodCallExpression(aSerializer, "WriteNullableInt64",   [l_name, l_value]);
    "nullableinteger":  exit new CGMethodCallExpression(aSerializer, "WriteNullableInt32",   [l_name, l_value]);
  else
    var ltype := self.ResolveDataTypeToTypeRef(aLibrary, aEntity.DataType);
    var le: CGExpression;
    if (ltype is CGNamedTypeReference) and (CGNamedTypeReference(ltype).GenericArguments = nil) then
      le := CGNamedTypeReference(ltype).FullName.AsNamedIdentifierExpression
    else
      le := ltype.AsExpression;
    var lformat := GetStreamingFormat(aLibrary, aEntity.DataType);
    if String.IsNullOrEmpty(lformat) then lformat := "RemObjects.SDK.StreamingFormat.Default";
    exit new CGMethodCallExpression(aSerializer,
                                   "Write",
                                   [l_name,
                                    l_value,
                                    new CGTypeOfExpression(le).AsCallParameter,
                                    lformat.AsNamedIdentifierExpression.AsCallParameter]);
  end;
end;

method EchoesRodlCodeGen.Intf_StructWriteMethod(aLibrary: RodlLibrary; aStruct: CGTypeDefinition; aRodlStruct: RodlStruct);
begin
  var lMethod := new CGMethodDefinition("WriteComplex",
                                        Virtuality := CGMemberVirtualityKind.Override,
                                        Visibility := CGMemberVisibilityKind.Public);
  lMethod.Parameters.Add(new CGParameterDefinition("serializer", "RemObjects.SDK.Serializer".AsTypeReference_NotNullable));

  var ifStatement := new CGBeginEndBlockStatement;
  var elseStatement := new CGBeginEndBlockStatement;
  var lif := new CGIfThenElseStatement(new CGPropertyAccessExpression("serializer".AsNamedIdentifierExpression, "RecordStrictOrder"),
                                       ifStatement,
                                       elseStatement);
  if aRodlStruct.AncestorEntity <> nil then
    ifStatement.Statements.Add(new CGMethodCallExpression(CGInheritedExpression.Inherited, "WriteComplex",["serializer".AsNamedIdentifierExpression.AsCallParameter]));

  var l_serializer := "serializer".AsNamedIdentifierExpression;
  for each laEntityItem in aRodlStruct.Items do
    ifStatement.Statements.Add(Intf_generateWriteStatement(aLibrary, l_serializer, laEntityItem));

  for each laEntityItem in aRodlStruct.GetAllItems.Sort_OrdinalIgnoreCase(b->b.Name) do
    elseStatement.Statements.Add(Intf_generateWriteStatement(aLibrary, l_serializer, laEntityItem));

  lMethod.Statements.Add(lif);
  aStruct.Members.Add(lMethod);
end;

method EchoesRodlCodeGen.Intf_GenerateServiceAsync(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_EntityName := aEntity.Name;
  var l_IName := $"I{l_EntityName}_Async";
  var l_intf := new CGInterfaceTypeDefinition(l_IName,
                                              Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    l_intf.Ancestors.Add(ResolveDataTypeToTypeRef(aLibrary, $"I{aEntity.AncestorName}_Async", aEntity.AncestorName))  //I%ancestor%_Async
  else
    l_intf.Ancestors.Add("RemObjects.SDK.IROService_Async".AsTypeReference_NotNullable);

  aFile.Types.Add(l_intf);

  var l_proxy := new CGClassTypeDefinition($"{aEntity.Name}_AsyncProxy", //%service%_AsyncProxy
                                           &Partial := true,
                                           Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    l_proxy.Ancestors.Add(ResolveDataTypeToTypeRef(aLibrary, $"{aEntity.AncestorName}_AsyncProxy", aEntity.AncestorName))  //%ancestor%_AsyncProxy
  else
    l_proxy.Ancestors.Add("RemObjects.SDK.AsyncProxy".AsTypeReference_NotNullable);
  l_proxy.ImplementedInterfaces.Add(l_intf.Name.AsTypeReference_NotNullable);
  aFile.Types.Add(l_proxy);
  Intf_GenerateServiceProxyConstructors(l_proxy);
  Intf_GenerateServiceProxyInterfaceNameProperty(l_proxy, aEntity);

  var l_callbackParam := new CGParameterDefinition(self.INTF_CALLBACK, "System.AsyncCallback".AsTypeReference_Nullable);
  var l_userdataParam := new CGParameterDefinition(self.INTF_USER_DATA, CGPredefinedTypeReference.Object);
  var l_asyncResult   := new CGParameterDefinition(self.INTF_ASYNC_RESULT, "System.IAsyncResult".AsTypeReference_NotNullable);
  var l_localmessage := self.INTF_LOCAL_MESSAGE.AsNamedIdentifierExpression;
  var l_localMessageVarDeclarationBegin := new CGVariableDeclarationStatement(self.INTF_LOCAL_MESSAGE,
                                                              "RemObjects.SDK.IMessage".AsTypeReference_NotNullable,
                                                              new CGMethodCallExpression(CGSelfExpression.Self, self.INTF_GET_MESSAGE));
  var l_localMessageVarDeclarationEnd := new CGVariableDeclarationStatement(self.INTF_LOCAL_MESSAGE,
                                                              "RemObjects.SDK.IMessage".AsTypeReference_NotNullable,
                                                              new CGPropertyAccessExpression(
                                                                  new CGTypeCastExpression(
                                                                      self.INTF_ASYNC_RESULT.AsNamedIdentifierExpression,
                                                                      "RemObjects.SDK.IClientAsyncResult".AsTypeReference_NotNullable,
                                                                      true),
                                                                  "Message"));
  var l_channel := (new CGPropertyAccessExpression(CGSelfExpression.Self, "ClientChannel"));



  for rodl_member in aEntity.DefaultInterface.Items do begin
    var l_intfBegin := new CGMethodDefinition($"Begin{rodl_member.Name}",
                                              Visibility := CGMemberVisibilityKind.Public);
    var l_intfEnd := new CGMethodDefinition($"End{rodl_member.Name}",
                                            Visibility := CGMemberVisibilityKind.Public);
    var l_intfAsync := new CGMethodDefinition($"{rodl_member.Name}Async",
                                              Visibility := CGMemberVisibilityKind.Public);
    l_intf.Members.Add(l_intfBegin);
    l_intf.Members.Add(l_intfEnd);

    var l_proxyBegin := new CGMethodDefinition($"Begin{rodl_member.Name}",
                                               ImplementsInterface := l_IName.AsTypeReference_NotNullable,
                                               ImplementsInterfaceMember := $"Begin{rodl_member.Name}",
                                               Virtuality := CGMemberVirtualityKind.Virtual,
                                               Visibility := CGMemberVisibilityKind.Public);
    var l_proxyEnd := new CGMethodDefinition($"End{rodl_member.Name}",
                                             ImplementsInterface := l_IName.AsTypeReference_NotNullable,
                                             ImplementsInterfaceMember := $"End{rodl_member.Name}",
                                             Virtuality := CGMemberVirtualityKind.Virtual,
                                             Visibility := CGMemberVisibilityKind.Public);
    var l_proxyAsync := new CGMethodDefinition($"{rodl_member.Name}Async",
                                               ImplementsInterface := l_IName.AsTypeReference_NotNullable,
                                               ImplementsInterfaceMember := $"{rodl_member.Name}Async",
                                               Virtuality := CGMemberVirtualityKind.Virtual,
                                               Visibility := CGMemberVisibilityKind.Public);
    l_proxy.Members.Add(l_proxyBegin);
    l_proxy.Members.Add(l_proxyEnd);
    //l_proxy.Members.Add(l_proxyAsync);

    l_intfEnd.Parameters.Add(l_asyncResult);
    l_proxyEnd.Parameters.Add(l_asyncResult);
    var lGenerateAwaitableMethod := self.AsyncSupport;
    for rodl_param in rodl_member.Items do begin
      var p:= new CGParameterDefinition(rodl_param.Name, ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType));
      case rodl_param.ParamFlag of
        ParamFlags.In: begin
          p.Modifier := CGParameterModifierKind.In;
          l_intfBegin.Parameters.Add(p);
          l_proxyBegin.Parameters.Add(p);
          l_intfAsync.Parameters.Add(p);
          l_proxyAsync.Parameters.Add(p);
        end;
        ParamFlags.InOut: begin
          p.Modifier := CGParameterModifierKind.Var;
          l_intfBegin.Parameters.Add(p);
          l_proxyBegin.Parameters.Add(p);
          l_intfEnd.Parameters.Add(p);
          l_proxyEnd.Parameters.Add(p);
          lGenerateAwaitableMethod := false;
        end;
        ParamFlags.Out: begin
          p.Modifier := CGParameterModifierKind.Out;
          l_intfEnd.Parameters.Add(p);
          l_proxyEnd.Parameters.Add(p);
          lGenerateAwaitableMethod := false;
        end;
      end;
    end;
    l_intfBegin.ReturnType := "System.IAsyncResult".AsTypeReference_NotNullable;
    l_intfBegin.Parameters.Add(l_callbackParam);
    l_intfBegin.Parameters.Add(l_userdataParam);

    l_proxyBegin.ReturnType := "System.IAsyncResult".AsTypeReference_NotNullable;
    l_proxyBegin.Parameters.Add(l_callbackParam);
    l_proxyBegin.Parameters.Add(l_userdataParam);

    if assigned(rodl_member.Result) then begin
      l_intfEnd.ReturnType := ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType);
      l_proxyEnd.ReturnType := l_intfEnd.ReturnType;
    end;

    {$REGION begin* method}
    l_proxyBegin.Statements.Add(l_localMessageVarDeclarationBegin);
    var l_body := new List<CGStatement>;
    var aNames: List<CGExpression>;
    var aValues: List<CGExpression>;
    GenerateAttributes(aLibrary,  aEntity, rodl_member, out aNames, out aValues);
    if aNames.Count > 0 then begin
      l_body.Add(new CGMethodCallExpression(l_localmessage,
                                            "SetAttributes",
                                            [ l_channel.AsCallParameter,
                                            new CGArrayLiteralExpression(aNames, CGPredefinedTypeReference.String).AsCallParameter,
                                            new CGArrayLiteralExpression(aValues, CGPredefinedTypeReference.String).AsCallParameter]));

    end;

    l_body.Add(new CGMethodCallExpression(l_localmessage,
                                          "InitializeRequestMessage",
                                          [l_channel.AsCallParameter,
                                           aLibrary.Name.AsLiteralExpression.AsCallParameter,
                                           (new CGPropertyAccessExpression(CGSelfExpression.Self, "ActiveInterfaceName")).AsCallParameter,
                                           rodl_member.Name.AsLiteralExpression.AsCallParameter]));

    for rodl_param in rodl_member.Items do
      if rodl_param.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
        l_body.Add(Intf_generateWriteStatement(aLibrary, l_localmessage, rodl_param));

    l_body.Add(new CGMethodCallExpression(l_localmessage, "FinalizeMessage"));
    l_body.Add(new CGMethodCallExpression(l_channel,
                                          "AsyncDispatch",
                                          [l_localmessage.AsCallParameter,
                                           self.INTF_CALLBACK.AsNamedIdentifierExpression.AsCallParameter,
                                           self.INTF_USER_DATA.AsNamedIdentifierExpression.AsCallParameter]).AsReturnStatement);

    var l_try := new CGTryFinallyCatchStatement(l_body);
    var l_except := new CGCatchBlockStatement("ex", "System.Exception".AsTypeReference_NotNullable);
    if aNames.Count > 0 then
      l_except.Statements.Add(new CGMethodCallExpression(l_localmessage, "ClearAttributes",[l_channel.AsCallParameter]));
    l_except.Statements.Add(new CGMethodCallExpression(CGSelfExpression.Self, self.INTF_CLEAR_MESSAGE, [l_localmessage.AsCallParameter]));
    l_except.Statements.Add(new CGThrowExpression("ex".AsNamedIdentifierExpression));
    l_try.CatchBlocks.Add(l_except);
    l_proxyBegin.Statements.Add(l_try);
    {$ENDREGION}
    {$REGION End*}
    l_proxyEnd.Statements.Add(l_localMessageVarDeclarationEnd);
    l_body := new List<CGStatement>;

    var l_localResultName: String := nil;
    if rodl_member.Result <> nil then begin
      l_localResultName := $"_{rodl_member.Result.Name}";
      while rodl_member.FindEntity(l_localResultName) <> nil do
        l_localResultName := $"_{l_localResultName}";
      l_body.Add(new CGVariableDeclarationStatement(l_localResultName,
                                                    ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType),
                                                    Intf_generateReadStatement(aLibrary, l_localmessage, rodl_member.Result)));
    end;

    for rodl_param in rodl_member.Items do
      if rodl_param.ParamFlag in [ParamFlags.InOut,ParamFlags.Out] then
        l_body.Add(new CGAssignmentStatement(rodl_param.Name.AsNamedIdentifierExpression, Intf_generateReadStatement(aLibrary, l_localmessage, rodl_param)));

    if rodl_member.Result <> nil then
      l_body.Add(new CGReturnStatement(l_localResultName.AsNamedIdentifierExpression));




    l_try := new CGTryFinallyCatchStatement(l_body);
    if aNames.Count > 0 then
      l_try.FinallyStatements.Add(new CGMethodCallExpression(l_localmessage, "ClearAttributes",[l_channel.AsCallParameter]));
    l_try.FinallyStatements.Add(new CGMethodCallExpression(CGSelfExpression.Self, self.INTF_CLEAR_MESSAGE, [l_localmessage.AsCallParameter]));
    l_proxyEnd.Statements.Add(l_try);
    {$ENDREGION}
    {$REGION *Async}
    if lGenerateAwaitableMethod then begin
      l_intf.Members.Add(l_intfAsync);
      l_proxy.Members.Add(l_proxyAsync);
      var l_result := new CGNamedTypeReference("System.Threading.Tasks.Task");
      if assigned(rodl_member.Result) then begin
        l_result.GenericArguments := new List<CGTypeReference>;
        l_result.GenericArguments.Add(ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType));
      end;
      l_intfAsync.ReturnType := l_result;
      l_proxyAsync.ReturnType := l_result;
      var l_factory := new CGPropertyAccessExpression(l_result.AsExpression, "Factory");
      var lBeginMethodCall := new CGMethodCallExpression(CGSelfExpression.Self,
                                                         l_intfBegin.Name);
      for p in l_proxyAsync.Parameters do
        lBeginMethodCall.Parameters.Add(p.Name.AsNamedIdentifierExpression.AsCallParameter);
      lBeginMethodCall.Parameters.Add(CGNilExpression.Nil.AsCallParameter);
      lBeginMethodCall.Parameters.Add(CGNilExpression.Nil.AsCallParameter);
      var lEndMethodCall: CGNewInstanceExpression :=
        if assigned(rodl_member.Result) then
          new CGNewInstanceExpression("System.Func".AsTypeReference_NotNullable)
        else
          new CGNewInstanceExpression("System.Action".AsTypeReference_NotNullable);
      lEndMethodCall.GenericArguments := new List<CGTypeReference>;
      lEndMethodCall.GenericArguments.Add("System.IAsyncResult".AsTypeReference_NotNullable);
      if assigned(rodl_member.Result) then
        lEndMethodCall.GenericArguments.Add(ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType));

      lEndMethodCall.Parameters.Add(new CGUnaryOperatorExpression(new CGFieldAccessExpression(CGSelfExpression.Self, l_intfEnd.Name),
                                                                  CGUnaryOperatorKind.AddressOfBlock).AsCallParameter);
      l_proxyAsync.Statements.Add(new CGMethodCallExpression(l_factory,
                                                             "FromAsync",
                                                             [lBeginMethodCall.AsCallParameter,
                                                              lEndMethodCall.AsCallParameter]).AsReturnStatement);
    end;
    {$ENDREGION}
  end;
  Intf_GenerateCoService(aFile, $"Co{l_EntityName}Async", l_intf.Name, l_proxy.Name);
end;

method EchoesRodlCodeGen.Intf_GenerateServiceProxyConstructors(aType: CGClassTypeDefinition);
begin
  {$REGION constructor(message: RemObjects.SDK.IMessage; clientChannel: RemObjects.SDK.IClientChannel)}
  var l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition("aMessage","RemObjects.SDK.IMessage".AsTypeReference_NotNullable));
  l_ctor.Parameters.Add(new CGParameterDefinition("aClientChannel","RemObjects.SDK.IClientChannel".AsTypeReference_NotNullable));
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                       ["aMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                        "aClientChannel".AsNamedIdentifierExpression.AsCallParameter]));
  aType.Members.Add(l_ctor);
  {$ENDREGION}
  {$REGION constructor(message: RemObjects.SDK.IMessage; clientChannel: RemObjects.SDK.IClientChannel; interfaceName: System.String);}
  l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition("aMessage","RemObjects.SDK.IMessage".AsTypeReference_NotNullable));
  l_ctor.Parameters.Add(new CGParameterDefinition("aClientChannel","RemObjects.SDK.IClientChannel".AsTypeReference_NotNullable));
  l_ctor.Parameters.Add(new CGParameterDefinition("anInterfaceName",CGPredefinedTypeReference.String));

  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                       ["aMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                        "aClientChannel".AsNamedIdentifierExpression.AsCallParameter,
                                                        "anInterfaceName".AsNamedIdentifierExpression.AsCallParameter]));
  aType.Members.Add(l_ctor);
  {$ENDREGION}
  {$REGION constructor(remoteService: RemObjects.SDK.IRemoteService)}
  l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition("aRemoteService","RemObjects.SDK.IRemoteService".AsTypeReference_NotNullable));
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                       ["aRemoteService".AsNamedIdentifierExpression.AsCallParameter]));
  aType.Members.Add(l_ctor);
  {$ENDREGION}
  {$REGION constructor(remoteService: RemObjects.SDK.IRemoteService; interfaceName: System.String)}
  l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition("aRemoteService","RemObjects.SDK.IRemoteService".AsTypeReference_NotNullable));
  l_ctor.Parameters.Add(new CGParameterDefinition("anInterfaceName",CGPredefinedTypeReference.String));
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                       ["aRemoteService".AsNamedIdentifierExpression.AsCallParameter,
                                                        "anInterfaceName".AsNamedIdentifierExpression.AsCallParameter]));
  aType.Members.Add(l_ctor);
  {$ENDREGION}
  {$REGION constructor(uri: System.Uri)}
  l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition("anUri","System.Uri".AsTypeReference_NotNullable));
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                       ["anUri".AsNamedIdentifierExpression.AsCallParameter]));
  aType.Members.Add(l_ctor);
  {$ENDREGION}
  {$REGION constructor(url: System.String)}
  l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  l_ctor.Parameters.Add(new CGParameterDefinition("aUrl",CGPredefinedTypeReference.String));
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                       ["aUrl".AsNamedIdentifierExpression.AsCallParameter]));
  aType.Members.Add(l_ctor);
  {$ENDREGION}
end;

method EchoesRodlCodeGen.GenerateAttributes(aLibrary: RodlLibrary; aService: RodlService; aOperation: RodlOperation; out aNames: List<CGExpression>; out aValues: List<CGExpression>);
begin
  aNames := new List<CGExpression>;
  aValues := new List<CGExpression>;

  var lsa := new Dictionary<String,String>;

  for li in aLibrary.CustomAttributes.Keys do
    if not IsServerSideAttribute(li) then
      if not lsa.ContainsKey(li.ToLowerInvariant) then
        lsa.Add(li.ToLowerInvariant, aLibrary.CustomAttributes[li]);

  for li in aService.CustomAttributes.Keys do
    if not IsServerSideAttribute(li) then
      if not lsa.ContainsKey(li.ToLowerInvariant) then
        lsa.Add(li.ToLowerInvariant, aService.CustomAttributes[li]);

  for li in aOperation.CustomAttributes.Keys do
    if not IsServerSideAttribute(li) then
      if not lsa.ContainsKey(li.ToLowerInvariant) then
        lsa.Add(li.ToLowerInvariant, aOperation.CustomAttributes[li]);

  for li in lsa.Keys do begin
    aNames.Add(li.ToLower.AsLiteralExpression);
    //if li.EqualsIgnoringCaseInvariant("TargetNamespace") then aValues.Add("TargetNamespace".AsNamedIdentifierExpression)
    //else if li.EqualsIgnoringCaseInvariant("Wsdl") then aValues.Add("WSDLLocation".AsNamedIdentifierExpression)
    //else
    aValues.Add(lsa[li].AsLiteralExpression);
  end;
end;

method EchoesRodlCodeGen.Intf_GenerateServiceProxyInterfaceNameProperty(aType: CGClassTypeDefinition; aRodlService: RodlService);
begin
  {$REGION property InterfaceName: System.String read get_InterfaceName; override;}
  aType.Members.Add(new CGPropertyDefinition("InterfaceName",CGPredefinedTypeReference.String,
                                              aRodlService.Name.AsLiteralExpression,
                                              &ReadOnly := true,
                                              //Initializer := aRodlService.Name.AsLiteralExpression,
                                              Virtuality := CGMemberVirtualityKind.Override,
                                              Visibility := CGMemberVisibilityKind.Public));

  {$ENDREGION}
end;


method EchoesRodlCodeGen.IsParameterDisposerNeeded(parameter: RodlParameter): Boolean;
begin
  exit not self.fDontNeedDisposers.Contains(parameter.DataType.ToLower);
end;

method EchoesRodlCodeGen.Intf_GenerateCoService(aUnit: CGCodeUnit; aName: String; aIntfName: String; aProxyName: String);
begin
  var l_cotype := new CGClassTypeDefinition(aName,
                                            &Static := true,
                                            Visibility := CGTypeVisibilityKind.Public);

  {$REGION class method &Create(message: RemObjects.SDK.IMessage; clientChannel: RemObjects.SDK.IClientChannel): I%service%;}
  var l_method := new CGMethodDefinition("Create",
                                         &Static := true,
                                         Visibility := CGMemberVisibilityKind.Public);
  l_method.Parameters.Add(new CGParameterDefinition("message", "RemObjects.SDK.IMessage".AsTypeReference_NotNullable));
  l_method.Parameters.Add(new CGParameterDefinition("clientChannel", "RemObjects.SDK.IClientChannel".AsTypeReference_NotNullable));
  l_method.ReturnType := aIntfName.AsTypeReference_NotNullable;
  l_method.Statements.Add((new CGNewInstanceExpression(aProxyName.AsTypeReference_NotNullable,
                                                      ["message".AsNamedIdentifierExpression.AsCallParameter,
                                                       "clientChannel".AsNamedIdentifierExpression.AsCallParameter])).AsReturnStatement);
  l_cotype.Members.Add(l_method);
  {$ENDREGION}

  {$REGION class method &Create(remoteService: RemObjects.SDK.IRemoteService): I%service%;}
  l_method := new CGMethodDefinition("Create",
                                     &Static := true,
                                     Visibility := CGMemberVisibilityKind.Public);
  l_method.Parameters.Add(new CGParameterDefinition("remoteService", "RemObjects.SDK.IRemoteService".AsTypeReference_NotNullable));
  l_method.ReturnType := aIntfName.AsTypeReference_NotNullable;
  l_method.Statements.Add((new CGNewInstanceExpression(aProxyName.AsTypeReference_NotNullable,
                                                      ["remoteService".AsNamedIdentifierExpression.AsCallParameter])).AsReturnStatement);
  l_cotype.Members.Add(l_method);
  {$ENDREGION}

  {$REGION class method &Create(uri: System.Uri): I%service%;}
  l_method := new CGMethodDefinition("Create",
                                     &Static := true,
                                     Visibility := CGMemberVisibilityKind.Public);
  l_method.Parameters.Add(new CGParameterDefinition("uri", "System.Uri".AsTypeReference_NotNullable));
  l_method.ReturnType := aIntfName.AsTypeReference_NotNullable;
  l_method.Statements.Add((new CGNewInstanceExpression(aProxyName.AsTypeReference_NotNullable,
                                                      ["uri".AsNamedIdentifierExpression.AsCallParameter])).AsReturnStatement);
  l_cotype.Members.Add(l_method);
  {$ENDREGION}

  {$REGION class method &Create(url: System.String): I%service%;}
  l_method := new CGMethodDefinition("Create",
                                     &Static := true,
                                     Visibility := CGMemberVisibilityKind.Public);
  l_method.Parameters.Add(new CGParameterDefinition("url", CGPredefinedTypeReference.String));
  l_method.ReturnType := aIntfName.AsTypeReference_NotNullable;
  l_method.Statements.Add((new CGNewInstanceExpression(aProxyName.AsTypeReference_NotNullable,
                                                      ["url".AsNamedIdentifierExpression.AsCallParameter])).AsReturnStatement);
  l_cotype.Members.Add(l_method);
  {$ENDREGION}
  aUnit.Types.Add(l_cotype);
end;

method EchoesRodlCodeGen.ResolveDataTypeToTypeRef(aLibrary: RodlLibrary; aDataType: String; aOrigType: String := nil): CGTypeReference;
begin
  if String.IsNullOrEmpty(aOrigType) then aOrigType := aDataType;
  var lLower := aDataType.ToLowerInvariant();
  if CodeGenTypes.ContainsKey(lLower) then
    exit CodeGenTypes[lLower]
  else begin
    var lent := aLibrary.FindEntity(aOrigType);
    if lent <> nil then begin
      if lent.IsFromUsedRodl then begin
        if not String.IsNullOrWhiteSpace(lent.FromUsedRodl:Includes:NetModule) then
          exit new CGNamedTypeReference(aDataType)
                                       &namespace(new CGNamespaceReference(lent.FromUsedRodl:Includes:NetModule))
                                       isClassType(not isEnum(aLibrary, aOrigType));
      end;
      if lent is RodlArray then begin
        if lent.HasCustomAttributes or not String.IsNullOrEmpty(lent.Documentation) then
          exit new CGNamedTypeReference(aDataType, IsClassType := false, DefaultNullability := CGTypeNullabilityKind.NullableUnwrapped)
        else
          exit new CGArrayTypeReference(ResolveDataTypeToTypeRef(aLibrary, RodlArray(lent).ElementType), DefaultNullability := CGTypeNullabilityKind.NullableUnwrapped);
      end;
    end;
    exit new CGNamedTypeReference(aDataType, IsClassType := not isEnum(aLibrary, aOrigType), DefaultNullability := CGTypeNullabilityKind.NotNullable);
  end;
end;

method EchoesRodlCodeGen.Impl_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var lservice := new CGClassTypeDefinition(aEntity.Name,
                                            Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lservice.Ancestors.Add(ResolveDataTypeToTypeRef(aLibrary, aEntity.AncestorName))
  else
    lservice.Ancestors.Add("RemObjects.SDK.Server.Service".AsTypeReference_NotNullable);
  lservice.ImplementedInterfaces.Add($"I{aEntity.Name}".AsTypeReference_NotNullable);

  if aEntity.Abstract then
    lservice.Attributes.Add(new CGAttribute("RemObjects.SDK.Server.Abstract".AsTypeReference_NotNullable))
  else
    lservice.Attributes.Add(new CGAttribute("RemObjects.SDK.Server.ClassFactories.StandardClassFactory".AsTypeReference_NotNullable));
  lservice.Attributes.Add(new CGAttribute("RemObjects.SDK.Server.Service".AsTypeReference_NotNullable,
                                          [new CGCallParameter(aEntity.Name.AsLiteralExpression, "Name"),
                                           new CGCallParameter(new CGTypeOfExpression($"{aEntity.Name}_Invoker".AsNamedIdentifierExpression), "InvokerClass"),
                                           new CGCallParameter(new CGTypeOfExpression($"{aEntity.Name}_Activator".AsNamedIdentifierExpression), "ActivatorClass")].ToList));
  if aEntity.HasCustomAttributes then begin
    var l_groups := aEntity.CustomAttributes["ROServiceGroups"];
    if not String.IsNullOrEmpty(l_groups) then begin
      for each it in l_groups.Split(",") do
        lservice.Attributes.Add(new CGAttribute("RemObjects.SDK.Server.ServiceGroup".AsTypeReference_NotNullable, [it.AsLiteralExpression.AsCallParameter]));
    end;
  end;

  lservice.Members.Add(
    new CGFieldDefinition("components",
                          "System.ComponentModel.Container".AsTypeReference_Nullable,
                          Initializer := CGNilExpression.Nil,
                          Visibility := CGMemberVisibilityKind.Private));

  lservice.Members.Add(
    new CGMethodDefinition("InitializeComponent",
                           Visibility := CGMemberVisibilityKind.Private));

  lservice.Members.Add(
    new CGConstructorDefinition("", [new CGConstructorCallStatement(CGSelfExpression.Self,
                                                                   [CGNilExpression.Nil.AsCallParameter,
                                                                    CGNilExpression.Nil.AsCallParameter])],
                                Visibility := if aEntity.Abstract then CGMemberVisibilityKind.Protected else CGMemberVisibilityKind.Public));

  lservice.Members.Add(
    new CGConstructorDefinition("", [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                                   ["sessionManager".AsNamedIdentifierExpression.AsCallParameter,
                                                                    "eventManager".AsNamedIdentifierExpression.AsCallParameter]),
                                     new CGMethodCallExpression(CGSelfExpression.Self,"InitializeComponent")],
                                Parameters := [new CGParameterDefinition("sessionManager", "ISessionManager".AsTypeReference_Nullable),
                                               new CGParameterDefinition("eventManager", "IEventSinkManager".AsTypeReference_Nullable)].ToList,
                                Visibility := if aEntity.Abstract then CGMemberVisibilityKind.Protected else CGMemberVisibilityKind.Public));

  var l_components := new CGFieldAccessExpression(CGSelfExpression.Self, "components");
  lservice.Members.Add(
    new CGMethodDefinition("Dispose",
                           [new CGIfThenElseStatement("disposing".AsNamedIdentifierExpression,
                                                      new CGIfThenElseStatement(
                                                        new CGBinaryOperatorExpression(
                                                          l_components,
                                                          CGNilExpression.Nil,
                                                          CGBinaryOperatorKind.NotEquals),
                                                        new CGMethodCallExpression(l_components,"Dispose"))),
                            new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                       "Dispose",
                                                       ["disposing".AsNamedIdentifierExpression.AsCallParameter])],
                          Parameters := [new CGParameterDefinition("disposing", CGPredefinedTypeReference.Boolean)].ToList,
                          Virtuality := CGMemberVirtualityKind.Override,
                          Visibility := CGMemberVisibilityKind.Protected));

  for rodl_member in aEntity.DefaultInterface.Items do begin
    var l_intfmethod := new CGMethodDefinition(rodl_member.Name,
                                               [new CGCommentStatement("Insert code here to implement this method.")],
                                               ImplementsInterface := $"I{aEntity.Name}".AsTypeReference_NotNullable,
                                               ImplementsInterfaceMember := rodl_member.Name,
                                               Virtuality := CGMemberVirtualityKind.Virtual,
                                               Visibility := CGMemberVisibilityKind.Public);
    for rodl_param in rodl_member.Items do begin
      if rodl_param.ParamFlag <> ParamFlags.Result then begin
        var cg4_param := new CGParameterDefinition(rodl_param.Name, ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType));
        case rodl_param.ParamFlag of
          ParamFlags.In: cg4_param.Modifier := CGParameterModifierKind.In;
          ParamFlags.InOut: cg4_param.Modifier := CGParameterModifierKind.Var;
          ParamFlags.Out: cg4_param.Modifier := CGParameterModifierKind.Out;
        end;
        l_intfmethod.Parameters.Add(cg4_param);
      end;
    end;
    if rodl_member.Result <> nil then
      l_intfmethod.ReturnType := ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType);

    lservice.Members.Add(l_intfmethod);
  end;
  aFile.Types.Add(lservice);
end;

method EchoesRodlCodeGen.GenerateServiceActivator(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_SafeEntityName := aEntity.Name;
  var l_activator := new CGClassTypeDefinition(
                            $"{l_SafeEntityName}_Activator",
                            CGPredefinedTypeReference.Object, // VB.NET workaround
                            ["RemObjects.SDK.Server.IServiceActivator".AsTypeReference_NotNullable].ToList,
                            Visibility := CGTypeVisibilityKind.Public);
  l_activator.Attributes.Add(new CGAttribute("System.Reflection.ObfuscationAttribute".AsTypeReference_NotNullable,
                                             [new CGCallParameter(true.AsLiteralExpression, "Exclude"),
                                              new CGCallParameter(false.AsLiteralExpression, "ApplyToMembers")
                                              ]));
  l_activator.Members.Add(new CGConstructorDefinition(&Empty := true,
                                                      Visibility := CGMemberVisibilityKind.Public));
  var l_method := new CGMethodDefinition("CreateInstance",
                                         ImplementsInterface := "RemObjects.SDK.Server.IServiceActivator".AsTypeReference_NotNullable,
                                         ImplementsInterfaceMember := "CreateInstance",
                                         ReturnType := "RemObjects.SDK.IROService".AsTypeReference_NotNullable,
                                         Visibility := CGMemberVisibilityKind.Public);
  if aEntity.Abstract then begin
    l_method.Statements.Add(
      new CGThrowExpression(
        new CGNewInstanceExpression("RemObjects.SDK.Exceptions.ServerSetupException".AsTypeReference_NotNullable,
                                    [$"Cannot activate abstract entity {l_SafeEntityName}".AsLiteralExpression.AsCallParameter])));
  end
  else begin
    l_method.Statements.Add(new CGTypeCastExpression(
                              new CGMethodCallExpression("RemObjects.SDK.Server.Engine.ObjectActivator".AsNamedIdentifierExpression,
                                                         "GetInstance",
                                                         [new CGTypeOfExpression(l_SafeEntityName.AsNamedIdentifierExpression).AsCallParameter]),
                              "RemObjects.SDK.IROService".AsTypeReference_NotNullable,
                              true).AsReturnStatement);
  end;
  l_activator.Members.Add(l_method);
  aFile.Types.Add(l_activator);
end;

method EchoesRodlCodeGen.Invk_GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_EntityName := aEntity.Name;

  var ltype := new CGClassTypeDefinition($"{l_EntityName}_Invoker",
                                         Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    ltype.Ancestors.Add(ResolveDataTypeToTypeRef(aLibrary, $"{aEntity.AncestorName}_Invoker", aEntity.AncestorName));

  ltype.Attributes.Add(GenerateObfuscationAttribute);

  var mem: CGMethodLikeMemberDefinition;

  ltype.Members.Add(new CGConstructorDefinition("",
                                               new CGConstructorCallStatement(CGInheritedExpression.Inherited),
                                               Visibility :=  CGMemberVisibilityKind.Public));
  var plist := new List<CGParameterDefinition>;
  plist.Add(new CGParameterDefinition(self.INVK_INSTANCE,    "RemObjects.SDK.IROService".AsTypeReference_NotNullable));
  plist.Add(new CGParameterDefinition(self.INVK_MESSAGE,     "RemObjects.SDK.IMessage".AsTypeReference_NotNullable));
  plist.Add(new CGParameterDefinition(self.INVK_CHANNEL_INFO,"RemObjects.SDK.Server.IServerChannelInfo".AsTypeReference_NotNullable));
  plist.Add(new CGParameterDefinition(self.INVK_OPTIONS     ,"RemObjects.SDK.Server.ResponseOptions".AsTypeReference_NotNullable, Modifier := CGParameterModifierKind.Out));

  for rodl_member in aEntity.DefaultInterface.Items do begin
    mem := new CGMethodDefinition($"Invoke_{rodl_member.Name}",
                                  Parameters := plist,
                                  &Static := true,
                                  Visibility := CGMemberVisibilityKind.Public);

    if (rodl_member.Roles:Roles:Count > 0) or (aEntity.Roles:Roles:Count > 0) then begin
      var list := new List<CGExpression>;
      for role in rodl_member.Roles:Roles do
        list.Add(role.ToString.AsLiteralExpression);
      for role in aEntity.Roles:Roles do
        list.Add(role.ToString.AsLiteralExpression);
      mem.Statements.Add(
            new CGMethodCallExpression(
               new CGTypeCastExpression(self.INVK_INSTANCE.AsNamedIdentifierExpression,
                                        "RemObjects.SDK.Server.IRolesAwareService".AsTypeReference_NotNullable,
                                        true),
               "ServiceValidateRoles",
               [new CGArrayLiteralExpression(list, CGPredefinedTypeReference.String).AsCallParameter]));
    end;

    var l_message := self.INVK_MESSAGE.AsNamedIdentifierExpression;
    if rodl_member.Items.Count > 0 then begin
      var list := new List<CGExpression>;
      for rodl_param in rodl_member.Items do
        if rodl_param.ParamFlag in [ParamFlags.In, ParamFlags.InOut] then
          list.Add(rodl_param.Name.AsLiteralExpression);
      if list.Count > 0 then begin
        mem.Statements.Add(new CGIfThenElseStatement(
                              new CGMethodCallExpression(l_message, "CanRemapParameters"),
                              new CGMethodCallExpression(l_message, "RemapParameters",
                                                         [new CGArrayLiteralExpression(list, CGPredefinedTypeReference.String).AsCallParameter])));
      end;
    end;
    var isDisposerNeeded := false;
    for rodl_param in rodl_member.Items do
        if IsParameterDisposerNeeded(rodl_param) then begin
          isDisposerNeeded := true;
          break;
        end;
    if assigned(rodl_member.Result) and IsParameterDisposerNeeded(rodl_member.Result) then isDisposerNeeded := true;
    var l_body: List<CGStatement> := nil;
    if isDisposerNeeded then begin
      mem.Statements.Add(
          new CGVariableDeclarationStatement(self.OBJECT_DISPOSER_NAME,
                                              "RemObjects.SDK.ObjectDisposer".AsTypeReference_NotNullable,
                                              new CGNewInstanceExpression("RemObjects.SDK.ObjectDisposer".AsNamedIdentifierExpression)));
      l_body := new List<CGStatement>;
      var l_try := new CGTryFinallyCatchStatement(l_body);
      l_try.FinallyStatements.Add(new CGMethodCallExpression(self.OBJECT_DISPOSER_NAME.AsNamedIdentifierExpression, "Dispose"));
      mem.Statements.Add(l_try);
    end
    else
      l_body := mem.Statements;

    for rodl_param in rodl_member.Items do
      if rodl_param.ParamFlag in [ParamFlags.In, ParamFlags.InOut] then
        l_body.Add(new CGVariableDeclarationStatement(rodl_param.Name,
                                                      ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType),
                                                      Value := Intf_generateReadStatement(aLibrary,
                                                                                          l_message,
                                                                                          rodl_param)));
    for rodl_param in rodl_member.Items do
      if (rodl_param.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) and IsParameterDisposerNeeded(rodl_param) then
        l_body.Add(new CGMethodCallExpression(self.OBJECT_DISPOSER_NAME.AsNamedIdentifierExpression,
                                              "Add",
                                              [rodl_param.Name.AsNamedIdentifierExpression.AsCallParameter]));




    if rodl_member.Result <> nil then begin
      l_body.Add(new CGVariableDeclarationStatement(rodl_member.Result.Name,
                                                    ResolveDataTypeToTypeRef(aLibrary, rodl_member.Result.DataType)));
    end;
    for rodl_param in rodl_member.Items do
      if rodl_param.ParamFlag in [ParamFlags.Out] then
        l_body.Add(new CGVariableDeclarationStatement(rodl_param.Name,
                                                      ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType)));

    var l_paramlist := new List<CGCallParameter>;
    for rodl_param in rodl_member.Items do begin
      var cg4param := rodl_param.Name.AsNamedIdentifierExpression.AsCallParameter;
      case rodl_param.ParamFlag of
        //ParamFlags.In: ;
        ParamFlags.Out: cg4param.Modifier := CGParameterModifierKind.Out;
        ParamFlags.InOut: cg4param.Modifier := CGParameterModifierKind.Var;
        ParamFlags.Result: continue;
      end;
      l_paramlist.Add(cg4param);
    end;
    var l_method := new CGMethodCallExpression(
                        new CGTypeCastExpression(
                          self.INVK_INSTANCE.AsNamedIdentifierExpression,
                          $"I{l_EntityName}".AsTypeReference_NotNullable,
                          true),
                       rodl_member.Name,
                       l_paramlist);
    if rodl_member.Result <> nil then
      l_body.Add(new CGAssignmentStatement(rodl_member.Result.Name.AsNamedIdentifierExpression, l_method))
    else
      l_body.Add(l_method);

    if rodl_member.Result <> nil then
      if IsParameterDisposerNeeded(rodl_member.Result) then
        l_body.Add(new CGMethodCallExpression(self.OBJECT_DISPOSER_NAME.AsNamedIdentifierExpression,
                                              "Add",
                                              [rodl_member.Result.Name.AsNamedIdentifierExpression.AsCallParameter]));
    for rodl_param in rodl_member.Items do begin
      if (rodl_param.ParamFlag in [ParamFlags.Out, ParamFlags.InOut]) and IsParameterDisposerNeeded(rodl_param) then
        l_body.Add(new CGMethodCallExpression(self.OBJECT_DISPOSER_NAME.AsNamedIdentifierExpression,
                                              "Add",
                                              [rodl_param.Name.AsNamedIdentifierExpression.AsCallParameter]));
    end;


    l_body.Add(new CGMethodCallExpression(l_message,
                                          "InitializeResponseMessage",
                                          [self.INVK_CHANNEL_INFO.AsNamedIdentifierExpression.AsCallParameter,
                                           aLibrary.Name.AsLiteralExpression.AsCallParameter,
                                           l_EntityName.AsLiteralExpression.AsCallParameter,
                                           $"{rodl_member.Name}Response".AsLiteralExpression.AsCallParameter]));
    var l_hasout := False;
    if rodl_member.Result <> nil then begin
      l_body.Add(Intf_generateWriteStatement(aLibrary, l_message, rodl_member.Result));
      l_hasout := True;
    end;

    for rodl_param in rodl_member.Items do
      if rodl_param.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then begin
        l_body.Add(Intf_generateWriteStatement(aLibrary, l_message, rodl_param));
        l_hasout := True;
      end;

    l_body.Add(new CGMethodCallExpression(l_message, "FinalizeMessage"));
    l_body.Add(new CGAssignmentStatement(self.INVK_OPTIONS.AsNamedIdentifierExpression,
                                         new CGFieldAccessExpression("RemObjects.SDK.Server.ResponseOptions".AsNamedIdentifierExpression,
                                                                      if l_hasout then "roDefault" else "roNoResponse")));
    ltype.Members.Add(mem);
  end;
  aFile.Types.Add(ltype);
end;

method EchoesRodlCodeGen.Invk_GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  var l_EntityName := aEntity.Name;

  var ltype := new CGClassTypeDefinition($"{l_EntityName}_EventSinkProxy",
                                         Visibility := CGTypeVisibilityKind.Public);
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    ltype.Ancestors.Add(ResolveDataTypeToTypeRef(aLibrary, $"{aEntity.AncestorName}_EventSinkProxy", aEntity.AncestorName))
  else
    ltype.Ancestors.Add("RemObjects.SDK.Server.EventSinkProxy".AsTypeReference_NotNullable);

  ltype.Attributes.Add(new CGAttribute("RemObjects.SDK.Server.EventSinkProxy".AsTypeReference_NotNullable,
                                       [new CGCallParameter(l_EntityName.AsLiteralExpression, "Name"),
                                        new CGCallParameter(new CGTypeOfExpression($"I{l_EntityName}".AsNamedIdentifierExpression), "EventSink")]));
  ltype.ImplementedInterfaces.Add($"I{l_EntityName}".AsTypeReference_NotNullable);

  ltype.Members.Add(new CGMethodDefinition(self.INVK_GET_INTERFACE_NAME,
                                           [l_EntityName.AsLiteralExpression.AsReturnStatement],
                                           ReturnType := CGPredefinedTypeReference.String,
                                           Virtuality := CGMemberVirtualityKind.Override,
                                           Visibility := CGMemberVisibilityKind.Protected));

  ltype.Members.Add(new CGMethodDefinition(self.INVK_GET_EVENT_SINK_TYPE,
                                           [new CGTypeOfExpression($"I{l_EntityName}".AsNamedIdentifierExpression).AsReturnStatement],
                                           ReturnType := "System.Type".AsTypeReference,
                                           Virtuality := CGMemberVirtualityKind.Override,
                                           Visibility := CGMemberVisibilityKind.Protected));

  ltype.Members.Add(
    new CGConstructorDefinition("",
                                 new CGConstructorCallStatement(
                                     CGInheritedExpression.Inherited,
                                     ["message".AsNamedIdentifierExpression.AsCallParameter,
                                     "channel".AsNamedIdentifierExpression.AsCallParameter,
                                     "eventTargets".AsNamedIdentifierExpression.AsCallParameter]),
                                     Parameters := [new CGParameterDefinition("message", "RemObjects.SDK.IMessage".AsTypeReference_NotNullable),
                                                    new CGParameterDefinition("channel", "RemObjects.SDK.Server.IServerEventChannel".AsTypeReference_NotNullable),
                                                    new CGParameterDefinition("eventTargets", "RemObjects.SDK.Server.IEventTargets".AsTypeReference_NotNullable)].ToList,
                                     Visibility :=  CGMemberVisibilityKind.Public));

  for rodl_member in aEntity.DefaultInterface.Items do begin
    var mem := new CGMethodDefinition(rodl_member.Name,
                                  ImplementsInterface := $"I{l_EntityName}".AsTypeReference_NotNullable,
                                  ImplementsInterfaceMember := rodl_member.Name,
                                  Virtuality := CGMemberVirtualityKind.Virtual,
                                  Visibility := CGMemberVisibilityKind.Public);

    var l_message := new CGPropertyAccessExpression(CGSelfExpression.Self, self.INVK_MESSAGE);
    var l_channel := new CGPropertyAccessExpression(CGSelfExpression.Self, self.INVK_SERVER_EVENT_CHANNEL);
    var l_body := mem.Statements;

    for rodl_param in rodl_member.Items do
      case rodl_param.ParamFlag of
        ParamFlags.In: begin
          mem.Parameters.Add(new CGParameterDefinition(rodl_param.Name,
                                                       ResolveDataTypeToTypeRef(aLibrary, rodl_param.DataType),
                                                       Modifier := CGParameterModifierKind.In));
        end;
      else
        raise new Exception($"Parameter type '{rodl_param.ParamFlag}' is not supported for event sinks");
      end;

    l_body.Add(new CGMethodCallExpression(l_message,
                                          "InitializeEventMessage",
                                          [l_channel.AsCallParameter,
                                           new CGMethodCallExpression(nil, self.INVK_GET_INTERFACE_NAME).AsCallParameter,
                                           rodl_member.Name.AsLiteralExpression.AsCallParameter]));

    for rodl_param in rodl_member.Items do
      l_body.Add(Intf_generateWriteStatement(aLibrary, l_message, rodl_param));

    l_body.Add(new CGMethodCallExpression(l_message, "FinalizeMessage"));
    l_body.Add(new CGMethodCallExpression(l_channel,
                                          "DispatchEvent",
                                          [l_message.AsCallParameter,
                                           new CGMethodCallExpression(nil, self.INVK_GET_EVENT_SINK_TYPE).AsCallParameter,
                                           new CGPropertyAccessExpression(CGSelfExpression.Self, self.INVK_EVENT_TARGETS).AsCallParameter]));
    ltype.Members.Add(mem);
  end;
  aFile.Types.Add(ltype);
end;

method EchoesRodlCodeGen.GenerateObfuscationAttribute: CGAttribute;
begin
  exit new CGAttribute("System.Reflection.ObfuscationAttribute".AsTypeReference_NotNullable,
                       [new CGCallParameter(true.AsLiteralExpression, "Exclude")])
end;


end.