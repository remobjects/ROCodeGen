namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

type
  JavaRodlCodeGen = public class (RodlCodeGen)
  private
    method isPrimitive(aType: String):Boolean;
    method GenerateROSDKType(aName: String): String;
    method GenerateGetProperty(aParent:CGExpression;Name:String): CGExpression;
    method GenerateSetProperty(aParent:CGExpression;Name:String; aValue:CGExpression): CGStatement;
    method GenerateOperationAttribute(aLibrary: RodlLibrary; aEntity: RodlOperation;Statements: List<CGStatement>);
    method GetReaderStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: CGExpression := new CGParameterAccessExpression("aMessage")): CGStatement;
    method GetReaderExpression(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: CGExpression := new CGParameterAccessExpression("aMessage")): CGExpression;
    method GetWriterStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; useGetter: Boolean := True; variableName: CGExpression := new CGParameterAccessExpression("aMessage")): CGStatement;
    method GetWriterStatement_DefaultValues(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: CGExpression := new CGParameterAccessExpression("aMessage")): CGStatement;

    method WriteToMessage_Method(aLibrary: RodlLibrary; aEntity: RodlStructEntity;useDefaultValues:Boolean): CGMethodDefinition;
    method ReadFromMessage_Method(aLibrary: RodlLibrary; aEntity: RodlStructEntity): CGMethodDefinition;
    method GenerateServiceProxyMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceProxyMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyEndMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyEndMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation;&locked:Boolean): CGMethodDefinition;
    method GenerateServiceConstructors(aLibrary: RodlLibrary; aEntity: RodlService; aService:CGClassTypeDefinition);

    method HandleAtributes_private(aLibrary: RodlLibrary; aEntity: RodlEntity): CGFieldDefinition;
    method HandleAtributes_public(aLibrary: RodlLibrary; aEntity: RodlEntity): CGMethodDefinition;
    method ConvertToSimple(aElementType_str: String; aElementType: CGTypeReference; aValue: CGExpression): CGStatement;
    method ConvertToObject(aElementType_str: String; aElementType: CGTypeReference): CGTypeReference;
    method IsSimpleType(aElementType_str: String): Boolean;
  protected
    method AddUsedNamespaces(aFile: CGCodeUnit; aLibrary: RodlLibrary);override;
    method AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary);override;
    method GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum); override;
    method GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);override;
    method GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);override;
    method GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);override;
    method GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);override;
    method GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);override;
    method GetGlobalName(aLibrary: RodlLibrary): String;override;
    method GetIncludesNamespace(aLibrary: RodlLibrary): String; override;
  public
    constructor;
    property addROSDKPrefix: Boolean := true;
    property isCooperMode: Boolean := false;
    method GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; override;
  end;

implementation

constructor JavaRodlCodeGen;
begin
  CodeGenTypes.Add("integer", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  CodeGenTypes.Add("datetime", "java.util.Date".AsTypeReference);
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeReference.Double));
  CodeGenTypes.Add("currency", "java.math.BigDecimal".AsTypeReference);
  CodeGenTypes.Add("widestring", ResolveStdtypes(CGPredefinedTypeReference.String));
  CodeGenTypes.Add("ansistring", ResolveStdtypes(CGPredefinedTypeReference.String));
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeReference.Int64));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeReference.Boolean));
  CodeGenTypes.Add("variant", "com.remobjects.sdk.VariantType".AsTypeReference);
  CodeGenTypes.Add("binary", new CGArrayTypeReference(ResolveStdtypes(CGPredefinedTypeReference.Int8)));
  CodeGenTypes.Add("xml", "com.remobjects.sdk.XmlType".AsTypeReference);
  CodeGenTypes.Add("guid", "java.util.UUID".AsTypeReference);
  CodeGenTypes.Add("decimal", "java.math.BigDecimal".AsTypeReference);
  CodeGenTypes.Add("utf8string", ResolveStdtypes(CGPredefinedTypeReference.String));
  CodeGenTypes.Add("xsdatetime", "java.util.Date".AsTypeReference);

  CodeGenTypes.Add("nullableinteger", ResolveStdtypes(CGPredefinedTypeReference.Int32, true));
  CodeGenTypes.Add("nullabledatetime", "java.util.Date".AsTypeReference);
  CodeGenTypes.Add("nullabledouble", ResolveStdtypes(CGPredefinedTypeReference.Double, true));
  CodeGenTypes.Add("nullablecurrency", "java.math.BigDecimal".AsTypeReference);
  CodeGenTypes.Add("nullableint64", ResolveStdtypes(CGPredefinedTypeReference.Int64, true));
  CodeGenTypes.Add("nullableboolean", ResolveStdtypes(CGPredefinedTypeReference.Boolean, true));
  CodeGenTypes.Add("nullableguid", "java.util.UUID".AsTypeReference);
  CodeGenTypes.Add("nullabledecimal", "java.math.BigDecimal".AsTypeReference);

  ReaderFunctions.Add("integer", "Int32");
  ReaderFunctions.Add("datetime", "DateTime");
  ReaderFunctions.Add("double", "Double");
  ReaderFunctions.Add("currency", "Currency");
  ReaderFunctions.Add("widestring", "WideString");
  ReaderFunctions.Add("ansistring", "AnsiString");
  ReaderFunctions.Add("int64", "Int64");
  ReaderFunctions.Add("boolean", "Boolean");
  ReaderFunctions.Add("variant", "Variant");
  ReaderFunctions.Add("binary", "Binary");
  ReaderFunctions.Add("xml", "Xml");
  ReaderFunctions.Add("guid", "Guid");
  ReaderFunctions.Add("decimal", "Decimal");
  ReaderFunctions.Add("utf8string", "Utf8String");
  ReaderFunctions.Add("xsdatetime", "DateTime");

  ReaderFunctions.Add("nullableinteger", "NullableInt32");
  ReaderFunctions.Add("nullabledatetime", "NullableDateTime");
  ReaderFunctions.Add("nullabledouble", "NullableDouble");
  ReaderFunctions.Add("nullablecurrency", "NullableCurrency");
  ReaderFunctions.Add("nullableint64", "NullableInt64");
  ReaderFunctions.Add("nullableboolean", "NullableBoolean");
  ReaderFunctions.Add("nullableguid", "NullableGuid");
  ReaderFunctions.Add("nullabledecimal", "NullableDecimal");

  ReservedWords.Add([
    "abstract", "and", "add", "async", "as", "begin", "break", "case", "class", "const", "constructor", "continue",
    "delegate", "default", "div", "do", "downto", "each", "else", "empty", "end", "enum", "ensure", "event", "except",
    "exit", "external", "false", "final", "finalizer", "finally", "flags", "for", "forward", "function", "global", "has",
    "if", "implementation", "implements", "implies", "in", "index", "inline", "inherited", "interface", "invariants", "is",
    "iterator", "locked", "locking", "loop", "matching", "method", "mod", "namespace", "nested", "new", "nil", "not",
    "nullable", "of", "old", "on", "operator", "or", "out", "override", "pinned", "partial", "private", "property",
    "protected", "public", "reintroduce", "raise", "read", "readonly", "remove", "repeat", "require", "result", "sealed",
    "self", "sequence", "set", "shl", "shr", "static", "step", "then", "to", "true", "try", "type", "typeof", "until",
    "unsafe", "uses", "using", "var", "virtual", "where", "while", "with", "write", "xor", "yield"]);
end;

