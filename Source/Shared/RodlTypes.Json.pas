namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  RodlEnum = public partial class
  private
    const def_PrefixEnumValues: Boolean = true;
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlEnumValue);
      PrefixEnumValues := not assigned(node["Prefix"]) or node["Prefix"].BooleanValue = true;
    end;

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      if PrefixEnumValues ≠ def_PrefixEnumValues then
        SaveBooleanToJson(node, "Prefix", PrefixEnumValues);

      if IsFromUsedRodl then
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);

      if DontCodegen ≠ def_DontCodegen then
        SaveBooleanToJson(node, "DontCodeGen", DontCodegen);

      SaveAttributesToJson(node);
      inherited SaveToJson(node, "Values", flattenUsedRODLs);
    end;


  end;

  RodlEnumValue = public partial class
  public
    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveAttributesToJson(node);
    end;
  end;

  RodlArray = public partial class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      ElementType := FixLegacyTypes(node["DataType"]:StringValue);
    end;

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);

      if IsFromUsedRodl then
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);

      if DontCodegen ≠ def_DontCodegen then
        SaveBooleanToJson(node, "DontCodeGen", DontCodegen);

      SaveAttributesToJson(node);
      SaveStringToJson(node, "DataType", ElementType);
    end;

  end;

  RodlStructEntity = public partial abstract class
  private
    const def_AutoCreateParams: Boolean = true;
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlField);
      AutoCreateProperties := not assigned(node["AutoCreateProperties"]) or (node["AutoCreateProperties"].BooleanValue = true);
    end;

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveStringToJson(node, "Ancestor", AncestorName);
      if AutoCreateProperties ≠ def_AutoCreateParams then begin
        SaveBooleanToJson(node, "AutoCreateProperties", AutoCreateProperties);
      end;
      if &Abstract ≠ def_Abstract then begin
        SaveBooleanToJson(node, "Abstract", Abstract);
      end;
      if DontCodegen ≠ def_DontCodegen then begin
        SaveBooleanToJson(node, "DontCodeGen", DontCodegen);
      end;
      if IsFromUsedRodl then begin
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);
      end;
      SaveAttributesToJson(node);
      inherited SaveToJson(node, "Elements", flattenUsedRODLs);
    end;

  end;

end.