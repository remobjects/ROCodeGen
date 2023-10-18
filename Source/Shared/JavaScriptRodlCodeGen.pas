namespace RemObjects.SDK.CodeGen4;

interface

type
  JavaScriptRodlCodeGen = public class(RodlCodeGen)
  private
    fKnownTypes: Dictionary<String, String> := new Dictionary<String, String>;
    method _FixDataType(aValue: String): String;
    begin
      var l_lower := aValue.ToLowerInvariant;
      if fKnownTypes.ContainsKey(l_lower) then
        exit fKnownTypes[l_lower]
      else
        exit aValue;
    end;
  protected
    method GetGlobalName(aLibrary: RodlLibrary): String; override; empty;

    method AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary); override;
    begin
      aFile.Initialization := new List<not nullable CGStatement>;
      var l_init := aFile.Initialization;

      var l_comment := new List<String>;
      l_comment.Add('This codegen depends on RemObjectsSDK.js');
      l_comment.Add('Usage:');
      l_comment.Add('var Channel = new RemObjects.SDK.HTTPClientChannel("http://localhost:8099/JSON");');
      l_comment.Add('var Message = new RemObjects.SDK.JSONMessage();');
      l_comment.Add('var Service = new NewService(Channel, Message);');
      l_comment.Add('Service.Sum(1, 2,');
      l_comment.Add('            function(result) {');
      l_comment.Add('                alert(result);');
      l_comment.Add('            },');
      l_comment.Add('            function(msg) {alert(msg.getErrorMessage())}');
      l_comment.Add(');');


      l_init.Add(new CGCommentStatement(l_comment));

      l_init.Add(new CGEmptyStatement());
      l_init.Add(new CGVariableDeclarationStatement('RemObjects',
                                                    nil,
                                                    new CGPropertyAccessExpression(
                                                      new CGMethodCallExpression(nil, 'require', './RemObjectsSDK'.AsLiteralExpression.AsCallParameter),
                                                      'RemObjects'
                                                    ),
                                                    Constant := true));

      var l_namespace := '__namespace'.AsNamedIdentifierExpression;

      var l_st: CGStatement := new CGAssignmentStatement(
                                  l_namespace,
                                  new CGSelfExpression()
                                );
      l_init.Add(l_st);

      var l_currnamespace := $"__{GetNamespace(aLibrary).Replace('.', '_')}__namespace";
      var l_currnamespace_ne := l_currnamespace.AsNamedIdentifierExpression;
      l_st := new CGVariableDeclarationStatement(
                  l_currnamespace,
                  nil,
                  new CGSelfExpression()
                );
      l_init.Add(l_st);

      var l_namespace_le := GetNamespace(aLibrary).AsLiteralExpression;
      var l_parts := 'parts'.AsNamedIdentifierExpression;
      var l_current := 'current'.AsNamedIdentifierExpression;
      var l_ifthen :=  new CGBeginEndBlockStatement();

      l_st := new CGVariableDeclarationStatement(
                    'parts',
                    nil,
                    new CGMethodCallExpression(l_namespace_le, 'split', [".".AsLiteralExpression.AsCallParameter])
                  );
      l_ifthen.Statements.Add(l_st);

      l_st := new CGVariableDeclarationStatement(
                    'current',
                    nil,
                    new CGSelfExpression
                  );
      l_ifthen.Statements.Add(l_st);

      var l_for := new CGBeginEndBlockStatement();

      var l_item := new CGArrayElementAccessExpression(l_current,
                        [new CGArrayElementAccessExpression(l_parts,
                            ['i'.AsNamedIdentifierExpression])]);

      l_st := new CGAssignmentStatement(
                l_item,
                new CGBinaryOperatorExpression(
                  l_item,
                  new CGNewInstanceExpression(new CGNilExpression),
                  CGBinaryOperatorKind.LogicalOr)
              );
      l_for.Statements.Add(l_st);

      l_st := new CGAssignmentStatement(
                l_current,
                l_item);
      l_for.Statements.Add(l_st);

      l_st := new CGForToLoopStatement('i',
                                       CGPredefinedTypeReference.Int32,
                                       0.AsLiteralExpression,
                                       new CGBinaryOperatorExpression(
                                         new CGPropertyAccessExpression(l_parts, 'length'),
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

    method GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum); override;
    begin
      var l_init := aFile.Initialization;
      l_init.Add(new CGEmptyStatement());

      var l_namespace := '__namespace'.AsNamedIdentifierExpression;

      var l_name := SafeIdentifier(aEntity.Name);
      var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);

      l_init.Add(new CGSingleLineCommentStatement($"Enum: {l_name}"));

      var l_st := new CGAssignmentStatement(
                    l_namespace_name,
                    new CGLocalMethodStatement(l_name, [new CGAssignmentStatement(
                                                        new CGPropertyAccessExpression(new CGSelfExpression, 'value'),
                                                        new CGNilExpression)]));
      l_init.Add(l_st);

      var l_prototype := new CGPropertyAccessExpression(l_namespace_name, 'prototype');

      l_st := new CGAssignmentStatement(
                l_prototype,
                new CGNewInstanceExpression(
                  new CGNamedTypeReference('ROEnumType') &namespace(new CGNamespaceReference('RemObjects.SDK'))
                )
              );
      l_init.Add(l_st);

      var l_array := new CGArrayLiteralExpression([]);
      for each item in aEntity.Items do
        l_array.Elements.Add(item.Name.AsLiteralExpression);

      l_st := new CGAssignmentStatement(
                new CGPropertyAccessExpression(l_prototype, 'enumValues'),
                l_array
              );
      l_init.Add(l_st);

      l_st := new CGAssignmentStatement(
                new CGPropertyAccessExpression(l_prototype, 'constructor'),
                l_namespace_name
              );
      l_init.Add(l_st);

      l_st := new CGAssignmentStatement(
                new CGArrayElementAccessExpression(
                  (new CGNamedTypeReference('RTTI') &namespace(new CGNamespaceReference('RemObjects.SDK'))).AsExpression,
                  l_name.AsLiteralExpression),
                l_namespace_name
              );
      l_init.Add(l_st);
    end;

    method GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct); override;
    begin
      var l_init := aFile.Initialization;
      l_init.Add(new CGEmptyStatement());

      var l_namespace := '__namespace'.AsNamedIdentifierExpression;

      var l_name := SafeIdentifier(aEntity.Name);
      var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
      l_init.Add(new CGSingleLineCommentStatement($"Struct: {l_name}"));
      var l_st_list := new List<CGStatement>;
      for each item in aEntity.GetAllItems.OrderBy(b->b.Name) do
        l_st_list.Add(new CGAssignmentStatement(
                          new CGPropertyAccessExpression(new CGSelfExpression(), SafeIdentifier(item.Name)),
                          new CGNewInstanceExpression(new CGNilExpression,
                                                      [new CGCallParameter(_FixDataType(item.DataType).AsLiteralExpression, 'dataType'),
                                                       new CGCallParameter(new CGNilExpression, 'value')])));

      var l_st := new CGAssignmentStatement(
                    l_namespace_name,
                    new CGLocalMethodStatement(l_name, l_st_list));
      l_init.Add(l_st);
      var l_prototype := new CGPropertyAccessExpression(l_namespace_name, 'prototype');
      l_st := new CGAssignmentStatement(
                l_prototype,
                new CGNewInstanceExpression(
                  new CGNamedTypeReference('ROStructType') &namespace(new CGNamespaceReference('RemObjects.SDK'))
                )
              );
      l_init.Add(l_st);
      l_st := new CGAssignmentStatement(
                new CGPropertyAccessExpression(l_prototype, 'constructor'),
                l_namespace_name
              );
      l_init.Add(l_st);

      l_st := new CGAssignmentStatement(
                new CGArrayElementAccessExpression(
                  (new CGNamedTypeReference('RTTI') &namespace(new CGNamespaceReference('RemObjects.SDK'))).AsExpression,
                  l_name.AsLiteralExpression),
                l_namespace_name
              );
      l_init.Add(l_st);
    end;

    method GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray); override;
    begin
      var l_init := aFile.Initialization;
      l_init.Add(new CGEmptyStatement());

      var l_namespace := '__namespace'.AsNamedIdentifierExpression;

      var l_name := SafeIdentifier(aEntity.Name);
      var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
      l_init.Add(new CGSingleLineCommentStatement($"Array: {l_name}"));

      var l_st := new CGAssignmentStatement(
                    l_namespace_name,
                    new CGLocalMethodStatement(l_name,
                      [ new CGMethodCallExpression(
                          new CGNamedTypeReference('ROArrayType') &namespace(new CGNamespaceReference('RemObjects.SDK')).AsExpression,
                          'call',
                          [(new CGSelfExpression).AsCallParameter]
                        ),
                        new CGAssignmentStatement(
                          new CGPropertyAccessExpression(new CGSelfExpression, 'elementType'),
                          aEntity.ElementType.AsLiteralExpression)
                      ]));
      l_init.Add(l_st);
      var l_prototype := new CGPropertyAccessExpression(l_namespace_name, 'prototype');
      l_st := new CGAssignmentStatement(
                l_prototype,
                new CGNewInstanceExpression(
                  new CGNamedTypeReference('ROArrayType') &namespace(new CGNamespaceReference('RemObjects.SDK'))
                )
              );
      l_init.Add(l_st);
      l_st := new CGAssignmentStatement(
                new CGPropertyAccessExpression(l_prototype, 'constructor'),
                l_namespace_name
              );
      l_init.Add(l_st);

      l_st := new CGAssignmentStatement(
                new CGArrayElementAccessExpression(
                  (new CGNamedTypeReference('RTTI') &namespace(new CGNamespaceReference('RemObjects.SDK'))).AsExpression,
                  l_name.AsLiteralExpression),
                l_namespace_name
              );
      l_init.Add(l_st);
    end;

    method GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException); override;
    begin
      var l_init := aFile.Initialization;
      l_init.Add(new CGEmptyStatement());

      var l_namespace := '__namespace'.AsNamedIdentifierExpression;

      var l_name := SafeIdentifier(aEntity.Name);
      var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
      l_init.Add(new CGSingleLineCommentStatement($"Exception: {l_name}"));
      var l_st_list := new List<CGStatement>;
      l_st_list.Add(new CGMethodCallExpression(
                          new CGNamedTypeReference('ROException') &namespace(new CGNamespaceReference('RemObjects.SDK')).AsExpression,
                          'call',
                          [(new CGSelfExpression).AsCallParameter,
                           'e'.AsNamedIdentifierExpression.AsCallParameter]
                        ));
      for each item in aEntity.Items do
        l_st_list.Add(new CGAssignmentStatement(
                          new CGPropertyAccessExpression(
                            new CGPropertyAccessExpression(new CGSelfExpression(), 'fields'),
                            SafeIdentifier(item.Name)),
                          new CGNewInstanceExpression(new CGNilExpression,
                                                      [new CGCallParameter(_FixDataType(item.DataType).AsLiteralExpression, 'dataType'),
                                                       new CGCallParameter(new CGNilExpression, 'value')])));

      var l_st := new CGAssignmentStatement(
                    l_namespace_name,
                    new CGLocalMethodStatement(l_name, [new CGParameterDefinition('e')].ToList, l_st_list));
      l_init.Add(l_st);
      var l_prototype := new CGPropertyAccessExpression(l_namespace_name, 'prototype');
      l_st := new CGAssignmentStatement(
                l_prototype,
                new CGNewInstanceExpression(
                  new CGNamedTypeReference('ROException') &namespace(new CGNamespaceReference('RemObjects.SDK'))
                )
              );
      l_init.Add(l_st);

      l_st := new CGAssignmentStatement(
                new CGArrayElementAccessExpression(
                  (new CGNamedTypeReference('RTTI') &namespace(new CGNamespaceReference('RemObjects.SDK'))).AsExpression,
                  l_name.AsLiteralExpression),
                l_namespace_name
              );
      l_init.Add(l_st);

    end;

    method GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService); override;
    begin
      var l_init := aFile.Initialization;
      l_init.Add(new CGEmptyStatement());

      var l_namespace := '__namespace'.AsNamedIdentifierExpression;

      var l_name := SafeIdentifier(aEntity.Name);
      var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
      l_init.Add(new CGSingleLineCommentStatement($"Service: {l_name}"));
      var l_serviceName := new CGPropertyAccessExpression(new CGSelfExpression, 'fServiceName');
      var l_st: CGStatement;
      l_st := new CGAssignmentStatement(
                l_namespace_name,
                new CGLocalMethodStatement(l_name,
                                           [new CGParameterDefinition('__channel'),
                                            new CGParameterDefinition('__message'),
                                            new CGParameterDefinition('__service_name')],
                                           [new CGMethodCallExpression(
                                              new CGNamedTypeReference('ROService') &namespace(new CGNamespaceReference('RemObjects.SDK')).AsExpression,
                                              'call',
                                              [(new CGSelfExpression).AsCallParameter,
                                               '__channel'.AsNamedIdentifierExpression.AsCallParameter,
                                               '__message'.AsNamedIdentifierExpression.AsCallParameter,
                                               '__service_name'.AsNamedIdentifierExpression.AsCallParameter]
                                            ),
                                            new CGAssignmentStatement(
                                              l_serviceName,
                                              new CGBinaryOperatorExpression(
                                                new CGBinaryOperatorExpression(
                                                  l_serviceName,
                                                  '__service_name'.AsNamedIdentifierExpression,
                                                  CGBinaryOperatorKind.LogicalOr),
                                                l_name.AsLiteralExpression,
                                                CGBinaryOperatorKind.LogicalOr))]
                                            )
              );
      l_init.Add(l_st);
      var l_prototype := new CGPropertyAccessExpression(l_namespace_name, 'prototype');

      if assigned(aEntity.AncestorEntity) then begin
        var l_AncestorNS := '';
        if (aEntity.AncestorEntity <> nil) then begin
          if (aEntity.AncestorEntity.IsFromUsedRodl) and not String.IsNullOrEmpty(aEntity.AncestorEntity.FromUsedRodl.Includes.JavaScriptModule) then
            l_AncestorNS := aEntity.AncestorEntity.FromUsedRodl.Includes.JavaScriptModule;
          if not String.IsNullOrEmpty(l_AncestorNS) then
            l_AncestorNS := l_AncestorNS.Replace('.', '_') + '__';
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
      for each op in aEntity.DefaultInterface.Items do begin
        var l_parameters := new List<CGParameterDefinition>;

        for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) do
          l_parameters.Add(new CGParameterDefinition(SafeIdentifier(&param.Name)));

        l_parameters.Add(new CGParameterDefinition('__success'));
        l_parameters.Add(new CGParameterDefinition('__error'));
        var l_try := new List<CGStatement>;
        l_st := new CGVariableDeclarationStatement('msg', nil,
                                                     new CGMethodCallExpression(
                                                       new CGPropertyAccessExpression(new CGSelfExpression, 'fMessage'),
                                                       'clone'
                                                     ));
        l_try.Add(l_st);
        var l_msg := 'msg'.AsNamedIdentifierExpression;
        l_st := new CGMethodCallExpression(l_msg, 'initialize',
                                           [l_serviceName.AsCallParameter,
                                            SafeIdentifier(op.Name).AsLiteralExpression.AsCallParameter]);
        l_try.Add(l_st);
        for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.In, ParamFlags.InOut]) do begin
          l_st := new CGMethodCallExpression(l_msg, 'write',
                                             [&param.Name.AsLiteralExpression.AsCallParameter,
                                              _FixDataType(&param.DataType).AsLiteralExpression.AsCallParameter,
                                              SafeIdentifier(param.Name).AsNamedIdentifierExpression.AsCallParameter ]);
          l_try.Add(l_st);
        end;
        l_st := new CGMethodCallExpression(l_msg, 'finalize');
        l_try.Add(l_st);

        var l_methodst := new List<CGStatement>;
        var l_message := '__message'.AsNamedIdentifierExpression;
        if assigned(op.Result) then begin
          l_st := new CGVariableDeclarationStatement('__result', nil,
                                                     new CGMethodCallExpression(l_message, 'read',
                                                       [op.Result.Name.AsLiteralExpression.AsCallParameter,
                                                        _FixDataType(op.Result.DataType).AsLiteralExpression.AsCallParameter]));
          l_methodst.Add(l_st);
        end;
        for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) do begin
          l_st := new CGVariableDeclarationStatement($'__{SafeIdentifier(&param.Name)}', nil,
                                                      new CGMethodCallExpression(l_msg, 'read',
                                                     [&param.Name.AsLiteralExpression.AsCallParameter,
                                                      _FixDataType(&param.DataType).AsLiteralExpression.AsCallParameter]));
          l_methodst.Add(l_st);
        end;

        var l_params1 := new List<CGCallParameter>;
        if assigned(op.Result) then
          l_params1.Add('__result'.AsNamedIdentifierExpression.AsCallParameter);

        for each &param in op.Items.Where(b->b.ParamFlag in [ParamFlags.InOut, ParamFlags.Out]) do
          l_params1.Add($'__{SafeIdentifier(&param.Name)}'.AsNamedIdentifierExpression.AsCallParameter);

        l_methodst.Add(new CGMethodCallExpression(nil, '__success', l_params1));
        var l_func := new CGAnonymousMethodExpression([new CGParameterDefinition('__message')].ToList, l_methodst);
        l_st := new CGMethodCallExpression(new CGPropertyAccessExpression(new CGSelfExpression, 'fChannel'), 'dispatch',
                                           [l_msg.AsCallParameter,
                                           l_func.AsCallParameter,
                                           '__error'.AsNamedIdentifierExpression.AsCallParameter]);
        l_try.Add(l_st);

        var l_catch := new CGCatchBlockStatement('e');

        l_catch.Statements.Add(new CGMethodCallExpression(nil, '__error',
                                                          [l_msg.AsCallParameter,
                                                           'e'.AsNamedIdentifierExpression.AsCallParameter]));
        var l_trycatch := new CGTryFinallyCatchStatement(l_try);
        l_trycatch.CatchBlocks.Add(l_catch);
        l_st := new CGAssignmentStatement(
                    new CGPropertyAccessExpression(l_prototype, SafeIdentifier(op.Name)),
                    new CGAnonymousMethodExpression(l_parameters, [l_trycatch as CGStatement].ToList));
        l_init.Add(l_st);
      end;
    end;

    method GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink); override;
    begin
      var l_init := aFile.Initialization;
      l_init.Add(new CGEmptyStatement());

      var l_namespace := '__namespace'.AsNamedIdentifierExpression;

      var l_name := SafeIdentifier(aEntity.Name);
      var l_namespace_name := new CGPropertyAccessExpression(l_namespace, l_name);
      l_init.Add(new CGSingleLineCommentStatement($"Event sink: {l_name}"));

      var l_st: CGStatement;


      var l_methodst :=new List<CGStatement>;
      for each op in aEntity.DefaultInterface.Items do begin
        var l_method_p :=new List<CGCallParameter>;
        for each &param in op.Items do begin
          var l_params := new List<CGCallParameter>;
          l_params.Add(new CGCallParameter(_FixDataType(&param.DataType).AsLiteralExpression, 'dataType'));
          l_params.Add(new CGCallParameter(new CGNilExpression, 'value'));
          l_method_p.Add(new CGCallParameter(
                            new CGNewInstanceExpression(new CGNilExpression, l_params),
                            &param.Name));
        end;
        l_methodst.Add(new CGAssignmentStatement(
                        new CGPropertyAccessExpression(new CGSelfExpression, op.Name),
                        new CGNewInstanceExpression(new CGNilExpression, l_method_p)));
      end;


      l_st := new CGAssignmentStatement(
                l_namespace_name,
                new CGLocalMethodStatement(aEntity.Name, l_methodst ));
      l_init.Add(l_st);

      var l_prototype := new CGPropertyAccessExpression(l_namespace_name, 'prototype');
      l_st := new CGAssignmentStatement(
                l_prototype,
                new CGNewInstanceExpression(
                  new CGNamedTypeReference('ROEventSink') &namespace(new CGNamespaceReference('RemObjects.SDK'))
                )
              );
      l_init.Add(l_st);
      l_st := new CGAssignmentStatement(
                new CGPropertyAccessExpression(l_prototype, 'constructor'),
                l_namespace_name
              );
      l_init.Add(l_st);

      l_st := new CGAssignmentStatement(
                new CGArrayElementAccessExpression(
                  (new CGNamedTypeReference('RTTI') &namespace(new CGNamespaceReference('RemObjects.SDK'))).AsExpression,
                  l_name.AsLiteralExpression),
                l_namespace_name
              );
      l_init.Add(l_st);
    end;

    method DoGenerateInterfaceFile(aLibrary: RodlLibrary; aTargetNamespace: String; aUnitName: String := nil): CGCodeUnit; override;
    begin
      result := inherited DoGenerateInterfaceFile(aLibrary, aTargetNamespace, aUnitName);
      result.Initialization.Add(new CGAssignmentStatement(
                                  new CGPropertyAccessExpression('exports'.AsNamedIdentifierExpression, aLibrary.Name),
                                  '__namespace'.AsNamedIdentifierExpression));
    end;
  public
    constructor;
    begin
      fKnownTypes.Add('integer', 'Integer');
      fKnownTypes.Add('datetime', 'DateTime');
      fKnownTypes.Add('double', 'Double');
      fKnownTypes.Add('currency', 'Currency');
      fKnownTypes.Add('widestring', 'WideString');
      fKnownTypes.Add('ansistring', 'AnsiString');
      fKnownTypes.Add('int64', 'Int64');
      fKnownTypes.Add('boolean', 'Boolean');
      fKnownTypes.Add('variant', 'Variant');
      fKnownTypes.Add('binary', 'Binary');
      fKnownTypes.Add('xml', 'Xml');
      fKnownTypes.Add('guid', 'Guid');
      fKnownTypes.Add('decimal', 'Decimal');
      fKnownTypes.Add('utf8string', 'Utf8String');
      fKnownTypes.Add('xsdatetime', 'XsDateTime');

      ReservedWords.Add('boolean');
      ReservedWords.Add('break');
      ReservedWords.Add('byte');
      ReservedWords.Add('case');
      ReservedWords.Add('catch');
      ReservedWords.Add('char');
      ReservedWords.Add('continue');
      ReservedWords.Add('default');
      ReservedWords.Add('delete');
      ReservedWords.Add('do');
      ReservedWords.Add('double');
      ReservedWords.Add('else');
      ReservedWords.Add('false');
      ReservedWords.Add('final');
      ReservedWords.Add('finally');
      ReservedWords.Add('float');
      ReservedWords.Add('for');
      ReservedWords.Add('function');
      ReservedWords.Add('if');
      ReservedWords.Add('in');
      ReservedWords.Add('instanceof');
      ReservedWords.Add('int');
      ReservedWords.Add('long');
      ReservedWords.Add('new');
      ReservedWords.Add('null');
      ReservedWords.Add('return');
      ReservedWords.Add('short');
      ReservedWords.Add('switch');
      ReservedWords.Add('this');
      ReservedWords.Add('throw');
      ReservedWords.Add('true');
      ReservedWords.Add('try');
      ReservedWords.Add('typeof');
      ReservedWords.Add('var');
      ReservedWords.Add('void');
      ReservedWords.Add('while');
      ReservedWords.Add('with');

    end;
  end;

implementation

end.