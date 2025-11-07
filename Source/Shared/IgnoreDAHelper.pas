namespace RemObjects.SDK.CodeGen4;

type
  IgnoreDAHelper = static public class
  private
    const gDA_RODL = new Guid("{DC8B7BE2-14AF-402D-B1F8-E1008B6FA4F6}");
    const gDA_Simple_RODL = new Guid("{367FA81F-09B7-4294-85AD-68C140EF1FA7}");
    const gDA_DataAbstractService = new Guid("{4C2EC238-4FB4-434E-8CFF-ED25EEFF1525}");
    const gDA_SimpleDataAbstractService = new Guid("{34F94CE3-8008-4662-9E02-9B1CE91B5B33}");

    class method IsDAGuid(aUseID: Guid): Boolean;
    begin
      exit (aUseID = gDA_RODL) or (aUseID = gDA_Simple_RODL);
    end;

    class method IsDAUses(aUse: RodlUse): Boolean;
    begin
      exit IsDAGuid(aUse.UsedRodlId);
    end;

    class method IsDataAbstractService(aEntity: RodlEntity): Boolean;
    begin
      exit assigned(aEntity) and
           (aEntity.Name = "DataAbstractService") and
           (aEntity.EntityID = gDA_DataAbstractService);
    end;

    class method IsSimpleDataAbstractService(aEntity: RodlEntity): Boolean;
    begin
      exit assigned(aEntity) and
           (aEntity.Name = "SimpleDataAbstractService") and
           (aEntity.EntityID = gDA_SimpleDataAbstractService);
    end;


    class method AddType(lib: RodlLibrary; aEntity: RodlEntity; List: List<RodlEntity>);
    begin
      List.Add(aEntity);

      if aEntity is RodlArray then
        CheckType(lib, RodlArray(aEntity).ElementType, List)
      else if (aEntity is RodlStruct) or (aEntity is RodlException) then begin
        for each f in RodlStructEntity(aEntity).Items do
          CheckType(lib, f.DataType, List)
      end;
    end;

    class method IsDAGuid(aEntity: RodlEntity): Boolean;
    begin
      if assigned(aEntity) and aEntity.IsFromUsedRodl then begin
        var g := if assigned(aEntity.FromUsedRodl) then
                   aEntity.FromUsedRodl.UsedRodlId
                  else
                   aEntity.FromUsedRodlId;
        exit IsDAGuid(g);
      end
      else
        exit false;
    end;

    class method CheckType(lib: RodlLibrary; aType: String; List: List<RodlEntity>);
    begin
      var dt := lib.FindEntity(aType);
      if IsDAGuid(dt) then
        if not List.Contains(dt) then begin
          AddType(lib, dt, List);
        end;
    end;

  public
    class method RemoveDA(lib: RodlLibrary; aInline: Boolean := false): RodlLibrary;
    begin
      var lresult: RodlLibrary;
      if aInline then begin
        lresult := lib;
      end
      else begin
        lresult := new RodlLibrary();
        lresult.LoadFromString(lib.ToJsonString);
      end;

      if lresult.Uses.Count = 0 then exit lresult;
      var isDADetected := false;
      for each u in lresult.Uses.Items do begin
        isDADetected := IsDAUses(u);
        if isDADetected then break;
      end;
      if not isDADetected then exit lresult;
      for i := 0 to lresult.Services.Items.Count - 1 do begin
        var s := lresult.Services.Items[i];
        if not String.IsNullOrEmpty(s.AncestorName) then begin
          var ae := s.AncestorEntity;
          // step1. remove "DataAbstractService"/"SimpleDataAbstractService" ancestor
          if IsDataAbstractService(ae) or IsSimpleDataAbstractService(ae) then begin
            s.AncestorName := nil;
          end
          else begin
            // duplicate logic of login services
            if ae.IsFromUsedRodl then begin
              var g := if assigned(ae.FromUsedRodl) then
                         ae.FromUsedRodl.UsedRodlId
                        else
                         ae.FromUsedRodlId;
              if IsDAGuid(g) then begin
                var it := s.GetAllOperations;
                s.DefaultInterface.Items.RemoveAll;
                s.DefaultInterface.Items.Add(it);
                s.AncestorName := nil;
              end;
            end;
          end;
        end;
      end;

      var lusedEntitles := new List<RodlEntity>;
      for each s in lresult.Services.Items do begin
        if IsDAGuid(s) then continue;
        for each op in s.GetAllOperations do begin
          for each p in op.Items do
            CheckType(lresult, p.DataType, lusedEntitles);
          if assigned(op.Result) then
            CheckType(lresult, op.Result.DataType, lusedEntitles);
        end;
      end;

      for each s in lresult.EventSinks.Items do begin
        if IsDAGuid(s) then continue;
        for each op in s.GetAllOperations do
          for each p in op.Items do
            CheckType(lresult, p.DataType, lusedEntitles);
      end;

      for each ar in lresult.Arrays.Items do begin
        if IsDAGuid(ar) then continue;
        CheckType(lresult, ar.ElementType, lusedEntitles);
      end;

      for each str in lresult.Structs.Items do begin
        if IsDAGuid(str) then continue;
        for each f in str.Items do
          CheckType(lresult, f.DataType, lusedEntitles);
        if assigned(str.AncestorName) then
          CheckType(lresult, str.AncestorName, lusedEntitles);
      end;

      for each str in lresult.Exceptions.Items do begin
        if IsDAGuid(str) then continue;
        for each f in str.Items do
          CheckType(lresult, f.DataType, lusedEntitles);
        if assigned(str.AncestorName) then
          CheckType(lresult, str.AncestorName, lusedEntitles);
      end;

      for each it in lusedEntitles do begin
        it.FromUsedRodl := nil;
        it.FromUsedRodlId := nil;
      end;

      for each u:RodlUse in lresult.Uses.Items.ToList do
        if IsDAUses(u) then
          lresult.Uses.Items.Remove(u);

      for each it in lresult.Arrays.Items.ToList do
        if IsDAGuid(it) then lresult.Arrays.Items.Remove(it);
      for each it in lresult.Enums.Items.ToList do
        if IsDAGuid(it) then lresult.Enums.Items.Remove(it);
      for each it in lresult.Exceptions.Items.ToList do
        if IsDAGuid(it) then lresult.Exceptions.Items.Remove(it);
      for each it in lresult.Structs.Items.ToList do
        if IsDAGuid(it) then lresult.Structs.Items.Remove(it);
      for each it in lresult.EventSinks.Items.ToList do
        if IsDAGuid(it) then lresult.EventSinks.Items.Remove(it);
      for each it in lresult.Services.Items.ToList do
        if IsDAGuid(it) then lresult.Services.Items.Remove(it);
      exit lresult;
    end;
  end;

end.