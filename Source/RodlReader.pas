namespace RemObjects.SDK.CodeGen4;

interface

type
  ParamFlags = public enum (
    &In,
    &Out,
    &InOut,
    &Result
  );

  RodlEntity = public abstract class
  private
    fOriginalName: String;
    method getOriginalName: String;
    fCustomAttributes: Dictionary<String,String> := new Dictionary<String,String>;
    fCustomAttributes_lower: Dictionary<String,String> := new Dictionary<String,String>;
    method getOwnerLibrary: RodlLibrary;
  protected
    method FixLegacyTypes(aName: String):String;
  public
    constructor(); virtual; empty;
    constructor(node: XmlElement);
    method LoadFromXmlNode(node: XmlElement); virtual;
    method HasCustomAttributes: Boolean;
    property IsFromUsedRodl: Boolean read assigned(FromUsedRodl);
    {$region Properties}
    property EntityID: Guid := Guid.EmptyGuid;
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
    property FromUsedRodlId: Guid := Guid.EmptyGuid;
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
    property DataType: String;
  end;

  RodlEntityWithAncestor = public abstract class (RodlEntity)
  private
    method setAncestorEntity(value: RodlEntity);
    method getAncestorEntity: RodlEntity;
  public
    method LoadFromXmlNode(node: XmlElement); override;
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
    method LoadFromXmlNode(node: XmlElement; aActivator: block : T);
    method GetInheritedItems: List<T>;
    method GetAllItems: List<T>;
    property Items: List<T> read fItems.Items;
    property Count: Int32 read fItems.Count;
    property Item[index: Integer]: T read fItems[index]; default;
  end;

  RodlStructEntity = public abstract class (RodlComplexEntity<RodlField>)
  public
    constructor();override;
    method LoadFromXmlNode(node: XmlElement); override;
    property AutoCreateProperties: Boolean := False;
  end;

  RodlServiceEntity = public abstract class (RodlComplexEntity<RodlInterface>)
  public
    constructor();override;
    property DefaultInterface: RodlInterface read iif(Count>0,Item[0],nil);
    method LoadFromXmlNode(node: XmlElement); override;
  end;

  EntityCollection<T> = public class
    where T is RodlEntity;
  private
    fEntityNodeName: String;
    fItems: List<T> := new List<T>;
  public
    constructor(aOwner: RodlEntity; nodeName: String);
    method LoadFromXmlNode(node: XmlElement; usedRodl: RodlUse; aActivator: block : T);
    method AddEntity(entity : T);
    method RemoveEntity(entity: T);
    method RemoveEntity(index: Int32);
    method FindEntity(name: String): T;
    method SortedByAncestor: List<T>;
    property Owner : RodlEntity;
    property Count: Integer read fItems.Count;
    property Items: List<T> read fItems;
    property Item[Index: Integer]: T read fItems[Index]; default;
  end;


  RodlLibrary = public class (RodlEntity)
  private
    fXmlNode: XmlElement; // only for supporting SaveToFile

    fStructs: EntityCollection<RodlStruct>;
    fArrays: EntityCollection<RodlArray>;
    fEnums: EntityCollection<RodlEnum>;
    fExceptions: EntityCollection<RodlException>;
    fGroups: EntityCollection<RodlGroup>;
    fUses: EntityCollection<RodlUse>;
    fServices: EntityCollection<RodlService>;
    fEventSinks: EntityCollection<RodlEventSink>;
    method LoadXML(aFile: String): XmlDocument;
    method isUsedRODLLoaded(anUse:RodlUse): Boolean;
  public
    constructor; override;
    constructor (aFilename: String);
    constructor (node: XmlElement);
    method LoadFromXmlNode(node: XmlElement); override;
    method LoadFromXmlNode(node: XmlElement; use: RodlUse);
    method LoadRemoteRodlFromXmlNode(node: XmlElement);
    method LoadFromUrl(aUrl: String);
    method LoadFromFile(aFilename: String);
    method LoadFromXmlString(aString: String);
    method LoadUsedFibraryFromFile(aFilename: String; use: RodlUse);
    method SaveToFile(aFilename: String);
    [ToString]
    method ToString: String;
    method FindEntity(aName: String):RodlEntity;
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
  public
    method LoadFromXmlNode(node: XmlElement); override;
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
    method LoadFromXmlNode(node: XmlElement); override;
    property FileName: String;
    property AbsoluteRodl: String;
    property &Namespace: String;
    property Includes: RodlInclude;
    property UsedRodlId: Guid;
    property IsMerged: Boolean read not UsedRodlId.Equals(Guid.EmptyGuid);
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
    method LoadFromXmlNode(node: XmlElement); override;
    property PrefixEnumValues: Boolean;
    property DefaultValueName: String read if Count > 0 then Item[0].Name;
  end;

  RodlArray= public class(RodlEntity)
  public
    method LoadFromXmlNode(node: XmlElement); override;
    property ElementType: String;
  end;

  RodlService= public class(RodlServiceEntity)
  private
    fRoles: RodlRoles := new RodlRoles();
  public
    method LoadFromXmlNode(node: XmlElement); override;
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
    method LoadFromXmlNode(node: XmlElement); override;
  end;

  RodlRole = public class
  public
    constructor; empty;
    constructor(aRole: String; aNot: Boolean);
    property Role: String;
    property &Not: Boolean;
  end;

  RodlRoles = public class
  private
    fRoles: List<RodlRole> := new List<RodlRole>;
  public
    method LoadFromXmlNode(node: XmlElement);
    method Clear;
    property Roles:List<RodlRole> read fRoles;
    property Role[index : Integer]: RodlRole read fRoles[index];
  end;

  RodlOperation = public class(RodlComplexEntity<RodlParameter>)
  private
    fRoles: RodlRoles := new RodlRoles();
  public
    constructor();override;
    method LoadFromXmlNode(node: XmlElement); override;
    property Roles: RodlRoles read fRoles;
    property &Result: RodlParameter;
    property ForceAsyncResponse: Boolean := false;
  end;

  RodlParameter = public class(RodlTypedEntity)
  private

  public
    method LoadFromXmlNode(node: XmlElement); override;
    property ParamFlag: ParamFlags;
  end;

  RodlReader = public class
  private
  protected
  public
  end;

