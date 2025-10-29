namespace RemObjects.SDK.CodeGen4;

interface

type
  PhpRodlCodeGen = public class(RodlCodeGen)
  private
    method _FixDataType(aValue: String): String;
    method GetScalarType(aValue: String): CGTypeReference;
    method GetGlobalVariable(aName: String): CGExpression;
    method GenerateCustomAttributeHandlers(aType: CGTypeDefinition; aRodlEntity: RodlEntity); empty;
    method GenerateXsDateTimeClass(file: CGCodeUnit; aLibrary: RodlLibrary);
    method Decrement1(aExpression: CGExpression): CGExpression;
    method GenerateHelper(file: CGCodeUnit; aLibrary: RodlLibrary);
    method IsScalar(aLibrary: RodlLibrary; aDataType: String): Boolean;
    method Generate_FromXmlRpcVal_Body(aLibrary: RodlLibrary; aStruct: RodlStructEntity; aList: List<CGStatement>);
    method Generate_ToXmlRpcVal_Body(aLibrary: RodlLibrary; aStruct: RodlStructEntity; aList: List<CGStatement>);
    property HelperName: CGExpression;
    method ParamToComment(aLibrary: RodlLibrary; aParam: RodlParameter): String;
    method GenerateServiceMethod_WriteParam(aLibrary: RodlLibrary; aParam: RodlParameter; msg: CGExpression): CGStatement;
    method GenerateServiceMethod_ReadParam(aLibrary: RodlLibrary; aParam: RodlParameter; aRes: CGExpression): CGExpression;
    method GenerateServiceMethod(aLibrary: RodlLibrary; aService: RodlService; aOperation: RodlOperation): CGMethodDefinition;
  protected
    property EnumBaseType: CGTypeReference read nil; override;
    method AddUsedNamespaces(file: CGCodeUnit; aLibrary: RodlLibrary); override;

    method GetGlobalName(aLibrary: RodlLibrary): String; override; empty;
    method AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary); override;
    method GenerateStructs(aFile: CGCodeUnit; aLibrary: RodlLibrary); override;
    method GenerateExceptions(file: CGCodeUnit; aLibrary: RodlLibrary); override;
    method GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum); override;
    method GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct); override;
    method GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray); override;
    method GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException); override;
    method GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService); override;
    method GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink); override;

  public
    property MergeAll: Boolean := true; override;
    property GenerateTypes: Boolean := false;
  end;

implementation

method PhpRodlCodeGen._FixDataType(aValue: String): String;
begin
  var l_lower := aValue.ToLowerInvariant;
  case l_lower of
    "integer": exit "int";
    "datetime": exit "dateTime.iso8601";
    "double": exit "double";
    "currency": exit "string";
    "widestring": exit "string";
    "ansistring": exit "string";
    "utf8string": exit "string";
    "int64": exit "string";
    "boolean": exit "boolean";
    "variant": exit "variant";
    "binary": exit "base64";
    "xml": exit "string";
    "guid": exit "string";
    "decimal": exit "string";
    "nullableinteger": exit "int";
    "nullabledouble": exit "double";
    "nullableboolean": exit "boolean";
    "nullabledatetime": exit "dateTime.iso8601";
    "nullablecurrency": exit "string";
    "nullableint64": exit "string";
    "nullableguid": exit "string";
    "nullabledecimal": exit "string";
  else
    exit "int"; // for enums
  end;
end;

