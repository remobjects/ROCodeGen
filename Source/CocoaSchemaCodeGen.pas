namespace RemObjects.DataAbstract.CodeGen4;

interface

uses
  System,
  System.Collections.Generic,
  System.Text,
  RemObjects.CodeGen4,
  RemObjects.SDK.CodeGen4,
  RemObjects.DataAbstract.Schema;

type
  [System.Reflection.ObfuscationAttribute(Exclude := True, ApplyToMembers := True)]
  CocoaTableDefinitionsCodeGen = public class
  private
    var fLanguage: String; readonly;

    class method BuildCodegenModelForSchemaField(field: SchemaField): CGPropertyDefinition;
    class method BuildCodegenModelForSchemaTable(table: SchemaDataTable): CGTypeDefinition;
    class method BuildCodegenModelForSchema(schema: Schema;  skippedTables: ICollection<String>;  &namespace: String;  includePrivateTables: Boolean): CGCodeUnit;
  public
    constructor(language: String);

    method Generate(schema: Schema;  schemaName: String;  schemaUri: String;  &namespace: String;  skippedTables: ICollection<String>;  includePrivateTables: Boolean): String;
  end;


implementation


constructor CocoaTableDefinitionsCodeGen(language: String);
begin
  self.fLanguage := language;
end;


method CocoaTableDefinitionsCodeGen.Generate(schema: Schema;  schemaName: String;  schemaUri: String;  &namespace: String;  skippedTables: ICollection<String>;  includePrivateTables: Boolean): String;
begin
  var gen: CGCodeGenerator := nil;
  case self.fLanguage.ToLowerInvariant() of
    'oxygene', 'pas', '.pas':    gen := new CGOxygeneCodeGenerator();
    'hydrogene' , 'cs', '.cs':   gen := new CGCSharpCodeGenerator(Dialect := CGCSharpCodeGeneratorDialect.Hydrogene);
    'silver', 'swift', '.swift': gen := new CGSwiftCodeGenerator(Dialect := CGSwiftCodeGeneratorDialect.Silver);
    'iodine', 'java', '.java':   gen := new CGJavaCodeGenerator(Dialect := CGJavaCodeGeneratorDialect.Iodine);
    else raise new NotSupportedException(String.Format('Unable to generate Cocoa Table Definitions. Unsupported language {0}', self.fLanguage));
  end;

  //gen.useTabs := false;
  var lUnit := CocoaTableDefinitionsCodeGen.BuildCodegenModelForSchema(schema, skippedTables, &namespace, includePrivateTables);
  //gen.Build(cgModel);
  var code: String := gen.GenerateUnit(lUnit);

  var lResult: StringBuilder := new StringBuilder();
  lResult.AppendLine("//------------------------------------------------------------------------------");
  lResult.AppendLine("// This file was auto-generated.");

  if not String.IsNullOrEmpty(schemaName) then
    lResult.AppendLine(String.Format('//#DA Schema Name:"{0}"', schemaName));

  if not String.IsNullOrEmpty(schemaUri) then
    lResult.AppendLine(String.Format('//#DA Schema Source:"{0}"', schemaUri));

  if includePrivateTables then
    lResult.Append('//#DA Add Private Tables');

  if skippedTables.Count > 0 then begin
    lResult.Append('//#DA Skipped Tables:"');
    for each table in skippedTables index i do begin
      if i > 0 then
        lResult.Append(',');
      lResult.Append(table);
    end;
    lResult.AppendLine('"');
  end;

  lResult.AppendLine("//------------------------------------------------------------------------------");
  lResult.AppendLine(code);

  exit lResult.ToString();
end;


