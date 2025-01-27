namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

type
  JavaScriptRodlCodeGen = public class(RodlCodeGen)
  private
    fKnownTypes: Dictionary<String, String> := new Dictionary<String, String>;
    method _FixDataType(aValue: String): String;
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


method JavaScriptRodlCodeGen.DoGenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit;
begin
  result := inherited DoGenerateInterfaceFile(aLibrary, aTargetNamespace, aUnitName);
  result.Initialization.Add(
                            new CGTryFinallyCatchStatement(
                                 [new CGAssignmentStatement(
                                     new CGPropertyAccessExpression(new CGLocalVariableAccessExpression("exports"), aLibrary.Name),
                                     new CGLocalVariableAccessExpression("__namespace"))],
                                  CatchBlocks := [new CGCatchBlockStatement()].ToList
                                  )
            );
end;


method JavaScriptRodlCodeGen.GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := new CGLocalVariableAccessExpression("__namespace");

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Event sink: {l_name}"));

  var l_st: CGStatement;


  var l_methodst :=new List<CGStatement>;
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
    l_methodst.Add(new CGAssignmentStatement(
                    new CGPropertyAccessExpression(CGSelfExpression.Self, op.Name),
                    new CGNewInstanceExpression(CGNilExpression.Nil, l_method_p)));
  end;


  l_st := new CGAssignmentStatement(
            l_namespace_name,
            new CGLocalMethodStatement(aEntity.Name, l_methodst ));
  l_init.Add(l_st);

  var l_prototype := new CGPropertyAccessExpression(l_namespace_name, "prototype");
  l_st := new CGAssignmentStatement(
            l_prototype,
            new CGNewInstanceExpression(
              new CGNamedTypeReference("ROEventSink") &namespace(new CGNamespaceReference("RemObjects.SDK"))
            )
          );
  l_init.Add(l_st);
  l_st := new CGAssignmentStatement(
            new CGPropertyAccessExpression(l_prototype, "constructor"),
            l_namespace_name
          );
  l_init.Add(l_st);

  l_st := new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
            l_namespace_name
          );
  l_init.Add(l_st);
end;


