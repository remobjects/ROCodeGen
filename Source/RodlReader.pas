namespace RemObjects.SDK.CodeGen4;

interface

uses
  RemObjects.CodeGen4,
  Sugar.*;

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
    constructor(); virtual;
    constructor(node: XmlElement);
    method LoadFromXmlNode(node: XmlElement); virtual;
    method HasCustomAttributes: Boolean;
    property IsFromUsedRodl: Boolean read assigned(FromUsedRodl);
    {$region Properties}
    property EntityID: Guid;
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
    property FromUsedRodlId: Guid;
    property Owner: RodlEntity;
    property OwnerLibrary: RodlLibrary read getOwnerLibrary;
    property DontCodegen: Boolean;
    {$endregion}
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
    method LoadFromXmlNode(node: XmlElement; aActivator: method : T);
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
    method LoadFromXmlNode(node: XmlElement; usedRodl: RodlUse; aActivator: method : T);
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
    method ToString: {$IF ECHOES}System.{$ENDIF}String; {$IF ECHOES}override;{$ENDIF}
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
    property ToffeeModule: String;
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
    method LoadFromXmlNode(node: XmlElement); override;
    property PrefixEnumValues: Boolean;
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
extension method String.FileExists: Boolean; assembly;
extension method String.PathIsRooted: Boolean; assembly;
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

extension method String.FileExists: Boolean;
begin
  {$IFDEF FAKESUGAR}
  exit File.Exists(self);
  {$ELSE}
  exit FileUtils.Exists(self);
  {$ENDIF}
end;

extension method String.PathIsRooted: Boolean;
begin
  if not(Self.Length >0) then exit false;
  {$IFDEF FAKESUGAR}
  if Self[0] = Path.DirectorySeparatorChar then exit true;
  {$ELSE}
  if Self[0] = Folder.Separator then exit true;
  {$ENDIF}
  if Self.Length >1 then
    if (Self[0] in ['A'..'Z','a'..'z']) and (Self[1] = ":") then exit true;
  exit false;
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
  exit iif(aName.ToLower() = "string", "AnsiString", aName);
end;

method RodlEntity.LoadFromXmlNode(node: XmlElement);
begin
  Name := node.Attributes["Name"]:Value;
  if (node.Attributes["UID"] <> nil) then EntityID := Guid.Parse(node.Attributes["UID"].Value);
  if (node.Attributes["FromUsedRodlUID"] <> nil) then FromUsedRodlId := Guid.Parse(node.Attributes["FromUsedRodlUID"].Value);
  &Abstract := node.Attributes["Abstract"]:Value = "1";
  DontCodegen :=  node.Attributes["DontCodeGen"]:Value = "1";
  var ldoc := node.GetFirstElementWithName("Documentation");
  if (ldoc <> nil) and (ldoc.FirstChild <> nil) then
      // FirstChild because data should be enclosed within CDATA
      Documentation := ldoc.FirstChild.Value;

  var lSubNode: XmlElement := node.GetFirstElementWithName("CustomAttributes");
  if (lSubNode <> nil) then begin
    for each childNode: XmlElement in lSubNode.ChildNodes do begin
      var lValue: XmlAttribute := childNode.Attributes["Value"];
      if (lValue <> nil) then begin
        CustomAttributes[childNode.LocalName] := lValue.Value;
        CustomAttributes_lower[childNode.LocalName.ToLower] := lValue.Value;
        if childNode.LocalName.ToLower = "soapname" then fOriginalName := lValue.Value;
      end;
    end;
  end;
end;

constructor RodlEntity();
begin
  EntityID := Guid.NewGuid();
  FromUsedRodlId := Guid.Empty;
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
  DataType := FixLegacyTypes(node.Attributes["DataType"].Value);
end;

method RodlEntityWithAncestor.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  if (node.Attributes["Ancestor"] <> nil) then AncestorName := node.Attributes["Ancestor"].Value;
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

method RodlComplexEntity<T>.LoadFromXmlNode(node: XmlElement; aActivator: method : T);
begin
  inherited LoadFromXmlNode(node);
  fItems.LoadFromXmlNode(node.GetFirstElementWithName(fItemsNodeName), nil, aActivator);
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
    result.AddRange(RodlComplexEntity<T>(lancestor).fItems.Items);
  end
  else begin
    result := new List<T>;
  end;
