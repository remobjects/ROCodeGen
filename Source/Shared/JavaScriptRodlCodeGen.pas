namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
{.$DEFINE ROSERVICE_ANCESTOR}
{$DEFINE TS_SIMPLE_DECLARATIONS}

interface

type
  JavaScriptRodlCodeGen = public class(RodlCodeGen)
  private
    fKnownTypes: Dictionary<String, String> := new Dictionary<String, String>;
    property IsJavaScript: Boolean read -> ((Generator is CGJavaScriptCodeGenerator) and CGJavaScriptCodeGenerator(Generator).IsStandard);
    property IsTypeScript: Boolean read -> ((Generator is CGJavaScriptCodeGenerator) and CGJavaScriptCodeGenerator(Generator).IsTypeScript);
    method _FixDataType(aValue: String): String;
    method ResolveDataTypeToTypeRef(aFile: CGCodeUnit; aLibrary: RodlLibrary; aDataType: String; aOrigType: String := nil; aUseNameSpace: Boolean := true): CGTypeReference;

    method GetStandardAncestor(aEntity: RodlEntity): String;
    method GetAncestorType(aFile: CGCodeUnit; aEntity: RodlEntity; aUseNameSpace: Boolean := true): CGNamedTypeReference;
    method SetPrototype(aPropotype: CGPropertyAccessExpression; aEntity: RodlEntity): CGAssignmentStatement;
    method GenerateMessageRead(aMessage: CGExpression; aEntity: RodlTypedEntity): CGExpression;
    method Intf_ToObject(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; aCallHost: CGExpression; aUseStoreType: Boolean := true): CGExpression;
    method Intf_FromObject(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; aCallSite: CGExpression; aLeft: CGExpression): List<CGStatement>;

    method CheckForNodeJS(): CGExpression;
    method Create_Record_String_any_typeref: CGTypeReference;
    {$REGION .d.ts}
    method GenerateRodlStructEntity_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStructEntity);
    method GenerateEnum_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
    method GenerateStruct_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
    method GenerateArray_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
    method GenerateException_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
    method GenerateService_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
    method GenerateEventSink_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
    method GenerateMapUnit(aLibrary: RodlLibrary; aTargetNamespace: String): CGCodeUnit;
    {$ENDREGION}
    method GetLocalNameSpaceVarName(aFile: CGCodeUnit): String;
    method GetNameSpaceVar(aFile: CGCodeUnit): CGLocalVariableAccessExpression;
  protected
    method GetGlobalName(aLibrary: RodlLibrary): String; override; empty;
    method AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary); override;
    method GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum); override;
    method GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct); override;
    method GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray); override;
    method GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException); override;
    method GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService); override;
    method GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink); override;
    method DoGenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
  public
    constructor;
    method GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>; override;
  end;

implementation

method JavaScriptRodlCodeGen._FixDataType(aValue: String): String;
begin
  var l_lower := aValue.ToLowerInvariant;
  if fKnownTypes.ContainsKey(l_lower) then
    exit fKnownTypes[l_lower]
  else
    exit aValue;
end;

constructor JavaScriptRodlCodeGen;
begin
  var l_decimal := new CGArrayTypeReference(CGPredefinedTypeReference.Int32,[new CGArrayBounds(0) &end(5)]);
  var l_datetime := "Date".AsTypeReference;
  var l_currency := "number".AsTypeReference;

  CodeGenTypes.Add("integer",         CGPredefinedTypeReference.Int32);
  CodeGenTypes.Add("datetime",        l_datetime.NotNullable);
  CodeGenTypes.Add("double",          CGPredefinedTypeReference.Double);
  CodeGenTypes.Add("currency",        l_currency.NotNullable);
  CodeGenTypes.Add("widestring",      CGPredefinedTypeReference.String);
  CodeGenTypes.Add("ansistring",      CGPredefinedTypeReference.String);
  CodeGenTypes.Add("int64",           CGPredefinedTypeReference.Int64);
  CodeGenTypes.Add("boolean",         CGPredefinedTypeReference.Boolean);
  CodeGenTypes.Add("variant",         CGPredefinedTypeReference.Dynamic);
  CodeGenTypes.Add("binary",          CGPredefinedTypeReference.String);
  CodeGenTypes.Add("xml",             CGPredefinedTypeReference.String);
  CodeGenTypes.Add("guid",            CGPredefinedTypeReference.String);
  CodeGenTypes.Add("decimal",         l_decimal);
  CodeGenTypes.Add("utf8string",      CGPredefinedTypeReference.String);
  CodeGenTypes.Add("xsdatetime",      "RemObjects.SDK.Types.XsDateTime".AsTypeReference_Nullable);
  CodeGenTypes.Add("nullableinteger", CGPredefinedTypeReference.Int32.NullableUnwrapped);
  CodeGenTypes.Add("nullabledatetime",l_datetime.NullableUnwrapped);
  CodeGenTypes.Add("nullabledouble",  CGPredefinedTypeReference.Double.NullableUnwrapped);
  CodeGenTypes.Add("nullablecurrency",l_currency.NullableUnwrapped);
  CodeGenTypes.Add("nullableint64",   CGPredefinedTypeReference.Int64.NullableUnwrapped);
  CodeGenTypes.Add("nullableboolean", CGPredefinedTypeReference.Boolean.NullableUnwrapped);
  CodeGenTypes.Add("nullableguid",    CGPredefinedTypeReference.String.NullableUnwrapped);
  CodeGenTypes.Add("nullabledecimal", l_decimal.NullableUnwrapped);


  fKnownTypes.Add("integer", "Integer");
  fKnownTypes.Add("datetime", "DateTime");
  fKnownTypes.Add("double", "Double");
  fKnownTypes.Add("currency", "Currency");
  fKnownTypes.Add("widestring", "WideString");
  fKnownTypes.Add("ansistring", "AnsiString");
  fKnownTypes.Add("int64", "Int64");
  fKnownTypes.Add("boolean", "Boolean");
  fKnownTypes.Add("variant", "Variant");
  fKnownTypes.Add("binary", "Binary");
  fKnownTypes.Add("xml", "Xml");
  fKnownTypes.Add("guid", "Guid");
  fKnownTypes.Add("decimal", "Decimal");
  fKnownTypes.Add("utf8string", "Utf8String");
  fKnownTypes.Add("xsdatetime", "XsDateTime");

  ReservedWords.Add("boolean");
  ReservedWords.Add("break");
  ReservedWords.Add("byte");
  ReservedWords.Add("case");
  ReservedWords.Add("catch");
  ReservedWords.Add("char");
  ReservedWords.Add("continue");
  ReservedWords.Add("default");
  ReservedWords.Add("delete");
  ReservedWords.Add("do");
  ReservedWords.Add("double");
  ReservedWords.Add("else");
  ReservedWords.Add("false");
  ReservedWords.Add("final");
  ReservedWords.Add("finally");
  ReservedWords.Add("float");
  ReservedWords.Add("for");
  ReservedWords.Add("function");
  ReservedWords.Add("if");
  ReservedWords.Add("in");
  ReservedWords.Add("instanceof");
  ReservedWords.Add("int");
  ReservedWords.Add("long");
  ReservedWords.Add("new");
  ReservedWords.Add("null");
  ReservedWords.Add("return");
  ReservedWords.Add("short");
  ReservedWords.Add("switch");
  ReservedWords.Add("this");
  ReservedWords.Add("throw");
  ReservedWords.Add("true");
  ReservedWords.Add("try");
  ReservedWords.Add("typeof");
  ReservedWords.Add("var");
  ReservedWords.Add("void");
  ReservedWords.Add("while");
  ReservedWords.Add("with");
end;

