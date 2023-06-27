namespace RemObjects.SDK.CodeGen4;

type
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

    constructor;
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
      constructor;
      LoadFromUrl(aURL);
    end;

    constructor (node: XmlElement);
    begin
      constructor;
      LoadFromXmlNode(node, nil);
    end;

    constructor (node: JsonNode);
    begin
      constructor;
      LoadFromJsonNode(node, nil);
    end;

    method LoadFromXmlNode(node: XmlElement; use: RodlUse := nil);
    begin
      if use = nil then begin
        fXmlDocument := node.Document; // needs to be kept in scope
        inherited LoadFromXmlNode(node);
        if (node.Attribute["Namespace"] ≠ nil) then
          &Namespace := node.Attribute["Namespace"].Value;
        if (node.Attribute["DataSnap"] ≠ nil) then
          DataSnap := node.Attribute["DataSnap"].Value = "1";
        if (node.Attribute["ScopedEnums"] ≠ nil) then
          ScopedEnums := node.Attribute["ScopedEnums"].Value = "1";
        DontApplyCodeGen := ((node.Attribute["SkipCodeGen"] ≠ nil) and (node.Attribute["SkipCodeGen"].Value = "1")) or
                            ((node.Attribute["DontCodeGen"] ≠ nil) and (node.Attribute["DontCodeGen"].Value = "1"));

        var lInclude := node.FirstElementWithName("Includes");
        if (lInclude ≠ nil) then begin
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
                      (((node.Attribute["SkipCodeGen"] ≠ nil) and (node.Attribute["SkipCodeGen"].Value = "1")) or
                       ((node.Attribute["DontCodeGen"] ≠ nil) and (node.Attribute["DontCodeGen"].Value = "1")));
        if (node.Attribute["Namespace"] ≠ nil) then use.Namespace := node.Attribute["Namespace"].Value;

        var lInclude := node.FirstElementWithName("Includes");
        if (lInclude ≠ nil) then begin
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

        var lIncludes := coalesce(node["Includes"], node["Platforms"]);
        if assigned(lIncludes) then begin
          Includes := new RodlInclude();
          Includes.LoadFromJsonNode(lIncludes);
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

        var lIncludes := coalesce(node["Includes"], node["Platforms"]);
        if assigned(lIncludes) then begin
          Includes := new RodlInclude();
          Includes.LoadFromJsonNode(lIncludes);
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
      result := coalesce(fXmlDocument:ToString, fJsonNode:ToString);
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

  //
  //
  //

  RodlUse = public class(RodlEntity)
  public
    constructor;
    begin
      inherited constructor;
      Includes := nil;
      UsedRodlId := Guid.Empty;
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);

      var lInclude: XmlElement := node.FirstElementWithName("Includes");
      if assigned(lInclude) then begin
        Includes := new RodlInclude();
        Includes.LoadFromXmlNode(lInclude);
      end
      else begin
        Includes := nil;
      end;

      if (node.Attribute["Rodl"] ≠ nil) then
        FileName := node.Attribute["Rodl"].Value;

      if (node.Attribute["AbsoluteRodl"] ≠ nil) then
        AbsoluteRodl := node.Attribute["AbsoluteRodl"].Value;

      if (node.Attribute["UsedRodlUID"] ≠ nil) then
        UsedRodlId := Guid.TryParse(node.Attribute["UsedRodlUID"].Value);

      DontApplyCodeGen := (node.Attribute["DontCodeGen"] ≠ nil) and (node.Attribute["DontCodeGen"].Value = "1");

      var usedRodlFileName: String := Path.GetFullPath(FileName);
      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (OwnerLibrary.Filename ≠ nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(Path.GetFullPath(OwnerLibrary.Filename).ParentDirectory, FileName));
      end;

      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (FromUsedRodl:AbsoluteFileName ≠ nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(FromUsedRodl:AbsoluteFileName:ParentDirectory, FileName));
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

      var lIncludes := coalesce(node["Includes"], node["Platforms"]);
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
        if (OwnerLibrary.Filename ≠ nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(Path.GetFullPath(OwnerLibrary.Filename).ParentDirectory, FileName));
      end;

      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (FromUsedRodl:AbsoluteFileName ≠ nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(FromUsedRodl:AbsoluteFileName:ParentDirectory, FileName));
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

  //
  //
  //

  RodlGroup = public class(RodlEntity)
  end;

end.