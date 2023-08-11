namespace RemObjects.SDK.CodeGen4;

type
  RodlRoles = public partial class
  public
    method LoadFromJsonNode(node: JsonNode);
    begin
      for each lItem in node['DenyRoles'] as JsonArray do
        fRoles.Add(new RodlRole(lItem:StringValue, true));
      for each lItem in node['AllowRoles'] as JsonArray do
        fRoles.Add(new RodlRole(lItem:StringValue, false));
    end;

    method SaveToJson(node: JsonObject);
    begin
      if fRoles.Count = 0 then
        exit;

      var l_allowRoles := new JsonArray();
      var l_denyRoles := new JsonArray();

      for each role: RodlRole in fRoles do begin
        var l_role := role.Role;
        if role.Not then
          l_denyRoles.Add([l_role])
        else
          l_allowRoles.Add([l_role]);
      end;

      if l_allowRoles.Count > 0 then
        node["AllowRoles"] := l_allowRoles;

      if l_denyRoles.Count > 0 then
        node["DenyRoles"] := l_denyRoles;
    end;

  end;

end.