method  JavaRodlCodeGen.WriteToMessage_Method(aLibrary: RodlLibrary; aEntity: RodlStructEntity;useDefaultValues:Boolean): CGMethodDefinition;
begin
  var param_aName := new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeReference.String));
  var param_aMessage := new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference);
  var l_method := new CGMethodDefinition("writeToMessage",
                        Parameters := [param_aName, param_aMessage].ToList,
                                        Virtuality := CGMemberVirtualityKind.Override,
                                        Visibility := CGMemberVisibilityKind.Public);

  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(GenerateGetProperty(param_aMessage.AsExpression, "UseStrictFieldOrderForStructs"),
                                                        lIfRecordStrictOrder_True,
                                                        lIfRecordStrictOrder_False
  );
  l_method.Statements.Add(lIfRecordStrictOrder);

  if assigned(aEntity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
      new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                 "writeToMessage",
                                 [param_aName.AsCallParameter, param_aMessage.AsCallParameter].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := aEntity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for f: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(f.Name.ToLowerInvariant, f);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for f: RodlField in aEntity.Items do
    if not lSortedFields.ContainsKey(f.Name.ToLowerInvariant) then begin
      lSortedFields.Add(f.Name.ToLowerInvariant, f);
      lIfRecordStrictOrder_True.Statements.Add(
        iif(useDefaultValues, GetWriterStatement_DefaultValues(aLibrary, f),GetWriterStatement(aLibrary, f))
      );
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(
      iif(useDefaultValues, GetWriterStatement_DefaultValues(aLibrary, lSortedFields.Item[lvalue]),GetWriterStatement(aLibrary, lSortedFields.Item[lvalue]))
    );
  exit l_method;
end;


method  JavaRodlCodeGen.AddUsedNamespaces(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  for Rodl: RodlUse in aLibrary.Uses.Items do begin
    if length(Rodl.Includes:JavaModule) > 0 then
      aFile.Imports.Add(new CGImport(Rodl.Includes:JavaModule))
     else if not String.IsNullOrEmpty(Rodl.Namespace) then
      aFile.Imports.Add(new CGImport(Rodl.Namespace));
  end;
  if not addROSDKPrefix then
    aFile.Imports.Add(new CGImport("com.remobjects.sdk"));
{
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("java.net.URI")));
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("java.util.Collection")));
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.ClientChannel")));
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.Message")));
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.ReferenceType")));
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.TypeManager")));
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.AsyncRequest")));
  aFile.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.AsyncProxy")));
}
end;

method JavaRodlCodeGen.GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var lAncestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := GenerateROSDKType("ComplexType");

  var lstruct := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name), lAncestorName.AsTypeReference,
                            &Partial := true,
                            Visibility := CGTypeVisibilityKind.Public
                            );
  lstruct.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(lstruct);
  {$REGION private class _attributes: HashMap<String, String>;}
  if (aEntity.CustomAttributes.Count > 0) then
    lstruct.Members.Add(HandleAtributes_private(aLibrary,aEntity));
  {$ENDREGION}
  {$REGION protected class var s_%fldname%: %fldtype%}
  for lm :RodlTypedEntity in aEntity.Items do begin
    lstruct.Members.Add(
                        new CGFieldDefinition($"s_{lm.Name}", ResolveDataTypeToTypeRef(aLibrary, lm.DataType),
                                              &Static := true,
                                              Visibility := CGMemberVisibilityKind.Protected
                                              ));
  end;
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: String): String; override;}
  if (aEntity.CustomAttributes.Count > 0) then
    lstruct.Members.Add(HandleAtributes_public(aLibrary,aEntity));
  {$ENDREGION}
  if aEntity.Items.Count >0 then begin
    {$REGION public class method setDefaultValues(p_%fldname%: %fldtype%)}
    var lsetDefaultValues := new CGMethodDefinition("setDefaultValues",
                                Visibility := CGMemberVisibilityKind.Public,
                                &Static := true
                                );
    lstruct.Members.Add(lsetDefaultValues);
    for lm: RodlTypedEntity in aEntity.Items do begin
      var temp_param := new CGParameterDefinition($"p_{lm.Name}", ResolveDataTypeToTypeRef(aLibrary,lm.DataType));
      lsetDefaultValues.Parameters.Add(temp_param);
      lsetDefaultValues.Statements.Add(
          new CGAssignmentStatement(
                new CGFieldAccessExpression(nil, $"s_{lm.Name}"),
                temp_param.AsExpression
        )
      );
    end;
    {$ENDREGION}
    {$REGION private %f_fldname%: %fldtype% + public getter/setter}
    for lm :RodlTypedEntity in aEntity.Items do begin
      var ltype := ResolveDataTypeToTypeRef(aLibrary,lm.DataType);
      var temp_field := new CGFieldDefinition($"f_{lm.Name}",
                                              ltype,
                                              Visibility := CGMemberVisibilityKind.Private);

      var expr_s_field := new CGFieldAccessExpression(nil, $"s_{lm.Name}");
      lstruct.Members.Add(temp_field);
      if not isCooperMode then begin
        var param_aValue := new CGParameterDefinition("aValue",ltype);
        lstruct.Members.Add(new CGMethodDefinition($"set{lm.Name}",
                                                    [new CGAssignmentStatement(temp_field.AsExpression, param_aValue.AsExpression)],
                                                    Parameters := [param_aValue].ToList,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    XmlDocumentation := GenerateDocumentation(lm)));
        var l_st: CGStatement;
        if IsSimpleType(lm.DataType) then
          l_st := temp_field.AsExpression.AsReturnStatement
        else
          l_st := new CGIfThenElseStatement(new CGBinaryOperatorExpression(temp_field.AsExpression, CGNilExpression.Nil, CGBinaryOperatorKind.NotEquals),
                                                      temp_field.AsExpression.AsReturnStatement,
                                                      expr_s_field.AsReturnStatement);
        lstruct.Members.Add(new CGMethodDefinition($"get{lm.Name}",
                                                    [l_st],
                                                    ReturnType := ltype,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    XmlDocumentation := GenerateDocumentation(lm)));
      end;
    end;
    {$ENDREGION}
    {$REGION public method writeToMessage(aName: String; aMessage: Message); override;}
    lstruct.Members.Add(WriteToMessage_Method(aLibrary,aEntity, true));
    {$ENDREGION}
    {$REGION method ReadFromMessage_Method(aName: String; aMessage: Message); override;}
    lstruct.Members.Add(ReadFromMessage_Method(aLibrary,aEntity));
    {$ENDREGION}
    {$REGION public property %fldname%: %fldtype%}
    if isCooperMode then begin
      for lm :RodlTypedEntity in aEntity.Items do begin
        var f_name := new CGFieldAccessExpression(nil, $"f_{lm.Name}");
        var s_name := new CGFieldAccessExpression(nil, $"s_{lm.Name}");
        var l_st: CGStatement;
        if IsSimpleType(lm.DataType) then
          l_st := f_name.AsReturnStatement
        else
          l_st := new CGIfThenElseStatement(new CGBinaryOperatorExpression(f_name, CGNilExpression.Nil, CGBinaryOperatorKind.NotEquals),
                                                      f_name.AsReturnStatement,
                                                      s_name.AsReturnStatement);
        lstruct.Members.Add(new CGPropertyDefinition(lm.Name,
                            ResolveDataTypeToTypeRef(aLibrary,lm.DataType),
                            [l_st],
                            SetExpression := f_name,
                            Visibility := CGMemberVisibilityKind.Public,
                            XmlDocumentation := GenerateDocumentation(lm)));
      end;
    end;
    {$ENDREGION}
  end;
end;