method JavaScriptRodlCodeGen.GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := new CGLocalVariableAccessExpression("__namespace");

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Service: {l_name}"));
  var l_serviceName := new CGPropertyAccessExpression(CGSelfExpression.Self, "fServiceName");
  var l_st: CGStatement;
  var param__channel := new CGParameterDefinition("__channel");
  var param__message := new CGParameterDefinition("__message");
  var param__service_name :=  new CGParameterDefinition("__service_name");
  l_st := new CGAssignmentStatement(
            l_namespace_name,
            new CGLocalMethodStatement(l_name,
                                       [param__channel, param__message, param__service_name],
                                       [new CGMethodCallExpression(
                                          new CGNamedTypeReference("ROService") &namespace(new CGNamespaceReference("RemObjects.SDK")).AsExpression,
                                          "call",
                                          [CGSelfExpression.Self.AsCallParameter,
                                           param__channel.AsCallParameter,
                                           param__message.AsCallParameter,
                                           param__service_name.AsCallParameter]
                                        ),
                                        new CGAssignmentStatement(
                                          l_serviceName,
                                          new CGBinaryOperatorExpression(
                                            new CGBinaryOperatorExpression(
                                              l_serviceName,
                                              param__service_name.AsExpression,
                                              CGBinaryOperatorKind.LogicalOr),
                                            l_name.AsLiteralExpression,
                                            CGBinaryOperatorKind.LogicalOr))]
                                        )
          );
  l_init.Add(l_st);
  var l_prototype := new CGPropertyAccessExpression(l_namespace_name, "prototype");

  if assigned(aEntity.AncestorEntity) then begin
    var l_AncestorNS := "";
    if (aEntity.AncestorEntity <> nil) then begin
      if (aEntity.AncestorEntity.IsFromUsedRodl) and not String.IsNullOrEmpty(aEntity.AncestorEntity.FromUsedRodl.Includes.JavaScriptModule) then
        l_AncestorNS := aEntity.AncestorEntity.FromUsedRodl.Includes.JavaScriptModule;
      if not String.IsNullOrEmpty(l_AncestorNS) then
        l_AncestorNS := l_AncestorNS.Replace(".", "_") + "__";
    end;
    l_AncestorNS := $"__{l_AncestorNS}namespace";


    l_st := new CGAssignmentStatement(
              l_prototype,
              new CGNewInstanceExpression(
                new CGNamedTypeReference(SafeIdentifier(aEntity.AncestorName)) &namespace(new CGNamespaceReference(l_AncestorNS))
              )
            );
    l_init.Add(l_st);
  end;
  var param__success := new CGParameterDefinition("__success");
  var param__error := new CGParameterDefinition("__error");
  for each op in aEntity.DefaultInterface.Items do begin
    var l_parameters := new List<CGParameterDefinition>;

    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) do
      l_parameters.Add(new CGParameterDefinition(SafeIdentifier(&param.Name)));


    l_parameters.Add(param__success);
    l_parameters.Add(param__error);
    var l_try := new List<CGStatement>;
    var localvar_msg := new CGVariableDeclarationStatement("msg", nil,
                                                           new CGMethodCallExpression(
                                                             new CGPropertyAccessExpression(CGSelfExpression.Self, "fMessage"),
                                                             "clone"
                                                           ));
    l_try.Add(localvar_msg);
    var l_msg := localvar_msg.AsExpression;
    l_st := new CGMethodCallExpression(l_msg, "initialize",
                                       [l_serviceName.AsCallParameter,
                                        SafeIdentifier(op.Name).AsLiteralExpression.AsCallParameter]);
    l_try.Add(l_st);
    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) do begin
      var l_datatype: CGExpression :=
        if isStruct(aLibrary, &param.DataType) or isArray(aLibrary, &param.DataType) then
          new CGMethodCallExpression("RemObjects.UTIL".AsNamedIdentifierExpression,
                                     "ROGetType",
                                     [new CGParameterAccessExpression(&param.Name).AsCallParameter])
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
      localvar__result := new CGVariableDeclarationStatement("__result", nil,
                                                   new CGMethodCallExpression(l_message, "read",
                                                     [op.Result.Name.AsLiteralExpression.AsCallParameter,
                                                      _FixDataType(op.Result.DataType).AsLiteralExpression.AsCallParameter]));
      l_methodst.Add(localvar__result);
    end;
    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) do begin
      l_st := new CGVariableDeclarationStatement($"__{SafeIdentifier(&param.Name)}", nil,
                                                  new CGMethodCallExpression(l_msg, "read",
                                                 [&param.Name.AsLiteralExpression.AsCallParameter,
                                                  _FixDataType(&param.DataType).AsLiteralExpression.AsCallParameter]));
      l_methodst.Add(l_st);
    end;

    var l_params1 := new List<CGCallParameter>;
    if assigned(op.Result) then
      l_params1.Add(localvar__result.AsCallParameter);

    for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) do
      l_params1.Add(new CGParameterAccessExpression($"__{SafeIdentifier(&param.Name)}").AsCallParameter);

    l_methodst.Add(new CGMethodCallExpression(nil, param__success.Name, l_params1));
    var l_func := new CGAnonymousMethodExpression([new CGParameterDefinition("__message")].ToList, l_methodst);
    l_st := new CGMethodCallExpression(new CGPropertyAccessExpression(CGSelfExpression.Self, "fChannel"), "dispatch",
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
    l_st := new CGAssignmentStatement(
                new CGPropertyAccessExpression(l_prototype, SafeIdentifier(op.Name)),
                new CGAnonymousMethodExpression(l_parameters, [l_trycatch as CGStatement].ToList));
    l_init.Add(l_st);
  end;
end;


method JavaScriptRodlCodeGen.GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := new CGLocalVariableAccessExpression("__namespace");

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Exception: {l_name}"));
  var param_e := new CGParameterDefinition("e");
  var l_st_list := new List<CGStatement>;
  l_st_list.Add(new CGMethodCallExpression(
                      new CGNamedTypeReference("ROException") &namespace(new CGNamespaceReference("RemObjects.SDK")).AsExpression,
                      "call",
                      [CGSelfExpression.Self.AsCallParameter,
                       param_e.AsCallParameter]
                    ));
  for each item in aEntity.Items do
    l_st_list.Add(new CGAssignmentStatement(
                      new CGPropertyAccessExpression(
                        new CGPropertyAccessExpression(CGSelfExpression.Self, "fields"),
                        SafeIdentifier(item.Name)),
                      new CGNewInstanceExpression(CGNilExpression.Nil,
                                                  [_FixDataType(item.DataType).AsLiteralExpression.AsCallParameter("dataType"),
                                                   CGNilExpression.Nil.AsCallParameter("value")])));

  var l_st := new CGAssignmentStatement(
                l_namespace_name,
                new CGLocalMethodStatement(l_name, [param_e].ToList, l_st_list));
  l_init.Add(l_st);
  l_st := new CGAssignmentStatement(
            new CGPropertyAccessExpression(l_namespace_name, "prototype"),
            new CGNewInstanceExpression(
              new CGNamedTypeReference("ROException") &namespace(new CGNamespaceReference("RemObjects.SDK"))
            )
          );
  l_init.Add(l_st);

  l_st := new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
            l_namespace_name
          );
  l_init.Add(l_st);