method JavaScriptRodlCodeGen.GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := GetNameSpaceVar(aFile);

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Event sink: {l_name}"));
  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity),
                                          Visibility := CGTypeVisibilityKind.Public);

  var l_ctor := new CGConstructorDefinition();
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));




  for each op in aEntity.DefaultInterface.Items do begin
    var l_method_p :=new List<CGCallParameter>;
    for each &param in op.Items do begin
      var l_params := new List<CGCallParameter>;
      l_params.Add(new CGCallParameter(_FixDataType(&param.DataType).AsLiteralExpression, "dataType"));
      l_params.Add(new CGCallParameter(CGNilExpression.Nil, "value"));
      l_method_p.Add(new CGCallParameter(
                        new CGNewInstanceExpression(CGNilExpression.Nil, l_params),
                        &param.Name));
    end;
    l_ctor.Statements.Add(new CGAssignmentStatement(
                            new CGPropertyAccessExpression(CGSelfExpression.Self, op.Name),
                            new CGNewInstanceExpression(CGNilExpression.Nil, l_method_p)));
  end;
  l_type.Members.Add(l_ctor);


  var param_aName := new CGParameterDefinition("aName", CGPredefinedTypeReference.String);
  {$REGION readEvent}
  var param_aMessage := new CGParameterDefinition("aMessage", "RemObjects.SDK.Message".AsTypeReference);
  var l_m := new CGMethodDefinition("readEvent",
                                    Parameters := [param_aMessage, param_aName].ToList,
                                    Visibility := CGMemberVisibilityKind.Public);
  var l_cases := new List<CGSwitchStatementCase>;
  for each op in aEntity.DefaultInterface.Items do begin
    var l_list := new List<CGStatement>;
    var l_event := new CGPropertyAccessExpression(CGSelfExpression.Self, op.Name);
    for each &param in op.Items do begin
      l_list.Add(new CGAssignmentStatement(
                  new CGPropertyAccessExpression(new CGPropertyAccessExpression(l_event, &param.Name),"value"),
                  GenerateMessageRead(param_aMessage.AsExpression, &param)
        ));
    end;
    l_list.Add(new CGBreakStatement());
    l_cases.Add(new CGSwitchStatementCase(op.Name.AsLiteralExpression, l_list));
  end;

  l_m.Statements.Add(new CGSwitchStatement(param_aName.AsExpression, l_cases));
  l_type.Members.Add(l_m);
  {$ENDREGION}

  {$REGION toObject}
  l_m := new CGMethodDefinition("toObject",
                                Parameters := [param_aName].ToList,
                                ReturnType := Create_Record_String_any_typeref,
                                Visibility := CGMemberVisibilityKind.Public);


  var var_result := new CGVariableDeclarationStatement("result", nil, new CGNewInstanceExpression(CGNilExpression.Nil));
  l_m.Statements.Add(var_result);
  l_cases := new List<CGSwitchStatementCase>;

  for each op in aEntity.DefaultInterface.Items do begin
    var l_list := new List<CGStatement>;
    var l_event := new CGPropertyAccessExpression(CGSelfExpression.Self, op.Name);
    for each &param in op.Items do begin
      l_list.Add(new CGAssignmentStatement(
                  new CGPropertyAccessExpression(var_result.AsExpression, &param.Name),
                  Intf_ToObject(aLibrary,  &param, l_event, false)
        ));
    end;
    l_list.Add(new CGBreakStatement());
    l_cases.Add(new CGSwitchStatementCase(op.Name.AsLiteralExpression, l_list));
  end;
  l_m.Statements.Add(new CGSwitchStatement(param_aName.AsExpression, l_cases));


  l_m.Statements.Add(var_result.AsExpression.AsReturnStatement);

  l_type.Members.Add(l_m);
  {$ENDREGION}

  l_init.Add(new CGLocalTypeDeclarationStatement(l_type));
  l_init.Add(new CGAssignmentStatement(l_namespace_name, l_name.AsNamedIdentifierExpression));
  l_init.Add(new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
              l_name.AsNamedIdentifierExpression
            ));
end;

method JavaScriptRodlCodeGen.GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := GetNameSpaceVar(aFile);

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Service: {l_name}"));
  var l_serviceName := new CGPropertyAccessExpression(CGSelfExpression.Self, "fServiceName");


  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity),
                                          Visibility := CGTypeVisibilityKind.Public);
  l_type.Members.Add(new CGPropertyDefinition("ServiceName",
                                              GetExpression := aEntity.Name.AsLiteralExpression,
                                              &Static := true,
                                              Visibility := CGMemberVisibilityKind.Public));
  var param__message := new CGParameterDefinition("__message",
                                                  new CGUnionTypeReference(["RemObjects.SDK.Message".AsTypeReference,
                                                                            "undefined".AsTypeReference].ToList),
                                                  DefaultValue := "undefined".AsNamedIdentifierExpression);

/*
  var param__channel := new CGParameterDefinition("__channel",
                                                  new CGUnionTypeReference(["RemObjects.SDK.ClientChannel".AsTypeReference,
                                                                            "RemObjects.SDK.RemoteService".AsTypeReference,
                                                                            CGPredefinedTypeReference.String as CGTypeReference
                                                                            ].ToList));
  var param__service_name :=  new CGParameterDefinition("__service_name",
                                                        new CGUnionTypeReference([CGPredefinedTypeReference.String as CGTypeReference,
                                                                                  "undefined".AsTypeReference].ToList),
                                                        DefaultValue := "undefined".AsNamedIdentifierExpression);
  var l_ctor := new CGConstructorDefinition(Parameters := [param__channel, param__message, param__service_name].ToList);
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,
                                                       [param__channel.AsCallParameter,
                                                        param__message.AsCallParameter,
                                                        param__service_name.AsCallParameter]));
  l_ctor.Statements.Add(new CGAssignmentStatement(l_serviceName,
                        new CGBinaryOperatorExpression(
                          new CGBinaryOperatorExpression(
                            l_serviceName,
                            param__service_name.AsExpression,
                            CGBinaryOperatorKind.LogicalOr
                          ),
                          aEntity.Name.AsLiteralExpression,
                          CGBinaryOperatorKind.LogicalOr
                        )));

  l_type.Members.Add(l_ctor);
  */
  //aFile.Types.Add(l_type);

  {$REGION methods}
  for each op in aEntity.DefaultInterface.Items do begin
    var l_m := new CGMethodDefinition(SafeIdentifier(op.Name),
                                      Visibility := CGMemberVisibilityKind.Public);

    var l_success := new CGBlockTypeDefinition("", IsPlainFunctionPointer := true );
    var l_error := new CGBlockTypeDefinition("", IsPlainFunctionPointer := true);
    l_error.Parameters.Add(new CGParameterDefinition("msg", "RemObjects.SDK.Message".AsTypeReference));
    l_error.Parameters.Add(new CGParameterDefinition("error", "unknown".AsTypeReference));


    var param__success := new CGParameterDefinition("__success", new CGInlineBlockTypeReference(l_success));
    var param__error := new CGParameterDefinition("__error", new CGInlineBlockTypeReference(l_error));

    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) do
      l_m.Parameters.Add(new CGParameterDefinition(SafeIdentifier(&param.Name),
                                                  ResolveDataTypeToTypeRef(aFile, aLibrary, &param.DataType)));


    l_m.Parameters.Add(param__success);
    l_m.Parameters.Add(param__error);
    var l_try := new List<CGStatement>;
    var localvar_msg := new CGVariableDeclarationStatement("msg",
                                                            "RemObjects.SDK.Message".AsTypeReference,
                                                            new CGMethodCallExpression(
                                                              new CGMethodCallExpression(CGSelfExpression.Self, "getMessage"),
                                                              "clone"
                                                            ),
                                                            Constant := true);
   // l_try.Add(localvar_msg);
    var l_msg := localvar_msg.AsExpression;
    var l_st: CGStatement := new CGMethodCallExpression(l_msg, "initialize",
                                       [l_serviceName.AsCallParameter,
                                        SafeIdentifier(op.Name).AsLiteralExpression.AsCallParameter]);
    l_try.Add(l_st);
    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) do begin
      var l_datatype: CGExpression :=
        //if isArray(aLibrary, &param.DataType) then
          //&param.DataType.AsLiteralExpression
        //else
        if isStruct(aLibrary, &param.DataType)  then
          new CGMethodCallExpression("RemObjects.UTIL".AsNamedIdentifierExpression,
                                      "ROGetType",
                                      [new CGParameterAccessExpression(&param.Name).AsCallParameter])
          //new CGMethodCallExpression(new CGParameterAccessExpression(&param.Name),"__getType")
        else
          _FixDataType(&param.DataType).AsLiteralExpression;
      l_st := new CGMethodCallExpression(l_msg, "write",
                                         [&param.Name.AsLiteralExpression.AsCallParameter,
                                          l_datatype.AsCallParameter,
                                          new CGParameterAccessExpression(&param.Name).AsCallParameter ]);
      l_try.Add(l_st);
    end;
    l_st := new CGMethodCallExpression(l_msg, "finalize");
    l_try.Add(l_st);

    var l_methodst := new List<CGStatement>;
    var l_message := param__message.AsExpression;
    var localvar__result: CGVariableDeclarationStatement;
    if assigned(op.Result) then begin
      localvar__result := new CGVariableDeclarationStatement("__result",
                                                             nil,
                                                             GenerateMessageRead(l_message,op.Result),
                                                             Constant := true);
      l_methodst.Add(localvar__result);
      l_success.Parameters.Add(new CGParameterDefinition("result", ResolveDataTypeToTypeRef(aFile, aLibrary, op.Result.DataType)));
    end;
    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) do begin
      l_st := new CGVariableDeclarationStatement($"__{SafeIdentifier(&param.Name)}",
                                                 nil,
                                                 GenerateMessageRead(l_message,&param),
                                                 Constant := true);
      l_methodst.Add(l_st);
      l_success.Parameters.Add(new CGParameterDefinition(&param.Name, ResolveDataTypeToTypeRef(aFile, aLibrary, &param.DataType)));
    end;

    var l_params1 := new List<CGCallParameter>;
    if assigned(op.Result) then
      l_params1.Add(localvar__result.AsCallParameter);

    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) do
      l_params1.Add(new CGParameterAccessExpression($"__{SafeIdentifier(&param.Name)}").AsCallParameter);

    l_methodst.Add(new CGMethodCallExpression(nil, param__success.Name, l_params1));
    var l_func := new CGAnonymousMethodExpression([new CGParameterDefinition("__message", "RemObjects.SDK.Message".AsTypeReference)].ToList,
                                                  l_methodst);
    l_st := new CGMethodCallExpression(new CGMethodCallExpression(CGSelfExpression.Self, "getChannel"), "dispatch",
                                       [l_msg.AsCallParameter,
                                       l_func.AsCallParameter,
                                       param__error.AsCallParameter]);
    l_try.Add(l_st);

    var l_catch := new CGCatchBlockStatement("e");

    l_catch.Statements.Add(new CGMethodCallExpression(nil, param__error.Name,
                                                      [l_msg.AsCallParameter,
                                                       new CGLocalVariableAccessExpression(l_catch.Name).AsCallParameter]));
    var l_trycatch := new CGTryFinallyCatchStatement(l_try);
    l_trycatch.CatchBlocks.Add(l_catch);

    l_m.Statements.Add(localvar_msg);
    l_m.Statements.Add(l_trycatch);
    l_type.Members.Add(l_m);
  end;
  {$ENDREGION}

  l_init.Add(new CGLocalTypeDeclarationStatement(l_type));
  l_init.Add(new CGAssignmentStatement(l_namespace_name, l_name.AsNamedIdentifierExpression));