method PhpRodlCodeGen.AddGlobalConstants(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  inherited;
  HelperName := $"{aLibrary.Name}Helpers".AsNamedIdentifierExpression;

  aFile.HeaderComment.Lines.Add("");
  aFile.HeaderComment.Lines.Add("This file depends on the PHP xmlrpc library from:");
  aFile.HeaderComment.Lines.Add("http://gggeek.github.io/phpxmlrpc/");
  aFile.HeaderComment.Lines.Add("");

  aFile.HeaderComment.Lines.Add("* _with_SessionID methods were deprecated. use UseSession & SessionID properties instead.");
  aFile.HeaderComment.Lines.Add("");

  var f := false;
  for each svc: RodlService in aLibrary.Services.Items do
    for each op in svc.DefaultInterface.Items do
      for each p in op.Items do
        if p.ParamFlag in [ParamFlags.Out, ParamFlags.InOut] then begin
          if not f then begin
            aFile.HeaderComment.Lines.Add("Out and InOut parameters are supported only if WrapResult property is set to true on both sides (client and server)");
            f := true;
          end;
          aFile.HeaderComment.Lines.Add($"  * {svc.Name}.{op.Name}");
          break;
        end;
end;

method PhpRodlCodeGen.GenerateEnum(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEnum);
begin
  inherited;
end;

method PhpRodlCodeGen.GenerateStruct(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlStruct);
begin
  var lstruct := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name));
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    lstruct.Ancestors.Add(aEntity.AncestorName.AsTypeReference);
  lstruct.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(lstruct);

  for lm :RodlTypedEntity in aEntity.Items do begin
    var l_type :=
      if not isEnum(aLibrary, lm.DataType) and IsScalar(aLibrary, lm.DataType) then
        GetScalarType(lm.DataType)
      else
        lm.DataType.AsTypeReference;

    var l_prop := new CGPropertyDefinition($"${lm.Name}",
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Comment := new CGCommentStatement(lm.DataType)
                                          );
    if GenerateTypes then l_prop.Type := l_type;
    lstruct.Members.Add(l_prop);
  end;

  lstruct.Members.Add(new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Unspecified));

  /* FromXmlRpcVal */
  var l_method := new CGMethodDefinition("FromXmlRpcVal",
                                    &Static := true,
                                    Visibility := CGMemberVisibilityKind.Unspecified);
  if GenerateTypes then l_method.ReturnType := lstruct.Name.AsTypeReference;
  var l_p_n := new CGParameterDefinition("$n");
  l_method.Parameters.Add(l_p_n);
  if GenerateTypes then l_p_n.Type := CGPredefinedTypeReference.Dynamic;
  var l_res := new CGVariableDeclarationStatement("$res", nil, new CGNewInstanceExpression(lstruct.Name.AsTypeReference));
  l_method.Statements.Add(l_res);
  Generate_FromXmlRpcVal_Body(aLibrary, aEntity, l_method.Statements);
  l_method.Statements.Add(l_res.AsExpression.AsReturnStatement);
  lstruct.Members.Add(l_method);

  /* ToXmlRpcVal */
  l_method := new CGMethodDefinition("ToXmlRpcVal",
                                &Static := true,
                                Visibility := CGMemberVisibilityKind.Unspecified);
  if GenerateTypes then l_method.ReturnType := "xmlrpcval".AsTypeReference;
  var l_p_data := new CGParameterDefinition("$data");
  if GenerateTypes then l_p_data.Type := CGPredefinedTypeReference.Dynamic;
  l_method.Parameters.Add(l_p_data);
  l_res := new CGVariableDeclarationStatement("$res", nil,new CGNewInstanceExpression("xmlrpcval".AsTypeReference));
  l_method.Statements.Add(l_res);
  var l_arr := new CGVariableDeclarationStatement("$arr", nil, new CGMethodCallExpression(nil, "array"));
  l_method.Statements.Add(l_arr);
  Generate_ToXmlRpcVal_Body(aLibrary, aEntity, l_method.Statements);
  l_method.Statements.Add(new CGMethodCallExpression(l_res.AsExpression,"addStruct",[l_arr.AsCallParameter]));
  l_method.Statements.Add(l_res.AsExpression.AsReturnStatement);
  lstruct.Members.Add(l_method);

  /* FromArray */
  l_method := new CGMethodDefinition("FromArray",
                                &Static := true,
                                Visibility := CGMemberVisibilityKind.Unspecified);
  if GenerateTypes then l_method.ReturnType := "xmlrpcval".AsTypeReference;
  l_p_data := new CGParameterDefinition("$data");
  if GenerateTypes then l_p_data.Type := CGPredefinedTypeReference.Dynamic;
  l_method.Parameters.Add(l_p_data);
  /*
    static function FromArray($data)
    {
        $items = array();
        for ($i = 0; $i < sizeof($data); $i++) {
            $items[$i] = UserInfo::ToXmlRpcVal($data[$i]);
        }
        $res = new xmlrpcval();
        $res->addArray($items);
        return $res;
    }
  */
  var l_items := new CGVariableDeclarationStatement("$items", nil, new CGMethodCallExpression(nil, "array"));
  l_method.Statements.Add(l_items);
  var l_i := new CGVariableDeclarationStatement("$i",nil);
  l_method.Statements.Add(
      new CGForToLoopStatement(l_i.Name,
                               new CGNamedTypeReference(""),
                               0.AsLiteralExpression,
                               Decrement1(new CGSizeOfExpression(l_p_data.AsExpression)),
                               new CGAssignmentStatement(new CGArrayElementAccessExpression(l_items.AsExpression,[l_i.AsExpression]),
                                                         new CGMethodCallExpression(lstruct.Name.AsNamedIdentifierExpression,
                                                                                    "ToXmlRpcVal",
                                                                                    [new CGArrayElementAccessExpression(l_p_data.AsExpression,
                                                                                                                        [l_i.AsExpression]).AsCallParameter],
                                                                                    CallSiteKind := CGCallSiteKind.Static))

                                ));
  l_res := new CGVariableDeclarationStatement("$res", nil,new CGNewInstanceExpression("xmlrpcval".AsTypeReference));
  l_method.Statements.Add(l_res);
  l_method.Statements.Add(new CGMethodCallExpression(l_res.AsExpression, "addArray", [l_items.AsCallParameter]));
  l_method.Statements.Add(l_res.AsExpression.AsReturnStatement);
  lstruct.Members.Add(l_method);

  /* ToArray */
  /*
    static function ToArray($data)
    {
        $items = array();
        for ($i = 0; $i < $data->arraysize(); $i++)
           $items[$i] = UserInfo::FromXmlRpcVal($data->arraymem($i));
        return $items;
    }
  */
  l_method := new CGMethodDefinition("ToArray",
                                &Static := true,
                                Visibility := CGMemberVisibilityKind.Unspecified);
  if GenerateTypes then l_method.ReturnType := "array".AsTypeReference;
  l_p_data := new CGParameterDefinition("$data");
  if GenerateTypes then l_p_data.Type := CGPredefinedTypeReference.Dynamic;
  l_method.Parameters.Add(l_p_data);
  l_items := new CGVariableDeclarationStatement("$items", nil, new CGMethodCallExpression(nil, "array"));
  l_method.Statements.Add(new CGForToLoopStatement(
                              l_i.Name,
                              new CGNamedTypeReference(""),
                              0.AsLiteralExpression,
                              Decrement1(new CGMethodCallExpression(l_p_data.AsExpression, "arraysize")),
                              new CGAssignmentStatement(
                                   new CGArrayElementAccessExpression(l_items.AsExpression,[l_i.AsExpression]),
                                   new CGMethodCallExpression(lstruct.Name.AsNamedIdentifierExpression,
                                                              "FromXmlRpcVal",
                                                              [new CGMethodCallExpression(l_p_data.AsExpression, "arraymem",
                                                                                          [l_i.AsCallParameter]).AsCallParameter],
                                                              CallSiteKind := CGCallSiteKind.Static))
                         ));

  l_method.Statements.Add(l_items.AsExpression.AsReturnStatement);
  lstruct.Members.Add(l_method);
