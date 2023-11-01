namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  RodlEntity = public partial abstract class
  protected
    const def_DontCodegen: Boolean = false;
    const def_Abstract: Boolean = false;

    method SaveAttributesToJson(node: JsonObject);
    begin
      SaveStringToJson(node, "Documentation", Documentation);

      if CustomAttributes.Count > 0  then begin
        var l_custom := new JsonObject();

        for each key: String in CustomAttributes.Keys do
          l_custom[key] := CustomAttributes[key];

        if l_custom.Count > 0 then
          node["CustomAttributes"] := l_custom;
      end;

      if assigned(GroupUnder) then
        SaveGuidToJson(node, "Group", GroupUnder.EntityID);
    end;

    method SaveStringToJson(node: JsonObject; attributeName: String; value: String);
    begin
      if not String.IsNullOrEmpty(value) then
        node[attributeName] := value;
    end;

    method SaveBooleanToJson(node: JsonObject; attributeName: String; value: Boolean);
    begin
      node[attributeName] := value;
    end;

    method SaveObjectToJson(node: JsonObject; attributeName: String; value: JsonObject);
    begin
      if node.Count > 0 then
        node[attributeName] := value;
    end;

    method SaveGuidToJson(node: JsonObject; attributeName: String; value: Guid);
    begin
      if not assigned(value) or (value = Guid.Empty) then begin
        exit;
        //  No need to save anything
      end;
      node[attributeName] := value.ToString(GuidFormat.Braces).ToUpper;
    end;

  public
    constructor(node: JsonNode);
    begin
      LoadFromJsonNode(node);
    end;

    method LoadFromJsonNode(node: JsonNode); virtual;
    begin
      Name := node["Name"]:StringValue;
      EntityID := Guid.TryParse(node["ID"]:StringValue);
      FromUsedRodlId := Guid.TryParse(node["FromUsedRodlID"]:StringValue);
      &Abstract := node["Abstract"]:BooleanValue;
      DontCodegen :=  node["DontCodeGen"]:BooleanValue;
      Documentation := node["Documentation"]:StringValue;

      var lCustomAttributes := node["CustomAttributes"];
      if assigned(lCustomAttributes) then begin
        for each k in lCustomAttributes.Keys do begin
          var lValue := lCustomAttributes[k]:StringValue;
          if length(lValue) > 0 then begin
            CustomAttributes[k] := lValue;
            CustomAttributes_lower[k.ToLowerInvariant] := lValue;
            if k.ToLowerInvariant = "soapname" then fOriginalName := lValue;
          end;
        end;
      end;
    end;

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); virtual; empty;


  end;

  RodlTypedEntity = public partial abstract class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      DataType := FixLegacyTypes(node["DataType"]:StringValue);
    end;

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveStringToJson(node, "DataType", DataType);
      if IsFromUsedRodl then
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);
      SaveAttributesToJson(node);
    end;

  end;

  RodlEntityWithAncestor = public partial abstract class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      AncestorName := node["Ancestor"]:StringValue;
    end;
  end;

  RodlComplexEntity<T> = public partial abstract class
  private
    fItemsNodeNameJson: nullable String;
    property ItemsNodeNameJson: String read coalesce(fItemsNodeNameJson, ItemsNodeNameXml);
  public
    method LoadFromJsonNode(node: JsonNode; aActivator: block : T);
    begin
      inherited LoadFromJsonNode(node);
      fItems.LoadFromJsonNode(node[ItemsNodeNameJson], nil, aActivator);
    end;

    method SaveToJson(node: JsonObject; name: String; flattenUsedRODLs: Boolean);
    begin
      fItems.SaveToJson(node, name, flattenUsedRODLs);
    end;
  end;

  EntityCollection<T> = public partial class
  public
    method LoadFromJsonNode(node: JsonNode; usedRodl: RodlUse; aActivator: block : T);
    begin
      if (node = nil) then exit;

      for lNode in (node as JsonArray) do begin
        //var lr := (lNode.NodeType = XmlNodeType.Element) and (XmlElement(lNode).LocalName = fEntityNodeName);
        //if lr then begin
          var lEntity := aActivator();
          lEntity.FromUsedRodl := usedRodl;
          lEntity.Owner := Owner;
          lEntity.LoadFromJsonNode(lNode);
          if assigned(lEntity.FromUsedRodl) then
            lEntity.FromUsedRodlId := usedRodl.UsedRodlId;
          if assigned(lEntity.FromUsedRodlId) then
            lEntity.FromUsedRodl := Owner.OwnerLibrary.Uses.Items.Where(b->b.UsedRodlId = lEntity.FromUsedRodlId).FirstOrDefault;
          var lIsNew := true;
          for entity: T in fItems do begin
            if (entity is RodlParameter) and (lEntity is RodlParameter) and
              (RodlParameter(entity).ParamFlag ≠ RodlParameter(lEntity).ParamFlag) then Continue;
              if entity.Name.EqualsIgnoringCaseInvariant(lEntity.Name) then begin
                lIsNew := false;
                break;
              end
              else begin
                lEntity.EntityID := Guid.NewGuid;
              end;
          end;
          if lIsNew then
            AddEntity(lEntity);
        //end;
      end;
    end;

    method SaveToJson(node: JsonObject; name: String; flattenUsedRODLs: Boolean);
    begin
      var l_array := new JsonArray();
      for each l_entity: RodlEntity in fItems do begin
        if flattenUsedRODLs or not l_entity.IsFromUsedRodl then begin
          var l_item := new JsonObject();
          l_entity.SaveToJson(l_item, flattenUsedRODLs);
          l_array.Add(l_item);
        end;
      end;

      if l_array.Count > 0 then
        node[name] := l_array;
    end;

  end;

end.