method JavaRodlCodeGen.GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
begin
  var lElementType: CGTypeReference := ResolveDataTypeToTypeRef(aLibrary, SafeIdentifier(aEntity.ElementType));
  var lElementTypeName: String  := aEntity.ElementType.ToLowerInvariant();
  var lIsStandardType: Boolean := ReaderFunctions.ContainsKey(lElementTypeName);
  var lIsEnum: Boolean := isEnum(aLibrary, aEntity.ElementType);
  var lIsArray: Boolean := isArray(aLibrary, aEntity.ElementType);
  var lIsStruct: Boolean := isStruct(aLibrary, aEntity.ElementType);

  var lArray := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name), GenerateROSDKType("ArrayType").AsTypeReference,
                                          Visibility := CGTypeVisibilityKind.Public,
                                          &Partial := true
                                          );
  lArray.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(lArray);

  if not isCooperMode then begin
    lArray.Attributes.Add(new CGAttribute("SuppressWarnings".AsTypeReference,
                           ["rawtypes".AsLiteralExpression.AsCallParameter].ToList));
  end;

  {$REGION Private class _attributes: HashMap<String, String>;}
  if (aEntity.CustomAttributes.Count > 0) then begin
    lArray.Members.Add(HandleAtributes_private(aLibrary,aEntity));
  end;
  {$ENDREGION}

  {$REGION Enum values cache}
  /* private ElementType[] fEnumValues;*/
  // Actually this should be a static variable. Unfortunately it seems that atm the codegen doesn't allow to define static constructors
  if lIsEnum then begin
    // Cache field
    lArray.Members.Add(new CGFieldDefinition("fEnumValues", new CGArrayTypeReference(lElementType)));

    // Cache initializer
    /* this.fEnumValues = NewEnum.values(); */
    lArray.Members.Add(
      new CGMethodDefinition("initEnumValues",
                           [ new CGAssignmentStatement(new CGFieldAccessExpression(CGSelfExpression.Self, "fEnumValues"),
                                                      new CGMethodCallExpression(lElementType.AsExpression(), "values")) ],
                            Visibility := CGMemberVisibilityKind.Private));
  end;
  {$ENDREGION}

  {$REGION Optional initializer call}
  /* this.initEnumValues(); */
  var lInitializerCall: CGStatement := iif(lIsEnum, new CGMethodCallExpression(CGSelfExpression.Self, "initEnumValues"), nil);
  {$ENDREGION}

  {$REGION .ctor}
  var lStatements1 := new List<CGStatement>();
  /* super(); */
  lStatements1.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, new List<CGCallParameter>()));
  if assigned(lInitializerCall) then begin
    /* this.initEnumValues(); */
    lStatements1.Add(lInitializerCall);
  end;

  lArray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lStatements1
      )
  );

  {$ENDREGION}

  {$REGION .ctor(aCapacity: Integer)}
  var param_aCapacity :=  new CGParameterDefinition("aCapacity", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  var lStatements2 := new List<CGStatement>();
  /* super(aCapacity); */
  lStatements2.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [param_aCapacity.AsCallParameter].ToList));
  if assigned(lInitializerCall) then begin
    /* this.initEnumValues(); */
    lStatements2.Add(lInitializerCall);
  end;

  lArray.Members.Add(
    new CGConstructorDefinition(
      Parameters := [param_aCapacity].ToList(),
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lStatements2
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aCollection: Collection)}
  var param_aCollection := new CGParameterDefinition("aCollection", "java.util.Collection".AsTypeReference()) ;
  var lStatements3 := new List<CGStatement>();
  lStatements3.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [param_aCollection.AsCallParameter].ToList));
  if assigned(lInitializerCall) then begin
    lStatements3.Add(lInitializerCall);
  end;

  lArray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Parameters := [param_aCollection].ToList(),
      Statements := lStatements3
      )
  );
  {$ENDREGION}

  {$REGION .ctor(anArray: array of Object)}
  var param_anArray := new CGParameterDefinition("anArray", new CGArrayTypeReference(ResolveStdtypes(CGPredefinedTypeReference.Object)));
  var lStatements4 := new List<CGStatement>();
  lStatements4.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [param_anArray.AsCallParameter].ToList));
  if assigned(lInitializerCall) then begin
    lStatements4.Add(lInitializerCall);
  end;

  lArray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Parameters := [param_anArray].ToList,
      Statements:= lStatements4
      )
  );
  {$ENDREGION}

  {$REGION method add: %ARRAY_TYPE%;}
  if isComplex(aLibrary,aEntity.ElementType) then begin
    var localvar_lresult := new CGVariableDeclarationStatement("lresult",lElementType,new CGNewInstanceExpression(lElementType));
    lArray.Members.Add(
      new CGMethodDefinition("add",
        Visibility := CGMemberVisibilityKind.Public,
        ReturnType := lElementType,
        Statements:=
          [localvar_lresult,
           new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", [localvar_lresult.AsCallParameter].ToList),
           localvar_lresult.AsExpression.AsReturnStatement
          ].ToList
        )
    );
  end;
  {$ENDREGION}

  {$REGION public class method getAttributeValue(aName: String): String; override;}
  if (aEntity.CustomAttributes.Count > 0) then
    lArray.Members.Add(HandleAtributes_public(aLibrary,aEntity));
  {$ENDREGION}

  var param_anItem := new CGParameterDefinition("anItem", lElementType);
  {$REGION method addItem(anItem: %ARRAY_TYPE%)}
  lArray.Members.Add(
    new CGMethodDefinition("addItem",
                           [new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                       "addItem",
                                                      [param_anItem.AsCallParameter])],
                           Visibility := CGMemberVisibilityKind.Public,
                           Parameters := [param_anItem].ToList));
  {$ENDREGION}

  var param_anIndex := new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32));
  {$REGION method insertItem(anItem: %ARRAY_TYPE%; anIndex: Integer);}
  lArray.Members.Add(
    new CGMethodDefinition("insertItem",
                           [new CGMethodCallExpression(CGInheritedExpression.Inherited,"insertItem",
                                                      [param_anItem.AsCallParameter,
                                                      param_anIndex.AsCallParameter].ToList)],
                            Parameters := [param_anItem, param_anIndex].ToList,
                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}

  {$REGION method replaceItemAtIndex(anItem: %ARRAY_TYPE%; anIndex: Integer);}
  lArray.Members.Add(
    new CGMethodDefinition("replaceItemAtIndex",
                          [new CGMethodCallExpression(CGInheritedExpression.Inherited, "replaceItemAtIndex",
                                                  [param_anItem.AsCallParameter,
                                                   param_anIndex.AsCallParameter])],
                          Parameters := [param_anItem,param_anIndex].ToList,
                          Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method getItemAtIndex(anIndex: Integer): %ARRAY_TYPE%; override;}
  lArray.Members.Add(
    new CGMethodDefinition("getItemAtIndex",
                            [
                              ConvertToSimple(lElementTypeName,
                                              lElementType,
                                              new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                         "__getItemAtIndex",
                                                         [param_anIndex.AsCallParameter()]))
                            ],
                            Parameters := [param_anIndex].ToList(),
                            ReturnType := lElementType,
                            //Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public)
  );
  {$ENDREGION}

  {$REGION method itemClass: &Class;}
  lArray.Members.Add(
    new CGMethodDefinition("itemClass",
                           [new CGTypeOfExpression(lElementType.AsExpression).AsReturnStatement],
                            ReturnType := "Class".AsTypeReference,
                            Visibility := CGMemberVisibilityKind.Public
                            )
      );
  {$ENDREGION}

  {$REGION method itemTypeName: String;}
  lArray.Members.Add(
    new CGMethodDefinition("itemTypeName",
                           [SafeIdentifier(aEntity.ElementType).AsLiteralExpression.AsReturnStatement],
                            ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                            Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  var param_aMessage := new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference);
  {$REGION method writeItemToMessage(aMessage: Message; anIndex: Integer); override;}
  var l_methodName: String;
  if lIsStandardType then begin
    l_methodName := ReaderFunctions[lElementTypeName];
  end
  else if lIsArray then begin
    l_methodName := "Array";
  end
  else if lIsStruct then begin
    l_methodName := "Complex";
  end
  else if lIsEnum then begin
    l_methodName := "Enum";
  end;

  var l_arg0 := CGNilExpression.Nil.AsCallParameter;
  var l_arg1_exp: CGExpression := new CGMethodCallExpression(CGSelfExpression.Self,"getItemAtIndex",[param_anIndex.AsCallParameter].ToList);
  if lIsEnum then begin
    l_arg1_exp := new CGMethodCallExpression(l_arg1_exp, "ordinal");
  end;
  var l_arg1 := l_arg1_exp.AsCallParameter;

  lArray.Members.Add(
    new CGMethodDefinition("writeItemToMessage",
                           [new CGMethodCallExpression(param_aMessage.AsExpression,"write" +  l_methodName,  [l_arg0,l_arg1].ToList)],
                            Parameters := [param_aMessage, param_anIndex].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method readItemFromMessage(aMessage: Message; anIndex: Integer); override;}
  var lArgList: List<CGCallParameter>;
  if lIsStruct or lIsArray then begin
    lArgList := [ l_arg0, new CGTypeOfExpression(lElementType.AsExpression()).AsCallParameter() ].ToList();
  end
  else begin
    lArgList := [ l_arg0 ].ToList();
  end;

  var lMethodStatements: List<CGStatement> := new List<CGStatement>();
  if lIsEnum then begin
    lMethodStatements.Add(
      new CGMethodCallExpression(
        CGSelfExpression.Self,
        "addItem",
        [
          new CGArrayElementAccessExpression(
            new CGFieldAccessExpression(CGSelfExpression.Self, "fEnumValues"),
            [ CGExpression(new CGMethodCallExpression(param_aMessage.AsExpression(), "readEnum", lArgList)) ].ToList()
          ).AsCallParameter()
        ].ToList()
      )
    );
  end
  else begin
    lMethodStatements.Add(
      new CGMethodCallExpression(
        CGSelfExpression.Self,
        "addItem",
        [ new CGMethodCallExpression(param_aMessage.AsExpression(), "read" +  l_methodName, lArgList).AsCallParameter() ].ToList()
      )
    );
  end;

  lArray.Members.Add(
    new CGMethodDefinition(
      "readItemFromMessage",
      lMethodStatements,
      Parameters := [param_aMessage, param_anIndex].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public
    )
  );
  {$ENDREGION}
end;

method JavaRodlCodeGen.GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
begin
  var lexception := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name),
                                              GenerateROSDKType("ExceptionType").AsTypeReference,
                                              Visibility := CGTypeVisibilityKind.Public,
                                              &Partial := true
                                              );
  lexception.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(lexception);
  if not isCooperMode then
    lexception.Attributes.Add(new CGAttribute("SuppressWarnings".AsTypeReference,
                                             ["serial".AsLiteralExpression.AsCallParameter].ToList));

  {$REGION private class _attributes: HashMap<String, String>;}
  if (aEntity.CustomAttributes.Count > 0) then
    lexception.Members.Add(HandleAtributes_private(aLibrary,aEntity));
  {$ENDREGION}

  {$REGION public class method getAttributeValue(aName: String): String; override;}
  if (aEntity.CustomAttributes.Count > 0) then
    lexception.Members.Add(HandleAtributes_public(aLibrary,aEntity));
  {$ENDREGION}

  if not isCooperMode then begin
  {$REGION private property %f_fldname%: %fldtype% + public getter/setter}
    for lm :RodlTypedEntity in aEntity.Items do begin
      var ltype := ResolveDataTypeToTypeRef(aLibrary,lm.DataType);
      var temp_field := new CGFieldDefinition($"f_{lm.Name}",
                                              ltype,
                                              Visibility := CGMemberVisibilityKind.Private);
      lexception.Members.Add(temp_field);
      if not isCooperMode then begin
        var param_aValue := new CGParameterDefinition("aValue",ltype);
        lexception.Members.Add(new CGMethodDefinition($"set{lm.Name}",
                                      [new CGAssignmentStatement(temp_field.AsExpression, param_aValue.AsExpression)],
                                      Parameters := [param_aValue].ToList,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      XmlDocumentation := GenerateDocumentation(lm)));
        lexception.Members.Add(new CGMethodDefinition($"get{lm.Name}",
                                      [temp_field.AsExpression.AsReturnStatement],
                                      ReturnType := ltype,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      XmlDocumentation := GenerateDocumentation(lm)));
      end;
    end;
  {$ENDREGION}
  end;

  var param_anExceptionMessage := new CGParameterDefinition("anExceptionMessage", ResolveStdtypes(CGPredefinedTypeReference.String));
  {$REGION .ctor(aExceptionMessage: String)}
  lexception.Members.Add(
      new CGConstructorDefinition(
          "",
          [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                          [param_anExceptionMessage.AsCallParameter].ToList)],
          Parameters := [param_anExceptionMessage].ToList,
          Visibility := CGMemberVisibilityKind.Public
          ));
  {$ENDREGION}

  {$REGION .ctor(aExceptionMessage: String; aFromServer: Boolean)}
  var param_aFromServer := new CGParameterDefinition("aFromServer", ResolveStdtypes(CGPredefinedTypeReference.Boolean));
  lexception.Members.Add(
      new CGConstructorDefinition(
          "",
          [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                          [param_anExceptionMessage.AsCallParameter,
                                          param_aFromServer.AsCallParameter].ToList)],
          Parameters :=[param_anExceptionMessage, param_aFromServer].ToList,
          Visibility := CGMemberVisibilityKind.Public
          ));
  {$ENDREGION}

  if aEntity.Items.Count >0 then begin
    {$REGION public method writeToMessage(aName: String; aMessage: Message); override;}
    lexception.Members.Add(WriteToMessage_Method(aLibrary,aEntity,false));
    {$ENDREGION}
    {$REGION method ReadFromMessage_Method(aName: String; aMessage: Message); override;}
    lexception.Members.Add(ReadFromMessage_Method(aLibrary,aEntity));
    {$ENDREGION}
  end;

  {$REGION public property %fldname%: %fldtype%}
  if isCooperMode then begin
    for lm :RodlTypedEntity in aEntity.Items do
      lexception.Members.Add(new CGPropertyDefinition(
      lm.Name,
      ResolveDataTypeToTypeRef(aLibrary,lm.DataType),
      Visibility := CGMemberVisibilityKind.Public,
      XmlDocumentation := GenerateDocumentation(lm)));
  end;
  {$ENDREGION}
