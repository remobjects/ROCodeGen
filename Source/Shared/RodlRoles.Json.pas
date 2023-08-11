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
  end;

end.