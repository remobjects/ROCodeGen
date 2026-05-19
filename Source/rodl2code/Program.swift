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
	writeLn("  - client (intf & serveraccess)")
	writeLn("  - server (intf & invk)")
	writeLn()
	writeLn("Valid <platform> values:")
	writeLn()
	writeLn("  - .net, net, echoes")
	writeLn("  - cocoa, xcode, toffee")
	writeLn("  - java, cooper")
	writeLn("  - delphi, c++builder, bcb")
	writeLn("  - javascript, js")
	writeLn("  - php")
	writeLn()
	writeLn("Valid <language> values:")
	writeLn()
	writeLn("  - oxygene, pas (RemObjects Oxygene)")
	writeLn("  - hydrogene, c#, cs (RemObjects C#)")
	writeLn("  - standard-csharp (Microsoft C#)")
	writeLn("  - visual-basic, visualbasic, vb, vb.net (Microsoft VB)")
	writeLn("  - mercury (RemObjects VB)")
	writeLn("  - silver (RemObjects Swift)")
	writeLn("  - swift (Apple Swift)")
	writeLn("  - objective-c, Objc (Apple Objective-C)")
	writeLn("  - delphi, pas, bcb, c++builder, cpp, c++ (Delphi & C++ Builder)")
	writeLn("  - iodine (RemObjects' Java)")
	writeLn("  - java (Oracle Java)")
	writeLn("  - javascript, js")
	writeLn("  - php")
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
	writeLn("  --splittypes (BCB only)")
	writeLn("  --hydra (Delphi only)")
	writeLn("  --skipasync (Delphi/BCB)")
	writeLn("  --skipdocumentation")
	writeLn("  --excludeclasses (valid for --type:intf only)")
	writeLn("  --excludeservices (valid for --type:intf only)")
	writeLn("  --excludeeventsinks (valid for --type:intf only)")
	writeLn("  --ignoreda (valid for --type:intf only)")
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
	let b = fileEncoding.GetBytes(Content, includeBOM: !omitBom)
	File.WriteBytes(aFileName, b)
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

var DADRoot = ExpandVariable("$(Data Abstract for Delphi)")
var DANRoot = ExpandVariable("$(Data Abstract for .NET)")
var RODRoot = ExpandVariable("$(RemObjects SDK for Delphi)")
var HYDRoot = ExpandVariable("$(Hydra for Delphi)")

RodlCodeGen.KnownRODLPaths["DataAbstract4.RODL".ToLowerInvariant()]         = DADRoot + "/Source/DataAbstract4.RODL"
RodlCodeGen.KnownRODLPaths["DataAbstract.RODL".ToLowerInvariant()]          = DANRoot + "/Source/RemObjects.DataAbstract.Server/DataAbstract4.RODL"
RodlCodeGen.KnownRODLPaths["ROServiceDiscovery.rodl".ToLowerInvariant()]    = RODRoot + "/Source/ROServiceDiscovery.rodl"
RodlCodeGen.KnownRODLPaths["uRODataSnap.rodl".ToLowerInvariant()]           = RODRoot + "/Source/DataSnap/uRODataSnap.rodl"
RodlCodeGen.KnownRODLPaths["HydraAutoUpdate.RODL".ToLowerInvariant()]       = HYDRoot + "/Source/HydraAutoUpdate.RODL"

switch options["platform"]?.ToLowerInvariant() {
	case "delphi", "bcb", "c++builder":
		RodlCodeGen.KnownRODLPaths["DataAbstract-Simple.RODL".ToLowerInvariant()] = DADRoot + "/Source/DataAbstract-Simple.RODL"
	default:
		RodlCodeGen.KnownRODLPaths["DataAbstract-Simple.RODL".ToLowerInvariant()] = DANRoot + "/Source/RemObjects.DataAbstract.Server/DataAbstract-Simple.RODL"
}

//
// Load RODL
//

var rodlFileName = params[0]
writeLn("Processing RODL file "+rodlFileName)