end;

method JavaRodlCodeGen.GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  {$REGION I%SERVICE_NAME%}
  var lIService := new CGInterfaceTypeDefinition(SafeIdentifier("I"+aEntity.Name),
                                                 Visibility := CGTypeVisibilityKind.Public);
  lIService.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(lIService);
  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
    var m := GenerateServiceProxyMethodDeclaration(aLibrary, lop);
    m.XmlDocumentation := GenerateDocumentation(lop);
    lIService.Members.Add(m);
  end;

  {$ENDREGION}

  {$REGION I%SERVICE_NAME%_Async}
  var lIServiceAsync := new CGInterfaceTypeDefinition(SafeIdentifier("I"+aEntity.Name+"_Async"),
                                                      Visibility := CGTypeVisibilityKind.Public
                                                      );
  aFile.Types.Add(lIServiceAsync);
  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
    lIServiceAsync.Members.Add(GenerateServiceAsyncProxyBeginMethodDeclaration(aLibrary, lop));
    lIServiceAsync.Members.Add(GenerateServiceAsyncProxyEndMethodDeclaration(aLibrary, lop,false));
  end;
  {$ENDREGION}

  {$REGION %SERVICE_NAME%_Proxy}
  var lAncestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lAncestorName) then
    lAncestorName := GenerateROSDKType("Proxy")
  else
    lAncestorName := lAncestorName+"_Proxy";
  var lServiceProxy := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name+"_Proxy"),
                                                [lAncestorName.AsTypeReference].ToList,
                                                [lIService.Name.AsTypeReference].ToList,
                                                  Visibility := CGTypeVisibilityKind.Public,
                                                  &Partial := true
                                                  );
  aFile.Types.Add(lServiceProxy);

  GenerateServiceConstructors(aLibrary,aEntity, lServiceProxy);

  for lop : RodlOperation in aEntity.DefaultInterface:Items do
    lServiceProxy.Members.Add(GenerateServiceProxyMethod(aLibrary,lop));
  {$ENDREGION}

  {$REGION %SERVICE_NAME%_AsyncProxy}
  var lServiceAsyncProxy := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name+"_AsyncProxy"),
                                                      [GenerateROSDKType("AsyncProxy").AsTypeReference].ToList,
                                                      [lIServiceAsync.Name.AsTypeReference].ToList,
                                                      Visibility := CGTypeVisibilityKind.Public,
                                                      &Partial := true);
  aFile.Types.Add(lServiceAsyncProxy);
  GenerateServiceConstructors(aLibrary,aEntity,lServiceAsyncProxy);
  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod(aLibrary, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyEndMethod(aLibrary, lop));
  end;
  {$ENDREGION}
end;


