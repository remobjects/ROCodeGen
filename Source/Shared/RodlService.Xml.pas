namespace RemObjects.SDK.CodeGen4;

type
  RodlServiceEntity = public partial abstract class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, -> new RodlInterface);
    end;
  end;

  RodlService = public partial class
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
  end;

  RodlInclude = public partial class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);
      DelphiModule := node.Attribute["Delphi"]:Value;
      NetModule := node.Attribute["DotNet"]:Value;
      ObjCModule := node.Attribute["ObjC"]:Value;
      JavaModule := node.Attribute["Java"]:Value;
      JavaScriptModule := node.Attribute["JavaScript"]:Value;
      CocoaModule := coalesce(node.Attribute["Cocoa"]:Value, node.Attribute["Nougat"]:Value, node.Attribute["Toffee"]:Value);
      SwiftModule := node.Attribute["Swift"]:Value;
    end;
  end;

  RodlInterface = public partial class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node, ->new RodlOperation);
    end;
  end;

  RodlOperation = public partial class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      LoadFromXmlNode(node,->new RodlParameter);
      fRoles.Clear;
      fRoles.LoadFromXmlNode(node);
      if (node.Attribute["ForceAsyncResponse"] ≠ nil) then ForceAsyncResponse := node.Attribute["ForceAsyncResponse"].Value = "1";

      for parameter: RodlParameter in Items do
        if parameter.ParamFlag = ParamFlags.Result then self.Result := parameter;
      Items.Remove(self.Result);
    end;
  end;

  RodlParameter = public partial class
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
  end;

end.