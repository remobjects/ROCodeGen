namespace RemObjects.SDK.CodeGen4;

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

  RodlEnumValue = public class(RodlEntity)
  end;

  RodlArray = public partial class(RodlEntity)
  public
    property ElementType: String;
  end;

  RodlStructEntity = public partial abstract class (RodlComplexEntity<RodlField>)
  public
    constructor;
    begin
      inherited constructor("Element");
    end;

    property AutoCreateProperties: Boolean := False;
  end;

  RodlStruct = public class(RodlStructEntity)
  end;

  RodlException = public class(RodlStructEntity)
  end;

  RodlField = public class(RodlTypedEntity)
  end;

end.