method JavaRodlCodeGen.GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  var i_name := "I"+aEntity.Name;
  var i_adaptername := i_name+"_Adapter";
  var lIEvent := new CGInterfaceTypeDefinition(i_name,GenerateROSDKType("IEvents").AsTypeReference,
                            Visibility := CGTypeVisibilityKind.Public);
  lIEvent.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(lIEvent);

  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
    {$REGION %event_sink%Event}
    var lOperation := new CGClassTypeDefinition(SafeIdentifier(lop.Name+"Event"),GenerateROSDKType("EventType").AsTypeReference,
                                                Visibility := CGTypeVisibilityKind.Public,
                                                &Partial := true
                                                );
    if not isCooperMode then begin
      for lm :RodlParameter in lop.Items do begin
        var ltype := ResolveDataTypeToTypeRef(aLibrary,lm.DataType);
        var temp_field := new CGFieldDefinition($"f_{lm.Name}",
                                               ltype,
                                               Visibility := CGMemberVisibilityKind.Private);
        lOperation.Members.Add(temp_field);
        var param_aValue := new CGParameterDefinition("aValue",ltype);
        lOperation.Members.Add(new CGMethodDefinition($"set{lm.Name}",
                                                      [new CGAssignmentStatement(temp_field.AsExpression, param_aValue.AsExpression)],
                                                      Parameters := [param_aValue].ToList,
                                                      Visibility := CGMemberVisibilityKind.Public,
                                                      XmlDocumentation := GenerateDocumentation(lm)));
        lOperation.Members.Add(new CGMethodDefinition($"get{lm.Name}",
                                                      [temp_field.AsExpression.AsReturnStatement],
                                                      ReturnType := ltype,
                                                      Visibility := CGMemberVisibilityKind.Public,
                                                      XmlDocumentation := GenerateDocumentation(lm)));
       end;
    end;
    var param_aBuffer := new CGParameterDefinition("aBuffer", GenerateROSDKType("Message").AsTypeReference);
    var lop_method := new CGConstructorDefinition(
                              Parameters:=[param_aBuffer].ToList,
                              Visibility := CGMemberVisibilityKind.Public);
    lOperation.Members.Add(lop_method);

    for lm :RodlParameter in lop.Items do begin
      if isCooperMode then begin
        lOperation.Members.Add(new CGPropertyDefinition(
                                                        lm.Name,
                                                        ResolveDataTypeToTypeRef(aLibrary,lm.DataType),
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        XmlDocumentation := GenerateDocumentation(lm)));
      end;
      lop_method.Statements.Add(GetReaderStatement(aLibrary, lm, param_aBuffer.AsExpression));
    end;

    aFile.Types.Add(lOperation);
    {$ENDREGION}
    lIEvent.Members.Add(new CGMethodDefinition(SafeIdentifier(lop.Name),
                                               Parameters := [new CGParameterDefinition("aEvent", lOperation.Name.AsTypeReference)].ToList,
                                               Visibility := CGMemberVisibilityKind.Public,
                                               XmlDocumentation := GenerateDocumentation(lop)
    ));
  end;
  if not isCooperMode then begin
    var lIEventAdapter := new CGClassTypeDefinition(i_adaptername,
                              ImplementedInterfaces := [i_name.AsTypeReference].ToList,
                              Visibility := CGTypeVisibilityKind.Public);

    aFile.Types.Add(lIEventAdapter);
    for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
      lIEventAdapter.Members.Add(new CGMethodDefinition(SafeIdentifier(lop.Name),
                                                       Parameters := [new CGParameterDefinition("aEvent", SafeIdentifier(lop.Name+"Event").AsTypeReference)].ToList,
                                                       Visibility := CGMemberVisibilityKind.Public,
                                                       Virtuality := CGMemberVirtualityKind.Override
                                                       ));
    end;
    lIEventAdapter.Members.Add(new CGMethodDefinition("OnException",
                                                      Parameters := [new CGParameterDefinition("aEvent", GenerateROSDKType("OnExceptionEvent").AsTypeReference)].ToList,
                                                      Visibility := CGMemberVisibilityKind.Public,
                                                      Virtuality := CGMemberVirtualityKind.Override
                                                      ));
  end;
end;

method JavaRodlCodeGen.GetWriterStatement_DefaultValues(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: CGExpression): CGStatement;
begin
  var lentityname := aEntity.Name;
  var lLower: String  := aEntity.DataType.ToLowerInvariant();
  var l_isStandard := ReaderFunctions.ContainsKey(lLower);
  var l_isArray := False;
  var l_isStruct := False;
  var l_isEnum := False;
  var l_methodName: String;
  if l_isStandard then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(aLibrary, aEntity.DataType) then begin
    l_methodName := "Array";
    l_isArray := True;
  end
  else if isStruct(aLibrary, aEntity.DataType) then begin
    l_methodName := "Complex";
    l_isStruct :=True;
  end
  else if isEnum(aLibrary, aEntity.DataType) then begin
    l_methodName := "Enum";
    l_isEnum := True;
  end;

  var entityname_ID := GenerateGetProperty(CGSelfExpression.Self,lentityname);
  var l_if_conditional := new CGAssignedExpression(entityname_ID);
  var l_write := "write" +  l_methodName;
  var l_arg0 := lentityname.AsLiteralExpression.AsCallParameter;
  var l_arg1 := entityname_ID.AsCallParameter;
  if l_isStandard or l_isStruct or l_isArray then begin
    exit new CGMethodCallExpression(variableName,l_write, [l_arg0,l_arg1].ToList);
  end
  else if l_isEnum then begin
    exit new CGIfThenElseStatement(
      l_if_conditional,
      new CGMethodCallExpression(variableName,
                                 l_write,
                                 [l_arg0,
                                 new CGMethodCallExpression(entityname_ID,"ordinal").AsCallParameter].ToList),
      new CGBeginEndBlockStatement([CGStatement(
          new CGMethodCallExpression(variableName,l_write, [l_arg0,new CGIntegerLiteralExpression(0).AsCallParameter].ToList))].ToList)
        );
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;
end;

method JavaRodlCodeGen.ReadFromMessage_Method(aLibrary: RodlLibrary; aEntity: RodlStructEntity): CGMethodDefinition;
begin
  var param_aName := new CGParameterDefinition("aName",   ResolveStdtypes(CGPredefinedTypeReference.String));
  var param_aMessage := new CGParameterDefinition("aMessage",GenerateROSDKType("Message").AsTypeReference);

  var l_method := new CGMethodDefinition("readFromMessage",
                        Parameters := [param_aName, param_aMessage].ToList,
                        Virtuality := CGMemberVirtualityKind.Override,
                        Visibility := CGMemberVisibilityKind.Public);
  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(GenerateGetProperty(param_aMessage.AsExpression,"UseStrictFieldOrderForStructs"),
                                                        lIfRecordStrictOrder_True,
                                                        lIfRecordStrictOrder_False
  );
  l_method.Statements.Add(lIfRecordStrictOrder);

  if assigned(aEntity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
                      new CGMethodCallExpression(CGInheritedExpression.Inherited, "readFromMessage",
                                                [param_aName.AsCallParameter,
                                                 param_aMessage.AsCallParameter].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := aEntity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for f: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(f.Name.ToLowerInvariant, f);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for f: RodlField in aEntity.Items do
    if not lSortedFields.ContainsKey(f.Name.ToLowerInvariant) then begin
      lSortedFields.Add(f.Name.ToLowerInvariant, f);
      lIfRecordStrictOrder_True.Statements.Add(GetReaderStatement(aLibrary, f));
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(GetReaderStatement(aLibrary, lSortedFields.Item[lvalue]));

  exit l_method;
end;

method JavaRodlCodeGen.GetReaderStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: CGExpression): CGStatement;
begin
  var lreader := GetReaderExpression(aLibrary,aEntity,variableName);
  exit GenerateSetProperty(CGSelfExpression.Self,aEntity.Name, lreader);
end;

method JavaRodlCodeGen.HandleAtributes_private(aLibrary: RodlLibrary; aEntity: RodlEntity): CGFieldDefinition;
begin
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (aEntity.CustomAttributes.Count = 0) then exit;
  exit new CGFieldDefinition("_attributes",
                             new CGNamedTypeReference("java.util.HashMap", GenericArguments := [ResolveStdtypes(CGPredefinedTypeReference.String),ResolveStdtypes(CGPredefinedTypeReference.String)].ToList),
                             &Static := true,
                             Visibility := CGMemberVisibilityKind.Private);
end;

method JavaRodlCodeGen.HandleAtributes_public(aLibrary: RodlLibrary; aEntity: RodlEntity): CGMethodDefinition;
begin
  var param_aName := new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeReference.String));
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (aEntity.CustomAttributes.Count = 0) then exit;
  var l_method := new CGMethodDefinition("getAttributeValue",
                                  Parameters := [param_aName].ToList,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                  &Static := True,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public);

  var l_attributes := new CGFieldAccessExpression(nil, "_attributes");
  var l_if_true := new CGBeginEndBlockStatement();
  var l_if := new CGIfThenElseStatement(
      new CGBinaryOperatorExpression(l_attributes, CGNilExpression.Nil, CGBinaryOperatorKind.Equals),
      l_if_true);
  l_method.Statements.Add(l_if);
  l_if_true.Statements.Add(
          new CGAssignmentStatement(
                            l_attributes,
                            new CGNewInstanceExpression(new CGNamedTypeReference("java.util.HashMap", GenericArguments := [ResolveStdtypes(CGPredefinedTypeReference.String),ResolveStdtypes(CGPredefinedTypeReference.String)].ToList)))
  );

  for l_key: String in aEntity.CustomAttributes.Keys do begin
    l_if_true.Statements.Add(
      new CGMethodCallExpression(l_attributes,"put",
                                [EscapeString(l_key.ToLowerInvariant).AsLiteralExpression.AsCallParameter,
                              EscapeString(aEntity.CustomAttributes[l_key]).AsLiteralExpression.AsCallParameter].ToList
        ));
  end;
  l_method.Statements.Add(new CGMethodCallExpression(l_attributes,"get", [new CGMethodCallExpression(param_aName.AsExpression,"toLowerCase").AsCallParameter].ToList).AsReturnStatement);
  exit l_method;