extension method XmlElement.ValueOrText: String; assembly;
extension method String.GetParentDirectory: String;

implementation

extension method String.GetParentDirectory: String;
begin
  {$IFDEF FAKESUGAR}
  exit Path.GetDirectoryName(Self);
  {$ELSE}
  exit Path.GetParentDirectory(Self);
  {$ENDIF}
end;

extension method XmlElement.ValueOrText: String;
begin
  {$IFDEF FAKESUGAR}
  exit Self.InnerText;
  {$ELSE}
  exit self.Value;
  {$ENDIF}
end;

method RodlEntity.HasCustomAttributes: Boolean;
begin
  Result := assigned(CustomAttributes) and (CustomAttributes:Count >0)
end;

method RodlEntity.getOwnerLibrary: RodlLibrary;
begin
  var lOwner: RodlEntity := self;
  while ((lOwner <> nil) and (not(lOwner is RodlLibrary))) do
     lOwner := lOwner.Owner;
  exit (lOwner as RodlLibrary);
end;

method RodlEntity.FixLegacyTypes(aName: String):String;
begin
  exit iif(aName.ToLowerInvariant() = "string", "AnsiString", aName);
end;

method RodlEntity.LoadFromXmlNode(node: XmlElement);
begin
  Name := node.Attribute["Name"]:Value;
  if (node.Attribute["UID"] <> nil) then EntityID := Guid.TryParse(node.Attribute["UID"].Value);
  if (node.Attribute["FromUsedRodlUID"] <> nil) then FromUsedRodlId := Guid.TryParse(node.Attribute["FromUsedRodlUID"].Value);
  &Abstract := node.Attribute["Abstract"]:Value = "1";
  DontCodegen :=  node.Attribute["DontCodeGen"]:Value = "1";
  var ldoc := node.FirstElementWithName("Documentation");

  if (ldoc ≠ nil) and (ldoc.Nodes.Count>0) and (ldoc.Nodes[0] is XmlCData) then begin
      // FirstChild because data should be enclosed within CDATA
    Documentation := (ldoc.Nodes[0] as XmlCData).Value;
  end;

  var lSubNode: XmlElement := node.FirstElementWithName("CustomAttributes");
  if (lSubNode <> nil) then begin
    for each childNode: XmlElement in lSubNode.Elements do begin
      var lValue: XmlAttribute := childNode.Attribute["Value"];
      if (lValue <> nil) then begin
        CustomAttributes[childNode.LocalName] := lValue.Value;
        CustomAttributes_lower[childNode.LocalName.ToLowerInvariant] := lValue.Value;
        if childNode.LocalName.ToLowerInvariant = "soapname" then fOriginalName := lValue.Value;
      end;
    end;
  end;