end;

method JavaScriptRodlCodeGen.GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := GetNameSpaceVar(aFile);

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Exception: {l_name}"));
  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity),
                                          Visibility := CGTypeVisibilityKind.Public);
  {$REGION .ctor}
  var l_e_param := new CGParameterDefinition("e", "Error".AsTypeReference.NullableUnwrapped);
  var l_ctor := new CGConstructorDefinition(Parameters := [l_e_param].ToList);
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited,[l_e_param.AsCallParameter]));

  var l_null_value := new CGCallParameter(CGNilExpression.Nil, "value");
  for each item in aEntity.Items.OrderBy(b->b.Name) do begin
    var l_value := l_null_value;


    // if type is enum and is from current library => create new instance of enum type
    var x:= aLibrary.FindEntity(item.DataType);
    if (x is RodlEnum) and not x.IsFromUsedRodl then begin
      l_value := new CGCallParameter(new CGNewInstanceExpression(x.Name.AsNamedIdentifierExpression), "value");
    end;

    l_ctor.Statements.Add(new CGAssignmentStatement(
                          new CGPropertyAccessExpression(CGSelfExpression.Self, SafeIdentifier(item.Name)),
                          new CGNewInstanceExpression(CGNilExpression.Nil,
                                                      [new CGCallParameter(_FixDataType(item.DataType).AsLiteralExpression, "dataType"),
                                                       l_value])));
  end;

  l_type.Members.Add(l_ctor);
  {$ENDREGION}
  var param_aMessage := new CGParameterDefinition("aMessage", "RemObjects.SDK.Message".AsTypeReference);
  {$REGION readFrom}
  var l_m := new CGMethodDefinition("readFrom",
                                    Parameters := [param_aMessage].ToList,
                                    Visibility := CGMemberVisibilityKind.Public);


  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add( new CGAssignmentStatement(
                        new CGPropertyAccessExpression(new CGFieldAccessExpression(CGSelfExpression.Self,item.Name), "value"),
                        GenerateMessageRead(param_aMessage.AsExpression, item)));
  end;
  l_type.Members.Add(l_m);
  {$ENDREGION}

  {$REGION writeTo}
  l_m := new CGMethodDefinition("writeTo",
                                Parameters := [param_aMessage].ToList,
                                Visibility := CGMemberVisibilityKind.Public);
  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add(new CGMethodCallExpression(param_aMessage.AsExpression,
                                                  "write",
                                                  [item.Name.AsLiteralExpression.AsCallParameter,
                                                  _FixDataType(item.DataType).AsLiteralExpression.AsCallParameter,
                                                  new CGPropertyAccessExpression(
                                                    new CGFieldAccessExpression(CGSelfExpression.Self,item.Name), "value").AsCallParameter]
                                                  ));
  end;

  l_type.Members.Add(l_m);
  {$ENDREGION}

  {$REGION toObject}
  var param_aStoreType := new CGParameterDefinition("aStoreType", CGPredefinedTypeReference.Boolean /*, DefaultValue := CGBooleanLiteralExpression.False*/);
  l_m := new CGMethodDefinition("toObject",
                                Parameters := [param_aStoreType].ToList,
                                ReturnType := Create_Record_String_any_typeref,
                                Visibility := CGMemberVisibilityKind.Public);


  var var_result := new CGVariableDeclarationStatement("result",
                                                        nil,
                                                        new CGNewInstanceExpression(CGNilExpression.Nil),
                                                        Constant := true);
  l_m.Statements.Add(var_result);
  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add( new CGAssignmentStatement(
                        new CGPropertyAccessExpression(var_result.AsExpression,item.Name),
                        Intf_ToObject(aLibrary, item, CGSelfExpression.Self)));

  end;
  l_m.Statements.Add(new CGIfThenElseStatement(param_aStoreType.AsExpression,
                                                new CGAssignmentStatement(
                                                  new CGPropertyAccessExpression(var_result.AsExpression,"__type"),
                                                  l_name.AsLiteralExpression)));

  l_m.Statements.Add(var_result.AsExpression.AsReturnStatement);

  l_type.Members.Add(l_m);
  {$ENDREGION}

  {$REGION fromObject}
  var param_aValue := new CGParameterDefinition("aValue", Create_Record_String_any_typeref);
  l_m := new CGMethodDefinition("fromObject",
                                Parameters := [param_aValue].ToList,
                                ReturnType := l_type.Name.AsTypeReference,
                                Visibility := CGMemberVisibilityKind.Public);


  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add(
        Intf_FromObject(aLibrary,
                        item,
                        param_aValue.AsExpression,
                        new CGPropertyAccessExpression( new CGPropertyAccessExpression(
                                                          CGSelfExpression.Self,
                                                          item.Name),
                                                        "value")));
  end;

  l_m.Statements.Add(CGSelfExpression.Self.AsReturnStatement);
  l_type.Members.Add(l_m);
  {$ENDREGION}

  l_init.Add(new CGLocalTypeDeclarationStatement(l_type));
  // registration
  l_init.Add(new CGAssignmentStatement(l_namespace_name, l_name.AsNamedIdentifierExpression));
  l_init.Add(new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
              l_name.AsNamedIdentifierExpression
            ));
end;

method JavaScriptRodlCodeGen.GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := GetNameSpaceVar(aFile);

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Array: {l_name}"));

  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity),
                                          Visibility := CGTypeVisibilityKind.Public);

  var l_ctor := new CGConstructorDefinition();
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));
  l_ctor.Statements.Add(new CGAssignmentStatement(
                                new CGPropertyAccessExpression(CGSelfExpression.Self, "elementType"),
                                aEntity.ElementType.AsLiteralExpression));
  l_ctor.Statements.Add(new CGAssignmentStatement(
                                new CGPropertyAccessExpression(CGSelfExpression.Self, "items"),
                                new CGArrayLiteralExpression()));
  l_type.Members.Add(l_ctor);
  //aFile.Types.Add(l_type);
  l_init.Add(new CGLocalTypeDeclarationStatement(l_type));

  l_init.Add(new CGAssignmentStatement(l_namespace_name, l_name.AsNamedIdentifierExpression));
  l_init.Add(new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
              l_name.AsNamedIdentifierExpression
            ));
end;


