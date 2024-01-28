namespace RemObjects.SDK.CodeGen4;

uses
  RemObjects.Elements.RTL;

type
  RodlLibrary = public partial class (RodlEntity)
  private
     const def_DataSnap: Boolean = false;
     const def_ScopedEnums: Boolean = false;
     const CONST_RODL_VERSION_JSON: String = "4.0"; public;
  private

    method SaveEntityCollectionToJson<T>(node: JsonObject; name: String; Coll: EntityCollection<T>; flattenUsedRODLs: Boolean);
      where T is RodlEntity;
    begin
      if Coll.Count > 0 then
        Coll.SaveToJson(node, name, flattenUsedRODLs);
    end;

  public
    constructor (node: JsonNode);
    begin
      constructor;
      LoadFromJsonNode(node, nil);
    end;

    method LoadFromJsonNode(node: JsonNode; use: RodlUse := nil);
    begin
      if not assigned(use) then begin
        inherited LoadFromJsonNode(node);
        &Namespace := node["Namespace"]:StringValue;
        DataSnap := valueOrDefault(node["DataSnap"]:BooleanValue);
        ScopedEnums := valueOrDefault(node["ScopedEnums"]:BooleanValue);
        DontApplyCodeGen := valueOrDefault(node["SkipCodeGen"]:BooleanValue) or
                            valueOrDefault(node["DontCodeGen"]:BooleanValue);

        var lIncludes := coalesce(node["Includes"], node["Platforms"]);
        if assigned(lIncludes) then begin
          Includes := new RodlInclude();
          Includes.LoadFromJsonNode(lIncludes);
        end
        else begin
          Includes := nil;
        end;
      end
      else begin
        use.Name := node["Name"]:StringValue;
        use.UsedRodlId := Guid.TryParse(node["ID"]:StringValue);
        use.DontApplyCodeGen := use.DontApplyCodeGen or
                                valueOrDefault(node["SkipCodeGen"]:BooleanValue) or
                                valueOrDefault(node["DontCodeGen"]:BooleanValue);
        use.Namespace := node["Namespace"]:StringValue;

        var lIncludes := coalesce(node["Includes"], node["Platforms"]);
        if assigned(lIncludes) then begin
          use.Includes := new RodlInclude();
          use.Includes.LoadFromJsonNode(lIncludes);
        end;
        if isUsedRODLLoaded(use) then exit;
      end;

      fUses.LoadFromJsonNode(node["Uses"], use, -> new RodlUse);
      fStructs.LoadFromJsonNode(node["Structs"], use, -> new RodlStruct);
      fArrays.LoadFromJsonNode(node["Arrays"], use, -> new RodlArray);
      fEnums.LoadFromJsonNode(node["Enums"], use, -> new RodlEnum);
      fExceptions.LoadFromJsonNode(node["Exceptions"], use, -> new RodlException);
      fGroups.LoadFromJsonNode(node["Groups"], use, -> new RodlGroup);
      fServices.LoadFromJsonNode(node["Services"], use, -> new RodlService);
      fEventSinks.LoadFromJsonNode(node["EventSinks"], use, -> new RodlEventSink);
    end;

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveStringToJson(node, "Namespace", &Namespace);
      SaveGuidToJson(node, "ID", EntityID);
      if DontApplyCodeGen ≠ def_DontCodegen then
        SaveBooleanToJson(node, "SkipCodeGen", DontApplyCodeGen);

      if DataSnap ≠ def_DataSnap then
        SaveBooleanToJson(node, "DataSnap", DataSnap);

      if ScopedEnums ≠ def_ScopedEnums then
        SaveBooleanToJson(node, "ScopedEnums", ScopedEnums);

      SaveStringToJson(node, "Version", CONST_RODL_VERSION_JSON);

      SaveAttributesToJson(node);

      if assigned(Includes) then begin
        var l_Includes := new JsonObject();
        Includes.SaveToJson(l_Includes, flattenUsedRODLs);
        SaveObjectToJson(node, "Includes", l_Includes);
      end;
      SaveEntityCollectionToJson(node, "Groups", fGroups, flattenUsedRODLs);
      SaveEntityCollectionToJson(node, "Services", fServices, flattenUsedRODLs);
      SaveEntityCollectionToJson(node, "EventSinks", fEventSinks, flattenUsedRODLs);
      SaveEntityCollectionToJson(node, "Structs", fStructs, flattenUsedRODLs);
      SaveEntityCollectionToJson(node, "Enums", fEnums, flattenUsedRODLs);
      SaveEntityCollectionToJson(node, "Arrays", fArrays, flattenUsedRODLs);
      SaveEntityCollectionToJson(node, "Uses", fUses, flattenUsedRODLs);
      SaveEntityCollectionToJson(node, "Exceptions", fExceptions, flattenUsedRODLs);
    end;

    method ToJsonString(flattenUsedRODLs: Boolean := true): String;
    begin
      var lJson := new JsonObject;
      SaveToJson(lJson, flattenUsedRODLs);
      exit lJson.ToString;
    end;

    method SaveToJsonFile(aFileName: String; flattenUsedRODLs: Boolean);
    begin
      File.WriteText(aFileName, ToJsonString(flattenUsedRODLs), Encoding.UTF8);
    end;
  end;

  RodlUse = public partial class
  public
    method LoadFromJsonNode(node: JsonNode); override;
    begin
      inherited LoadFromJsonNode(node);

      var lIncludes := coalesce(node["Includes"], node["Platforms"]);
      if assigned(lIncludes) then begin
        Includes := new RodlInclude();
        Includes.LoadFromJsonNode(lIncludes);
      end
      else begin
        Includes := nil;
      end;

      FileName := node["Rodl"]:StringValue;
      AbsoluteRodl := node["AbsoluteRodl"]:StringValue;
      UsedRodlId := Guid.TryParse(node["UsedRodlID"]:StringValue);
      DontApplyCodeGen := valueOrDefault(node["DontCodeGen"]:BooleanValue);
      DontCodegen := DontApplyCodeGen;
      if node["Merged"]:BooleanValue then begin
        Loaded := true;
        exit;
      end;
      var usedRodlFileName: String := Path.GetFullPath(FileName);
      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (OwnerLibrary.Filename ≠ nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(Path.GetFullPath(OwnerLibrary.Filename).ParentDirectory, FileName));
      end;

      if (not usedRodlFileName.FileExists and not FileName.IsAbsolutePath) then begin
        if (FromUsedRodl:AbsoluteFileName ≠ nil) then
          usedRodlFileName := Path.GetFullPath(Path.Combine(FromUsedRodl:AbsoluteFileName:ParentDirectory, FileName));
      end;


      if (not usedRodlFileName.FileExists) then usedRodlFileName := AbsoluteRodl;
      if String.IsNullOrEmpty(usedRodlFileName) then Exit;
      if (not usedRodlFileName.FileExists) then begin
        usedRodlFileName := usedRodlFileName.Replace("/", Path.DirectorySeparatorChar).Replace("\", Path.DirectorySeparatorChar);
        var lFilename := Path.GetFileName(usedRodlFileName).ToLowerInvariant;
        //writeLn("checking for "+lFilename);
        if RodlCodeGen.KnownRODLPaths.ContainsKey(lFilename) then
          usedRodlFileName := RodlCodeGen.KnownRODLPaths[lFilename].Replace("/", Path.DirectorySeparatorChar).Replace("\", Path.DirectorySeparatorChar);
      end;

      //writeLn("using rodl: "+usedRodlFileName);

      if (usedRodlFileName.FileExists) then begin
        AbsoluteFileName := usedRodlFileName;
        OwnerLibrary.LoadUsedLibraryFromFile(usedRodlFileName, self);
        Loaded := true;
      end;

    end;

    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveStringToJson(node, "Rodl", FileName);
      SaveStringToJson(node, "AbsoluteRodl", AbsoluteRodl);
      if DontApplyCodeGen ≠ def_DontCodegen then
        SaveBooleanToJson(node, "DontCodeGen", DontApplyCodeGen);

      if IsMerged and flattenUsedRODLs then
        SaveBooleanToJson(node, "Merged", true);

      SaveGuidToJson(node, "UsedRodlID", UsedRodlId);
      if assigned(Includes) then begin
        var l_Includes := new JsonObject();
        Includes.SaveToJson(l_Includes, flattenUsedRODLs);
        SaveObjectToJson(node, "Includes", l_Includes);
      end;
    end;

  end;

  RodlGroup = public partial class
  public
    method SaveToJson(node: JsonObject; flattenUsedRODLs: Boolean); override;
    begin
      SaveStringToJson(node, "Name", Name);
      SaveGuidToJson(node, "ID", EntityID);
      if IsFromUsedRodl then
        SaveGuidToJson(node, "FromUsedRodlID", FromUsedRodlId);
      SaveAttributesToJson(node);
    end;

  end;

end.