end;

method PhpRodlCodeGen.GenerateArray(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlArray);
begin
  inherited;
end;

method PhpRodlCodeGen.GenerateException(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlException);
begin
  var lAncestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lAncestorName) then lAncestorName := "Exception";
  var l_SafeEntityName := SafeIdentifier(aEntity.Name);

  var ltype := new CGClassTypeDefinition(l_SafeEntityName, lAncestorName.AsTypeReference_NotNullable);
  ltype.XmlDocumentation := GenerateDocumentation(aEntity);

  for lm :RodlTypedEntity in aEntity.Items do begin
    var l_type :=
      if not isEnum(aLibrary, lm.DataType) and IsScalar(aLibrary, lm.DataType) then
        GetScalarType(lm.DataType)
      else
        lm.DataType.AsTypeReference;
    var l_p := new CGPropertyDefinition($"${lm.Name}",
                                        Visibility := CGMemberVisibilityKind.Public,
                                        Comment := new CGCommentStatement(lm.DataType)
                                        );
    if GenerateTypes then l_p.Type := l_type;
    ltype.Members.Add(l_p);
  end;
  aFile.Types.Add(ltype);
end;

method PhpRodlCodeGen.GenerateService(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlService);
begin
  var l_service := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name));
  if not String.IsNullOrEmpty(aEntity.AncestorName) then
    l_service.Ancestors.Add(aEntity.AncestorName.AsTypeReference);
  l_service.XmlDocumentation := GenerateDocumentation(aEntity);
  aFile.Types.Add(l_service);
  l_service.Members.Add(new CGPropertyDefinition("$WrappedResult",
                                                 Visibility := CGMemberVisibilityKind.Public,
                                                 Initializer := CGBooleanLiteralExpression.False));
  l_service.Members.Add(new CGPropertyDefinition("$SessionID",
                                                 Visibility := CGMemberVisibilityKind.Public,
                                                 Initializer := "00000000-0000-0000-0000-000000000000".AsLiteralExpression));
  l_service.Members.Add(new CGPropertyDefinition("$UseSession",
                                                 Visibility := CGMemberVisibilityKind.Public,
                                                 Initializer := CGBooleanLiteralExpression.False));
  l_service.Members.Add(new CGPropertyDefinition("$___server",
                                                 Visibility := CGMemberVisibilityKind.Private));
  /* ------------------------------------------------------------------- */
  /* constructor

    function __construct($path, $server='', $port='', $method='') {
        $this->$___server = new xmlrpc_client($path, $server, $port, $method);
    }
  */
  var l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Unspecified);
  var l_p_path := new CGParameterDefinition("$path");
  if GenerateTypes then l_p_path.Type := CGPredefinedTypeReference.String;
  var l_p_server := new CGParameterDefinition("$server", DefaultValue := "".AsLiteralExpression);
  if GenerateTypes then l_p_server.Type := CGPredefinedTypeReference.String;
  var l_p_port   := new CGParameterDefinition("$port",   DefaultValue := "".AsLiteralExpression);
  if GenerateTypes then l_p_port.Type := CGPredefinedTypeReference.String;
  var l_p_method := new CGParameterDefinition("$method", DefaultValue := "".AsLiteralExpression);
  if GenerateTypes then l_p_method.Type := CGPredefinedTypeReference.String;
  l_ctor.Parameters.Add(l_p_path);
  l_ctor.Parameters.Add(l_p_server);
  l_ctor.Parameters.Add(l_p_port);
  l_ctor.Parameters.Add(l_p_method);
//  l_ctor.Statements.Add(new CGAssignmentStatement(GetGlobalVariable("xmlrpc_internalencoding"), "UTF-8".AsLiteralExpression));

  var l_php := new CGNamedTypeReference("PhpXmlRpc") &namespace(new CGNamespaceReference("PhpXmlRpc")).AsExpression;
  l_ctor.Statements.Add(
    new CGAssignmentStatement(
      new CGFieldAccessExpression(l_php,"$xmlrpc_null_extension",CallSiteKind := CGCallSiteKind.Static),
      CGBooleanLiteralExpression.True)
    );
  l_ctor.Statements.Add(
    new CGAssignmentStatement(
      new CGFieldAccessExpression(l_php,"$xmlrpc_internalencoding",CallSiteKind := CGCallSiteKind.Static),
      "UTF-8".AsLiteralExpression)
    );
  l_ctor.Statements.Add(new CGMethodCallExpression(l_php,"exportGlobals", CallSiteKind := CGCallSiteKind.Static));


  var _serv := new CGFieldAccessExpression(CGSelfExpression.Self, "___server");
  l_ctor.Statements.Add(
     new CGAssignmentStatement(
       _serv,
       new CGNewInstanceExpression("xmlrpc_client".AsTypeReference,
                                   [l_p_path.AsCallParameter, l_p_server.AsCallParameter, l_p_port.AsCallParameter, l_p_method.AsCallParameter])
     ));
  l_ctor.Statements.Add(
     new CGAssignmentStatement(
        new CGFieldAccessExpression(_serv, "request_charset_encoding"),
        "UTF-8".AsLiteralExpression
     ));
  l_ctor.Statements.Add(
     new CGCodeCommentStatement(
     new CGAssignmentStatement(
        new CGFieldAccessExpression(_serv, "use_curl"),
        new CGFieldAccessExpression("xmlrpc_client".AsNamedIdentifierExpression,
                                    "USE_CURL_ALWAYS",
                                    CallSiteKind := CGCallSiteKind.Static)
     )));

  l_service.Members.Add(l_ctor);
  /* ------------------------------------------------------------------- */

  /*
    function GetXmlRpcClient() {
        return $this->$___server;
    }
  */
  l_service.Members.Add(new CGMethodDefinition("GetXmlRpcClient",
                                               [_serv.AsReturnStatement],
                                               ReturnType := "xmlrpc_client".AsTypeReference,
                                               Visibility := CGMemberVisibilityKind.Unspecified));
  /* ------------------------------------------------------------------- */
  for each op in aEntity.DefaultInterface.Items do
    l_service.Members.Add(GenerateServiceMethod(aLibrary, aEntity, op));


