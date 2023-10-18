namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  RodlLibrary = public partial class (RodlEntity)
  private
    fStructs: EntityCollection<RodlStruct>;
    fArrays: EntityCollection<RodlArray>;
    fEnums: EntityCollection<RodlEnum>;
    fExceptions: EntityCollection<RodlException>;
    fGroups: EntityCollection<RodlGroup>;
    fUses: EntityCollection<RodlUse>;
    fServices: EntityCollection<RodlService>;
    fEventSinks: EntityCollection<RodlEventSink>;

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

    method LoadFromString(aString: String; aUse: RodlUse := nil);
    begin
      if length(aString) > 0 then begin
        case aString[0] of
          '<': LoadFromXmlNode(XmlDocument.FromString(aString).Root, aUse);
          '{': LoadFromJsonNode(JsonDocument.FromString(aString).Root, aUse);
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

    method LoadUsedLibraryFromFile(aFilename: String; aUse: RodlUse);
    begin
      LoadFromString(File.ReadText(aFilename), aUse);
    end;

    method SaveToFile(aFilename: String; flattenUsedRODLs: Boolean = true);
    begin
      //if assigned(fXmlDocument) then
        //fXmlDocument.SaveToFile(aFilename)
      //else if assigned(fJsonNode) then
        //File.WriteText(aFilename, fJsonNode.ToString);
       SaveToJsonFile(aFilename, flattenUsedRODLs);
    end;

    [ToString]
    method ToString: String;
    begin
      //result := coalesce(fXmlDocument:ToString, fJsonNode:ToString);
      exit ToJsonString;
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

  RodlUse = public partial class(RodlEntity)
  public
    constructor;
    begin
      inherited constructor;
      Includes := nil;
      UsedRodlId := Guid.Empty;
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

  RodlGroup = public partial class(RodlEntity)
  end;

end.