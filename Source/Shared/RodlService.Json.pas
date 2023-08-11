namespace RemObjects.SDK.CodeGen4;

type
  RodlServiceEntity = public partial abstract class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      var lDefaultInterface := new RodlInterface;
      lDefaultInterface.LoadFromJsonNode(node);
      lDefaultInterface.Owner := self;
      Items.Add(lDefaultInterface);
      //LoadFromJsonNode(node, -> new RodlInterface);
    end;
  end;

  RodlService = public partial class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      fRoles.Clear;
      fRoles.LoadFromJsonNode(node);
      &Private := valueOrDefault(node["Private"]:BooleanValue);
      ImplClass := node["ImplClass"]:StringValue;
      ImplUnit := node["ImplUnit"]:StringValue;
    end;
  end;

  RodlInclude = public partial class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      DelphiModule := node["Delphi"]:StringValue;
      NetModule := coalesce(node[".NET"]:StringValue, node[".Net"]:StringValue, node["DotNet"]:StringValue);
      ObjCModule := node["ObjC"]:StringValue;
      JavaModule := node["Java"]:StringValue;
      JavaScriptModule := node["JavaScript"]:StringValue;
      CocoaModule := coalesce(node["Cocoa"]:StringValue, node["Nougat"]:StringValue, node["Toffee"]:StringValue);
      SwiftModule := node["Swift"]:StringValue;
    end;
  end;

  RodlInterface = public partial class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);
      LoadFromJsonNode(node, -> new RodlOperation);
    end;
  end;

  RodlOperation = public partial class
  public
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
  end;

  RodlParameter = public partial class
  public
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
  end;

end.