end;

method PhpRodlCodeGen.GenerateEventSink(aFile: CGCodeUnit; aLibrary: RodlLibrary; aEntity: RodlEventSink);
begin
  inherited;
end;


method PhpRodlCodeGen.GenerateExceptions(file: CGCodeUnit; aLibrary: RodlLibrary);
begin
  inherited;
  GenerateHelper(file, aLibrary);
end;

method PhpRodlCodeGen.GetGlobalVariable(aName: String): CGExpression;
begin
  exit new CGArrayElementAccessExpression("$GLOBALS".AsNamedIdentifierExpression, aName.AsLiteralExpression);
end;

method PhpRodlCodeGen.GenerateHelper(file: CGCodeUnit; aLibrary: RodlLibrary);
begin
  var l_t := new CGClassTypeDefinition($"{aLibrary.Name}Helpers");
  /*---------------------------------------------------------------*/
  var l_member := new CGMethodDefinition("RaiseException",
                                          &Static := true,
                                          Visibility := CGMemberVisibilityKind.Unspecified);
  var l_p_message := new CGParameterDefinition("$message");
  if GenerateTypes then l_p_message.Type := CGPredefinedTypeReference.String;
  l_member.Parameters.Add(l_p_message);
  var l_i := new CGVariableDeclarationStatement("$i", nil, new CGMethodCallExpression(nil, "strpos",
                                                                      [":".AsLiteralExpression.AsCallParameter,
                                                                       l_p_message.AsCallParameter]));
  l_member.Statements.Add(l_i);
  var l_else := new CGBeginEndBlockStatement;
  var l_throw: CGStatement := new CGThrowExpression(new CGNewInstanceExpression("Exception".AsTypeReference,
                                                                                [l_p_message.AsCallParameter]));
  var l_class := new CGVariableDeclarationStatement("$class", nil, new CGMethodCallExpression(nil, "substr",
                                                                        [l_p_message.AsCallParameter,
                                                                        0.AsLiteralExpression.AsCallParameter,
                                                                        l_i.AsCallParameter]));
  l_else.Statements.Add(l_class);
  var l_submsg := new CGVariableDeclarationStatement("$submsg", nil, new CGMethodCallExpression(nil, "substr",
                                                                              [l_p_message.AsCallParameter,
                                                                               new CGBinaryOperatorExpression(
                                                                                 l_i.AsExpression,
                                                                                 1.AsLiteralExpression,
                                                                                 CGBinaryOperatorKind.Addition
                                                                                ).AsCallParameter]));
  l_else.Statements.Add(l_submsg);
  var l_cases:= new List<CGSwitchStatementCase>();
  for each it in aLibrary.Exceptions.SortedByAncestor.ToList do
    l_cases.Add(
      new CGSwitchStatementCase(
        it.Name.AsLiteralExpression,
        [new CGThrowExpression(new CGNewInstanceExpression(it.Name.AsTypeReference,[l_submsg.AsCallParameter])) as CGStatement].ToList
      ));
  l_else.Statements.Add(new CGSwitchStatement(l_class.AsExpression,
                                              l_cases.ToArray,
                                              [l_throw].ToList));

  l_member.Statements.Add(
    new CGIfThenElseStatement(
      new CGBinaryOperatorExpression(l_i.AsExpression,
                                     0.AsLiteralExpression,
                                     CGBinaryOperatorKind.LessThanOrEquals),
      l_throw,
      l_else));

  l_t.Members.Add(l_member);
