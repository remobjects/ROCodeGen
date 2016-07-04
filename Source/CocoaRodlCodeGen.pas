namespace RemObjects.SDK.CodeGen4;
{$HIDE W46}
interface

uses
  Sugar.*,
  RemObjects.CodeGen4;

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
    method GetReaderStatement(library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGStatement;
    method GetReaderExpression(library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGExpression;
    method GetWriterStatement(library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"; isMethod: Boolean; aInOnly: Boolean := false): CGStatement;

    method WriteToMessage_Method(library: RodlLibrary; entity: RodlStructEntity): CGMethodDefinition;
    method ReadFromMessage_Method(library: RodlLibrary; entity: RodlStructEntity): CGMethodDefinition;

    method GenerateServiceProxyMethod(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceProxyMethodDeclaration(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod_Body(library: RodlLibrary; entity: RodlOperation; Statements: List<CGStatement>);
    method GenerateServiceAsyncProxyBeginMethod(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod_start(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethod_startWithBlock(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyBeginMethodDeclaration(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
    method GenerateServiceAsyncProxyEndMethod(library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;

    method GenerateOperationAttribute(library: RodlLibrary; entity: RodlOperation;Statements: List<CGStatement>);
    method GenerateServiceMethods(library: RodlLibrary; entity: RodlService; service:CGClassTypeDefinition);

    method HandleAtributes_private(library: RodlLibrary; entity: RodlEntity): CGFieldDefinition;
    method HandleAtributes_public(library: RodlLibrary; entity: RodlEntity): CGMethodDefinition;
    method ApplyParamDirection(paramFlag: ParamFlags; aInOnly: Boolean := false): CGParameterModifierKind;
    method ApplyParamDirectionExpression(aExpr: CGExpression; paramFlag: ParamFlags; aInOnly: Boolean := false): CGExpression;
  protected
    method isClassType(library: RodlLibrary; dataType: String): Boolean; 
    method AddUsedNamespaces(file: CGCodeUnit; library: RodlLibrary); override;
    method AddGlobalConstants(file: CGCodeUnit; library: RodlLibrary);override;
    method GenerateEnum(file: CGCodeUnit; library: RodlLibrary; entity: RodlEnum); override;
    method GenerateStruct(file: CGCodeUnit; library: RodlLibrary; entity: RodlStruct); override;
    method GenerateArray(file: CGCodeUnit; library: RodlLibrary; entity: RodlArray); override;
    method GenerateOldStyleArray(file: CGCodeUnit; library: RodlLibrary; entity: RodlArray);
    method GenerateException(file: CGCodeUnit; library: RodlLibrary; entity: RodlException); override;
    method GenerateService(file: CGCodeUnit; library: RodlLibrary; entity: RodlService); override;
    method GenerateEventSink(file: CGCodeUnit; library: RodlLibrary; entity: RodlEventSink); override;
    method GetNamespace(library: RodlLibrary): String;override;
    method GetGlobalName(library: RodlLibrary): String;override;
  public
    property SwiftDialect: CGSwiftCodeGeneratorDialect := CGSwiftCodeGeneratorDialect.Silver;
    constructor;
    constructor withSwiftDialect(aSwiftDialect: CGSwiftCodeGeneratorDialect);
  end;

implementation

method CocoaRodlCodeGen.AddUsedNamespaces(file: CGCodeUnit; &library: RodlLibrary);
begin
  file.Imports.Add(new CGImport(new CGNamespaceReference("Foundation")));
  file.Imports.Add(new CGImport(new CGNamespaceReference("RemObjectsSDK")));
  for rodl: RodlUse in library.Uses.Items do begin
    if length(rodl.Includes:ToffeeModule) > 0 then
      file.Imports.Add(new CGImport(new CGNamespaceReference(rodl.Includes.ToffeeModule)))
     else if length(rodl.Namespace) > 0 then
      file.Imports.Add(new CGImport(new CGNamespaceReference(rodl.Namespace)))
    else
      file.HeaderComment.Lines.Add(String.Format("Requires RODL file {0} ({1}) in same namespace.", [rodl.Name, rodl.FileName]));
  end;
end;

method CocoaRodlCodeGen.GenerateEnum(file: CGCodeUnit; &library: RodlLibrary; entity: RodlEnum);
begin
  inherited GenerateEnum(file,&library, entity);
  var lname := SafeIdentifier(entity.Name);
  var lenum := new CGClassTypeDefinition(lname+"__EnumMetaData", "ROEnumMetaData".AsTypeReference,
                                         Visibility := CGTypeVisibilityKind.Public);
  file.Types.Add(lenum);
  lenum.Members.Add(new CGFieldDefinition("stringToValueLookup",
                                          "NSDictionary".AsTypeReference,
                                          Visibility := CGMemberVisibilityKind.Private
          )
  );
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

  {$REGION method stringFromValue(aValue: Integer): NSString;}
  var lcases := new List<CGSwitchStatementCase>;
  for enummember: RodlEnumValue in entity.Items index i do begin
    var lmName := GenerateEnumMemberName(library, entity, enummember);
    lcases.Add(new CGSwitchStatementCase(i.AsLiteralExpression, [CGStatement(lmName.AsLiteralExpression.AsReturnStatement)].ToList));
  end;
  var sw: CGStatement := new CGSwitchStatement("aValue".AsNamedIdentifierExpression,
                                            lcases,
                                            DefaultCase := [CGStatement("<Invalid Enum Value>".AsLiteralExpression.AsReturnStatement)].ToList);
  lenum.Members.Add(new CGMethodDefinition("stringFromValue",
                                          [sw].ToList,
                                          Parameters := [new CGParameterDefinition("aValue", NSUIntegerType)].ToList,
                                          ReturnType:= CGPredefinedTypeReference.String.NotNullable,
                                          Virtuality := CGMemberVirtualityKind.Override,
                                          Visibility := CGMemberVisibilityKind.Public));
  {$ENDREGION}

  {$REGION method valueFromString(aValue: NSString): Integer; override;}
  var largs := new List<CGCallParameter>;
  for enummember: RodlEnumValue in entity.Items do begin
    var lmName := GenerateEnumMemberName(library, entity, enummember);
    largs.Add(new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,
                                          "numberWithInt",
                                        [new CGTypeCastExpression(new CGEnumValueAccessExpression(lname.AsTypeReference,lmName), NSUIntegerType, ThrowsException := true).AsCallParameter].ToList
    ).AsEllipsisCallParameter);
    largs.Add(lmName.AsLiteralExpression.AsEllipsisCallParameter);
  end;
  largs.Add(new CGNilExpression().AsEllipsisCallParameter);
  lenum.Members.Add(new CGMethodDefinition(
        "valueFromString",
        Parameters := [new CGParameterDefinition("aValue", CGPredefinedTypeReference.String.NotNullable)].ToList,
        ReturnType:= NSUIntegerType,
        Virtuality := CGMemberVirtualityKind.Override,
        Visibility := CGMemberVisibilityKind.Public,
        Statements:= [{0}new CGIfThenElseStatement(
                            new CGAssignedExpression("stringToValueLookup".AsNamedIdentifierExpression, Inverted := true),
                            new CGAssignmentStatement("stringToValueLookup".AsNamedIdentifierExpression,
                                                      new CGNewInstanceExpression("NSDictionary".AsTypeReference, largs, ConstructorName := "withObjectsAndKeys"))),
                      {1}new CGVariableDeclarationStatement("lResult",
                                                            "NSNumber".AsTypeReference,
                                                            new CGMethodCallExpression("stringToValueLookup".AsNamedIdentifierExpression,
                                                                                             "valueForKey",
                                                                                             ["aValue".AsNamedIdentifierExpression.AsCallParameter].ToList)
                              ),
                      {2}new CGIfThenElseStatement(
                            new CGAssignedExpression("lResult".AsNamedIdentifierExpression),
                            new CGPropertyAccessExpression("lResult".AsNamedIdentifierExpression,"intValue").AsReturnStatement,
                            new CGThrowStatement(new CGNewInstanceExpression("NSException".AsTypeReference,
                                                                             ["ROException".AsLiteralExpression.AsCallParameter,
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
                                               "stringFromValue",
                                               [new CGTypeCastExpression("aValue".AsNamedIdentifierExpression, NSUIntegerType).AsCallParameter].ToList
                                              ).AsReturnStatement],
      Parameters := [new CGParameterDefinition("aValue",lname.AsTypeReference)].ToList,
      ReturnType := CGPredefinedTypeReference.String.NotNullable,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateStruct(file: CGCodeUnit; &library: RodlLibrary; entity: RodlStruct);
begin
  var lancestorName := entity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then lancestorName := "ROComplexType";

  var lstruct := new CGClassTypeDefinition(SafeIdentifier(entity.Name), lancestorName.AsTypeReference,
                                           Visibility := CGTypeVisibilityKind.Public,
                                           Comment := GenerateDocumentation(entity));
  if IsSwift then
    lstruct.Attributes.Add(new CGAttribute("objc".AsTypeReference, SafeIdentifier(entity.Name).AsNamedIdentifierExpression.AsCallParameter));
  file.Types.Add(lstruct);
  {$REGION private class class __attributes: NSDictionary;}
  if (entity.CustomAttributes.Count > 0) then
    lstruct.Members.Add(HandleAtributes_private(&library,entity));
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (entity.CustomAttributes.Count > 0) then
    lstruct.Members.Add(HandleAtributes_public(&library,entity));
  {$ENDREGION}
  {$REGION public property %fldname%: %fldtype%}
  for lm :RodlTypedEntity in entity.Items do
    lstruct.Members.Add(new CGPropertyDefinition(lm.Name,
                                                 ResolveDataTypeToTypeRef(&library,lm.DataType),
                                                 Visibility := CGMemberVisibilityKind.Public,
                                                 Comment := GenerateDocumentation(lm)));
  {$ENDREGION}
  {$REGION method assignFrom(aValue: ROComplexType); override;}
  lstruct.Members.Add(
    new CGMethodDefinition("assignFrom",
      Parameters := [new CGParameterDefinition("aValue", "ROComplexType".AsTypeReference(CGTypeNullabilityKind.NotNullable))].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public    )
  );
  {$ENDREGION}

  if entity.Items.Count >0 then begin
    {$REGION public method writeToMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lstruct.Members.Add(WriteToMessage_Method(&library,entity));
    {$ENDREGION}
    {$REGION public method readFromMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lstruct.Members.Add(ReadFromMessage_Method(&library,entity));
    {$ENDREGION}
  end;
end;

method CocoaRodlCodeGen.GenerateArray(file: CGCodeUnit; &library: RodlLibrary; entity: RodlArray);
begin
  var larray := new CGClassTypeDefinition(SafeIdentifier(entity.Name), "ROMutableArray".AsTypeReference,
                                          Visibility := CGTypeVisibilityKind.Public,
                                          Comment := GenerateDocumentation(entity));
  file.Types.Add(larray);

  {$REGION private class __attributes: NSDictionary;}
  if (entity.CustomAttributes.Count > 0) then
    larray.Members.Add(HandleAtributes_private(&library,entity));
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (entity.CustomAttributes.Count > 0) then
    larray.Members.Add(HandleAtributes_public(&library,entity));
  {$ENDREGION}

  var l_elementType:= ResolveDataTypeToTypeRef(&library,SafeIdentifier(entity.ElementType));
  var lisEnum := isEnum(&library,entity.ElementType);
  var lisComplex := isComplex(&library, entity.ElementType);
  var lisArray := isArray(&library, entity.ElementType);
  var lIsSimple := not (lisEnum or lisComplex);
  
  {$REGION method itemClass: &Class; override;}
  if lisComplex then begin
    var l_elementType2 := ResolveDataTypeToTypeRef(&library,SafeIdentifier(entity.ElementType)).NotNullable;
    larray.Members.Add(
      new CGPropertyDefinition(
        "itemClass", CGPredefinedTypeReference.Class.NotNullable,
        GetExpression := new CGTypeOfExpression(l_elementType2.AsExpression),
        Visibility := CGMemberVisibilityKind.Public,
        Virtuality := CGMemberVirtualityKind.Override,
        Atomic := true));
  end;
  {$ENDREGION}

  {$REGION - (void)writeItem:(id)item toMessage:(ROMessage *)aMessage withIndex:(NSUInteger)index; }
  var lst := new List<CGStatement>;

  //var __item: %ARRAY_TYPE% := self.itemAtIndex(aIndex);
  var getItemAtIndex: CGExpression := new CGArrayElementAccessExpression(new CGSelfExpression, ["aIndex".AsNamedIdentifierExpression]);
  if lIsSimple then begin
    var getItemAtIndexAsNSNumber := new CGTypeCastExpression(getItemAtIndex, "NSNumber".AsTypeReference, ThrowsException := true);
    case entity.ElementType.ToLower of
      "integer": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "intValue");
      "int64": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "longLongValue");
      "double": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "doubleValue");
      "boolean": getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndexAsNSNumber, "boolValue");
    end;
  end else if lisEnum then begin
    getItemAtIndex := new CGTypeCastExpression(getItemAtIndex, "NSNumber".AsTypeReference, ThrowsException := true);
    getItemAtIndex := new CGPropertyAccessExpression(getItemAtIndex, "integerValue");
    getItemAtIndex := new CGTypeCastExpression(getItemAtIndex, l_elementType, ThrowsException := true);
  end else begin
    getItemAtIndex := new CGTypeCastExpression(getItemAtIndex, l_elementType, ThrowsException := true);
  end;
  lst.Add(new CGVariableDeclarationStatement("__item", l_elementType, getItemAtIndex, &ReadOnly := true));

  var lLower: String  := entity.ElementType.ToLower();
  var l_methodName: String;
  if ReaderFunctions.ContainsKey(lLower) then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, entity.ElementType) then begin
    l_methodName := "MutableArray";
  end
  else if isStruct(&library, entity.ElementType) then begin
    l_methodName := "Complex";
  end
  else if lisEnum then begin
    l_methodName := "Enum";
  end;

  var lar := new List<CGCallParameter>;
  lar.Add("__item".AsNamedIdentifierExpression.AsCallParameter);
  lar.Add(new CGCallParameter(new CGNilExpression(), "withName"));
  if lisEnum then
    lar.Add(new CGCallParameter(new CGMethodCallExpression((entity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), "asEnum"));

  lst.Add(new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, "write" +  l_methodName, lar));
  larray.Members.Add(
    new CGMethodDefinition( "writeItem",
      Parameters := [new CGParameterDefinition("aItem", CGPredefinedTypeReference.Dynamic.NotNullable),
                     new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference(CGTypeNullabilityKind.NotNullable), Externalname := "toMessage"),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := "withIndex")].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lst as not nullable));
  {$ENDREGION}

  {$REGION - (id)readItemFromMessage:(ROMessage *)aMessage withIndex:(NSUInteger)index; }
  lst := new List<CGStatement>;
  
  lar:= new List<CGCallParameter>;
  lar.Add(new CGNilExpression().AsCallParameter);
  if lisEnum then
    lar.Add(new CGCallParameter(new CGMethodCallExpression((entity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), "asEnum"));
  if lisComplex or lisArray then
    lar.Add(new CGCallParameter(new CGPropertyAccessExpression(nil, "itemClass"), "asClass"));

  var lexp: CGExpression := new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, "read" +  l_methodName+"WithName",  lar);

  if lisComplex or lisEnum or lisArray then
    lexp := new CGTypeCastExpression(lexp, l_elementType, ThrowsException := true);
  lst.Add(new CGVariableDeclarationStatement("__item", l_elementType, lexp, &ReadOnly := true));

  var item: CGExpression := "__item".AsNamedIdentifierExpression;
  if lIsSimple then begin
    case entity.ElementType.ToLower of
      "integer": item := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithInteger", [item.AsCallParameter]);
      "int64": item := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithLongLong", [item.AsCallParameter]);
      "double": item := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithDouble", [item.AsCallParameter]);
      "boolean": item := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithBool", [item.AsCallParameter]);
    end;
  end else if lisEnum then begin
    item := new CGTypeCastExpression(item, "NSInteger".AsTypeReference, ThrowsException := true);
    item := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression, "numberWithInteger", [item.AsCallParameter]);
  end;  
  lst.Add(item.AsReturnStatement);
  
  larray.Members.Add(
    new CGMethodDefinition("readItemFromMessage",
      Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference(CGTypeNullabilityKind.NotNullable)),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := "withIndex")].ToList,
                     ReturnType := CGPredefinedTypeReference.Dynamic.NullableNotUnwrapped,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lst as not nullable));
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateOldStyleArray(file: CGCodeUnit; &library: RodlLibrary; entity: RodlArray);
begin
  var larray := new CGClassTypeDefinition(SafeIdentifier(entity.Name), "ROArray".AsTypeReference,
                                          Visibility := CGTypeVisibilityKind.Public,
                                          Comment := GenerateDocumentation(entity));
  file.Types.Add(larray);
  {$REGION private class __attributes: NSDictionary;}
  if (entity.CustomAttributes.Count > 0) then
    larray.Members.Add(HandleAtributes_private(&library,entity));
  {$ENDREGION}
  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (entity.CustomAttributes.Count > 0) then
    larray.Members.Add(HandleAtributes_public(&library,entity));
  {$ENDREGION}

  var l_elementType:= ResolveDataTypeToTypeRef(&library,SafeIdentifier(entity.ElementType));
  var lisEnum := isEnum(&library,entity.ElementType);
  var lisComplex := iif(not lisEnum,isComplex(&library,entity.ElementType), false) ;
  var lisSimple := not (lisEnum or lisComplex);

  {$REGION method add: %ARRAY_TYPE%;}
  if lisComplex then
    larray.Members.Add(
      new CGMethodDefinition("add",
        ReturnType := l_elementType,
        Visibility := CGMemberVisibilityKind.Public,
        Statements:=
          [new CGVariableDeclarationStatement('lresult',l_elementType, new CGNewInstanceExpression(l_elementType)),
           new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", ["lresult".AsNamedIdentifierExpression.AsCallParameter].ToList),
           "lresult".AsNamedIdentifierExpression.AsReturnStatement
          ].ToList
        )
    );
  {$ENDREGION}

  {$REGION method addItem(aObject: %ARRAY_TYPE%);}
  var lexp : CGExpression := "aObject".AsNamedIdentifierExpression;
  if lisEnum then     lexp := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWithInt", [lexp.AsCallParameter].ToList);
  if lisSimple then   lexp := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWith"+GetNumberFN(entity.ElementType), [lexp.AsCallParameter].ToList);
  larray.Members.Add(
    new CGMethodDefinition("addItem",
      [new CGMethodCallExpression(CGInheritedExpression.Inherited, "addItem", [lexp.AsCallParameter].ToList)],
      Parameters := [new CGParameterDefinition("aObject", l_elementType)].ToList,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method insertItem(aObject: %ARRAY_TYPE%) atIndex(aIndex: NSUInteger);}
  larray.Members.Add(
    new CGMethodDefinition("insertItem",
      [new CGMethodCallExpression(CGInheritedExpression.Inherited, "insertItem", [lexp.AsCallParameter,new CGCallParameter("aIndex".AsNamedIdentifierExpression, "atIndex")].ToList)],
      Parameters := [new CGParameterDefinition("aObject", l_elementType),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := "atIndex")].ToList,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}

  {$REGION method replaceItemAtIndex(aIndex: NSUInteger) withItem(aItem: %ARRAY_TYPE%);}
  lexp := "aItem".AsNamedIdentifierExpression;
  if lisEnum then   lexp := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWithInt",[lexp.AsCallParameter].ToList);
  if lisSimple then lexp := new CGMethodCallExpression("NSNumber".AsTypeReferenceExpression,"numberWith"+GetNumberFN(entity.ElementType),[lexp.AsCallParameter].ToList);
  larray.Members.Add(
    new CGMethodDefinition("replaceItemAtIndex",
                          [new CGMethodCallExpression(CGInheritedExpression.Inherited, "replaceItemAtIndex",
                                                                                                  ["aIndex".AsNamedIdentifierExpression.AsCallParameter,
                                                                                                   new CGCallParameter(lexp, "withItem")].ToList)],
                            Parameters := [new CGParameterDefinition("aIndex", NSUIntegerType),
                                          new CGParameterDefinition("aItem", l_elementType, Externalname := "withItem")].ToList,
                            Visibility := CGMemberVisibilityKind.Public)
  );
  {$ENDREGION}

  {$REGION method itemAtIndex(aIndex: NSUInteger): %ARRAY_TYPE%;}
  var lst := new List<CGStatement>;
  if lisComplex then begin
    //  exit inherited itemAtIndex(aIndex) as %ARRAY_TYPE%;
    lst.Add(new CGTypeCastExpression(
              new CGMethodCallExpression(CGInheritedExpression.Inherited, "itemAtIndex", ["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList),
              l_elementType,
              ThrowsException := True
              ).AsReturnStatement);
  end;
  if lisSimple then begin
    //  var __result: Integer;
    //  __result := (inherited itemAtIndex(aIndex) as NSNumber) as %ARRAY_TYPE%;
    //  exit __result;
    lst.Add(new CGVariableDeclarationStatement("__result",ResolveStdtypes(CGPredefinedTypeKind.Int32)));
    lst.Add(new CGAssignmentStatement(
                                     "__result".AsNamedIdentifierExpression,
                                     new CGTypeCastExpression(
                                        new CGTypeCastExpression(
                                          new CGMethodCallExpression(CGInheritedExpression.Inherited, "itemAtIndex", ["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList),
                                          "NSNumber".AsTypeReference,
                                          ThrowsException := True
                                          ),
                                      l_elementType,
                                      ThrowsException := True
                                     )

                  ));
    lst.Add("__result".AsNamedIdentifierExpression.AsReturnStatement);
  end;
  if lisEnum then begin
    //  exit inherited itemAtIndex(aIndex).intValue;
    lst.Add( new CGPropertyAccessExpression(
                    new CGMethodCallExpression(CGInheritedExpression.Inherited, "itemAtIndex", ["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList),
                    "intValue").AsReturnStatement);

  end;
  larray.Members.Add(
    new CGMethodDefinition("itemAtIndex",
      Parameters := [new CGParameterDefinition("aIndex", NSUIntegerType)].ToList,
      ReturnType := l_elementType,
      Visibility := CGMemberVisibilityKind.Public,
      Virtuality := CGMemberVirtualityKind.Reintroduce,
      statements := lst as not nullable));
  {$ENDREGION}

  {$REGION method itemClass: &Class; override;}
  if lisComplex then begin
    var l_elementType2 := ResolveDataTypeToTypeRef(&library,SafeIdentifier(entity.ElementType)).NotNullable;
    larray.Members.Add(
      new CGPropertyDefinition(
        "itemClass", CGPredefinedTypeReference.Class,
        GetExpression := new CGTypeOfExpression(l_elementType2.AsExpression),
        Visibility := CGMemberVisibilityKind.Public,
        Virtuality := CGMemberVirtualityKind.Override,
        Atomic := true));
  end;
  {$ENDREGION}

  {$REGION method itemTypeName: NSString; override;}
  larray.Members.Add(
    new CGPropertyDefinition("itemTypeName", CGPredefinedTypeReference.String.NotNullable,
                          GetExpression := entity.ElementType.AsLiteralExpression,
                          Virtuality := CGMemberVirtualityKind.Override,
                          Visibility := CGMemberVisibilityKind.Public,
                          Atomic := true));
  {$ENDREGION}

  {$REGION method writeItemToMessage(aMessage: ROMessage) fromIndex(aIndex: Integer); override;}
  lst := new List<CGStatement>;
  //var __item: %ARRAY_TYPE% := self.itemAtIndex(aIndex);
  lst.Add(new CGVariableDeclarationStatement("__item",l_elementType,new CGMethodCallExpression(new CGSelfExpression,"itemAtIndex",["aIndex".AsNamedIdentifierExpression.AsCallParameter].ToList), &ReadOnly := true));
  var lLower: String  := entity.ElementType.ToLower();
  var l_methodName: String;
  if ReaderFunctions.ContainsKey(lLower) then begin
    l_methodName := ReaderFunctions[lLower];
  end
  else if isArray(&library, entity.ElementType) then begin
    l_methodName := "MutableArray";
  end
  else if isStruct(&library, entity.ElementType) then begin
    l_methodName := "Complex";
  end
  else if lisEnum then begin
    l_methodName := "Enum";
  end;

  var lar := new List<CGCallParameter>;
  lar.Add("__item".AsNamedIdentifierExpression.AsCallParameter);
  lar.Add(new CGCallParameter(new CGNilExpression(), "withName"));
  if lisEnum then
    lar.Add(new CGCallParameter(new CGMethodCallExpression((entity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), "asEnum"));

  lst.Add(new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, "write" +  l_methodName, lar));
  larray.Members.Add(
    new CGMethodDefinition( "writeItemToMessage",
      Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname :="fromIndex" )].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lst as not nullable));
  {$ENDREGION}

  {$REGION method method readItemFromMessage(aMessage: ROMessage) toIndex(aIndex: Integer); override;}
  lst:=new List<CGStatement>;
  //  var __item: %ARRAY_TYPE%;
  lst.Add(new CGVariableDeclarationStatement("__item", l_elementType.NotNullable, &ReadOnly := true));
  lar:= new List<CGCallParameter>;
  lar.Add(new CGNilExpression().AsCallParameter);
  if lisEnum then
    lar.Add(new CGCallParameter(new CGMethodCallExpression((entity.ElementType+"__EnumMetaData").AsTypeReferenceExpression,"instance"), "asEnum"));
  if lisComplex then
    lar.Add(new CGCallParameter(new CGPropertyAccessExpression(new CGSelfExpression, "itemClass"), "asClass"));

  lexp := new CGMethodCallExpression("aMessage".AsNamedIdentifierExpression, "read" +  l_methodName+"WithName",  lar);

  if lisComplex then
    lexp := new CGTypeCastExpression(
       lexp,
       l_elementType,
       ThrowsException := true);
  lst.Add(new CGAssignmentStatement("__item".AsNamedIdentifierExpression, lexp));
  lst.Add(new CGCommentStatement("for efficiency, assumes this is called in ascending order"));
  lst.Add(new CGMethodCallExpression(new CGSelfExpression, "addItem",["__item".AsNamedIdentifierExpression.AsCallParameter].ToList));
  larray.Members.Add(
    new CGMethodDefinition("readItemFromMessage",
      Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference),
                     new CGParameterDefinition("aIndex", NSUIntegerType, Externalname := "toIndex")].ToList,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public,
      Statements := lst as not nullable));
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateException(file: CGCodeUnit; &library: RodlLibrary; entity: RodlException);
begin
  var lancestorName := entity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then lancestorName := "ROException";
  var lexception := new CGClassTypeDefinition(SafeIdentifier(entity.Name), lancestorName.AsTypeReference,
                                              Visibility := CGTypeVisibilityKind.Public,
                                              Comment := GenerateDocumentation(entity));
  file.Types.Add(lexception);

  {$REGION private class class __attributes: NSDictionary;}
  if (entity.CustomAttributes.Count > 0) then
    lexception.Members.Add(HandleAtributes_private(&library,entity));
  {$ENDREGION}

  {$REGION public class method getAttributeValue(aName: NSString): NSString;}
  if (entity.CustomAttributes.Count > 0) then
    lexception.Members.Add(HandleAtributes_public(&library,entity));
  {$ENDREGION}

  {$REGION public property %fldname%: %fldtype%}
  for lm :RodlTypedEntity in entity.Items do
    lexception.Members.Add(new CGPropertyDefinition(lm.Name,
                                                    ResolveDataTypeToTypeRef(&library,lm.DataType),
                                                    Visibility:= CGMemberVisibilityKind.Public,
                                                    Comment := GenerateDocumentation(lm)));
  {$ENDREGION}

  {$REGION public method initWithMessage(anExceptionMessage: NSString; a%FIELD_NAME_UNSAFE%: %FIELD_TYPE%);dynamic;}
  var linitWithMessage := new CGConstructorDefinition("withMessage", Visibility := CGMemberVisibilityKind.Public);
  lexception.Members.Add(linitWithMessage);
  var lAncestorEntity := entity as RodlStructEntity;
  var st:= new CGBeginEndBlockStatement;
  var llist:= new List<CGCallParameter>;
  while assigned(lAncestorEntity) do begin
    var memberlist:= new List<CGParameterDefinition>;

    var arlist:= new List<CGCallParameter>;
    for lm: RodlTypedEntity in lAncestorEntity.Items do begin
      var lname := "a"+lm.Name;
      memberlist.Add(new CGParameterDefinition(lname, ResolveDataTypeToTypeRef(lm.OwnerLibrary,lm.DataType)));
      if lAncestorEntity = entity then
        st.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(nil, SafeIdentifier(lm.Name)),
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
  linitWithMessage.Statements.AddRange(st.Statements);

  {$ENDREGION}

  if entity.Items.Count >0 then begin
    {$REGION public method writeToMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lexception.Members.Add(WriteToMessage_Method(&library,entity));
    {$ENDREGION}
    {$REGION public method readFromMessage(aMessage: ROMessage) withName(aName: NSString); override;}
    lexception.Members.Add(ReadFromMessage_Method(&library,entity));
    {$ENDREGION}
  end;
end;

method CocoaRodlCodeGen.GenerateService(file: CGCodeUnit; &library: RodlLibrary; entity: RodlService);
begin
  {$REGION I%SERVICE_NAME%}
  var lIService := new CGInterfaceTypeDefinition(SafeIdentifier("I"+entity.Name),
                                                 Visibility := CGTypeVisibilityKind.Public,
                                                 Comment := GenerateDocumentation(entity));
  file.Types.Add(lIService);
  for lop : RodlOperation in entity.DefaultInterface:Items do begin
    var lm := GenerateServiceProxyMethodDeclaration(&library, lop);
    lm.Comment := GenerateDocumentation(lop, true);
    lIService.Members.Add(lm);
  end;

  {$ENDREGION}

  {$REGION %SERVICE_NAME%_Proxy}
  var lancestorName := entity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then
    lancestorName := "ROProxy"
  else
    lancestorName := lancestorName+"_Proxy";
  var lServiceProxy := new CGClassTypeDefinition(SafeIdentifier(entity.Name+"_Proxy"),
                                                 [lancestorName.AsTypeReference].ToList,
                                                 [lIService.Name.AsTypeReference].ToList,
                                                 Visibility := CGTypeVisibilityKind.Public
                                                 );
  file.Types.Add(lServiceProxy);

  GenerateServiceMethods(&library,entity, lServiceProxy);

  for lop : RodlOperation in entity.DefaultInterface:Items do
    lServiceProxy.Members.Add(GenerateServiceProxyMethod(&library,lop));
  {$ENDREGION}

  {$REGION %SERVICE_NAME%_AsyncProxy}
  lancestorName := entity.AncestorName;
  if String.IsNullOrEmpty(lancestorName) then
    lancestorName := "ROAsyncProxy"
  else
    lancestorName := lancestorName+"_AsyncProxy";

  var lServiceAsyncProxy := new CGClassTypeDefinition(SafeIdentifier(entity.Name+"_AsyncProxy"),lancestorName.AsTypeReference,
                            Visibility := CGTypeVisibilityKind.Public
                            );
  file.Types.Add(lServiceAsyncProxy);
  GenerateServiceMethods(&library,entity,lServiceAsyncProxy);
  for lop : RodlOperation in entity.DefaultInterface:Items do begin
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod(&library, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod_start(&library, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyBeginMethod_startWithBlock(&library, lop));
    lServiceAsyncProxy.Members.Add(GenerateServiceAsyncProxyEndMethod(&library, lop));
  end;
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateEventSink(file: CGCodeUnit; &library: RodlLibrary; entity: RodlEventSink);
begin
  var lIEvent := new CGInterfaceTypeDefinition("I"+entity.Name,
                                              Visibility := CGTypeVisibilityKind.Public,
                                              Comment:= GenerateDocumentation(entity));
  file.Types.Add(lIEvent);

  var lEventInvoker := new CGClassTypeDefinition(entity.Name+"_EventInvoker", "ROEventInvoker".AsTypeReference,
                            Visibility := CGTypeVisibilityKind.Public
                            );
  file.Types.Add(lEventInvoker);

  for lop : RodlOperation in entity.DefaultInterface:Items do begin

    var lievent_method := new CGMethodDefinition(lop.Name,
                                                 Visibility := CGMemberVisibilityKind.Public,
                                                 Comment:= GenerateDocumentation(lop, true));
    lIEvent.Members.Add(lievent_method);
    var lInParam:=new List<RodlParameter>;
    for lm :RodlParameter in lop.Items do begin
      lievent_method.Parameters.Add(new CGParameterDefinition(SafeIdentifier(lm.Name),ResolveDataTypeToTypeRef(library,lm.DataType), Modifier := ApplyParamDirection(lm.ParamFlag)));
      if lm.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then lInParam.Add(lm);
    end;

    var linvk_method := new CGMethodDefinition("Invoke_"+lop.Name,
                              Parameters := [new CGParameterDefinition("aMessage", "ROMessage".AsTypeReference),
                                             new CGParameterDefinition("aHandler", ResolveStdtypes(CGPredefinedTypeKind.Object), Externalname := "handler")].ToList,
                              ReturnType:= ResolveStdtypes(CGPredefinedTypeKind.Boolean),
      Visibility := CGMemberVisibilityKind.Public);
    lEventInvoker.Members.Add(linvk_method);
    if IsAppleSwift then begin
      linvk_method.Statements.Add(new CGVariableDeclarationStatement("__selPattern",
                                                                     "NSString".AsTypeReference(CGTypeNullabilityKind.NotNullable),
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
    for lm: RodlParameter in lInParam do begin
      var lm_name:= "__"+SafeIdentifier(lm.Name);
      if_true.Statements.Add(new CGVariableDeclarationStatement(lm_name,ResolveDataTypeToTypeRef(library,lm.DataType),GetReaderExpression(&library,lm)));
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
  CodeGenTypes.Add("datetime", "NSDate".AsTypeReference(CGTypeNullabilityKind.NullableUnwrapped));
  CodeGenTypes.Add("double", ResolveStdtypes(CGPredefinedTypeKind.Double));
  CodeGenTypes.Add("currency", "NSDecimalNumber".AsTypeReference(CGTypeNullabilityKind.NullableUnwrapped));
  CodeGenTypes.Add("widestring", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("ansistring", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("int64", ResolveStdtypes(CGPredefinedTypeKind.Int64));
  CodeGenTypes.Add("boolean", ResolveStdtypes(CGPredefinedTypeKind.Boolean));
  CodeGenTypes.Add("variant", "ROVariant".AsTypeReference);
  CodeGenTypes.Add("binary", "NSData".AsTypeReference);
  CodeGenTypes.Add("xml", "ROXml".AsTypeReference);
  CodeGenTypes.Add("guid", "ROGuid".AsTypeReference);
  CodeGenTypes.Add("decimal", "NSDecimalNumber".AsTypeReference(CGTypeNullabilityKind.NullableUnwrapped));
  CodeGenTypes.Add("utf8string", ResolveStdtypes(CGPredefinedTypeKind.String));
  CodeGenTypes.Add("xsdatetime", "NSDate".AsTypeReference(CGTypeNullabilityKind.NullableUnwrapped));

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

  {ReservedWords.AddRange([
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

method CocoaRodlCodeGen.HandleAtributes_private(&library: RodlLibrary; entity: RodlEntity): CGFieldDefinition;
begin
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (entity.CustomAttributes.Count = 0) then exit;
  exit new CGFieldDefinition(
                  "__attributes",
                  "NSDictionary".AsTypeReference,
                  &Static := true,
                  Visibility := CGMemberVisibilityKind.Private);
end;

method CocoaRodlCodeGen.HandleAtributes_public(&library: RodlLibrary; entity: RodlEntity): CGMethodDefinition;
begin
  // There is no need to generate CustomAttribute-related methods if there is no custom attributes
  if (entity.CustomAttributes.Count = 0) then exit;
  Result := new CGMethodDefinition("getAttributeValue",
                                  ReturnType := CGPredefinedTypeReference.String,
                                  Parameters := [new CGParameterDefinition("aName", CGPredefinedTypeReference.String.NotNullable)].ToList,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  Virtuality := CGMemberVirtualityKind.Override,
                                  &Static := true);

  var l_attributes := "__attributes".AsNamedIdentifierExpression;
  var list:= new List<CGCallParameter>;
  list.Add(new CGBooleanLiteralExpression(False).AsCallParameter);
  for l_key: String in entity.CustomAttributes.Keys do begin
    list.Add(EscapeString(l_key.ToLower).AsLiteralExpression.AsCallParameter);
    list.Add(EscapeString(entity.CustomAttributes[l_key]).AsLiteralExpression.AsCallParameter);
  end;
  list.Add(new CGNilExpression().AsCallParameter);

  Result.Statements.Add(new CGIfThenElseStatement(
      new CGAssignedExpression(l_attributes, Inverted := true),
      new CGAssignmentStatement(l_attributes,
                                new CGMethodCallExpression(nil,"DictionaryFromNameValueList", list)
      )));

  Result.Statements.Add(new CGMethodCallExpression(l_attributes, "objectForKey",
                                                   [new CGMethodCallExpression("aName".AsNamedIdentifierExpression, "lowercaseString").AsCallParameter].ToList).AsReturnStatement);
end;

method CocoaRodlCodeGen.WriteToMessage_Method(&library: RodlLibrary; entity: RodlStructEntity): CGMethodDefinition;
begin
  //method writeToMessage(aMessage: ROMessage) withName(aName: NSString); override;
  Result := new CGMethodDefinition("writeToMessage",
                        Parameters := [new CGParameterDefinition("aMessage","ROMessage".AsTypeReference(CGTypeNullabilityKind.NotNullable)),
                                       new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeKind.String), ExternalName := "withName")].ToList,
                        Visibility := CGMemberVisibilityKind.Public);
  if not (entity is RodlException) then result.Virtuality := CGMemberVirtualityKind.Override;
  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(
                                                new CGPropertyAccessExpression("aMessage".AsNamedIdentifierExpression, "useStrictFieldOrderForStructs"),
                                                lIfRecordStrictOrder_True,
                                                lIfRecordStrictOrder_False
  );
  Result.Statements.Add(lIfRecordStrictOrder);

  if assigned(entity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
                      new CGMethodCallExpression(CGInheritedExpression.Inherited, "writeToMessage",
                                                ["aMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                 new CGCallParameter("aName".AsNamedIdentifierExpression, "withName")].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := entity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for field: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(field.Name.ToLower, field);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for field: RodlField in entity.Items do
    if not lSortedFields.ContainsKey(field.Name.ToLower) then begin
      lSortedFields.Add(field.Name.ToLower, field);
      lIfRecordStrictOrder_True.Statements.Add(GetWriterStatement(library, field, false));
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(GetWriterStatement(library, lSortedFields.Item[lvalue], false));
end;

method CocoaRodlCodeGen.ReadFromMessage_Method(&library: RodlLibrary; entity: RodlStructEntity): CGMethodDefinition;
begin
  //method readFromMessage(aMessage: ROMessage) withName(aName: NSString); override;
  Result := new CGMethodDefinition("readFromMessage",
                                  Parameters := [new CGParameterDefinition("aMessage","ROMessage".AsTypeReference(CGTypeNullabilityKind.NotNullable)),
                                                 new CGParameterDefinition("aName", ResolveStdtypes(CGPredefinedTypeKind.String),ExternalName :="withName")].ToList,
                                  Visibility := CGMemberVisibilityKind.Public);
  if not (entity is RodlException) then result.Virtuality := CGMemberVirtualityKind.Override;
  var lIfRecordStrictOrder_True := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder_False := new CGBeginEndBlockStatement;
  var lIfRecordStrictOrder := new CGIfThenElseStatement(
                                                new CGPropertyAccessExpression("aMessage".AsNamedIdentifierExpression, "useStrictFieldOrderForStructs"),
                                                lIfRecordStrictOrder_True,
                                                lIfRecordStrictOrder_False
  );
  Result.Statements.Add(lIfRecordStrictOrder);

  if assigned(entity.AncestorEntity) then begin
    lIfRecordStrictOrder_True.Statements.Add(
      new CGMethodCallExpression(CGInheritedExpression.Inherited, "readFromMessage",
                                 ["aMessage".AsNamedIdentifierExpression.AsCallParameter,
                                 new CGCallParameter("aName".AsNamedIdentifierExpression, "withName")].ToList)
    );
  end;

  var lSortedFields := new Dictionary<String,RodlField>;

  var lAncestorEntity := entity.AncestorEntity as RodlStructEntity;
  while assigned(lAncestorEntity) do begin
    for field: RodlField in lAncestorEntity.Items do
      lSortedFields.Add(field.Name.ToLower, field);

    lAncestorEntity := lAncestorEntity.AncestorEntity as RodlStructEntity;
  end;

  for field: RodlField in entity.Items do
    if not lSortedFields.ContainsKey(field.Name.ToLower) then begin
      lSortedFields.Add(field.Name.ToLower, field);
      lIfRecordStrictOrder_True.Statements.Add(GetReaderStatement(library, field));
    end;

  for lvalue: String in lSortedFields.Keys.ToList.Sort_OrdinalIgnoreCase(b->b) do
    lIfRecordStrictOrder_False.Statements.Add(GetReaderStatement(library, lSortedFields.Item[lvalue]));

end;

method CocoaRodlCodeGen.GetWriterStatement(&library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"; isMethod: Boolean; aInOnly: Boolean := false): CGStatement;
begin
  var lLower: String  := entity.DataType.ToLower();
  var l_methodName: String;
  var lisEnum := isEnum(&library,entity.DataType);
  var lisComplex := iif(not lisEnum,isComplex(&library,entity.DataType), false);
  var lisSimple := not (lisEnum or lisComplex);

  if lisEnum then l_methodName := "Enum"
  else if isArray(&library, entity.DataType) then  l_methodName := "MutableArray"
  else if isStruct(&library, entity.DataType) then l_methodName := "Complex"
  else if ReaderFunctions.ContainsKey(lLower) then l_methodName := ReaderFunctions[lLower]
  else l_methodName := "UnknownType";

  var l_ident : CGExpression := if isMethod then
                                   SafeIdentifier(entity.Name).AsNamedIdentifierExpression
                                else
                                   new CGPropertyAccessExpression(nil, SafeIdentifier(entity.Name));
  if entity is RodlParameter then
    l_ident := ApplyParamDirectionExpression(l_ident,RodlParameter(entity).ParamFlag, aInOnly);
  if lisComplex or lisSimple then begin
    exit new CGMethodCallExpression(variableName.AsNamedIdentifierExpression,
                                    "write" +  l_methodName,
                                    [l_ident.AsCallParameter,
                                     new CGCallParameter(CleanedWsdlName(entity.Name).AsLiteralExpression, "withName")].ToList);
  end
  else if lisEnum then begin
    //aMessage.write%FIELD_READER_WRITER%(Integer(%FIELD_NAME%)) withName("%FIELD_NAME_UNSAFE%") asEnum(%FIELD_TYPE_RAW%__EnumMetaData.instance);
    exit new CGMethodCallExpression(variableName.AsNamedIdentifierExpression,
                                    "write" +  l_methodName,
                                    [new CGTypeCastExpression(l_ident, NSUIntegerType, ThrowsException := true).AsCallParameter,
                                     new CGCallParameter(CleanedWsdlName(entity.Name).AsLiteralExpression, "withName"),
                                     new CGCallParameter(new CGMethodCallExpression((entity.DataType+"__EnumMetaData").AsTypeReferenceExpression, "instance"), "asEnum")].ToList);
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[entity.DataType]));
  end;
end;

method CocoaRodlCodeGen.GetReaderStatement(&library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGStatement;
begin
  exit new CGAssignmentStatement(
    new CGPropertyAccessExpression(nil, SafeIdentifier(entity.Name)),
    GetReaderExpression(&library,entity,variableName));
end;

method CocoaRodlCodeGen.GetReaderExpression(&library: RodlLibrary; entity: RodlTypedEntity; variableName: String := "aMessage"): CGExpression;
begin
  var lLower: String  := entity.DataType.ToLower();
  var l_methodName: String;
  var lisEnum := isEnum(&library,entity.DataType);
  var lisComplex := iif(not lisEnum,isComplex(&library,entity.DataType), false);
  var lisArray := isArray(&library, entity.DataType);
  var lisStruct := isStruct(&library, entity.DataType);
  var lisSimple := not (lisEnum or lisComplex);

  if lisEnum then l_methodName := "Enum"
  else if lisArray then  l_methodName := "MutableArray"
  else if lisStruct then l_methodName := "Complex"
  else if ReaderFunctions.ContainsKey(lLower) then l_methodName := ReaderFunctions[lLower]
  else l_methodName := "UnknownType";

  var lNameString := CleanedWsdlName(entity.Name).AsLiteralExpression.AsCallParameter;
  if isClassType(library, entity.DataType) then begin
    // %FIELD_NAME% := aMessage.read%FIELD_READER_WRITER%WithName("%FIELD_NAME_UNSAFE%") asClass(%FIELD_TYPE_NAME%.class) as %FIELD_TYPE_NAME%;
    var l_type := ResolveDataTypeToTypeRef(&library, entity.DataType);//.NotNullabeCopy;
    if lisComplex or lisArray then begin
      //var l_type1:= ResolveDataTypeToTypeRef(&library, entity.DataType).NotNullable;
      var l_arg1 := new CGCallParameter(new CGTypeOfExpression(l_type.AsExpression), "asClass");
      var l_methodCall := new CGMethodCallExpression(variableName.AsNamedIdentifierExpression,
                                     "read" +  l_methodName+"WithName",
                                     [lNameString, l_arg1].ToList);
      exit new CGTypeCastExpression(l_methodCall, l_type, ThrowsException := true)
    end
    else begin
      var l_methodCall := new CGMethodCallExpression(variableName.AsNamedIdentifierExpression,
                                     "read" +  l_methodName+"WithName",
                                     [lNameString].ToList);
      exit l_methodCall;
    end;
  end
  else if lisEnum then begin
    // %FIELD_NAME% := %FIELD_TYPE_RAW%(aMessage.read%FIELD_READER_WRITER%WithName("%FIELD_NAME_UNSAFE%") asEnum(%FIELD_TYPE_RAW%__EnumMetaData.instance));
    var l_type := ResolveDataTypeToTypeRef(&library, entity.DataType);
    var l_arg1 := new CGCallParameter(new CGMethodCallExpression((SafeIdentifier(entity.DataType)+"__EnumMetaData").AsTypeReferenceExpression,"instance"), "asEnum");
    exit new CGTypeCastExpression(
        new CGMethodCallExpression(variableName.AsNamedIdentifierExpression,
                                   "read" +  l_methodName+"WithName",
                                   [lNameString, l_arg1].ToList),
        l_type,
        ThrowsException := true);
  end
  else if lisSimple then begin
    exit new CGMethodCallExpression(variableName.AsNamedIdentifierExpression,
                                   "read" +  l_methodName+"WithName",
                                   [lNameString].ToList);
  end
  else begin
    raise new Exception(String.Format("unknown type: {0}",[entity.DataType]));
  end;
end;

method CocoaRodlCodeGen.isClassType(&library: RodlLibrary; dataType: String): Boolean;
begin
  exit not (fCachedNumberFN.ContainsKey(dataType.ToLower) or isEnum(&library,dataType));
end;

method CocoaRodlCodeGen.GetNumberFN(dataType: String): String;
begin
  var ln := dataType.ToLower;
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

method CocoaRodlCodeGen.GenerateServiceProxyMethod(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
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
  if assigned(entity.Result) then begin
    result.Statements.Add(new CGVariableDeclarationStatement("__result",result.ReturnType));
  end;

  result.Statements.Add(new CGVariableDeclarationStatement("__localMessage",
                                                           "ROMessage".AsTypeReference,
                                                           new CGTypeCastExpression(new CGMethodCallExpression(new CGPropertyAccessExpression(new CGSelfExpression(), "__message") , "copy"), "ROMessage".AsTypeReference(), ThrowsException := true),
                                                           &ReadOnly := true));

  GenerateOperationAttribute(&library,entity,result.Statements);
  result.Statements.Add(
    new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression,
                               "initializeAsRequestMessage",
                              [new CGPropertyAccessExpression(new CGSelfExpression, "__clientChannel").AsCallParameter,
                              new CGCallParameter(library.Name.AsLiteralExpression, "libraryName"),
                              new CGCallParameter(new CGMethodCallExpression(new CGSelfExpression(), "__getActiveInterfaceName"), "interfaceName"),
                              new CGCallParameter(SafeIdentifier(entity.Name).AsLiteralExpression, "messageName")].ToList
    ));

  // Apple Swift can't do and doesn't need the try/finally
  var ltry := new List<CGStatement>;
  var lfinally := if SwiftDialect = CGSwiftCodeGeneratorDialect.Silver then new List<CGStatement> else ltry;

  for lp: RodlParameter in l_in do
    ltry.Add(GetWriterStatement(&library,lp,"__localMessage", true));
  ltry.Add(new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression, "finalizeMessage"));
  ltry.Add(new CGMethodCallExpression(new CGPropertyAccessExpression(new CGSelfExpression, "__clientChannel"),
                                                 "dispatch",
                                                 ["__localMessage".AsNamedIdentifierExpression.AsCallParameter].ToList));
  if assigned(entity.Result) then
    ltry.Add(new CGAssignmentStatement("__result".AsNamedIdentifierExpression,
                                                  GetReaderExpression(&library,entity.Result,"__localMessage")));

  for lp: RodlParameter in l_out do
    ltry.Add(new CGAssignmentStatement(
                            ApplyParamDirectionExpression(lp.Name.AsNamedIdentifierExpression,lp.ParamFlag),
                            GetReaderExpression(&library,lp,"__localMessage")
                            ));

  var self_message := new CGPropertyAccessExpression(new CGSelfExpression, "__message");
  lfinally.Add(new CGMethodCallExpression(nil, "objc_sync_enter", [self_message.AsCallParameter].ToList));
  lfinally.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(self_message, "clientID"),
                                         new CGPropertyAccessExpression("__localMessage".AsNamedIdentifierExpression, "clientID")));
  lfinally.Add(new CGMethodCallExpression(nil,"objc_sync_exit",   [self_message.AsCallParameter].ToList));

  if SwiftDialect = CGSwiftCodeGeneratorDialect.Silver then begin
    result.Statements.Add(new CGTryFinallyCatchStatement(ltry, FinallyStatements:= lfinally as not nullable));
  end else begin
    result.Statements.AddRange(ltry);
  end;

  if assigned(entity.Result) then
    Result.Statements.Add("__result".AsNamedIdentifierExpression.AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceProxyMethodDeclaration(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition(SafeIdentifier(entity.Name),
                                  Visibility := CGMemberVisibilityKind.Public);
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut, ParamFlags.Out] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(&library, lp.DataType), Modifier := ApplyParamDirection(lp.ParamFlag)));
  end;
  if assigned(entity.Result) then
    Result.ReturnType := ResolveDataTypeToTypeRef(&library, entity.Result.DataType);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(&library ,entity);
  GenerateServiceAsyncProxyBeginMethod_Body(&library,entity,result.Statements);
  // exit self.__clientChannel.asyncDispatch(__localMessage) withProxy(self) start(true);
  result.Statements.Add(new CGMethodCallExpression( new CGPropertyAccessExpression(new CGSelfExpression,"__clientChannel"),
                                                    "asyncDispatch",
                                                    ["__localMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                     new CGCallParameter(new CGSelfExpression(), "withProxy"),
                                                     new CGCallParameter(new CGBooleanLiteralExpression(True), "start")].ToList
                          ).AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyEndMethod(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition("end" + PascalCase(entity.Name), Visibility := CGMemberVisibilityKind.Public);
  result.Parameters.Add(new CGParameterDefinition("__asyncRequest", "ROAsyncRequest".AsTypeReference));
  var l_out := new List<RodlParameter>;
  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.Out,ParamFlags.InOut] then begin
      l_out.Add(lp);
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(&library, lp.DataType), Modifier := CGParameterModifierKind.Out)); // end* metbods are always "out"
    end;
  end;

  if assigned(entity.Result) then begin
    Result.ReturnType := ResolveDataTypeToTypeRef(&library, entity.Result.DataType);
  end;

  if assigned(entity.Result) then
    result.Statements.Add(new CGVariableDeclarationStatement("__result", result.ReturnType) );
  result.Statements.Add(new CGVariableDeclarationStatement("__localMessage", "ROMessage".AsTypeReference, new CGPropertyAccessExpression("__asyncRequest".AsNamedIdentifierExpression, "responseMessage"), &ReadOnly := true));
  GenerateOperationAttribute(&library,entity,Result.Statements);
  if assigned(entity.Result) then
    result.Statements.Add(new CGAssignmentStatement("__result".AsNamedIdentifierExpression, GetReaderExpression(&library,entity.Result,"__localMessage")));

  for lp: RodlParameter in l_out do
    Result.Statements.Add(new CGAssignmentStatement(
                                    ApplyParamDirectionExpression(lp.Name.AsNamedIdentifierExpression,lp.ParamFlag),
                                    GetReaderExpression(&library,lp,"__localMessage")
                                    ));

  var self_message := new CGPropertyAccessExpression(new CGSelfExpression, "__message");
  Result.Statements.Add(new CGMethodCallExpression(nil, "objc_sync_enter", [self_message.AsCallParameter].ToList));
  Result.Statements.Add(new CGAssignmentStatement(new CGPropertyAccessExpression(self_message,"clientID"), new CGPropertyAccessExpression("__localMessage".AsNamedIdentifierExpression, "clientID")));
  Result.Statements.Add(new CGMethodCallExpression(nil,"objc_sync_exit", [self_message.AsCallParameter].ToList));

  if assigned(entity.Result) then
    Result.Statements.Add("__result".AsNamedIdentifierExpression.AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethodDeclaration(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  Result:= new CGMethodDefinition("begin" + PascalCase(entity.Name),
                                  Visibility := CGMemberVisibilityKind.Public,
                                  ReturnType := "ROAsyncRequest".AsTypeReference);

  for lp: RodlParameter in entity.Items do begin
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      Result.Parameters.Add(new CGParameterDefinition(lp.Name, ResolveDataTypeToTypeRef(&library, lp.DataType), Modifier := ApplyParamDirection(lp.ParamFlag, true)));
  end;
end;

method CocoaRodlCodeGen.GenerateOperationAttribute(&library: RodlLibrary; entity: RodlOperation; Statements: List<CGStatement>);
begin
  var ld := Operation_GetAttributes(&library, entity);
  if ld.Count > 0  then begin
    var list:= new List<CGCallParameter>;
    list.Add(new CGBooleanLiteralExpression(False).AsCallParameter);
    for l_key: String in ld.Keys do begin
      list.Add(EscapeString(l_key.ToLower).AsLiteralExpression.AsCallParameter);
      list.Add(EscapeString(ld[l_key]).AsLiteralExpression.AsCallParameter);
    end;
    list.Add(new CGNilExpression().AsCallParameter);
    Statements.Add(new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression,
                                              "setupAttributes",
                                              [new CGMethodCallExpression(nil,"DictionaryFromNameValueList",list).AsCallParameter].ToList));
  end;
end;

method CocoaRodlCodeGen.GenerateServiceMethods(&library: RodlLibrary; entity: RodlService; service: CGClassTypeDefinition);
begin
  {$REGION method __getInterfaceName: NSString; override;}
  service.Members.Add(
    new CGMethodDefinition("__getInterfaceName",
      [SafeIdentifier(entity.Name).AsLiteralExpression.AsReturnStatement],
      ReturnType := CGPredefinedTypeReference.String.NotNullable,
      Virtuality := CGMemberVirtualityKind.Override,
      Visibility := CGMemberVisibilityKind.Public
      )
  );
  {$ENDREGION}
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod_start(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(&library, entity);
  if result.Parameters.Count = 0 then
    result.Name := result.Name+ "__start";
  result.Parameters.Add(new CGParameterDefinition("___start", ResolveStdtypes(CGPredefinedTypeKind.Boolean), Externalname := if result.Parameters.Count > 0 then "start"));
  GenerateServiceAsyncProxyBeginMethod_Body(&library,entity,result.Statements);
  result.Statements.Add(new CGMethodCallExpression( new CGPropertyAccessExpression(new CGSelfExpression(),"__clientChannel"),
                                                   "asyncDispatch",
                                                  ["__localMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                   new CGCallParameter(new CGSelfExpression(), "withProxy"),
                                                   new CGCallParameter("___start".AsNamedIdentifierExpression, "start")].ToList
                                                  ).AsReturnStatement);
end;

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod_startWithBlock(&library: RodlLibrary; entity: RodlOperation): CGMethodDefinition;
begin
  result := GenerateServiceAsyncProxyBeginMethodDeclaration(&library, entity);
  if result.Parameters.Count = 0 then
    result.Name := result.Name+ "__startWithBlock";
  var bl := new CGInlineBlockTypeReference (new CGBlockTypeDefinition('',Parameters := [new CGParameterDefinition("arg", "ROAsyncRequest".AsTypeReference)].ToList));
  result.Parameters.Add(new CGParameterDefinition("___block", bl, Externalname := if result.Parameters.Count > 0 then "startWithBlock"));
  GenerateServiceAsyncProxyBeginMethod_Body(&library,entity,result.Statements);
  result.Statements.Add(new CGMethodCallExpression( new CGPropertyAccessExpression(new CGSelfExpression(),"__clientChannel"),
                                                   "asyncDispatch",
                                                  ["__localMessage".AsNamedIdentifierExpression.AsCallParameter,
                                                   new CGCallParameter(new CGSelfExpression(), "withProxy"),
                                                   new CGCallParameter("___block".AsNamedIdentifierExpression, "startWithBlock")].ToList
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

method CocoaRodlCodeGen.GenerateServiceAsyncProxyBeginMethod_Body(&library: RodlLibrary; entity: RodlOperation; Statements: List<CGStatement>);
begin
  Statements.Add(new CGVariableDeclarationStatement("__localMessage",
                                                    "ROMessage".AsTypeReference,
                                                    new CGTypeCastExpression(new CGMethodCallExpression(new CGPropertyAccessExpression(new CGSelfExpression(), "__message") , "copy"), "ROMessage".AsTypeReference(), ThrowsException := true),
                                                    &ReadOnly := true));
  GenerateOperationAttribute(&library,entity,Statements);
  Statements.Add(
    new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression,
                               "initializeAsRequestMessage",
                               [new CGCallParameter(new CGPropertyAccessExpression(new CGSelfExpression,"__clientChannel")),
                                new CGCallParameter(library.Name.AsLiteralExpression, "libraryName"),
                                new CGCallParameter(new CGMethodCallExpression(new CGSelfExpression(), "__getActiveInterfaceName"), "interfaceName"),
                                new CGCallParameter(SafeIdentifier(entity.Name).AsLiteralExpression, "messageName")].ToList));
  for lp: RodlParameter in entity.Items do
    if lp.ParamFlag in [ParamFlags.In,ParamFlags.InOut] then
      Statements.Add(GetWriterStatement(&library,lp,"__localMessage", true, true));
  Statements.Add(new CGMethodCallExpression("__localMessage".AsNamedIdentifierExpression, "finalizeMessage"));
end;

method CocoaRodlCodeGen.GetNamespace(library: RodlLibrary): String;
begin
  if assigned(library.Includes) then result := library.Includes.ToffeeModule;
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

  for lentity : RodlService in &library.Services.Items.OrderBy(b->b.Name) do begin
    if not EntityNeedsCodeGen(lentity) then Continue;
    var lname := lentity.Name;
    if lentity.Count > 0 then
      file.Globals.Add(new CGFieldDefinition(String.Format("I{0}_IID",[lname]), CGPredefinedTypeReference.String.NotNullable,
                                  Constant := true,
                                  Visibility := CGMemberVisibilityKind.Public,
                                  Initializer := ('{'+lentity.DefaultInterface.EntityID.ToString.ToUpper+'}').AsLiteralExpression).AsGlobal);
  end;


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