namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  RodlEnum = public class(RodlComplexEntity<RodlEnumValue>)
  public
    constructor;
    begin
      inherited constructor("EnumValue", "Values");
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, -> new RodlEnumValue);
      PrefixEnumValues :=  not assigned(node.Attribute["Prefix"]) or (node.Attribute["Prefix"]:Value ≠ '0');
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlEnumValue);
      PrefixEnumValues := not assigned(node["Prefix"]) or node["Prefix"].BooleanValue = true;
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
      ElementType := FixLegacyTypes(node.FirstElementWithName("ElementType"):Attribute["DataType"]:Value);
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
      if (node.Attribute["AutoCreateParams"] ≠ nil) then
        AutoCreateProperties := not assigned(node.Attribute["AutoCreateParams"]) or (node.Attribute["AutoCreateParams"].Value ≠ "0");
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlField);
      AutoCreateProperties := not assigned(node["AutoCreateProperties"]) or (node["AutoCreateProperties"].BooleanValue = true);
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