method JavaScriptRodlCodeGen.GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := GetNameSpaceVar(aFile);

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Struct: {l_name}"));
  var param_aMessage := new CGParameterDefinition("aMessage", "RemObjects.SDK.Message".AsTypeReference);
  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity),
                                          Visibility := CGTypeVisibilityKind.Public);
  {$REGION .ctor}
  var l_ctor := new CGConstructorDefinition();
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));

  var l_null_value := new CGCallParameter(CGNilExpression.Nil, "value");
  for each item in aEntity.Items.OrderBy(b->b.Name) do begin
    var l_value := l_null_value;


    // if type is enum and is from current library => create new instance of enum type
    var x:= aLibrary.FindEntity(item.DataType);
    if (x is RodlEnum) and not x.IsFromUsedRodl then begin
      l_value := new CGCallParameter(new CGNewInstanceExpression(x.Name.AsNamedIdentifierExpression), "value");
    end;

    l_ctor.Statements.Add(new CGAssignmentStatement(
                          new CGPropertyAccessExpression(CGSelfExpression.Self, SafeIdentifier(item.Name)),
                          new CGNewInstanceExpression(CGNilExpression.Nil,
                                                      [new CGCallParameter(_FixDataType(item.DataType).AsLiteralExpression, "dataType"),
                                                       l_value])));
  end;

  l_type.Members.Add(l_ctor);
  {$ENDREGION}
  {$REGION readFrom}
  var l_m := new CGMethodDefinition("readFrom",
                                    Parameters := [param_aMessage].ToList,
                                    Visibility := CGMemberVisibilityKind.Public);


  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add( new CGAssignmentStatement(
                        new CGPropertyAccessExpression(new CGFieldAccessExpression(CGSelfExpression.Self,item.Name), "value"),
                        GenerateMessageRead(param_aMessage.AsExpression, item)
                      ));
  end;
  l_type.Members.Add(l_m);
  {$ENDREGION}

  {$REGION writeTo}
  l_m := new CGMethodDefinition("writeTo",
                                Parameters := [param_aMessage].ToList,
                                Visibility := CGMemberVisibilityKind.Public);
  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add(new CGMethodCallExpression(param_aMessage.AsExpression,
                                                  "write",
                                                  [item.Name.AsLiteralExpression.AsCallParameter,
                                                  _FixDataType(item.DataType).AsLiteralExpression.AsCallParameter,
                                                  new CGPropertyAccessExpression(
                                                    new CGFieldAccessExpression(CGSelfExpression.Self,item.Name), "value").AsCallParameter]
                                                  ));
  end;

  l_type.Members.Add(l_m);
  {$ENDREGION}

  {$REGION toObject}
  var param_aStoreType := new CGParameterDefinition("aStoreType", CGPredefinedTypeReference.Boolean /*, DefaultValue := CGBooleanLiteralExpression.False*/);
  l_m := new CGMethodDefinition("toObject",
                                Parameters := [param_aStoreType].ToList,
                                ReturnType := Create_Record_String_any_typeref,
                                Visibility := CGMemberVisibilityKind.Public);


  var var_result := new CGVariableDeclarationStatement("result",
                                                        nil,
                                                        new CGNewInstanceExpression(CGNilExpression.Nil),
                                                        &Constant := true);
  l_m.Statements.Add(var_result);
  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add( new CGAssignmentStatement(
                        new CGPropertyAccessExpression(var_result.AsExpression,item.Name),
                        Intf_ToObject(aLibrary, item, CGSelfExpression.Self)));
  end;
  l_m.Statements.Add(new CGIfThenElseStatement(param_aStoreType.AsExpression,
                                                new CGAssignmentStatement(
                                                  new CGPropertyAccessExpression(var_result.AsExpression,"__type"),
                                                  l_name.AsLiteralExpression)));

  l_m.Statements.Add(var_result.AsExpression.AsReturnStatement);

  l_type.Members.Add(l_m);
  {$ENDREGION}
  {$REGION fromObject}
  var param_aValue := new CGParameterDefinition("aValue", Create_Record_String_any_typeref);
  l_m := new CGMethodDefinition("fromObject",
                                Parameters := [param_aValue].ToList,
                                ReturnType := l_type.Name.AsTypeReference,
                                Visibility := CGMemberVisibilityKind.Public);


  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do begin
    l_m.Statements.Add(Intf_FromObject( aLibrary,
                                        item,
                                        param_aValue.AsExpression,
                                        new CGPropertyAccessExpression(
                                                    new CGPropertyAccessExpression(CGSelfExpression.Self,
                                                                                    item.Name),
                                                    "value")));
  end;

  l_m.Statements.Add(CGSelfExpression.Self.AsReturnStatement);
  l_type.Members.Add(l_m);
  {$ENDREGION}


  l_init.Add(new CGLocalTypeDeclarationStatement(l_type));
  // registration
  l_init.Add(new CGAssignmentStatement(l_namespace_name, l_name.AsNamedIdentifierExpression));
  l_init.Add(new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
              l_name.AsNamedIdentifierExpression
            ));
end;


method JavaScriptRodlCodeGen.GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := GetNameSpaceVar(aFile);
  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Enum: {l_name}"));

  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity),
                                          Visibility := CGTypeVisibilityKind.Public);

  var l_ctor := new CGConstructorDefinition();
  l_ctor.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited));
  l_ctor.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(CGSelfExpression.Self,"value"),CGNilExpression.Nil));

  var l_array := new CGArrayLiteralExpression([]);
  for each item in aEntity.Items do
    l_array.Elements.Add(item.Name.AsLiteralExpression);
  l_ctor.Statements.Add(new CGAssignmentStatement(
                          new CGPropertyAccessExpression(CGSelfExpression.Self, "enumValues"),
                          l_array
                        ));
  l_type.Members.Add(l_ctor);
  //aFile.Types.Add(l_type);
  l_init.Add(new CGLocalTypeDeclarationStatement(l_type));

  l_init.Add(new CGAssignmentStatement(l_namespace_name, l_name.AsNamedIdentifierExpression));
  l_init.Add(new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
              l_name.AsNamedIdentifierExpression
            ));
end;


method JavaScriptRodlCodeGen.AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  aFile.Initialization := new List<not nullable CGStatement>;
  var l_init := aFile.Initialization;

  var l_comment := new List<String>;
  l_comment.Add("This codegen depends on RemObjectsSDK.js");
  l_comment.Add("Usage:");
  l_comment.Add("var Channel = new RemObjects.SDK.HTTPClientChannel(""http://localhost:8099/JSON"");");
  l_comment.Add("var Message = new RemObjects.SDK.JSONMessage();");
  l_comment.Add("var Service = new NewService(Channel, Message);");
  l_comment.Add("Service.Sum(1, 2,");
  l_comment.Add("            function(result) {");
  l_comment.Add("                alert(result);");
  l_comment.Add("            },");
  l_comment.Add("            function(msg, error) {alert(msg.getErrorMessage())}");
  l_comment.Add(");");


  l_init.Add(new CGCommentStatement(l_comment));

  l_init.Add(new CGEmptyStatement());




  /*
  if (typeof globalThis !== "undefined") {
    var current = globalThis;
  } else if (typeof window !== "undefined") {
    var current = window;
  } else {
    var current = this;
  }
  */

  l_init.Add(
    new CGIfThenElseStatement(
      // condition1
      new CGBinaryOperatorExpression(
        new CGTypeOfExpression("globalThis".AsNamedIdentifierExpression),
        "undefined".AsLiteralExpression,
        CGBinaryOperatorKind.StrictNotEquals),
      // if1
      new CGVariableDeclarationStatement(
        "current",
        CGPredefinedTypeReference.Dynamic,
        "globalThis".AsNamedIdentifierExpression),
      //else1
      new CGIfThenElseStatement(
        // condition2
        new CGBinaryOperatorExpression(
          new CGTypeOfExpression("window".AsNamedIdentifierExpression),
          "undefined".AsLiteralExpression,
          CGBinaryOperatorKind.StrictNotEquals),
        // if2
        new CGVariableDeclarationStatement(
          "current",
          CGPredefinedTypeReference.Dynamic,
          "window".AsNamedIdentifierExpression),
        // else2
        new CGVariableDeclarationStatement(
          "current",
          CGPredefinedTypeReference.Dynamic,
          CGSelfExpression.Self)
      )
    ));


  var l_current := new CGLocalVariableAccessExpression("current");
  var localvar__namespace := new CGVariableDeclarationStatement(GetLocalNameSpaceVarName(aFile),
                                                                Create_Record_String_any_typeref,
                                                                l_current,
                                                                Constant := true);


  var l_ifthen :=  new CGBeginEndBlockStatement();


  /*
  var localvar_parts := new CGVariableDeclarationStatement(
                            "parts",
                            new CGArrayTypeReference(CGPredefinedTypeReference.String),
                            new CGMethodCallExpression(l_namespace_le, "split", [".".AsLiteralExpression.AsCallParameter]),
                            Constant := true
                          );

  var l_parts := localvar_parts.AsExpression;



  var l_ifthen :=  new CGBeginEndBlockStatement();
  l_ifthen.Statements.Add(localvar_parts);
  l_ifthen.Statements.Add(localvar_current);


  var loop_var: String := "i";

  var l_for := new CGBeginEndBlockStatement();

  var l_item := new CGArrayElementAccessExpression(l_current,
                    [new CGArrayElementAccessExpression(l_parts,
                        [new CGLocalVariableAccessExpression(loop_var)])]);
  var l_st: CGStatement;
  l_st := new CGAssignmentStatement(
            l_item,
            new CGBinaryOperatorExpression(
              l_item,
              new CGNewInstanceExpression(CGNilExpression.Nil),
              CGBinaryOperatorKind.LogicalOr)
          );
  l_for.Statements.Add(l_st);

  l_st := new CGAssignmentStatement(
            l_current,
            l_item);
  l_for.Statements.Add(l_st);

  l_st := new CGForToLoopStatement(loop_var,
                                  CGPredefinedTypeReference.Int32,
                                  0.AsLiteralExpression,
                                  new CGBinaryOperatorExpression(
                                  new CGPropertyAccessExpression(l_parts, "length"),
                                  1.AsLiteralExpression,
                                  CGBinaryOperatorKind.Subtraction),
                                  l_for);
  l_ifthen.Statements.Add(l_st);
*/

  var l_part: CGExpression := l_current;
  var l_empty := new CGNewInstanceExpression(CGNilExpression.Nil);
  for each ns in GetNamespace(aLibrary).Split(".") do begin
    var temp := new CGArrayElementAccessExpression(l_part, [ns.AsLiteralExpression]);
    l_ifthen.Statements.Add(
      new CGAssignmentStatement(temp,
                                new CGBinaryOperatorExpression(temp, l_empty, CGBinaryOperatorKind.LogicalOr))
      );
    l_part := temp;
  end;

  //var l_st := new CGAssignmentStatement(l_namespace, l_current);
  //l_ifthen.Statements.Add(l_st);
  //l_st := new CGAssignmentStatement(l_currnamespace_ne, l_current);
  //l_ifthen.Statements.Add(l_st);

  if not String.IsNullOrEmpty(GetNamespace(aLibrary)) then begin
    l_init.Add(l_ifthen.Statements);
    localvar__namespace.Value := l_part;
  end;
  l_init.Add(localvar__namespace);