/*---------------------------------------------------------------*/
  l_member := new CGMethodDefinition("FromArray",
                                      &Static := true,
                                      Comment := new CGCommentStatement("Scalar from array"),
                                      Visibility := CGMemberVisibilityKind.Unspecified
                                      );
  if GenerateTypes then l_member.ReturnType := "xmlrpcval".AsTypeReference;
  var l_p_data := new CGParameterDefinition("$data");
  if GenerateTypes then l_p_data.Type := CGPredefinedTypeReference.Dynamic;
  var l_p_subtype := new CGParameterDefinition("$subtype");
  if GenerateTypes then l_p_subtype.Type := CGPredefinedTypeReference.String;
  l_member.Parameters.Add(l_p_data);
  l_member.Parameters.Add(l_p_subtype);

  var l_items := new CGVariableDeclarationStatement("$items", nil, new CGMethodCallExpression(nil, "array"));
  l_member.Statements.Add(l_items);
  l_member.Statements.Add(new CGForToLoopStatement(
                              l_i.Name,
                              new CGNamedTypeReference(""),
                              0.AsLiteralExpression,
                              Decrement1(new CGSizeOfExpression(l_p_data.AsExpression)),
                              new CGAssignmentStatement(
                                   new CGArrayElementAccessExpression(l_items.AsExpression,[l_i.AsExpression]),
                                   new CGNewInstanceExpression("xmlrpcval".AsTypeReference,
                                                               [new CGArrayElementAccessExpression(l_p_data.AsExpression,[l_i.AsExpression]).AsCallParameter,
                                                                l_p_subtype.AsCallParameter])
                                    )
                         ));
  var l_res := new CGVariableDeclarationStatement("$res", nil, new CGNewInstanceExpression("xmlrpcval".AsTypeReference));
  l_member.Statements.Add(l_res);
  l_member.Statements.Add(new CGMethodCallExpression(l_res.AsExpression,"addArray",[l_items.AsCallParameter]));
  l_member.Statements.Add(l_res.AsExpression.AsReturnStatement);


  l_t.Members.Add(l_member);
/*---------------------------------------------------------------*/
/*
// Scalar to array
static function ToArray($data)
{
    $items = array();
    for ($i = 0; $i < $data->arraysize(); $i++) $items[$i] = $data->arraymem($i)->scalarval();
    return $items;
}
*/

  l_member := new CGMethodDefinition("ToArray",
                                      &Static := true,
                                      Comment := new CGCommentStatement("Scalar to array"),
                                      Visibility := CGMemberVisibilityKind.Unspecified);
  if GenerateTypes then l_member.ReturnType := CGPredefinedTypeReference.Dynamic;
  l_member.Parameters.Add(l_p_data);
  if GenerateTypes then l_p_data.Type := CGPredefinedTypeReference.Dynamic;
  l_member.Statements.Add(new CGAssignmentStatement(
                                               l_items.AsExpression,
                                               new CGMethodCallExpression(nil, "array")
                          ));
  l_member.Statements.Add(new CGForToLoopStatement(
                              l_i.Name,
                              new CGNamedTypeReference(""),
                              0.AsLiteralExpression,
                              Decrement1(new CGMethodCallExpression(l_p_data.AsExpression, "arraysize")),
                              new CGAssignmentStatement(
                                   new CGArrayElementAccessExpression(l_items.AsExpression,[l_i.AsExpression]),
                                   new CGMethodCallExpression(
                                         new CGMethodCallExpression(l_p_data.AsExpression,
                                                                    "arraymem",[l_i.AsCallParameter]),
                                         "scalarval"
                                    ))
                         ));
  l_member.Statements.Add(l_items.AsExpression.AsReturnStatement);
  l_t.Members.Add(l_member);
  file.Types.Add(l_t);
end;

method PhpRodlCodeGen.AddUsedNamespaces(file: CGCodeUnit; aLibrary: RodlLibrary);
begin
  file.Imports.Add(new CGPhpImport("xmlrpc.inc", Mode := CGPhpImportMode.RequireOnce));
end;

method PhpRodlCodeGen.Decrement1(aExpression: CGExpression): CGExpression;
begin
  /* aExpression - 1 */
  exit new CGBinaryOperatorExpression(aExpression,
                                      1.AsLiteralExpression,
                                      CGBinaryOperatorKind.Subtraction);
end;

method PhpRodlCodeGen.IsScalar(aLibrary: RodlLibrary; aDataType: String): Boolean;
begin
  aDataType := aDataType.ToLowerInvariant;
  exit isEnum(aLibrary, aDataType) or
    (aDataType in ["integer", "datetime", "double", "currency", "widestring",
                   "ansistring", "string", "int64", "boolean", "variant", "binary", "utf8string",
                   "xml", "guid", "decimal", "nullableboolean", "nullablecurrency",
                   "nullabledatetime", "nullabledecimal", "nullabledouble", "nullableguid",
                   "nullableint64", "nullableinteger"]);
end;

method PhpRodlCodeGen.Generate_FromXmlRpcVal_Body(aLibrary: RodlLibrary; aStruct: RodlStructEntity; aList: List<CGStatement>);
begin
  if (aStruct.AncestorEntity <> nil) and (aStruct.AncestorEntity is RodlStructEntity) then
    Generate_FromXmlRpcVal_Body(aLibrary, aStruct.AncestorEntity as RodlStructEntity, aList);
  var l_res := new CGVariableDeclarationStatement("$res", nil);
  var l_p_n := new CGParameterDefinition("$n");

  for each m in aStruct.Items do begin
    var l_res_name := new CGFieldAccessExpression(l_res.AsExpression, m.Name);
    var l_p_n_structmem := new CGMethodCallExpression(l_p_n.AsExpression, "structmem", [m.Name.AsLiteralExpression.AsCallParameter]);
    var l_value: CGExpression := nil;
    if isEnum(aLibrary, m.DataType) then
      l_value := new CGMethodCallExpression(nil,"constant",
                                           [new CGBinaryOperatorExpression((m.DataType+"::").AsLiteralExpression,
                                            new CGMethodCallExpression(l_p_n_structmem,"scalarval"),
                                            CGBinaryOperatorKind.Concat).AsCallParameter])
    else if IsScalar(aLibrary, m.DataType) then
      //$res->NewField2 = $n->structmem("NewField2")->scalarval();
      l_value := new CGMethodCallExpression(l_p_n_structmem,"scalarval")
    else begin
      var ar := aLibrary.Arrays.FindEntity(m.DataType);
      if assigned(ar) then begin
        if IsScalar(aLibrary, ar.ElementType) then
          // $res->NewField1 = NewStruct::ToArray($n->structmem("NewField1"));
          l_value := new CGMethodCallExpression(HelperName, "ToArray", [l_p_n_structmem.AsCallParameter], CallSiteKind := CGCallSiteKind.Static)
        else
          //$res->NewField1 = NewStruct::ToArray($n->structmem("NewField1"));
          l_value := new CGMethodCallExpression(m.DataType.AsNamedIdentifierExpression, "ToArray",[l_p_n_structmem.AsCallParameter], CallSiteKind := CGCallSiteKind.Static);
      end
      else
        //$res->NewField3 = NewStruct::FromXmlRpcVal($n->structmem("NewField3"));
        l_value := new CGMethodCallExpression(m.DataType.AsNamedIdentifierExpression, "FromXmlRpcVal",[l_p_n_structmem.AsCallParameter], CallSiteKind := CGCallSiteKind.Static);

    end;
    aList.Add(new CGAssignmentStatement(l_res_name,l_value));
  end;