end;

constructor RodlEntity(node: XmlElement);
begin
  constructor();
  LoadFromXmlNode(node);
end;

method RodlEntity.getOriginalName: String;
begin
  exit iif(String.IsNullOrEmpty(fOriginalName), Name, fOriginalName);
end;

method RodlTypedEntity.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  DataType := FixLegacyTypes(node.Attribute["DataType"].Value);
end;

method RodlEntityWithAncestor.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  if (node.Attribute["Ancestor"] <> nil) then AncestorName := node.Attribute["Ancestor"].Value;
end;

method RodlEntityWithAncestor.getAncestorEntity: RodlEntity;
begin
  if (String.IsNullOrEmpty(AncestorName)) then exit nil;

  var lRodlLibrary: RodlLibrary := OwnerLibrary;

  exit iif(lRodlLibrary = nil, nil , lRodlLibrary.FindEntity(AncestorName));
end;

method RodlEntityWithAncestor.setAncestorEntity(value: RodlEntity);
begin
  value := getAncestorEntity;
end;

method RodlComplexEntity<T>.LoadFromXmlNode(node: XmlElement; aActivator: block : T);
begin
  inherited LoadFromXmlNode(node);
  fItems.LoadFromXmlNode(node.FirstElementWithName(fItemsNodeName), nil, aActivator);
end;

constructor RodlComplexEntity<T>(nodeName: String);
begin
  inherited constructor;
  fItemsNodeName := nodeName + "s";
  fItems := new EntityCollection<T>(self, nodeName);
end;

method RodlComplexEntity<T>.GetInheritedItems: List<T>;
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

method RodlComplexEntity<T>.GetAllItems: List<T>;
begin
  result := GetInheritedItems;
  result.Add(Self.fItems.Items);
end;

constructor RodlStructEntity;
begin
  inherited constructor("Element");
end;

method RodlStructEntity.LoadFromXmlNode(node: XmlElement);
begin
  LoadFromXmlNode(node,-> new RodlField);
  if (node.Attribute["AutoCreateParams"] <> nil) then
    AutoCreateProperties := (node.Attribute["AutoCreateParams"].Value = "1");
end;

constructor RodlServiceEntity;
begin
  inherited constructor("Interface");
end;

method RodlServiceEntity.LoadFromXmlNode(node: XmlElement);
begin
  LoadFromXmlNode(node,-> new RodlInterface);
end;

constructor EntityCollection<T>(aOwner: RodlEntity; nodeName: String);
begin
  fEntityNodeName := nodeName;
  Owner := aOwner;
end;

method EntityCollection<T>.AddEntity(entity: T);
begin
  fItems.Add(entity);
end;

method EntityCollection<T>.RemoveEntity(entity: T);
begin
  fItems.Remove(entity);
