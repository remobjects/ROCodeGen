﻿namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  RodlEnum = public partial class(RodlComplexEntity<RodlEnumValue>)
  public
    constructor;
    begin
      inherited constructor("EnumValue", "Values");
    end;

    property PrefixEnumValues: Boolean;
    property DefaultValueName: String read if Count > 0 then Item[0].Name;
  end;

  RodlEnumValue = public partial class(RodlEntity)
  end;

  RodlArray = public partial class(RodlEntity)
  public
    property ElementType: String;
    method Validate; override;
    begin
      inherited;
      if RodlLibrary.IsInternalType(ElementType) then exit;
      if OwnerLibrary:FindEntity(ElementType) = nil then raise new Exception($'Invalid or undefined element type ({self.ElementType}) is used in {self.GetFullName}');
    end;
  end;

  RodlStructEntity = public partial abstract class (RodlComplexEntity<RodlField>)
  public
    constructor;
    begin
      inherited constructor("Element");
    end;

    property AutoCreateProperties: Boolean := true;
  end;

  RodlStruct = public class(RodlStructEntity)
  end;

  RodlException = public class(RodlStructEntity)
  end;

  RodlField = public class(RodlTypedEntity)
  end;

end.