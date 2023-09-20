namespace RemObjects.SDK.CodeGen4;

type
  RodlLibrary = public partial class (RodlEntity)
  private
    method LoadXML(aFile: String): XmlDocument;
    begin
      exit XmlDocument.FromFile(aFile);
    end;
  public
    constructor (node: XmlElement);
    begin
      constructor;
      LoadFromXmlNode(node, nil);
    end;

    method LoadFromXmlNode(node: XmlElement; use: RodlUse := nil);
    begin
      if use = nil then begin
        inherited LoadFromXmlNode(node);
        if (node.Attribute["Namespace"] ≠ nil) then
          &Namespace := node.Attribute["Namespace"].Value;
        if (node.Attribute["DataSnap"] ≠ nil) then
          DataSnap := node.Attribute["DataSnap"].Value = "1";
        if (node.Attribute["ScopedEnums"] ≠ nil) then
          ScopedEnums := node.Attribute["ScopedEnums"].Value = "1";
        DontApplyCodeGen := ((node.Attribute["SkipCodeGen"] ≠ nil) and (node.Attribute["SkipCodeGen"].Value = "1")) or
                            ((node.Attribute["DontCodeGen"] ≠ nil) and (node.Attribute["DontCodeGen"].Value = "1"));

        var lInclude := node.FirstElementWithName("Includes");
        if (lInclude ≠ nil) then begin
          Includes := new RodlInclude();
          Includes.LoadFromXmlNode(lInclude);
        end
        else begin
          Includes := nil;
        end;
      end
      else begin
        use.Name := node.Attribute["Name"]:Value;
        use.UsedRodlId := Guid.TryParse(node.Attribute["UID"].Value);
        use.DontApplyCodeGen := use.DontApplyCodeGen or
                      (((node.Attribute["SkipCodeGen"] ≠ nil) and (node.Attribute["SkipCodeGen"].Value = "1")) or
                       ((node.Attribute["DontCodeGen"] ≠ nil) and (node.Attribute["DontCodeGen"].Value = "1")));
        if (node.Attribute["Namespace"] ≠ nil) then use.Namespace := node.Attribute["Namespace"].Value;

        var lInclude := node.FirstElementWithName("Includes");
        if (lInclude ≠ nil) then begin
          use.Includes := new RodlInclude();
          use.Includes.LoadFromXmlNode(lInclude);
        end;
        if isUsedRODLLoaded(use) then exit;
      end;

      fUses.LoadFromXmlNode(node.FirstElementWithName("Uses"), use, -> new RodlUse);
      fStructs.LoadFromXmlNode(node.FirstElementWithName("Structs"), use, -> new RodlStruct);
      fArrays.LoadFromXmlNode(node.FirstElementWithName("Arrays"), use, -> new RodlArray);
      fEnums.LoadFromXmlNode(node.FirstElementWithName("Enums"), use, -> new RodlEnum);
      fExceptions.LoadFromXmlNode(node.FirstElementWithName("Exceptions"), use, -> new RodlException);
      fGroups.LoadFromXmlNode(node.FirstElementWithName("Groups"), use, -> new RodlGroup);
      fServices.LoadFromXmlNode(node.FirstElementWithName("Services"), use, -> new RodlService);
      fEventSinks.LoadFromXmlNode(node.FirstElementWithName("EventSinks"), use, -> new RodlEventSink);
    end;
  end;

  RodlUse = public partial class
  public
    method LoadFromXmlNode(node: XmlElement); override;
    begin
      inherited LoadFromXmlNode(node);

      var lInclude: XmlElement := node.FirstElementWithName("Includes");
      if assigned(lInclude) then begin
        Includes := new RodlInclude();
        Includes.LoadFromXmlNode(lInclude);
      end
      else begin
        Includes := nil;
      end;

      if (node.Attribute["Rodl"] ≠ nil) then
        FileName := node.Attribute["Rodl"].Value;

      if (node.Attribute["AbsoluteRodl"] ≠ nil) then
        AbsoluteRodl := node.Attribute["AbsoluteRodl"].Value;

      if (node.Attribute["UsedRodlUID"] ≠ nil) then
        UsedRodlId := Guid.TryParse(node.Attribute["UsedRodlUID"].Value);

      DontApplyCodeGen := (node.Attribute["DontCodeGen"] ≠ nil) and (node.Attribute["DontCodeGen"].Value = "1");
      if node.Attribute["Merged"]:Value = "1" then begin
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