end;

method RodlComplexEntity<T>.GetAllItems: List<T>;
begin
  result := GetInheritedItems;
  result.AddRange(Self.fItems.Items);
end;

constructor RodlStructEntity;
begin
  inherited constructor("Element");
end;

method RodlStructEntity.LoadFromXmlNode(node: XmlElement);
begin
  LoadFromXmlNode(node,-> new RodlField);
  if (node.Attributes["AutoCreateParams"] <> nil) then
    AutoCreateProperties := (node.Attributes["AutoCreateParams"].Value = "1");
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

method EntityCollection<T>.RemoveEntity(&index: Integer);
begin
  fItems.RemoveAt(index);
end;

method EntityCollection<T>.FindEntity(name: String): T;
begin
  for lRodlEntity: T in fItems do
    if lRodlEntity.Name.EqualsIgnoreCase(name) then exit lRodlEntity;
  exit nil;
end;

method EntityCollection<T>.LoadFromXmlNode(node: XmlElement; usedRodl: RodlUse; aActivator: method : T);
begin
  if (node = nil) then exit;

  for lNode: XmlNode in node.ChildNodes do begin
    var lr := (lNode.NodeType = XmlNodeType.Element) and (XmlElement(lNode).LocalName = fEntityNodeName);
    if lr then begin
      var lEntity := aActivator();
      lEntity.FromUsedRodl := usedRodl;
      lEntity.Owner := Owner;
      lEntity.LoadFromXmlNode(XmlElement(lNode));

      var lIsNew := true;
      for entity:T in fItems do
        if entity.EntityID.Equals(lEntity.EntityID) then begin
          if entity.Name.EqualsIgnoreCase(lEntity.Name) then begin
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
    lResult.AddRange(fItems);
    exit;
  end;}

  for each lt in fItems do begin
    var laname:= RodlEntityWithAncestor(lt):AncestorName;
    if not String.IsNullOrEmpty(laname) and (fItems.Where(b->b.Name.EqualsIgnoreCase(laname)).Count>0) then
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
  if Path.GetExtension(aFilename):ToLower = ".remoterodl" then begin

    var lRemoteRodl := LoadXML(aFilename);
    if not assigned(lRemoteRodl)then
      raise new Exception("Could not read "+aFilename);
    LoadRemoteRodlFromXmlNode(lRemoteRodl.DocumentElement);

  end
  else begin
    Filename := aFilename;
    var lDocument := LoadXML(aFilename);
      if not assigned(lDocument)then
        raise new Exception("Could not read "+aFilename);
    LoadFromXmlNode(lDocument.DocumentElement);
  end;
end;

method RodlLibrary.SaveToFile(aFilename: String);
begin
  if assigned(fXmlNode) then
    fXmlNode.OwnerDocument.Save(aFilename);
end;


method RodlLibrary.ToString: {$IF ECHOES}System.{$ENDIF}String;
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
  LoadFromXmlNode(lDocument.DocumentElement);
end;