end;

method JavaScriptRodlCodeGen.ResolveDataTypeToTypeRef(aFile: CGCodeUnit; aLibrary: RodlLibrary; aDataType: String; aOrigType: String := nil; aUseNameSpace: Boolean := true): CGTypeReference;
begin
  if String.IsNullOrEmpty(aOrigType) then aOrigType := aDataType;
  var lLower := aDataType.ToLowerInvariant();
  if CodeGenTypes.ContainsKey(lLower) then
    exit CodeGenTypes[lLower]
  else begin
    var lent := aLibrary.FindEntity(aOrigType);
    if lent <> nil then begin
      if lent.IsFromUsedRodl then begin
        if not String.IsNullOrWhiteSpace(lent.FromUsedRodl:Includes:JavaScriptModule) then begin
          if isEnum(aLibrary, aOrigType) then
            exit new CGNamedTypeReference(aDataType)
                                       &namespace(new CGNamespaceReference(lent.FromUsedRodl:Includes:JavaScriptModule))
                                       isClassType(false)

          else
            exit new CGNamedTypeReference(aDataType)
                           &namespace(new CGNamespaceReference(lent.FromUsedRodl:Includes:JavaScriptModule))
                           isClassType(true);
        end;
      end;
    end;
    var l_ns := if aUseNameSpace then
                  new CGNamespaceReference(GetLocalNameSpaceVarName(aFile))
                else
                  nil;

    if aUseNameSpace then
      exit new CGNamedTypeReference(aDataType)
                                    &Namespace(l_ns)
                                    isClassType(not isEnum(aLibrary, aOrigType))
    else
      exit new CGNamedTypeReference(aDataType)
                                    isClassType(not isEnum(aLibrary, aOrigType));

  end;
end;

method JavaScriptRodlCodeGen.SetPrototype(aPropotype: CGPropertyAccessExpression; aEntity: RodlEntity): CGAssignmentStatement;
begin
  var l_ancestor: CGTypeReference := nil;
  if (aEntity is RodlEntityWithAncestor) and assigned(RodlEntityWithAncestor(aEntity).AncestorEntity) then begin
    var lEntity := RodlEntityWithAncestor(aEntity);
    var l_AncestorNS := "";
    if (lEntity.AncestorEntity <> nil) then begin
      if (lEntity.AncestorEntity.IsFromUsedRodl) and not String.IsNullOrEmpty(lEntity.AncestorEntity.FromUsedRodl.Includes.JavaScriptModule) then
        l_AncestorNS := lEntity.AncestorEntity.FromUsedRodl.Includes.JavaScriptModule;
      if not String.IsNullOrEmpty(l_AncestorNS) then
        l_AncestorNS := l_AncestorNS.Replace(".", "_") + "__";
    end;
    l_ancestor := new CGNamedTypeReference(SafeIdentifier(lEntity.AncestorName)) &namespace(new CGNamespaceReference($"__{l_AncestorNS}namespace"))
  end
  else begin
    var l_type: String :=
      if aEntity is RodlEnum then "ROEnumType" else
      if aEntity is RodlStruct then "ROStructType" else
      if aEntity is RodlArray then "ROArrayType" else
      if aEntity is RodlException then "ROException" else
      if aEntity is RodlEventSink then "ROEventSink" else
      if aEntity is RodlService then "ROService" else
      nil;
    l_ancestor := new CGNamedTypeReference(l_type) &namespace(new CGNamespaceReference("RemObjects.SDK"));
  end;

  exit new CGAssignmentStatement(aPropotype, new CGNewInstanceExpression(l_ancestor));
end;

method JavaScriptRodlCodeGen.GetAncestorType(aFile: CGCodeUnit; aEntity: RodlEntity; aUseNameSpace: Boolean := true): CGNamedTypeReference;
begin
  if (aEntity is RodlEntityWithAncestor) and assigned(RodlEntityWithAncestor(aEntity).AncestorEntity) then begin
    var lEntity := RodlEntityWithAncestor(aEntity);
    var l_AncestorNS := "";
    if (lEntity.AncestorEntity <> nil) then begin
      if (lEntity.AncestorEntity.IsFromUsedRodl) and not String.IsNullOrEmpty(lEntity.AncestorEntity.FromUsedRodl.Includes:JavaScriptModule) then
        l_AncestorNS := lEntity.AncestorEntity.FromUsedRodl.Includes:JavaScriptModule;
      if aUseNameSpace and String.IsNullOrWhiteSpace(l_AncestorNS) then
        l_AncestorNS := GetLocalNameSpaceVarName(aFile);
    end;
    var l_ns := if {aUseNameSpace or } not String.IsNullOrWhiteSpace(l_AncestorNS) then
                  new CGNamespaceReference(l_AncestorNS)
                else
                  nil;

    if assigned(l_ns) then
      exit new CGNamedTypeReference(SafeIdentifier(lEntity.AncestorName))
                                    &Namespace(l_ns)
    else
      exit new CGNamedTypeReference(SafeIdentifier(lEntity.AncestorName));
  end
  else begin
    exit new CGNamedTypeReference(GetStandardAncestor(aEntity)) &namespace(new CGNamespaceReference("RemObjects.SDK"));
  end;
end;


method JavaScriptRodlCodeGen.GetStandardAncestor(aEntity: RodlEntity): String;
begin
  if aEntity is RodlEnum then exit "ROEnumType";
  if aEntity is RodlStruct then exit "ROStructType";
  if aEntity is RodlArray then exit "ROArrayType";
  if aEntity is RodlException then exit "ROException";
  if aEntity is RodlEventSink then exit "ROEventSink";
  if aEntity is RodlService then exit "ROService";
  raise new Exception("unknown type");
end;


method JavaScriptRodlCodeGen.Intf_ToObject(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; aCallHost: CGExpression; aUseStoreType: Boolean ): CGExpression;
begin
  var param_aStoreType := new CGParameterDefinition("aStoreType", CGPredefinedTypeReference.Boolean);
  var l_params := new List<CGCallParameter>;
  if aUseStoreType then
    l_params.Add(param_aStoreType.AsCallParameter);
  var l_value: CGExpression := new CGPropertyAccessExpression(
                                    new CGPropertyAccessExpression(aCallHost, aEntity.Name),
                                    "value");
  if isComplex(aLibrary, aEntity.DataType) or isEnum(aLibrary, aEntity.DataType) then begin
    l_value := new CGIfThenElseExpression(l_value,
                                          new CGMethodCallExpression(l_value, "toObject",l_params),
                                          CGNilExpression.Nil);
  end;
  exit l_value;
end;


method JavaScriptRodlCodeGen.GenerateMessageRead(aMessage: CGExpression; aEntity: RodlTypedEntity): CGExpression;
begin
  exit new CGMethodCallExpression(aMessage,
                                  "read",
                                  [ aEntity.Name.AsLiteralExpression.AsCallParameter,
                                    _FixDataType(aEntity.DataType).AsLiteralExpression.AsCallParameter]);
