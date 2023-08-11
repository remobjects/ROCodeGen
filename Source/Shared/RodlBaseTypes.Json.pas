namespace RemObjects.SDK.CodeGen4;

type
  RodlEntity = public partial abstract class
  public
    constructor(node: JsonNode);
    begin
      LoadFromJsonNode(node);
    end;

    method LoadFromJsonNode(node: JsonNode); virtual;
    begin
      Name := node["Name"]:StringValue;
      EntityID := Guid.TryParse(node["ID"]:StringValue);
      FromUsedRodlId := Guid.TryParse(node["FromUsedRodlUID"]:StringValue);
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
  end;

  RodlTypedEntity = public partial abstract class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      DataType := FixLegacyTypes(node["DataType"]:StringValue);
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

          var lIsNew := true;
          for entity:T in fItems do begin
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
  end;

end.