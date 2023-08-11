namespace RemObjects.SDK.CodeGen4;

type
  RodlEnum = public partial class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlEnumValue);
      PrefixEnumValues := not assigned(node["Prefix"]) or node["Prefix"].BooleanValue = true;
    end;
  end;

  RodlArray = public partial class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      ElementType := FixLegacyTypes(node["DataType"]:StringValue);
    end;
  end;

  RodlStructEntity = public partial abstract class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlField);
      AutoCreateProperties := not assigned(node["AutoCreateProperties"]) or (node["AutoCreateProperties"].BooleanValue = true);
    end;
  end;

end.