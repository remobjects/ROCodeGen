namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

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

  RodlEventSink = public partial class
  public
    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveGuidToJson(node, "ID", DefaultInterface.EntityID);
      SaveStringToJson(node, "Ancestor", AncestorName);
      if &Abstract ≠ def_Abstract then
        SaveBooleanToJson(node, "Abstract", Abstract);
      if DontCodegen ≠ def_DontCodegen then
        SaveBooleanToJson(node, "DontCodeGen", DontCodegen);
      if IsFromUsedRodl then
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);
      SaveAttributesToJson(node);
      DefaultInterface.SaveToJson(node, "Operations", flattenUsedRODLs);
    end;
  end;

  RodlService = public partial class
  private
    const def_Private: Boolean = false;
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

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveGuidToJson(node, "ID", DefaultInterface.EntityID);
      SaveStringToJson(node, "ImplUnit", ImplUnit);
      SaveStringToJson(node, "ImplClass", ImplClass);
      SaveStringToJson(node, "Ancestor", AncestorName);
      if &Abstract ≠ def_Abstract then
        SaveBooleanToJson(node, "Abstract", &Abstract);

      if &Private ≠ def_Private then
        SaveBooleanToJson(node, "Private", &Private);

      if IsFromUsedRodl then
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);

      if DontCodegen ≠ def_DontCodegen then
        SaveBooleanToJson(node, "DontCodeGen", DontCodegen);

      fRoles.SaveToJson(node);
      SaveAttributesToJson(node);
      DefaultInterface.SaveToJson(node, "Operations", flattenUsedRODLs);
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

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Delphi", DelphiModule);
      SaveStringToJson(node, ".NET", NetModule);
      SaveStringToJson(node, "ObjC", ObjCModule);
      SaveStringToJson(node, "Java", JavaModule);
      SaveStringToJson(node, "JavaScript", JavaScriptModule);
      SaveStringToJson(node, "Toffee", CocoaModule);
      SaveStringToJson(node, "Swift", SwiftModule);
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
  private
    const def_ForceAsyncResponse: Boolean = false;
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

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      if ForceAsyncResponse ≠ def_ForceAsyncResponse then
        SaveBooleanToJson(node, "ForceAsyncResponse", ForceAsyncResponse);
      fRoles.SaveToJson(node);
      SaveAttributesToJson(node);
      try
        if assigned(self.Result) then
          Items.Insert(0, self.Result);
        inherited SaveToJson(node, "Parameters", flattenUsedRODLs);
      finally
        if assigned(self.Result) then
          Items.Remove(self.Result);
      end;
    end;

  end;

  RodlParameter = public partial class
  private
    const def_ParamFlag: ParamFlags = ParamFlags.In;
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

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveStringToJson(node, "DataType", DataType);

      if IsFromUsedRodl then
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);

      if ParamFlag ≠ def_ParamFlag then
        SaveStringToJson(node, "Flag", ParamFlag.ToString());

      SaveAttributesToJson(node);
    end;
  end;

end.