namespace RemObjects.SDK.CodeGen4;

type
  RodlRoles = public partial class
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
  end;

end.