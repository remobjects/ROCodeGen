import AppKit

@IBObject public class RodlDocumentWindowController: NSWindowController,INSOpenSavePanelDelegate {

	public init(document: RodlDocument) {
		super.init(windowNibName: "RodlDocumentWindowController")
		self.rodlDocument = document
	}

	private var rodlDocument: RodlDocument
	private var files = NSMutableDictionary()
	private var error: String?

	public override func windowDidLoad() {

		super.windowDidLoad()

		fillPopup()
		if let document = document {
			error = document.error
			document.loadedCallback = { error in
				error = document.error
				self.updateUI()
				self.targetChanged(nil)
			}
		}
		updateUI()
	}

	@IBOutlet var libraryNameField: NSTextField!
	@IBOutlet var targetsPopup: NSPopUpButton!
	@IBOutlet var tabs: NSPopUpButton!
	@IBOutlet var codeField: NSTextView!
	@IBOutlet var saveButton: NSButton!
	@IBOutlet var generateServerAccessClass: NSButton!

	@IBAction func generateServerAccessClassChanged(_ sender: AnyObject?) {
		targetChanged(sender)
	}


	@IBAction func save(_ sender: AnyObject?) {

		let s = NSSavePanel.savePanel()
		s.allowsOtherFileTypes = false
		s.extensionHidden = false
		s.prompt = saveButton.title
		let firstFilename = files.allKeys.sortedArrayUsingDescriptors([NSSortDescriptor(key: "self", ascending: true)])[0]
		s.nameFieldStringValue = firstFilename
		/*if false/*rodlDocument.isTemporary*/ {
			s.directoryURL = nil
		} else {
			s.directoryURL = rodlDocument.URL.URLBy
		}*/
		//s.setNameFieldStringValue(this.uniqueNameBasedOnName(template.defaultName) atURL(s.directoryURL()) nameHasExtension(false));
		s.delegate = self
		s.beginSheetModalForWindow(window!) { result in
			if result > 0 {
				if let baseUrl = s.URL?.URLByDeletingLastPathComponent {
					for f in self.files.allKeys {
						let fileUrl = baseUrl.URLByAppendingPathComponent(f)!

						if fileUrl.lastPathComponent!.stringByDeletingPathExtension!.hasSuffix("_ServerAccess") {
							if NSFileManager.defaultManager.fileExistsAtPath(fileUrl.path!) {
								continue
							}
						}

						do {
							try self.files[f]?.writeToURL(fileUrl, atomically: true, encoding: .NSUTF8StringEncoding)
						} catch {
							NSLog("%@", error)
						}
					}
					NSWorkspace.sharedWorkspace.selectFile(baseUrl.URLByAppendingPathComponent(firstFilename)!.path, inFileViewerRootedAtPath: baseUrl.path!)
				}
			}
		}
	}

