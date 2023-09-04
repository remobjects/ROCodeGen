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
  public
    constructor;
    begin
      inherited constructor("Parameter");
    end;

    property Roles: RodlRoles read fRoles;
    property &Result: RodlParameter;
    property ForceAsyncResponse: Boolean := false;
  end;

  RodlParameter = public partial class(RodlTypedEntity)
  public
    property ParamFlag: ParamFlags;
  end;

end.