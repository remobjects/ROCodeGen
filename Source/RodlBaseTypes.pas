namespace RemObjects.SDK.CodeGen4;

type
  ParamFlags = public enum (&In, &Out, &InOut, &Result);

  RodlEntity = public abstract class
  private
    fOriginalName: String;
    method getOriginalName: String;
    begin
      exit iif(String.IsNullOrEmpty(fOriginalName), Name, fOriginalName);
    end;

    fCustomAttributes: Dictionary<String,String> := new Dictionary<String,String>;
    fCustomAttributes_lower: Dictionary<String,String> := new Dictionary<String,String>;
    method getOwnerLibrary: RodlLibrary;
    begin
      var lOwner: RodlEntity := self;
      while ((lOwner <> nil) and (not(lOwner is RodlLibrary))) do
         lOwner := lOwner.Owner;
      exit (lOwner as RodlLibrary);
    end;

  protected
    method FixLegacyTypes(aName: String):String;
    begin
      exit iif(aName.ToLowerInvariant() = "string", "AnsiString", aName);
    end;

  public
    constructor(); virtual; empty;

    constructor(node: XmlElement);
    begin
      LoadFromXmlNode(node);
    end;

    constructor(node: JsonNode);
    begin
      LoadFromJsonNode(node);
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

    method LoadFromJsonNode(node: JsonNode); virtual;
    begin
      Name := node["Name"]:StringValue;
      EntityID := Guid.TryParse(node["UID"]:StringValue);
      FromUsedRodlId := Guid.TryParse(node["FromUsedRodlUID"]:StringValue);
      &Abstract := node["Abstract"]:BooleanValue;
      DontCodegen :=  node["DontCodeGen"]:BooleanValue;
      Documentation := node["Documentation"]:StringValue;

      var lCustomAttributes := node["CustomAttributes"];
      if assigned(lCustomAttributes) then begin
        for each k in lCustomAttributes.Keys do begin
          var lValue := lCustomAttributes["Value"]:StringValue;
          if length(lValue) > 0 then begin
            CustomAttributes[k] := lValue;
            CustomAttributes_lower[k.ToLowerInvariant] := lValue;
            if k.ToLowerInvariant = "soapname" then fOriginalName := lValue;
          end;
        end;
      end;
    end;

    method HasCustomAttributes: Boolean;
    begin
      Result := assigned(CustomAttributes) and (CustomAttributes:Count >0)
    end;

    property IsFromUsedRodl: Boolean read assigned(FromUsedRodl);
    {$region Properties}
    property EntityID: nullable Guid;
    property Name: String;
    property OriginalName: String read getOriginalName write fOriginalName;
    property Documentation: String;
    property &Abstract: Boolean;
    property CustomAttributes: Dictionary<String,String> read fCustomAttributes;
    property CustomAttributes_lower: Dictionary<String,String> read fCustomAttributes_lower;
    //property PluginData :XmlDocument;  //????
    //property HasPluginData: Boolean read getPluginData;
    property GroupUnder: RodlGroup;
    property FromUsedRodl: RodlUse;
    property FromUsedRodlId: nullable Guid;
    property Owner: RodlEntity;
    property OwnerLibrary: RodlLibrary read getOwnerLibrary;
    property DontCodegen: Boolean;
    {$endregion}
    {$IFDEF ECHOES}
    method ToString: String; override;
    begin
      exit Name;
    end;
    {$ENDIF}
  end;

  RodlTypedEntity = public abstract class (RodlEntity)
  public

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      DataType := FixLegacyTypes(node.Attribute["DataType"].Value);
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      DataType := FixLegacyTypes(node["DataType"]:StringValue);
    end;

    property DataType: String;
  end;

  RodlEntityWithAncestor = public abstract class (RodlEntity)
  private
    method setAncestorEntity(value: RodlEntity);
    begin
      value := getAncestorEntity;
    end;

    method getAncestorEntity: RodlEntity;
    begin
      if (String.IsNullOrEmpty(AncestorName)) then exit nil;

      var lRodlLibrary: RodlLibrary := OwnerLibrary;

      exit iif(lRodlLibrary = nil, nil , lRodlLibrary.FindEntity(AncestorName));
    end;

  public

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      if (node.Attribute["Ancestor"] <> nil) then AncestorName := node.Attribute["Ancestor"].Value;
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      AncestorName := node["Ancestor"]:StringValue;
    end;

    property AncestorName: String;
    property AncestorEntity: RodlEntity read getAncestorEntity write setAncestorEntity;
  end;

  RodlComplexEntity<T> = public abstract class (RodlEntityWithAncestor)
    where T is RodlEntity;
  private
    fItemsNodeName: String;
    fItems: EntityCollection<T>;
  public
    constructor();abstract;
    constructor(nodeName:String);
    begin
      inherited constructor;
      fItemsNodeName := nodeName + "s";
      fItems := new EntityCollection<T>(self, nodeName);
    end;

    method LoadFromXmlNode(node: XmlElement; aActivator: block : T);
    begin
      inherited LoadFromXmlNode(node);
      fItems.LoadFromXmlNode(node.FirstElementWithName(fItemsNodeName), nil, aActivator);
    end;

    method LoadFromJsonNode(node: JsonNode; aActivator: block : T);
    begin
      inherited LoadFromJsonNode(node);
      fItems.LoadFromJsonNode(node, nil, aActivator);
    end;

    method GetInheritedItems: List<T>;
    begin
      var lancestor := AncestorEntity;
      if assigned(lancestor) and (lancestor is RodlComplexEntity<T>) then begin
        result := RodlComplexEntity<T>(lancestor).GetInheritedItems;
        result.Add(RodlComplexEntity<T>(lancestor).fItems.Items);
      end
      else begin
        result := new List<T>;
      end;
    end;

    method GetAllItems: List<T>;
    begin
      result := GetInheritedItems;
      result.Add(Self.fItems.Items);
    end;

    property Items: List<T> read fItems.Items;
    property Count: Int32 read fItems.Count;
    property Item[index: Integer]: T read fItems[index]; default;
  end;

  EntityCollection<T> = public class
    where T is RodlEntity;
  private
    fEntityNodeName: String;
    fItems: List<T> := new List<T>;
  public
    constructor(aOwner: RodlEntity; nodeName: String);
    begin
      fEntityNodeName := nodeName;
      Owner := aOwner;
    end;

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

          var lIsNew := true;
          for entity:T in fItems do begin
            if (entity is RodlParameter) and (lEntity is RodlParameter) and
              (RodlParameter(entity).ParamFlag <> RodlParameter(lEntity).ParamFlag) then Continue;
            if entity.EntityID.Equals(lEntity.EntityID) then begin
              if entity.Name.EqualsIgnoringCaseInvariant(lEntity.Name) then begin
                lIsNew := false;
                break;
              end
              else begin
                lEntity.EntityID := Guid.NewGuid;
              end;
            end;
          end;
          if lIsNew then AddEntity(lEntity);
        end;
      end;
    end;

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
              (RodlParameter(entity).ParamFlag <> RodlParameter(lEntity).ParamFlag) then Continue;
            if entity.EntityID.Equals(lEntity.EntityID) then begin
              if entity.Name.EqualsIgnoringCaseInvariant(lEntity.Name) then begin
                lIsNew := false;
                break;
              end
              else begin
                lEntity.EntityID := Guid.NewGuid;
              end;
            end;
          end;
          if lIsNew then AddEntity(lEntity);
        //end;
      end;
    end;

    method AddEntity(entity : T);
    begin
      fItems.Add(entity);
    end;

    method RemoveEntity(entity: T);
    begin
      fItems.Remove(entity);
    end;

    method RemoveEntity(index: Int32);
    begin
      fItems.RemoveAt(index);
    end;

    method FindEntity(name: String): T;
    begin
      for lRodlEntity: T in fItems do
        if not lRodlEntity.IsFromUsedRodl and lRodlEntity.Name.EqualsIgnoringCaseInvariant(name) then exit lRodlEntity;

      for lRodlEntity: T in fItems do
        if lRodlEntity.Name.EqualsIgnoringCaseInvariant(name) then exit lRodlEntity;
      exit nil;
    end;

    method SortedByAncestor: List<T>;
    begin
      var lResult := new List<T>;
      var lAncestors := new List<T>;

      {if typeOf(T).Equals(typeOf(RodlEntityWithAncestor) then begin
        lResult.Add(fItems);
        exit;
      end;}

      for each lt in fItems.OrderBy(b->b.Name) do begin
        var laname:= RodlEntityWithAncestor(lt):AncestorName;
        if not String.IsNullOrEmpty(laname) and (fItems.Where(b->b.Name.EqualsIgnoringCaseInvariant(laname)).Count>0) then
          lAncestors.Add(lt)
        else
          lResult.Add(lt);
      end;

      var lWorked := false;
      while lAncestors.Count > 0 do begin
        lWorked := false;
        for i: Integer := lAncestors.Count-1 downto 0 do begin
          var laname:= (lAncestors[i] as RodlEntityWithAncestor).AncestorName;
          var lst := lResult.Where(b->b.Name.Equals(laname)).ToList;
          if lst.Count = 1 then begin
            var lIndex := lResult.IndexOf(lst[0]);
            lResult.Insert(lIndex+1,lAncestors[i]);
            lAncestors.RemoveAt(i);
            lWorked := true;
          end;
          if (not lWorked) and (lAncestors.Count > 0) then
            new Exception("Invalid or recursive inheritance detected");
        end;
      end;
      exit lResult;
    end;

    property Owner : RodlEntity;
    property Count: Integer read fItems.Count;
    property Items: List<T> read fItems;
    property Item[Index: Integer]: T read fItems[Index]; default;
  end;

end.