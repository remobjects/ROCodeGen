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
    method GetReaderStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: String := "aMessage"): CGStatement;
    method GetReaderExpression(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: String := "aMessage"): CGExpression;
    method GetWriterStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; useGetter: Boolean := True; variableName: String := "aMessage"): CGStatement;
    method GetWriterStatement_DefaultValues(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: String := "aMessage"): CGStatement;

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
    property addROSDKPrefix: Boolean := True;
    property isCooperMode: Boolean := True;
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
  Result := new CGMethodDefinition("writeToMessage",
                        Parameters := [new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeReference.String)),
                                       new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference)].ToList,
                                        Virtuality := CGMemberVirtualityKind.Override,
                                        Visibility := CGMemberVisibilityKind.Public);

  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(GenerateGetProperty("aMessage".AsNamedIdentifierExpression,"UseStrictFieldOrderForStructs"),
                                                        lIfRecordStrictOrder_True,
                                                        lIfRecordStrictOrder_False
  );
  Result.Statements.Add(lIfRecordStrictOrder);

  if assigned(aEntity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
      new CGMethodCallExpression(CGInheritedExpression.Inherited, "writeToMessage",
                                  ["aName".AsNamedIdentifierExpression.AsCallParameter,
                                  "aMessage".AsNamedIdentifierExpression.AsCallParameter].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := aEntity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for field: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(field.Name.ToLowerInvariant, field);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for field: RodlField in aEntity.Items do
    if not lSortedFields.ContainsKey(field.Name.ToLowerInvariant) then begin
      lSortedFields.Add(field.Name.ToLowerInvariant, field);
      lIfRecordStrictOrder_True.Statements.Add(
        iif(useDefaultValues, GetWriterStatement_DefaultValues(aLibrary, field),GetWriterStatement(aLibrary, field))
      );
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(
      iif(useDefaultValues, GetWriterStatement_DefaultValues(aLibrary, lSortedFields.Item[lvalue]),GetWriterStatement(aLibrary, lSortedFields.Item[lvalue]))
    );
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
  lstruct.Comment := GenerateDocumentation(aEntity);
  aFile.Types.Add(lstruct);
  {$REGION private class _attributes: HashMap<String, String>;}
  if (aEntity.CustomAttributes.Count > 0) then
    lstruct.Members.Add(HandleAtributes_private(aLibrary,aEntity));
  {$ENDREGION}
  {$REGION protected class var s_%fldname%: %fldtype%}
  for lm :RodlTypedEntity in aEntity.Items do begin
    lstruct.Members.Add(
                        new CGFieldDefinition("s_"+lm.Name, ResolveDataTypeToTypeRef(aLibrary,lm.DataType),
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
      lsetDefaultValues.Parameters.Add(
        new CGParameterDefinition("p_"+lm.Name, ResolveDataTypeToTypeRef(aLibrary,lm.DataType)));
      lsetDefaultValues.Statements.Add(
          new CGAssignmentStatement(
                ("s_"+lm.Name).AsNamedIdentifierExpression,
                ("p_"+lm.Name).AsNamedIdentifierExpression
        )
      );
    end;
    {$ENDREGION}
    {$REGION private %f_fldname%: %fldtype% + public getter/setter}
    for lm :RodlTypedEntity in aEntity.Items do begin
      var ltype := ResolveDataTypeToTypeRef(aLibrary,lm.DataType);
      var f_name :='f_'+lm.Name;
      var s_name :='s_'+lm.Name;
      lstruct.Members.Add(new CGFieldDefinition(f_name,
                                                  ltype,
                                                  Visibility := CGMemberVisibilityKind.Private));
      if not isCooperMode then begin
        lstruct.Members.Add(new CGMethodDefinition('set'+lm.Name,
                                                    [new CGAssignmentStatement(f_name.AsNamedIdentifierExpression,'aValue'.AsNamedIdentifierExpression)],
                                                    Parameters := [new CGParameterDefinition('aValue',ltype)].ToList,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    Comment:= GenerateDocumentation(lm)));
        lstruct.Members.Add(new CGMethodDefinition('get'+lm.Name,
                                                    [new CGIfThenElseStatement(new CGBinaryOperatorExpression(f_name.AsNamedIdentifierExpression, CGNilExpression.Nil, CGBinaryOperatorKind.NotEquals),
                                                      f_name.AsNamedIdentifierExpression.AsReturnStatement,
                                                      s_name.AsNamedIdentifierExpression.AsReturnStatement)],
                                                    ReturnType := ltype,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    Comment:= GenerateDocumentation(lm)));
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
        var f_name :='f_'+lm.Name;
        var s_name :='s_'+lm.Name;
        var st1: CGStatement :=new CGIfThenElseStatement(new CGBinaryOperatorExpression(f_name.AsNamedIdentifierExpression, CGNilExpression.Nil, CGBinaryOperatorKind.NotEquals),
                                                          f_name.AsNamedIdentifierExpression.AsReturnStatement,
                                                          s_name.AsNamedIdentifierExpression.AsReturnStatement);
        //var st2: CGStatement :=new CGAssignmentStatement(f_name.AsNamedIdentifierExpression,CGPropertyDefinition.MAGIC_VALUE_PARAMETER_NAME.AsNamedIdentifierExpression);
        lstruct.Members.Add(new CGPropertyDefinition(lm.Name,
                            ResolveDataTypeToTypeRef(aLibrary,lm.DataType),
                            [st1].ToList,
                            SetExpression := f_name.AsNamedIdentifierExpression,
                            Visibility := CGMemberVisibilityKind.Public,
                            Comment := GenerateDocumentation(lm)));
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
  lArray.Comment := GenerateDocumentation(aEntity);
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
  // Actually this should be a static variable. Unfortunately it seems that atm the codegen doesn't allow to define static constructors
  if lIsEnum then begin
    // Cache field
    lArray.Members.Add(new CGFieldDefinition('fEnumValues', new CGArrayTypeReference(lElementType)));

    // Cache initializer
    lArray.Members.Add(
      new CGMethodDefinition('initEnumValues',
                           [ new CGAssignmentStatement(new CGFieldAccessExpression(CGSelfExpression.Self, 'fEnumValues'),
                                                      new CGMethodCallExpression(lElementType.AsExpression(), 'values')) ],
                            Visibility := CGMemberVisibilityKind.Private));
  end;
  {$ENDREGION}

  {$REGION Optional initializer call}
  var lInitializerCall: CGStatement := iif(lIsEnum, new CGMethodCallExpression(CGSelfExpression.Self, 'initEnumValues'), nil);
  {$ENDREGION}

  {$REGION .ctor}
  var lStatements1 := new List<CGStatement>();
  lStatements1.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, new List<CGCallParameter>()));
  if assigned(lInitializerCall) then begin
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
  var lStatements2 := new List<CGStatement>();
  lStatements2.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [ "aCapacity".AsNamedIdentifierExpression().AsCallParameter() ].ToList()));
  if assigned(lInitializerCall) then begin
    lStatements2.Add(lInitializerCall);
  end;

  lArray.Members.Add(
    new CGConstructorDefinition(
      Parameters := [ new CGParameterDefinition("aCapacity", ResolveStdtypes(CGPredefinedTypeReference.Int32)) ].ToList(),
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lStatements2
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aCollection: Collection)}
  var lStatements3 := new List<CGStatement>();
  lStatements3.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, ["aCollection".AsNamedIdentifierExpression().AsCallParameter() ].ToList()));
  if assigned(lInitializerCall) then begin
    lStatements3.Add(lInitializerCall);
  end;

  lArray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Parameters := [ new CGParameterDefinition("aCollection", "java.util.Collection".AsTypeReference()) ].ToList(),
      Statements := lStatements3
      )
  );
  {$ENDREGION}

  {$REGION .ctor(anArray: array of Object)}
  var lStatements4 := new List<CGStatement>();
  lStatements4.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, [ "anArray".AsNamedIdentifierExpression().AsCallParameter() ].ToList()));
  if assigned(lInitializerCall) then begin
    lStatements4.Add(lInitializerCall);
  end;

  lArray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Parameters := [ new CGParameterDefinition("anArray", new CGArrayTypeReference(ResolveStdtypes(CGPredefinedTypeReference.Object))) ].ToList(),
      Statements:= lStatements4
      )
  );
  {$ENDREGION}

  {$REGION method add: %ARRAY_TYPE%;}
  if isComplex(aLibrary,aEntity.ElementType) then
    lArray.Members.Add(
      new CGMethodDefinition("add",
        Visibility := CGMemberVisibilityKind.Public,
        ReturnType := lElementType,
        Statements:=
          [new CGVariableDeclarationStatement('lresult',lElementType,new CGNewInstanceExpression(lElementType)),
           new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", ["lresult".AsNamedIdentifierExpression.AsCallParameter].ToList),
           "lresult".AsNamedIdentifierExpression.AsReturnStatement
          ].ToList
        )
    );

  {$ENDREGION}

  {$REGION public class method getAttributeValue(aName: String): String; override;}
  if (aEntity.CustomAttributes.Count > 0) then
    lArray.Members.Add(HandleAtributes_public(aLibrary,aEntity));
  {$ENDREGION}

  {$REGION method addItem(anItem: %ARRAY_TYPE%)}
  lArray.Members.Add(
    new CGMethodDefinition("addItem",
                           [new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", ["anItem".AsNamedIdentifierExpression.AsCallParameter].ToList)],
                           Visibility := CGMemberVisibilityKind.Public,
                           Parameters := [new CGParameterDefinition("anItem", lElementType)].ToList));
  {$ENDREGION}

  {$REGION method insertItem(anItem: %ARRAY_TYPE%; anIndex: Integer);}
  lArray.Members.Add(
    new CGMethodDefinition("insertItem",
                           [new CGMethodCallExpression(CGInheritedExpression.Inherited,"insertItem",
                                                      ["anItem".AsNamedIdentifierExpression.AsCallParameter,
                                                      "anIndex".AsNamedIdentifierExpression.AsCallParameter].ToList)],
                            Parameters := [new CGParameterDefinition("anItem", lElementType),
                                           new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32))].ToList,
                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}

  {$REGION method replaceItemAtIndex(anItem: %ARRAY_TYPE%; anIndex: Integer);}
  lArray.Members.Add(
    new CGMethodDefinition("replaceItemAtIndex",
                          [new CGMethodCallExpression(CGInheritedExpression.Inherited, "replaceItemAtIndex",
                                                  ["anItem".AsNamedIdentifierExpression.AsCallParameter,
                                                  "anIndex".AsNamedIdentifierExpression.AsCallParameter].ToList)],
                          Parameters := [new CGParameterDefinition("anItem", lElementType),
                                         new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32))].ToList,
                          Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method getItemAtIndex(anIndex: Integer): %ARRAY_TYPE%; override;}
  lArray.Members.Add(
    new CGMethodDefinition("getItemAtIndex",
                            [
                              CGStatement(
                                new CGTypeCastExpression(
                                  new CGMethodCallExpression(CGInheritedExpression.Inherited, '__getItemAtIndex', [ 'anIndex'.AsNamedIdentifierExpression().AsCallParameter() ].ToList()),
                                  lElementType,
                                  ThrowsException := true
                                ).AsReturnStatement()
                              )
                            ].ToList(),
                            Parameters := [ new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32)) ].ToList(),
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

  var l_arg0 := new CGNilExpression().AsCallParameter;
  var l_arg1_exp: CGExpression := new CGMethodCallExpression(CGSelfExpression.Self,"getItemAtIndex",["anIndex".AsNamedIdentifierExpression.AsCallParameter].ToList);
  if lIsEnum then begin
    l_arg1_exp := new CGMethodCallExpression(l_arg1_exp,"ordinal");
  end;
  var l_arg1 := l_arg1_exp.AsCallParameter;

  lArray.Members.Add(
    new CGMethodDefinition("writeItemToMessage",
                           [new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression,"write" +  l_methodName,  [l_arg0,l_arg1].ToList)],
                            Parameters := [new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference),
                                           new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32))].ToList,
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
            new CGFieldAccessExpression(CGSelfExpression.Self, 'fEnumValues'),
            [ CGExpression(new CGMethodCallExpression('aMessage'.AsNamedIdentifierExpression(), 'readEnum', lArgList)) ].ToList()
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
        [ new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression(), "read" +  l_methodName, lArgList).AsCallParameter() ].ToList()
      )
    );
  end;

  lArray.Members.Add(
    new CGMethodDefinition(
      "readItemFromMessage",
      lMethodStatements,
      Parameters := [new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference),
                   new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeReference.Int32))].ToList,
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
  lexception.Comment := GenerateDocumentation(aEntity);
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
      var f_name :='f_'+lm.Name;
      lexception.Members.Add(new CGFieldDefinition(f_name,
                                                   ltype,
                                                   Visibility := CGMemberVisibilityKind.Private));
      if not isCooperMode then begin
        lexception.Members.Add(new CGMethodDefinition('set'+lm.Name,
                                      [new CGAssignmentStatement(f_name.AsNamedIdentifierExpression,'aValue'.AsNamedIdentifierExpression)],
                                      Parameters := [new CGParameterDefinition('aValue',ltype)].ToList,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      Comment:= GenerateDocumentation(lm)));
        lexception.Members.Add(new CGMethodDefinition('get'+lm.Name,
                                      [f_name.AsNamedIdentifierExpression.AsReturnStatement],
                                      ReturnType := ltype,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      Comment:= GenerateDocumentation(lm)));
      end;
    end;
  {$ENDREGION}
  end;

  {$REGION .ctor(aExceptionMessage: String)}
  lexception.Members.Add(
                        new CGConstructorDefinition(
                                                    Parameters := [new CGParameterDefinition("anExceptionMessage", ResolveStdtypes(CGPredefinedTypeReference.String))].ToList,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    Statements := [CGStatement(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                                                                              ["anExceptionMessage".AsNamedIdentifierExpression.AsCallParameter].ToList))].ToList
                                                    ));
  {$ENDREGION}

  {$REGION .ctor(aExceptionMessage: String; aFromServer: Boolean)}
  lexception.Members.Add(
                        new CGConstructorDefinition(
                                                    Parameters :=[new CGParameterDefinition("anExceptionMessage", ResolveStdtypes(CGPredefinedTypeReference.String)),
                                                                  new CGParameterDefinition("aFromServer", ResolveStdtypes(CGPredefinedTypeReference.Boolean))].ToList,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    Statements:= [CGStatement(
                                                                        new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                                        ["anExceptionMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                                        "aFromServer".AsNamedIdentifierExpression.AsCallParameter].ToList))].ToList
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
      Comment := GenerateDocumentation(lm)));
  end;
  {$ENDREGION}
end;

method JavaRodlCodeGen.GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  {$REGION I%SERVICE_NAME%}
  var lIService := new CGInterfaceTypeDefinition(SafeIdentifier("I"+aEntity.Name),
                                                 Visibility := CGTypeVisibilityKind.Public);
  lIService.Comment := GenerateDocumentation(aEntity);
  aFile.Types.Add(lIService);
  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
    var m := GenerateServiceProxyMethodDeclaration(aLibrary, lop);
    m.Comment := GenerateDocumentation(lop, true);
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
  var i_name := 'I'+aEntity.Name;
  var i_adaptername := i_name+'_Adapter';
  var lIEvent := new CGInterfaceTypeDefinition(i_name,GenerateROSDKType("IEvents").AsTypeReference,
                            Visibility := CGTypeVisibilityKind.Public);
  lIEvent.Comment := GenerateDocumentation(aEntity);
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
        var f_name :='f_'+lm.Name;
        lOperation.Members.Add(new CGFieldDefinition(f_name,
                                                     ltype,
                                                     Visibility := CGMemberVisibilityKind.Private));
        lOperation.Members.Add(new CGMethodDefinition('set'+lm.Name,
                                                      [new CGAssignmentStatement(f_name.AsNamedIdentifierExpression,'aValue'.AsNamedIdentifierExpression)],
                                                      Parameters := [new CGParameterDefinition('aValue',ltype)].ToList,
                                                      Visibility := CGMemberVisibilityKind.Public,
                                                      Comment:= GenerateDocumentation(lm)));
        lOperation.Members.Add(new CGMethodDefinition('get'+lm.Name,
                                                      [f_name.AsNamedIdentifierExpression.AsReturnStatement],
                                                      ReturnType := ltype,
                                                      Visibility := CGMemberVisibilityKind.Public,
                                                      Comment:= GenerateDocumentation(lm)));
       end;
    end;

    var lop_method := new CGConstructorDefinition(
                              Parameters:=[new CGParameterDefinition("aBuffer", GenerateROSDKType("Message").AsTypeReference)].ToList,
                              Visibility := CGMemberVisibilityKind.Public);
    lOperation.Members.Add(lop_method);

    for lm :RodlParameter in lop.Items do begin
      if isCooperMode then begin
        lOperation.Members.Add(new CGPropertyDefinition(
                                                        lm.Name,
                                                        ResolveDataTypeToTypeRef(aLibrary,lm.DataType),
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        Comment:= GenerateDocumentation(lm)));
      end;
      lop_method.Statements.Add(GetReaderStatement(aLibrary,lm,"aBuffer"));
    end;

    aFile.Types.Add(lOperation);
    {$ENDREGION}
    lIEvent.Members.Add(new CGMethodDefinition(SafeIdentifier(lop.Name),
                                               Parameters := [new CGParameterDefinition("aEvent", lOperation.Name.AsTypeReference)].ToList,
                                               Visibility := CGMemberVisibilityKind.Public,
                                               Comment := GenerateDocumentation(lop,false)
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

method JavaRodlCodeGen.GetWriterStatement_DefaultValues(aLibrary: RodlLibrary; aEntity: RodlTypedEntity;variableName: String): CGStatement;
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
//  var s_entityname_ID := ("s_"+lentityname).AsNamedIdentifierExpression;
  var l_if_conditional := new CGAssignedExpression(entityname_ID);
  var l_varname := variableName.AsNamedIdentifierExpression;
  var l_write := "write" +  l_methodName;
  var l_arg0 := lentityname.AsLiteralExpression.AsCallParameter;
  var l_arg1 := entityname_ID.AsCallParameter;
  if l_isStandard or l_isStruct or l_isArray then begin
    exit new CGMethodCallExpression(l_varname,l_write, [l_arg0,l_arg1].ToList);
  end
  else if l_isEnum then begin
    exit new CGIfThenElseStatement(
      l_if_conditional,
      new CGMethodCallExpression(l_varname,
                                 l_write,
                                 [l_arg0,
                                 new CGMethodCallExpression(entityname_ID,"ordinal").AsCallParameter].ToList),
      new CGBeginEndBlockStatement([CGStatement(
          new CGMethodCallExpression(l_varname,l_write, [l_arg0,new CGIntegerLiteralExpression(0).AsCallParameter].ToList)
                 { new CGIfThenElseStatement(
                       new CGAssignedExpression(s_entityname_ID),
                       new CGMethodCallExpression(l_varname,l_write, [l_arg0,new CGMethodCallExpression(s_entityname_ID,"ordinal").AsCallParameter].ToList),
                       new CGMethodCallExpression(l_varname,l_write, [l_arg0,new CGIntegerLiteralExpression(0).AsCallParameter].ToList)
                    )}
               )].ToList)
        );
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;
end;

method JavaRodlCodeGen.ReadFromMessage_Method(aLibrary: RodlLibrary; aEntity: RodlStructEntity): CGMethodDefinition;
begin
  Result := new CGMethodDefinition("readFromMessage",
                        Parameters := [new CGParameterDefinition("aName",   ResolveStdtypes(CGPredefinedTypeReference.String)),
                                       new CGParameterDefinition("aMessage",GenerateROSDKType("Message").AsTypeReference)].ToList,
                        Virtuality := CGMemberVirtualityKind.Override,
                        Visibility := CGMemberVisibilityKind.Public);
  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(GenerateGetProperty("aMessage".AsNamedIdentifierExpression,"UseStrictFieldOrderForStructs"),
                                                        lIfRecordStrictOrder_True,
                                                        lIfRecordStrictOrder_False
  );
  Result.Statements.Add(lIfRecordStrictOrder);

  if assigned(aEntity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
                      new CGMethodCallExpression(CGInheritedExpression.Inherited,"readFromMessage",
                                                ["aName".AsNamedIdentifierExpression.AsCallParameter,
                                                 "aMessage".AsNamedIdentifierExpression.AsCallParameter].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := aEntity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for field: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(field.Name.ToLowerInvariant, field);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for field: RodlField in aEntity.Items do
    if not lSortedFields.ContainsKey(field.Name.ToLowerInvariant) then begin
      lSortedFields.Add(field.Name.ToLowerInvariant, field);
      lIfRecordStrictOrder_True.Statements.Add(GetReaderStatement(aLibrary, field));
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(GetReaderStatement(aLibrary, lSortedFields.Item[lvalue]));

end;

method JavaRodlCodeGen.GetReaderStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: String): CGStatement;
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
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (aEntity.CustomAttributes.Count = 0) then exit;
  Result := new CGMethodDefinition("getAttributeValue",
                                  Parameters:=[new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeReference.String))].ToList,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeReference.String),
                                  &Static := True,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  Visibility := CGMemberVisibilityKind.Public);

  var l_attributes := "_attributes".AsNamedIdentifierExpression;
  var l_if_true := new CGBeginEndBlockStatement();
  var l_if := new CGIfThenElseStatement(
      new CGBinaryOperatorExpression(l_attributes,new CGNilExpression(),CGBinaryOperatorKind.Equals),
      l_if_true);
  Result.Statements.Add(l_if);
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
  Result.Statements.Add(new CGMethodCallExpression(l_attributes,"get", [new CGMethodCallExpression("aName".AsNamedIdentifierExpression,"toLowerCase").AsCallParameter].ToList).AsReturnStatement);
end;

method JavaRodlCodeGen.GetWriterStatement(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; useGetter: Boolean := True; variableName: String := "aMessage"): CGStatement;
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

  var variableName_ID := variableName.AsNamedIdentifierExpression;
  var writer_name := "write" +  l_methodName;
  var entity_ID := iif(useGetter,
                       GenerateGetProperty(CGSelfExpression.Self,lentityname),
                       lentityname.AsNamedIdentifierExpression);
  var l_arg0 := lentityname.AsLiteralExpression.AsCallParameter;
  var l_arg1 := entity_ID.AsCallParameter;
  if l_isStandard or l_isStruct or l_isArray then begin
    exit new CGMethodCallExpression(variableName_ID,writer_name,[l_arg0,l_arg1].ToList);
  end
  else if l_isEnum then begin
    exit new CGMethodCallExpression(variableName_ID,writer_name,[l_arg0, new CGMethodCallExpression(entity_ID,"ordinal").AsCallParameter].ToList);
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;
end;

method JavaRodlCodeGen.GetReaderExpression(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; variableName: String := "aMessage"): CGExpression;
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

  var varname_ID := variableName.AsNamedIdentifierExpression;
  var reader_name := "read" +  l_methodName;
//  var l_reader := new CGIdentifierExpression("read" +  l_methodName, variableName);
  var l_arg0 : CGCallParameter := aEntity.Name.AsLiteralExpression.AsCallParameter;
  var l_type := ResolveDataTypeToTypeRef(aLibrary,aEntity.DataType);


  if l_isStandard then begin
    var temp := new CGMethodCallExpression(varname_ID,reader_name,[l_arg0].ToList);
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
        new CGMethodCallExpression(varname_ID,reader_name,[l_arg0,l_arg1].ToList),
        l_type,
        ThrowsException:=true);
  end
  else if l_isEnum then begin
    exit new CGArrayElementAccessExpression(new CGMethodCallExpression(l_type.AsExpression, "values"),
                                            [CGExpression(new CGMethodCallExpression(varname_ID,reader_name,[l_arg0].ToList))].ToList
      );
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;

end;

method JavaRodlCodeGen.GenerateServiceProxyMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceProxyMethodDeclaration(aLibrary,aEntity);
  var l_in:= new List<RodlParameter>;
  var l_out:= new List<RodlParameter>;
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_in.Add(lp);
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_out.Add(lp);
  end;

  var llocalmessage := "_localMessage".AsNamedIdentifierExpression;
  Result.Statements.Add(new CGVariableDeclarationStatement(
                                                  "_localMessage",
                                                  GenerateROSDKType("Message").AsTypeReference,
                                                  new CGTypeCastExpression(
                                                                    new CGMethodCallExpression(
                                                                              GenerateGetProperty(CGSelfExpression.Self, "ProxyMessage"),
                                                                              "clone"),
                                                                    GenerateROSDKType("Message").AsTypeReference,
                                                                    ThrowsException:=True)));
  GenerateOperationAttribute(aLibrary,aEntity,Result.Statements);
  Result.Statements.Add(
    new CGMethodCallExpression(llocalmessage,"initializeAsRequestMessage",
                                [aEntity.OwnerLibrary.Name.AsLiteralExpression.AsCallParameter,
                                new CGMethodCallExpression(CGSelfExpression.Self, "_getActiveInterfaceName").AsCallParameter,
                                aEntity.Name.AsLiteralExpression.AsCallParameter].ToList
      ));
  var ltry := new List<CGStatement>;
  var lfinally := new List<CGStatement>;


  for lp: RodlParameter in l_in do
    ltry.Add(GetWriterStatement(aLibrary,lp,false, llocalmessage.Name));
  ltry.Add(new CGMethodCallExpression(llocalmessage, "finalizeMessage"));
  ltry.Add(new CGMethodCallExpression(GenerateGetProperty(CGSelfExpression.Self, "ProxyClientChannel"),
                                      "dispatch",
                                      [llocalmessage.AsCallParameter].ToList));

  if assigned(aEntity.Result) then begin
    ltry.Add(new CGVariableDeclarationStatement("lResult",Result.ReturnType,GetReaderExpression(aLibrary,aEntity.Result,llocalmessage.Name)));
  end;
  for lp: RodlParameter in l_out do
    ltry.Add(GenerateSetProperty(("_"+lp.Name).AsNamedIdentifierExpression,
                                 "Value",
                                 GetReaderExpression(aLibrary,lp,llocalmessage.Name)                            ));
  if assigned(aEntity.Result) then
    ltry.Add("lResult".AsNamedIdentifierExpression.AsReturnStatement);
  lfinally.Add(GenerateSetProperty(GenerateGetProperty(CGSelfExpression.Self,"ProxyMessage"),
                                   "ClientID",
                                   GenerateGetProperty(llocalmessage,"ClientID")));
  lfinally.Add(new CGMethodCallExpression(llocalmessage, "clear"));
  Result.Statements.Add(new CGTryFinallyCatchStatement(ltry, &FinallyStatements:= lfinally as not nullable));
end;

method JavaRodlCodeGen.GenerateServiceProxyMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition(SafeIdentifier(aEntity.Name),
                                  Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(aLibrary, lp.DataType)));
  end;
  if assigned(aEntity.Result) then Result.ReturnType := ResolveDataTypeToTypeRef(aLibrary, aEntity.Result.DataType);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition("_"+lp.Name, new CGNamedTypeReference(GenerateROSDKType("ReferenceType"), GenericArguments:=[ResolveDataTypeToTypeRef(aLibrary, lp.DataType)].ToList)));
  end;
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyBeginMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition("begin" + PascalCase(aEntity.Name),
                                  ReturnType := GenerateROSDKType("AsyncRequest").AsTypeReference,
                                  Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(aLibrary, lp.DataType)));
  end;
  result.Parameters.Add(new CGParameterDefinition("start", ResolveStdtypes(CGPredefinedTypeReference.Boolean)));
  result.Parameters.Add(new CGParameterDefinition("callback", GenerateROSDKType("AsyncRequest.IAsyncRequestCallback").AsTypeReference));
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyEndMethodDeclaration(aLibrary: RodlLibrary; aEntity: RodlOperation;&locked:Boolean): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition("end" + PascalCase(aEntity.Name),
      Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, new CGNamedTypeReference(GenerateROSDKType("ReferenceType"), GenericArguments :=[ResolveDataTypeToTypeRef(aLibrary, lp.DataType)].ToList)));
  end;
  if assigned(aEntity.Result) then
    result.ReturnType := ResolveDataTypeToTypeRef(aLibrary, aEntity.Result.DataType);

  result.Parameters.Add(new CGParameterDefinition("aAsyncRequest", GenerateROSDKType("AsyncRequest").AsTypeReference));
  result.Locked := &locked;
