namespace RemObjects.SDK.CodeGen4;

type
  RodlEnum = public class(RodlComplexEntity<RodlEnumValue>)
  public
    constructor;
    begin
      inherited constructor("EnumValue");
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, -> new RodlEnumValue);
      PrefixEnumValues := node.Attribute["Prefix"]:Value <> '0';
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlEnumValue);
      PrefixEnumValues := valueOrDefault(node["Prefix"]:BooleanValue);
    end;

    property PrefixEnumValues: Boolean;
    property DefaultValueName: String read if Count > 0 then Item[0].Name;
  end;

  RodlEnumValue = public class(RodlEntity)
  end;

  //
  //
  //

  RodlArray = public class(RodlEntity)
  public

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      ElementType := FixLegacyTypes(node.FirstElementWithName("ElementType"):Value);
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      ElementType := FixLegacyTypes(node["DataType"]:StringValue);
    end;

    property ElementType: String;
  end;

  //
  //
  //

  RodlStructEntity = public abstract class (RodlComplexEntity<RodlField>)
  public
    constructor;
    begin
      inherited constructor("Element");
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node,-> new RodlField);
      if (node.Attribute["AutoCreateParams"] <> nil) then
        AutoCreateProperties := (node.Attribute["AutoCreateParams"].Value = "1");
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlField);
      AutoCreateProperties := valueOrDefault(node["AutoCreateParams"]:BooleanValue);
    end;

    property AutoCreateProperties: Boolean := False;
  end;

  RodlStruct = public class(RodlStructEntity)
  end;

  RodlException = public class(RodlStructEntity)
  end;

  RodlField = public class(RodlTypedEntity)
  end;

end.