end;


method JavaScriptRodlCodeGen.GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := new CGLocalVariableAccessExpression( "__namespace");

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Array: {l_name}"));

  var l_st := new CGAssignmentStatement(
                l_namespace_name,
                new CGLocalMethodStatement(l_name,
                  [ new CGMethodCallExpression(
                      new CGNamedTypeReference("ROArrayType") &namespace(new CGNamespaceReference("RemObjects.SDK")).AsExpression,
                      "call",
                      [(CGSelfExpression.Self).AsCallParameter]
                    ),
                    new CGAssignmentStatement(
                      new CGPropertyAccessExpression(CGSelfExpression.Self, "elementType"),
                      aEntity.ElementType.AsLiteralExpression)
                  ]));
  l_init.Add(l_st);
  var l_prototype := new CGPropertyAccessExpression(l_namespace_name, "prototype");
  l_st := new CGAssignmentStatement(
            l_prototype,
            new CGNewInstanceExpression(
              new CGNamedTypeReference("ROArrayType") &namespace(new CGNamespaceReference("RemObjects.SDK"))
            )
          );
  l_init.Add(l_st);
  l_st := new CGAssignmentStatement(
            new CGPropertyAccessExpression(l_prototype, "constructor"),
            l_namespace_name
          );
  l_init.Add(l_st);

  l_st := new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
            l_namespace_name
          );
  l_init.Add(l_st);
end;


method JavaScriptRodlCodeGen.GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := new CGLocalVariableAccessExpression("__namespace");

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
  l_init.Add(new CGSingleLineCommentStatement($"Struct: {l_name}"));
  var l_st_list := new List<CGStatement>;
  for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do
    l_st_list.Add(new CGAssignmentStatement(
                      new CGPropertyAccessExpression(CGSelfExpression.Self, SafeIdentifier(item.Name)),
                      new CGNewInstanceExpression(CGNilExpression.Nil,
                                                  [new CGCallParameter(_FixDataType(item.DataType).AsLiteralExpression, "dataType"),
                                                   new CGCallParameter(CGNilExpression.Nil, "value")])));

  var l_st := new CGAssignmentStatement(
                l_namespace_name,
                new CGLocalMethodStatement(l_name, l_st_list));
  l_init.Add(l_st);
  var l_prototype := new CGPropertyAccessExpression(l_namespace_name, "prototype");
  l_st := new CGAssignmentStatement(
            l_prototype,
            new CGNewInstanceExpression(
              new CGNamedTypeReference("ROStructType") &namespace(new CGNamespaceReference("RemObjects.SDK"))
            )
          );
  l_init.Add(l_st);
  l_st := new CGAssignmentStatement(
            new CGPropertyAccessExpression(l_prototype, "constructor"),
            l_namespace_name
          );
  l_init.Add(l_st);

  l_st := new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
            l_namespace_name
          );
  l_init.Add(l_st);
end;


