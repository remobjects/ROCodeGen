namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

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

    [ToString]
    method ToString: String;
    begin
      exit (if self.&Not then "!" else "") + self.Role;
    end;
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