end;

method PhpRodlCodeGen.Generate_ToXmlRpcVal_Body(aLibrary: RodlLibrary; aStruct: RodlStructEntity; aList: List<CGStatement>);
begin
  if (aStruct.AncestorEntity <> nil) and (aStruct.AncestorEntity is RodlStructEntity) then
    Generate_ToXmlRpcVal_Body(aLibrary, aStruct.AncestorEntity as RodlStructEntity, aList);
  var l_arr := new CGVariableDeclarationStatement("$arr", nil);
  var l_p_data := new CGParameterDefinition("$data");

  for each m in aStruct.Items do begin
    var l_arr_name := new CGArrayElementAccessExpression(l_arr.AsExpression, [m.Name.AsLiteralExpression]);
    var l_prop := new CGFieldAccessExpression(l_p_data.AsExpression, m.Name);
    var l_value: CGExpression := nil;

    if isEnum(aLibrary, m.DataType) then
      l_value := new CGNewInstanceExpression("xmlrpcval".AsTypeReference, [new CGFieldAccessExpression(l_prop, "name").AsCallParameter, "string".AsLiteralExpression.AsCallParameter])
    else if IsScalar(aLibrary, m.DataType) then
      //$arr["NewField"] = new xmlrpcval($data->NewField, "string");
      l_value := new CGNewInstanceExpression("xmlrpcval".AsTypeReference, [l_prop.AsCallParameter, _FixDataType(m.DataType).AsLiteralExpression.AsCallParameter])
    else begin
      var ar := aLibrary.Arrays.FindEntity(m.DataType);
      if assigned(ar) then begin
        if isEnum(aLibrary, ar.ElementType) then
          l_value := new CGMethodCallExpression(HelperName, "FromArray", [l_prop.AsCallParameter, "string".AsLiteralExpression.AsCallParameter], CallSiteKind := CGCallSiteKind.Static)
        else if IsScalar(aLibrary, ar.ElementType) then
          // $arr["NewField1"] = NewLibraryHelpers::FromArray($data->NewField1, "string");
          l_value := new CGMethodCallExpression(HelperName, "FromArray", [l_prop.AsCallParameter, _FixDataType(ar.ElementType).AsLiteralExpression.AsCallParameter], CallSiteKind := CGCallSiteKind.Static)
        else
          //$res->NewField1 = NewStruct::FromArray($data->NewField2, "string");
          l_value := new CGMethodCallExpression(m.DataType.AsNamedIdentifierExpression, "FromArray",[l_prop.AsCallParameter], CallSiteKind := CGCallSiteKind.Static);
      end
      else
        //$arr["NewField3"] = NewStruct::ToXmlRpcVal($data->NewField3, "string");
        l_value := new CGMethodCallExpression(m.DataType.AsNamedIdentifierExpression, "ToXmlRpcVal",[l_prop.AsCallParameter, "string".AsLiteralExpression.AsCallParameter], CallSiteKind := CGCallSiteKind.Static);
    end;
    var l_ass := new CGAssignmentStatement(l_arr_name,l_value);
    if IsNullableType(m.DataType) then
      aList.Add(new CGIfThenElseStatement(new CGBinaryOperatorExpression(l_prop, CGNilExpression.Nil, CGBinaryOperatorKind.Equals),
                                          new CGAssignmentStatement(l_arr_name, new CGNewInstanceExpression("xmlrpcval".AsTypeReference, [CGNilExpression.Nil.AsCallParameter, "null".AsLiteralExpression.AsCallParameter])),
                                          l_ass))
    else
      aList.Add(l_ass);
  end;
end;

method PhpRodlCodeGen.ParamToComment(aLibrary: RodlLibrary; aParam: RodlParameter): String;
begin
  var r := "";
  case aParam.ParamFlag of
    ParamFlags.Out: r := "out ";
    ParamFlags.InOut: r := "var ";
  end;
  exit r + "$" + aParam.Name + ": " + aParam.DataType;
end;