do {

	var isSupportedUrl =    rodlFileName.hasPrefix("http://") || rodlFileName.hasPrefix("https://") || rodlFileName.hasPrefix("file://")
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

	if var outPath = options["outpath"] {
		targetRodlFileName = Path.Combine(outPath, Path.GetFileName(targetRodlFileName))!
		Folder.Create(Path.GetParentDirectory(targetRodlFileName))
	}

	if options["type"]?.ToLowerInvariant() == "res" {
		let resFileName = Path.ChangeExtension(targetRodlFileName, ".res")
		ResGenerator.GenerateResFile(rodlLibrary, resFileName)
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
	if options["platform"]?.ToLowerInvariant() == "php" && options["language"] == nil {
		options["language"] = "php"
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
		case "client": break
		case "server": break
		default:
			writeSyntax()
			writeLn("Unsupported type: "+options["type"])
			return 2
	}
	rodlLibrary.Validate()


	var codegen: CGCodeGenerator?
	var codegenH: CGCodeGenerator?

	var fileExtension = "txt"
	switch options["language"]?.ToLowerInvariant() {
		case "oxygene", "pas":
			options["language"] = "oxygene"
			codegen = CGOxygeneCodeGenerator(style: .Standard, quoteStyle: .SmartDouble)
			fileExtension = codegen!.defaultFileExtension
		case "hydrogene", "csharp", "c#", "cs":
			options["language"] = "c#"
			codegen = CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Hydrogene)
			fileExtension = codegen!.defaultFileExtension
		case "visual-c#", "visualcsharp", "vc#", "standard-csharp":
			options["language"] = "standard-c#"
			codegen = CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Standard)
			fileExtension = codegen!.defaultFileExtension
		case "visual-basic", "visualbasic", "visualbasic.net", "vb", "vb.net":
			options["language"] = "standard-vb"
			codegen = CGVisualBasicNetCodeGenerator(dialect: CGVisualBasicCodeGeneratorDialect.Standard)
			fileExtension = codegen!.defaultFileExtension
		case "mercury":
			options["language"] = "vb"
			codegen = CGVisualBasicNetCodeGenerator(dialect: CGVisualBasicCodeGeneratorDialect.Mercury)
			fileExtension = codegen!.defaultFileExtension
		case "silver":
			options["language"] = "swift"
			codegen = CGSwiftCodeGenerator(dialect: CGSwiftCodeGeneratorDialect.Silver)
			fileExtension = codegen!.defaultFileExtension
		case "swift", "apple-swift", "standard-swift":
			options["language"] = "standard-swift"
			codegen = CGSwiftCodeGenerator(dialect: CGSwiftCodeGeneratorDialect.Standard)
			fileExtension = codegen!.defaultFileExtension
		case "objc", "objectivec", "objective-c":
			options["language"] = "objc"
			codegen = CGObjectiveCMCodeGenerator()
			codegenH = CGObjectiveCHCodeGenerator()
			fileExtension = codegen!.defaultFileExtension
		case "delphi":
			options["language"] = "delphi"
			options["platform"] = "delphi" // force platform to Delphi
			codegen = CGDelphiCodeGenerator()
			codegen!.splitLinesLongerThan = 200
			fileExtension = codegen!.defaultFileExtension
		case "bcb", "cpp", "c++", "c++builder":
			options["platform"] = "bcb" // force platform to bcb
			options["language"] = "cpp"
			codegen = CGCPlusPlusCPPCodeGenerator(dialect: .CPlusPlusBuilder)
			codegenH = CGCPlusPlusHCodeGenerator(dialect: .CPlusPlusBuilder)
			codegen!.splitLinesLongerThan = 200
			codegenH!.splitLinesLongerThan = 200
			fileExtension = codegen!.defaultFileExtension
		case "iodine":
			options["language"] = "java"
			codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Iodine)
			fileExtension = codegen!.defaultFileExtension
		case "java":
			if options["platform"]?.ToLowerInvariant() == "java" {
				options["language"] = "standard-java"
				omitBom = true
				codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Standard)
			} else {
				options["language"] = "java"
				codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Iodine)
			}
			fileExtension = codegen!.defaultFileExtension
		case "javascript", "js":
			options["language"] = "javascript"
			options["platform"] = "javascript" // force platform to JavaScript
			codegen = CGJavaScriptCodeGenerator()
			fileExtension = codegen!.defaultFileExtension
		case "php":
			//options["language"] = "php"
			//options["platform"] = "php"
			codegen = CGPhpCodeGenerator()
			fileExtension = "php.inc"
		default:
	}

	var serverSupport = false
	var activeRodlCodeGen: RodlCodeGen?
	var activeServerAccessCodeGen: ServerAccessCodeGen?
	var activeServerAccessCodeGenDFM: DelphiServerAccessCodeGen?
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
			activeRodlCodeGen = EchoesRodlCodeGen()
			activeServerAccessCodeGen = NetServerAccessCodeGen(rodl: rodlLibrary, namespace: options["namespace"])
		case "delphi":
			options["platform"] = "delphi"
			options["language"] = "delphi" // force language to Delphi
			serverSupport = true
			activeRodlCodeGen = DelphiRodlCodeGen()
			activeServerAccessCodeGenDFM = DelphiServerAccessCodeGen(rodl:rodlLibrary)
			activeServerAccessCodeGen = activeServerAccessCodeGenDFM
		case "bcb", "c++builder":
			options["platform"] = "bcb"
			options["language"] = "cpp" // force language to C++(Builder)
			serverSupport = true
			activeRodlCodeGen = CPlusPlusBuilderRodlCodeGen()
			activeServerAccessCodeGenDFM = CPlusPlusBuilderServerAccessCodeGen(rodl:rodlLibrary)
			activeServerAccessCodeGen = activeServerAccessCodeGenDFM
		case "javascript", "js":
			options["platform"] = "javascript"
			options["language"] = "js" // force language to JavaScript
			activeRodlCodeGen = JavaScriptRodlCodeGen()
		case "php":
			activeRodlCodeGen = PhpRodlCodeGen()
		default:
	}

	activeRodlCodeGen?.RodlFileName = Path.GetFileName(targetRodlFileName)
	if options["full-type-names"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.IncludeUnitNameForOwnTypes = true
	}
	if options["scoped-enums"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.ScopedEnums = true
	}
	if options["legacy-strings"] != nil {
		(activeRodlCodeGen as? DelphiRodlCodeGen)?.LegacyStrings = true
	}
	if options["skipdocumentation"] != nil {
		activeRodlCodeGen?.GenerateDocumentation = false
	}
	if options["excludeclasses"] != nil {
		activeRodlCodeGen?.ExcludeClasses = true
	}
	if options["excludeservices"] != nil {
		activeRodlCodeGen?.ExcludeServices = true
	}
	if options["excludeeventsinks"] != nil {
		activeRodlCodeGen?.ExcludeEventSinks = true
	}
	var IgnoreDA = false
	if options["ignoreda"] != nil {
		IgnoreDA = true
	}

	if (options["platform"] == "bcb") {
		let lcodegen = (activeRodlCodeGen as? CPlusPlusBuilderRodlCodeGen)?
		if options["splittypes"] != nil {
			lcodegen.SplitTypes = true
		}
		if options["skipasync"] != nil {
			lcodegen.AsyncSupport = false
		}
	}
	if (options["platform"] == "delphi") {
		let lcodegen = (activeRodlCodeGen as? DelphiRodlCodeGen)?

		if options["skipasync"] != nil {
			lcodegen.AsyncSupport = false
		}

		if options["xe2"] != nil {
			switch options["xe2"]?.ToLowerInvariant() {
				case "on":
					lcodegen.DelphiXE2Mode = State.On
					if codegen is CGDelphiCodeGenerator {
						(codegen as? CGDelphiCodeGenerator)?.Dialect = .Delphi2009
					}
				case "off": lcodegen.DelphiXE2Mode = State.Off
				case "auto": lcodegen.DelphiXE2Mode = State.Auto
				default:
			}
		}
		if options["fpc"] != nil {
			switch options["fpc"]?.ToLowerInvariant() {
				case "on": lcodegen.FPCMode = State.On
				case "off": lcodegen.FPCMode = State.Off
				case "auto": lcodegen.FPCMode = State.Auto
				default:
			}
		}
		if options["codefirst"] != nil {
			switch options["codefirst"]?.ToLowerInvariant() {
				case "on": lcodegen.CodeFirstMode = State.On
				case "off": lcodegen.CodeFirstMode = State.Off
				case "auto": lcodegen.CodeFirstMode = State.Auto
				default:
			}
		}
		if options["genericarray"] != nil {
			switch options["genericarray"]?.ToLowerInvariant() {
				case "on": lcodegen.GenericArrayMode = State.On
				case "off": lcodegen.GenericArrayMode = State.Off
				case "auto": lcodegen.GenericArrayMode = State.Auto
				default:
			}
		}

		if (lcodegen.FPCMode == State.On) {
			lcodegen.DelphiXE2Mode = State.Off
		}
		if (lcodegen.DelphiXE2Mode == State.Off) {
			lcodegen.CodeFirstMode = State.Off
			lcodegen.GenericArrayMode = State.Off
		}
		if (lcodegen.DelphiXE2Mode == State.On) {
			lcodegen.FPCMode = State.Off
		}
		if (lcodegen.CodeFirstMode == State.Off) {
			lcodegen.GenericArrayMode = State.Off
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
		var s1 = Path.GetParentDirectory(targetRodlFileName)
		var s2 = Path.GetFileNameWithoutExtension(Path.GetFileName(targetRodlFileName))+"_"+suffix+"."+fileExtension
		if String.IsNullOrWhiteSpace(s1) {
			return s2
		}
		else {
			return Path.Combine(s1, s2)
		}
	}

	func targetFileName(_ name: String) -> String? {
		return Path.Combine(Path.GetParentDirectory(targetRodlFileName), name)
	}

	func writeSingleFile(_ fileName: String,_ content: String) {
		_WriteText(fileName, content)
		writeLn("Wrote file \(fileName)")
	}

	func writeFiles(_ sourceFiles: Dictionary<String!,String!>!) {
		for name in sourceFiles.Keys {
			writeSingleFile(targetFileName(name), sourceFiles[name])
		}
	}

	if activeRodlCodeGen == nil {
		writeLn("Unsupported platform: "+options["platform"])
		return 2
	}
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

			let generateIntf = {
				let rodlLibrary1 = iif(IgnoreDA, rodlLibrary.RemoveDA(), rodlLibrary)
				let generateIntf1 = {
					let sourceFiles = activeRodlCodeGen.GenerateInterfaceFiles(rodlLibrary1, options["namespace"])
					writeFiles(sourceFiles)
				}
				let intf_file = targetFileNameWithSuffix("Intf")
				if activeRodlCodeGen.CodeUnitSupport {
					if ((activeRodlCodeGen is JavaRodlCodeGen) && (codegen is CGJavaCodeGenerator)) ||
						(activeRodlCodeGen is JavaScriptRodlCodeGen)
					{
						generateIntf1()
					} else {
						if (activeRodlCodeGen is CPlusPlusBuilderRodlCodeGen) && (options["splittypes"] != nil) {
							generateIntf1()
							activeRodlCodeGen.Generator = codegenH
							generateIntf1()
						}
						else {
							let lunit = activeRodlCodeGen.GenerateInterfaceCodeUnit(rodlLibrary, options["namespace"], intf_file)
							if let lunit = lunit {
								let source = activeRodlCodeGen.Generator.GenerateUnit(lunit)
								writeSingleFile(intf_file, source)
								if let codegenH = codegenH {
									let sourceH = codegenH.GenerateUnit(lunit)
									let intf_fileH = Path.ChangeExtension(intf_file, codegenH.defaultFileExtension)
									writeSingleFile(intf_fileH, sourceH)
								}
							}
						}
					}
				}
				else {
					let source = activeRodlCodeGen.GenerateInterfaceFile(rodlLibrary, options["namespace"], intf_file)
					writeSingleFile(intf_file, source)
				}
			}

			let generateServerAccess = {
				if let activeServerAccessCodeGen = activeServerAccessCodeGen, let codegen = codegen {
					if isSupportedUrl {
						activeServerAccessCodeGen.serverAddress = url.ToAbsoluteString()
					}
					if codegen is CGJavaCodeGenerator {
						if let sourceFiles = (activeServerAccessCodeGen as? JavaServerAccessCodeGen)?.generateFiles(codegen/*options["namespace"]*/) {
							writeFiles(sourceFiles)
						}
					} else {
						let sa_file = targetFileNameWithSuffix("ServerAccess")
						let unit = activeServerAccessCodeGen.generateCodeUnit(/*options["namespace"]*/)
						if let unit = unit {
							if length(unit.FileName) == 0 {
								unit.FileName = Path.GetFileName(sa_file)
							}
							let source = codegen?.GenerateUnit(unit)
							writeSingleFile(sa_file, source)
							if let activeServerAccessCodeGenDFM = activeServerAccessCodeGenDFM {
								let dfm = activeServerAccessCodeGenDFM.generateDFM()
								let sa_file_dfm = Path.ChangeExtension(sa_file, "dfm")
								writeSingleFile(sa_file_dfm, dfm)
							}
							if let codegenH = codegenH {
								let sourceH = codegenH.GenerateUnit(unit)
								let sa_fileH = Path.ChangeExtension(sa_file, codegenH.defaultFileExtension)
								writeSingleFile(sa_fileH, sourceH)
							}
						}
					}
				}
			}

			let generateInvk = {
				if !serverSupport {
					writeLn("Generating server code is not supported for this platform.")
					return false
				}
				let invk_file = targetFileNameWithSuffix("Invk")
				if activeRodlCodeGen?.CodeUnitSupport {
					if (activeRodlCodeGen is CPlusPlusBuilderRodlCodeGen) && (options["splittypes"] != nil) {
						let generateInvk1 = {
							let sourceFiles = activeRodlCodeGen.GenerateInvokerFiles(rodlLibrary, options["namespace"])
							writeFiles(sourceFiles)
						}
						generateInvk1()
						activeRodlCodeGen.Generator = codegenH
						generateInvk1()
						activeRodlCodeGen.Generator = codegen
					}
					else {
						let lunit = activeRodlCodeGen?.GenerateInvokerCodeUnit(rodlLibrary, options["namespace"], invk_file)
						if let lunit = lunit {
							let source = activeRodlCodeGen?.Generator.GenerateUnit(lunit)
							writeSingleFile(invk_file, source)
							if let codegenH = codegenH {
								let sourceH = codegenH.GenerateUnit(lunit)
								let invk_fileH = Path.ChangeExtension(invk_file, codegenH?.defaultFileExtension)
								writeSingleFile(invk_fileH, sourceH)
							}
						}
					}

				}
				else {
					let source = activeRodlCodeGen?.GenerateInvokerFile(rodlLibrary, options["namespace"], invk_file)
					if !String.IsNullOrWhiteSpace(source) {
						writeSingleFile(invk_file, source)
					}
				}
				return true
			}

			let generateImpl = {
				let processServices = {
					for i in 0 ..< rodlLibrary.Services.Count {
						let s = rodlLibrary.Services[i]

						if options["service"] == nil || s.Name == options["service"] {

							if let sourceFiles = activeRodlCodeGen?.GenerateImplementationFiles( rodlLibrary, options["namespace"], s.Name) {
								writeFiles(sourceFiles)
							}
						}
					}
				}

				processServices()
				if let codegenH = codegenH {
					(activeRodlCodeGen as? DelphiRodlCodeGen)?.GenerateDFMs = false
					processServices()
				}
			}

			switch type.ToLowerInvariant() {
				case "intf":
					generateIntf()
				case "serveraccess":
					generateServerAccess()
				case "client":
					generateIntf()
					activeServerAccessCodeGen?.ignoreRODLnamespace = true
					generateServerAccess()
				case "server":
					generateIntf()
					if !generateInvk() {
						return 2    // error
					}
				case "invk":
					if !generateInvk() {
						return 2    // error
					}
				case "impl":
					generateImpl()
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