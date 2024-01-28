namespace RemObjects.SDK.CodeGen4;

type
  RodlEntity = public partial abstract class
  public
    constructor(node: XmlElement);
    begin
      LoadFromXmlNode(node);
    end;

    method LoadFromXmlNode(node: XmlElement); virtual;
    begin
      Name := node.Attribute["Name"]:Value;
      EntityID := Guid.TryParse(node.Attribute["UID"]:Value);
      FromUsedRodlId := Guid.TryParse(node.Attribute["FromUsedRodlUID"]:Value);
      &Abstract := node.Attribute["Abstract"]:Value = "1";
      DontCodegen :=  node.Attribute["DontCodeGen"]:Value = "1";

      var lDoc := node.FirstElementWithName("Documentation");
      if (lDoc ≠ nil) and (lDoc.Nodes.Count>0) and (lDoc.Nodes[0] is XmlCData) then begin
        // FirstChild because data should be enclosed within CDATA
        Documentation := (lDoc.Nodes[0] as XmlCData).Value;
      end;

      var lCustomAttributes := node.FirstElementWithName("CustomAttributes");
      if assigned(lCustomAttributes) then begin
        for each childNode: XmlElement in lCustomAttributes.Elements do begin
          var lValue: XmlAttribute := childNode.Attribute["Value"];
          if assigned(lValue) then begin
            CustomAttributes[childNode.LocalName] := lValue.Value;
            CustomAttributes_lower[childNode.LocalName.ToLowerInvariant] := lValue.Value;
            if childNode.LocalName.ToLowerInvariant = "soapname" then fOriginalName := lValue.Value;
          end;
        end;
      end;
    end;

  end;

  RodlTypedEntity = public partial abstract class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      DataType := FixLegacyTypes(node.Attribute["DataType"].Value);
    end;
  end;

  RodlEntityWithAncestor = public partial abstract class (RodlEntity)
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      if (node.Attribute["Ancestor"] ≠ nil) then AncestorName := node.Attribute["Ancestor"].Value;
    end;
  end;

  RodlComplexEntity<T> = public partial abstract class
  private
    fItemsNodeNameXml: nullable String;
    property ItemsNodeNameXml: String read fItemsNodeNameXml;
  public
    method LoadFromXmlNode(node: XmlElement; aActivator: block : T);
    begin
      inherited LoadFromXmlNode(node);
      fItems.LoadFromXmlNode(node.FirstElementWithName(ItemsNodeNameXml), nil, aActivator);
    end;
  end;

  EntityCollection<T> = public partial class
  public
    method LoadFromXmlNode(node: XmlElement; usedRodl: RodlUse; aActivator: block : T);
    begin
      if (node = nil) then exit;

      for lNode: XmlNode in node.Elements do begin
        var lr := (lNode.NodeType = XmlNodeType.Element) and (XmlElement(lNode).LocalName = fEntityNodeName);
        if lr then begin
          var lEntity := aActivator();
          lEntity.FromUsedRodl := usedRodl;
          lEntity.Owner := Owner;
          lEntity.LoadFromXmlNode(XmlElement(lNode));
          if assigned(lEntity.FromUsedRodl) then
            lEntity.FromUsedRodlId := usedRodl.UsedRodlId;
          if assigned(lEntity.FromUsedRodlId) and not assigned(lEntity.FromUsedRodl) then
            lEntity.FromUsedRodl := Owner.OwnerLibrary.Uses.Items.Where(b->b.UsedRodlId = lEntity.FromUsedRodlId).FirstOrDefault;
          var lIsNew := true;
          for entity: T in fItems do begin
            if (entity is RodlParameter) and (lEntity is RodlParameter) and
              (RodlParameter(entity).ParamFlag ≠ RodlParameter(lEntity).ParamFlag) then Continue;
            if entity.EntityID:&Equals(lEntity.EntityID) then begin
              if entity.Name.EqualsIgnoringCaseInvariant(lEntity.Name) then begin
                lIsNew := false;
                break;
              end
              else begin
                lEntity.EntityID := Guid.NewGuid;
              end;
            end;
          end;
          if lIsNew then
            AddEntity(lEntity);
        end;
      end;
    end;
  end;

end.