method PhpRodlCodeGen.GenerateServiceMethod(aLibrary: RodlLibrary; aService: RodlService; aOperation: RodlOperation): CGMethodDefinition;
begin
  var lname := aOperation.Name;
  var lresult := new CGMethodDefinition(lname, Visibility := CGMemberVisibilityKind.Unspecified);
  if assigned(aOperation.Result) and GenerateTypes then
    lresult.ReturnType := if not isEnum(aLibrary, aOperation.Result.DataType) and IsScalar(aLibrary, aOperation.Result.DataType) then
                              GetScalarType(aOperation.Result.DataType)
                            else
                              aOperation.Result.DataType.AsTypeReference;

  var f_session := new CGFieldAccessExpression(CGSelfExpression.Self, "SessionID");

  var l_comment := "";
  for each p in aOperation.Items do begin
    var l_type :=
      if not isEnum(aLibrary, p.DataType) and IsScalar(aLibrary, p.DataType) then
        GetScalarType(p.DataType)
      else
        p.DataType.AsTypeReference;
    var l_p := new CGParameterDefinition($"${p.Name}");
    if GenerateTypes then l_p.Type := l_type;
    case p.ParamFlag of
      ParamFlags.Out: l_p.Modifier := CGParameterModifierKind.Out;
      ParamFlags.InOut: l_p.Modifier := CGParameterModifierKind.Var;
    end;
    lresult.Parameters.Add(l_p);
    if l_comment <> "" then l_comment := l_comment + ", ";
    l_comment := l_comment + ParamToComment(aLibrary, p);
  end;
  lresult.Comment :=  new CGCommentStatement(lname + "(" + l_comment + ")");
  var l_msg := new CGVariableDeclarationStatement("$___msg",
                                                  nil,
                                                  new CGNewInstanceExpression("xmlrpcmsg".AsTypeReference,
                                                                              [(aService.Name+"."+aOperation.Name).AsLiteralExpression.AsCallParameter]));
  lresult.Statements.Add(l_msg);
  //$___msg->addParam(new xmlrpcval($SessionId, "string"));
  lresult.Statements.Add(
    new CGIfThenElseStatement(new CGFieldAccessExpression(CGSelfExpression.Self, "UseSession"),
                              new CGMethodCallExpression(l_msg.AsExpression,
                                                      "addParam",
                                                      [new CGNewInstanceExpression("xmlrpcval".AsTypeReference,
                                                          [f_session.AsCallParameter,
                                                          "string".AsLiteralExpression.AsCallParameter]).AsCallParameter
                                                      ])
                              ));
  for p in aOperation.Items do begin
    if p.ParamFlag in [ParamFlags.In, ParamFlags.InOut] then
      lresult.Statements.Add(GenerateServiceMethod_WriteParam(aLibrary, p, l_msg.AsExpression));
  end;

  /* $___res = $this->$___server->send($___msg); */
  var l_res := new CGVariableDeclarationStatement("$___res",
                                                  nil,
                                                  new CGMethodCallExpression(
                                                    new CGMethodCallExpression(CGSelfExpression.Self, "GetXmlRpcClient"),
                                                    "send",
                                                    [l_msg.AsCallParameter]));
  lresult.Statements.Add(l_res);
  /* if ($___res->faultCode()) rbug6520Helpers::RaiseException($___res->faultString());*/
  lresult.Statements.Add(
    new CGIfThenElseStatement(
      new CGMethodCallExpression(l_res.AsExpression,"faultCode"),
      new CGMethodCallExpression(HelperName,
                                 "RaiseException",
                                 [new CGMethodCallExpression(l_res.AsExpression,
                                                             "faultString").AsCallParameter],
                                 CallSiteKind := CGCallSiteKind.Static)
    )
  );
  var l_res_Value := new CGMethodCallExpression(l_res.AsExpression,"value");

  var if_true := new CGBeginEndBlockStatement;
  var if_false := new CGBeginEndBlockStatement;


  lresult.Statements.Add(
    new CGIfThenElseStatement(
      new CGFieldAccessExpression(CGSelfExpression.Self, "WrappedResult"),
      if_true,
      if_false
    ));

  if_true.Statements.Add(
      new CGIfThenElseStatement(
        new CGMethodCallExpression(l_res_Value,
                                   "structMemExists",
                                   ["SessionId".AsLiteralExpression.AsCallParameter]),
        new CGAssignmentStatement(
          f_session,
          new CGMethodCallExpression(
            new CGMethodCallExpression(l_res_Value,
                "structmem",["SessionId".AsLiteralExpression.AsCallParameter]),
            "scalarval")
          )
      )
    );
  var l_var_result := new CGVariableDeclarationStatement("$__result", nil);
  if aOperation.Result <> nil then begin
    if_false.Statements.Add(GenerateServiceMethod_ReadParam(aLibrary, aOperation.Result, l_res_Value).AsReturnStatement);
    l_var_result.Value := GenerateServiceMethod_ReadParam(aLibrary,
                                                          aOperation.Result,
                                                          new CGMethodCallExpression(l_res_Value,
                                                                                     "structmem",
                                                                                     [aOperation.Result.Name.AsLiteralExpression.AsCallParameter]));
    if_true.Statements.Add(l_var_result);
  end;

  for each p in aOperation.Items do begin
    if p.ParamFlag in [ParamFlags.InOut, ParamFlags.Out] then begin
      if_true.Statements.Add(
        new CGAssignmentStatement(new CGParameterAccessExpression($"${p.Name}"),
        GenerateServiceMethod_ReadParam(aLibrary,
                                        p,
                                        new CGMethodCallExpression(l_res_Value,
                                                                   "structmem",
                                                                   [p.Name.AsLiteralExpression.AsCallParameter]))));
    end;
  end;

  if aOperation.Result <> nil then
    if_true.Statements.Add(l_var_result.AsExpression.AsReturnStatement);

  exit lresult;
end;