end;

method EntityCollection<T>.RemoveEntity(&index: Int32);
begin
  fItems.RemoveAt(index);
end;

method EntityCollection<T>.FindEntity(name: String): T;
begin
  for lRodlEntity: T in fItems do
    if not lRodlEntity.IsFromUsedRodl and lRodlEntity.Name.EqualsIgnoringCaseInvariant(name) then exit lRodlEntity;

  for lRodlEntity: T in fItems do
    if lRodlEntity.Name.EqualsIgnoringCaseInvariant(name) then exit lRodlEntity;
  exit nil;
end;

method EntityCollection<T>.LoadFromXmlNode(node: XmlElement; usedRodl: RodlUse; aActivator: block : T);
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
      for entity:T in fItems do
        if entity.EntityID.Equals(lEntity.EntityID) then begin
          if entity.Name.EqualsIgnoringCaseInvariant(lEntity.Name) then begin
            lIsNew := false;
            break;
          end
          else begin
            lEntity.EntityID := Guid.NewGuid;
          end;
        end;
      if lIsNew then AddEntity(lEntity);
    end;
  end;
end;

method EntityCollection<T>.SortedByAncestor: List<T>;
begin
  var lResult := new List<T>;
  var lAncestors := new List<T>;

  {if typeOf(T).Equals(typeOf(RodlEntityWithAncestor) then begin
    lResult.Add(fItems);
    exit;
  end;}

  for each lt in fItems do begin
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

constructor RodlLibrary;
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

constructor RodlLibrary(aFilename: String);
begin
  constructor();
  if aFilename.StartsWith('http://') or aFilename.StartsWith('https://') or
    aFilename.StartsWith('superhttp://') or aFilename.StartsWith('superhttps://') or
    aFilename.StartsWith('tcp://') or aFilename.StartsWith('tcps://') or
    aFilename.StartsWith('supertcp://') or aFilename.StartsWith('supertcps://') then
    LoadFromUrl(aFilename)
  else
    LoadFromFile(aFilename);
end;

constructor RodlLibrary(node: XmlElement);
begin
  constructor();
  LoadFromXmlNode(node, nil);
end;

method RodlLibrary.LoadFromFile(aFilename: String);
begin
  if Path.GetExtension(aFilename):ToLowerInvariant = ".remoterodl" then begin

    var lRemoteRodl := LoadXML(aFilename);
    if not assigned(lRemoteRodl)then
      raise new Exception("Could not read "+aFilename);
    LoadRemoteRodlFromXmlNode(lRemoteRodl.Root);

  end
  else begin
    Filename := aFilename;
    var lDocument := LoadXML(aFilename);
      if not assigned(lDocument)then
        raise new Exception("Could not read "+aFilename);
    LoadFromXmlNode(lDocument.Root);
  end;
end;

method RodlLibrary.SaveToFile(aFilename: String);
begin
  if assigned(fXmlNode) then
    fXmlNode.Document.SaveToFile(aFilename);
end;


method RodlLibrary.ToString: String;
begin
  if assigned(fXmlNode) then
    {$IFDEF FAKESUGAR}
    result := fXmlNode.OwnerDocument.InnerXml;
    {$ELSE}
    result := fXmlNode.ToString();
    {$ENDIF}
end;

method RodlLibrary.LoadFromXmlString(aString: String);
begin
  {$IFDEF FAKESUGAR}
  var lDocument := new XmlDocument();
  lDocument.LoadXml(aString);
  {$ELSE}
  var lDocument := XmlDocument.FromString(aString);
  {$ENDIF}
  LoadFromXmlNode(lDocument.Root);
end;

method RodlLibrary.LoadRemoteRodlFromXmlNode(node: XmlElement);
begin
  {$MESSAGE optimize code}
  var lServers := node.ElementsWithName("Server");

  if lServers.Count ≠ 1 then
    raise new Exception("Server element not found in remoteRODL.");

  {$IFDEF FAKESUGAR}
  var lServerUris := (lServers.Item(0)as XmlElement):GetElementsByTagName("ServerUri");
  if lServerUris.Count ≠ 1 then
    raise new Exception("lServerUris element not found in remoteRODL.");
  LoadFromUrl(lServerUris.Item(0).Value);
  {$ELSE}
  var lServerUris := lServers.FirstOrDefault.ElementsWithName("ServerUri");
  if lServerUris.Count ≠ 1 then
    raise new Exception("lServerUris element not found in remoteRODL.");
  LoadFromUrl(lServerUris.FirstOrDefault.Value);
  {$ENDIF}
end;

method RodlLibrary.LoadFromUrl(aUrl: String);
begin
  {$IFDEF FAKESUGAR}
  var lUrl := new Uri(aUrl);
  if lUrl.Scheme in ["http", "https"] then begin
    var allData := new System.IO.MemoryStream();
    using webRequest := System.Net.WebRequest.Create(lUrl) as System.Net.HttpWebRequest do begin
      webRequest.AllowAutoRedirect := true;
      //webRequest.UserAgent := "RemObjects Sugar/8.0 http://www.elementscompiler.com/elements/sugar";
      webRequest.Method := 'GET';
      var webResponse := webRequest.GetResponse() as System.Net.HttpWebResponse;
      webResponse.GetResponseStream().CopyTo(allData);
    end;
    var lXml := new XmlDocument;
    lXml.Load(allData);
    LoadFromXmlNode(lXml.Root);
  end
  else if lUrl.Scheme = "file" then begin
    var lXml := LoadXML(lUrl.AbsolutePath);
    LoadFromXmlNode(lXml.Root);
  end else begin
    raise new Exception("Unspoorted URL Scheme ("+lUrl.Scheme+") in remoteRODL.");
  end;
  {$ELSE}
  var lUrl := Url.UrlWithString(aUrl);
  if lUrl.Scheme in ["http", "https"] then begin
    var lXml := Http.GetXml(new HttpRequest(lUrl));// why is this cast needed, we have operator Implicit from Url to HttpRequest
    LoadFromXmlNode(lXml.Root);
  end
  else if lUrl.Scheme = "file" then begin
    var lXml := LoadXML(lUrl.Path);
    LoadFromXmlNode(lXml.Root);
  end else begin
    raise new Exception("Unspoorted URL Scheme ("+lUrl.Scheme+") in remoteRODL.");
  end;
  {$ENDIF}

end;

method RodlLibrary.LoadFromXmlNode(node: XmlElement);
begin
  LoadFromXmlNode(node, nil);
end;

method RodlLibrary.LoadFromXmlNode(node: XmlElement; use: RodlUse);
begin
  if use = nil then begin
    fXmlNode := node;
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

method RodlLibrary.LoadUsedFibraryFromFile(aFilename: String; use: RodlUse);
begin
  var lDocument := LoadXML(aFilename);
  LoadFromXmlNode(lDocument.Root, use);
end;

method RodlLibrary.FindEntity(aName: String): RodlEntity;
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

method RodlLibrary.LoadXML(aFile: String): XmlDocument;
begin
  {$IFDEF FAKESUGAR}
  Result := new XmlDocument;
  result.Load(aFile);
  {$ELSE}
  exit XmlDocument.FromFile(aFile);
  {$ENDIF}
end;

method RodlLibrary.isUsedRODLLoaded(anUse: RodlUse): Boolean;
begin
  if EntityID.Equals(anUse.UsedRodlId) then exit true;
  for m in &Uses.Items do begin
    if m = anUse then continue;
    if m.UsedRodlId.Equals(anUse.UsedRodlId) then exit true;
  end;
  exit false;
end;

method RodlInclude.LoadAttribute(node: XmlElement; aName: String): String;
begin
  exit iif(node.Attribute[aName] <> nil, node.Attribute[aName].Value, "");
end;

method RodlInclude.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);

  DelphiModule := LoadAttribute(node, "Delphi");
  NetModule := LoadAttribute(node, "DotNet");
  ObjCModule := LoadAttribute(node, "ObjC");
  JavaModule := LoadAttribute(node, "Java");
  JavaScriptModule := LoadAttribute(node, "JavaScript");
  CocoaModule := LoadAttribute(node, "Cocoa");
  //backward compatibility
  if String.IsNullOrEmpty(CocoaModule) then
    CocoaModule := LoadAttribute(node, "Nougat");
