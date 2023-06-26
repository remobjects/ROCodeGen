namespace RemObjects.SDK.CodeGen4;

type
  RodlServiceEntity = public abstract class (RodlComplexEntity<RodlInterface>)
  public

    constructor;
    begin
      inherited constructor("Interface");
    end;

    property DefaultInterface: RodlInterface read if Count > 0 then Item[0];

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, -> new RodlInterface);
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      var lDefaultInterface := new RodlInterface;
      lDefaultInterface.LoadFromJsonNode(node);
      Items.Add(lDefaultInterface);
      //LoadFromJsonNode(node, -> new RodlInterface);
    end;

  end;

  RodlEventSink = public class(RodlServiceEntity)
  end;

  RodlService = public class(RodlServiceEntity)
  private
    fRoles := new RodlRoles();

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

  //
  //
  //

  RodlInclude = public class(RodlEntity)
  private

    method LoadAttribute(node:XmlElement; aName:String):String;
    begin
      exit iif(node.Attribute[aName] <> nil, node.Attribute[aName].Value, "");
    end;

  public

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);

      DelphiModule := node.Attribute["Delphi"]:Value;
      NetModule := node.Attribute["DotNet"]:Value;
      ObjCModule := node.Attribute["ObjC"]:Value;
      JavaModule := node.Attribute["Java"]:Value;
      JavaScriptModule := node.Attribute["JavaScript"]:Value;
      CocoaModule := node.Attribute["Cocoa"]:Value;
      //backward compatibility
      if String.IsNullOrEmpty(CocoaModule) then
        CocoaModule := node.Attribute["Nougat"]:Value;
      if String.IsNullOrEmpty(CocoaModule) then
        CocoaModule := node.Attribute["Toffee"]:Value;
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

  RodlInterface = public class(RodlComplexEntity<RodlOperation>)
  private
  public
    constructor;
    begin
      inherited constructor("Operation");
    end;

    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, ->new RodlOperation);
    end;

    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      LoadFromJsonNode(node, -> new RodlOperation);
    end;

  end;

  RodlOperation = public class(RodlComplexEntity<RodlParameter>)
  private
    fRoles: RodlRoles := new RodlRoles();
  public
    constructor;
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

end.