end;

method JavaRodlCodeGen.GetWriterStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; useGetter: Boolean := True; variableName: CGExpression): CGStatement;
begin
  var lentityname := aEntity.Name;
  var lLower: String  := aEntity.DataType.ToLowerInvariant();
  var l_isStandard := ReaderFunctions.ContainsKey(lLower);
  var l_isArray := False;
  var l_isStruct := False;
  var l_isEnum := False;
  var l_methodName: String;
  if l_isStandard then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(aLibrary, aEntity.DataType) then begin
    l_methodName := "Array";
    l_isArray := True;
  end
  else if isStruct(aLibrary, aEntity.DataType) then begin
    l_methodName := "Complex";
    l_isStruct :=True;
  end
  else if isEnum(aLibrary, aEntity.DataType) then begin
    l_methodName := "Enum";
    l_isEnum := True;
  end;

  var writer_name := "write" +  l_methodName;
  var entity_ID := iif(useGetter,
                       GenerateGetProperty(CGSelfExpression.Self,lentityname),
                       new CGFieldAccessExpression(nil, lentityname));
  var l_arg0 := lentityname.AsLiteralExpression.AsCallParameter;
  var l_arg1 := entity_ID.AsCallParameter;
  if l_isStandard or l_isStruct or l_isArray then begin
    exit new CGMethodCallExpression(variableName,writer_name,[l_arg0,l_arg1].ToList);
  end
  else if l_isEnum then begin
    exit new CGMethodCallExpression(variableName,writer_name,[l_arg0, new CGMethodCallExpression(entity_ID,"ordinal").AsCallParameter].ToList);
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;
end;

method JavaRodlCodeGen.GetReaderExpression(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: CGExpression): CGExpression;
begin
  var lLower: String  := aEntity.DataType.ToLowerInvariant();
  var l_isStandard := ReaderFunctions.ContainsKey(lLower);
  var l_isArray := False;
  var l_isStruct := False;
  var l_isEnum := False;
  var l_methodName: String;
  if l_isStandard then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(aLibrary, aEntity.DataType) then begin
    l_methodName := "Array";
    l_isArray := True;
  end
  else if isStruct(aLibrary, aEntity.DataType) then begin
    l_methodName := "Complex";
    l_isStruct :=True;
  end
  else if isEnum(aLibrary, aEntity.DataType) then begin
    l_methodName := "Enum";
    l_isEnum := True;
  end;

  var reader_name := "read" +  l_methodName;
//  var l_reader := new CGIdentifierExpression("read" +  l_methodName, variableName);
  var l_arg0 : CGCallParameter := aEntity.Name.AsLiteralExpression.AsCallParameter;
  var l_type := ResolveDataTypeToTypeRef(aLibrary,aEntity.DataType);


  if l_isStandard then begin
    var temp := new CGMethodCallExpression(variableName,reader_name,[l_arg0].ToList);
    if isPrimitive(aEntity.DataType) then
      exit temp
    else
      exit new CGTypeCastExpression(temp,
                                    l_type,
                                    ThrowsException:=true);
  end
  else if l_isArray or l_isStruct then begin
    var l_arg1 := new CGTypeOfExpression(l_type.AsExpression).AsCallParameter;
    exit new CGTypeCastExpression(
        new CGMethodCallExpression(variableName,reader_name,[l_arg0,l_arg1].ToList),
        l_type,
        ThrowsException:=true);
  end
  else if l_isEnum then begin
    exit new CGArrayElementAccessExpression(new CGMethodCallExpression(l_type.AsExpression, "values"),
                                            [CGExpression(new CGMethodCallExpression(variableName,reader_name,[l_arg0].ToList))].ToList
      );
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;

end;

method JavaRodlCodeGen.GenerateServiceProxyMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  var l_method := GenerateServiceProxyMethodDeclaration(aLibrary,aEntity);
  var l_in:= new List<RodlParameter>;
  var l_out:= new List<RodlParameter>;
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_in.Add(lp);
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_out.Add(lp);
  end;

  var localvar_localMessage := new CGVariableDeclarationStatement(
                                      "_localMessage",
                                      GenerateROSDKType("Message").AsTypeReference,
                                      new CGTypeCastExpression(
                                                        new CGMethodCallExpression(
                                                                  GenerateGetProperty(CGSelfExpression.Self, "ProxyMessage"),
                                                                  "clone"),
                                                        GenerateROSDKType("Message").AsTypeReference,
                                                        ThrowsException:=True));
  l_method.Statements.Add(localvar_localMessage);
  GenerateOperationAttribute(aLibrary,aEntity,l_method.Statements);
  l_method.Statements.Add(
    new CGMethodCallExpression(localvar_localMessage.AsExpression, "initializeAsRequestMessage",
                                [aEntity.OwnerLibrary.Name.AsLiteralExpression.AsCallParameter,
                                new CGMethodCallExpression(CGSelfExpression.Self, "_getActiveInterfaceName").AsCallParameter,
                                aEntity.Name.AsLiteralExpression.AsCallParameter].ToList
      ));
  var ltry := new List<CGStatement>;
  var lfinally := new List<CGStatement>;


  for lp: RodlParameter in l_in do
    ltry.Add(GetWriterStatement(aLibrary,lp,false, localvar_localMessage.AsExpression));
  ltry.Add(new CGMethodCallExpression(localvar_localMessage.AsExpression, "finalizeMessage"));
  ltry.Add(new CGMethodCallExpression(GenerateGetProperty(CGSelfExpression.Self, "ProxyClientChannel"),
                                      "dispatch",
                                      [localvar_localMessage.AsCallParameter].ToList));
  var localvar_lResult: CGVariableDeclarationStatement;
  if assigned(aEntity.Result) then begin
    localvar_lResult := new CGVariableDeclarationStatement("lResult",l_method.ReturnType,GetReaderExpression(aLibrary,aEntity.Result,localvar_localMessage.AsExpression));
    ltry.Add(localvar_lResult);
  end;
  for lp: RodlParameter in l_out do
    ltry.Add(GenerateSetProperty(
                 new CGParameterAccessExpression($"_{lp.Name}"),
                 "Value",
                 GetReaderExpression(aLibrary,lp,localvar_localMessage.AsExpression)));
  if assigned(aEntity.Result) then
    ltry.Add(localvar_lResult.AsExpression.AsReturnStatement);
  lfinally.Add(GenerateSetProperty(GenerateGetProperty(CGSelfExpression.Self, "ProxyMessage"),
                                   "ClientID",
                                   GenerateGetProperty(localvar_localMessage.AsExpression,"ClientID")));
  lfinally.Add(new CGMethodCallExpression(localvar_localMessage.AsExpression, "clear"));
  l_method.Statements.Add(new CGTryFinallyCatchStatement(ltry, &FinallyStatements:= lfinally as not nullable));
  exit l_method;
