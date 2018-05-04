namespace RemObjects.DataAbstract.CodeGen4;

uses
  System.Collections.Generic,
  System.ComponentModel,
  System.IO,
  System.Text,
  RemObjects.CodeGen4,
  RemObjects.DataAbstract.Schema;

type
  [System.Reflection.ObfuscationAttribute(Exclude := true, ApplyToMembers := true)]
  NetTableDefinitionsCodeGen = public class
  private
    {$REGION Private constants }
    const EVENT_PROPERTY_CHANGING: String = 'PropertyChanging';
    const EVENT_PROPERTY_CHANGED: String = 'PropertyChanged';

    const TRIGGER_PROPERTY_CHANGING: String = 'OnPropertyChanging';
    const TRIGGER_PROPERTY_CHANGED: String = 'OnPropertyChanged';

    const EVENT_TRIGGER_PARAMETER_NAME: String = 'parameterName';

    const CODE_FIELD_PREFIX: String = 'f____';
    const CODE_FIELD_SOURCE_TABLE: String = CODE_FIELD_PREFIX + PROPERTY_SOURCE_TABLE;
    const CODE_OLD_VALUES_FIELD: String = 'm____OldValues';

    const SCHEMA_FIELD_SOURCE_TABLE: String = '@SourceTable';

    const PROPERTY_SOURCE_TABLE: String = 'ServerSchemaSourceTable';
    {$ENDREGION}

    {$REGION Private fields}
    var fCodeGenerator: CGCodeGenerator; readonly;
    var fFullyFeaturedCodeGen: Boolean; readonly;

    var fCodeUnit: CGCodeUnit;
    {$ENDREGION}


    method GetValidIdentifier(name: String): String;
    begin
      var identifier: String := RemObjects.SDK.Helpers.StringHelpers.ClearIdentifier(name, false);
      if identifier.ToUpperInvariant() in [ NetTableDefinitionsCodeGen.EVENT_PROPERTY_CHANGING.ToUpperInvariant(),
                                              NetTableDefinitionsCodeGen.EVENT_PROPERTY_CHANGED.ToUpperInvariant(),
                                              NetTableDefinitionsCodeGen.TRIGGER_PROPERTY_CHANGING.ToUpperInvariant(),
                                              NetTableDefinitionsCodeGen.TRIGGER_PROPERTY_CHANGED.ToUpperInvariant() ] then begin
        identifier := identifier + '_';
      end;

      exit identifier;
    end;


    method GetTableRelationships(schema: Schema;  tableName: String): IList<SchemaRelationship>;
    begin
      var relationships: List<SchemaRelationship> := new List<SchemaRelationship>();
      for each relation: SchemaRelationship in schema.Relationships do begin
        if String.Equals(tableName, relation.DetailDataTableName, StringComparison.OrdinalIgnoreCase) then begin
          relationships.Add(relation);
        end;
      end;

      exit relationships;
    end;


    method GenerateCodeMetadata(schemaName: String;  schemaUri: String;  skippedTables: ICollection<String>;  includePrivateTables: Boolean);
    begin
      if not String.IsNullOrEmpty(schemaName) then begin
        self.fCodeUnit.HeaderComment.Lines.Add(String.Format('#DA Schema Name:"{0}"', schemaName));
      end;

      if not String.IsNullOrEmpty(schemaUri) then begin
        self.fCodeUnit.HeaderComment.Lines.Add(String.Format('#DA Schema Source:"{0}"', schemaUri));
      end;

      if includePrivateTables then begin
        self.fCodeUnit.HeaderComment.Lines.Add('#DA Add Private Tables');
      end;

      if skippedTables.Count > 0 then begin
        var skippedTablesComment: StringBuilder := new StringBuilder();
        skippedTablesComment.Append('#DA Skipped Tables:"');
        for each tableName: String in skippedTables index i do begin
          if i > 0 then begin
            skippedTablesComment.Append(',');
          end;

          skippedTablesComment.Append(tableName);
        end;

        skippedTablesComment.Append('"');

        self.fCodeUnit.HeaderComment.Lines.Add(skippedTablesComment.ToString());
      end;
    end;


    method AddTableFieldMetadata(codeField: CGMemberDefinition;  schemaField: SchemaField);
    begin
      codeField.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.FieldName"), (new CGStringLiteralExpression(schemaField.Name)).AsCallParameter()));
      codeField.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.DataType"),
                                                (new CGEnumValueAccessExpression(new CGNamedTypeReference(typeOf(RemObjects.DataAbstract.Schema.DataType).ToString()), schemaField.DataType.ToString())).AsCallParameter()));


      if schemaField.InPrimaryKey then begin
        codeField.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.PrimaryKey")));
      end;

      if schemaField.LogChanges then begin
        codeField.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.LogChanges")));
      end;

      if schemaField.ServerAutoRefresh then begin
        codeField.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.ServerAutoRefresh")));
      end;
    end;


    method GenerateUnit(schema: Schema;  schemaName: String;  schemaUri: String;  &namespace: String;  skippedTables: ICollection<String>;  includePrivateTables: Boolean);
    begin
      // Get Schema Tables list
      var schemaTables: ICollection<SchemaDataTable> := schema.GetAllDatasets(not includePrivateTables);

      // Convert skipped table nemas into HashSet
      var skippedTablesList: HashSet<String> := new HashSet<String>(StringComparer.Ordinal);
      for each tableName: String in skippedTables do begin
        skippedTablesList.Add(tableName);
      end;

      self.fCodeUnit := new CGCodeUnit(&namespace);

      self.GenerateCodeMetadata(schemaName, schemaUri, skippedTables, includePrivateTables);

      var tableDefinitions: List<CGTypeDefinition> := new List<CGTypeDefinition>(schemaTables.Count);
      for each table in schemaTables do begin
        // Skip unneeded tables
        if skippedTablesList.Contains(table.Name) then begin
          continue;
        end;

        tableDefinitions.Add(self.GenerateTableTypeDefinition(table, self.GetTableRelationships(schema, table.Name)));
      end;

      for each table in tableDefinitions do begin
        self.fCodeUnit.Types.Add(table);
      end;

      self.GenerateDataContext(tableDefinitions);
    end;


    method GenerateTableTypeDefinition(table: SchemaDataTable;  relations: IList<SchemaRelationship>): CGClassTypeDefinition;
    begin
      var typeDefinition := new CGClassTypeDefinition(self.GetValidIdentifier(table.Name));

      typeDefinition.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.TableName"), (new CGStringLiteralExpression(table.Name)).AsCallParameter()));
      typeDefinition.Visibility := CGTypeVisibilityKind.Public;
      typeDefinition.Partial := true;

      self.GenerateICloneableImplementation(typeDefinition, table is SchemaUnionDataTable, table.Fields);

      self.GeneratePropertyChangeEventDefinitions(typeDefinition);

      self.GeneratePropertyChangingEventTrigger(typeDefinition);
      self.GeneratePropertyChangedEventTrigger(typeDefinition);

      self.GenerateChangeManagementMethods(typeDefinition);

      for each schemaField: SchemaField in table.Fields do begin
        // DA LINQ cannot access calculated fields AS IS
        if schemaField.Calculated then begin
          continue;
        end;

        var fieldType: &Type := FieldUtils.DataTypeToType(schemaField.DataType);
        var fieldTypeReference: CGTypeReference;
        if fieldType.IsValueType and not schemaField.Required then begin
          fieldTypeReference := new CGNamedTypeReference('System.Nullable');
          CGNamedTypeReference(fieldTypeReference).GenericArguments := new List<CGTypeReference>([ new CGNamedTypeReference(fieldType.ToString()) ]);
        end
        else begin
          fieldTypeReference := iif(fieldType.IsArray,
                                  (new CGArrayTypeReference(new CGNamedTypeReference(fieldType.GetElementType().ToString()) defaultNullability(CGTypeNullabilityKind.Default))).copyWithNullability(CGTypeNullabilityKind.NullableNotUnwrapped),
                                  new CGNamedTypeReference(fieldType.ToString()) defaultNullability(CGTypeNullabilityKind.Default));
        end;

        var fieldName: String := self.GetValidIdentifier(schemaField.Name);
        // In C# member names cannot be the same as their enclosing type
        // Check is not case-sensitive because VB.NET and Oxygene don't care about identifier case
        if String.Equals(fieldName, table.Name, StringComparison.OrdinalIgnoreCase) then begin
          fieldName := fieldName + '_Field';
        end;

        var fieldDefinition := new CGFieldDefinition(NetTableDefinitionsCodeGen.CODE_FIELD_PREFIX + fieldName, fieldTypeReference);
        fieldDefinition.Visibility := CGMemberVisibilityKind.Private;
        typeDefinition.Members.Add(fieldDefinition);

        var fieldReference := new CGFieldAccessExpression(new CGSelfExpression(), fieldDefinition.Name);

        var propertyDefinition := new CGPropertyDefinition(fieldName, fieldTypeReference, new List<CGStatement>(), new List<CGStatement>());
        propertyDefinition.Visibility := CGMemberVisibilityKind.Public;
        typeDefinition.Members.Add(propertyDefinition);

        // Get relations
        for each relation: SchemaRelationship in relations do begin
          if not String.Equals(schemaField.Name, relation.DetailFields, StringComparison.OrdinalIgnoreCase) then begin
            continue;
          end;

          propertyDefinition.Attributes.Add(new CGAttribute(new CGNamedTypeReference('RemObjects.DataAbstract.Linq.Relation'),
                                              (new CGStringLiteralExpression(relation.MasterDataTableName)).AsCallParameter(),
                                              (new CGStringLiteralExpression(relation.MasterFields)).AsCallParameter()));
        end;

        self.AddTableFieldMetadata(propertyDefinition, schemaField);

        propertyDefinition.GetStatements.Add(new CGReturnStatement(fieldReference));

        if not schemaField.ReadOnly then begin
          var conditionStatement: CGBinaryOperatorExpression;

          if schemaField.DataType = DataType.Blob then begin
            var comparerCall := new CGMethodCallExpression(new CGTypeReferenceExpression(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.LinqDataAdapter")), "CompareBytes", fieldReference.AsCallParameter(), (new CGPropertyValueExpression()).AsCallParameter());

            conditionStatement := new CGBinaryOperatorExpression(comparerCall, new CGBooleanLiteralExpression(true), CGBinaryOperatorKind.NotEquals);
          end
          else begin
            var comparerType: CGNamedTypeReference := new CGNamedTypeReference('System.Collections.Generic.Comparer');
            comparerType.GenericArguments := new List<CGTypeReference>([ fieldTypeReference ]);

            var comparerInstance := new CGPropertyAccessExpression(new CGTypeReferenceExpression(comparerType), "Default");

            var comparerCall := new CGMethodCallExpression(comparerInstance, "Compare", fieldReference.AsCallParameter(), (new CGPropertyValueExpression()).AsCallParameter());

            conditionStatement := new CGBinaryOperatorExpression(comparerCall, new CGIntegerLiteralExpression(0), CGBinaryOperatorKind.NotEquals);          
          end;

          var statements := new CGBeginEndBlockStatement();

          if self.fFullyFeaturedCodeGen then begin
            statements.Statements.Add(new CGMethodCallExpression(new CGSelfExpression(), NetTableDefinitionsCodeGen.TRIGGER_PROPERTY_CHANGING, new CGStringLiteralExpression(fieldName).AsCallParameter()));
          end;

          statements.Statements.Add(new CGAssignmentStatement(fieldReference, new CGPropertyValueExpression()));
          statements.Statements.Add(new CGMethodCallExpression(new CGSelfExpression(), NetTableDefinitionsCodeGen.TRIGGER_PROPERTY_CHANGED, new CGStringLiteralExpression(fieldName).AsCallParameter()));

          propertyDefinition.SetStatements.Add(new CGIfThenElseStatement(conditionStatement, statements));
        end
        else begin
          propertyDefinition.SetStatements.Add(new CGAssignmentStatement(fieldReference, new CGPropertyValueExpression()));
        end;
      end;

      if (table is SchemaUnionDataTable) then begin
        var fieldDefinition := new CGFieldDefinition(NetTableDefinitionsCodeGen.CODE_FIELD_SOURCE_TABLE, CGPredefinedTypeReference.Int32);
        fieldDefinition.Initializer := new CGIntegerLiteralExpression(0); // This is needed to get rid of 'Field is never assigned' compiler warnings
        fieldDefinition.Visibility := CGMemberVisibilityKind.Private;
        typeDefinition.Members.Add(fieldDefinition);

        var fieldReference := new CGFieldAccessExpression(new CGSelfExpression(), fieldDefinition.Name);

        var propertyDefinition := new CGPropertyDefinition(NetTableDefinitionsCodeGen.PROPERTY_SOURCE_TABLE, CGPredefinedTypeReference.Int32, new List<CGStatement>(), new List<CGStatement>());
        propertyDefinition.Visibility := CGMemberVisibilityKind.Public;
        typeDefinition.Members.Add(propertyDefinition);

        propertyDefinition.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.FieldName"), (new CGStringLiteralExpression(NetTableDefinitionsCodeGen.SCHEMA_FIELD_SOURCE_TABLE)).AsCallParameter()));
        propertyDefinition.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.DataType"),
                                                (new CGEnumValueAccessExpression(new CGNamedTypeReference(typeOf(RemObjects.DataAbstract.Schema.DataType).ToString()), 'Integer')).AsCallParameter()));
        propertyDefinition.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.PrimaryKey")));
        propertyDefinition.Attributes.Add(new CGAttribute(new CGNamedTypeReference("RemObjects.DataAbstract.Linq.LogChanges")));

        propertyDefinition.GetStatements.Add(new CGReturnStatement(fieldReference));
        propertyDefinition.SetStatements.Add(new CGAssignmentStatement(fieldReference, new CGPropertyValueExpression()));
      end;

      exit typeDefinition;
    end;


    method GenerateICloneableImplementation(typeDefinition: CGClassTypeDefinition;  isUnionTable: Boolean;  fields: SchemaFieldCollection);
    begin
      if not self.fFullyFeaturedCodeGen then begin
        exit;
      end;

      typeDefinition.ImplementedInterfaces.Add(new CGNamedTypeReference(typeOf(ICloneable).ToString()));

      var cloneMethod := new CGMethodDefinition("Clone");
      cloneMethod.Visibility := CGMemberVisibilityKind.Public;
      typeDefinition.Members.Add(cloneMethod);

      cloneMethod.ReturnType := CGPredefinedTypeReference.Object;

      cloneMethod.Statements.Add(new CGVariableDeclarationStatement("v____new", new CGNamedTypeReference(typeDefinition.Name), new CGNewInstanceExpression(new CGNamedTypeReference(typeDefinition.Name))));
      var clonedInstance := new CGNamedIdentifierExpression("v____new");

      for each field: SchemaField in fields do begin
        if field.Calculated then begin
          continue;
        end;

        var fieldName: String := NetTableDefinitionsCodeGen.CODE_FIELD_PREFIX + GetValidIdentifier(field.Name);
        cloneMethod.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(clonedInstance, fieldName), new CGFieldAccessExpression(new CGSelfExpression(), fieldName)));
      end;

      if isUnionTable then begin
        cloneMethod.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(clonedInstance, NetTableDefinitionsCodeGen.CODE_FIELD_SOURCE_TABLE),
                                      new CGFieldAccessExpression(new CGSelfExpression(), NetTableDefinitionsCodeGen.CODE_FIELD_SOURCE_TABLE)));
      end;

      cloneMethod.Statements.Add(new CGReturnStatement(clonedInstance));
    end;


    method GeneratePropertyChangeEventDefinitions(typeDefinition: CGClassTypeDefinition);
    begin
      typeDefinition.ImplementedInterfaces.Add(new CGNamedTypeReference(typeOf(INotifyPropertyChanged).ToString()));

      var eventDefinition := new CGEventDefinition(NetTableDefinitionsCodeGen.EVENT_PROPERTY_CHANGED, new CGNamedTypeReference(typeOf(PropertyChangedEventHandler).ToString()));
      eventDefinition.Visibility := CGMemberVisibilityKind.Public;
      typeDefinition.Members.Add(eventDefinition);

      if self.fFullyFeaturedCodeGen then begin
        typeDefinition.ImplementedInterfaces.Add(new CGNamedTypeReference(typeOf(INotifyPropertyChanging).ToString()));

        eventDefinition := new CGEventDefinition(NetTableDefinitionsCodeGen.EVENT_PROPERTY_CHANGING, new CGNamedTypeReference(typeOf(PropertyChangingEventHandler).ToString()));
        eventDefinition.Visibility := CGMemberVisibilityKind.Public;
        typeDefinition.Members.Add(eventDefinition);
      end;
    end;


    method GeneratePropertyChangingEventTrigger(typeDefinition: CGClassTypeDefinition);
    begin
      if not self.fFullyFeaturedCodeGen then begin
        exit;
      end;

      var triggerMethod := new CGMethodDefinition(NetTableDefinitionsCodeGen.TRIGGER_PROPERTY_CHANGING);
      triggerMethod.Visibility := CGMemberVisibilityKind.Protected;

      triggerMethod.Parameters.Add(new CGParameterDefinition(NetTableDefinitionsCodeGen.EVENT_TRIGGER_PARAMETER_NAME, CGPredefinedTypeReference.String));

      var eventFieldReference := new CGFieldAccessExpression(new CGSelfExpression(), NetTableDefinitionsCodeGen.EVENT_PROPERTY_CHANGING);
      var conditionExpression := new CGBinaryOperatorExpression(eventFieldReference, new CGNilExpression(), CGBinaryOperatorKind.NotEquals);

      var eventArgsInstance := new CGNewInstanceExpression(new CGNamedTypeReference(typeOf(PropertyChangingEventArgs).ToString()), (new CGNamedIdentifierExpression(NetTableDefinitionsCodeGen.EVENT_TRIGGER_PARAMETER_NAME)).AsCallParameter());
      var eventInvokeStatement := new CGMethodCallExpression(eventFieldReference, "Invoke", (new CGSelfExpression()).AsCallParameter(), eventArgsInstance.AsCallParameter());

      triggerMethod.Statements.Add(new CGIfThenElseStatement(conditionExpression, eventInvokeStatement));

      typeDefinition.Members.Add(triggerMethod);
    end;


    method GeneratePropertyChangedEventTrigger(typeDefinition: CGClassTypeDefinition);
    begin
      var triggerMethod := new CGMethodDefinition(NetTableDefinitionsCodeGen.TRIGGER_PROPERTY_CHANGED);
      triggerMethod.Visibility := CGMemberVisibilityKind.Protected;

      triggerMethod.Parameters.Add(new CGParameterDefinition(NetTableDefinitionsCodeGen.EVENT_TRIGGER_PARAMETER_NAME, CGPredefinedTypeReference.String));

      var eventFieldReference := new CGFieldAccessExpression(new CGSelfExpression(), NetTableDefinitionsCodeGen.EVENT_PROPERTY_CHANGED);
      var conditionExpression := new CGBinaryOperatorExpression(eventFieldReference, new CGNilExpression(), CGBinaryOperatorKind.NotEquals);

      var eventArgsInstance := new CGNewInstanceExpression(new CGNamedTypeReference(typeOf(PropertyChangedEventArgs).ToString()), (new CGNamedIdentifierExpression(NetTableDefinitionsCodeGen.EVENT_TRIGGER_PARAMETER_NAME)).AsCallParameter());
      var eventInvokeStatement := new CGMethodCallExpression(eventFieldReference, "Invoke", (new CGSelfExpression()).AsCallParameter(), eventArgsInstance.AsCallParameter());
     
      if self.fFullyFeaturedCodeGen then begin
        conditionExpression := new CGBinaryOperatorExpression(
                                        new CGParenthesesExpression(conditionExpression),
                                        new CGParenthesesExpression(new CGBinaryOperatorExpression(new CGFieldAccessExpression(new CGSelfExpression(), "m____OldValues"), new CGNilExpression(), CGBinaryOperatorKind.Equals)),
                                        CGBinaryOperatorKind.LogicalAnd);

      end;

      triggerMethod.Statements.Add(new CGIfThenElseStatement(conditionExpression, eventInvokeStatement));

      typeDefinition.Members.Add(triggerMethod);
    end;


    method GenerateChangeManagementMethods(typeDefinition: CGClassTypeDefinition);
    begin
      if not self.fFullyFeaturedCodeGen then begin
        exit;
      end;

      var oldValuesField := new CGFieldDefinition(CODE_OLD_VALUES_FIELD, new CGNamedTypeReference(typeDefinition.Name));
      oldValuesField.Visibility := CGMemberVisibilityKind.Private;
      typeDefinition.Members.Add(oldValuesField);

      var beginUpdateMethod := new CGMethodDefinition("BeginUpdate");
      beginUpdateMethod.Visibility := CGMemberVisibilityKind.Public;
      beginUpdateMethod.Statements.Add
        (
          new CGAssignmentStatement
          (
            new CGFieldAccessExpression(new CGSelfExpression(), CODE_OLD_VALUES_FIELD),
            new CGTypeCastExpression
            (
              new CGMethodCallExpression(new CGSelfExpression(), "Clone"),
              new CGNamedTypeReference(typeDefinition.Name)
            )
          )
        );
      typeDefinition.Members.Add(beginUpdateMethod);

      var endUpdateMethod := new CGMethodDefinition("EndUpdate");
      endUpdateMethod.Visibility := CGMemberVisibilityKind.Public;
      endUpdateMethod.Parameters.Add(new CGParameterDefinition("dataAdapter", new CGNamedTypeReference("RemObjects.DataAbstract.Linq.LinqDataAdapter")));

      var updateMethodCall := new CGMethodCallExpression
          (
            new CGNamedIdentifierExpression("dataAdapter"),
            "UpdateRow",
            new CGFieldAccessExpression(new CGSelfExpression(), CODE_OLD_VALUES_FIELD).AsCallParameter(),
            new CGSelfExpression().AsCallParameter()
          );
      updateMethodCall.GenericArguments := new List<CGTypeReference>([ new CGNamedTypeReference(typeDefinition.Name) ]);

      endUpdateMethod.Statements.Add(updateMethodCall);

      endUpdateMethod.Statements.Add
        (
          new CGAssignmentStatement
          (
            new CGFieldAccessExpression(new CGSelfExpression(), CODE_OLD_VALUES_FIELD),
            new CGNilExpression()
          )
        );


      typeDefinition.Members.Add(endUpdateMethod);

      var cancelUpdateMethod := new CGMethodDefinition("CancelUpdate");
      cancelUpdateMethod.Visibility := CGMemberVisibilityKind.Public;
      cancelUpdateMethod.Statements.Add
        (
          new CGAssignmentStatement
          (
            new CGFieldAccessExpression(new CGSelfExpression(), CODE_OLD_VALUES_FIELD),
            new CGNilExpression()
          )
        );
      typeDefinition.Members.Add(cancelUpdateMethod);
    end;


    method GenerateDataContext(items: List<CGTypeDefinition>);
    begin
      var dataContext := new CGClassTypeDefinition("DataContext");
      dataContext.Partial := true;
      dataContext.Visibility := CGTypeVisibilityKind.Public;

      var constructorDefinition := new CGConstructorDefinition();
      constructorDefinition.Visibility := CGMemberVisibilityKind.Public;
      dataContext.Members.Add(constructorDefinition);

      for each table in items do begin
        var field := new CGFieldDefinition(NetTableDefinitionsCodeGen.CODE_FIELD_PREFIX + table.Name);
        field.Type := new CGNamedTypeReference("System.Collections.Generic.IEnumerable",
                        GenericArguments := new List<CGTypeReference>([ new CGNamedTypeReference(table.Name) ]));
        dataContext.Members.Add(field);

        var tableFieldReference := new CGFieldAccessExpression(new CGSelfExpression(), field.Name);

        var tableProperty := new CGPropertyDefinition(table.Name, field.Type, new List<CGStatement>(), new List<CGStatement>());
        tableProperty.Visibility := CGMemberVisibilityKind.Public;
        tableProperty.GetStatements.Add(new CGReturnStatement(tableFieldReference));
        tableProperty.SetStatements.Add(new CGAssignmentStatement(tableFieldReference, new CGPropertyValueExpression()));
        dataContext.Members.Add(tableProperty);
      end;

      self.fCodeUnit.Types.Add(dataContext);
    end;


    method GenerateCode(): String;
    begin
      exit self.fCodeGenerator.GenerateUnit(self.fCodeUnit);
    end;

  public
    constructor(generator: CGCodeGenerator;  fullCodeGen: Boolean);
    begin
      self.fCodeGenerator := generator;
      self.fFullyFeaturedCodeGen := fullCodeGen;
    end;


    method Generate(schema: Schema;  schemaName: String;  schemaUri: String;  &namespace: String;  skippedTables: ICollection<String>;  includePrivateTables: Boolean): String;
    begin
      self.GenerateUnit(schema, schemaName, schemaUri, &namespace, skippedTables, includePrivateTables);

      var code: String := self.GenerateCode();

      self.fCodeUnit := nil;
      exit code;
    end;
  end;


end.