method JavaScriptRodlCodeGen.GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  var l_init := aFile.Initialization;
  l_init.Add(new CGEmptyStatement());

  var l_namespace := new CGLocalVariableAccessExpression("__namespace");

  var l_name := SafeIdentifier(aEntity.Name);
  var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);

  l_init.Add(new CGSingleLineCommentStatement($"Enum: {l_name}"));

  var l_st := new CGAssignmentStatement(
                l_namespace_name,
                new CGLocalMethodStatement(l_name, [new CGAssignmentStatement(
                                                    new CGPropertyAccessExpression(CGSelfExpression.Self, "value"),
                                                    CGNilExpression.Nil)]));
  l_init.Add(l_st);

  var l_prototype := new CGPropertyAccessExpression(l_namespace_name, "prototype");

  l_st := new CGAssignmentStatement(
            l_prototype,
            new CGNewInstanceExpression(
              new CGNamedTypeReference("ROEnumType") &namespace(new CGNamespaceReference("RemObjects.SDK"))
            )
          );
  l_init.Add(l_st);

  var l_array := new CGArrayLiteralExpression([]);
  for each item in aEntity.Items do
    l_array.Elements.Add(item.Name.AsLiteralExpression);

  l_st := new CGAssignmentStatement(
            new CGPropertyAccessExpression(l_prototype, "enumValues"),
            l_array
          );
  l_init.Add(l_st);

  l_st := new CGAssignmentStatement(
            new CGPropertyAccessExpression(l_prototype, "constructor"),
            l_namespace_name
          );
  l_init.Add(l_st);

  l_st := new CGAssignmentStatement(
            new CGArrayElementAccessExpression(
              (new CGNamedTypeReference("RTTI") &namespace(new CGNamespaceReference("RemObjects.SDK"))).AsExpression,
              l_name.AsLiteralExpression),
            l_namespace_name
          );
  l_init.Add(l_st);
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
  l_comment.Add("            function(msg) {alert(msg.getErrorMessage())}");
  l_comment.Add(");");


  l_init.Add(new CGCommentStatement(l_comment));

  l_init.Add(new CGEmptyStatement());
  l_init.Add(new CGTryFinallyCatchStatement(
                                 [ new CGVariableDeclarationStatement("RemObjects",
                                      nil,
                                      new CGPropertyAccessExpression(
                                        new CGMethodCallExpression(nil, "require", "./RemObjectsSDK.js".AsLiteralExpression.AsCallParameter),
                                        "RemObjects"
                                      ),
                                      Constant := true)],
                                  CatchBlocks := [new CGCatchBlockStatement()].ToList
                                  )
            );
  l_init.Add();

  var localvar__namespace := new CGVariableDeclarationStatement("__namespace", nil, CGSelfExpression.Self);
  l_init.Add(localvar__namespace);

  var localvar_currnamespace := new CGVariableDeclarationStatement(
                                        $"__{GetNamespace(aLibrary).Replace('.', '_')}__namespace",
                                        nil,
                                        CGSelfExpression.Self
                                      );
  l_init.Add(localvar_currnamespace);

  var l_namespace := localvar__namespace.AsExpression;
  var l_currnamespace_ne := localvar_currnamespace.AsExpression;

  var l_namespace_le := GetNamespace(aLibrary).AsLiteralExpression;

  var localvar_parts := new CGVariableDeclarationStatement(
                            "parts",
                            nil,
                            new CGMethodCallExpression(l_namespace_le, "split", [".".AsLiteralExpression.AsCallParameter])
                          );

  var l_parts := localvar_parts.AsExpression;
  var localvar_current := new CGVariableDeclarationStatement(
                              "current",
                              nil,
                              CGSelfExpression.Self
                            );


  var l_current := localvar_current.AsExpression;
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

  l_st := new CGAssignmentStatement(
            l_namespace,
            l_current);
  l_ifthen.Statements.Add(l_st);

  l_st := new CGAssignmentStatement(
            l_currnamespace_ne,
            l_current);
  l_ifthen.Statements.Add(l_st);

  l_st := new CGIfThenElseStatement(
            new CGBinaryOperatorExpression(
              l_namespace_le,
              "".AsLiteralExpression,
              CGBinaryOperatorKind.NotEquals),
            l_ifthen
          );
  l_init.Add(l_st);
end;



end.