end;

constructor RodlUse;
begin
  inherited constructor;
  Includes := nil;
  UsedRodlId := Guid.EmptyGuid;
end;

method RodlUse.LoadFromXmlNode(node: XmlElement);
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
    OwnerLibrary.LoadUsedFibraryFromFile(usedRodlFileName, self);
    Loaded := true;
  end;

end;

constructor RodlEnum;
begin
  inherited constructor("EnumValue");
end;

method RodlEnum.LoadFromXmlNode(node: XmlElement);
begin
  LoadFromXmlNode(node, -> new RodlEnumValue);
  PrefixEnumValues := node.Attribute["Prefix"]:Value <> '0';
end;

method RodlArray.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  for lElementType in node.Elements do begin
    if (lElementType.LocalName = "ElementType") then begin
      if (XmlElement(lElementType).Attribute["DataType"] <> nil) then
        ElementType := FixLegacyTypes(XmlElement(lElementType).Attribute["DataType"].Value);
      break;
    end;
  end;
end;

method RodlService.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  fRoles.Clear;
  fRoles.LoadFromXmlNode(node);
  &Private := node.Attribute["Private"]:Value = "1";
  ImplClass := node.Attribute["ImplClass"]:Value;
  ImplUnit := node.Attribute["ImplUnit"]:Value;