method PhpRodlCodeGen.GetScalarType(aValue: String): CGTypeReference;
begin
  case aValue.ToLowerInvariant of
    "integer": exit CGPredefinedTypeReference.Int;
    "double": exit CGPredefinedTypeReference.Double;
    "boolean": exit CGPredefinedTypeReference.Boolean;
    "nullableinteger": exit CGPredefinedTypeReference.Int.copyWithNullability(CGTypeNullabilityKind.NullableUnwrapped);
    "nullabledouble": exit CGPredefinedTypeReference.Double.copyWithNullability(CGTypeNullabilityKind.NullableUnwrapped);
    "nullableboolean": exit CGPredefinedTypeReference.Boolean.copyWithNullability(CGTypeNullabilityKind.NullableUnwrapped);
    "nullabledatetime",
    "nullablecurrency",
    "nullableint64",
    "nullableguid",
    "nullabledecimal": exit CGPredefinedTypeReference.String.copyWithNullability(CGTypeNullabilityKind.NullableUnwrapped);
  else
    exit CGPredefinedTypeReference.String;
  end;
end;

method PhpRodlCodeGen.GenerateXsDateTimeClass(file: CGCodeUnit; aLibrary: RodlLibrary);
begin
  var str := new RodlStruct(Name := "XsDateTime");
  str.Items.Add(new RodlField(Name := "DateTime", DataType := "DateTime"));
  str.Items.Add(new RodlField(Name := "TimeZoneOffset", DataType := "Integer"));
  GenerateStruct(file, aLibrary, str);
  if file.Types.Last:Name = "XsDateTime" then begin
    //var l_ctor := new CGConstructorDefinition(Visibility := CGMemberVisibilityKind.Unspecified);
    var list := file.Types.Last.Members.Where(b->b is CGConstructorDefinition);
    if list.Count = 1 then begin
      var l_ctor := list.First as CGConstructorDefinition;
      var l_p_dt := new CGPhpConstructorParameterDefinition("$DT",
                                                            DefaultValue := CGNilExpression.Nil
                                                            //,Visibility := CGPhpConstructorParameterVisibility.Public
                                                            );
      var l_p_offset := new CGPhpConstructorParameterDefinition("$Offset",
                                                                DefaultValue := 0.AsLiteralExpression
                                                                //, Visibility := CGPhpConstructorParameterVisibility.Public
                                                                );

      l_ctor.Parameters.Add(l_p_dt);
      l_ctor.Parameters.Add(l_p_offset);
      l_ctor.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(CGSelfExpression.Self, "DateTime"), l_p_dt.AsExpression));
      l_ctor.Statements.Add(new CGAssignmentStatement(new CGFieldAccessExpression(CGSelfExpression.Self, "TimeZoneOffset"), l_p_offset.AsExpression));
    end;
  end;
end;

method PhpRodlCodeGen.GenerateServiceMethod_ReadParam(aLibrary: RodlLibrary; aParam: RodlParameter; aRes: CGExpression): CGExpression;
begin
  if IsScalar(aLibrary, aParam.DataType) then
    exit new CGMethodCallExpression(aRes, "scalarval")
  else begin
    var ar := aLibrary.Arrays.FindEntity(aParam.DataType);
    if assigned(ar) then begin
      if IsScalar(aLibrary, ar.ElementType) then
        exit new CGMethodCallExpression(
            HelperName,"ToArray",
            [aRes.AsCallParameter],
            CallSiteKind := CGCallSiteKind.Static)
      else
        exit
          new CGMethodCallExpression(
            ar.ElementType.AsNamedIdentifierExpression,"ToArray",
            [aRes.AsCallParameter],
            CallSiteKind := CGCallSiteKind.Static)
    end
    else
      exit new CGMethodCallExpression(
          aParam.DataType.AsNamedIdentifierExpression,
          "FromXmlRpcVal",
          [aRes.AsCallParameter],
          CallSiteKind := CGCallSiteKind.Static);
  end;
end;

method PhpRodlCodeGen.GenerateStructs(aFile: CGCodeUnit; aLibrary: RodlLibrary);
begin
  GenerateXsDateTimeClass(aFile, aLibrary);
  inherited;
end;

method PhpRodlCodeGen.GenerateServiceMethod_WriteParam(aLibrary: RodlLibrary; aParam: RodlParameter; msg: CGExpression): CGStatement;
begin
  var l_p := new CGParameterAccessExpression($"${aParam.Name}").AsCallParameter;
  var l_value: CGExpression;
  if IsScalar(aLibrary, aParam.DataType) then
    l_value := new CGNewInstanceExpression("xmlrpcval".AsTypeReference,
                                           [l_p,
                                            _FixDataType(aParam.DataType).AsLiteralExpression.AsCallParameter])
  else begin
    var ar := aLibrary.Arrays.FindEntity(aParam.DataType);
    if assigned(ar) then begin
      if IsScalar(aLibrary, ar.ElementType) then
        l_value := new CGMethodCallExpression(HelperName,
                                              "FromArray",
                                              [l_p,
                                               _FixDataType(ar.ElementType).AsLiteralExpression.AsCallParameter],
                                               CallSiteKind := CGCallSiteKind.Static)
      else
        l_value := new CGMethodCallExpression(ar.ElementType.AsNamedIdentifierExpression,
                                              "FromArray",
                                              [l_p],
                                               CallSiteKind := CGCallSiteKind.Static);
    end
    else
      l_value := new CGMethodCallExpression(aParam.DataType.AsNamedIdentifierExpression,
                                            "ToXmlRpcVal",
                                            [l_p],
                                            CallSiteKind := CGCallSiteKind.Static);
  end;

  exit new CGMethodCallExpression(msg,
                                  "addParam",
                                  [l_value.AsCallParameter]);
end;


end.