method RodlLibrary.LoadRemoteRodlFromXmlNode(node: XmlElement);
begin
  {$MESSAGE optimize code}
  var lServers := node.GetElementsByTagName("Server");

  if lServers.Count ≠ 1 then
    raise new Exception("Server element not found in remoteRODL.");

  {$IFDEF FAKESUGAR}
  var lServerUris := (lServers.Item(0)as XmlElement):GetElementsByTagName("ServerUri");
  if lServerUris.Count ≠ 1 then
    raise new Exception("lServerUris element not found in remoteRODL.");
  LoadFromUrl(lServerUris.Item(0).Value);  
  {$ELSE}
  var lServerUris := lServers[0].GetElementsByTagName("ServerUri");
  if length(lServerUris) ≠ 1 then
    raise new Exception("lServerUris element not found in remoteRODL.");
  LoadFromUrl(lServerUris[0].Value);  
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
    LoadFromXmlNode(lXml.DocumentElement);
  end
  else if lUrl.Scheme = "file" then begin
    var lXml := LoadXML(lUrl.AbsolutePath);
    LoadFromXmlNode(lXml.DocumentElement);
  end else begin
    raise new Exception("Unspoorted URL Scheme ("+lUrl.Scheme+") in remoteRODL.");
  end;
  {$ELSE}
  var lUrl := new Url(aUrl);
  if lUrl.Scheme in ["http", "https"] then begin
    var lXml := Http.GetXml(new HttpRequest(lUrl));// why is this cast needed, we have operator Implicit from Url to HttpRequest
    LoadFromXmlNode(lXml.DocumentElement);
  end
  else if lUrl.Scheme = "file" then begin
    var lXml := LoadXML(lUrl.Path);
    LoadFromXmlNode(lXml.DocumentElement);
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
    if (node.Attributes["Namespace"] <> nil) then
      &Namespace := node.Attributes["Namespace"].Value;
    if (node.Attributes["DataSnap"] <> nil) then
      DataSnap := node.Attributes["DataSnap"].Value = "1";
    if (node.Attributes["ScopedEnums"] <> nil) then
      ScopedEnums := node.Attributes["ScopedEnums"].Value = "1";
    DontApplyCodeGen := ((node.Attributes["SkipCodeGen"] <> nil) and (node.Attributes["SkipCodeGen"].Value = "1")) or
                        ((node.Attributes["DontCodeGen"] <> nil) and (node.Attributes["DontCodeGen"].Value = "1"));

    var lInclude := node.GetFirstElementWithName("Includes");
    if (lInclude <> nil) then begin
      Includes := new RodlInclude();
      Includes.LoadFromXmlNode(lInclude);
    end
    else begin
      Includes := nil;
    end;
  end
  else begin
    use.Name := node.Attributes["Name"]:Value;
    use.UsedRodlId := Guid.Parse(node.Attributes["UID"].Value);
    use.DontApplyCodeGen := use.DontApplyCodeGen or
                  (((node.Attributes["SkipCodeGen"] <> nil) and (node.Attributes["SkipCodeGen"].Value = "1")) or
                   ((node.Attributes["DontCodeGen"] <> nil) and (node.Attributes["DontCodeGen"].Value = "1")));
    if (node.Attributes["Namespace"] <> nil) then use.Namespace := node.Attributes["Namespace"].Value;

    var lInclude := node.GetFirstElementWithName("Includes");
    if (lInclude <> nil) then begin
      use.Includes := new RodlInclude();
      use.Includes.LoadFromXmlNode(lInclude);
    end;
    if isUsedRODLLoaded(use) then exit; 
  end;

  fUses.LoadFromXmlNode(node.GetFirstElementWithName("Uses"), use, -> new RodlUse);
  fStructs.LoadFromXmlNode(node.GetFirstElementWithName("Structs"), use, -> new RodlStruct);
  fArrays.LoadFromXmlNode(node.GetFirstElementWithName("Arrays"), use, -> new RodlArray);
  fEnums.LoadFromXmlNode(node.GetFirstElementWithName("Enums"), use, -> new RodlEnum);
  fExceptions.LoadFromXmlNode(node.GetFirstElementWithName("Exceptions"), use, -> new RodlException);
  fGroups.LoadFromXmlNode(node.GetFirstElementWithName("Groups"), use, -> new RodlGroup);
  fServices.LoadFromXmlNode(node.GetFirstElementWithName("Services"), use, -> new RodlService);
  fEventSinks.LoadFromXmlNode(node.GetFirstElementWithName("EventSinks"), use, -> new RodlEventSink);
end;

method RodlLibrary.LoadUsedFibraryFromFile(aFilename: String; use: RodlUse);
begin
  var lDocument := LoadXML(aFilename);
  LoadFromXmlNode(lDocument.DocumentElement, use);
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
  exit iif(node.Attributes[aName] <> nil, node.Attributes[aName].Value, "");
end;

method RodlInclude.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);

  DelphiModule := LoadAttribute(node, "Delphi");
  NetModule := LoadAttribute(node, "DotNet");
  ObjCModule := LoadAttribute(node, "ObjC");
  JavaModule := LoadAttribute(node, "Java");
  JavaScriptModule := LoadAttribute(node, "JavaScript");
  ToffeeModule := LoadAttribute(node, "Toffee");
  //backward compatibility
  if String.IsNullOrEmpty(ToffeeModule) then 
    ToffeeModule := LoadAttribute(node, "Nougat");
end;

