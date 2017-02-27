namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

type
  CocoaRodlCodeGen = public class (RodlCodeGen)
  private
    fCachedNumberFN: Dictionary<String, String> := new Dictionary<String, String>;

    property IsSwift: Boolean read Generator is CGSwiftCodeGenerator;
    property IsObjC:  Boolean read Generator is CGObjectiveCCodeGenerator;
    property IsAppleSwift: Boolean read IsSwift and (SwiftDialect = SwiftDialect.Standard);
    property IsSilver: Boolean read IsSwift and (SwiftDialect = SwiftDialect.Silver);
    property NSUIntegerType: CGTypeReference read (if IsAppleSwift then "UInt"     else "NSUInteger").AsTypeReference(false);
    property SELType:        CGTypeReference read (if IsAppleSwift then "Selector" else "SEL").AsTypeReference(false);

    method GetNumberFN(dataType: String):String;
    method GetReaderStatement(library: RodlLibrary; aEntity: RodlTypedEntity; aVariableName: String := "aMessage"): CGStatement;
    method GetReaderExpression(library: RodlLibrary; aEntity: RodlTypedEntity; aVariableName: String := "aMessage"): CGExpression;
    method GetWriterStatement(library: RodlLibrary; aEntity: RodlTypedEntity; aVariableName: String := "aMessage"; isMethod: Boolean; aInOnly: Boolean := false): CGStatement;

    method WriteToMessage_Method(library: RodlLibrary; aEntity: RodlStructEntity): CGMethodDefinition;
    method ReadFromMessage_Method(library: RodlLibrary; aEntity: RodlStructEntity): CGMethodDefinition;

    method GenerateServiceProxyMethod(library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceProxyMethodDeclaration(library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod_Body(library: RodlLibrary; aEntity: RodlOperation; Statements: List<CGStatement>);
    method GenerateServiceAsyncProxyBeginMethod(library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod_start(library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod_startWithBlock(library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethodDeclaration(library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyEndMethod(library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;

    method GenerateOperationAttribute(library: RodlLibrary; aEntity: RodlOperation;Statements: List<CGStatement>);
    method GenerateServiceMethods(library: RodlLibrary; aEntity: RodlService; service:CGClassTypeDefinition);

    method HandleAtributes_private(library: RodlLibrary; aEntity: RodlEntity): CGFieldDefinition;
    method HandleAtributes_public(library: RodlLibrary; aEntity: RodlEntity): CGMethodDefinition;
    method ApplyParamDirection(paramFlag: ParamFlags; aInOnly: Boolean := false): CGParameterModifierKind;
    method ApplyParamDirectionExpression(aExpr: CGExpression; paramFlag: ParamFlags; aInOnly: Boolean := false): CGExpression;
  protected
    method isClassType(library: RodlLibrary; dataType: String): Boolean;
    method AddUsedNamespaces(file: CGCodeUnit; library: RodlLibrary); override;
    method AddGlobalConstants(file: CGCodeUnit; library: RodlLibrary);override;
    method GenerateEnum(file: CGCodeUnit; library: RodlLibrary; aEntity: RodlEnum); override;
    method GenerateStruct(file: CGCodeUnit; library: RodlLibrary; aEntity: RodlStruct); override;
    method GenerateArray(file: CGCodeUnit; library: RodlLibrary; aEntity: RodlArray); override;
    method GenerateOldStyleArray(file: CGCodeUnit; library: RodlLibrary; aEntity: RodlArray);
    method GenerateException(file: CGCodeUnit; library: RodlLibrary; aEntity: RodlException); override;
    method GenerateService(file: CGCodeUnit; library: RodlLibrary; aEntity: RodlService); override;
    method GenerateEventSink(file: CGCodeUnit; library: RodlLibrary; aEntity: RodlEventSink); override;
    method GetNamespace(library: RodlLibrary): String;override;
    method GetGlobalName(library: RodlLibrary): String;override;

    property EnumBaseType: CGTypeReference read NSUIntegerType; override;
  public
    property SwiftDialect: CGSwiftCodeGeneratorDialect := CGSwiftCodeGeneratorDialect.Silver;
    property DontPrefixEnumValues: Boolean := not IsObjC; override;
    constructor;
    constructor withSwiftDialect(aSwiftDialect: CGSwiftCodeGeneratorDialect);
    method FixUpForAppeSwift;
  end;

implementation

method CocoaRodlCodeGen.AddUsedNamespaces(file: CGCodeUnit; &library: RodlLibrary);
begin
  file.Imports.Add(new CGImport(new CGNamespaceReference("Foundation")));
  file.Imports.Add(new CGImport(new CGNamespaceReference("RemObjectsSDK")));
  for rodl: RodlUse in library.Uses.Items do begin
    if length(rodl.Includes:CocoaModule) > 0 then
      file.Imports.Add(new CGImport(new CGNamespaceReference(rodl.Includes.CocoaModule)))
     else if length(rodl.Namespace) > 0 then
      file.Imports.Add(new CGImport(new CGNamespaceReference(rodl.Namespace)))
    else
      file.HeaderComment.Lines.Add(String.Format("Requires RODL file {0} ({1}) in same namespace.", [rodl.Name, rodl.FileName]));
  end;
end;

method CocoaRodlCodeGen.GenerateEnum(file: CGCodeUnit; &library: RodlLibrary; aEntity: RodlEnum);
begin
  inherited GenerateEnum(file, &library, aEntity);
  var lname := SafeIdentifier(aEntity.Name);
  var lenum := new CGClassTypeDefinition(lname+"__EnumMetaData", "ROEnumMetaData".AsTypeReference,
                                         Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(lenum);

  var linst :=  lname+"__EnumMetaDataInstance";
  lenum.Members.Add(new CGFieldDefinition(linst,
                                          lenum.Name.AsTypeReference,
                                          Visibility := CGMemberVisibilityKind.Private,
                                          &Static := True,
                                          Initializer := new CGNilExpression
          )
  );
  {$REGION class method instance: %ENUM_NAME%__EnumMetaData;}
  lenum.Members.Add(new CGMethodDefinition("instance",
                                           [new CGIfThenElseStatement(new CGAssignedExpression(linst.AsNamedIdentifierExpression, Inverted := true),
                                                new CGAssignmentStatement(
                                                    linst.AsNamedIdentifierExpression,
                                                    new CGNewInstanceExpression(lenum.Name.AsTypeReference)),
                                                nil),
                                              linst.AsNamedIdentifierExpression.AsReturnStatement].ToList,
                               ReturnType:= lenum.Name.AsTypeReference,
                               &Static := True,
                               Visibility := CGMemberVisibilityKind.Public
          ));
  {$ENDREGION}

  {$REGION method typeName: NSString; override;}
  lenum.Members.Add(
    new CGPropertyDefinition("typeName", CGPredefinedTypeReference.String.NotNullable,
                          GetExpression := lname.AsLiteralExpression,
                          Virtuality := CGMemberVirtualityKind.Override,
                          Visibility := CGMemberVisibilityKind.Public,
                          &ReadOnly := true,
                          Atomic := true)
  );
  {$ENDREGION}

  if not IsAppleSwift then begin
    lenum.Members.Add(new CGFieldDefinition("stringToValueLookup",
                                            "NSDictionary".AsTypeReference,
                                            Visibility := CGMemberVisibilityKind.Private
            )
    );

      {$REGION method stringFromValue(aValue: Integer): NSString;}
      var lcases := new List<CGSwitchStatementCase>;
      for enummember: RodlEnumValue in aEntity.Items index i do begin
        var lmName := GenerateEnumMemberName(library, aEntity, enummember);
        lcases.Add(new CGSwitchStatementCase(i.AsLiteralExpression, [CGStatement(lmName.AsLiteralExpression.AsReturnStatement)].ToList));
      end;
      var sw: CGStatement := new CGSwitchStatement("aValue".AsNamedIdentifierExpression,
                                                lcases,
                                                DefaultCase := [CGStatement("<Invalid Enum Value>".AsLiteralExpression.AsReturnStatement)].ToList);
      lenum.Members.Add(new CGMethodDefinition(if IsSwift then "string" else "stringFromValue",
                                              [sw].ToList,
                                              Parameters := [new CGParameterDefinition("aValue", NSUIntegerType, ExternalName := if IsSwift then "fromValue")].ToList,
                                              ReturnType:= CGPredefinedTypeReference.String.NotNullable,
                                              Virtuality := CGMemberVirtualityKind.Override,
                                              Visibility := CGMemberVisibilityKind.Public));
      {$ENDREGION}

      {$REGION method valueFromString(aValue: NSString): Integer; override;}
    var lArgs := new List<CGCallParameter>;
    for enummember: RodlEnumValue in aEntity.Items do begin
      var lmName := GenerateEnumMemberName(library, aEntity, enummember);
      var lParameter := new CGTypeCastExpression(new CGEnumValueAccessExpression(lname.AsTypeReference,lmName), NSUIntegerType, ThrowsException := true);
      lArgs.Add(if IsSwift then new CGNewInstanceExpression("NSNumber".AsTypeReferenceExpression, [lParameter.AsCallParameter("unsignedInt")]).AsCallParameter
                else new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithInt", [lParameter.AsCallParameter].ToList).AsEllipsisCallParameter);
      lArgs.Add(lmName.AsLiteralExpression.AsEllipsisCallParameter);
    end;
    lArgs.Add(new CGNilExpression().AsEllipsisCallParameter);

    var lNewDictionary := /*if IsAppleSwift then
                            new CGNewInstanceExpression("NSDictionary".AsTypeReference, lArgs, ConstructorName := "dictionaryLiteral")
                          else*/
                            new CGNewInstanceExpression("NSDictionary".AsTypeReference, lArgs, ConstructorName := "withObjectsAndKeys");

    lenum.Members.Add(new CGMethodDefinition(
          if IsSwift then "value" else "valueFromString",
          Parameters := [new CGParameterDefinition("aValue", CGPredefinedTypeReference.String.NotNullable, ExternalName := if IsSwift then "from")].ToList,
          ReturnType:= NSUIntegerType,
          Virtuality := CGMemberVirtualityKind.Override,
          Visibility := CGMemberVisibilityKind.Public,
          Statements:= [{0}new CGIfThenElseStatement(
                              new CGAssignedExpression("stringToValueLookup".AsNamedIdentifierExpression, Inverted := true),
                              new CGAssignmentStatement("stringToValueLookup".AsNamedIdentifierExpression,
                                                        lNewDictionary)),
                        {1}new CGVariableDeclarationStatement("lResult",
                                                              "NSNumber".AsTypeReference,
                                                              new CGTypeCastExpression(new CGMethodCallExpression("stringToValueLookup".AsNamedIdentifierExpression,
                                                                                                                  if IsSwift then "value" else "valueForKey",
                                                                                                                  ["aValue".AsNamedIdentifierExpression.AsCallParameter(if IsSwift then "forKey")].ToList),
                                                                                       "NSNumber".AsTypeReference, true)
                                ),
                        {2}new CGIfThenElseStatement(
                              new CGAssignedExpression("lResult".AsNamedIdentifierExpression),
                              new CGPropertyAccessExpression("lResult".AsNamedIdentifierExpression,"unsignedIntValue").AsReturnStatement,
                              if IsAppleSwift then
                                new CGThrowStatement(new CGNewInstanceExpression("NSError".AsTypeReference,
                                                                                 ["ROException".AsLiteralExpression.AsCallParameter("domain"),
                                                                                  0.AsLiteralExpression.AsCallParameter("code"),
                                                                                  CGNilExpression.Nil.AsCallParameter("userInfo")
                                                                                  ].ToList))
                              else
                                new CGThrowStatement(new CGNewInstanceExpression("NSException".AsTypeReference,
                                                                                 [if IsAppleSwift then
                                                                                    new CGNewInstanceExpression("NSExceptionName".AsTypeReference, "ROException".AsLiteralExpression.AsCallParameter).AsCallParameter
                                                                                  else
                                                                                   "ROException".AsLiteralExpression.AsCallParameter,
                                                                                  if IsAppleSwift then
                                                                                    new CGNewInstanceExpression("String".AsTypeReference, [("Invalid value %@ for enum "+lname).AsLiteralExpression.AsCallParameter, "aValue".AsNamedIdentifierExpression.AsEllipsisCallParameter].ToList).AsCallParameter("reason")
                                                                                  else
                                                                                    new CGMethodCallExpression(CGPredefinedTypeReference.String.AsExpression, "stringWithFormat", [("Invalid value %@ for enum "+lname).AsLiteralExpression.AsCallParameter, "aValue".AsNamedIdentifierExpression.AsEllipsisCallParameter].ToList).AsCallParameter("reason"),
                                                                                  CGNilExpression.Nil.AsCallParameter("userInfo")
                                                                                  ].ToList, ConstructorName := "withName"))
                        )
                      ].ToList
          ));
    {$ENDREGION}

    {$REGION method typeName: NSString; override;}
    lenum.Members.Add(
      new CGMethodDefinition(
        lname+"ToString",
        [new CGMethodCallExpression(new CGMethodCallExpression(lenum.Name.AsTypeReferenceExpression,"instance"),
                                                 if IsSwift then "string" else "stringFromValue",
                                                 [new CGTypeCastExpression("aValue".AsNamedIdentifierExpression, NSUIntegerType, true).AsCallParameter(if IsSwift then "fromValue")].ToList
                                                ).AsReturnStatement],
        Parameters := [new CGParameterDefinition("aValue",lname.AsTypeReference)].ToList,
        ReturnType := CGPredefinedTypeReference.String.NotNullable,
        Visibility := CGMemberVisibilityKind.Public
        )
    );
    {$ENDREGION}
  end;

end;

method CocoaRodlCodeGen.GenerateStruct(file: CGCodeUnit; &library: RodlLibrary; aEntity: RodlStruct);
begin
  var lancestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then lancestorName := "ROComplexType";

  var lStruct := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name), lancestorName.AsTypeReference,
                                           Visibility := CGTypeVisibilityKind.Public,
                                           Comment := GenerateDocumentation(aEntity));
  lStruct.Attributes.Add(new CGAttribute("objc".AsTypeReference, SafeIdentifier(aEntity.Name).AsNamedIdentifierExpression.AsCallParameter));
  file.Types.Add(lStruct);
  {$REGION private class class __attributes: NSDictionary;}
  if (aEntity.CustomAttributes.Count > 0) then
    lStruct.Members.Add(HandleAtributes_private(&library,aEntity));
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (aEntity.CustomAttributes.Count > 0) then
    lStruct.Members.Add(HandleAtributes_public(&library,aEntity));
  {$ENDREGION}
  {$REGION public property %fldname%: %fldtype%}
  for m: RodlTypedEntity in aEntity.Items do begin
    var lType := ResolveDataTypeToTypeRef(&library, m.DataType);
    var p := new CGPropertyDefinition(m.Name, lType,
                                      Visibility := CGMemberVisibilityKind.Public,
                                      Comment := GenerateDocumentation(m));
    var lEnumDefault := FindEnum(library, m.DataType):DefaultValueName;
    if assigned(lEnumDefault) then
      p.Initializer := new CGEnumValueAccessExpression(lType, lEnumDefault);
    lStruct.Members.Add(p);
  end;
  {$ENDREGION}
  {$REGION method assignFrom(aValue: ROComplexType); override;}
  lStruct.Members.Add(
    new CGMethodDefinition(if IsSwift then "assign" else "assignFrom",
      Parameters := [new CGParameterDefinition("aValue", "ROComplexType".AsTypeReference().NotNullable, ExternalName := if IsSwift then "from")].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public    )
  );
  {$ENDREGION}

  if aEntity.Items.Count >0 then begin
    {$REGION public method writeToMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lStruct.Members.Add(WriteToMessage_Method(&library,aEntity));
    {$ENDREGION}
    {$REGION public method readFromMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lStruct.Members.Add(ReadFromMessage_Method(&library,aEntity));
    {$ENDREGION}
  end;
end;

method CocoaRodlCodeGen.GenerateArray(file: CGCodeUnit; &library: RodlLibrary; aEntity: RodlArray);
begin
  var lArray := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name), "ROMutableArray".AsTypeReference,
                                          Visibility := CGTypeVisibilityKind.Public,
                                          Comment := GenerateDocumentation(aEntity));
  file.Types.Add(lArray);

  {$REGION private class __attributes: NSDictionary;}
  if (aEntity.CustomAttributes.Count > 0) then
    lArray.Members.Add(HandleAtributes_private(&library,aEntity));
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (aEntity.CustomAttributes.Count > 0) then
    lArray.Members.Add(HandleAtributes_public(&library,aEntity));
  {$ENDREGION}

  var lElementType:= ResolveDataTypeToTypeRef(&library, SafeIdentifier(aEntity.ElementType));
  var lIsEnum := isEnum(&library,aEntity.ElementType);
  var lIsComplex := isComplex(&library, aEntity.ElementType);
  var lIsArray := isArray(&library, aEntity.ElementType);
  var lIsSimple := not (lIsEnum or lIsComplex);

  {$REGION method itemClass: &Class; override;}
  if lIsComplex then begin
    var l_elementType2 := ResolveDataTypeToTypeRef(&library,SafeIdentifier(aEntity.ElementType)).NotNullable;
    lArray.Members.Add(
      new CGPropertyDefinition(
        "itemClass", CGPredefinedTypeReference.Class.NotNullable,
        GetExpression := new CGTypeOfExpression(l_elementType2.AsExpression),
        Visibility := CGMemberVisibilityKind.Public,
        Virtuality := CGMemberVirtualityKind.Override,
        Atomic := true));
  end;
  {$ENDREGION}

  {$REGION - (void)writeItem:(id)item toMessage:(ROMessage *)aMessage withIndex:(NSUInteger)index; }
  var lList := new List<CGStatement>;

  //var __item: %ARRAY_TYPE% := self.itemAtIndex(aIndex);
  var getItemAtIndex: CGExpression := if IsAppleSwift then
                                        new CGMethodCallExpression(new CGSelfExpression, "object", "aIndex".AsNamedIdentifierExpression.AsCallParameter("at"))
                                      else
                                        new CGArrayElementAccessExpression(new CGSelfExpression, ["aIndex".AsNamedIdentifierExpression]);
  if lIsSimple then begin
    var getItemAtIndexAsNSNumber := new CGTypeCastExpression(getItemAtIndex, "NSNumber".AsTypeReference, ThrowsException := true);
    case aEntity.ElementType.ToLowerInvariant of
      "integer": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "intValue");
      "int64": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "longLongValue");
      "double": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "doubleValue");
      "boolean": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "boolValue");
      else if IsAppleSwift then getItemAtIndex := new CGTypeCastExpression(getItemAtIndex, lElementType, ThrowsException := true);
    end;
  end
  else if lIsEnum then begin
    getItemAtIndex := new CGTypeCastExpression(getItemAtIndex, "NSNumber".AsTypeReference, ThrowsException := true);
    getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndex, "integerValue");
    getItemAtIndex := new CGTypeCastExpression(getItemAtIndex, lElementType, ThrowsException := true);
  end
  else begin
    getItemAtIndex := new CGTypeCastExpression(getItemAtIndex, lElementType, ThrowsException := true);
  end;
  lList.Add(new CGVariableDeclarationStatement("__item", lElementType, getItemAtIndex, &ReadOnly := true));

  var lLower: String  := aEntity.ElementType.ToLowerInvariant();
  var lMethodName: String;
  if ReaderFunctions.ContainsKey(lLower) then begin
    lMethodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, aEntity.ElementType) then begin
    lMethodName := "MutableArray";
  end
  else if isStruct(&library, aEntity.ElementType) then begin
    lMethodName := "Complex";
  end
  else if lIsEnum then begin
    lMethodName := "Enum";
  end;

  var lArguments := new List<CGCallParameter>;
  lArguments.Add("__item".AsNamedIdentifierExpression.AsCallParameter);
  lArguments.Add(new CGCallParameter(new CGNilExpression(), "withName"));
  if lIsEnum then
    lArguments.Add(new CGCallParameter(new CGMethodCallExpression((aEntity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), if IsAppleSwift then "as" else "asEnum"));

  lList.Add(new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, "write" +  lMethodName, lArguments));
  lArray.Members.Add(
    new CGMethodDefinition( "writeItem",
      Parameters := [new CGParameterDefinition("aItem", CGPredefinedTypeReference.Dynamic.NotNullable),
                     new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference().NotNullable, Externalname := if IsAppleSwift then "to" else "toMessage"),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := if IsAppleSwift then "with" else "withIndex")].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lList as not nullable));
  {$ENDREGION}

  {$REGION - (id)readItemFromMessage:(ROMessage *)aMessage withIndex:(NSUInteger)index; }
  lList := new List<CGStatement>;

  lArguments:= new List<CGCallParameter>;
  lArguments.Add(new CGNilExpression().AsCallParameter(if IsSwift then "withName"));
  if lIsEnum then
    lArguments.Add(new CGCallParameter(new CGMethodCallExpression((aEntity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), if IsAppleSwift then "as" else "asEnum"));
  if lIsComplex or lIsArray then
    lArguments.Add(new CGCallParameter(new CGPropertyAccessExpression(nil, "itemClass"), if IsSwift then "as" else "asClass"));

  var lExpression: CGExpression := new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, if IsSwift then "read"+lMethodName else "read"+lMethodName+"WithName", lArguments);

  if lIsComplex or lIsEnum or lIsArray then
    lExpression := new CGTypeCastExpression(lExpression, lElementType, ThrowsException := true);
  lList.Add(new CGVariableDeclarationStatement("__item", lElementType, lExpression, &ReadOnly := true));

  var lItem: CGExpression := "__item".AsNamedIdentifierExpression;
  if lIsSimple then begin
    case aEntity.ElementType.ToLowerInvariant of
      "integer": lItem := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithInteger", [lItem.AsCallParameter]);
      "int64": lItem := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithLongLong", [lItem.AsCallParameter]);
      "double": lItem := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithDouble", [lItem.AsCallParameter]);
      "boolean": lItem := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithBool", [lItem.AsCallParameter]);
    end;
  end else if lIsEnum then begin
    lItem := new CGTypeCastExpression(lItem, "NSInteger".AsTypeReference, ThrowsException := true);
    lItem := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithInteger", [lItem.AsCallParameter]);
  end;
  lList.Add(lItem.AsReturnStatement);

  lArray.Members.Add(
    new CGMethodDefinition(if IsAppleSwift then "readItem" else "readItemFromMessage",
      Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference().NotNullable, ExternalName := if IsAppleSwift then "from"),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := if IsAppleSwift then "with" else "withIndex")].ToList,
                     ReturnType := CGPredefinedTypeReference.Dynamic.NullableNotUnwrapped,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lList as not nullable));
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateOldStyleArray(file: CGCodeUnit; &library: RodlLibrary; aEntity: RodlArray);
begin
  var lArray := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name), "ROArray".AsTypeReference,
                                          Visibility := CGTypeVisibilityKind.Public,
                                          Comment := GenerateDocumentation(aEntity));
  file.Types.Add(lArray);
  {$REGION private class __attributes: NSDictionary;}
  if (aEntity.CustomAttributes.Count > 0) then
    lArray.Members.Add(HandleAtributes_private(&library,aEntity));
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (aEntity.CustomAttributes.Count > 0) then
    lArray.Members.Add(HandleAtributes_public(&library,aEntity));
  {$ENDREGION}

  var lElementType:= ResolveDataTypeToTypeRef(&library,SafeIdentifier(aEntity.ElementType));
  var lIsEnum := isEnum(&library,aEntity.ElementType);
  var lIsComplex := iif(not lIsEnum,isComplex(&library,aEntity.ElementType), false) ;
  var lIsSimple := not (lIsEnum or lIsComplex);

  {$REGION method add: %ARRAY_TYPE%;}
  if lIsComplex then
    lArray.Members.Add(
      new CGMethodDefinition("add",
        ReturnType := lElementType,
        Visibility := CGMemberVisibilityKind.Public,
        Statements:=
          [new CGVariableDeclarationStatement('lresult',lElementType, new CGNewInstanceExpression(lElementType)),
           new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", ["lresult".AsNamedIdentifierExpression.AsCallParameter].ToList),
           "lresult".AsNamedIdentifierExpression.AsReturnStatement
          ].ToList
        )
    );
  {$ENDREGION}

  {$REGION method addItem(aObject: %ARRAY_TYPE%);}
  var lExpression : CGExpression := "aObject".AsNamedIdentifierExpression;
  if lIsEnum then     lExpression := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWithInt", [lExpression.AsCallParameter].ToList);
  if lIsSimple then   lExpression := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWith"+GetNumberFN(aEntity.ElementType), [lExpression.AsCallParameter].ToList);
  lArray.Members.Add(
    new CGMethodDefinition("addItem",
      [new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", [lExpression.AsCallParameter].ToList)],
      Parameters := [new CGParameterDefinition("aObject", lElementType)].ToList,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method insertItem(aObject: %ARRAY_TYPE%) atIndex(aIndex: NSUInteger);}
  lArray.Members.Add(
    new CGMethodDefinition("insertItem",
      [new CGMethodCallExpression(CGInheritedExpression.Inherited, "insertItem", [lExpression.AsCallParameter,new CGCallParameter("aIndex".AsNamedIdentifierExpression, "atIndex")].ToList)],
      Parameters := [new CGParameterDefinition("aObject", lElementType),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := "atIndex")].ToList,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method replaceItemAtIndex(aIndex: NSUInteger) withItem(aItem: %ARRAY_TYPE%);}
  lExpression := "aItem".AsNamedIdentifierExpression;
  if lIsEnum then   lExpression := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWithInt",[lExpression.AsCallParameter].ToList);
  if lIsSimple then lExpression := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWith"+GetNumberFN(aEntity.ElementType),[lExpression.AsCallParameter].ToList);
  lArray.Members.Add(
    new CGMethodDefinition("replaceItemAtIndex",
                          [new CGMethodCallExpression(CGInheritedExpression.Inherited, "replaceItemAtIndex",
                                                                                                  ["aIndex".AsNamedIdentifierExpression.AsCallParameter,
                                                                                                   new CGCallParameter(lExpression, "withItem")].ToList)],
                            Parameters := [new CGParameterDefinition("aIndex", NSUIntegerType),
                                          new CGParameterDefinition("aItem", lElementType, Externalname := "withItem")].ToList,
                            Visibility := CGMemberVisibilityKind.Public)
  );
  {$ENDREGION}

  {$REGION method itemAtIndex(aIndex: NSUInteger): %ARRAY_TYPE%;}
  var lList := new List<CGStatement>;
  if lIsComplex then begin
    //  exit inherited itemAtIndex(aIndex) as %ARRAY_TYPE%;
    lList.Add(new CGTypeCastExpression(
              new CGMethodCallExpression(CGInheritedExpression.Inherited, "itemAtIndex", ["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList),
              lElementType,
              ThrowsException := True
              ).AsReturnStatement);
  end;
  if lIsSimple then begin
    //  var __result: Integer;
    //  __result := (inherited itemAtIndex(aIndex) as NSNumber) as %ARRAY_TYPE%;
    //  exit __result;
    lList.Add(new CGVariableDeclarationStatement("__result",ResolveStdtypes(CGPredefinedTypeKind.Int32)));
    lList.Add(new CGAssignmentStatement(
                                     "__result".AsNamedIdentifierExpression,
                                     new CGTypeCastExpression(
                                        new CGTypeCastExpression(
                                          new CGMethodCallExpression(CGInheritedExpression.Inherited, "itemAtIndex", ["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList),
                                          "NSNumber".AsTypeReference,
                                          ThrowsException := True
                                          ),
                                      lElementType,
                                      ThrowsException := True
                                     )

                  ));
    lList.Add("__result".AsNamedIdentifierExpression.AsReturnStatement);
  end;
  if lIsEnum then begin
    //  exit inherited itemAtIndex(aIndex).intValue;
    lList.Add( new CGPropertyAccessExpression(
                    new CGMethodCallExpression(CGInheritedExpression.Inherited, "itemAtIndex", ["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList),
                    "intValue").AsReturnStatement);

  end;
  lArray.Members.Add(
    new CGMethodDefinition("itemAtIndex",
      Parameters := [new CGParameterDefinition("aIndex", NSUIntegerType)].ToList,
      ReturnType := lElementType,
      Visibility := CGMemberVisibilityKind.Public,
      Virtuality := CGMemberVirtualityKind.Reintroduce,
      statements := lList as not nullable));
  {$ENDREGION}

  {$REGION method itemClass: &Class; override;}
  if lIsComplex then begin
    var l_elementType2 := ResolveDataTypeToTypeRef(&library,SafeIdentifier(aEntity.ElementType)).NotNullable;
    lArray.Members.Add(
      new CGPropertyDefinition(
        "itemClass", CGPredefinedTypeReference.Class,
        GetExpression := new CGTypeOfExpression(l_elementType2.AsExpression),
        Visibility := CGMemberVisibilityKind.Public,
        Virtuality := CGMemberVirtualityKind.Override,
        Atomic := true));
  end;
  {$ENDREGION}

  {$REGION method itemTypeName: NSString; override;}
  lArray.Members.Add(
    new CGPropertyDefinition("itemTypeName", CGPredefinedTypeReference.String.NotNullable,
                          GetExpression := aEntity.ElementType.AsLiteralExpression,
                          Virtuality := CGMemberVirtualityKind.Override,
                          Visibility := CGMemberVisibilityKind.Public,
                          Atomic := true));
  {$ENDREGION}

  {$REGION method writeItemToMessage(aMessage: ROMessage) fromIndex(aIndex: Integer); override;}
  lList := new List<CGStatement>;
  //var __item: %ARRAY_TYPE% := self.itemAtIndex(aIndex);
  lList.Add(new CGVariableDeclarationStatement("__item",lElementType,new CGMethodCallExpression(new CGSelfExpression,"itemAtIndex",["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList), &ReadOnly := true));
  var lLower: String  := aEntity.ElementType.ToLowerInvariant();
  var lMethodName: String;
  if ReaderFunctions.ContainsKey(lLower) then begin
    lMethodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, aEntity.ElementType) then begin
    lMethodName := "MutableArray";
  end
  else if isStruct(&library, aEntity.ElementType) then begin
    lMethodName := "Complex";
  end
  else if lIsEnum then begin
    lMethodName := "Enum";
  end;

  var lArguments := new List<CGCallParameter>;
  lArguments.Add("__item".AsNamedIdentifierExpression.AsCallParameter);
  lArguments.Add(new CGCallParameter(new CGNilExpression(), "withName"));
  if lIsEnum then
    lArguments.Add(new CGCallParameter(new CGMethodCallExpression((aEntity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), if IsAppleSwift then "as" else "asEnum"));

  lList.Add(new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, "write" +  lMethodName, lArguments));
  lArray.Members.Add(
    new CGMethodDefinition( "writeItemToMessage",
      Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname :="fromIndex" )].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lList as not nullable));
  {$ENDREGION}

  {$REGION method method readItemFromMessage(aMessage: ROMessage) toIndex(aIndex: Integer); override;}
  lList := new List<CGStatement>;
  //  var __item: %ARRAY_TYPE%;
  lList.Add(new CGVariableDeclarationStatement("__item", lElementType.NotNullable, &ReadOnly := true));
  lArguments:= new List<CGCallParameter>;
  lArguments.Add(new CGNilExpression().AsCallParameter);
  if lIsEnum then
    lArguments.Add(new CGCallParameter(new CGMethodCallExpression((aEntity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), if IsAppleSwift then "as" else "asEnum"));
  if lIsComplex then
    lArguments.Add(new CGCallParameter(new CGPropertyAccessExpression(new CGSelfExpression, "itemClass"), "asClass"));

  lExpression := new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, "read" +  lMethodName+"WithName",  lArguments);

  if lIsComplex then
    lExpression := new CGTypeCastExpression(
       lExpression,
       lElementType,
       ThrowsException := true);
  lList.Add(new CGAssignmentStatement("__item".AsNamedIdentifierExpression, lExpression));
  lList.Add(new CGCommentStatement("for efficiency, assumes this is called in ascending order"));
  lList.Add(new CGMethodCallExpression(new CGSelfExpression, "addItem",["__item".AsNamedIdentifierExpression.AsCallParameter].ToList));
  lArray.Members.Add(
    new CGMethodDefinition(if IsSwift then "readItem" else "readItemFromMessage",
      Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference, ExternalName := if IsSwift then "from"),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := "toIndex")].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lList as not nullable));
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateException(file: CGCodeUnit; &library: RodlLibrary; aEntity: RodlException);
begin
  var lancestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then lancestorName := "ROException";
  var lException := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name), lancestorName.AsTypeReference,
                                              Visibility := CGTypeVisibilityKind.Public,
                                              Comment := GenerateDocumentation(aEntity));
  file.Types.Add(lException);

  {$REGION private class class __attributes: NSDictionary;}
  if (aEntity.CustomAttributes.Count > 0) then
    lException.Members.Add(HandleAtributes_private(&library,aEntity));
  {$ENDREGION}

  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (aEntity.CustomAttributes.Count > 0) then
    lException.Members.Add(HandleAtributes_public(&library,aEntity));
  {$ENDREGION}

  {$REGION public property %fldname%: %fldtype%}
  for m: RodlTypedEntity in aEntity.Items do
    lException.Members.Add(new CGPropertyDefinition(m.Name,
                                                    ResolveDataTypeToTypeRef(&library,m.DataType),
                                                    Visibility:= CGMemberVisibilityKind.Public,
                                                    Comment := GenerateDocumentation(m)));
  {$ENDREGION}

  {$REGION public method initWithMessage(anExceptionMessage: NSString; a%FIELD_NAME_UNSAFE%: %FIELD_TYPE%);dynamic;}
  var linitWithMessage := new CGConstructorDefinition("withMessage", Visibility := CGMemberVisibilityKind.Public);
  lException.Members.Add(linitWithMessage);
  var lAncestorEntity := aEntity as RodlStructEntity;
  var st:= new CGBeginEndBlockStatement;
  var llist:= new List<CGCallParameter>;
  while assigned(lAncestorEntity) do begin
    var memberlist:= new List<CGParameterDefinition>;

    var arlist:= new List<CGCallParameter>;
    for m: RodlTypedEntity in lAncestorEntity.Items do begin
      var lname := "a"+m.Name;
      memberlist.Add(new CGParameterDefinition(lname, ResolveDataTypeToTypeRef(m.OwnerLibrary,m.DataType)));
      if lAncestorEntity = aEntity then
        st.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(nil, SafeIdentifier(m.Name)),
                                                    lname.AsNamedIdentifierExpression))
      else
        arlist.Add(lname.AsNamedIdentifierExpression.AsCallParameter);
    end;

    for i: Integer := memberlist.Count-1 downto 0 do
      linitWithMessage.Parameters.Insert(0,memberlist[i]);

    for i: Integer := arlist.Count-1 downto 0 do
      llist.Insert(0,arlist[i]);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;
  linitWithMessage.Parameters.Insert(0,new CGParameterDefinition("anExceptionMessage", CGPredefinedTypeReference.String.NotNullable));
  llist.Insert(0,"anExceptionMessage".AsNamedIdentifierExpression.AsCallParameter);
  linitWithMessage.Statements.Add(new CGConstructorCallStatement(CGInheritedExpression.Inherited, llist, ConstructorName := "withMessage"));
  linitWithMessage.Statements.Add(st.Statements);

  {$ENDREGION}

  if aEntity.Items.Count >0 then begin
    {$REGION public method writeToMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lException.Members.Add(WriteToMessage_Method(&library,aEntity));
    {$ENDREGION}
    {$REGION public method readFromMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lException.Members.Add(ReadFromMessage_Method(&library,aEntity));
    {$ENDREGION}
  end;
end;

method CocoaRodlCodeGen.GenerateService(file: CGCodeUnit; &library: RodlLibrary; aEntity: RodlService);
begin
  {$REGION I%SERVICE_NAME%}
  var lIService := new CGInterfaceTypeDefinition(SafeIdentifier("I"+aEntity.Name),
                                                 Visibility := CGTypeVisibilityKind.Public,
                                                 Comment := GenerateDocumentation(aEntity));
  file.Types.Add(lIService);
  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
    var m := GenerateServiceProxyMethodDeclaration(&library, lop);
    m.Comment := GenerateDocumentation(lop, true);
    lIService.Members.Add(m);
  end;

  {$ENDREGION}

  {$REGION %SERVICE_NAME%_Proxy}
  var lancestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then
    lancestorName := "ROProxy"
  else
    lancestorName := lancestorName+"_Proxy";
  var lServiceProxy := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name+"_Proxy"),
                                                 [lancestorName.AsTypeReference].ToList,
                                                 [lIService.Name.AsTypeReference].ToList,
                                                 Visibility := CGTypeVisibilityKind.Public
                                                 );
  file.Types.Add(lServiceProxy);

  GenerateServiceMethods(&library,aEntity, lServiceProxy);

  for lop : RodlOperation in aEntity.DefaultInterface:Items do
    lServiceProxy.Members.Add(GenerateServiceProxyMethod(&library,lop));
  {$ENDREGION}

  {$REGION %SERVICE_NAME%_AsyncProxy}
  lancestorName := aEntity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then
    lancestorName := "ROAsyncProxy"
  else
    lancestorName := lancestorName+"_AsyncProxy";

  var lServiceAsyncProxy := new CGClassTypeDefinition(SafeIdentifier(aEntity.Name+"_AsyncProxy"),lancestorName.AsTypeReference,
                            Visibility := CGTypeVisibilityKind.Public
                            );
  file.Types.Add(lServiceAsyncProxy);
  GenerateServiceMethods(&library,aEntity,lServiceAsyncProxy);
  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod(&library, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod_start(&library, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod_startWithBlock(&library, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyEndMethod(&library, lop));
  end;
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateEventSink(file: CGCodeUnit; &library: RodlLibrary; aEntity: RodlEventSink);
begin
  var lIEvent := new CGInterfaceTypeDefinition("I"+aEntity.Name,
                                              Visibility := CGTypeVisibilityKind.Public,
                                              Comment:= GenerateDocumentation(aEntity));
  file.Types.Add(lIEvent);

  var lEventInvoker := new CGClassTypeDefinition(aEntity.Name+"_EventInvoker", "ROEventInvoker".AsTypeReference,
                            Visibility := CGTypeVisibilityKind.Public
                            );
  file.Types.Add(lEventInvoker);

  for lop : RodlOperation in aEntity.DefaultInterface:Items do begin

    var lievent_method := new CGMethodDefinition(lop.Name,
                                                 Visibility := CGMemberVisibilityKind.Public,
                                                 Comment:= GenerateDocumentation(lop, true));
    lIEvent.Members.Add(lievent_method);
    var lInParam:=new List<RodlParameter>;
    for m: RodlParameter in lop.Items do begin
      lievent_method.Parameters.Add(new CGParameterDefinition(SafeIdentifier(m.Name),ResolveDataTypeToTypeRef(library,m.DataType), Modifier := ApplyParamDirection(m.ParamFlag)));
      if m.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then lInParam.Add(m);
    end;

    var linvk_method := new CGMethodDefinition("Invoke_"+lop.Name,
                              Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference),
                                             new CGParameterDefinition("aHandler", ResolveStdtypes(CGPredefinedTypeKind.Object), Externalname := "handler")].ToList,
                              ReturnType:= ResolveStdtypes(CGPredefinedTypeKind.Boolean),
      Visibility := CGMemberVisibilityKind.Public);
    lEventInvoker.Members.Add(linvk_method);
    if IsAppleSwift then begin
      linvk_method.Statements.Add(new CGVariableDeclarationStatement("__selPattern",
                                                                     "NSString".AsTypeReference().NotNullable,
                                                                     new CGNewInstanceExpression("NSString".AsTypeReference,
                                                                                                [SafeIdentifier(lop.Name).AsLiteralExpression.AsCallParameter("string")].ToList)));
    end
    else begin
      linvk_method.Statements.Add(new CGVariableDeclarationStatement("__selPattern",
                                                                     "NSString".AsTypeReference,
                                                                     new CGMethodCallExpression("NSMutableString".AsTypeReferenceExpression,
                                                                                                "stringWithString",
                                                                                                [SafeIdentifier(lop.Name).AsLiteralExpression.AsCallParameter].ToList)));
    end;
    if lInParam.Count>0 then
      linvk_method.Statements.Add(new CGForToLoopStatement(
                                            "i",
                                            ResolveStdtypes(CGPredefinedTypeKind.Int),
                                            new CGIntegerLiteralExpression(1),
                                            new CGIntegerLiteralExpression(lInParam.Count),
                                            new CGAssignmentStatement("__selPattern".AsNamedIdentifierExpression, new CGMethodCallExpression("__selPattern".AsNamedIdentifierExpression, "stringByAppendingString", [":".AsLiteralExpression.AsCallParameter].ToList))
                                      ));
    linvk_method.Statements.Add(new CGVariableDeclarationStatement("__selector",
                                                                   SELType,
                                                                   new CGMethodCallExpression(nil,
                                                                                                    "NSSelectorFromString", [
                                                                                                    (if IsAppleSwift then
                                                                                                      new CGTypeCastExpression("__selPattern".AsNamedIdentifierExpression, "String".AsTypeReference, GuaranteedSafe := true)
                                                                                                    else
                                                                                                      "__selPattern".AsNamedIdentifierExpression).AsCallParameter].ToList),
                                                                   &ReadOnly := true));
    var if_true:= new CGBeginEndBlockStatement;


    {if_true.Statements.Add(new CGVariableDeclarationStatement("__signature",
                                                              "NSMethodSignature".AsTypeReference,
                                                              new CGMethodCallExpression("aHandler".AsNamedIdentifierExpression,
                                                                                                "methodSignatureForSelector",
                                                                                                ["__selector".AsNamedIdentifierExpression.AsCallParameter].ToList)));}
    if IsAppleSwift then
      if_true.Statements.Add(new CGVariableDeclarationStatement("__invocation",
                                                                "ROInvocation".AsTypeReference,
                                                                new CGNewInstanceExpression("ROInvocation".AsTypeReference,
                                                                                            ["__selector".AsNamedIdentifierExpression.AsCallParameter("selector"),
                                                                                             "aHandler".AsNamedIdentifierExpression.AsCallParameter("object")].ToList),
                                                                &ReadOnly := true))
    else
      if_true.Statements.Add(new CGVariableDeclarationStatement("__invocation",
                                                                "ROInvocation".AsTypeReference,
                                                                new CGMethodCallExpression("ROInvocation".AsTypeReferenceExpression,
                                                                                           "invocationWithSelector",
                                                                                           ["__selector".AsNamedIdentifierExpression.AsCallParameter,
                                                                                            "aHandler".AsNamedIdentifierExpression.AsCallParameter("object")].ToList),
                                                                &ReadOnly := true));
    //Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively; you should set these values directly with the target and selector properties. Use indices 2 and greater for the arguments normally passed in a message.
    var linc := 2;
    for m: RodlParameter in lInParam do begin
      var lm_name:= "__"+SafeIdentifier(m.Name);
      if_true.Statements.Add(new CGVariableDeclarationStatement(lm_name,ResolveDataTypeToTypeRef(library,m.DataType),GetReaderExpression(&library,m)));
      if_true.Statements.Add(new CGMethodCallExpression("__invocation".AsNamedIdentifierExpression,
                                                        "setArgument",
                                                        [new CGCallParameter(new CGUnaryOperatorExpression(lm_name.AsNamedIdentifierExpression, CGUnaryOperatorKind.AddressOf)),
                                                        new CGCallParameter(new CGIntegerLiteralExpression(linc), "atIndex")].ToList));
      inc(linc);
    end;
    if_true.Statements.Add(new CGMethodCallExpression("__invocation".AsNamedIdentifierExpression,"invoke"));
    if_true.Statements.Add(new CGBooleanLiteralExpression(True).AsReturnStatement);
    linvk_method.Statements.Add(new CGIfThenElseStatement(
                                        new CGMethodCallExpression("aHandler".AsNamedIdentifierExpression,"respondsToSelector",  ["__selector".AsNamedIdentifierExpression.AsCallParameter].ToList),
                                        if_true,
                                        new CGBooleanLiteralExpression(False).AsReturnStatement
    ));
  end;
end;


constructor CocoaRodlCodeGen;
begin
  CodeGenTypes.Add("integer", ResolveStdtypes(CGPredefinedTypeKind.Int32));
  CodeGenTypes.Add("datetime", "NSDate".AsTypeReference().NullableUnwrapped);
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeKind.Double));
  CodeGenTypes.Add("currency", "NSDecimalNumber".AsTypeReference().NullableUnwrapped);
  CodeGenTypes.Add("widestring", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("ansistring", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeKind.Int64));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeKind.Boolean));
  CodeGenTypes.Add("variant", "ROVariant".AsTypeReference);
  CodeGenTypes.Add("binary", "NSData".AsTypeReference);
  CodeGenTypes.Add("xml", "ROXml".AsTypeReference);
  CodeGenTypes.Add("guid", "ROGuid".AsTypeReference);
  CodeGenTypes.Add("decimal", "NSDecimalNumber".AsTypeReference().NullableUnwrapped);
  CodeGenTypes.Add("utf8string", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("xsdatetime", "NSDate".AsTypeReference().NullableUnwrapped);

  ReaderFunctions.Add("integer", "Int32");
  ReaderFunctions.Add("datetime", "DateTime");
  ReaderFunctions.Add("double", "Double");
  ReaderFunctions.Add("currency", "Currency");
  ReaderFunctions.Add("widestring", "WideString");
  ReaderFunctions.Add("ansistring", "AnsiString");
  ReaderFunctions.Add("int64", "Int64");
  ReaderFunctions.Add("decimal", "Decimal");
  ReaderFunctions.Add("guid", "Guid");
  ReaderFunctions.Add("utf8string", "Utf8String");
  ReaderFunctions.Add("boolean", "Boolean");
  ReaderFunctions.Add("variant", "Variant");
  ReaderFunctions.Add("binary", "Binary");
  ReaderFunctions.Add("xml", "Xml");
  ReaderFunctions.Add("xsdatetime", "XsDateTime");

  fCachedNumberFN.Add("integer","Int");
  fCachedNumberFN.Add("double", "Double");
  fCachedNumberFN.Add("int64", "LongLong");
  fCachedNumberFN.Add("boolean", "Bool");

  {ReservedWords.Add([
    "abstract", "and", "add", "async", "as", "begin", "break", "case", "class", "const", "constructor", "continue",
    "delegate", "default", "div", "do", "downto", "each", "else", "empty", "end", "enum", "ensure", "event", "except",
    "exit", "external", "false", "final", "finalizer", "finally", "flags", "for", "forward", "function", "global", "has",
    "if", "implementation", "implements", "implies", "in", "index", "inline", "inherited", "interface", "invariants", "is",
    "iterator", "locked", "locking", "loop", "matching", "method", "mod", "namespace", "nested", "new", "nil", "not",
    "nullable", "of", "old", "on", "operator", "or", "out", "override", "pinned", "partial", "private", "property",
    "protected", "public", "reintroduce", "raise", "read", "readonly", "remove", "repeat", "require", "result", "sealed",
    "self", "sequence", "set", "shl", "shr", "static", "step", "then", "to", "true", "try", "type", "typeof", "until",
    "unsafe", "uses", "using", "var", "virtual", "where", "while", "with", "write", "xor", "yield"]);}
end;

constructor CocoaRodlCodeGen withSwiftDialect(aSwiftDialect: CGSwiftCodeGeneratorDialect);
begin
  constructor;
  SwiftDialect := aSwiftDialect;
end;

method CocoaRodlCodeGen.FixUpForAppeSwift;
begin
  // nasty hack, but so fuck it!
  CodeGenTypes.Remove("binary");
  CodeGenTypes.Add("binary", "Data".AsTypeReference);
end;

method CocoaRodlCodeGen.HandleAtributes_private(&library: RodlLibrary; aEntity: RodlEntity): CGFieldDefinition;
begin
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (aEntity.CustomAttributes.Count = 0) then exit;
  exit new CGFieldDefinition(
                  "__attributes",
                  "NSDictionary".AsTypeReference,
                  &Static := true,
                  Visibility := CGMemberVisibilityKind.Private);
end;

method CocoaRodlCodeGen.HandleAtributes_public(&library: RodlLibrary; aEntity: RodlEntity): CGMethodDefinition;
begin
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (aEntity.CustomAttributes.Count = 0) then exit;
  result := new CGMethodDefinition("getAttributeValue",
                                  ReturnType := CGPredefinedTypeReference.String,
                                  Parameters := [new CGParameterDefinition("aName", CGPredefinedTypeReference.String.NotNullable)].ToList,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  &Static := true);

  var l_attributes := "__attributes".AsNamedIdentifierExpression;
  var list:= new List<CGCallParameter>;
  list.Add(new CGBooleanLiteralExpression(False).AsCallParameter);
  for l_key: String in aEntity.CustomAttributes.Keys do begin
    list.Add(EscapeString(l_key.ToLowerInvariant).AsLiteralExpression.AsCallParameter);
    list.Add(EscapeString(aEntity.CustomAttributes[l_key]).AsLiteralExpression.AsCallParameter);
  end;
  list.Add(new CGNilExpression().AsCallParameter);

  result.Statements.Add(new CGIfThenElseStatement(
      new CGAssignedExpression(l_attributes, Inverted := true),
      new CGAssignmentStatement(l_attributes,
                                new CGMethodCallExpression(nil,"DictionaryFromNameValueList", list)
      )));

  result.Statements.Add(new CGMethodCallExpression(l_attributes, "objectForKey",
                                                   [new CGMethodCallExpression("aName".AsNamedIdentifierExpression, "lowercaseString").AsCallParameter].ToList).AsReturnStatement);
end;

method CocoaRodlCodeGen.WriteToMessage_Method(&library: RodlLibrary; aEntity: RodlStructEntity): CGMethodDefinition;
begin
  //method writeToMessage(aMessage: ROMessage) withName(aName: NSString); override;
  result := new CGMethodDefinition(if IsSwift then "write" else "writeToMessage",
                        Parameters := [new CGParameterDefinition("aMessage","ROMessage".AsTypeReference().NotNullable, ExternalName := if IsSwift then "to"),
                                       new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeKind.String), ExternalName := "withName")].ToList,
                        Visibility := CGMemberVisibilityKind.Public);
  if not (aEntity is RodlException) then result.Virtuality := CGMemberVirtualityKind.Override;
  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(
                                                new CGPropertyAccessExpression("aMessage".AsNamedIdentifierExpression, "useStrictFieldOrderForStructs"),
                                                lIfRecordStrictOrder_True,
                                                lIfRecordStrictOrder_False
  );
  result.Statements.Add(lIfRecordStrictOrder);

  if assigned(aEntity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
                      new CGMethodCallExpression(CGInheritedExpression.Inherited, if IsSwift then "write" else "writeToMessage",
                                                ["aMessage".AsNamedIdentifierExpression.AsCallParameter(if IsSwift then "to"),
                                                 new CGCallParameter("aName".AsNamedIdentifierExpression, "withName")].ToList)
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
      lIfRecordStrictOrder_True.Statements.Add(GetWriterStatement(library, field, false));
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(GetWriterStatement(library, lSortedFields.Item[lvalue], false));
end;

method CocoaRodlCodeGen.ReadFromMessage_Method(&library: RodlLibrary; aEntity: RodlStructEntity): CGMethodDefinition;
begin
  //method readFromMessage(aMessage: ROMessage) withName(aName: NSString); override;
  result := new CGMethodDefinition(if IsSwift then "read" else "readFromMessage",
                                  Parameters := [new CGParameterDefinition("aMessage","ROMessage".AsTypeReference().NotNullable, ExternalName := if IsSwift then "from"),
                                                 new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeKind.String), ExternalName :="withName")].ToList,
                                  Visibility := CGMemberVisibilityKind.Public);
  if not (aEntity is RodlException) then result.Virtuality := CGMemberVirtualityKind.Override;
  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(
                                                new CGPropertyAccessExpression("aMessage".AsNamedIdentifierExpression, "useStrictFieldOrderForStructs"),
                                                lIfRecordStrictOrder_True,
                                                lIfRecordStrictOrder_False
  );
  result.Statements.Add(lIfRecordStrictOrder);

  if assigned(aEntity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
      new CGMethodCallExpression(CGInheritedExpression.Inherited, if IsSwift then "read" else "readFromMessage",
                                 ["aMessage".AsNamedIdentifierExpression.AsCallParameter(if IsSwift then "from"),
                                 new CGCallParameter("aName".AsNamedIdentifierExpression, "withName")].ToList)
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
      lIfRecordStrictOrder_True.Statements.Add(GetReaderStatement(library, field));
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(GetReaderStatement(library, lSortedFields.Item[lvalue]));

end;

method CocoaRodlCodeGen.GetWriterStatement(&library: RodlLibrary; aEntity: RodlTypedEntity; aVariableName: String := "aMessage"; isMethod: Boolean; aInOnly: Boolean := false): CGStatement;
begin
  var lLower: String  := aEntity.DataType.ToLowerInvariant();
  var lMethodName: String;
  var lIsEnum := isEnum(&library,aEntity.DataType);
  var lIsComplex := iif(not lIsEnum,isComplex(&library,aEntity.DataType), false);
  var lIsSimple := not (lIsEnum or lIsComplex);

  if lIsEnum then lMethodName := "Enum"
  else if isArray(&library, aEntity.DataType) then  lMethodName := "MutableArray"
  else if isStruct(&library, aEntity.DataType) then lMethodName := "Complex"
  else if ReaderFunctions.ContainsKey(lLower) then lMethodName := ReaderFunctions[lLower]
  else lMethodName := "UnknownType";

  var lIdentifier : CGExpression := if isMethod then
                                      SafeIdentifier(aEntity.Name).AsNamedIdentifierExpression
                                    else
                                      new CGPropertyAccessExpression(nil, SafeIdentifier(aEntity.Name));
  if aEntity is RodlParameter then
    lIdentifier := ApplyParamDirectionExpression(lIdentifier,RodlParameter(aEntity).ParamFlag, aInOnly);
  if lIsComplex or lIsSimple then begin
    exit new CGMethodCallExpression(aVariableName.AsNamedIdentifierExpression,
                                    "write" +  lMethodName,
                                    [lIdentifier.AsCallParameter,
                                     new CGCallParameter(CleanedWsdlName(aEntity.Name).AsLiteralExpression, "withName")].ToList);
  end
  else if lIsEnum then begin
    //aMessage.write%FIELD_READER_WRITER%(Integer(%FIELD_NAME%)) withName("%FIELD_NAME_UNSAFE%") asEnum(%FIELD_TYPE_RAW%__EnumMetaData.instance);
    exit new CGMethodCallExpression(aVariableName.AsNamedIdentifierExpression,
                                    "write" +  lMethodName,
                                    [if IsAppleSwift then new CGPropertyAccessExpression(lIdentifier, "rawValue").AsCallParameter
                                                     else new CGTypeCastExpression(lIdentifier, NSUIntegerType, ThrowsException := true).AsCallParameter,
                                     new CGCallParameter(CleanedWsdlName(aEntity.Name).AsLiteralExpression, "withName"),
                                     new CGCallParameter(new CGMethodCallExpression((aEntity.DataType+"__EnumMetaData").AsTypeReferenceExpression, "instance"), if IsAppleSwift then "as" else "asEnum")].ToList);
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;
end;

method CocoaRodlCodeGen.GetReaderStatement(&library: RodlLibrary; aEntity: RodlTypedEntity; aVariableName: String := "aMessage"): CGStatement;
begin
  exit new CGAssignmentStatement(new CGPropertyAccessExpression(nil, SafeIdentifier(aEntity.Name)), GetReaderExpression(&library,aEntity,aVariableName));
end;

method CocoaRodlCodeGen.GetReaderExpression(&library: RodlLibrary; aEntity: RodlTypedEntity; aVariableName: String := "aMessage"): CGExpression;
begin
  var lLower: String  := aEntity.DataType.ToLowerInvariant();
  var lMethodName: String;
  var lIsEnum := isEnum(&library,aEntity.DataType);
  var lIsComplex := iif(not lIsEnum,isComplex(&library,aEntity.DataType), false);
  var lIsArray := isArray(&library, aEntity.DataType);
  var lIsStruct := isStruct(&library, aEntity.DataType);
  var lIsSimple := not (lIsEnum or lIsComplex);

  if lIsEnum then lMethodName := "Enum"
  else if lIsArray then  lMethodName := "MutableArray"
  else if lIsStruct then lMethodName := "Complex"
  else if ReaderFunctions.ContainsKey(lLower) then lMethodName := ReaderFunctions[lLower]
  else lMethodName := "UnknownType";

  var lNameString := CleanedWsdlName(aEntity.Name).AsLiteralExpression.AsCallParameter(if IsSwift then "withName");
  if isClassType(library, aEntity.DataType) then begin
    // %FIELD_NAME% := aMessage.read%FIELD_READER_WRITER%WithName("%FIELD_NAME_UNSAFE%") asClass(%FIELD_TYPE_NAME%.class) as %FIELD_TYPE_NAME%;
    var lType := ResolveDataTypeToTypeRef(&library, aEntity.DataType);//.NotNullabeCopy;
    if lIsComplex or lIsArray then begin
      //var l_type1:= ResolveDataTypeToTypeRef(&library, aEntity.DataType).NotNullable;
      var lArgument1 := new CGCallParameter(new CGTypeOfExpression(lType.AsExpression), if IsSwift then "as" else "asClass");
      var l_methodCall := new CGMethodCallExpression(aVariableName.AsNamedIdentifierExpression,
                                     if IsSwift then "read"+lMethodName else "read"+lMethodName+"WithName",
                                     [lNameString, lArgument1].ToList);
      exit new CGTypeCastExpression(l_methodCall, lType, ThrowsException := true)
    end
    else begin
      var l_methodCall := new CGMethodCallExpression(aVariableName.AsNamedIdentifierExpression,
                                     if IsSwift then "read"+lMethodName else "read"+lMethodName+"WithName",
                                     [lNameString].ToList);
      exit l_methodCall;
    end;
  end
  else if lIsEnum then begin
    // %FIELD_NAME% := %FIELD_TYPE_RAW%(aMessage.read%FIELD_READER_WRITER%WithName("%FIELD_NAME_UNSAFE%") asEnum(%FIELD_TYPE_RAW%__EnumMetaData.instance));
    var lType := ResolveDataTypeToTypeRef(&library, aEntity.DataType);
    var lArgument1 := new CGCallParameter(new CGMethodCallExpression((SafeIdentifier(aEntity.DataType)+"__EnumMetaData").AsTypeReferenceExpression,"instance"), "asEnum");
    var lMethodCall :=         new CGMethodCallExpression(aVariableName.AsNamedIdentifierExpression,
                                   if IsSwift then "read"+lMethodName else "read"+lMethodName+"WithName",
                                   [lNameString, lArgument1].ToList);
    if IsAppleSwift then
      exit new CGUnaryOperatorExpression(new CGNewInstanceExpression(lType, lMethodCall.AsCallParameter("rawValue")), CGUnaryOperatorKind.ForceUnwrapNullable)
    else
      exit new CGTypeCastExpression(lMethodCall, lType, ThrowsException := true);
  end
  else if lIsSimple then begin
    exit new CGMethodCallExpression(aVariableName.AsNamedIdentifierExpression,
                                   if IsSwift then "read"+lMethodName else "read"+lMethodName+"WithName",
                                   [lNameString].ToList);
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[aEntity.DataType]));
  end;