class method CocoaTableDefinitionsCodeGen.BuildCodegenModelForSchemaField(field: SchemaField): CGPropertyDefinition;
begin
  var typeRef: CGTypeReference := nil;
  case field.DataType of
    DataType.String,
    DataType.WideString,
    DataType.FixedChar,
    DataType.FixedWideChar,
    DataType.Memo,
    DataType.WideMemo:
      typeRef := CGPredefinedTypeReference.String;

    DataType.DateTime:
      typeRef := new CGNamedTypeReference('NSDate') isClassType(true); // DefaultNullability will be set to CGTypeNullabilityKind.NullableUnwrapped by constructor

    DataType.Float,
    DataType.Currency,
    DataType.AutoInc,
    DataType.Integer,
    DataType.LargeInt,
    DataType.Boolean,
    DataType.LargeAutoInc,
    DataType.Byte,
    DataType.ShortInt,
    DataType.Word,
    DataType.SmallInt,
    DataType.Cardinal,
    DataType.LargeUInt,
    DataType.Decimal,
    DataType.SingleFloat:
      typeRef := new CGNamedTypeReference('NSNumber') isClassType(true); // DefaultNullability will be set to CGTypeNullabilityKind.NullableUnwrapped by constructor

    DataType.Xml:
      typeRef := new CGNamedTypeReference('ROXML') isClassType(true); // DefaultNullability will be set to CGTypeNullabilityKind.NullableUnwrapped by constructor
    DataType.Guid:
      typeRef := new CGNamedTypeReference('ROGUID') isClassType(true); // DefaultNullability will be set to CGTypeNullabilityKind.NullableUnwrapped by constructor
    DataType.Blob:
      typeRef := new CGNamedTypeReference('NSData') isClassType(true); // DefaultNullability will be set to CGTypeNullabilityKind.NullableUnwrapped by constructor

    else
      typeRef := new CGNamedTypeReference('UNSUPPORTED_TYPE_' + field.DataType.ToString());
  end;

  {var nonAtomicModifier: CGModifierTypeRef := new CGModifierTypeRef();
  nonAtomicModifier.Type := CGModifierType.Nonatomic;
  nonAtomicModifier.SubType := typeRef;

  var strongModifier: CGModifierTypeRef := new CGModifierTypeRef();
  strongModifier.Type := CGModifierType.Strong;
  strongModifier.SubType := nonAtomicModifier; // nested}

  result := new CGPropertyDefinition(field.Name, typeRef);
  result.Visibility := CGMemberVisibilityKind.Unspecified;
  result.Dynamic := true;
  result.Atomic := false;
end;


class method CocoaTableDefinitionsCodeGen.BuildCodegenModelForSchemaTable(table: SchemaDataTable): CGTypeDefinition;
begin
  var name := table.Name.Replace('.', '');
  var t := new CGInterfaceTypeDefinition(String.Format('I{0}Row_Protocol', name));
  t.Visibility := CGTypeVisibilityKind.Public;

  for each f: SchemaField in table.Fields do
    t.Members.Add(CocoaTableDefinitionsCodeGen.BuildCodegenModelForSchemaField(f));

  result := t;
end;


class method CocoaTableDefinitionsCodeGen.BuildCodegenModelForSchema(schema: Schema;  skippedTables: ICollection<String>;  &namespace: String;  includePrivateTables: Boolean): CGCodeUnit;
begin
  var ns: CGNamespaceReference := iif(not String.IsNullOrEmpty(&namespace), new CGNamespaceReference(&namespace), nil);
  var f := new CGCodeUnit(ns);
  f.Imports.Add(new CGImport('Foundation'));
  f.Imports.Add(new CGImport('DataAbstract'));

  // Get Schema Tables list
  var lSchemaTables: ICollection<SchemaDataTable> := schema.GetAllDatasets(not includePrivateTables);
  for each table: SchemaDataTable in lSchemaTables do begin
    if skippedTables.Contains(table.Name) then
      continue;

    var t := CocoaTableDefinitionsCodeGen.BuildCodegenModelForSchemaTable(table);
    f.Types.Add(t)
  end;

  exit f;
end;


end.