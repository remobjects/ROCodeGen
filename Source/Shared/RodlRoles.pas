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

  RodlRoles = public partial class
  private
    fRoles: List<RodlRole> := new List<RodlRole>;
  public
    method Clear;
    begin
      fRoles.RemoveAll;
    end;

    property Roles:List<RodlRole> read fRoles;
    property Role[index : Integer]: RodlRole read fRoles[index];
  end;

end.