	private func fillPopup() {
		targetsPopup.removeAllItems()
		targetsPopup.menu!.addItemWithTitle("Cocoa: Objectve-C (Xcode)", action: nil, keyEquivalent: "")!.representedObject = "ObjC/Xcode/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Cocoa: Swift (Xcode)", action: nil, keyEquivalent: "")!.representedObject = "Swift/Xcode/ServerAccess"
		targetsPopup.menu!.addItem(NSMenuItem.separatorItem)
		targetsPopup.menu!.addItemWithTitle("Cocoa: Oxygene", action: nil, keyEquivalent: "")!.representedObject = "Oxygene/Cocoa/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Cocoa: RemObjects C#", action: nil, keyEquivalent: "")!.representedObject = "C#/Cocoa/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Cocoa: Swift (Silver)", action: nil, keyEquivalent: "")!.representedObject = "Silver/Cocoa/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Cocoa: Java (Iodine)", action: nil, keyEquivalent: "")!.representedObject = "Iodine/Cocoa/ServerAccess"
		if monoInstalled {
			targetsPopup.menu!.addItem(NSMenuItem.separatorItem)
			targetsPopup.menu!.addItemWithTitle(".NET: Oxygene", action: nil, keyEquivalent: "")!.representedObject = "Oxygene/.NET/ServerAccess"
			targetsPopup.menu!.addItemWithTitle(".NET: C#", action: nil, keyEquivalent: "")!.representedObject = "C#/.NET/ServerAccess"
			targetsPopup.menu!.addItemWithTitle(".NET: Swift (Silver)", action: nil, keyEquivalent: "")!.representedObject = "Silver/.NET/ServerAccess"
			targetsPopup.menu!.addItemWithTitle(".NET: Java (Iodine)", action: nil, keyEquivalent: "")!.representedObject = "Iodine/.NET/ServerAccess"
			targetsPopup.menu!.addItemWithTitle(".NET: Visual Basic", action: nil, keyEquivalent: "")!.representedObject = "VB/.NET/ServerAccess"
		}
		targetsPopup.menu!.addItem(NSMenuItem.separatorItem)
		targetsPopup.menu!.addItemWithTitle("Java: Java Language", action: nil, keyEquivalent: "")!.representedObject = "Java/Java"
		targetsPopup.menu!.addItemWithTitle("Java: Oxygene", action: nil, keyEquivalent: "")!.representedObject = "Oxygene/Java/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Java: RemObjects C#", action: nil, keyEquivalent: "")!.representedObject = "C#/Java/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Java: Swift (Silver)", action: nil, keyEquivalent: "")!.representedObject = "Silver/Java/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Java: Java (Iodine)", action: nil, keyEquivalent: "")!.representedObject = "Iodine/Java/ServerAccess"
		targetsPopup.menu!.addItem(NSMenuItem.separatorItem)
		targetsPopup.menu!.addItemWithTitle("Delphi: Delphi", action: nil, keyEquivalent: "")!.representedObject = "Delphi/Delphi/ServerAccess"
		targetsPopup.menu!.addItemWithTitle("Delphi: C++Builder", action: nil, keyEquivalent: "")!.representedObject = "BCB/Delphi/ServerAccess"
		targetsPopup.menu!.addItem(NSMenuItem.separatorItem)
		targetsPopup.menu!.addItemWithTitle("JavaScript: JavaScript", action: nil, keyEquivalent: "")!.representedObject = "JavaScript/JavaScript"

		if let last = NSUserDefaults.standardUserDefaults.stringForKey("LastSelectedTarget"), let item = targetsPopup.itemWithTitle(last) {
			targetsPopup.selectItemWithTitle(last)
		} else {
			targetsPopup.selectItemWithTitle("Cocoa: Swift (Xcode)")
		}
	}

	private func updateCodeFieldUI()
	{
		codeField.font = NSFont.fontWithName("Menlo",size:10);
		codeField.drawsBackground = false
		codeField.textStorage?.font = NSFont.fontWithName("Menlo", size: 11)


		/*let fieldEditor = window.fieldEditor(true, forObject: codeField)
		fieldEditor.setSelectedRange(NSMakeRange(0, 0))
		fieldEditor.setNeedsDisplay(true)
		fieldEditor.backgroundColor = codeField.backgroundColor*/
	}

	private func updateUI() {

		if let target = targetsPopup.selectedItem?.representedObject {
			generateServerAccessClass.enabled = target.componentsSeparatedByString("/").containsObject("ServerAccess")
		} else {
			generateServerAccessClass.enabled = false
		}

		if let rodlLibrary = rodlDocument.rodlLibrary, let libraryName = rodlLibrary.Name {
			libraryNameField.stringValue = rodlLibrary.Name
			libraryNameField.enabled = false
			targetsPopup.enabled = true
			if files.allKeys.count > 0 {
				tabs.removeAllItems()
				var i = 0;
				for k in files.allKeys.sortedArrayUsingDescriptors([NSSortDescriptor(key: "self", ascending: true)]) {
					tabs.addItemWithTitle(k)
					i += 1
				}
				tabs.selectItemAtIndex(0)
				tabs.hidden = false
				tabs.enabled = tabs.itemArray.count > 1
				tabChanged(nil)
				codeField.backgroundColor = NSColor.textBackgroundColor
				updateCodeFieldUI()
				saveButton.enabled = true
				saveButton.title = "Save \(files.allKeys.count) \(files.allKeys.count > 1 ? "files":"file")"
				return
			} else if let error = error {
				tabs.removeAllItems()
				tabs.addItemWithTitle("An error occurred")
				tabs.selectItemAtIndex(0)
				tabs.hidden = false
				tabs.enabled = false
				tabChanged(nil)
				codeField.backgroundColor = NSColor.colorWithCalibratedRed(1.0, green: 0.7, blue: 0.7, alpha: 1.0)
				updateCodeFieldUI()
				saveButton.enabled = false
				saveButton.title = "Save"
				return
			}
		} else {
			libraryNameField.stringValue = ""
		}

		tabs.removeAllItems()
		tabs.enabled = false
		codeField.string = ""
		saveButton.enabled = false
		saveButton.title = "Save"
		libraryNameField.enabled = false
		targetsPopup.enabled = (error == nil)
		generateServerAccessClass.enabled = false
	}

	@IBAction func tabChanged(_ sender: AnyObject?) {
		if tabs.indexOfSelectedItem >= 0 && tabs.indexOfSelectedItem < files.allKeys.count {
			codeField.string = coalesce(files[files.allKeys.sortedArrayUsingDescriptors([NSSortDescriptor(key: "self", ascending: true)])[tabs.indexOfSelectedItem]], "")
		} else if let error = error {
			codeField.string = error
		} else {
			codeField.string = ""
		}
	}

	@IBAction func targetChanged(_ sender: AnyObject?) {
		codeField.string = ""
		files = NSMutableDictionary()
		error = nil
		updateUI()
		if let rodlLibrary = rodlDocument.rodlLibrary, let libraryName = rodlLibrary.Name {
			if let selectedItem = targetsPopup.selectedItem {
				NSUserDefaults.standardUserDefaults.setObject(selectedItem.title, forKey: "LastSelectedTarget")
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
					self.generateCodeFor(target: selectedItem!.representedObject!)
				}
			}
		} else if let error = rodlDocument.error {
			codeField.string = error.description
		}
	}

	func generateCodeFor(target: String) {
		if let parts = target.componentsSeparatedByString("/"), parts.count >= 2 {
			let language = parts[0]
			let platform = parts[1]

			if platform == ".NET" {
				generateCodeWithCodeDomForLanguage(language)
				generateCodeWithCG4ForLanguage(language, platform: platform) // serverAccess only
			//} else if language == "JavaScript" /*|| language == "BCB"*/ {
				//generateCodeWithCG2ForLanguage(language, platform: platform)
			} else {
				generateCodeWithCG4ForLanguage(language, platform: platform)
			}
			dispatch_async(dispatch_get_main_queue()) {
				self.updateUI()
			}
		}
	}

	func generateCodeWithCG4ForLanguage(_ language: String, platform: String)
	{
		var codegen: CGCodeGenerator?
		var rocodegen: RodlCodeGen? = nil
		var serverAccessCodegen: ServerAccessCodeGen?
		var fileExtension = CGHelpers.FileExtensionForLanguage(language)
		switch language {
			case "ObjC":
				codegen = CGObjectiveCMCodeGenerator()
			case "Swift", "Silver":
				if platform == "Xcode" {
					codegen = CGSwiftCodeGenerator(dialect: .Standard)
				} else {
					codegen = CGSwiftCodeGenerator(dialect: .Silver)
				}
			case "Oxygene":
				codegen = CGOxygeneCodeGenerator(style: .Standard, quoteStyle: .SmartSingle)
			case "VC#":
				codegen = CGCSharpCodeGenerator(dialect: .Standard) // not currently used/needed
			case "C#":
				codegen = CGCSharpCodeGenerator(dialect: .Hydrogene)
			case "Iodine":
				codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Iodine)
			case "Java":
				codegen = CGJavaCodeGenerator(dialect: CGJavaCodeGeneratorDialect.Standard)
			case "JavaSript":
				codegen = CGJavaScriptCodeGenerator()
			case "Delphi":
				codegen = CGDelphiCodeGenerator()
			case "VB":
				codegen = CGVisualBasicNetCodeGenerator()
			case "BCB":
				codegen = CGCPlusPlusCPPCodeGenerator(dialect: .CPlusPlusBuilder)
				break
			default: return
		}
		switch platform {
			case ".NET":
				//rocodegen = CocoaRodlCodeGen(swiftDialect: .Standard)
				serverAccessCodegen = NetServerAccessCodeGen(rodl: rodlDocument!.rodlLibrary!)
			case "Xcode":
				rocodegen = CocoaRodlCodeGen(swiftDialect: .Standard)
				if codegen is CGSwiftCodeGenerator {
					(rocodegen as! CocoaRodlCodeGen).FixUpForAppleSwift()
				}
				serverAccessCodegen = CocoaServerAccessCodeGen(rodl: rodlDocument!.rodlLibrary!, generator: codegen!)
			case "Cocoa":
				rocodegen = CocoaRodlCodeGen(swiftDialect: .Silver)
				serverAccessCodegen = CocoaServerAccessCodeGen(rodl: rodlDocument!.rodlLibrary!, generator: codegen!)
			case "Java":
				rocodegen = JavaRodlCodeGen()
				serverAccessCodegen = JavaServerAccessCodeGen(rodl: rodlDocument!.rodlLibrary!)
			case "JavaSript":
				rocodegen = JavaScriptRodlCodeGen()
				serverAccessCodegen = nil
			case "Delphi":
				rocodegen = DelphiRodlCodeGen()
				serverAccessCodegen = DelphiServerAccessCodeGen(rodl: rodlDocument!.rodlLibrary!)
			default: return
		}

		let namespace = coalesce(rodlDocument!.rodlLibrary!.Namespace, "your.namespace")
		let filename = rodlDocument!.rodlLibrary!.Name+"_Intf"
		let serverAccessFilename = rodlDocument!.rodlLibrary!.Name+"_ServerAccess"

		if let codegen = codegen, let fileExtension = fileExtension {
			codegen.splitLinesLongerThan = 200

			if let rocodegen = rocodegen {
				rocodegen.Generator = codegen

				if language == "Java" {

					files = rocodegen.GenerateInterfaceFiles(rodlDocument.rodlLibrary, namespace)

				} else {

					let source = rocodegen.GenerateInterfaceFile(rodlDocument.rodlLibrary, namespace, filename)
					files[filename+fileExtension] = source

					if language == "ObjC" {
						rocodegen.Generator = CGObjectiveCHCodeGenerator()
						let sourceH = rocodegen.GenerateInterfaceFile(rodlDocument.rodlLibrary, namespace, filename)
						files[filename+".h"] = sourceH
					} else if language == "BCB" {
						rocodegen.Generator = CGCPlusPlusHCodeGenerator()
						let sourceH = rocodegen.GenerateInterfaceFile(rodlDocument.rodlLibrary, namespace, filename)
						files[filename+".h"] = sourceH
					}
				}

			}

			if let serverAccessCodegen = serverAccessCodegen {
				if generateServerAccessClass.state == NSOnState {
					let serverAccessUnit = serverAccessCodegen.generateCodeUnit()
					let serverAccessSource = codegen.GenerateUnit(serverAccessUnit)
					files[serverAccessFilename+fileExtension] = serverAccessSource
					if language == "ObjC" {
						let serverAccessSourceH = CGObjectiveCHCodeGenerator().GenerateUnit(serverAccessUnit)
						files[serverAccessFilename+".h"] = serverAccessSourceH
					} else if language == "BCB" {
						let serverAccessSourceH = CGCPlusPlusHCodeGenerator().GenerateUnit(serverAccessUnit)
						files[serverAccessFilename+"h"] = serverAccessSourceH
					}

				}
			}
		}
	}

	//func generateCodeWithCG2ForLanguage(_ language: String, platform: String) {

		//if let fileExtension = CGHelpers.FileExtensionForLanguage(language) {
			//if let codegen2 = NSBundle.mainBundle.pathForResource("codegen2", ofType: "") {
				//if let filename = rodlDocument!.saveTempRodl() {
					//__try
					//{
						//let task = NSTask()

						//var codeFileName = NSTemporaryDirectory().stringByAppendingPathComponent(NSUUID.UUID.UUIDString+"_Intf"+fileExtension)
						//task.arguments = ["/rodl:\(filename)",
										  //"/type:intf",
										  //"/lang:\(language.lowercaseString)",
										  //"/out:\(codeFileName)",
										  //"/libname:\(rodlDocument!.rodlLibrary!.Name)", // needs newer CODEGEN2
										  //"/namespace:\(rodlDocument!.rodlLibrary!.Name)"] // needs newer CODEGEN2

						////let env = ["MONO_MANAGED_WATCHER" : "false"]
						////task.environment = env

						//task.launchPath = codegen2
						//task.setStandardInput(NSPipe.pipe)
						//task.setStandardOutput(NSPipe.pipe)
						//task.setStandardError(NSPipe.pipe)
						//NSLog("Starting %@ %@", task.launchPath, task.arguments)
						//task.launch()

						//let output = processTaskOutput(task, name: "codegen2")

						//var prettyCodeFilename = rodlDocument!.rodlLibrary!.Name+"_Intf"+fileExtension
						//if NSFileManager.defaultManager.fileExistsAtPath(codeFileName) {
							//var encoding: NSStringEncoding = .UTF8StringEncoding
							//let source = try! String.stringWithContentsOfFile(codeFileName, usedEncoding: &encoding)
							//files[prettyCodeFilename] = source
							//try! NSFileManager.defaultManager.removeItemAtPath(codeFileName)

							////75094: Swift: inconsistent nullability inference
							//codeFileName = Path.ChangeExtension(codeFileName, ".h")
							//prettyCodeFilename = Path.ChangeExtension(prettyCodeFilename, ".h")
							//if NSFileManager.defaultManager.fileExistsAtPath(codeFileName) {
								//let sourceH = try! String.stringWithContentsOfFile(codeFileName, usedEncoding: &encoding)
								//files[prettyCodeFilename] = sourceH
								//try! NSFileManager.defaultManager.removeItemAtPath(codeFileName)
							//}

						//} else {
							//error = output
						//}
					//}
					//__finally
					//{
						//try! NSFileManager.defaultManager.removeItemAtPath(filename)
					//}
				//}
			//}
		//}
	//}

	func generateCodeWithCodeDomForLanguage(_ language: String) {

		if let fileExtension = CGHelpers.FileExtensionForLanguage(language) {
			if let rodl2code = NSBundle.mainBundle.pathForResource("rodl2code", ofType: "exe") {

				if let filename = rodlDocument!.saveTempRodl() {
					__try
					{
						let task = NSTask()
						task.arguments = [rodl2code, filename, "--type:Intf", "--platform:.NET", "--language:\(language)", "--namespace:\(rodlDocument!.rodlLibrary!.Name)"]

						//let env = ["MONO_MANAGED_WATCHER" : "false"]
						//task.environment = env

						task.launchPath = monoPath()
						task.setStandardInput(NSPipe.pipe)
						task.setStandardOutput(NSPipe.pipe)
						task.setStandardError(NSPipe.pipe)
						NSLog("Starting %@ %@", task.launchPath, task.arguments)
						task.launch()

						let output = processTaskOutput(task, name: "rodl2code.exe")

						let codeFileName = filename.stringByDeletingPathExtension+"_Intf"+fileExtension
						let prettyCodeFilename = rodlDocument!.rodlLibrary!.Name+"_Intf"+fileExtension
						if NSFileManager.defaultManager.fileExistsAtPath(codeFileName) {
							var encoding: NSStringEncoding = .UTF8StringEncoding
							let source = try! String.stringWithContentsOfFile(codeFileName, usedEncoding: &encoding)
							files[prettyCodeFilename] = source
							try! NSFileManager.defaultManager.removeItemAtPath(codeFileName)
						} else {
							error = output
						}
					}
					__finally
					{
						try! NSFileManager.defaultManager.removeItemAtPath(filename)
					}
				}
			}
		}
	}

	func processTaskOutput(_ task: NSTask, name: String) -> String {

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			let stdOut = task.standardError!.fileHandleForReading
			var lastIncompleteLogLine: String?

			while task.isRunning {
				autoreleasepool {
					/*result +=*/ self.processTaskOutputFromStdOut(stdOut, name: name+" (stderr)", lastIncompleteLogLine: &lastIncompleteLogLine)
					NSRunLoop.currentRunLoop().runUntilDate(NSDate.date)
				}
			}
			self.processTaskOutputFromStdOut(stdOut, name: name+" (stderr)", lastIncompleteLogLine: &lastIncompleteLogLine)
		}
		var result = ""
		let stdOut = task.standardOutput!.fileHandleForReading
		var lastIncompleteLogLine: String?

		while task.isRunning {
			autoreleasepool {
				result += self.processTaskOutputFromStdOut(stdOut, name: name, lastIncompleteLogLine: &lastIncompleteLogLine)
				NSRunLoop.currentRunLoop().runUntilDate(NSDate.date)
			}
		}
		result += self.processTaskOutputFromStdOut(stdOut, name: name, lastIncompleteLogLine: &lastIncompleteLogLine)
		return result
	}

	@discardableResult func processTaskOutputFromStdOut(_ stdOut: NSFileHandle, name: String, inout lastIncompleteLogLine: String?) -> String {
		var result = ""
		let d = stdOut.availableData;
		if (d != nil && d.length > 0) {
			var rawString = NSString(data: d, encoding: .NSUTF8StringEncoding)
			if let last = lastIncompleteLogLine {
				rawString = last.stringByAppendingString(rawString);
				lastIncompleteLogLine = nil;
			}
			let lines = rawString.componentsSeparatedByString("\n");
			for i in 0 ..< lines.count {
				let s: String = lines[i]!;
				if i == lines.count-1 && !s.hasSuffix("\n") {
					if s.length > 0 {
						lastIncompleteLogLine = s;
					}
					break;
				}
				let line = "[\(name)] \(s!)"
				result += line+"\n"
				dispatch_async(dispatch_get_main_queue()) {
					NSLog("%@", line);
				}
			}
		}
		return result
	}

	public var monoPath: String? {
		get {
			var result = "/usr/bin/mono"
			if NSFileManager.defaultManager.fileExistsAtPath(result) {
				return result
			}

			result = "/usr/local/bin/mono"
			if NSFileManager.defaultManager.fileExistsAtPath(result) {
				return result
			}

			result = "/Library/Frameworks/Mono.framework/Versions/Current/Commands/mono"
			if NSFileManager.defaultManager.fileExistsAtPath(result) {
				return result
			}
			return nil
		}
	}

	public var monoInstalled: Bool {
		get {
			return monoPath != nil
		}
	}

}