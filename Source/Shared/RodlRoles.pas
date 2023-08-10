namespace RemObjects.SDK.CodeGen4;

type
  RodlRole = public class
  public
    constructor; empty;
    constructor(aRole: String; aNot: Boolean);
    begin
      Role := aRole;
      &Not := aNot;
    end;

    property Role: String;
    property &Not: Boolean;
  end;

  RodlRoles = public class
  private
    fRoles: List<RodlRole> := new List<RodlRole>;
  public

    method LoadFromXmlNode(node: XmlElement);
    begin
      var el := node.FirstElementWithName("Roles") as XmlElement;

      if (el = nil) or (el.Elements.Count = 0) then exit;

      for each lItem in el.Elements do begin
        if (lItem.LocalName = "DenyRole") then fRoles.Add(new RodlRole(lItem.Value, true))
        else if (lItem.LocalName = "AllowRole") then fRoles.Add(new RodlRole(lItem.Value, false));
      end;
    end;

    method LoadFromJsonNode(node: JsonNode);
    begin
      for each lItem in node['DenyRoles'] as JsonArray do
        fRoles.Add(new RodlRole(lItem:StringValue, true));
      for each lItem in node['AllowRoles'] as JsonArray do
        fRoles.Add(new RodlRole(lItem:StringValue, false));
    end;

    method Clear;
    begin
      fRoles.RemoveAll;
    end;

    property Roles:List<RodlRole> read fRoles;
    property Role[index : Integer]: RodlRole read fRoles[index];
  end;

end.