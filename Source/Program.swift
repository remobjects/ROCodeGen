import RemObjects.SDK.CodeGen4

func writeSyntax() {
	writeLn("Syntax:")
	writeLn()
	writeLn("  rodl2code <rodl> --type:<type> --platform:<platform> --language:<language> --namespace:<namespace>")
	writeLn("  rodl2code <rodl> --service:<name> --platform:<platform> --language:<language> --namespace:<namespace>")
	writeLn("  rodl2code <rodl> --services --platform:<platform> --language:<language> --namespace:<namespace>")
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
	writeLn("  - javascript, js (not supported yet)")
	writeLn()
	writeLn("Valid <language> values:")
	writeLn()
	writeLn("  - oxygene, pas")
	writeLn("  - hydrogene, c#, cs")
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
	writeLn("  --codefirst-compatible (Delphi only)")
	writeLn()
	writeLn("  --outpath:<path> (optional target folder for generated files)")
	writeLn("  --no-utf8 (disable UTF-8 for IDEs from last century)")
	writeLn("  --no-bom (omit BOM from UTF-8 files; default fore java)")
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
				options[name.ToLower()] = value // retest 72610: Sugar mapping fails at runtime, trying to call the mapped method
				//(options as! NSMutableDictionary)[name] = value.ToLower() // Parameter 1 is "String", should be "TValue", in call to NSMutableDictionary<TKey,TValue>!.setObject(anObject: TValue, forKeyedSubscript aKey: TKey)
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

	var isUrl = rodlFileName.hasPrefix("http://") || rodlFileName.hasPrefix("https://")
	var url = isUrl ? rodlFileName : nil

	if !isUrl && !File.Exists(params[0]) {
		writeLn("File \(params[0]) not found")
		writeLn()
		return 2
	}

	let rodlLibrary = RodlLibrary(rodlFileName)

	var targetRodlFileName = isUrl ? "."+Path.DirectorySeparatorChar+rodlLibrary.Name+".rodl" : rodlFileName;
	if let outPath = options["outpath"] {
		targetRodlFileName = Path.Combine(outPath, Path.GetFileName(targetRodlFileName))!
		Folder.Create(Path.GetParentDirectory(targetRodlFileName))
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
	if options["platform"]?.ToLower() == "delphi" && options["language"] == nil {
		options["language"] = "delphi"
	}
	if options["platform"]?.ToLower() == "bcb" && options["language"] == nil {
		options["language"] = "cpp"
	}
	if options["language"] == nil {
		writeSyntax()
		return 1
	}

	if options["namespace"] == nil {
		options["namespace"] = "YourNamespace"
	}

	switch options["type"]?.ToLower() {
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

	if options["type"]?.ToLower() == "res" {

		let resFileName = Path.ChangeExtension(targetRodlFileName, ".res")
		ResGenerator.GenerateResFile(rodlLibrary, resFileName);
		writeLn("Wrote file \(resFileName)")
		return
	}

	var codegen: CGCodeGenerator?

	var fileExtension = "txt"
	switch options["language"]?.ToLower() {
		case "oxygene", "pas":
			options["language"] = "oxygene"
			codegen = CGOxygeneCodeGenerator()
			fileExtension = "pas"
		case "hydrogene", "csharp", "c#", "cs":
			options["language"] = "c#"
			codegen = CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Hydrogene)
			fileExtension = "cs"
		case "visual-c#", "visualcsharp", "vc#", "standard-csharp":
			options["language"] = "standard-c#"
			codegen = CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Standard)
			fileExtension = "cs"
		case "visual-basic", "visualbasic", "visualbasic.net", "vb", "vb.ndet":
			options["language"] = "vb"
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
			if options["platform"]?.ToLower() == "java" {
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
			codegen = CGJavaScriptCodeGenerator()
			writeLn("JavaScript language codegen is not supported in rodl2code yet, sorry.")
			fileExtension = "js"
			return 2
		default:
	}

	var serverSupport = false
	var activeRodlCodeGen: RodlCodeGen?
	var activeServerAccessCodeGen: ServerAccessCodeGen?
	switch options["platform"]?.ToLower() {
		case "cooper", "java":
			options["platform"] = "java"
			if options["language"] == "swift" {
				options["language"] = "silver" // force our Swift
			}
			activeRodlCodeGen = JavaRodlCodeGen()
			activeServerAccessCodeGen = JavaServerAccessCodeGen(rodl: rodlLibrary)
		case "toffee", "nougat", "cocoa", "xcode": // keep Nougat, undocumdented, for backwards comopatibility
			options["platform"] = "cocoa"
			if options["language"]?.ToLower() == "swift" && (options["platform"]?.ToLower() == "toffee" || options["platform"]?.ToLower() == "nougat") {
					options["language"] = "silver" // force our Swift
			}
			activeRodlCodeGen = CocoaRodlCodeGen()
			activeServerAccessCodeGen = CocoaServerAccessCodeGen(rodl: rodlLibrary, generator: codegen!)

			if let cocoaRodlCodeGen = activeRodlCodeGen as? CocoaRodlCodeGen {
				if options["language"] == "standard-swift" {
					cocoaRodlCodeGen.SwiftDialect = .Standard
					cocoaRodlCodeGen.FixUpForAppeSwift()
				} else {
					cocoaRodlCodeGen.SwiftDialect = .Silver
				}
			}

		case "echoes", "net", ".net":
			options["platform"] = ".net"
			serverSupport = true
			#if ECHOES
			activeRodlCodeGen = EchoesCodeDomRodlCodeGen()
			#else
			activeServerAccessCodeGen = NetServerAccessCodeGen(rodl: rodlLibrary, namespace: options["namespace"])
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
			//activeRodlCodeGen = JavaScriptRodlCodeGen()
			//activeServerAccessCodeGen = JavaScriptServerAccessCodeGen()
			writeLn("javaScript RODL codegen is not supported in rodl2code yet, sorry.")
			return 2
		default:
	}

	if options["full-type-names"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.IncludeUnitNameForOwnTypes = true
	}
	if options["scoped-enums"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.ScopedEnums = true
	}
	if options["legacy-strings"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.LegacyStrings = true
	}

	if options["codefirst-compatible"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.CodeFirstCompatible = true
	}

	if options["no-utf8"] != nil {
		fileEncoding = Encoding.ASCII
	}
	if options["no-bom"] != nil {
		omitBom = true
	}

	func targetFileNameWithSuffix(_ suffix: String) -> String? {
		return Path.Combine(Path.GetParentDirectory(targetRodlFileName), Path.GetFileNameWithoutExtension(Path.GetFileName(targetRodlFileName))+"_"+suffix+"."+fileExtension)
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

			switch type.ToLower() {
				case "intf":
					if codegen is CGJavaCodeGenerator {
						let sourceFiles = activeRodlCodeGen.GenerateInterfaceFiles(rodlLibrary, options["namespace"])
						for name in sourceFiles.Keys {
							var fileName = Path.Combine(Path.GetParentDirectory(targetRodlFileName), name)
							_WriteText(fileName, sourceFiles[name]);
							writeLn("Wrote file \(fileName)")
						}
					} else {
						let source = activeRodlCodeGen?.GenerateInterfaceFile(rodlLibrary, options["namespace"], targetFileNameWithSuffix("Intf"))
						_WriteText(targetFileNameWithSuffix("Intf"), source);
						writeLn("Wrote file \(targetFileNameWithSuffix("Intf"))")

						if options["language"] == "objc" {
							activeRodlCodeGen?.Generator = CGObjectiveCHCodeGenerator()
							let sourceH = activeRodlCodeGen?.GenerateInterfaceFile(rodlLibrary, options["namespace"], targetFileNameWithSuffix("Intf"))
							fileExtension = "h";
							_WriteText(targetFileNameWithSuffix("Intf"), sourceH);
							writeLn("Wrote file \(targetFileNameWithSuffix("Intf"))")
						} else if options["language"] == "cpp" {
							activeRodlCodeGen?.Generator = CGCPlusPlusHCodeGenerator(dialect: .CPlusPlusBuilder)
							let sourceH = activeRodlCodeGen?.GenerateInterfaceFile(rodlLibrary, options["namespace"], targetFileNameWithSuffix("Intf"))
							fileExtension = "h";
							_WriteText(targetFileNameWithSuffix("Intf"), sourceH);
							writeLn("Wrote file \(targetFileNameWithSuffix("Intf"))")
						}
					}

				case "serveraccess":

					if let activeServerAccessCodeGen = activeServerAccessCodeGen, let codegen = codegen {
						if isUrl {
							activeServerAccessCodeGen.serverAddress = url;
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
							let unit = activeServerAccessCodeGen.generateCodeUnit(/*options["namespace"]*/)
							if length(unit.FileName) == 0 {
								unit.FileName = Path.GetFileName(targetFileNameWithSuffix("ServerAccess"));
							}
							let source = codegen?.GenerateUnit(unit)
							_WriteText(targetFileNameWithSuffix("ServerAccess"), source);
							writeLn("Wrote file \(targetFileNameWithSuffix("ServerAccess"))")

							if (options["platform"] == "delphi")||(options["platform"] == "bcb") {
								let dfm = (activeServerAccessCodeGen as? DelphiServerAccessCodeGen)?.generateDFM()
								fileExtension = "dfm";
								_WriteText(targetFileNameWithSuffix("ServerAccess"), dfm);
								writeLn("Wrote file \(targetFileNameWithSuffix("ServerAccess"))")
							}
							if options["language"] == "objc" {
								let codegenH = CGObjectiveCHCodeGenerator()
								let sourceH = codegenH?.GenerateUnit(unit)
								fileExtension = "h";
								_WriteText(targetFileNameWithSuffix("ServerAccess"), sourceH);
								writeLn("Wrote file \(targetFileNameWithSuffix("ServerAccess"))")
							} else if options["language"] == "cpp" {
								let codegenH = CGCPlusPlusHCodeGenerator(dialect: .CPlusPlusBuilder)
								let sourceH = codegenH?.GenerateUnit(unit)
								fileExtension = "h";
								_WriteText(targetFileNameWithSuffix("ServerAccess"), sourceH);
								writeLn("Wrote file \(targetFileNameWithSuffix("ServerAccess"))")
							}
						}
					}

				case "invk":
					if !serverSupport {
						writeLn("Generating server code is not supported for this platform.")
					}
					let source = activeRodlCodeGen?.GenerateInvokerFile(rodlLibrary, options["namespace"], targetFileNameWithSuffix("Invk"))
					_WriteText(targetFileNameWithSuffix("Invk"), source);
					writeLn("Wrote file \(targetFileNameWithSuffix("Invk"))")

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
	writeLn(error.ToString())
	writeLn()
	return 2
}