constructor RodlUse;
begin
  inherited constructor;
  Includes := nil;
  UsedRodlId := Guid.Empty;
end;

method RodlUse.LoadFromXmlNode(node: XmlElement);
begin
  var l_Separator := {$IFDEF FAKESUGAR}Path.DirectorySeparatorChar{$ELSE}Folder.Separator{$ENDIF};


  inherited LoadFromXmlNode(node);

  var linclude: XmlElement := node.GetFirstElementWithName("Includes");
  if (linclude <> nil) then begin
    Includes := new RodlInclude();
    Includes.LoadFromXmlNode(linclude);
  end
  else begin
    Includes := nil;
  end;

  if (node.Attributes["Rodl"] <> nil) then
    FileName := node.Attributes["Rodl"].Value;

  if (node.Attributes["AbsoluteRodl"] <> nil) then
    AbsoluteRodl := node.Attributes["AbsoluteRodl"].Value;

  if (node.Attributes["UsedRodlID"] <> nil) then
    UsedRodlId := Guid.Parse(node.Attributes["UsedRodlID"].Value);

  DontApplyCodeGen := (node.Attributes["DontCodeGen"] <> nil) and (node.Attributes["DontCodeGen"].Value = "1");

  var usedRodlFileName: String := Path.GetFullPath(FileName);
  if (not usedRodlFileName.FileExists and not FileName.PathIsRooted) then begin
    if (OwnerLibrary.Filename <> nil) then
      usedRodlFileName := Path.GetFullPath(Path.Combine(Path.GetFullPath(OwnerLibrary.Filename).GetParentDirectory, FileName));
  end;

  if (not usedRodlFileName.FileExists and not FileName.PathIsRooted) then begin
    if (FromUsedRodl:AbsoluteFileName <> nil) then
      usedRodlFileName := Path.GetFullPath(Path.Combine(FromUsedRodl:AbsoluteFileName:GetParentDirectory, FileName));
  end;


  if (not usedRodlFileName.FileExists) then usedRodlFileName := AbsoluteRodl;
  if (not usedRodlFileName.FileExists) then begin
    usedRodlFileName := usedRodlFileName.Replace("/", l_Separator).Replace("\", l_Separator);
    var lFilename := Path.GetFileName(usedRodlFileName).ToLower;
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
  PrefixEnumValues := node.Attributes["Prefix"]:Value <> '0';
end;

method RodlArray.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  for lElementType: XmlNode in node.ChildNodes do begin
    if (lElementType.LocalName = "ElementType") then begin
      if (XmlElement(lElementType).Attributes["DataType"] <> nil) then
        ElementType := FixLegacyTypes(XmlElement(lElementType).Attributes["DataType"].Value);
      break;
    end;
  end;
end;

method RodlService.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  fRoles.Clear;
  fRoles.LoadFromXmlNode(node);
  &Private := node.Attributes["Private"]:Value = "1";
  ImplClass := node.Attributes["ImplClass"]:Value;
  ImplUnit := node.Attributes["ImplUnit"]:Value;
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
  if (node.Attributes["ForceAsyncResponse"] <> nil) then ForceAsyncResponse := node.Attributes["ForceAsyncResponse"].Value = "1";

  for parameter: RodlParameter in Items do
    if parameter.ParamFlag = ParamFlags.Result then self.Result := parameter;
  Items.Remove(self.Result);
end;

method RodlRoles.LoadFromXmlNode(node: XmlElement);
begin
  var el := node.GetFirstElementWithName("Roles") as XmlElement;

  if (el = nil) or (el.ChildCount = 0) then exit;

  for i:Int32 := 0 to el.ChildCount-1 do begin
    var lItem:XmlElement := el.ChildNodes[i] as XmlElement;
    if (lItem = nil) then continue;

    if (lItem.Name = "DenyRole") then fRoles.Add(new RodlRole(lItem.ValueOrText, true))
    else if (lItem.Name = "AllowRole") then fRoles.Add(new RodlRole(lItem.ValueOrText, false));
  end;
end;

method RodlRoles.Clear;
begin
  fRoles.Clear;
end;

method RodlParameter.LoadFromXmlNode(node: XmlElement);
begin
  inherited LoadFromXmlNode(node);
  var ln := node.Attributes["Flag"].Value.ToLower;
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

