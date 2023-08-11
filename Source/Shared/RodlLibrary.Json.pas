namespace RemObjects.SDK.CodeGen4;

type
  RodlLibrary = public partial class (RodlEntity)
  private
    fJsonNode: JsonNode; // only for supporting SaveToFile
  public
    constructor (node: JsonNode);
    begin
      constructor;
      LoadFromJsonNode(node, nil);
    end;

    method LoadFromJsonNode(node: JsonNode; use: RodlUse := nil);
    begin
      if not assigned(use) then begin
        fJsonNode := node; // needs to be kept in scope
        inherited LoadFromJsonNode(node);
        &Namespace := node["Namespace"]:StringValue;
        DataSnap := valueOrDefault(node["DataSnap"]:BooleanValue);
        ScopedEnums := valueOrDefault(node["ScopedEnums"]:BooleanValue);
        DontApplyCodeGen := valueOrDefault(node["SkipCodeGen"]:BooleanValue) or valueOrDefault(node["DontCodeGen"]:BooleanValue);

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
        use.DontApplyCodeGen := valueOrDefault(node["SkipCodeGen"]:BooleanValue) or valueOrDefault(node["DontCodeGen"]:BooleanValue);
        use.Namespace := node["Namespace"]:StringValue;

        var lIncludes := coalesce(node["Includes"], node["Platforms"]);
        if assigned(lIncludes) then begin
          Includes := new RodlInclude();
          Includes.LoadFromJsonNode(lIncludes);
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
          usedRodlFileName := RodlCodeGen.KnownRODLPaths[lFilename];
      end;

      //writeLn("using rodl: "+usedRodlFileName);

      if (usedRodlFileName.FileExists) then begin
        AbsoluteFileName := usedRodlFileName;
        OwnerLibrary.LoadUsedLibraryFromFile(usedRodlFileName, self);
        Loaded := true;
      end;

    end;
  end;

end.