end;

method JavaScriptRodlCodeGen.CheckForNodeJS: CGExpression;
begin
  var process := new CGFieldAccessExpression(nil, "process");
  var process_versions := new CGFieldAccessExpression(process, "versions");
  var process_versions_node := new CGFieldAccessExpression(process_versions, "node");
  //var &require := new CGFieldAccessExpression(nil, "require");
  //var &global := new CGFieldAccessExpression(nil, "global");

  var part1 := new CGBinaryOperatorExpression(new CGTypeOfExpression(process), "object".AsLiteralExpression, CGBinaryOperatorKind.StrictEquals);
  var part2 := new CGBinaryOperatorExpression(process_versions, CGNilExpression.Nil, CGBinaryOperatorKind.NotEquals);
  var part3 := new CGBinaryOperatorExpression(process_versions_node, CGNilExpression.Nil, CGBinaryOperatorKind.NotEquals);
  //var part4 := new CGBinaryOperatorExpression(new CGTypeOfExpression(&require), "function".AsLiteralExpression, CGBinaryOperatorKind.StrictEquals);
  //var part5 := new CGBinaryOperatorExpression(new CGTypeOfExpression(&global), "object".AsLiteralExpression, CGBinaryOperatorKind.StrictEquals);

  var exp1 := new CGBinaryOperatorExpression(part1, part2, CGBinaryOperatorKind.LogicalAnd);
  //var exp2 := new CGBinaryOperatorExpression(part3, part4, CGBinaryOperatorKind.LogicalAnd);
  //var exp3 := new CGBinaryOperatorExpression(exp1, exp2, CGBinaryOperatorKind.LogicalAnd);
  //var exp4 := new CGBinaryOperatorExpression(exp3, part5, CGBinaryOperatorKind.LogicalAnd);

  var exp4 := new CGBinaryOperatorExpression(exp1, part3, CGBinaryOperatorKind.LogicalAnd);
  exit exp4;
end;

method JavaScriptRodlCodeGen.Create_Record_String_any_typeref: CGTypeReference;
begin
  exit new CGNamedTypeReference("Record",
                                GenericArguments :=
                                  [CGPredefinedTypeReference.String as CGTypeReference,
                                  "any".AsTypeReference].ToList);
end;