end;

method JavaRodlCodeGen.GenerateServiceProxyMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  var l_method := new CGMethodDefinition(SafeIdentifier(aEntity.Name),
                                  Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_method.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(aLibrary, lp.DataType)));
  end;
  if assigned(aEntity.Result) then l_method.ReturnType := ResolveDataTypeToTypeRef(aLibrary, aEntity.Result.DataType);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_method.Parameters.Add(new CGParameterDefinition("_"+lp.Name,
                                                      new CGNamedTypeReference(GenerateROSDKType("ReferenceType"),
                                                                               GenericArguments:=[ConvertToObject(lp.DataType,ResolveDataTypeToTypeRef(aLibrary, lp.DataType))].ToList)));
  end;
  exit l_method;
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyBeginMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  var l_method:= new CGMethodDefinition("begin" + PascalCase(aEntity.Name),
                                  ReturnType := GenerateROSDKType("AsyncRequest").AsTypeReference,
                                  Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_method.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(aLibrary, lp.DataType)));
  end;
  l_method.Parameters.Add(new CGParameterDefinition("start", ResolveStdtypes(CGPredefinedTypeReference.Boolean)));
  l_method.Parameters.Add(new CGParameterDefinition("callback", GenerateROSDKType("AsyncRequest.IAsyncRequestCallback").AsTypeReference));
  exit l_method;
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyEndMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation;&locked:Boolean): CGMethodDefinition;
begin
  var l_method:= new CGMethodDefinition("end" + PascalCase(aEntity.Name),
      Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_method.Parameters.Add(new CGParameterDefinition(lp.Name,
                                                      new CGNamedTypeReference(GenerateROSDKType("ReferenceType"),
                                                                               GenericArguments := [ConvertToObject(lp.DataType, ResolveDataTypeToTypeRef(aLibrary, lp.DataType))].ToList)
                                                      ));
  end;
  if assigned(aEntity.Result) then
    l_method.ReturnType := ResolveDataTypeToTypeRef(aLibrary, aEntity.Result.DataType);

  l_method.Parameters.Add(new CGParameterDefinition("aAsyncRequest", GenerateROSDKType("AsyncRequest").AsTypeReference));
  l_method.Locked := &locked;
  exit l_method
end;


method JavaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  var l_method := GenerateServiceAsyncProxyBeginMethodDeclaration(aLibrary,aEntity);
  var l_in:= new List<RodlParameter>;
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_in.Add(lp);
  end;

  var localvar_localMessage := new CGVariableDeclarationStatement("_localMessage",
                                                           GenerateROSDKType("Message").AsTypeReference,
                                                           new CGTypeCastExpression(
                                                                              new CGMethodCallExpression(
                                                                                                    GenerateGetProperty(CGSelfExpression.Self,"ProxyMessage"),
                                                                                                    "clone"),
                                                                              GenerateROSDKType("Message").AsTypeReference,
                                                                              ThrowsException:=True)
                                                );
  l_method.Statements.Add(localvar_localMessage);

  GenerateOperationAttribute(aLibrary,aEntity,l_method.Statements);

  l_method.Statements.Add(
    new CGMethodCallExpression(localvar_localMessage.AsExpression,"initializeAsRequestMessage",
                              [aEntity.OwnerLibrary.Name.AsLiteralExpression.AsCallParameter,
                              new CGMethodCallExpression(CGSelfExpression.Self, "_getActiveInterfaceName").AsCallParameter,
                              aEntity.Name.AsLiteralExpression.AsCallParameter].ToList
    ));

  for lp: RodlParameter in l_in do
    l_method.Statements.Add(GetWriterStatement(aLibrary, lp, false, localvar_localMessage.AsExpression));
  l_method.Statements.Add(new CGMethodCallExpression(localvar_localMessage.AsExpression, "finalizeMessage"));
  l_method.Statements.Add(new CGMethodCallExpression(GenerateGetProperty(CGSelfExpression.Self,"ProxyClientChannel"),
                                                   "asyncDispatch",
                                                   [localvar_localMessage.AsCallParameter,
                                                   new CGSelfExpression().AsCallParameter,
                                                   new CGParameterAccessExpression("start").AsCallParameter,
                                                   new CGParameterAccessExpression("callback").AsCallParameter].ToList).AsReturnStatement
  );
  exit l_method;
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyEndMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  var l_method := GenerateServiceAsyncProxyEndMethodDeclaration(aLibrary,aEntity, true);

  var l_out:= new List<RodlParameter>;
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_out.Add(lp);
  end;

  var localvar_localMessage := new CGVariableDeclarationStatement("_localMessage",
                                                           GenerateROSDKType("Message").AsTypeReference,
                                                           GenerateGetProperty(new CGParameterAccessExpression("aAsyncRequest"),"ProcessMessage"));
  l_method.Statements.Add(localvar_localMessage);

  GenerateOperationAttribute(aLibrary, aEntity, l_method.Statements);

  var localvar_lResult : CGVariableDeclarationStatement;
  if assigned(aEntity.Result) then begin
    localvar_lResult := new CGVariableDeclarationStatement("lResult", l_method.ReturnType, GetReaderExpression(aLibrary,aEntity.Result,localvar_localMessage.AsExpression));
    l_method.Statements.Add(localvar_lResult);
  end;

  for lp: RodlParameter in l_out do
    l_method.Statements.Add(GenerateSetProperty(new CGParameterAccessExpression(lp.Name),
                                              "Value",
                                              GetReaderExpression(aLibrary,lp,localvar_localMessage.AsExpression)));
  var mess := GenerateGetProperty(new CGSelfExpression,"ProxyMessage");
  l_method.Statements.Add(GenerateSetProperty(mess,"ClientID",GenerateGetProperty(localvar_localMessage.AsExpression,"ClientID")));
  l_method.Statements.Add(new CGMethodCallExpression(localvar_localMessage.AsExpression,"clear"));
  if assigned(aEntity.Result) then
    l_method.Statements.Add(localvar_lResult.AsExpression.AsReturnStatement);
  exit l_method;
end;

method JavaRodlCodeGen.GenerateServiceConstructors(aLibrary: RodlLibrary; aEntity: RodlService; aService: CGClassTypeDefinition);
begin
  {$REGION .ctor}
  var l_Setpackage := new CGMethodCallExpression(GenerateROSDKType("TypeManager").AsNamedIdentifierExpression,"setPackage",[targetNamespace.AsLiteralExpression.AsCallParameter].ToList);
  aService.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [
        new CGConstructorCallStatement(CGInheritedExpression.Inherited, new List<CGCallParameter>),
        l_Setpackage].ToList
      )
  );
  {$ENDREGION}

  var param_aMessage := new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference);
  var param_aClientChannel := new CGParameterDefinition("aClientChannel", GenerateROSDKType("ClientChannel").AsTypeReference);
  {$REGION .ctor(aMessage: Message; aClientChannel: ClientChannel)}
  aService.Members.Add(
    new CGConstructorDefinition(
      Parameters := [param_aMessage, param_aClientChannel].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [
            new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                        [param_aMessage.AsCallParameter, param_aClientChannel.AsCallParameter].ToList),
         l_Setpackage
        ].ToList
      )
  );
  {$ENDREGION}

  var param_aOverrideInterfaceName := new CGParameterDefinition("aOverrideInterfaceName", ResolveStdtypes(CGPredefinedTypeReference.String));
  {$REGION .ctor(aMessage: Message; aClientChannel: ClientChannel; aOverrideInterfaceName: String)}
  aService.Members.Add(
    new CGConstructorDefinition(
     Parameters := [param_aMessage, param_aClientChannel,param_aOverrideInterfaceName].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                  [param_aMessage.AsCallParameter,
                                                   param_aClientChannel.AsCallParameter,
                                                   param_aOverrideInterfaceName.AsCallParameter].ToList),
                    l_Setpackage
                    ].ToList
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aSchema: URI)}
  var param_aSchema := new CGParameterDefinition("aSchema", "java.net.URI".AsTypeReference);
  aService.Members.Add(
    new CGConstructorDefinition(
      Parameters := [param_aSchema].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                  [param_aSchema.AsCallParameter].ToList),
                    l_Setpackage].ToList
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aSchema: URI; aOverrideInterfaceName: String)}
  param_aSchema := new CGParameterDefinition("aSchema", "java.net.URI".AsTypeReference);
  aService.Members.Add(
    new CGConstructorDefinition(
     Parameters:=[param_aSchema, param_aOverrideInterfaceName].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                  [param_aSchema.AsCallParameter, param_aOverrideInterfaceName.AsCallParameter].ToList),
                    l_Setpackage
                  ].ToList
      )
  );
  {$ENDREGION}

  {$REGION method _getInterfaceName: String; override;}
  aService.Members.Add(
    new CGMethodDefinition("_getInterfaceName",
                          [SafeIdentifier(aEntity.Name).AsLiteralExpression.AsReturnStatement],
                          ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                          Virtuality := CGMemberVirtualityKind.Override,
                          Visibility := CGMemberVisibilityKind.Public)
  );
  {$ENDREGION}
