﻿namespace RemObjects.SDK.CodeGen4;

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

  RodlStructEntity = public abstract class (RodlComplexEntity<RodlField>)
  public
    constructor();override;
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

  RodlServiceEntity = public abstract class (RodlComplexEntity<RodlInterface>)
  public
    constructor();override;
    begin
      inherited constructor("Interface");
    end;

    property DefaultInterface: RodlInterface read iif(Count>0,Item[0],nil);

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node,-> new RodlInterface);
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlInterface);
    end;

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


  RodlLibrary = public class (RodlEntity)
  private
    fXmlDocument: XmlDocument; // only for supporting SaveToFile
    fJsonNode: JsonNode; // only for supporting SaveToFile

    fStructs: EntityCollection<RodlStruct>;
    fArrays: EntityCollection<RodlArray>;
    fEnums: EntityCollection<RodlEnum>;
    fExceptions: EntityCollection<RodlException>;
    fGroups: EntityCollection<RodlGroup>;
    fUses: EntityCollection<RodlUse>;
    fServices: EntityCollection<RodlService>;
    fEventSinks: EntityCollection<RodlEventSink>;

    method LoadXML(aFile: String): XmlDocument;
    begin
      exit XmlDocument.FromFile(aFile);
    end;

    method isUsedRODLLoaded(anUse:RodlUse): Boolean;
    begin
      if EntityID.Equals(anUse.UsedRodlId) then exit true;
      for m in &Uses.Items do begin
        if m = anUse then continue;
        if m.UsedRodlId.Equals(anUse.UsedRodlId) then exit true;
      end;
      exit false;
    end;

  public
    constructor; override;
    begin
      Includes := nil;
      fStructs := new EntityCollection<RodlStruct>(self, "Struct");
      fArrays := new EntityCollection<RodlArray>(self, "Array");
      fEnums := new EntityCollection<RodlEnum>(self, "Enum");
      fExceptions := new EntityCollection<RodlException>(self, "Exception");
      fGroups := new EntityCollection<RodlGroup>(self, "Group");
      fUses := new EntityCollection<RodlUse>(self, "Use");
      fServices := new EntityCollection<RodlService>(self, "Service");
      fEventSinks := new EntityCollection<RodlEventSink>(self, "EventSink");
    end;

    constructor withURL(aURL: Url);
    begin
      LoadFromUrl(aURL);
    end;

    constructor (node: XmlElement);
    begin
      constructor();
      LoadFromXmlNode(node, nil);
    end;

    constructor (node: JsonNode);
    begin
      constructor();
      LoadFromJsonNode(node, nil);
    end;

    method LoadFromXmlNode(node: XmlElement; use: RodlUse := nil);
    begin
      if use = nil then begin
        fXmlDocument := node.Document; // needs to be kept in scope
        inherited LoadFromXmlNode(node);
        if (node.Attribute["Namespace"] <> nil) then
          &Namespace := node.Attribute["Namespace"].Value;
        if (node.Attribute["DataSnap"] <> nil) then
          DataSnap := node.Attribute["DataSnap"].Value = "1";
        if (node.Attribute["ScopedEnums"] <> nil) then
          ScopedEnums := node.Attribute["ScopedEnums"].Value = "1";
        DontApplyCodeGen := ((node.Attribute["SkipCodeGen"] <> nil) and (node.Attribute["SkipCodeGen"].Value = "1")) or
                            ((node.Attribute["DontCodeGen"] <> nil) and (node.Attribute["DontCodeGen"].Value = "1"));

        var lInclude := node.FirstElementWithName("Includes");
        if (lInclude <> nil) then begin
          Includes := new RodlInclude();
          Includes.LoadFromXmlNode(lInclude);
        end
        else begin
          Includes := nil;
        end;
      end
      else begin
        use.Name := node.Attribute["Name"]:Value;
        use.UsedRodlId := Guid.TryParse(node.Attribute["UID"].Value);
        use.DontApplyCodeGen := use.DontApplyCodeGen or
                      (((node.Attribute["SkipCodeGen"] <> nil) and (node.Attribute["SkipCodeGen"].Value = "1")) or
                       ((node.Attribute["DontCodeGen"] <> nil) and (node.Attribute["DontCodeGen"].Value = "1")));
        if (node.Attribute["Namespace"] <> nil) then use.Namespace := node.Attribute["Namespace"].Value;

        var lInclude := node.FirstElementWithName("Includes");
        if (lInclude <> nil) then begin
          use.Includes := new RodlInclude();
          use.Includes.LoadFromXmlNode(lInclude);
        end;
        if isUsedRODLLoaded(use) then exit;
      end;

      fUses.LoadFromXmlNode(node.FirstElementWithName("Uses"), use, -> new RodlUse);
      fStructs.LoadFromXmlNode(node.FirstElementWithName("Structs"), use, -> new RodlStruct);
      fArrays.LoadFromXmlNode(node.FirstElementWithName("Arrays"), use, -> new RodlArray);
      fEnums.LoadFromXmlNode(node.FirstElementWithName("Enums"), use, -> new RodlEnum);
      fExceptions.LoadFromXmlNode(node.FirstElementWithName("Exceptions"), use, -> new RodlException);
      fGroups.LoadFromXmlNode(node.FirstElementWithName("Groups"), use, -> new RodlGroup);
      fServices.LoadFromXmlNode(node.FirstElementWithName("Services"), use, -> new RodlService);
      fEventSinks.LoadFromXmlNode(node.FirstElementWithName("EventSinks"), use, -> new RodlEventSink);
    end;

    method LoadFromJsonNode(node: JsonNode; use: RodlUse := nil);
    begin
      if not assigned(use) then begin
        fJsonNode := node; // needs to be kept in scope
        inherited LoadFromJsonNode(node);
        &Namespace := node["Namespace"]:StringValue;
        DataSnap := valueOrDefault(node["DataSnap"]:BooleanValue);
        ScopedEnums := valueOrDefault(node["ScopedEnums"]:BooleanValue);
        DontApplyCodeGen := valueOrDefault(node["SkipCodeGen"]:BooleanValue) or valueOrDefault(node["DontCodeGen"]:BooleanValue);

        var lInclude := node["Includes"];
        if assigned(lInclude) then begin
          Includes := new RodlInclude();
          Includes.LoadFromJsonNode(lInclude);
        end
        else begin
          Includes := nil;
        end;
      end
      else begin
        use.Name := node["Name"]:StringValue;
        use.UsedRodlId := Guid.TryParse(node["ID"]:StringValue);
        use.DontApplyCodeGen := valueOrDefault(node["SkipCodeGen"]:BooleanValue) or valueOrDefault(node["DontCodeGen"]:BooleanValue);
        use.Namespace := node["Namespace"]:StringValue;

        var lInclude := node["Includes"];
        if assigned(lInclude) then begin
          Includes := new RodlInclude();
          Includes.LoadFromJsonNode(lInclude);
        end;
        if isUsedRODLLoaded(use) then exit;
      end;

      fUses.LoadFromJsonNode(node["Uses"], use, -> new RodlUse);
      fStructs.LoadFromJsonNode(node["Structs"], use, -> new RodlStruct);
      fArrays.LoadFromJsonNode(node["Arrays"], use, -> new RodlArray);
      fEnums.LoadFromJsonNode(node["Enums"], use, -> new RodlEnum);
      fExceptions.LoadFromJsonNode(node["Exceptions"], use, -> new RodlException);
      fGroups.LoadFromJsonNode(node["Groups"], use, -> new RodlGroup);
      fServices.LoadFromJsonNode(node["Services"], use, -> new RodlService);
      fEventSinks.LoadFromJsonNode(node["EventSinks"], use, -> new RodlEventSink);
    end;

    method LoadFromString(aString: String; use: RodlUse := nil);
    begin
      if length(aString) > 0 then begin
        case aString[0] of
          '<': LoadFromXmlNode(XmlDocument.FromString(aString).Root, use);
          '{': LoadFromJsonNode(JsonDocument.FromString(aString).Root, use);
          else raise new Exception("Unexpected file format for rodl.");
        end;
      end;
    end;

    //

    method LoadRemoteRodlFromXmlNode(node: XmlElement);
    begin
      {$MESSAGE optimize code}
      var lServers := node.ElementsWithName("Server");

      if lServers.Count ≠ 1 then
        raise new Exception("Server element not found in remoteRODL.");

      var lServerUris := lServers.FirstOrDefault.ElementsWithName("ServerUri");
      if lServerUris.Count ≠ 1 then
        raise new Exception("lServerUris element not found in remoteRODL.");
      LoadFromUrl(Url.UrlWithString(lServerUris.FirstOrDefault.Value));
    end;

    method LoadFromFile(aFilename: String);
    begin
      if Path.GetExtension(aFilename):ToLowerInvariant = ".remoterodl" then begin
        var lRemoteRodl := LoadXML(aFilename);
        if not assigned(lRemoteRodl)then
          raise new Exception("Could not read "+aFilename);
        LoadRemoteRodlFromXmlNode(lRemoteRodl.Root);
      end
      else begin
        Filename := aFilename;
        LoadFromString(File.ReadText(Filename));
      end;
    end;

    method LoadFromUrl(aUrl: Url);
    begin
      case caseInsensitive(aUrl.Scheme) of
        "http", "https": begin
            LoadFromString(Http.GetString(new HttpRequest(aUrl)));
          end;
        "file": begin
            LoadFromFile(aUrl.FilePath);
          end;
        "superhttp", "superhttps",
        "supertcp", "supertcps",
        "tcp", "tcps": raise new Exception("Unsupported URL Scheme ("+aUrl.Scheme+") in remoteRODL.");
        else raise new Exception("Unsupported URL Scheme ("+aUrl.Scheme+") in remoteRODL.");
      end;
    end;

    method LoadUsedLibraryFromFile(aFilename: String; use: RodlUse);
    begin
      LoadFromString(File.ReadText(aFilename), use);
    end;

    method SaveToFile(aFilename: String);
    begin
      if assigned(fXmlDocument) then
        fXmlDocument.SaveToFile(aFilename)
      else if assigned(fJsonNode) then
        File.WriteText(aFilename, fJsonNode.ToString);
    end;

    [ToString]
    method ToString: String;
    begin
      if assigned(fXmlDocument) then
        result := fXmlDocument.ToString();
    end;

    method FindEntity(aName: String):RodlEntity;
    begin
      var lEntity: RodlEntity;

      lEntity := fStructs.FindEntity(aName);
      if (lEntity = nil) then lEntity := fArrays.FindEntity(aName);
      if (lEntity = nil) then lEntity := fEnums.FindEntity(aName);
      if (lEntity = nil) then lEntity := fExceptions.FindEntity(aName);
      if (lEntity = nil) then lEntity := fGroups.FindEntity(aName);
      if (lEntity = nil) then lEntity := fUses.FindEntity(aName);
      if (lEntity = nil) then lEntity := fServices.FindEntity(aName);
      if (lEntity = nil) then lEntity := fEventSinks.FindEntity(aName);

      exit lEntity;
    end;

    property Structs: EntityCollection<RodlStruct> read fStructs;
    property Arrays: EntityCollection<RodlArray> read fArrays;
    property Enums: EntityCollection<RodlEnum> read fEnums;
    property Exceptions: EntityCollection<RodlException> read fExceptions;
    property Groups: EntityCollection<RodlGroup> read fGroups;
    property &Uses: EntityCollection<RodlUse> read fUses;
    property Services: EntityCollection<RodlService> read fServices;
    property EventSinks: EntityCollection<RodlEventSink> read fEventSinks;
    property Filename: String;
    property &Namespace: String;
    property Includes: RodlInclude;
    property DontApplyCodeGen: Boolean;
    property DataSnap: Boolean := false;
    property ScopedEnums: Boolean := false;
  end;

  RodlGroup = public class(RodlEntity)
  end;

  RodlInclude= public class(RodlEntity)
  private

    method LoadAttribute(node:XmlElement; aName:String):String;
    begin
      exit iif(node.Attribute[aName] <> nil, node.Attribute[aName].Value, "");
    end;

  public

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);

      DelphiModule := node.Attribute("Delphi"):Value;
      NetModule := node.Attribute("DotNet"):Value;
      ObjCModule := node.Attribute("ObjC"):Value;
      JavaModule := node.Attribute("Java"):Value;
      JavaScriptModule := node.Attribute("JavaScript"):Value;
      CocoaModule := node.Attribute("Cocoa"):Value;
      //backward compatibility
      if String.IsNullOrEmpty(CocoaModule) then
        CocoaModule := node.Attribute("Nougat"):Value;
      if String.IsNullOrEmpty(CocoaModule) then
        CocoaModule := node.Attribute("Tooffee"):Value;
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);

      DelphiModule := node["Delphi"]:StringValue;
      NetModule := node["DotNet"]:StringValue;
      ObjCModule := node["ObjC"]:StringValue;
      JavaModule := node["Java"]:StringValue;
      JavaScriptModule := node["JavaScript"]:StringValue;
      CocoaModule := node["Cocoa"]:StringValue;
      //backward compatibility
      if String.IsNullOrEmpty(CocoaModule) then
        CocoaModule := node["Nougat"]:StringValue;
      if String.IsNullOrEmpty(CocoaModule) then
        CocoaModule := node["Toffee"]:StringValue;
    end;

    property DelphiModule: String;
    property JavaModule: String;
    property JavaScriptModule: String;
    property NetModule: String;
    property CocoaModule: String;
    property ObjCModule: String;
  end;


  RodlUse = public class(RodlEntity)
  public
    constructor();override;
    begin
      inherited constructor;
      Includes := nil;
      UsedRodlId := Guid.Empty;
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);

      var linclude: XmlElement := node.FirstElementWithName("Includes");
      if (linclude <> nil) then begin
        Includes := new RodlInclude();
        Includes.LoadFromXmlNode(linclude);
      end
      else begin
        Includes := nil;
      end;

      if (node.Attribute["Rodl"] <> nil) then
        FileName := node.Attribute["Rodl"].Value;

      if (node.Attribute["AbsoluteRodl"] <> nil) then
        AbsoluteRodl := node.Attribute["AbsoluteRodl"].Value;

      if (node.Attribute["UsedRodlUID"] <> nil) then
        UsedRodlId := Guid.TryParse(node.Attribute["UsedRodlUID"].Value);

      DontApplyCodeGen := (node.Attribute["DontCodeGen"] <> nil) and (node.Attribute["DontCodeGen"].Value = "1");

      var usedRodlFileName: String := Path.GetFullPath(FileName);
      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (OwnerLibrary.Filename <> nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(Path.GetFullPath(OwnerLibrary.Filename).GetParentDirectory, FileName));
      end;

      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (FromUsedRodl:AbsoluteFileName <> nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(FromUsedRodl:AbsoluteFileName:GetParentDirectory, FileName));
      end;


      if (not usedRodlFileName.FileExists) then usedRodlFileName := AbsoluteRodl;
      if String.IsNullOrEmpty(usedRodlFileName) then Exit;
      if (not usedRodlFileName.FileExists) then begin
        usedRodlFileName := usedRodlFileName.Replace("/", Path.DirectorySeparatorChar).Replace("\", Path.DirectorySeparatorChar);
        var lFilename := Path.GetFileName(usedRodlFileName).ToLowerInvariant;
        //writeLn("checking for "+lFilename);
        if RodlCodeGen.KnownRODLPaths.ContainsKey(lFilename) then
          usedRodlFileName := RodlCodeGen.KnownRODLPaths[lFilename];
      end;

      //writeLn("using rodl: "+usedRodlFileName);

      if (usedRodlFileName.FileExists) then begin
        AbsoluteFileName := usedRodlFileName;
        OwnerLibrary.LoadUsedLibraryFromFile(usedRodlFileName, self);
        Loaded := true;
      end;

    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);

      var lIncludes := node["Includes"];
      if assigned(lIncludes) then begin
        Includes := new RodlInclude();
        Includes.LoadFromJsonNode(lIncludes);
      end
      else begin
        Includes := nil;
      end;

      FileName := node["Rodl"]:StringValue;
      AbsoluteRodl := node["AbsoluteRodl"]:StringValue;
      UsedRodlId := Guid.TryParse(node["UsedRodlID"]:StringValue);
      DontApplyCodeGen := valueOrDefault(node["DontCodeGen"]:BooleanValue);

      var usedRodlFileName: String := Path.GetFullPath(FileName);
      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (OwnerLibrary.Filename <> nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(Path.GetFullPath(OwnerLibrary.Filename).GetParentDirectory, FileName));
      end;

      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (FromUsedRodl:AbsoluteFileName <> nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(FromUsedRodl:AbsoluteFileName:GetParentDirectory, FileName));
      end;


      if (not usedRodlFileName.FileExists) then usedRodlFileName := AbsoluteRodl;
      if String.IsNullOrEmpty(usedRodlFileName) then Exit;
      if (not usedRodlFileName.FileExists) then begin
        usedRodlFileName := usedRodlFileName.Replace("/", Path.DirectorySeparatorChar).Replace("\", Path.DirectorySeparatorChar);
        var lFilename := Path.GetFileName(usedRodlFileName).ToLowerInvariant;
        //writeLn("checking for "+lFilename);
        if RodlCodeGen.KnownRODLPaths.ContainsKey(lFilename) then
          usedRodlFileName := RodlCodeGen.KnownRODLPaths[lFilename];
      end;

      //writeLn("using rodl: "+usedRodlFileName);

      if (usedRodlFileName.FileExists) then begin
        AbsoluteFileName := usedRodlFileName;
        OwnerLibrary.LoadUsedLibraryFromFile(usedRodlFileName, self);
        Loaded := true;
      end;

    end;

    property FileName: String;
    property AbsoluteRodl: String;
    property &Namespace: String;
    property Includes: RodlInclude;
    property UsedRodlId: Guid;
    property IsMerged: Boolean read not UsedRodlId.Equals(Guid.Empty);
    property DontApplyCodeGen: Boolean;
    property Loaded: Boolean;
    property AbsoluteFileName: String;
  end;

  RodlField = public class(RodlTypedEntity)
  end;

  RodlStruct= public class(RodlStructEntity)
  end;

  RodlException= public class(RodlStructEntity)
  end;

  RodlEnumValue = public class(RodlEntity)
  end;

  RodlEnum= public class(RodlComplexEntity<RodlEnumValue>)
  public
    constructor();override;
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

  RodlArray= public class(RodlEntity)
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

  RodlService = public class(RodlServiceEntity)
  private
    fRoles: RodlRoles := new RodlRoles();
  public

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      fRoles.Clear;
      fRoles.LoadFromXmlNode(node);
      &Private := node.Attribute["Private"]:Value = "1";
      ImplClass := node.Attribute["ImplClass"]:Value;
      ImplUnit := node.Attribute["ImplUnit"]:Value;
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      fRoles.Clear;
      fRoles.LoadFromJsonNode(node);
      &Private := valueOrDefault(node["Private"]:BooleanValue);
      ImplClass := node["ImplClass"]:StringValue;
      ImplUnit := node["ImplUnit"]:StringValue;
    end;

    property Roles: RodlRoles read fRoles;
    property ImplUnit:String;
    property ImplClass:String;
    property &Private: Boolean;
  end;

  RodlEventSink= public class(RodlServiceEntity)
  end;

  RodlInterface= public class(RodlComplexEntity<RodlOperation>)
  private
  public
    constructor();override;
    begin
      inherited constructor("Operation");
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, ->new RodlOperation);
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node, -> new RodlOperation);
    end;

  end;

  RodlRole = public class
  public
    constructor; empty;
    constructor(aRole: String; aNot: Boolean);
    begin
      Role := aRole;
      &Not := aNot;
    end;

    property Role: String;
    property &Not: Boolean;
  end;

  RodlRoles = public class
  private
    fRoles: List<RodlRole> := new List<RodlRole>;
  public

    method LoadFromXmlNode(node: XmlElement);
    begin
      var el := node.FirstElementWithName("Roles") as XmlElement;

      if (el = nil) or (el.Elements.Count = 0) then exit;

      for each lItem in el.Elements do begin
        if (lItem.LocalName = "DenyRole") then fRoles.Add(new RodlRole(lItem.ValueOrText, true))
        else if (lItem.LocalName = "AllowRole") then fRoles.Add(new RodlRole(lItem.ValueOrText, false));
      end;
    end;

    method LoadFromJsonNode(node: JsonNode);
    begin
      for each lItem in node['DenyRoles'] as JsonArray do
        fRoles.Add(new RodlRole(lItem:StringValue, true));
      for each lItem in node['DenyRoles'] as JsonArray do
        fRoles.Add(new RodlRole(lItem:StringValue, false));
    end;

    method Clear;
    begin
      fRoles.RemoveAll;
    end;

    property Roles:List<RodlRole> read fRoles;
    property Role[index : Integer]: RodlRole read fRoles[index];
  end;

  RodlOperation = public class(RodlComplexEntity<RodlParameter>)
  private
    fRoles: RodlRoles := new RodlRoles();
  public
    constructor();override;
    begin
      inherited constructor("Parameter");
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node,->new RodlParameter);
      fRoles.Clear;
      fRoles.LoadFromXmlNode(node);
      if (node.Attribute["ForceAsyncResponse"] <> nil) then ForceAsyncResponse := node.Attribute["ForceAsyncResponse"].Value = "1";

      for parameter: RodlParameter in Items do
        if parameter.ParamFlag = ParamFlags.Result then self.Result := parameter;
      Items.Remove(self.Result);
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      LoadFromJsonNode(node,->new RodlParameter);
      fRoles.Clear;
      fRoles.LoadFromJsonNode(node);
      ForceAsyncResponse := valueOrDefault(node["ForceAsyncResponse"]:BooleanValue);

      for parameter: RodlParameter in Items do
        if parameter.ParamFlag = ParamFlags.Result then self.Result := parameter;
      Items.Remove(self.Result);
    end;

    property Roles: RodlRoles read fRoles;
    property &Result: RodlParameter;
    property ForceAsyncResponse: Boolean := false;
  end;

  RodlParameter = public class(RodlTypedEntity)
  public

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      case caseInsensitive(node.Attribute["Flag"]:Value) of
        'in': ParamFlag:= ParamFlags.In;
        'out': ParamFlag:= ParamFlags.Out;
        'inout': ParamFlag:= ParamFlags.InOut;
        'result': ParamFlag:= ParamFlags.Result;
        else ParamFlag := ParamFlags.In;
      end;
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      case caseInsensitive(node["Flag"]:StringValue) of
        'in': ParamFlag:= ParamFlags.In;
        'out': ParamFlag:= ParamFlags.Out;
        'inout': ParamFlag:= ParamFlags.InOut;
        'result': ParamFlag:= ParamFlags.Result;
        else ParamFlag := ParamFlags.In;
      end;
    end;

    property ParamFlag: ParamFlags;
  end;

  RodlReader = public class
  private
  protected
  public
  end;

extension method XmlElement.ValueOrText: String; assembly;
begin
  {$IFDEF FAKESUGAR}
  exit Self.InnerText;
  {$ELSE}
  exit self.Value;
  {$ENDIF}
end;

extension method String.GetParentDirectory: String;
begin
  {$IFDEF FAKESUGAR}
  exit Path.GetDirectoryName(Self);
  {$ELSE}
  exit Path.GetParentDirectory(Self);
  {$ENDIF}
end;

end.