method JavaScriptRodlCodeGen.Intf_FromObject(aLibrary: RodlLibrary; aEntity: RodlTypedEntity; aCallSite: CGExpression; aLeft: CGExpression): List<CGStatement>;
begin
  var r := new List<CGStatement>;
  var aValue_item := new CGPropertyAccessExpression(aCallSite, aEntity.Name);
  var l_isComplex := isComplex(aLibrary, aEntity.DataType) or isEnum(aLibrary, aEntity.DataType);
  var lRight: CGExpression;
  if l_isComplex then begin
    var ltype: CGExpression := new CGArrayElementAccessExpression(
                                          (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
                                          aEntity.DataType.AsLiteralExpression);
    // if type is enum and is from current library
    var x:= aLibrary.FindEntity(aEntity.DataType);
    if (x is RodlEnum) and not x.IsFromUsedRodl then
      ltype := x.Name.AsNamedIdentifierExpression;

    lRight := new CGNewInstanceExpression(ltype);
  end
  else if aEntity.DataType.EqualsIgnoringCase("NullableDateTime") then begin
    lRight := new CGIfThenElseExpression(aValue_item,
                                      aValue_item,
                                      new CGMethodCallExpression(
                                        "RemObjects.UTIL".AsNamedIdentifierExpression,
                                        "ISO8601toDateTime",
                                        [aValue_item.AsCallParameter]
                                      ));
  end
  else if aEntity.DataType.EqualsIgnoringCase("DateTime") then begin
    lRight := new CGMethodCallExpression(
            "RemObjects.UTIL".AsNamedIdentifierExpression,
            "ISO8601toDateTime",
            [aValue_item.AsCallParameter]
          );
  end
  else begin
    lRight := aValue_item;
  end;

  r.Add(new CGAssignmentStatement(aLeft, lRight));
  if l_isComplex then
    r.Add(new CGIfThenElseStatement(aValue_item,
                                      new CGMethodCallExpression(
                                            aLeft,
                                            "fromObject",
                                            [aValue_item.AsCallParameter])));
  exit r;
end;

method JavaScriptRodlCodeGen.GenerateEnum_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var l_name := SafeIdentifier(aEntity.Name);
  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity, false),
                                          Visibility := CGTypeVisibilityKind.Public);
  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  {$REGION .ctor}
  l_type.Members.Add(new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}
  {$ENDIF}
  {$REGION value}
  var l_value_types := new List<CGTypeReference>;
  for each item in aEntity.Items do
    l_value_types.Add($"""{item.Name}""".AsTypeReference);
  l_value_types.Add("null".AsTypeReference);

  l_type.Members.Add(new CGFieldDefinition("value",
                                            new CGUnionTypeReference(l_value_types),
                                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION value}
  {$REGION enumValues}
  l_value_types := new List<CGTypeReference>;
  for each item in aEntity.Items do
    l_value_types.Add($"""{item.Name}""".AsTypeReference);
  l_type.Members.Add(new CGFieldDefinition("enumValues",
                                            new CGTupleTypeReference(l_value_types),
                                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION enumValues}
  aFile.Types.Add(l_type);
end;

method JavaScriptRodlCodeGen.GenerateStruct_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  GenerateRodlStructEntity_Map(aFile, aLibrary, aEntity);
end;

method JavaScriptRodlCodeGen.GenerateRodlStructEntity_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStructEntity);
begin
  var l_name := SafeIdentifier(aEntity.Name);
  var l_null_type := "null".AsTypeReference;

  var suffix := "Data";
  while aLibrary.FindEntity($"{l_name}{suffix}") <> nil do
    suffix := $"_{suffix}";

  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  var param_aMessage := new CGParameterDefinition("aMessage", "RemObjects.SDK.Message".AsTypeReference);
  var l_interface := new CGInterfaceTypeDefinition($"{l_name}{suffix}",
                                                   Visibility := CGTypeVisibilityKind.Public);
  {$REGION properties}
  for each item in aEntity.Items.OrderBy(b->b.Name) do begin
    var l_value_type := ResolveDataTypeToTypeRef(aFile, aLibrary, item.DataType, nil, false);
    l_interface.Members.Add(new CGFieldDefinition(item.Name,
                                                  new CGUnionTypeReference([l_value_type, l_null_type].ToList),
                                                  Visibility := CGMemberVisibilityKind.Public));
  end;

  {$ENDREGION}

  aFile.Types.Add(l_interface);
  {$ENDIF TS_SIMPLE_DECLARATIONS}
  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity, false),
                                          Visibility := CGTypeVisibilityKind.Public);
  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  {$REGION .ctor}
  var l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public);
  if aEntity is RodlException then begin
    l_ctor.Parameters.Add(new CGParameterDefinition("e",
                                                    "Error".AsTypeReference,
                                                    DefaultValue := "undefined".AsNamedIdentifierExpression));
  end;
  l_type.Members.Add(l_ctor);
  {$ENDREGION}
  {$ENDIF}

  {$REGION properties}
  for each item in aEntity.Items.OrderBy(b->b.Name) do begin
    var l_dataType_type := $'"{_FixDataType(item.DataType)}"'.AsTypeReference;

    var l_value_type := ResolveDataTypeToTypeRef(aFile, aLibrary, item.DataType, nil, false);

    // if type is enum and is from current library => create new instance of enum type
    var x:= aLibrary.FindEntity(item.DataType);
    if not (x is RodlEnum)  then begin
      l_value_type := new CGUnionTypeReference([l_value_type, l_null_type].ToList);
    end;

    l_type.Members.Add(
      new CGFieldDefinition(item.Name,
                            new CGInlineBlockTypeReference(
                              new CGBlockTypeDefinition("",
                                                        IsPlainFunctionPointer := false,
                                                        Parameters := [
                                                          new CGParameterDefinition("dataType", l_dataType_type),
                                                          new CGParameterDefinition("value", l_value_type)].ToList)),
                            Visibility := CGMemberVisibilityKind.Public));
  end;

  {$ENDREGION}

  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  {$REGION readFrom}
  l_type.Members.Add(new CGMethodDefinition("readFrom",
                                            Parameters := [param_aMessage].ToList,
                                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}

  {$REGION writeTo}
  l_type.Members.Add(new CGMethodDefinition("writeTo",
                                            Parameters := [param_aMessage].ToList,
                                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}

  {$REGION toObject}
  var param_aStoreType := new CGParameterDefinition("aStoreType", CGPredefinedTypeReference.Boolean, DefaultValue := "undefined".AsNamedIdentifierExpression);
  var l_m := new CGMethodDefinition("toObject",
                                Parameters := [param_aStoreType].ToList,
                                ReturnType := new CGIntersectionTypeReference(
                                                [l_interface.AsTypeReference,
                                                new CGInlineBlockTypeReference(
                                                  new CGBlockTypeDefinition("",
                                                                            Parameters:=
                                                                              [new CGParameterDefinition("__type",
                                                                                CGPredefinedTypeReference.String,
                                                                                DefaultValue := "undefined".AsNamedIdentifierExpression)].ToList
                                                  ))].ToList),
                                Visibility := CGMemberVisibilityKind.Public);
  l_type.Members.Add(l_m);
  {$ENDREGION}
  {$REGION fromObject}
  var param_aValue := new CGParameterDefinition("aValue", Create_Record_String_any_typeref);
  l_m := new CGMethodDefinition("fromObject",
                                Parameters := [param_aValue].ToList,
                                ReturnType := CGPredefinedTypeReference.InstanceType,
                                Visibility := CGMemberVisibilityKind.Public);
  l_type.Members.Add(l_m);
  {$ENDREGION}
  {$ENDIF TS_SIMPLE_DECLARATIONS}
  aFile.Types.Add(l_type);

end;

method JavaScriptRodlCodeGen.GenerateInterfaceFiles(aLibrary: RodlLibrary; aTargetNamespace: String): not nullable Dictionary<String,String>;
begin
  var l_dict := new Dictionary<String,String>;
  l_dict.Add( Path.ChangeExtension($"{aLibrary.Name}_Intf",
                                  Generator.defaultFileExtension),
              Generator.GenerateUnit(DoGenerateInterfaceFile(aLibrary, aTargetNamespace))
            );
  if (Generator is CGJavaScriptCodeGenerator) then begin
    var l_dialect := CGJavaScriptCodeGenerator(Generator).Dialect;
    try
      CGJavaScriptCodeGenerator(Generator).Dialect := CGJavaScriptCodeGeneratorDialect.TypeScript;
      l_dict.Add( $"{aLibrary.Name}_Intf.d.ts",
                  Generator.GenerateUnit(GenerateMapUnit(aLibrary, aTargetNamespace)) definitionOnly(true)
                );
    finally
      CGJavaScriptCodeGenerator(Generator).Dialect := l_dialect;
    end;
  end;
  exit l_dict;
end;

method JavaScriptRodlCodeGen.GenerateMapUnit(aLibrary: RodlLibrary; aTargetNamespace: String): CGCodeUnit;
begin
  targetNamespace := coalesce(GetIncludesNamespace(aLibrary), aTargetNamespace, GetNamespace(aLibrary));
  var lresult := new CGCodeUnit();
  lresult.Namespace := new CGNamespaceReference(targetNamespace);
  lresult.HeaderComment := GenerateUnitComment(false);
  lresult.Initialization := new List<not nullable CGStatement>;

  lresult.Directives.Add('/// <reference path="./RemObjectsSDK.d.ts" />'.AsCompilerDirective);
  if IsDAProject(aLibrary, true) then begin
    lresult.Directives.Add('/// <reference path="./DataAbstract4_Intf.d.ts" />'.AsCompilerDirective);
    lresult.Directives.Add('/// <reference path="./DataAbstract.d.ts" />'.AsCompilerDirective);
  end;

  var lProcessedFiles:= new List<String>;
  for each u in aLibrary.Uses.Items do begin
    if not u.DontApplyCodeGen then continue;
    if IsDAUses(u) then continue; // already processed
    var l_file := $"./{Path.GetFileNameWithoutExtension(u.FileName)}_Intf.d.ts";
    if lProcessedFiles.Contains(l_file) then continue;
    lresult.Directives.Add($'/// <reference path="{l_file}" />'.AsCompilerDirective);
    lProcessedFiles.Add(l_file);
  end;

  if not ExcludeClasses then begin
    for aEntity: RodlEnum in aLibrary.Enums.Items.OrderBy(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      GenerateEnum_Map(lresult, aLibrary, aEntity);
    end;
    for aEntity: RodlStruct in aLibrary.Structs.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      GenerateStruct_Map(lresult, aLibrary, aEntity);
    end;
    for aEntity: RodlArray  in aLibrary.Arrays.Items.OrderBy(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      GenerateArray_Map(lresult, aLibrary, aEntity);
    end;
    for aEntity: RodlException in aLibrary.Exceptions.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      GenerateException_Map(lresult, aLibrary, aEntity);
    end;
  end;

  if not ExcludeServices then
    for aEntity: RodlService in aLibrary.Services.SortedByAncestor do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      GenerateService_Map(lresult, aLibrary, aEntity);
    end;

  if not ExcludeEventSinks then
    for aEntity: RodlEventSink in aLibrary.EventSinks.Items.OrderBy(b->b.Name) do begin
      if not EntityNeedsCodeGen(aEntity) then continue;
      GenerateEventSink_Map(lresult, aLibrary, aEntity);
    end;


  var l_init := lresult.Initialization;
  var l_int := new CGInterfaceTypeDefinition( targetNamespace.Replace(".",""),
                                              Visibility := CGTypeVisibilityKind.Public);

  for t in lresult.Types do begin
    if aLibrary.FindEntity(t.Name) = nil then continue;
    l_int.Members.Add(new CGFieldDefinition(t.Name,
                                            new CGMetaTypeReference(
                                              new CGNamedTypeReference(t.Name)
                                                                  &namespace(new CGNamespaceReference(targetNamespace))
                                                                  isClassType(true)),
                                            Visibility := CGMemberVisibilityKind.Public));
  end;
  l_init.Add(new CGLocalTypeDeclarationStatement(l_int));
  exit lresult;
end;

method JavaScriptRodlCodeGen.GenerateException_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
begin
  GenerateRodlStructEntity_Map(aFile, aLibrary, aEntity);
end;


method JavaScriptRodlCodeGen.GenerateArray_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
begin
  var l_name := SafeIdentifier(aEntity.Name);
  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity, false),
                                          Visibility := CGTypeVisibilityKind.Public);
  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  l_type.Members.Add(new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public));
  {$ENDIF}
  l_type.Members.Add(new CGFieldDefinition("elementType",
                                            $'"{aEntity.ElementType}"'.AsTypeReference,
                                            Visibility := CGMemberVisibilityKind.Public));
  l_type.Members.Add(new CGFieldDefinition("items",
                                            new CGArrayTypeReference(ResolveDataTypeToTypeRef(aFile, aLibrary,aEntity.ElementType,nil, false)),
                                            Visibility := CGMemberVisibilityKind.Public));
  aFile.Types.Add(l_type);
end;

method JavaScriptRodlCodeGen.GenerateService_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_name := SafeIdentifier(aEntity.Name);
  {$IFDEF ROSERVICE_ANCESTOR}
  var anc := new CGNamedTypeReference(GetStandardAncestor(aEntity)) &namespace(new CGNamespaceReference("RemObjects.SDK"));
  {$ELSE}
  var anc := GetAncestorType(aFile, aEntity, false);
  {$ENDIF}

  var l_type := new CGClassTypeDefinition(l_name,
                                          anc,
                                          Visibility := CGTypeVisibilityKind.Public);
  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  l_type.Members.Add(new CGConstructorDefinition("",
                                                  Parameters := [new CGParameterDefinition("aUrl", CGPredefinedTypeReference.String)].ToList,
                                                  Comment := new CGCommentStatement("URL constructor"),
                                                  Visibility := CGMemberVisibilityKind.Public));
  l_type.Members.Add(new CGConstructorDefinition("",
                                                  Parameters := [new CGParameterDefinition("aRemoteService", "RemObjects.SDK.RemoteService".AsTypeReference)].ToList,
                                                  Comment := new CGCommentStatement("Remote Service constructor"),
                                                  Visibility := CGMemberVisibilityKind.Public));
  l_type.Members.Add(new CGConstructorDefinition("",
                                                  Parameters := [new CGParameterDefinition("aChannel", "RemObjects.SDK.ClientChannel".AsTypeReference),
                                                                 new CGParameterDefinition("aMessage", "RemObjects.SDK.Message".AsTypeReference)].ToList,
                                                  Comment := new CGCommentStatement("Standard constructor with channel and message"),
                                                  Visibility := CGMemberVisibilityKind.Public));
  l_type.Members.Add(new CGConstructorDefinition("",
                                                  Parameters := [new CGParameterDefinition("aChannel", "RemObjects.SDK.ClientChannel".AsTypeReference),
                                                                 new CGParameterDefinition("aMessage", "RemObjects.SDK.Message".AsTypeReference),
                                                                 new CGParameterDefinition("aServiceName", CGPredefinedTypeReference.String)].ToList,
                                                  Comment := new CGCommentStatement("Standard constructor with custom service name"),
                                                  Visibility := CGMemberVisibilityKind.Public));
  l_type.Members.Add(new CGConstructorDefinition("",
                                                  Parameters := [new CGParameterDefinition("__channel", new CGUnionTypeReference(
                                                                                                          ["RemObjects.SDK.ClientChannel".AsTypeReference,
                                                                                                           "RemObjects.SDK.RemoteService".AsTypeReference,
                                                                                                           CGPredefinedTypeReference.String as CGTypeReference].ToList)),
                                                                 new CGParameterDefinition("__message", "RemObjects.SDK.Message".AsTypeReference, DefaultValue := "undefined".AsNamedIdentifierExpression),
                                                                 new CGParameterDefinition("__service_name", CGPredefinedTypeReference.String, DefaultValue := "undefined".AsNamedIdentifierExpression)].ToList,
                                                  Comment := new CGCommentStatement("Implementation signature"),
                                                  Visibility := CGMemberVisibilityKind.Public));
  l_type.Members.Add(new CGFieldDefinition("fServiceName",
                                            CGPredefinedTypeReference.String,
                                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDIF}
  {$REGION methods}
  {$IFDEF ROSERVICE_ANCESTOR}
  var methods := aEntity.GetAllOperations;
  {$ELSE}
  var methods := aEntity.DefaultInterface.Items;
  {$ENDIF}
  for each op in methods do begin
    var l_m := new CGMethodDefinition(SafeIdentifier(op.Name),
                                      Visibility := CGMemberVisibilityKind.Public);

    var l_success := new CGBlockTypeDefinition("", IsPlainFunctionPointer := true);
    var l_error := new CGBlockTypeDefinition("", IsPlainFunctionPointer := true);
    l_error.Parameters.Add(new CGParameterDefinition("msg", "RemObjects.SDK.Message".AsTypeReference));
    l_error.Parameters.Add(new CGParameterDefinition("error", "unknown".AsTypeReference));


    var param__success := new CGParameterDefinition("__success", new CGInlineBlockTypeReference(l_success));
    var param__error := new CGParameterDefinition("__error", new CGInlineBlockTypeReference(l_error));

    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) do
      l_m.Parameters.Add(new CGParameterDefinition(SafeIdentifier(&param.Name),
                                                  ResolveDataTypeToTypeRef(aFile, aLibrary, &param.DataType, nil, false)));


    l_m.Parameters.Add(param__success);
    l_m.Parameters.Add(param__error);

    if assigned(op.Result) then
      l_success.Parameters.Add(new CGParameterDefinition("result", ResolveDataTypeToTypeRef(aFile, aLibrary, op.Result.DataType, nil, false)));

    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) do
      l_success.Parameters.Add(new CGParameterDefinition(&param.Name, ResolveDataTypeToTypeRef(aFile, aLibrary, &param.DataType, nil, false)));

    l_type.Members.Add(l_m);
  end;
  {$ENDREGION}
  aFile.Types.Add(l_type);
