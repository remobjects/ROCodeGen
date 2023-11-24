import RemObjects.SDK.CodeGen4

func writeSyntax() {
	writeLn("Syntax:")
	writeLn()
	writeLn("  rodl2code <rodl> --type:<type> --platform:<platform> --language:<language>")
	writeLn("  rodl2code <rodl> --service:<name> --platform:<platform> --language:<language>")
	writeLn("  rodl2code <rodl> --services --platform:<platform> --language:<language>")
	writeLn()
	writeLn("<rodl> can be:")
	writeLn()
	writeLn("  - the path to a local .RODL file")
	writeLn("  - the path to a local .remoteRODL file")
	writeLn("  - a http:// or https:// URL for a remote server")
	writeLn()
	writeLn("Valid <type> values:")
	writeLn()
	writeLn("  - intf")
	writeLn("  - invk")
	writeLn("  - impl (same as --services)")
	writeLn("  - res")
	writeLn("  - serveraccess")
	writeLn()
	writeLn("Valid <platform> values:")
	writeLn()
	#if ECHOES
	writeLn("  - .net, net, echoes")
	#endif
	writeLn("  - cocoa, xcode, toffee")
	writeLn("  - java, cooper")
	writeLn("  - delphi, c++builder, bcb")
	writeLn("  - javascript, js")
	writeLn()
	writeLn("Valid <language> values:")
	writeLn()
	writeLn("  - oxygene, pas")
	writeLn("  - hydrogene, c#, cs")
	writeLn("  - visual-basic, visualbasic, vb, vb.net")
	writeLn("  - mercury")
	writeLn("  - silver (RemObjects Swift)")
	writeLn("  - swift (Apple Swift)")
	writeLn("  - objective-c, Objc")
	writeLn("  - delphi, pas, c++builder, cpp, c++")
	writeLn("  - iodine (RemObjects' Java)")
	writeLn("  - java (Oracle Java)")
	writeLn()
	writeLn("Additional options:")
	writeLn()
	writeLn("  --full-type-names (Currently Delphi/BCB only)")
	writeLn("  --scoped-enums (Currently Delphi/BCB only)")
	writeLn("  --legacy-strings (Delphi/BCB only)")
	writeLn("  --xe2:<on|off|auto> (Delphi only)")
	writeLn("  --fpc:<on|off|auto> (FreePascal only)")
	writeLn("  --codefirst:<on|off|auto> (Delphi only)")
	writeLn("  --genericarray:<on|off|auto> (Delphi only)")
	writeLn("  --hydra (Delphi only)")
	writeLn()
	writeLn("  --outpath:<path> (optional target folder for generated files)")
	writeLn("  --outfilename:<name> (optional base filename for generated files, w/o extension)")
	writeLn("  --no-utf8 (disable UTF-8 for IDEs from last century)")
	writeLn("  --no-bom (omit BOM from UTF-8 files; default for Java)")
	writeLn("  --namespace:<namespace> (optional namespace for generated files)")
	writeLn()

	#hint add --await
}

var fileEncoding = Encoding.UTF8
var omitBom = false

func _WriteText(_ aFileName: String, _ Content: String) {
	let b = fileEncoding.GetBytes(Content, includeBOM: !omitBom);
	File.WriteBytes(aFileName, b);
}

var options = [String:String]()

func parseParameters(_ cmdlineParams: [String]) {
	for s in cmdlineParams {
		var param: String = s
		if param.StartsWith("--") {
			param = param.Substring(2)
			var p = param.IndexOf(":")
			if p > 0 {
				var name = param.Substring(0, p)
				var value = param.Substring(p+1)
				options[name.ToLowerInvariant()] = value // retest 72610: Sugar mapping fails at runtime, trying to call the mapped method
				//(options as! NSMutableDictionary)[name] = value.ToLowerInvariant() // Parameter 1 is "String", should be "TValue", in call to NSMutableDictionary<TKey,TValue>!.setObject(anObject: TValue, forKeyedSubscript aKey: TKey)
																		  // Parameter 2 is "String!", should be "TKey", in call to NSMutableDictionary<TKey,TValue>!.setObject(anObject: TValue, forKeyedSubscript aKey: TKey)
			}
			else {
				options[param] = ""
			}
		}
	}
}

writeLn("Remoting SDK Service Interface Code Generator, based on CodeGen4 (https://github.com/remobjects/codegen4)")
writeLn()

let params = C_ARGV
parseParameters(params)

if params.count < 1 { //70956: Silver: problem with boolean short circuit
	writeSyntax()
	return 1
}
if params.count < 1 {
	//writeLn("File \(params[0]) not found")
	writeLn()
	writeSyntax()
	return 1
}