end;

constructor RodlInterface;
begin
  inherited constructor("Operation");
end;

method RodlInterface.LoadFromXmlNode(node: XmlElement);
begin
  LoadFromXmlNode(node, ->new RodlOperation);
end;

constructor RodlRole(aRole: String; aNot: Boolean);
begin
  Role := aRole;
  &Not := aNot;
end;

constructor RodlOperation;
begin
  inherited constructor("Parameter");
end;

method RodlOperation.LoadFromXmlNode(node: XmlElement);
begin
  LoadFromXmlNode(node,->new RodlParameter);
  fRoles.Clear;
  fRoles.LoadFromXmlNode(node);
  if (node.Attribute["ForceAsyncResponse"] <> nil) then ForceAsyncResponse := node.Attribute["ForceAsyncResponse"].Value = "1";

  for parameter: RodlParameter in Items do
    if parameter.ParamFlag = ParamFlags.Result then self.Result := parameter;
  Items.Remove(self.Result);
end;

method RodlRoles.LoadFromXmlNode(node: XmlElement);
begin
  var el := node.FirstElementWithName("Roles") as XmlElement;

  if (el = nil) or (el.Elements.Count = 0) then exit;

  for each lItem in el.Elements do begin
    if (lItem.LocalName = "DenyRole") then fRoles.Add(new RodlRole(lItem.ValueOrText, true))
    else if (lItem.LocalName = "AllowRole") then fRoles.Add(new RodlRole(lItem.ValueOrText, false));
  end;
end;

method RodlRoles.Clear;
begin
  fRoles.RemoveAll;
end;

method RodlParameter.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  var ln := node.Attribute["Flag"].Value.ToLowerInvariant;
  case ln of
    'in': ParamFlag:= ParamFlags.In;
    'out': ParamFlag:= ParamFlags.Out;
    'inout': ParamFlag:= ParamFlags.InOut;
    'result': ParamFlag:= ParamFlags.Result;
  else
    ParamFlag := ParamFlags.In;
  end;
end;

end.