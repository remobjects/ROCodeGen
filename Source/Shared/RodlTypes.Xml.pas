namespace RemObjects.SDK.CodeGen4;

type
  RodlEnum = public partial class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, -> new RodlEnumValue);
      PrefixEnumValues :=  not assigned(node.Attribute["Prefix"]) or (node.Attribute["Prefix"]:Value ≠ '0');
    end;
  end;

  RodlArray = public partial class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      ElementType := FixLegacyTypes(node.FirstElementWithName("ElementType"):Attribute["DataType"]:Value);
    end;
  end;

  RodlStructEntity = public partial abstract class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node,-> new RodlField);
      if (node.Attribute["AutoCreateParams"] ≠ nil) then
        AutoCreateProperties := not assigned(node.Attribute["AutoCreateParams"]) or (node.Attribute["AutoCreateParams"].Value ≠ "0");
    end;
  end;

end.