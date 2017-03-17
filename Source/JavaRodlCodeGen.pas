namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

type
  JavaRodlCodeGen = public class (RodlCodeGen)
  private
    method isPrimitive(&type: String):Boolean;
    method GenerateROSDKType(aName: String): String;
    method GenerateGetProperty(aParent:CGExpression;Name:String): CGExpression;
    method GenerateSetProperty(aParent:CGExpression;Name:String; aValue:CGExpression): CGStatement;
    method GenerateOperationAttribute(library: RodlLibrary; entity: RodlOperation;Statements: List<CGStatement>);
    method GetReaderStatement(library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGStatement;
    method GetReaderExpression(library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGExpression;
    method GetWriterStatement(library: RodlLibrary; entity: RodlTypedEntity; useGetter: Boolean := True; variableName: String := "aMessage"): CGStatement;
    method GetWriterStatement_DefaultValues(library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGStatement;

    method WriteToMessage_Method(library: RodlLibrary; entity: RodlStructEntity;useDefaultValues:Boolean): CGMethodDefinition;
    method ReadFromMessage_Method(library: RodlLibrary; entity: RodlStructEntity): CGMethodDefinition;
    method GenerateServiceProxyMethod(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceProxyMethodDeclaration(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyEndMethod(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethodDeclaration(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyEndMethodDeclaration(library: RodlLibrary; entity: RodlOperation;&locked:Boolean): CGMethodDefinition;
    method GenerateServiceConstructors(library: RodlLibrary; entity: RodlService; service:CGClassTypeDefinition);

    method HandleAtributes_private(library: RodlLibrary; entity: RodlEntity): CGFieldDefinition;
    method HandleAtributes_public(library: RodlLibrary; entity: RodlEntity): CGMethodDefinition;
  protected
    method AddUsedNamespaces(file: CGCodeUnit; library: RodlLibrary);override;
    method AddGlobalConstants(file: CGCodeUnit; library: RodlLibrary);override;
    method GenerateEnum(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum); override;
    method GenerateStruct(file: CGCodeUnit; library: RodlLibrary; entity: RodlStruct);override;
    method GenerateArray(file: CGCodeUnit; library: RodlLibrary; entity: RodlArray);override;
    method GenerateException(file: CGCodeUnit; library: RodlLibrary; entity: RodlException);override;
    method GenerateService(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);override;
    method GenerateEventSink(file: CGCodeUnit; library: RodlLibrary; entity: RodlEventSink);override;
    method GetGlobalName(library: RodlLibrary): String;override;
    method GetNamespace(library: RodlLibrary): String;override;
  public
    constructor;
    property addROSDKPrefix: Boolean := True;
    property isCooperMode: Boolean := True;
    method GenerateInterfaceFiles(library: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; override;
  end;

implementation

constructor JavaRodlCodeGen;
begin
  CodeGenTypes.Add("integer", ResolveStdtypes(CGPredefinedTypeKind.Int32,true));
  CodeGenTypes.Add("datetime", "java.util.Date".AsTypeReference);
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeKind.Double,true));
  CodeGenTypes.Add("currency", "java.math.BigDecimal".AsTypeReference);
  CodeGenTypes.Add("widestring", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("ansistring", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeKind.Int64,true));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeKind.Boolean,true));
  CodeGenTypes.Add("variant", "com.remobjects.sdk.VariantType".AsTypeReference);
  CodeGenTypes.Add("binary", new CGArrayTypeReference(ResolveStdtypes(CGPredefinedTypeKind.Int8)));
  CodeGenTypes.Add("xml", "com.remobjects.sdk.XmlType".AsTypeReference);
  CodeGenTypes.Add("guid", "java.util.UUID".AsTypeReference);
  CodeGenTypes.Add("decimal", "java.math.BigDecimal".AsTypeReference);
  CodeGenTypes.Add("utf8string", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("xsdatetime", "java.util.Date".AsTypeReference);

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

method  JavaRodlCodeGen.WriteToMessage_Method(&library: RodlLibrary; entity: RodlStructEntity;useDefaultValues:Boolean): CGMethodDefinition;
begin
  Result := new CGMethodDefinition("writeToMessage",
                        Parameters := [new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeKind.String)),
                                       new CGParameterDefinition("aMessage","Message".AsTypeReference)].ToList,
                                        Virtuality := CGMemberVirtualityKind.Override,
                                        Visibility := CGMemberVisibilityKind.Public);

  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(GenerateGetProperty("aMessage".AsNamedIdentifierExpression,"UseStrictFieldOrderForStructs"),
                                                        lIfRecordStrictOrder_True,
                                                        lIfRecordStrictOrder_False
  );
  Result.Statements.Add(lIfRecordStrictOrder);

  if assigned(entity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
      new CGMethodCallExpression(CGInheritedExpression.Inherited, "writeToMessage",
                                  ["aName".AsNamedIdentifierExpression.AsCallParameter,
                                  "aMessage".AsNamedIdentifierExpression.AsCallParameter].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := entity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for field: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(field.Name.ToLowerInvariant, field);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for field: RodlField in entity.Items do
    if not lSortedFields.ContainsKey(field.Name.ToLowerInvariant) then begin
      lSortedFields.Add(field.Name.ToLowerInvariant, field);
      lIfRecordStrictOrder_True.Statements.Add(
        iif(useDefaultValues, GetWriterStatement_DefaultValues(library, field),GetWriterStatement(library, field))
      );
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(
      iif(useDefaultValues, GetWriterStatement_DefaultValues(library, lSortedFields.Item[lvalue]),GetWriterStatement(library, lSortedFields.Item[lvalue]))
    );
end;


method  JavaRodlCodeGen.AddUsedNamespaces(file: CGCodeUnit; &library: RodlLibrary);
begin
  for Rodl: RodlUse in library.Uses.Items do begin
    if length(Rodl.Includes:JavaModule) > 0 then
      file.Imports.Add(new CGImport(Rodl.Includes:JavaModule))
     else if not String.IsNullOrEmpty(Rodl.Namespace) then
      file.Imports.Add(new CGImport(Rodl.Namespace));
  end;
  file.Imports.Add(new CGImport("java.util"));
  file.Imports.Add(new CGImport("java.net"));
//  file.Imports.Add(new CGImport("java.math"));
  file.Imports.Add(new CGImport("com.remobjects.sdk"));
{
  file.Imports.Add(new CGImport(new CGNamedTypeReference("java.net.URI")));
  file.Imports.Add(new CGImport(new CGNamedTypeReference("java.util.Collection")));
  file.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.ClientChannel")));
  file.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.Message")));
  file.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.ReferenceType")));
  file.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.TypeManager")));
  file.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.AsyncRequest")));
  file.Imports.Add(new CGImport(new CGNamedTypeReference("com.remobjects.sdk.AsyncProxy")));
}
end;

method JavaRodlCodeGen.GenerateStruct(file: CGCodeUnit; library: RodlLibrary; entity: RodlStruct);
begin
  var lancestorName := entity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then lancestorName := GenerateROSDKType("ComplexType");

  var lstruct := new CGClassTypeDefinition(SafeIdentifier(entity.Name), lancestorName.AsTypeReference,
                            &Partial := true,
                            Visibility := CGTypeVisibilityKind.Public
                            );
  lstruct.Comment := GenerateDocumentation(entity);
  file.Types.Add(lstruct);
  {$REGION private class _attributes: HashMap<String, String>;}
  if (entity.CustomAttributes.Count > 0) then
    lstruct.Members.Add(HandleAtributes_private(&library,entity));
  {$ENDREGION}
  {$REGION protected class var s_%fldname%: %fldtype%}
  for lm :RodlTypedEntity in entity.Items do begin
    lstruct.Members.Add(
                        new CGFieldDefinition("s_"+lm.Name, ResolveDataTypeToTypeRef(&library,lm.DataType),
                                              &Static := true,
                                              Visibility := CGMemberVisibilityKind.Protected
                                              ));
  end;
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: String): String; override;}
  if (entity.CustomAttributes.Count > 0) then
    lstruct.Members.Add(HandleAtributes_public(&library,entity));
  {$ENDREGION}
  if entity.Items.Count >0 then begin
    {$REGION public class method setDefaultValues(p_%fldname%: %fldtype%)}
    var lsetDefaultValues := new CGMethodDefinition("setDefaultValues",
                                Visibility := CGMemberVisibilityKind.Public,
                                &Static := true
                                );
    lstruct.Members.Add(lsetDefaultValues);
    for lm: RodlTypedEntity in entity.Items do begin
      lsetDefaultValues.Parameters.Add(
        new CGParameterDefinition("p_"+lm.Name, ResolveDataTypeToTypeRef(&library,lm.DataType)));
      lsetDefaultValues.Statements.Add(
          new CGAssignmentStatement(
                ("s_"+lm.Name).AsNamedIdentifierExpression,
                ("p_"+lm.Name).AsNamedIdentifierExpression
        )
      );
    end;
    {$ENDREGION}
    {$REGION private %f_fldname%: %fldtype% + public getter/setter}
    for lm :RodlTypedEntity in entity.Items do begin
      var ltype := ResolveDataTypeToTypeRef(&library,lm.DataType);
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
    lstruct.Members.Add(WriteToMessage_Method(&library,entity,true));
    {$ENDREGION}
    {$REGION method ReadFromMessage_Method(aName: String; aMessage: Message); override;}
    lstruct.Members.Add(ReadFromMessage_Method(&library,entity));
    {$ENDREGION}
    {$REGION public property %fldname%: %fldtype%}
    if isCooperMode then begin
      for lm :RodlTypedEntity in entity.Items do begin
        var f_name :='f_'+lm.Name;
        var s_name :='s_'+lm.Name;
        var st1: CGStatement :=new CGIfThenElseStatement(new CGBinaryOperatorExpression(f_name.AsNamedIdentifierExpression, CGNilExpression.Nil, CGBinaryOperatorKind.NotEquals),
                                                          f_name.AsNamedIdentifierExpression.AsReturnStatement,
                                                          s_name.AsNamedIdentifierExpression.AsReturnStatement);
        //var st2: CGStatement :=new CGAssignmentStatement(f_name.AsNamedIdentifierExpression,CGPropertyDefinition.MAGIC_VALUE_PARAMETER_NAME.AsNamedIdentifierExpression);
        lstruct.Members.Add(new CGPropertyDefinition(lm.Name,
                            ResolveDataTypeToTypeRef(&library,lm.DataType),
                            [st1].ToList,
                            SetExpression := f_name.AsNamedIdentifierExpression,
                            Visibility := CGMemberVisibilityKind.Public,
                            Comment := GenerateDocumentation(lm)));
      end;
    end;
    {$ENDREGION}
  end;
end;

method JavaRodlCodeGen.GenerateArray(file: CGCodeUnit; library: RodlLibrary; entity: RodlArray);
begin
  var larray := new CGClassTypeDefinition(SafeIdentifier(entity.Name),GenerateROSDKType("ArrayType").AsTypeReference,
                                          Visibility := CGTypeVisibilityKind.Public,
                                          &Partial := true
                                          );
  larray.Comment := GenerateDocumentation(entity);
  file.Types.Add(larray);
  if not isCooperMode then
    larray.Attributes.Add(new CGAttribute("SuppressWarnings".AsTypeReference,
                           ["rawtypes".AsLiteralExpression.AsCallParameter].ToList));
  {$REGION private class _attributes: HashMap<String, String>;}
  if (entity.CustomAttributes.Count > 0) then
    larray.Members.Add(HandleAtributes_private(&library,entity));
  {$ENDREGION}

  {$REGION .ctor}
  larray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [
        CGStatement(new CGConstructorCallStatement(CGInheritedExpression.Inherited, new List<CGCallParameter>))
      ].ToList)
  );
  {$ENDREGION}

  {$REGION .ctor(aCapacity: Integer)}
  larray.Members.Add(
    new CGConstructorDefinition(
            Parameters := [new CGParameterDefinition("aCapacity", ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
            Visibility := CGMemberVisibilityKind.Public,
            Statements:=
               [CGStatement(
                  new CGConstructorCallStatement(CGInheritedExpression.Inherited,["aCapacity".AsNamedIdentifierExpression.AsCallParameter].ToList))
               ].ToList
            )
  );
  {$ENDREGION}

  {$REGION .ctor(aCollection: Collection)}
  larray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Parameters := [new CGParameterDefinition("aCollection", "Collection".AsTypeReference)].ToList,
      Statements := [
        CGStatement(
            new CGConstructorCallStatement(CGInheritedExpression.Inherited,["aCollection".AsNamedIdentifierExpression.AsCallParameter].ToList))
      ].ToList)
  );
  {$ENDREGION}

  var l_elementType := ResolveDataTypeToTypeRef(&library,SafeIdentifier(entity.ElementType));

  {$REGION .ctor(anArray: array of Object)}
  larray.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Parameters := [new CGParameterDefinition("anArray", new CGArrayTypeReference(ResolveStdtypes(CGPredefinedTypeKind.Object)))].ToList,
      Statements:= [
        CGStatement(
            new CGConstructorCallStatement(CGInheritedExpression.Inherited, ["anArray".AsNamedIdentifierExpression.AsCallParameter].ToList ))].ToList)
  );
  {$ENDREGION}

  {$REGION method add: %ARRAY_TYPE%;}
  if isComplex(&library,entity.ElementType) then
    larray.Members.Add(
      new CGMethodDefinition("add",
        Visibility := CGMemberVisibilityKind.Public,
        ReturnType := l_elementType,
        Statements:=
          [new CGVariableDeclarationStatement('lresult',l_elementType,new CGNewInstanceExpression(l_elementType)),
           new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", ["lresult".AsNamedIdentifierExpression.AsCallParameter].ToList),
           "lresult".AsNamedIdentifierExpression.AsReturnStatement
          ].ToList
        )
    );

  {$ENDREGION}

  {$REGION public class method getAttributeValue(aName: String): String; override;}
  if (entity.CustomAttributes.Count > 0) then
    larray.Members.Add(HandleAtributes_public(&library,entity));
  {$ENDREGION}

  {$REGION method addItem(anItem: %ARRAY_TYPE%)}
  larray.Members.Add(
    new CGMethodDefinition("addItem",
                           [new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", ["anItem".AsNamedIdentifierExpression.AsCallParameter].ToList)],
                           Visibility := CGMemberVisibilityKind.Public,
                           Parameters := [new CGParameterDefinition("anItem", l_elementType)].ToList));
  {$ENDREGION}

  {$REGION method insertItem(anItem: %ARRAY_TYPE%; anIndex: Integer);}
  larray.Members.Add(
    new CGMethodDefinition("insertItem",
                           [new CGMethodCallExpression(CGInheritedExpression.Inherited,"insertItem",
                                                      ["anItem".AsNamedIdentifierExpression.AsCallParameter,
                                                      "anIndex".AsNamedIdentifierExpression.AsCallParameter].ToList)],
                            Parameters := [new CGParameterDefinition("anItem", l_elementType),
                                           new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}

  {$REGION method replaceItemAtIndex(anItem: %ARRAY_TYPE%; anIndex: Integer);}
  larray.Members.Add(
    new CGMethodDefinition("replaceItemAtIndex",
                          [new CGMethodCallExpression(CGInheritedExpression.Inherited, "replaceItemAtIndex",
                                                  ["anItem".AsNamedIdentifierExpression.AsCallParameter,
                                                  "anIndex".AsNamedIdentifierExpression.AsCallParameter].ToList)],
                          Parameters := [new CGParameterDefinition("anItem", l_elementType),
                                         new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                          Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method getItemAtIndex(anIndex: Integer): %ARRAY_TYPE%; override;}
  larray.Members.Add(
    new CGMethodDefinition("getItemAtIndex",
                           [new CGTypeCastExpression(
                                                    new CGMethodCallExpression(CGInheritedExpression.Inherited,
                                                                                "getItemAtIndex",
                                                                               ["anIndex".AsNamedIdentifierExpression.AsCallParameter].ToList),
                                                    l_elementType,
                                                    ThrowsException := true).AsReturnStatement],
                            Parameters :=[new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                            ReturnType := l_elementType,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public)
  );
  {$ENDREGION}

  {$REGION method itemClass: &Class;}
  larray.Members.Add(
    new CGMethodDefinition("itemClass",
                           [new CGTypeOfExpression(l_elementType.AsExpression).AsReturnStatement],
                            ReturnType := "Class".AsTypeReference,
                            Visibility := CGMemberVisibilityKind.Public
                            )
      );
  {$ENDREGION}

  {$REGION method itemTypeName: String;}
  larray.Members.Add(
    new CGMethodDefinition("itemTypeName",
                           [SafeIdentifier(entity.ElementType).AsLiteralExpression.AsReturnStatement],
                            ReturnType := ResolveStdtypes(CGPredefinedTypeKind.String),
                            Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method writeItemToMessage(aMessage: Message; anIndex: Integer); override;}
  var lLower: String  := entity.ElementType.ToLowerInvariant();
  var l_isStandard := ReaderFunctions.ContainsKey(lLower);
  var l_isArray := False;
  var l_isStruct := False;
  var l_isEnum := False;
  var l_methodName: String;
  if l_isStandard then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, entity.ElementType) then begin
    l_methodName := "Array";
    l_isArray := True;
  end
  else if isStruct(&library, entity.ElementType) then begin
    l_methodName := "Complex";
    l_isStruct :=True;
  end
  else if isEnum(&library, entity.ElementType) then begin
    l_methodName := "Enum";
    l_isEnum := True;
  end;

  var l_arg0 := new CGNilExpression().AsCallParameter;
  var l_arg1_exp: CGExpression := new CGMethodCallExpression(CGSelfExpression.Self,"getItemAtIndex",["anIndex".AsNamedIdentifierExpression.AsCallParameter].ToList);
  if l_isEnum then l_arg1_exp := new CGMethodCallExpression(l_arg1_exp,"ordinal");
  var l_arg1 := l_arg1_exp.AsCallParameter;

  larray.Members.Add(
    new CGMethodDefinition("writeItemToMessage",
                           [new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression,"write" +  l_methodName,  [l_arg0,l_arg1].ToList)],
                            Parameters := [new CGParameterDefinition("aMessage", "Message".AsTypeReference),
                                           new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
                            Virtuality := CGMemberVirtualityKind.Override,
                            Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method readItemFromMessage(aMessage: Message; anIndex: Integer); override;}
  var l_arg_array : array of CGCallParameter;
  if l_isStruct or l_isArray then begin
    l_arg_array:= [l_arg0, new CGTypeOfExpression(l_elementType.AsExpression).AsCallParameter];
  end
  else begin
    l_arg_array:= [l_arg0];
  end;

  larray.Members.Add(
    new CGMethodDefinition("readItemFromMessage",
                           [new CGMethodCallExpression(CGSelfExpression.Self,
                                                       "addItem",
                                                       [new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression,
                                                                                   "read" +  l_methodName,
                                                                                   l_arg_array.ToList).AsCallParameter].ToList)
                           ],
      Parameters := [new CGParameterDefinition("aMessage", "Message".AsTypeReference),
                   new CGParameterDefinition("anIndex", ResolveStdtypes(CGPredefinedTypeKind.Int32))].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}
end;

method JavaRodlCodeGen.GenerateException(file: CGCodeUnit; library: RodlLibrary; entity: RodlException);
begin
  var lexception := new CGClassTypeDefinition(SafeIdentifier(entity.Name),
                                              GenerateROSDKType("ExceptionType").AsTypeReference,
                                              Visibility := CGTypeVisibilityKind.Public,
                                              &Partial := true
                                              );
  lexception.Comment := GenerateDocumentation(entity);
  file.Types.Add(lexception);
  if not isCooperMode then
    lexception.Attributes.Add(new CGAttribute("SuppressWarnings".AsTypeReference,
                                             ["serial".AsLiteralExpression.AsCallParameter].ToList));

  {$REGION private class _attributes: HashMap<String, String>;}
  if (entity.CustomAttributes.Count > 0) then
    lexception.Members.Add(HandleAtributes_private(&library,entity));
  {$ENDREGION}

  {$REGION public class method getAttributeValue(aName: String): String; override;}
  if (entity.CustomAttributes.Count > 0) then
    lexception.Members.Add(HandleAtributes_public(&library,entity));
  {$ENDREGION}

  if not isCooperMode then begin
  {$REGION private property %f_fldname%: %fldtype% + public getter/setter}
    for lm :RodlTypedEntity in entity.Items do begin
      var ltype := ResolveDataTypeToTypeRef(&library,lm.DataType);
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
                                                    Parameters := [new CGParameterDefinition("anExceptionMessage", ResolveStdtypes(CGPredefinedTypeKind.String))].ToList,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    statements := [CGStatement(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                                                                              ["anExceptionMessage".AsNamedIdentifierExpression.AsCallParameter].ToList))].ToList
                                                    ));
  {$ENDREGION}

  {$REGION .ctor(aExceptionMessage: String; aFromServer: Boolean)}
  lexception.Members.Add(
                        new CGConstructorDefinition(
                                                    Parameters :=[new CGParameterDefinition("anExceptionMessage", ResolveStdtypes(CGPredefinedTypeKind.String)),
                                                                  new CGParameterDefinition("aFromServer", ResolveStdtypes(CGPredefinedTypeKind.Boolean))].ToList,
                                                    Visibility := CGMemberVisibilityKind.Public,
                                                    Statements:= [CGStatement(
                                                                        new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                                        ["anExceptionMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                                        "aFromServer".AsNamedIdentifierExpression.AsCallParameter].ToList))].ToList
                                                                        ));
  {$ENDREGION}

  if entity.Items.Count >0 then begin
    {$REGION public method writeToMessage(aName: String; aMessage: Message); override;}
    lexception.Members.Add(WriteToMessage_Method(&library,entity,false));
    {$ENDREGION}
    {$REGION method ReadFromMessage_Method(aName: String; aMessage: Message); override;}
    lexception.Members.Add(ReadFromMessage_Method(&library,entity));
    {$ENDREGION}
  end;

  {$REGION public property %fldname%: %fldtype%}
  if isCooperMode then begin
    for lm :RodlTypedEntity in entity.Items do
      lexception.Members.Add(new CGPropertyDefinition(
      lm.Name,
      ResolveDataTypeToTypeRef(&library,lm.DataType),
      Visibility := CGMemberVisibilityKind.Public,
      Comment := GenerateDocumentation(lm)));
  end;
  {$ENDREGION}
end;

method JavaRodlCodeGen.GenerateService(file: CGCodeUnit; library: RodlLibrary; entity: RodlService);
begin
  {$REGION I%SERVICE_NAME%}
  var lIService := new CGInterfaceTypeDefinition(SafeIdentifier("I"+entity.Name),
                                                 Visibility := CGTypeVisibilityKind.Public);
  lIService.Comment := GenerateDocumentation(entity);
  file.Types.Add(lIService);
  for lop : RodlOperation in entity.DefaultInterface:Items do begin
    var m := GenerateServiceProxyMethodDeclaration(&library, lop);
    m.Comment := GenerateDocumentation(lop,true);
    lIService.Members.Add(m);
  end;

  {$ENDREGION}

  {$REGION I%SERVICE_NAME%_Async}
  var lIServiceAsync := new CGInterfaceTypeDefinition(SafeIdentifier("I"+entity.Name+"_Async"),
                                                      Visibility := CGTypeVisibilityKind.Public
                                                      );
  file.Types.Add(lIServiceAsync);
  for lop : RodlOperation in entity.DefaultInterface:Items do begin
    lIServiceAsync.Members.Add(GenerateServiceAsyncProxyBeginMethodDeclaration(&library, lop));
    lIServiceAsync.Members.Add(GenerateServiceAsyncProxyEndMethodDeclaration(&library, lop,false));
  end;
  {$ENDREGION}

  {$REGION %SERVICE_NAME%_Proxy}
  var lancestorName := entity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then
    lancestorName := GenerateROSDKType("Proxy")
  else
    lancestorName := lancestorName+"_Proxy";
  var lServiceProxy := new CGClassTypeDefinition(SafeIdentifier(entity.Name+"_Proxy"),
                                                [lancestorName.AsTypeReference].ToList,
                                                [lIService.Name.AsTypeReference].ToList,
                                                  Visibility := CGTypeVisibilityKind.Public,
                                                  &Partial := true
                                                  );
  file.Types.Add(lServiceProxy);

  GenerateServiceConstructors(&library,entity, lServiceProxy);

  for lop : RodlOperation in entity.DefaultInterface:Items do
    lServiceProxy.Members.Add(GenerateServiceProxyMethod(&library,lop));
  {$ENDREGION}

  {$REGION %SERVICE_NAME%_AsyncProxy}
  var lServiceAsyncProxy := new CGClassTypeDefinition(SafeIdentifier(entity.Name+"_AsyncProxy"),
                                                      [GenerateROSDKType("AsyncProxy").AsTypeReference].ToList,
                                                      [lIServiceAsync.Name.AsTypeReference].ToList,
                                                      Visibility := CGTypeVisibilityKind.Public,
                                                      &Partial := true);
  file.Types.Add(lServiceAsyncProxy);
  GenerateServiceConstructors(&library,entity,lServiceAsyncProxy);
  for lop : RodlOperation in entity.DefaultInterface:Items do begin
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod(&library, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyEndMethod(&library, lop));
  end;
  {$ENDREGION}
end;


method JavaRodlCodeGen.GenerateEventSink(file: CGCodeUnit; library: RodlLibrary; entity: RodlEventSink);
begin
  var i_name := 'I'+entity.Name;
  var i_adaptername := i_name+'_Adapter';
  var lIEvent := new CGInterfaceTypeDefinition(i_name,GenerateROSDKType("IEvents").AsTypeReference,
                            Visibility := CGTypeVisibilityKind.Public);
  lIEvent.Comment := GenerateDocumentation(entity);
  file.Types.Add(lIEvent);

  for lop : RodlOperation in entity.DefaultInterface:Items do begin
    {$REGION %event_sink%Event}
    var lOperation := new CGClassTypeDefinition(SafeIdentifier(lop.Name+"Event"),GenerateROSDKType("EventType").AsTypeReference,
                                                Visibility := CGTypeVisibilityKind.Public,
                                                &Partial := true
                                                );
    if not isCooperMode then begin
      for lm :RodlParameter in lop.Items do begin
        var ltype := ResolveDataTypeToTypeRef(&library,lm.DataType);
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
                              Parameters:=[new CGParameterDefinition("aBuffer", "Message".AsTypeReference)].ToList,
                              Visibility := CGMemberVisibilityKind.Public);
    lOperation.Members.Add(lop_method);

    for lm :RodlParameter in lop.Items do begin
      if isCooperMode then begin
        lOperation.Members.Add(new CGPropertyDefinition(
                                                        lm.Name,
                                                        ResolveDataTypeToTypeRef(&library,lm.DataType),
                                                        Visibility := CGMemberVisibilityKind.Public,
                                                        Comment:= GenerateDocumentation(lm)));
      end;
      lop_method.Statements.Add(GetReaderStatement(&library,lm,"aBuffer"));
    end;

    file.Types.Add(lOperation);
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

    file.Types.Add(lIEventAdapter);
    for lop : RodlOperation in entity.DefaultInterface:Items do begin
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

method JavaRodlCodeGen.GetWriterStatement_DefaultValues(&library: RodlLibrary; entity: RodlTypedEntity;variableName: String): CGStatement;
begin
  var lentityname := entity.Name;
  var lLower: String  := entity.DataType.ToLowerInvariant();
  var l_isStandard := ReaderFunctions.ContainsKey(lLower);
  var l_isArray := False;
  var l_isStruct := False;
  var l_isEnum := False;
  var l_methodName: String;
  if l_isStandard then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, entity.DataType) then begin
    l_methodName := "Array";
    l_isArray := True;
  end
  else if isStruct(&library, entity.DataType) then begin
    l_methodName := "Complex";
    l_isStruct :=True;
  end
  else if isEnum(&library, entity.DataType) then begin
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
    raise new Exception(String.Format("unknown type: {0}",[entity.DataType]));
  end;
end;

method JavaRodlCodeGen.ReadFromMessage_Method(&library: RodlLibrary; entity: RodlStructEntity): CGMethodDefinition;
begin
  Result := new CGMethodDefinition("readFromMessage",
                        Parameters := [new CGParameterDefinition("aName",   ResolveStdtypes(CGPredefinedTypeKind.String)),
                                       new CGParameterDefinition("aMessage","Message".AsTypeReference)].ToList,
                        Virtuality := CGMemberVirtualityKind.Override,
                        Visibility := CGMemberVisibilityKind.Public);
  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(GenerateGetProperty("aMessage".AsNamedIdentifierExpression,"UseStrictFieldOrderForStructs"),
                                                        lIfRecordStrictOrder_True,
                                                        lIfRecordStrictOrder_False
  );
  Result.Statements.Add(lIfRecordStrictOrder);

  if assigned(entity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
                      new CGMethodCallExpression(CGInheritedExpression.Inherited,"readFromMessage",
                                                ["aName".AsNamedIdentifierExpression.AsCallParameter,
                                                 "aMessage".AsNamedIdentifierExpression.AsCallParameter].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := entity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for field: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(field.Name.ToLowerInvariant, field);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for field: RodlField in entity.Items do
    if not lSortedFields.ContainsKey(field.Name.ToLowerInvariant) then begin
      lSortedFields.Add(field.Name.ToLowerInvariant, field);
      lIfRecordStrictOrder_True.Statements.Add(GetReaderStatement(library, field));
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(GetReaderStatement(library, lSortedFields.Item[lvalue]));

end;

method JavaRodlCodeGen.GetReaderStatement(&library: RodlLibrary; entity: RodlTypedEntity; variableName: String): CGStatement;
begin
  var lreader := GetReaderExpression(&library,entity,variableName);
  exit GenerateSetProperty(CGSelfExpression.Self,entity.Name, lreader);
end;

method JavaRodlCodeGen.HandleAtributes_private(&library: RodlLibrary; entity: RodlEntity): CGFieldDefinition;
begin
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (entity.CustomAttributes.Count = 0) then exit;
  exit new CGFieldDefinition("_attributes",
                             new CGNamedTypeReference("HashMap", GenericArguments := [ResolveStdtypes(CGPredefinedTypeKind.String),ResolveStdtypes(CGPredefinedTypeKind.String)].ToList),
                            &Static := true,
                            Visibility := CGMemberVisibilityKind.Private);
end;

method JavaRodlCodeGen.HandleAtributes_public(&library: RodlLibrary; entity: RodlEntity): CGMethodDefinition;
begin
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (entity.CustomAttributes.Count = 0) then exit;
  Result := new CGMethodDefinition("getAttributeValue",
                                  Parameters:=[new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeKind.String))].ToList,
                                  ReturnType := ResolveStdtypes(CGPredefinedTypeKind.String),
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
                            new CGNewInstanceExpression(new CGNamedTypeReference("HashMap", GenericArguments := [ResolveStdtypes(CGPredefinedTypeKind.String),ResolveStdtypes(CGPredefinedTypeKind.String)].ToList)))
  );

  for l_key: String in entity.CustomAttributes.Keys do begin
    l_if_true.Statements.Add(
      new CGMethodCallExpression(l_attributes,"put",
                                [EscapeString(l_key.ToLowerInvariant).AsLiteralExpression.AsCallParameter,
                              EscapeString(entity.CustomAttributes[l_key]).AsLiteralExpression.AsCallParameter].ToList
        ));
  end;
  Result.Statements.Add(new CGMethodCallExpression(l_attributes,"get", [new CGMethodCallExpression("aName".AsNamedIdentifierExpression,"toLowerCase").AsCallParameter].ToList).AsReturnStatement);
end;

method JavaRodlCodeGen.GetWriterStatement(&library: RodlLibrary; entity: RodlTypedEntity; useGetter: Boolean := True; variableName: String := "aMessage"): CGStatement;
begin
  var lentityname := entity.Name;
  var lLower: String  := entity.DataType.ToLowerInvariant();
  var l_isStandard := ReaderFunctions.ContainsKey(lLower);
  var l_isArray := False;
  var l_isStruct := False;
  var l_isEnum := False;
  var l_methodName: String;
  if l_isStandard then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, entity.DataType) then begin
    l_methodName := "Array";
    l_isArray := True;
  end
  else if isStruct(&library, entity.DataType) then begin
    l_methodName := "Complex";
    l_isStruct :=True;
  end
  else if isEnum(&library, entity.DataType) then begin
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
    raise new Exception(String.Format("unknown type: {0}",[entity.DataType]));
  end;
end;

method JavaRodlCodeGen.GetReaderExpression(&library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGExpression;
begin
  var lLower: String  := entity.DataType.ToLowerInvariant();
  var l_isStandard := ReaderFunctions.ContainsKey(lLower);
  var l_isArray := False;
  var l_isStruct := False;
  var l_isEnum := False;
  var l_methodName: String;
  if l_isStandard then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, entity.DataType) then begin
    l_methodName := "Array";
    l_isArray := True;
  end
  else if isStruct(&library, entity.DataType) then begin
    l_methodName := "Complex";
    l_isStruct :=True;
  end
  else if isEnum(&library, entity.DataType) then begin
    l_methodName := "Enum";
    l_isEnum := True;
  end;

  var varname_ID := variableName.AsNamedIdentifierExpression;
  var reader_name := "read" +  l_methodName;
//  var l_reader := new CGIdentifierExpression("read" +  l_methodName, variableName);
  var l_arg0 : CGCallParameter := entity.Name.AsLiteralExpression.AsCallParameter;
  var l_type := ResolveDataTypeToTypeRef(&library,entity.DataType);


  if l_isStandard then begin
    var temp := new CGMethodCallExpression(varname_ID,reader_name,[l_arg0].ToList);
    if isPrimitive(entity.DataType) then
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
    raise new Exception(String.Format("unknown type: {0}",[entity.DataType]));
  end;

end;

method JavaRodlCodeGen.GenerateServiceProxyMethod(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceProxyMethodDeclaration(&library,entity);
  var l_in:= new List<RodlParameter>;
  var l_out:= new List<RodlParameter>;
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_in.Add(lp);
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_out.Add(lp);
  end;

  var llocalmessage := "_localMessage".AsNamedIdentifierExpression;
  Result.Statements.Add(new CGVariableDeclarationStatement(
                                                  "_localMessage",
                                                  "Message".AsTypeReference,
                                                  new CGTypeCastExpression(
                                                                    new CGMethodCallExpression(
                                                                              GenerateGetProperty(CGSelfExpression.Self, "ProxyMessage"),
                                                                              "clone"),
                                                                    "Message".AsTypeReference,
                                                                    ThrowsException:=True)));
  GenerateOperationAttribute(&library,entity,Result.Statements);
  Result.Statements.Add(
    new CGMethodCallExpression(llocalmessage,"initializeAsRequestMessage",
                                [entity.OwnerLibrary.Name.AsLiteralExpression.AsCallParameter,
                                new CGMethodCallExpression(CGSelfExpression.Self, "_getActiveInterfaceName").AsCallParameter,
                                entity.Name.AsLiteralExpression.AsCallParameter].ToList
      ));
  var ltry := new List<CGStatement>;
  var lfinally := new List<CGStatement>;


  for lp: RodlParameter in l_in do
    ltry.Add(GetWriterStatement(&library,lp,false, llocalmessage.Name));
  ltry.Add(new CGMethodCallExpression(llocalmessage, "finalizeMessage"));
  ltry.Add(new CGMethodCallExpression(GenerateGetProperty(CGSelfExpression.Self, "ProxyClientChannel"),
                                      "dispatch",
                                      [llocalmessage.AsCallParameter].ToList));

  if assigned(entity.Result) then begin
    ltry.Add(new CGVariableDeclarationStatement("lResult",Result.ReturnType,GetReaderExpression(&library,entity.Result,llocalmessage.Name)));
  end;
  for lp: RodlParameter in l_out do
    ltry.Add(GenerateSetProperty(("_"+lp.Name).AsNamedIdentifierExpression,
                                 "Value",
                                 GetReaderExpression(&library,lp,llocalmessage.Name)                            ));
  if assigned(entity.Result) then
    ltry.Add("lResult".AsNamedIdentifierExpression.AsReturnStatement);
  lfinally.Add(GenerateSetProperty(GenerateGetProperty(CGSelfExpression.Self,"ProxyMessage"),
                                   "ClientID",
                                   GenerateGetProperty(llocalmessage,"ClientID")));
  lfinally.Add(new CGMethodCallExpression(llocalmessage, "clear"));
  Result.Statements.Add(new CGTryFinallyCatchStatement(ltry, &FinallyStatements:= lfinally as not nullable));
end;

method JavaRodlCodeGen.GenerateServiceProxyMethodDeclaration(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition(SafeIdentifier(entity.Name),
                                  Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(&library, lp.DataType)));
  end;
  if assigned(entity.Result) then Result.ReturnType := ResolveDataTypeToTypeRef(&library, entity.Result.DataType);
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition("_"+lp.Name, new CGNamedTypeReference(GenerateROSDKType("ReferenceType"), GenericArguments:=[ResolveDataTypeToTypeRef(&library, lp.DataType)].ToList)));
  end;
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyBeginMethodDeclaration(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition("begin" + PascalCase(entity.Name),
                                  ReturnType := GenerateROSDKType("AsyncRequest").AsTypeReference,
                                  Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(&library, lp.DataType)));
  end;
  result.Parameters.Add(new CGParameterDefinition("start", ResolveStdtypes(CGPredefinedTypeKind.Boolean)));
  result.Parameters.Add(new CGParameterDefinition("callback", GenerateROSDKType("AsyncRequest.IAsyncRequestCallback").AsTypeReference));
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyEndMethodDeclaration(&library: RodlLibrary; entity: RodlOperation;&locked:Boolean): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition("end" + PascalCase(entity.Name),
      Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, new CGNamedTypeReference(GenerateROSDKType("ReferenceType"), GenericArguments :=[ResolveDataTypeToTypeRef(&library, lp.DataType)].ToList)));
  end;
  if assigned(entity.Result) then
    result.ReturnType := ResolveDataTypeToTypeRef(library, entity.Result.DataType);

  result.Parameters.Add(new CGParameterDefinition("aAsyncRequest", GenerateROSDKType("AsyncRequest").AsTypeReference));
  result.Locked := &locked;
end;


method JavaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(&library,entity);
  var l_in:= new List<RodlParameter>;
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      l_in.Add(lp);
  end;

  var llocalmessage := "_localMessage".AsNamedIdentifierExpression;
  Result.Statements.Add(new CGVariableDeclarationStatement("_localMessage",
                                                           "Message".AsTypeReference,
                                                           new CGTypeCastExpression(
                                                                              new CGMethodCallExpression(
                                                                                                    GenerateGetProperty(CGSelfExpression.Self,"ProxyMessage"),
                                                                                                    "clone"),
                                                                              "Message".AsTypeReference,
                                                                              ThrowsException:=True)
                                                ));

  GenerateOperationAttribute(&library,entity,Result.Statements);

  Result.Statements.Add(
    new CGMethodCallExpression(llocalmessage,"initializeAsRequestMessage",
                              [entity.OwnerLibrary.Name.AsLiteralExpression.AsCallParameter,
                              new CGMethodCallExpression(CGSelfExpression.Self, "_getActiveInterfaceName").AsCallParameter,
                              entity.Name.AsLiteralExpression.AsCallParameter].ToList
    ));

  for lp: RodlParameter in l_in do
    Result.Statements.Add(GetWriterStatement(&library,lp,false,llocalmessage.Name));
  Result.Statements.Add(new CGMethodCallExpression(llocalmessage, "finalizeMessage"));
  Result.Statements.Add(new CGMethodCallExpression(GenerateGetProperty(CGSelfExpression.Self,"ProxyClientChannel"),
                                                   "asyncDispatch",
                                                   [llocalmessage.AsCallParameter,
                                                   new CGSelfExpression().AsCallParameter,
                                                   "start".AsNamedIdentifierExpression.AsCallParameter,
                                                   "callback".AsNamedIdentifierExpression.AsCallParameter].ToList).AsReturnStatement
  );
end;

method JavaRodlCodeGen.GenerateServiceAsyncProxyEndMethod(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyEndMethodDeclaration(&library,entity,true);

  var l_out:= new List<RodlParameter>;
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      l_out.Add(lp);
  end;

  var llocalmessage := "_localMessage".AsNamedIdentifierExpression;
  Result.Statements.Add(new CGVariableDeclarationStatement("_localMessage",
                                                           "Message".AsTypeReference,
                                                           GenerateGetProperty("aAsyncRequest".AsNamedIdentifierExpression,"ProcessMessage")));

  GenerateOperationAttribute(&library,entity,Result.Statements);

  if assigned(entity.Result) then begin
    Result.Statements.Add(new CGVariableDeclarationStatement("lResult",Result.ReturnType,GetReaderExpression(&library,entity.Result,llocalmessage.Name)));
  end;
  for lp: RodlParameter in l_out do
    Result.Statements.Add(GenerateSetProperty(lp.Name.AsNamedIdentifierExpression,
                                              "Value",
                                              GetReaderExpression(&library,lp,llocalmessage.Name)));
  var mess := GenerateGetProperty(new CGSelfExpression,"ProxyMessage");
  Result.Statements.Add(GenerateSetProperty(mess,"ClientID",GenerateGetProperty(llocalmessage,"ClientID")));
  Result.Statements.Add(new CGMethodCallExpression(llocalmessage,"clear"));
  if assigned(entity.Result) then
    Result.Statements.Add("lResult".AsNamedIdentifierExpression.AsReturnStatement);
end;

method JavaRodlCodeGen.GenerateServiceConstructors(&library: RodlLibrary; entity: RodlService; service: CGClassTypeDefinition);
begin
  {$REGION .ctor}
  var l_Setpackage := new CGMethodCallExpression("TypeManager".AsNamedIdentifierExpression,"setPackage",[targetNamespace.AsLiteralExpression.AsCallParameter].ToList);
  service.Members.Add(
    new CGConstructorDefinition(
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [
        new CGConstructorCallStatement(CGInheritedExpression.Inherited, new List<CGCallParameter>),
        l_Setpackage].ToList
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aMessage: Message; aClientChannel: ClientChannel)}
  service.Members.Add(
    new CGConstructorDefinition(
      Parameters := [new CGParameterDefinition("aMessage", "Message".AsTypeReference),
                     new CGParameterDefinition("aClientChannel", "ClientChannel".AsTypeReference)].ToList,
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
  service.Members.Add(
    new CGConstructorDefinition(
     Parameters := [new CGParameterDefinition("aMessage", "Message".AsTypeReference),
                    new CGParameterDefinition("aClientChannel", "ClientChannel".AsTypeReference),
                    new CGParameterDefinition("aOverrideInterfaceName", ResolveStdtypes(CGPredefinedTypeKind.String))].ToList,
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
  service.Members.Add(
    new CGConstructorDefinition(
      Parameters := [new CGParameterDefinition("aSchema", "URI".AsTypeReference)].ToList,
      Visibility := CGMemberVisibilityKind.Public,
      Statements:= [new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                  ["aSchema".AsNamedIdentifierExpression.AsCallParameter].ToList),
                    l_Setpackage].ToList
      )
  );
  {$ENDREGION}

  {$REGION .ctor(aSchema: URI; aOverrideInterfaceName: String)}
  service.Members.Add(
    new CGConstructorDefinition(
     Parameters:=[new CGParameterDefinition("aSchema", "URI".AsTypeReference),
                  new CGParameterDefinition("aOverrideInterfaceName", ResolveStdtypes(CGPredefinedTypeKind.String))].ToList,
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
  service.Members.Add(
    new CGMethodDefinition("_getInterfaceName",
                          [SafeIdentifier(entity.Name).AsLiteralExpression.AsReturnStatement],
                          ReturnType := ResolveStdtypes(CGPredefinedTypeKind.String),
                          Virtuality := CGMemberVirtualityKind.Override,
                          Visibility := CGMemberVisibilityKind.Public)
  );
  {$ENDREGION}
end;

method JavaRodlCodeGen.GenerateOperationAttribute(&library: RodlLibrary; entity: RodlOperation; Statements: List<CGStatement>);
begin
  var ld := Operation_GetAttributes(&library, entity);
  if ld.Count > 0 then begin
    var lhashmaptype := new CGNamedTypeReference("HashMap",GenericArguments := [ResolveStdtypes(CGPredefinedTypeKind.String),ResolveStdtypes(CGPredefinedTypeKind.String)].ToList);
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

method JavaRodlCodeGen.GetGlobalName(library: RodlLibrary): String;
begin
  exit 'Defines_'+GetNamespace(library).Replace('.','_');
end;

method JavaRodlCodeGen.GetNamespace(library: RodlLibrary): String;
begin
  if assigned(library.Includes) then result := library.Includes.JavaModule;
  if String.IsNullOrWhiteSpace(result) then result := inherited GetNamespace(library);
end;

method JavaRodlCodeGen.GenerateInterfaceFiles(library: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>;
begin
  isCooperMode := False;
  result := new Dictionary<String,String>;
  var lnamespace := iif(String.IsNullOrEmpty(aTargetNamespace), library.Namespace,aTargetNamespace);
  var lunit := DoGenerateInterfaceFile(library, lnamespace);
  //var lgn := GetGlobalName(library);
  for k in lunit.Types do begin
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

method JavaRodlCodeGen.GenerateEnum(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum);
begin
  var lenum := new CGEnumTypeDefinition(SafeIdentifier(entity.Name),
                                        Visibility := CGTypeVisibilityKind.Public);
  lenum.Comment := GenerateDocumentation(entity);
  file.Types.Add(lenum);
  for enummember: RodlEnumValue in entity.Items do begin
    var lname := GenerateEnumMemberName(library, entity, enummember);
    var lenummember := new CGEnumValueDefinition(lname);
    lenummember.Comment := GenerateDocumentation(enummember);
    lenum.Members.Add(lenummember);
  end;
end;

method JavaRodlCodeGen.AddGlobalConstants(file: CGCodeUnit; library: RodlLibrary);
begin
  var TargetNamespaceName := GetNamespace(library);

  var ltype : CGTypeDefinition;

  if isCooperMode then
    ltype := new CGClassTypeDefinition(GetGlobalName(library), visibility:= CGTypeVisibilityKind.Public)
  else
    ltype := new CGInterfaceTypeDefinition(GetGlobalName(library), visibility:= CGTypeVisibilityKind.Public);

  file.Types.Add(ltype);

  ltype.Members.Add(new CGFieldDefinition("TARGET_NAMESPACE", ResolveStdtypes(CGPredefinedTypeKind.String),
                    Constant := true,
                    &Static := true,
                    Visibility := CGMemberVisibilityKind.Public,
                    Initializer := if assigned(TargetNamespaceName) then TargetNamespaceName.AsLiteralExpression));

  for lentity: RodlEntity in &library.EventSinks.Items.Sort_OrdinalIgnoreCase(b->b.Name) do begin
    if not EntityNeedsCodeGen(lentity) then Continue;
    var lName := lentity.Name;
    ltype.Members.Add(new CGFieldDefinition(String.Format("EID_{0}",[lName]), ResolveStdtypes(CGPredefinedTypeKind.String),
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

method JavaRodlCodeGen.isPrimitive(&type: String): Boolean;
begin
  result := not CodeGenTypes.ContainsKey(&type.ToLowerInvariant);
  if result then begin
    var k := CodeGenTypes[&type.ToLowerInvariant];
    result := (k is CGPredefinedTypeReference) and
              (CodeGenTypes[&type.ToLowerInvariant].Nullability <> CGTypeNullabilityKind.NullableNotUnwrapped);
  end;
end;

end.