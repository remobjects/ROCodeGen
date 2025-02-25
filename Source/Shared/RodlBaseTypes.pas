namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  ParamFlags = public enum (&In, &Out, &InOut, &Result);

  RodlEntity = public partial abstract class
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
      while ((lOwner ≠ nil) and (not(lOwner is RodlLibrary))) do
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
    method HasCustomAttributes: Boolean;
    begin
      Result := assigned(CustomAttributes) and (CustomAttributes:Count >0)
    end;

    {$REGION validate}
    method Validate; virtual; empty;
    method GetFullName: String;
    begin
      //service & eventsing & rodlstruct & rodlexception & rodlenum
      if (self is RodlServiceEntity) or (self is RodlStructEntity) or (self is RodlEnum) then
        exit self.Name
      // rodl operation & rodl param & field & enum value
      else if (self is RodlOperation) or (self is RodlParameter) or (self is RodlField) or (self is RodlEnumValue) then begin
        if assigned(self.Owner) then
          exit Owner.GetFullName + '.' + self.Name
        else
          exit self.Name;
      end
      // rodl interface
      else if self is RodlInterface then begin
        if assigned(self.Owner) then
          exit Owner.GetFullName
        else
          exit '';
      end
      else
        exit self.Name;
    end;
    {$ENDREGION}

    property IsFromUsedRodl: Boolean read assigned(FromUsedRodl) or assigned(FromUsedRodlId) ;
    {$REGION Properties}
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
    property DontCodegen: Boolean; virtual;
    {$ENDREGION}
    {$IFDEF ECHOES}
    method ToString: String; override;
    begin
      exit Name;
    end;
    {$ENDIF}
  end;

  RodlTypedEntity = public partial abstract class (RodlEntity)
  public
    property DataType: String;
    method Validate; override;
    begin
      inherited;
      if RodlLibrary.IsInternalType(DataType) then exit;
      if OwnerLibrary:FindEntity(DataType) = nil then raise new Exception($'Invalid or undefined type ({self.DataType}) is used in {self.GetFullName}');
    end;
  end;

  RodlEntityWithAncestor = public partial abstract class (RodlEntity)
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
    property AncestorName: String;
    property AncestorEntity: RodlEntity read getAncestorEntity write setAncestorEntity;
    method Validate; override;
    begin
      inherited;
      if not String.IsNullOrWhiteSpace(AncestorName) then begin
        var a := AncestorEntity;
        if (a = nil) then raise new Exception($'Invalid or undefined ancestor ({self.AncestorName}) is used in {self.GetFullName}');
        a.Validate;
      end;
    end;
  end;

  RodlComplexEntity<T> = public partial abstract class (RodlEntityWithAncestor)
    where T is RodlEntity;
  private
    fItems: EntityCollection<T>;
  public
    constructor();abstract;

    constructor(nodeName:String; aItemsNodeNameXmlJson: nullable String := nil);
    begin
      inherited constructor;
      fItemsNodeNameXml := nodeName + "s";
      fItemsNodeNameJson := aItemsNodeNameXmlJson;
      fItems := new EntityCollection<T>(self, nodeName);
    end;

    method Validate; override;
    begin
      inherited;
      fItems.Validate;
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

    method FindEntity(name: String): T;
    begin
      exit fItems.FindEntity(name);
    end;

    property Items: List<T> read fItems.Items;
    property Count: Int32 read fItems.Count;
    property Item[index: Integer]: T read fItems[index]; default;
  end;

  EntityCollection<T> = public partial class
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

    method AddEntity(aEntity : T);
    begin
      fItems.Add(aEntity);
    end;

    method RemoveEntity(aEntity: T);
    begin
      fItems.Remove(aEntity);
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
            if lIndex + 1 > lResult.Count - 1 then begin
              lResult.Add(lAncestors[i]);
            end
            else begin
              for j: Integer := lIndex + 1 to lResult.Count - 1 do begin
                if lResult[j].Name.CompareToIgnoreCase(lAncestors[i].Name) >= 0 then begin
                  lResult.Insert(j, lAncestors[i]);
                  break;
                end
                else begin
                  lResult.Insert(j + 1, lAncestors[i]);
                  break;
                end;
              end;
            end;

            lAncestors.RemoveAt(i);
            lWorked := true;
          end;
          if (not lWorked) and (lAncestors.Count > 0) then
            new Exception("Invalid or recursive inheritance detected");
        end;
      end;
      exit lResult;
    end;

    method Validate;
    begin
      for each it in fItems do
        it.Validate;
    end;

    property Owner : RodlEntity;
    property Count: Integer read fItems.Count;
    property Items: List<T> read fItems;
    property Item[Index: Integer]: T read fItems[Index]; default;
  end;

end.