end;

method JavaRodlCodeGen.GenerateOperationAttribute(aLibrary: RodlLibrary; aEntity: RodlOperation; Statements: List<CGStatement>);
begin
  var ld := Operation_GetAttributes(aLibrary, aEntity);
  if ld.Count > 0 then begin
    var lhashmaptype := new CGNamedTypeReference("java.util.HashMap",GenericArguments := [ResolveStdtypes(CGPredefinedTypeReference.String),ResolveStdtypes(CGPredefinedTypeReference.String)].ToList);
    var localvar_lAttributesMap := new CGVariableDeclarationStatement("lAttributesMap",lhashmaptype,new CGNewInstanceExpression(lhashmaptype));
    Statements.Add(localvar_lAttributesMap);
    for l_key: String in ld.Keys do begin
      Statements.Add(
        new CGMethodCallExpression(localvar_lAttributesMap.AsExpression, "put",
                                  [EscapeString(l_key.ToLowerInvariant).AsLiteralExpression.AsCallParameter,
                                  EscapeString(ld[l_key]).AsLiteralExpression.AsCallParameter].ToList));
    end;
    Statements.Add(new CGMethodCallExpression(new CGLocalVariableAccessExpression("_localMessage"),
                                              "setupAttributes",
                                              [localvar_lAttributesMap.AsCallParameter].ToList));
  end;
end;

method JavaRodlCodeGen.GetGlobalName(aLibrary: RodlLibrary): String;
begin
  exit "Defines_" + targetNamespace.Replace(".", "_");
end;

method JavaRodlCodeGen.GetIncludesNamespace(aLibrary: RodlLibrary): String;
begin
  if assigned(aLibrary.Includes) then exit aLibrary.Includes.JavaModule;
  exit inherited GetIncludesNamespace(aLibrary);
end;

method JavaRodlCodeGen.GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>;
begin
  var l_dict := new Dictionary<String,String>;
  var lunit := DoGenerateInterfaceFile(aLibrary, aTargetNamespace);
  for k in lunit.Types.OrderBy(b->b.Name) do begin
     l_dict.Add(Path.ChangeExtension(k.Name, Generator.defaultFileExtension), (Generator.GenerateUnitForSingleType(k) &unit(lunit)));
  end;
  exit l_dict;
end;

method JavaRodlCodeGen.GenerateGetProperty(aParent: CGExpression; Name: String): CGExpression;
begin
  exit iif(isCooperMode,
          new CGFieldAccessExpression(aParent, Name),
          new CGMethodCallExpression(aParent, $"get{Name}"));
end;

method JavaRodlCodeGen.GenerateSetProperty(aParent: CGExpression; Name: String; aValue:CGExpression): CGStatement;
begin
  exit iif(isCooperMode,
          new CGAssignmentStatement(new CGFieldAccessExpression(aParent, Name), aValue),
          new CGMethodCallExpression(aParent, $"set{Name}",[aValue.AsCallParameter].ToList));
end;

method JavaRodlCodeGen.GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var lenum := new CGEnumTypeDefinition(SafeIdentifier(aEntity.Name),
                                        Visibility := CGTypeVisibilityKind.Public);
  if isCooperMode then lenum.BaseType := new CGNamedTypeReference("Enum");
  lenum.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(lenum);
  for enummember: RodlEnumValue in aEntity.Items do begin
    var lname := GenerateEnumMemberName(aLibrary, aEntity, enummember);
    var lenummember := new CGEnumValueDefinition(lname);
    lenummember.XmlDocumentation := GenerateDocumentation(enummember);
    lenum.Members.Add(lenummember);
  end;
end;

method JavaRodlCodeGen.AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin

  var ltype : CGTypeDefinition;

  if isCooperMode then
    ltype := new CGClassTypeDefinition(GetGlobalName(aLibrary), Visibility:= CGTypeVisibilityKind.Public)
  else
    ltype := new CGInterfaceTypeDefinition(GetGlobalName(aLibrary), Visibility:= CGTypeVisibilityKind.Public);

  aFile.Types.Add(ltype);

  ltype.Members.Add(new CGFieldDefinition("TARGET_NAMESPACE", ResolveStdtypes(CGPredefinedTypeReference.String),
                    Constant := true,
                    &Static := true,
                    Visibility := CGMemberVisibilityKind.Public,
                    Initializer := if assigned(targetNamespace) then targetNamespace.AsLiteralExpression));

  for lentity: RodlEntity in aLibrary.EventSinks.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(lentity) then Continue;
    var lName := lentity.Name;
    ltype.Members.Add(new CGFieldDefinition(String.Format("EID_{0}",[lName]), ResolveStdtypes(CGPredefinedTypeReference.String),
                                          Constant := true,
                                          &Static := true,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Initializer := lName.AsLiteralExpression));
  end;
end;

method JavaRodlCodeGen.GenerateROSDKType(aName: String): String;
begin
  if addROSDKPrefix then
    exit "com.remobjects.sdk."+aName
  else
    exit aName;
end;

method JavaRodlCodeGen.isPrimitive(aType: String): Boolean;
begin
  var l_result := not CodeGenTypes.ContainsKey(aType.ToLowerInvariant);
  if l_result then begin
    var k := CodeGenTypes[aType.ToLowerInvariant];
    l_result := (k is CGPredefinedTypeReference) and
              (CodeGenTypes[aType.ToLowerInvariant].Nullability <> CGTypeNullabilityKind.NullableNotUnwrapped);
  end;
  exit l_result;
end;

method JavaRodlCodeGen.ConvertToSimple(aElementType_str: String; aElementType: CGTypeReference; aValue: CGExpression): CGStatement;
begin
  if not isCooperMode then begin
    case aElementType_str of
      "integer": aElementType := CGPredefinedTypeReference.Int32.NullableNotUnwrapped;
      "double":  aElementType := CGPredefinedTypeReference.Double.NullableNotUnwrapped;
      "int64":   aElementType := CGPredefinedTypeReference.Int64.NullableNotUnwrapped;
      "boolean": aElementType := CGPredefinedTypeReference.Boolean.NullableNotUnwrapped;
    end;
  end;
  var l_result: CGExpression := new CGTypeCastExpression(
                    aValue,
                    aElementType,
                    ThrowsException := true
                  );
  if not isCooperMode then begin
    case aElementType_str of
      "integer": l_result := new CGMethodCallExpression(l_result, "intValue");
      "double":  l_result := new CGMethodCallExpression(l_result, "doubleValue");
      "int64":   l_result := new CGMethodCallExpression(l_result, "longValue");
      "boolean": l_result := new CGMethodCallExpression(l_result, "booleanValue");
    end;
  end;
  exit l_result.AsReturnStatement;
end;

method JavaRodlCodeGen.IsSimpleType(aElementType_str: String): Boolean;
begin
  exit aElementType_str.ToLowerInvariant() in ["integer", "double", "int64", "boolean"];
end;

method JavaRodlCodeGen.ConvertToObject(aElementType_str: String; aElementType: CGTypeReference): CGTypeReference;
begin
  if not isCooperMode and IsSimpleType(aElementType_str) then
    aElementType := aElementType.NullableNotUnwrapped;
  exit aElementType;
end;

end.