//
// Load RODL
//

var rodlFileName = params[0];
writeLn("Processing RODL file "+rodlFileName)

do {

	var isSupportedUrl =    rodlFileName.hasPrefix("http://") || rodlFileName.hasPrefix("https://")
	var isUnsupportedUrl =  rodlFileName.hasPrefix("superhttp://") || rodlFileName.hasPrefix("superhttps://") ||
							rodlFileName.hasPrefix("supertcp://") || rodlFileName.hasPrefix("supertcps://") ||
							rodlFileName.hasPrefix("tcp://") || rodlFileName.hasPrefix("tcps://") ||
							rodlFileName.hasPrefix("udp://") || rodlFileName.hasPrefix("udps://")
	if isUnsupportedUrl {
		var lUrl = Url.UrlWithString(rodlFileName)
		writeLn("Unsupported URL Scheme ("+lUrl.Scheme+")")
		writeLn()
		return 2
	}
	if !isSupportedUrl && !File.Exists(rodlFileName) {
		writeLn("File \(rodlFileName) not found")
		writeLn()
		return 2
	}

	var url = isSupportedUrl ? Url.UrlWithString(rodlFileName) : Url.UrlWithFilePath(rodlFileName)
	let rodlLibrary = RodlLibrary(URL: url)

	if options["namespace"] == nil {
		options["namespace"] = iif(!String.IsNullOrEmpty(rodlLibrary.Namespace), rodlLibrary.Namespace, "YourNamespace")
	}

	var targetRodlFileName = options["outfilename"]
	if targetRodlFileName != nil {
		rodlLibrary.Name = targetRodlFileName
		targetRodlFileName = targetRodlFileName+".rodl"
	} else {
		targetRodlFileName = isSupportedUrl ? "."+Path.DirectorySeparatorChar+rodlLibrary.Name+".rodl" : rodlFileName
	}

	if let outPath = options["outpath"] {
		targetRodlFileName = Path.Combine(outPath, Path.GetFileName(targetRodlFileName))!
		Folder.Create(Path.GetParentDirectory(targetRodlFileName))
	}

	if options["type"]?.ToLowerInvariant() == "res" {
		let resFileName = Path.ChangeExtension(targetRodlFileName, ".res")
		ResGenerator.GenerateResFile(rodlLibrary, resFileName);
		writeLn("Wrote file \(resFileName)")
		return
	}
	//
	// Check options
	//

	if options["platform"] == nil {
		writeSyntax()
		return 1
	}
	if options["type"] == nil && options["service"] == nil && options["services"] == nil {
		writeSyntax()
		return 1
	}
	if options["platform"]?.ToLowerInvariant() == "delphi" && options["language"] == nil {
		options["language"] = "delphi"
	}
	if options["platform"]?.ToLowerInvariant() == "bcb" && options["language"] == nil {
		options["language"] = "cpp"
	}
	if options["language"] == nil {
		writeSyntax()
		return 1
	}

	switch options["type"]?.ToLowerInvariant() {
		case "intf": break
		case "invk": break
		case "impl": break
		case "res": break
		case "serveraccess": break
		default:
			writeSyntax()
			writeLn("Unsupported type: "+options["type"])
			return 2
	}


	var codegen: CGCodeGenerator?

	var fileExtension = "txt"
	switch options["language"]?.ToLowerInvariant() {
		case "oxygene", "pas":
			options["language"] = "oxygene"
			codegen = CGOxygeneCodeGenerator(style: .Standard, quoteStyle: .SmartDouble)
			fileExtension = "pas"
		case "hydrogene", "csharp", "c#", "cs":
			options["language"] = "c#"
			codegen = CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Hydrogene)
			fileExtension = "cs"
		case "visual-c#", "visualcsharp", "vc#", "standard-csharp":
			options["language"] = "standard-c#"
			codegen = CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Standard)
			fileExtension = "cs"
		case "visual-basic", "visualbasic", "visualbasic.net", "vb", "vb.net":
			options["language"] = "standard-vb"
			codegen = CGVisualBasicNetCodeGenerator(dialect: CGVisualBasicCodeGeneratorDialect.Standard)
			fileExtension = "vb"
		case "mercury":
			options["language"] = "vb"
			codegen = CGVisualBasicNetCodeGenerator(dialect: CGVisualBasicCodeGeneratorDialect.Mercury)
			fileExtension = "vb"
		case "silver":
			options["language"] = "swift"
			codegen = CGSwiftCodeGenerator(dialect: CGSwiftCodeGeneratorDialect.Silver)
			fileExtension = "swift"
		case "swift", "apple-swift", "standard-swift":
			options["language"] = "standard-swift"
			codegen = CGSwiftCodeGenerator(dialect: CGSwiftCodeGeneratorDialect.Standard)
			fileExtension = "swift"
		case "objc", "objectivec", "objective-c":
			options["language"] = "objc"
			codegen = CGObjectiveCMCodeGenerator()
			fileExtension = "m"
		case "delphi":
			options["language"] = "delphi"
			options["platform"] = "delphi" // force platform to Delphi
			codegen = CGDelphiCodeGenerator()
			codegen!.splitLinesLongerThan = 200
			fileExtension = "pas"
		case "bcb", "cpp", "c++", "c++builder":
			options["language"] = "cpp"
			codegen = CGCPlusPlusCPPCodeGenerator(dialect: .CPlusPlusBuilder)
			fileExtension = "cpp"
		case "iodine":
			options["language"] = "java"
			codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Iodine)
			fileExtension = "java"
		case "java":
			if options["platform"]?.ToLowerInvariant() == "java" {
				options["language"] = "standard-java"
				omitBom = true
				codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Standard)
			} else {
				options["language"] = "java"
				codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Iodine)
			}
			fileExtension = "java"
		case "javascript", "js":
			options["language"] = "javascript"
			options["platform"] = "javascript" // force platform to JavaScript
			codegen = CGJavaScriptCodeGenerator()
			fileExtension = "js"
		default:
	}

	var serverSupport = false
	var activeRodlCodeGen: RodlCodeGen?
	var activeServerAccessCodeGen: ServerAccessCodeGen?
	switch options["platform"]?.ToLowerInvariant() {
		case "cooper", "java":
			options["platform"] = "java"
			if options["language"] == "swift" {
				options["language"] = "silver" // force our Swift
			}
			activeRodlCodeGen = JavaRodlCodeGen()
			activeServerAccessCodeGen = JavaServerAccessCodeGen(rodl: rodlLibrary)
		case "toffee", "nougat", "cocoa", "xcode", "swift": // keep Nougat, undocumdented, for backwards comopatibility
			var lAppleSwift = options["platform"]?.ToLowerInvariant() == "swift"
			options["platform"] = "cocoa"
			if options["language"]?.ToLowerInvariant() == "swift" && (options["platform"]?.ToLowerInvariant() == "toffee" || options["platform"]?.ToLowerInvariant() == "nougat") {
					options["language"] = "silver" // force our Swift
			}
			activeRodlCodeGen = CocoaRodlCodeGen()
			activeServerAccessCodeGen = CocoaServerAccessCodeGen(rodl: rodlLibrary, generator: codegen!)

			if let cocoaRodlCodeGen = activeRodlCodeGen as? CocoaRodlCodeGen {
				if lAppleSwift || options["language"] == "standard-swift" {
					cocoaRodlCodeGen.SwiftDialect = .Standard
					cocoaRodlCodeGen.FixUpForAppleSwift()
				} else {
					cocoaRodlCodeGen.SwiftDialect = .Silver
				}
			}

		case "echoes", "net", ".net":
			options["platform"] = ".net"
			serverSupport = true
			#if ECHOES
			activeRodlCodeGen = EchoesCodeDomRodlCodeGen()
			activeServerAccessCodeGen = NetServerAccessCodeGen(rodl: rodlLibrary, namespace: options["namespace"])
			#else
			//activeRodlCodeGen = DotNetRodlCodeGen()
			writeLn(".NET codegen is not supported in the Mac version of rodl2code, sorry. Use 'mono rodl2code.exe', instead.")
			return 2
			#endif
		case "delphi":
			options["platform"] = "delphi"
			options["language"] = "delphi" // force language to Delphi
			serverSupport = true
			activeRodlCodeGen = DelphiRodlCodeGen()
			activeServerAccessCodeGen = DelphiServerAccessCodeGen(rodl:rodlLibrary)
		case "bcb", "c++builder":
			options["platform"] = "bcb"
			options["language"] = "bcb" // force language to C++(Builder)
			serverSupport = true
			activeRodlCodeGen = CPlusPlusBuilderRodlCodeGen()
			activeServerAccessCodeGen = CPlusPlusBuilderServerAccessCodeGen(rodl:rodlLibrary)
		case "javascript", "js":
			options["platform"] = "javascript"
			options["language"] = "js" // force language to JavaScript
			activeRodlCodeGen = JavaScriptRodlCodeGen()
		default:
	}

	activeRodlCodeGen?.RodlFileName = Path.GetFileName(targetRodlFileName);
	if options["full-type-names"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.IncludeUnitNameForOwnTypes = true
	}
	if options["scoped-enums"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.ScopedEnums = true
	}
	if options["legacy-strings"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.LegacyStrings = true
	}
	if (options["platform"] == "delphi") {
		let lcodegen = (activeRodlCodeGen as? DelphiRodlCodeGen)?;

		if options["xe2"] != nil {
			switch options["xe2"]?.ToLowerInvariant() {
				case "on": lcodegen.DelphiXE2Mode = State.On;
				case "off": lcodegen.DelphiXE2Mode = State.Off;
				case "auto": lcodegen.DelphiXE2Mode = State.Auto;
				default:
			}
		}
		if options["fpc"] != nil {
			switch options["fpc"]?.ToLowerInvariant() {
				case "on": lcodegen.FPCMode = State.On;
				case "off": lcodegen.FPCMode = State.Off;
				case "auto": lcodegen.FPCMode = State.Auto;
				default:
			}
		}
		if options["codefirst"] != nil {
			switch options["codefirst"]?.ToLowerInvariant() {
				case "on": lcodegen.CodeFirstMode = State.On;
				case "off": lcodegen.CodeFirstMode = State.Off;
				case "auto": lcodegen.CodeFirstMode = State.Auto;
				default:
			}
		}
		if options["genericarray"] != nil {
			switch options["genericarray"]?.ToLowerInvariant() {
				case "on": lcodegen.GenericArrayMode = State.On;
				case "off": lcodegen.GenericArrayMode = State.Off;
				case "auto": lcodegen.GenericArrayMode = State.Auto;
				default:
			}
		}

		if (lcodegen.FPCMode == State.On) {
			lcodegen.DelphiXE2Mode = State.Off;
		}
		if (lcodegen.DelphiXE2Mode == State.Off) {
			lcodegen.CodeFirstMode = State.Off;
			lcodegen.GenericArrayMode = State.Off;
		}
		if (lcodegen.DelphiXE2Mode == State.On) {
			lcodegen.FPCMode = State.Off;
		}
		if (lcodegen.CodeFirstMode == State.Off) {
			lcodegen.GenericArrayMode = State.Off;
		}
	}

	if options["hydra"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.IsHydra = true
	}

	if options["no-utf8"] != nil {
		fileEncoding = Encoding.ASCII
	}
	if options["no-bom"] != nil {
		omitBom = true
	}

	func targetFileNameWithSuffix(_ suffix: String) -> String? {
		var s1 = Path.GetParentDirectory(targetRodlFileName);
		var s2 = Path.GetFileNameWithoutExtension(Path.GetFileName(targetRodlFileName))+"_"+suffix+"."+fileExtension;
		if String.IsNullOrWhiteSpace(s1) {
			return s2
		}
		else {
			return Path.Combine(s1, s2);
		}
	}

	func targetFileName(_ name: String) -> String? {
		return Path.Combine(Path.GetParentDirectory(targetRodlFileName), name)
	}

	if activeRodlCodeGen == nil {
		writeLn("Unsupported platform: "+options["platform"])
		return 2
	}
	#if ECHOES
	if let echoesRodlCodegen = activeRodlCodeGen as? EchoesCodeDomRodlCodeGen {
		echoesRodlCodegen.Language = options["language"]
		if echoesRodlCodegen.GetCodeDomProviderForLanguage() == nil {
			writeLn("No CodeDom provider is registered for language: "+options["language"])
			return 2
		}
	}
	#endif
	if codegen == nil {
		writeSyntax()
		writeLn("Unsupported language: "+options["language"])
		return 2
	}

	if options["service"] != nil {
		options["type"] = "impl"
	} else if options["services"] != nil {
		options["type"] = "impl"
	}

	if let type = options["type"] {
		writeLn("Generating "+options["type"])

		if let activeRodlCodeGen = activeRodlCodeGen {
			activeRodlCodeGen.Generator = codegen

			switch type.ToLowerInvariant() {
				case "intf":
					if codegen is CGJavaCodeGenerator {
						let sourceFiles = activeRodlCodeGen.GenerateInterfaceFiles(rodlLibrary, options["namespace"])
						for name in sourceFiles.Keys {
							var fileName = Path.Combine(Path.GetParentDirectory(targetRodlFileName), name)
							_WriteText(fileName, sourceFiles[name]);
							writeLn("Wrote file \(fileName)")
						}
					} else {
						let intf_file = targetFileNameWithSuffix("Intf");
						let source = activeRodlCodeGen?.GenerateInterfaceFile(rodlLibrary, options["namespace"], intf_file)
						_WriteText(intf_file, source);
						writeLn("Wrote file \(intf_file)")

						if options["language"] == "objc" {
							activeRodlCodeGen?.Generator = CGObjectiveCHCodeGenerator()
							let sourceH = activeRodlCodeGen?.GenerateInterfaceFile(rodlLibrary, options["namespace"], intf_file)
							fileExtension = "h";
							_WriteText(intf_file, sourceH);
							writeLn("Wrote file \(intf_file)")
						} else if options["language"] == "cpp" {
							activeRodlCodeGen?.Generator = CGCPlusPlusHCodeGenerator(dialect: .CPlusPlusBuilder)
							let sourceH = activeRodlCodeGen?.GenerateInterfaceFile(rodlLibrary, options["namespace"], intf_file)
							fileExtension = "h";
							_WriteText(intf_file, sourceH);
							writeLn("Wrote file \(intf_file)")
						}
					}

				case "serveraccess":

					if let activeServerAccessCodeGen = activeServerAccessCodeGen, let codegen = codegen {
						if isSupportedUrl {
							activeServerAccessCodeGen.serverAddress = url.ToAbsoluteString();
						}
						if codegen is CGJavaCodeGenerator {
							if let sourceFiles = (activeServerAccessCodeGen as? JavaServerAccessCodeGen)?.generateFiles(codegen/*options["namespace"]*/) {
								for name in sourceFiles.Keys {
									var fileName = Path.Combine(Path.GetParentDirectory(targetRodlFileName), name)
									_WriteText(fileName, sourceFiles[name]);
									writeLn("Wrote file \(fileName)")
								}
							}
						} else {
							let sa_file = targetFileNameWithSuffix("ServerAccess");
							let unit = activeServerAccessCodeGen.generateCodeUnit(/*options["namespace"]*/)
							if length(unit.FileName) == 0 {
								unit.FileName = Path.GetFileName(sa_file);
							}
							let source = codegen?.GenerateUnit(unit)
							_WriteText(sa_file, source);
							writeLn("Wrote file \(sa_file)")

							if (options["platform"] == "delphi")||(options["platform"] == "bcb") {
								let dfm = (activeServerAccessCodeGen as? DelphiServerAccessCodeGen)?.generateDFM()
								fileExtension = "dfm";
								_WriteText(sa_file, dfm);
								writeLn("Wrote file \(sa_file)")
							}
							if options["language"] == "objc" {
								let codegenH = CGObjectiveCHCodeGenerator()
								let sourceH = codegenH?.GenerateUnit(unit)
								fileExtension = "h";
								_WriteText(sa_file, sourceH);
								writeLn("Wrote file \(sa_file)")
							} else if options["language"] == "cpp" {
								let codegenH = CGCPlusPlusHCodeGenerator(dialect: .CPlusPlusBuilder)
								let sourceH = codegenH?.GenerateUnit(unit)
								fileExtension = "h";
								_WriteText(sa_file, sourceH);
								writeLn("Wrote file \(sa_file)")
							}
						}
					}

				case "invk":
					if !serverSupport {
						writeLn("Generating server code is not supported for this platform.")
					}
					let invk_file = targetFileNameWithSuffix("Invk");
					let source = activeRodlCodeGen?.GenerateInvokerFile(rodlLibrary, options["namespace"], invk_file)
					if !String.IsNullOrWhiteSpace(source) {
						_WriteText(invk_file, source);
						writeLn("Wrote file \(invk_file)")
					}

				case "impl":

					let processServices = {
						for i in 0 ..< rodlLibrary.Services.Count {
							let s = rodlLibrary.Services[i]

							if options["service"] == nil || s.Name == options["service"] {

								if let sourceFiles = activeRodlCodeGen?.GenerateImplementationFiles( rodlLibrary, options["namespace"], s.Name) {
									//for (n,c) in sourceFiles {
									for n in sourceFiles.Keys {
										_WriteText(targetFileName(n), sourceFiles[n]);
										writeLn("Wrote file \(targetFileName(n))")
									}
								}
							}
						}
					}

					processServices()
					if options["language"] == "cpp" {
						activeRodlCodeGen?.Generator = CGCPlusPlusHCodeGenerator(dialect: .CPlusPlusBuilder)
						(activeRodlCodeGen as? DelphiRodlCodeGen)?.GenerateDFMs = false
						fileExtension = "h";
						processServices()
					}

					break
				default:
			}    // todo: generate services
		}
	}
} catch {
	writeLn("There was a problem loading the RODL.")
	writeLn()
	writeLn(error.ToString() as String!)
	writeLn()
	return 2
}