end;

method JavaScriptRodlCodeGen.GenerateEventSink_Map(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin

  var l_null_type := "null".AsTypeReference;
  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  var l_uniontypes := new List<CGTypeReference>;
  for each op in aEntity.DefaultInterface.Items do begin
    var l_eventName := $"{aEntity.Name}_{op.Name}";
    var suffix := "EventData";

    while aLibrary.FindEntity($"{l_eventName}{suffix}") <> nil do
      suffix := $"_{suffix}";

    var l_interface := new CGInterfaceTypeDefinition($"{l_eventName}{suffix}",
                                                     Visibility := CGTypeVisibilityKind.Public);
    l_uniontypes.Add(l_interface.AsTypeReference);
    {$REGION properties}
    for each item in op.Items do begin
      var l_value_type := ResolveDataTypeToTypeRef(aFile, aLibrary, item.DataType, nil, false);
      if isStruct(aLibrary, item.DataType) or isException(aLibrary, item.DataType) then begin
        var str_suffix := "Data";
        while aLibrary.FindEntity($"{item.DataType}{str_suffix}") <> nil do
          str_suffix := $"_{str_suffix}";
        var l_t := aFile.Types.Where(b->b.Name = $"{item.DataType}{str_suffix}");
        if l_t.Count = 1 then
          l_value_type := l_t.First.AsTypeReference;
      end;
      l_interface.Members.Add(new CGFieldDefinition(item.Name,
                                                    new CGUnionTypeReference([l_value_type, l_null_type].ToList),
                                                    Visibility := CGMemberVisibilityKind.Public));
    end;


    {$ENDREGION}

    aFile.Types.Add(l_interface);
  end;
  {$ENDIF}

  var l_name := SafeIdentifier(aEntity.Name);
  var l_type := new CGClassTypeDefinition(l_name,
                                          GetAncestorType(aFile, aEntity, false),
                                          Visibility := CGTypeVisibilityKind.Public);
  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  l_type.Members.Add(new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Public));
  {$ENDIF}
  {$REGION properties}
  for each op in aEntity.DefaultInterface.Items do begin
    var l_p := new List<CGParameterDefinition>;
    for each p in op.Items do begin
      var l_dataType_type := $'"{_FixDataType(p.DataType)}"'.AsTypeReference;

      var l_value_type := ResolveDataTypeToTypeRef(aFile, aLibrary, p.DataType, nil, false);

      // if type is enum and is from current library => create new instance of enum type
      var x:= aLibrary.FindEntity(p.DataType);
      if not (x is RodlEnum)  then begin
        l_value_type := new CGUnionTypeReference([l_value_type, l_null_type].ToList);
      end;

      l_p.Add(
        new CGParameterDefinition(p.Name,
                                  new CGInlineBlockTypeReference(
                                    new CGBlockTypeDefinition("",
                                                              IsPlainFunctionPointer := false,
                                                              Parameters := [
                                                                new CGParameterDefinition("dataType", l_dataType_type),
                                                                new CGParameterDefinition("value", l_value_type)].ToList))));
    end;

    l_type.Members.Add(new CGFieldDefinition(op.Name,
                            new CGInlineBlockTypeReference(
                                new CGBlockTypeDefinition("",
                                                          IsPlainFunctionPointer := false,
                                                          Parameters := l_p)),
                              Visibility := CGMemberVisibilityKind.Public));

  end;

  {$ENDREGION}
  {$IFNDEF TS_SIMPLE_DECLARATIONS}
  l_type.Members.Add(new CGMethodDefinition("readEvent",
                                            Parameters := [
                                              new CGParameterDefinition("aMessage","RemObjects.SDK.Message".AsTypeReference),
                                              new CGParameterDefinition("aName", CGPredefinedTypeReference.String)].ToList,
                                            Visibility := CGMemberVisibilityKind.Public));
  l_type.Members.Add(new CGMethodDefinition("toObject",
                                            Parameters := [new CGParameterDefinition("aName", CGPredefinedTypeReference.String)].ToList,
                                            ReturnType := new CGUnionTypeReference(l_uniontypes),
                                            Visibility := CGMemberVisibilityKind.Public));
  {$ENDIF TS_SIMPLE_DECLARATIONS}
  aFile.Types.Add(l_type);
end;

method JavaScriptRodlCodeGen.DoGenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit;
begin
  var lr := inherited DoGenerateInterfaceFile(aLibrary, aTargetNamespace, aUnitName);
  var l_init := lr.Initialization;
  l_init.Add(new CGEmptyStatement());

  var f_module := new CGFieldAccessExpression(nil, "module");
  var l_ns := lr.Namespace.Name.Split(".");
  l_init.Add(new CGIfThenElseStatement(
                CheckForNodeJS,
                new CGIfThenElseStatement(
                  new CGBinaryOperatorExpression(new CGTypeOfExpression(f_module), "undefined".AsLiteralExpression, CGBinaryOperatorKind.StrictNotEquals),
                  new CGAssignmentStatement(
                    new CGFieldAccessExpression(f_module, "exports"),
                    new CGNewInstanceExpression(CGNilExpression.Nil, [new CGCallParameter(l_ns[0].AsNamedIdentifierExpression)])
                  )
                )
            ));
  exit lr;
end;

method JavaScriptRodlCodeGen.GetNameSpaceVar(aFile: CGCodeUnit): CGLocalVariableAccessExpression;
begin
  exit new CGLocalVariableAccessExpression(GetLocalNameSpaceVarName(aFile));
end;


method JavaScriptRodlCodeGen.GetLocalNameSpaceVarName(aFile: CGCodeUnit): String;
begin
  exit $"__{aFile.Namespace.Name.Replace('.','_')}_namespace";
end;




end.