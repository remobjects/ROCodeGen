namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  RodlServiceEntity = public partial abstract class (RodlComplexEntity<RodlInterface>)
  public
    constructor;
    begin
      inherited constructor("Interface");
    end;

    property DefaultInterface: RodlInterface read if Count > 0 then Item[0];

    method GetInheritedOperations: List<RodlOperation>;
    begin
      var lancestor := AncestorEntity;
      if assigned(lancestor) and (lancestor is RodlServiceEntity) and assigned(RodlServiceEntity(lancestor).DefaultInterface) then begin
        result := RodlServiceEntity(lancestor).GetInheritedOperations;
        result.Add(RodlServiceEntity(lancestor).DefaultInterface.Items);
      end
      else begin
        result := new List<RodlOperation>;
      end;
    end;

    method GetAllOperations: List<RodlOperation>;
    begin
      result := GetInheritedOperations;
      if assigned(DefaultInterface) then
        result.Add(DefaultInterface.Items);
    end;

  end;

  RodlEventSink = public partial class(RodlServiceEntity)
  end;

  RodlService = public partial class(RodlServiceEntity)
  private
    fRoles := new RodlRoles();
  public
    property Roles: RodlRoles read fRoles;
    property ImplUnit:String;
    property ImplClass:String;
    property &Private: Boolean;
    property RequireSession: Boolean;
  end;

  RodlInclude = public partial class(RodlEntity)
  private
    method LoadAttribute(node:XmlElement; aName:String):String;
    begin
      exit iif(node.Attribute[aName] ≠ nil, node.Attribute[aName].Value, "");
    end;
  public
    property DelphiModule: String;
    property JavaModule: String;
    property JavaScriptModule: String;
    property NetModule: String;
    property CocoaModule: String;
    property ObjCModule: String;
    property SwiftModule: String;
  end;

  RodlInterface = public partial class(RodlComplexEntity<RodlOperation>)
  private
  public
    constructor;
    begin
      inherited constructor("Operation");
    end;
  end;

  RodlOperation = public partial class(RodlComplexEntity<RodlParameter>)
  private
    fRoles: RodlRoles := new RodlRoles();
    fCode: Dictionary<String, String> := new Dictionary<String, String>();
  public
    constructor;
    begin
      inherited constructor("Parameter");
    end;

    property Roles: RodlRoles read fRoles;
    property &Result: RodlParameter;
    property ForceAsyncResponse: Boolean := false;
    property Code: Dictionary<String, String> read fCode;
  end;

  RodlParameter = public partial class(RodlTypedEntity)
  public
    property ParamFlag: ParamFlags;
  end;

end.