end;


method JavaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(aLibrary,aEntity);
  var l_in:= new List<RodlParameter>;
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_in.Add(lp);
  end;

  var llocalmessage := "_localMessage".AsNamedIdentifierExpression;
  Result.Statements.Add(new CGVariableDeclarationStatement("_localMessage",
                                                           GenerateROSDKType("Message").AsTypeReference,
                                                           new CGTypeCastExpression(
                                                                              new CGMethodCallExpression(
                                                                                                    GenerateGetProperty(CGSelfExpression.Self,"ProxyMessage"),
                                                                                                    "clone"),
                                                                              GenerateROSDKType("Message").AsTypeReference,
                                                                              ThrowsException:=True)
                                                ));

  GenerateOperationAttribute(aLibrary,aEntity,Result.Statements);

  Result.Statements.Add(
    new CGMethodCallExpression(llocalmessage,"initializeAsRequestMessage",
                              [aEntity.OwnerLibrary.Name.AsLiteralExpression.AsCallParameter,
                              new CGMethodCallExpression(CGSelfExpression.Self, "_getActiveInterfaceName").AsCallParameter,
                              aEntity.Name.AsLiteralExpression.AsCallParameter].ToList
    ));

  for lp: RodlParameter in l_in do
    Result.Statements.Add(GetWriterStatement(aLibrary,lp,false,llocalmessage.Name));
  Result.Statements.Add(new CGMethodCallExpression(llocalmessage, "finalizeMessage"));
  Result.Statements.Add(new CGMethodCallExpression(GenerateGetProperty(CGSelfExpression.Self,"ProxyClientChannel"),
                                                   "asyncDispatch",
                                                   [llocalmessage.AsCallParameter,
                                                   new CGSelfExpression().AsCallParameter,
                                                   "start".AsNamedIdentifierExpression.AsCallParameter,
                                                   "callback".AsNamedIdentifierExpression.AsCallParameter].ToList).AsReturnStatement
  );
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyEndMethod(aLibrary: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyEndMethodDeclaration(aLibrary,aEntity, true);

  var l_out:= new List<RodlParameter>;
  for lp: RodlParameter in aEntity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_out.Add(lp);
  end;

  var llocalmessage := "_localMessage".AsNamedIdentifierExpression;
  Result.Statements.Add(new CGVariableDeclarationStatement("_localMessage",
                                                           GenerateROSDKType("Message").AsTypeReference,
                                                           GenerateGetProperty("aAsyncRequest".AsNamedIdentifierExpression,"ProcessMessage")));

  GenerateOperationAttribute(aLibrary,aEntity,Result.Statements);

  if assigned(aEntity.Result) then begin
    Result.Statements.Add(new CGVariableDeclarationStatement("lResult",Result.ReturnType,GetReaderExpression(aLibrary,aEntity.Result,llocalmessage.Name)));
  end;
  for lp: RodlParameter in l_out do
    Result.Statements.Add(GenerateSetProperty(lp.Name.AsNamedIdentifierExpression,
                                              "Value",
                                              GetReaderExpression(aLibrary,lp,llocalmessage.Name)));
  var mess := GenerateGetProperty(new CGSelfExpression,"ProxyMessage");
  Result.Statements.Add(GenerateSetProperty(mess,"ClientID",GenerateGetProperty(llocalmessage,"ClientID")));
  Result.Statements.Add(new CGMethodCallExpression(llocalmessage,"clear"));
  if assigned(aEntity.Result) then
    Result.Statements.Add("lResult".AsNamedIdentifierExpression.AsReturnStatement);
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

  {$REGION .ctor(aMessage: Message; aClientChannel: ClientChannel)}
  aService.Members.Add(
    new CGConstructorDefinition(
      Parameters := [new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference),
                     new CGParameterDefinition("aClientChannel", GenerateROSDKType("ClientChannel").AsTypeReference)].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [
            new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                        ["aMessage".AsNamedIdentifierExpression.AsCallParameter,
                                         "aClientChannel".AsNamedIdentifierExpression.AsCallParameter].ToList),
         l_Setpackage
        ].ToList
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aMessage: Message; aClientChannel: ClientChannel; aOverrideInterfaceName: String)}
  aService.Members.Add(
    new CGConstructorDefinition(
     Parameters := [new CGParameterDefinition("aMessage", GenerateROSDKType("Message").AsTypeReference),
                    new CGParameterDefinition("aClientChannel", GenerateROSDKType("ClientChannel").AsTypeReference),
                    new CGParameterDefinition("aOverrideInterfaceName", ResolveStdtypes(CGPredefinedTypeReference.String))].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                  ["aMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                   "aClientChannel".AsNamedIdentifierExpression.AsCallParameter,
                                                   "aOverrideInterfaceName".AsNamedIdentifierExpression.AsCallParameter].ToList),
                    l_Setpackage
                    ].ToList
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aSchema: URI)}
  aService.Members.Add(
    new CGConstructorDefinition(
      Parameters := [new CGParameterDefinition("aSchema", "java.net.URI".AsTypeReference)].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                  ["aSchema".AsNamedIdentifierExpression.AsCallParameter].ToList),
                    l_Setpackage].ToList
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aSchema: URI; aOverrideInterfaceName: String)}
  aService.Members.Add(
    new CGConstructorDefinition(
     Parameters:=[new CGParameterDefinition("aSchema", "java.net.URI".AsTypeReference),
                  new CGParameterDefinition("aOverrideInterfaceName", ResolveStdtypes(CGPredefinedTypeReference.String))].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                  ["aSchema".AsNamedIdentifierExpression.AsCallParameter,
                                                    "aOverrideInterfaceName".AsNamedIdentifierExpression.AsCallParameter].ToList),
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
    var l_attributes := "lAttributesMap".AsNamedIdentifierExpression;
    Statements.Add(new CGVariableDeclarationStatement("lAttributesMap",lhashmaptype,new CGNewInstanceExpression(lhashmaptype)));
    for l_key: String in ld.Keys do begin
      Statements.Add(
        new CGMethodCallExpression(l_attributes, "put",
                                  [EscapeString(l_key.ToLowerInvariant).AsLiteralExpression.AsCallParameter,
                                  EscapeString(ld[l_key]).AsLiteralExpression.AsCallParameter].ToList));
    end;
    Statements.Add(new CGMethodCallExpression("_localMessage".AsNamedIdentifierExpression,"setupAttributes",[l_attributes.AsCallParameter].ToList));
  end;
end;

method JavaRodlCodeGen.GetGlobalName(aLibrary: RodlLibrary): String;
begin
  exit 'Defines_' + targetNamespace.Replace('.', '_');
end;

method JavaRodlCodeGen.GetIncludesNamespace(aLibrary: RodlLibrary): String;
begin
  if assigned(aLibrary.Includes) then exit aLibrary.Includes.JavaModule;
  exit inherited GetIncludesNamespace(aLibrary);
end;

method JavaRodlCodeGen.GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>;
begin
  isCooperMode := False;
  result := new Dictionary<String,String>;
  var lunit := DoGenerateInterfaceFile(aLibrary, aTargetNamespace);
  //var lgn := GetGlobalName(aLibrary);
  for k in lunit.Types.OrderBy(b->b.Name) do begin
{    if (k is CGInterfaceTypeDefinition) and (CGInterfaceTypeDefinition(k).Name = lgn) then
      result.Add(Path.ChangeExtension('Defines', Generator.defaultFileExtension), (Generator.GenerateUnitForSingleType(k) &unit(lunit)))
    else
}      result.Add(Path.ChangeExtension(k.Name, Generator.defaultFileExtension), (Generator.GenerateUnitForSingleType(k) &unit(lunit)));
  end;
end;

method JavaRodlCodeGen.GenerateGetProperty(aParent: CGExpression; Name: String): CGExpression;
begin
  exit iif(isCooperMode,
          new CGFieldAccessExpression(aParent, Name),
          new CGMethodCallExpression(aParent, "get"+Name));
end;

method JavaRodlCodeGen.GenerateSetProperty(aParent: CGExpression; Name: String; aValue:CGExpression): CGStatement;
begin
  exit iif(isCooperMode,
          new CGAssignmentStatement(new CGFieldAccessExpression(aParent, Name), aValue),
          new CGMethodCallExpression(aParent, "set"+Name,[aValue.AsCallParameter].ToList));
end;

method JavaRodlCodeGen.GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var lenum := new CGEnumTypeDefinition(SafeIdentifier(aEntity.Name),
                                        Visibility := CGTypeVisibilityKind.Public,
                                        BaseType := new CGNamedTypeReference('Enum'));
  lenum.Comment := GenerateDocumentation(aEntity);
  aFile.Types.Add(lenum);
  for enummember: RodlEnumValue in aEntity.Items do begin
    var lname := GenerateEnumMemberName(aLibrary, aEntity, enummember);
    var lenummember := new CGEnumValueDefinition(lname);
    lenummember.Comment := GenerateDocumentation(enummember);
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
  result := not CodeGenTypes.ContainsKey(aType.ToLowerInvariant);
  if result then begin
    var k := CodeGenTypes[aType.ToLowerInvariant];
    result := (k is CGPredefinedTypeReference) and
              (CodeGenTypes[aType.ToLowerInvariant].Nullability <> CGTypeNullabilityKind.NullableNotUnwrapped);
  end;
end;

end.