end;

method CocoaRodlCodeGen.isClassType(&library: RodlLibrary; dataType: String): Boolean;
begin
  exit not (fCachedNumberFN.ContainsKey(dataType.ToLowerInvariant) or isEnum(&library,dataType));
end;

method CocoaRodlCodeGen.GetNumberFN(dataType: String): String;
begin
  var ln := dataType.ToLowerInvariant;
  if fCachedNumberFN.ContainsKey(ln) then
    exit fCachedNumberFN[ln]
  else
    exit "-";
end;

method CocoaRodlCodeGen.ApplyParamDirection(paramFlag: ParamFlags; aInOnly: Boolean := false): CGParameterModifierKind;
begin
  case paramFlag of
    ParamFlags.In: exit CGParameterModifierKind.In;
    ParamFlags.InOut: exit if aInOnly then CGParameterModifierKind.In else CGParameterModifierKind.Var;
    ParamFlags.Out: exit CGParameterModifierKind.Out;
    ParamFlags.Result: raise new Exception("problem with ParamFlags.Result");
  end;
end;

method CocoaRodlCodeGen.GenerateServiceProxyMethod(&library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceProxyMethodDeclaration(&library,aEntity);
  var lInParameters := new List<RodlParameter>;
  var lOutParameters := new List<RodlParameter>;
  for p: RodlParameter in aEntity.Items do begin
    if p.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      lInParameters.Add(p);
    if p.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then
      lOutParameters.Add(p);
  end;
  if assigned(aEntity.Result) then begin
    result.Statements.Add(new CGVariableDeclarationStatement("__result",result.ReturnType));
  end;

  result.Statements.Add(new CGVariableDeclarationStatement("__localMessage",
                                                           "ROMessage".AsTypeReference,
                                                           new CGTypeCastExpression(new CGMethodCallExpression(new CGPropertyAccessExpression(new CGSelfExpression(), "__message") , "copy"), "ROMessage".AsTypeReference(), ThrowsException := true),
                                                           &ReadOnly := true));

  GenerateOperationAttribute(&library,aEntity,result.Statements);
  result.Statements.Add(new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression,
                                                   if IsAppleSwift then "initialize" else "initializeAsRequestMessage",
                                                   [new CGPropertyAccessExpression(new CGSelfExpression, "__clientChannel").AsCallParameter(if IsAppleSwift then "asRequest"),
                                                   new CGCallParameter(library.Name.AsLiteralExpression, "libraryName"),
                                                   new CGCallParameter(new CGMethodCallExpression(new CGSelfExpression(), "__getActiveInterfaceName"), "interfaceName"),
                                                   new CGCallParameter(SafeIdentifier(aEntity.Name).AsLiteralExpression, "messageName")].ToList
    ));

  // Apple Swift can't do and doesn't need the try/finally
  var lTryStatements := new List<CGStatement>;
  var lFinallyStatements := if SwiftDialect = CGSwiftCodeGeneratorDialect.Silver then new List<CGStatement> else lTryStatements;

  for p: RodlParameter in lInParameters do
    lTryStatements.Add(GetWriterStatement(&library, p, " __localMessage", true));
  lTryStatements.Add(new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression, "finalizeMessage"));
  lTryStatements.Add(new CGMethodCallExpression(new CGPropertyAccessExpression(new CGSelfExpression, "__clientChannel"),
                                                 "dispatch",
                                                 ["__localMessage".AsNamedIdentifierExpression.AsCallParameter].ToList));
  if assigned(aEntity.Result) then
    lTryStatements.Add(new CGAssignmentStatement("__result".AsNamedIdentifierExpression,
                                                  GetReaderExpression(&library,aEntity.Result,"__localMessage")));

  for p: RodlParameter in lOutParameters do
    lTryStatements.Add(new CGAssignmentStatement(
                            ApplyParamDirectionExpression(p.Name.AsNamedIdentifierExpression, p.ParamFlag),
                            GetReaderExpression(&library, p ,"__localMessage")
                            ));

  var lSelfMessage := new CGPropertyAccessExpression(new CGSelfExpression, "__message");
  lFinallyStatements.Add(new CGMethodCallExpression(nil, "objc_sync_enter", [lSelfMessage.AsCallParameter].ToList));
  lFinallyStatements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(lSelfMessage, "clientID"),
                                         new CGPropertyAccessExpression("__localMessage".AsNamedIdentifierExpression, "clientID")));
  lFinallyStatements.Add(new CGMethodCallExpression(nil,"objc_sync_exit",   [lSelfMessage.AsCallParameter].ToList));

  if SwiftDialect = CGSwiftCodeGeneratorDialect.Silver then begin
    result.Statements.Add(new CGTryFinallyCatchStatement(lTryStatements, FinallyStatements:= lFinallyStatements as not nullable));
  end
  else begin
    result.Statements.Add(lTryStatements);
  end;

  if assigned(aEntity.Result) then
    result.Statements.Add("__result".AsNamedIdentifierExpression.AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceProxyMethodDeclaration(&library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result:= new CGMethodDefinition(SafeIdentifier(aEntity.Name),
                                  Visibility := CGMemberVisibilityKind.Public);
  for p: RodlParameter in aEntity.Items do begin
    if p.ParamFlag in [ParamFlags.In, ParamFlags.InOut, ParamFlags.Out] then
      result.Parameters.Add(new CGParameterDefinition(p.Name, ResolveDataTypeToTypeRef(&library, p.DataType), Modifier := ApplyParamDirection(p.ParamFlag)));
  end;
  if assigned(aEntity.Result) then
    result.ReturnType := ResolveDataTypeToTypeRef(&library, aEntity.Result.DataType);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod(&library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(&library ,aEntity);
  GenerateServiceAsyncProxyBeginMethod_Body(&library,aEntity,result.Statements);
  // exit self.__clientChannel.asyncDispatch(__localMessage) withProxy(self) start(true);
  result.Statements.Add(new CGMethodCallExpression( new CGPropertyAccessExpression(new CGSelfExpression,"__clientChannel"),
                                                    "asyncDispatch",
                                                    ["__localMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                     new CGCallParameter(new CGSelfExpression(), if IsSwift then "with" else "withProxy"),
                                                     new CGCallParameter(new CGBooleanLiteralExpression(True), "start")].ToList
                          ).AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyEndMethod(&library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := new CGMethodDefinition("end" + PascalCase(aEntity.Name), Visibility := CGMemberVisibilityKind.Public);
  result.Parameters.Add(new CGParameterDefinition("__asyncRequest", "ROAsyncRequest".AsTypeReference));
  var lOutParameters := new List<RodlParameter>;
  for p: RodlParameter in aEntity.Items do begin
    if p.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then begin
      lOutParameters.Add(p);
      result.Parameters.Add(new CGParameterDefinition(p.Name, ResolveDataTypeToTypeRef(&library, p.DataType), Modifier := CGParameterModifierKind.Out)); // end* metbods are always "out"
    end;
  end;

  if assigned(aEntity.Result) then begin
    result.ReturnType := ResolveDataTypeToTypeRef(&library, aEntity.Result.DataType);
  end;

  if assigned(aEntity.Result) then
    result.Statements.Add(new CGVariableDeclarationStatement("__result", result.ReturnType) );
  result.Statements.Add(new CGVariableDeclarationStatement("__localMessage", "ROMessage".AsTypeReference, new CGPropertyAccessExpression("__asyncRequest".AsNamedIdentifierExpression, "responseMessage"), &ReadOnly := true));
  GenerateOperationAttribute(&library,aEntity,Result.Statements);
  if assigned(aEntity.Result) then
    result.Statements.Add(new CGAssignmentStatement("__result".AsNamedIdentifierExpression, GetReaderExpression(&library,aEntity.Result,"__localMessage")));

  for p: RodlParameter in lOutParameters do
    result.Statements.Add(new CGAssignmentStatement(
                                    ApplyParamDirectionExpression(p.Name.AsNamedIdentifierExpression,p.ParamFlag),
                                    GetReaderExpression(&library,p,"__localMessage")
                                    ));

  var lSelfMessage := new CGPropertyAccessExpression(new CGSelfExpression, "__message");
  result.Statements.Add(new CGMethodCallExpression(nil, "objc_sync_enter", [lSelfMessage.AsCallParameter].ToList));
  result.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(lSelfMessage,"clientID"), new CGPropertyAccessExpression("__localMessage".AsNamedIdentifierExpression, "clientID")));
  result.Statements.Add(new CGMethodCallExpression(nil,"objc_sync_exit", [lSelfMessage.AsCallParameter].ToList));

  if assigned(aEntity.Result) then
    result.Statements.Add("__result".AsNamedIdentifierExpression.AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethodDeclaration(&library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := new CGMethodDefinition("begin" + PascalCase(aEntity.Name),
                                   Visibility := CGMemberVisibilityKind.Public,
                                   ReturnType := "ROAsyncRequest".AsTypeReference);
  if IsSwift then
    result.Attributes.Add(new CGAttribute("discardableResult".AsTypeReference));

  for p: RodlParameter in aEntity.Items do begin
    if p.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      result.Parameters.Add(new CGParameterDefinition(p.Name, ResolveDataTypeToTypeRef(&library, p.DataType), Modifier := ApplyParamDirection(p.ParamFlag, true)));
  end;
end;

method CocoaRodlCodeGen.GenerateOperationAttribute(&library: RodlLibrary; aEntity: RodlOperation; Statements: List<CGStatement>);
begin
  var ld := Operation_GetAttributes(&library, aEntity);
  if ld.Count > 0  then begin
    var list:= new List<CGCallParameter>;
    list.Add(new CGBooleanLiteralExpression(False).AsCallParameter);
    for l_key: String in ld.Keys do begin
      list.Add(EscapeString(l_key.ToLowerInvariant).AsLiteralExpression.AsCallParameter);
      list.Add(EscapeString(ld[l_key]).AsLiteralExpression.AsCallParameter);
    end;
    list.Add(new CGNilExpression().AsCallParameter);
    Statements.Add(new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression,
                                              "setupAttributes",
                                              [new CGMethodCallExpression(nil,"DictionaryFromNameValueList",list).AsCallParameter].ToList));
  end;
end;

method CocoaRodlCodeGen.GenerateServiceMethods(&library: RodlLibrary; aEntity: RodlService; service: CGClassTypeDefinition);
begin
  {$REGION method __getInterfaceName: NSString; override;}
  service.Members.Add(
    new CGMethodDefinition("__getInterfaceName",
      [SafeIdentifier(aEntity.Name).AsLiteralExpression.AsReturnStatement],
      ReturnType := CGPredefinedTypeReference.String.NotNullable,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod_start(&library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(&library, aEntity);
  if result.Parameters.Count = 0 then
    result.Name := result.Name+ "__start";
  result.Parameters.Add(new CGParameterDefinition("___start", ResolveStdtypes(CGPredefinedTypeKind.Boolean), Externalname := if result.Parameters.Count > 0 then "start"));
  GenerateServiceAsyncProxyBeginMethod_Body(&library,aEntity,result.Statements);
  result.Statements.Add(new CGMethodCallExpression( new CGPropertyAccessExpression(new CGSelfExpression(),"__clientChannel"),
                                                   "asyncDispatch",
                                                  ["__localMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                   new CGCallParameter(new CGSelfExpression(), if IsSwift then "with" else "withProxy"),
                                                   new CGCallParameter("___start".AsNamedIdentifierExpression, "start")].ToList
                                                  ).AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod_startWithBlock(&library: RodlLibrary; aEntity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(&library, aEntity);
  if result.Parameters.Count = 0 then
    result.Name := result.Name+ "__startWithBlock";
  var bl := new CGInlineBlockTypeReference (new CGBlockTypeDefinition('',Parameters := [new CGParameterDefinition("arg", "ROAsyncRequest".AsTypeReference(CGTypeNullabilityKind.NullableNotUnwrapped))].ToList));
  result.Parameters.Add(new CGParameterDefinition("___block", bl, Externalname := if result.Parameters.Count > 0 then (if IsAppleSwift then "startWith" else "startWithBlock")));
  GenerateServiceAsyncProxyBeginMethod_Body(&library,aEntity,result.Statements);
  result.Statements.Add(new CGMethodCallExpression( new CGPropertyAccessExpression(new CGSelfExpression(),"__clientChannel"),
                                                   "asyncDispatch",
                                                  ["__localMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                   new CGCallParameter(new CGSelfExpression(), if IsSwift then "with" else "withProxy"),
                                                   new CGCallParameter("___block".AsNamedIdentifierExpression, (if IsAppleSwift then "startWith" else "startWithBlock"))].ToList
                          ).AsReturnStatement);
end;

method CocoaRodlCodeGen.ApplyParamDirectionExpression(aExpr: CGExpression; paramFlag: ParamFlags; aInOnly: Boolean := false): CGExpression;
begin
  if Generator is CGObjectiveCCodeGenerator then begin
    case paramFlag of
      ParamFlags.In: exit aExpr;
      ParamFlags.InOut: exit if aInOnly then aExpr else new CGPointerDereferenceExpression(aExpr);
      ParamFlags.Out: exit new CGPointerDereferenceExpression(aExpr);
      ParamFlags.Result: raise new Exception("problem with ParamFlags.Result");
    end;
  end
  else
    exit aExpr;
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod_Body(&library: RodlLibrary; aEntity: RodlOperation; Statements: List<CGStatement>);
begin
  Statements.Add(new CGVariableDeclarationStatement("__localMessage",
                                                    "ROMessage".AsTypeReference,
                                                    new CGTypeCastExpression(new CGMethodCallExpression(new CGPropertyAccessExpression(new CGSelfExpression(), "__message") , "copy"), "ROMessage".AsTypeReference(), ThrowsException := true),
                                                    &ReadOnly := true));
  GenerateOperationAttribute(&library,aEntity,Statements);
  Statements.Add(
    new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression,
                               if IsAppleSwift then "initialize" else "initializeAsRequestMessage",
                               [new CGCallParameter(new CGPropertyAccessExpression(new CGSelfExpression,"__clientChannel"), Name := if IsAppleSwift then "asRequest"),
                                new CGCallParameter(library.Name.AsLiteralExpression, "libraryName"),
                                new CGCallParameter(new CGMethodCallExpression(new CGSelfExpression(), "__getActiveInterfaceName"), "interfaceName"),
                                new CGCallParameter(SafeIdentifier(aEntity.Name).AsLiteralExpression, "messageName")].ToList));
  for p: RodlParameter in aEntity.Items do
    if p.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      Statements.Add(GetWriterStatement(&library,p,"__localMessage", true, true));
  Statements.Add(new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression, "finalizeMessage"));
end;

method CocoaRodlCodeGen.GetNamespace(library: RodlLibrary): String;
begin
  if assigned(library.Includes) then result := library.Includes.CocoaModule;
  if String.IsNullOrWhiteSpace(result) then result := inherited GetNamespace(library);
end;

method CocoaRodlCodeGen.GetGlobalName(library: RodlLibrary): String;
begin
  exit library.Name+"_Defines";
end;

method CocoaRodlCodeGen.AddGlobalConstants(file: CGCodeUnit; library: RodlLibrary);
begin
  var TargetNamespaceName := GetNamespace(library);

  file.Globals.Add(new CGFieldDefinition("TargetNamespace", CGPredefinedTypeReference.String.NotNullable,
                  Constant := true,
                  Visibility := CGMemberVisibilityKind.Public,
                  Initializer := if assigned(TargetNamespaceName) then TargetNamespaceName.AsLiteralExpression).AsGlobal());

  for lentity: RodlEntity in &library.EventSinks.Items do begin
    if not EntityNeedsCodeGen(lentity) then Continue;
    var lName := lentity.Name;
    file.Globals.Add(new CGFieldDefinition(String.Format("EID_{0}",[lName]), CGPredefinedTypeReference.String.NotNullable,
                                          Constant := true,
                                          Visibility := CGMemberVisibilityKind.Public,
                                          Initializer := lName.AsLiteralExpression).AsGlobal);
  end;
end;

end.