import RemObjects.SDK.CodeGen4

public __abstract class ServerAccessCodeGen {

	let rodl: RodlLibrary
	public var serverAddress: String?
	public var namespace: String?

	public init(rodl: RodlLibrary) {
		self.rodl = rodl
	}

	func isCodeGenerationRequired(_ service: RodlService!) -> Boolean {
		if service.DontCodegen {
			return false;
		}

		if service.FromUsedRodl != nil {
			return !service.FromUsedRodl.DontApplyCodeGen;
		}

		// If UsedRodl is null but its Id is set then special handling is required
		if service.FromUsedRodlId == Guid.EmptyGuid {
			return true;
		}

		for i in 0 ..< self.rodl.Uses.Count {
			let rodlUse = rodl.Uses[i]
			if rodlUse.UsedRodlId == service.FromUsedRodlId {
				return !rodlUse.DontApplyCodeGen;
			}
		}

		return true;
	}

	func isLoginService(_ serviceName: String) -> Boolean {
		return  serviceName.EqualsIgnoringCaseInvariant("LoginService");
	}

	func hasLoginService() -> Boolean{
		for i in 0 ..< rodl.Services.Count {
			let service = rodl.Services[i]
			if isCodeGenerationRequired(service) && isLoginService(service.Name) {
				return true
			}
		}
		return false;
	}

	public func generateCodeUnit() -> CGCodeUnit {

		let unit = CGCodeUnit()
		unit.FileName =  rodl.Name+"_ServerAccess"

		defineNamespace(unit)
		generateStandardImports(unit)
		generatUsedRodlImports(unit)

		let serverAccess = CGClassTypeDefinition("ServerAccess")
		serverAccess.Visibility = .Public

		unit.Types.Add(serverAccess)

		generateSingletonPattern(serverAccess)
		generateBasics(serverAccess)

		for i in 0 ..< rodl.Services.Count {
			let service = rodl.Services[i]
			if isCodeGenerationRequired(service) {
				generateService(serverAccess, service: service)
			}
		}

		if hasLoginService() {
			generateLoginPattern(serverAccess)
		}

		return unit
	}

	private func defineNamespace(_ unit: CGCodeUnit) {
		if let namespace = self.namespace {
			unit.Namespace = CGNamespaceReference(namespace)
		}
	}

	/*fileprivate*/internal func generateStandardImports(_ unit: CGCodeUnit) {
		// no-op, but platforms will override
	}

	/*fileprivate*/internal func generatUsedRodlImports(_ unit: CGCodeUnit) {
		for uses in rodl.Uses.Items {
			let platformNamespace = self.getPlatformSpecificNamespace(uses);
			if length(platformNamespace) > 0 {
				unit.Imports.Add(CGImport(CGNamespaceReference(platformNamespace)))
			} else {
				if length(uses.Namespace) > 0 {
					unit.Imports.Add(CGImport(CGNamespaceReference(uses.Namespace)))
				} else {
					unit.HeaderComment.Lines.Add(String.Format("Requires RODL file {0} ({1}) in same namespace.", [uses.Name, uses.FileName]));
				}
			}
		}
	}
	/*fileprivate*/internal __abstract func getPlatformSpecificNamespace(_ reference: RodlUse) -> String!;
	/*fileprivate*/internal __abstract func generateSingletonPattern(_ serverAccess: CGClassTypeDefinition)
	/*fileprivate*/internal __abstract func generateBasics(_ serverAccess: CGClassTypeDefinition)
	/*fileprivate*/internal __abstract func generateService(_ serverAccess: CGClassTypeDefinition, service: RodlService)
	/*fileprivate*/internal __abstract func generateLoginPattern(_ serverAccess: CGClassTypeDefinition)
}

public class CocoaServerAccessCodeGen : ServerAccessCodeGen {

	public init(rodl: RodlLibrary, generator: CGCodeGenerator) {
		super.init(rodl: rodl)
		self.generator = generator
		isAppleSwift = isSwift && (generator as! CGSwiftCodeGenerator).Dialect == CGSwiftCodeGeneratorDialect.Standard
	}
	let generator: CGCodeGenerator

	/*public init(rodl: RodlLibrary, isAppleSwift: Boolean = false) {
		super.init(rodl: rodl)
		self.isAppleSwift = isAppleSwift
	}*/

	var isSwift: Boolean { return isAppleSwift || generator is CGSwiftCodeGenerator }
	var isAppleSwift: Boolean
	var isElements: Boolean { return !(generator is CGObjectiveCCodeGenerator) && !isAppleSwift }

	override func generateStandardImports(_ unit: CGCodeUnit) {
		unit.Imports.Add(CGImport("Foundation"))
		unit.Imports.Add(CGImport("RemObjectsSDK"))
		unit.FileImports.Add(CGImport(rodl.Name+"_Intf"))
	}

	override func getPlatformSpecificNamespace(_ reference: RodlUse) -> String! {
		if length(reference.Includes?.CocoaModule) > 0 {
			return reference.Includes.CocoaModule;
		} else {
			return "";
		}
	}

	override func generateSingletonPattern(_ serverAccess: CGClassTypeDefinition) {
		let field = CGFieldDefinition("_sharedInstance", serverAccess.Name.AsTypeReference().NullableNotUnwrapped)
		serverAccess.Members.Add(field)
		field.Static = true

		let fieldAccess = CGFieldAccessExpression(CGSelfExpression.`Self`, "_sharedInstance")
		fieldAccess.CallSiteKind = .Static

		let property = CGPropertyDefinition("sharedInstance", serverAccess.Name.AsTypeReference().NotNullable)
		serverAccess.Members.Add(property)
		property.Static = true
		property.Visibility = .Public
		let ifInstantiated = CGIfThenElseStatement(CGAssignedExpression(fieldAccess, inverted: true),
		CGAssignmentStatement(fieldAccess, CGNewInstanceExpression(serverAccess.Name.AsTypeReference())))
		let propertyGetter = List<CGStatement>()
		propertyGetter.Add(ifInstantiated)
		propertyGetter.Add(CGUnaryOperatorExpression(fieldAccess, .ForceUnwrapNullable).AsReturnStatement())
		property.GetStatements = propertyGetter
	}

	override func generateBasics(_ serverAccess: CGClassTypeDefinition) {

		if isElements {
			serverAccess.ImplementedInterfaces.Add("IROClientChannelDelegate".AsTypeReference())
		} else {
			serverAccess.ImplementedInterfaces.Add("ROClientChannelDelegate".AsTypeReference())
		}

		//serverAccess.Members.Add(CGFieldDefinition("_message", "ROMessage".AsTypeReference().NotNullable))
		//serverAccess.Members.Add(CGFieldDefinition("_channel", "ROClientChannel".AsTypeReference().NotNullable))

		let addressProperty = CGPropertyDefinition("serverURL", (isSwift ? "URL" : "NSURL").AsTypeReference().NotNullable)
		serverAccess.Members.Add(addressProperty)
		addressProperty.Visibility = .Public
		addressProperty.ReadOnly = true

		var addressLiteral: CGExpression
		if let serverAddress = self.serverAddress {
			addressLiteral = serverAddress.AsLiteralExpression()
		} else {
			addressLiteral = "http://yourserver.example.com:8099/bin".AsLiteralExpression()
		}

		if isAppleSwift {
			let url = CGNewInstanceExpression("URL".AsTypeReference(), [addressLiteral.AsCallParameter("string")].ToList())
			addressProperty.Initializer = CGUnaryOperatorExpression(url, .ForceUnwrapNullable)
		} else {
			let url = CGMethodCallExpression("NSURL".AsTypeReferenceExpression(), "URLWithString", [addressLiteral.AsCallParameter()])
			addressProperty.Initializer = CGUnaryOperatorExpression(url, .ForceUnwrapNullable)
		}

		/*let ctor = CGConstructorDefinition()
		serverAccess.Members.Add(ctor)
		ctor.Visibility = .Private
		ctor.Virtuality = .Override
		ctor.Empty = true*/

		//let messageType = "ROBinMessage" // make configurabkle later on, maybe
		//let channelType = "ROHttpClientChannel" // make configurabkle later on, maybe
		//ctor.Statements.Add(CGAssignmentStatement(CGFieldAccessExpression(CGSelfExpression.`Self`, "_message"), CGNewInstanceExpression(messageType.AsTypeReference())))
		//ctor.Statements.Add(CGAssignmentStatement(CGFieldAccessExpression(CGSelfExpression.`Self`, "_message"), CGMethodCallExpression("ROClientChannel".AsTypeReferenceExpression(), "channelWithTargetURL", [url.AsCallParameter()])))

	}

	override func generateLoginPattern(_ serverAccess: CGClassTypeDefinition) {

		let needsLoginMethod = CGMethodDefinition(isAppleSwift ? "clientChannelNeedsLogin" : "clientChannelNeedsLoginOnMainThread")
		serverAccess.Members.Add(needsLoginMethod);
		let param = CGParameterDefinition("channel", "ROClientChannel".AsTypeReference())
		if isAppleSwift {
			param.ExternalName = "onMainThread"
		}
		needsLoginMethod.Parameters.Add(param)
		needsLoginMethod.Visibility = .Public
		needsLoginMethod.ReturnType = CGPredefinedTypeReference.Boolean
		needsLoginMethod.Statements.Add(CGCommentStatement("Implement authentication here by calling loginService.Login()"))
		needsLoginMethod.Statements.Add(CGBooleanLiteralExpression.False.AsReturnStatement())
		needsLoginMethod.Attributes.Add(CGAttribute("objc".AsTypeReference()))
	}

	override func generateService(_ serverAccess: CGClassTypeDefinition, service: RodlService) {
		if isLoginService(service.Name) {
			generateService(serverAccess, service: service, async: false)
		} else {
			generateService(serverAccess, service: service, async: true)
		}
	}

	func generateService(_ serverAccess: CGClassTypeDefinition, service: RodlService, async: Boolean) {
		let proxyType = async ? (service.Name+"_AsyncProxy").AsTypeReference() : (service.Name+"_Proxy").AsTypeReference()
		let property = CGPropertyDefinition(CGCodeGenerator.lowercaseFirstLetter(service.Name), proxyType.NotNullable)
		serverAccess.Members.Add(property)
		if isLoginService(service.Name) {
			property.Visibility = .Private
		} else {
			property.Visibility = .Public
		}

		//property.GetExpression = CGNewInstanceExpression(proxyType, [CGCallParameter(CGFieldAccessExpression(CGSelfExpression.`Self`, "_message"), "message"),
		//                                                             CGCallParameter(CGFieldAccessExpression(CGSelfExpression.`Self`, "_channel"), "channel")])

		let remoteService = "RORemoteService".AsTypeReference()
		let service = CGNewInstanceExpression(remoteService, [CGPropertyAccessExpression(CGSelfExpression.`Self`, "serverURL").AsCallParameter("targetURL"),
																					   service.Name.AsLiteralExpression().AsCallParameter("serviceName")])
		service.ConstructorName = "withTargetURL"

		let propertyGetter = List<CGStatement>()
		propertyGetter.Add(CGVariableDeclarationStatement("service", remoteService, service, readOnly: true))
		propertyGetter.Add(CGAssignmentStatement(CGPropertyAccessExpression(CGPropertyAccessExpression("service".AsNamedIdentifierExpression(), "channel"), "delegate"), CGSelfExpression.`Self`))

		var proxy = CGNewInstanceExpression(proxyType, ["service".AsNamedIdentifierExpression().AsCallParameter("service")])
		proxy.ConstructorName = "withService"
		propertyGetter.Add(proxy.AsReturnStatement())

		property.GetStatements = propertyGetter
	}
}

public class NetServerAccessCodeGen : ServerAccessCodeGen {

	public init(rodl: RodlLibrary, namespace namespace: String!) {
		super.init(rodl: rodl);
		self.namespace = namespace;
	}

	override func generateStandardImports(_ unit: CGCodeUnit) {
		unit.Imports.Add(CGImport("RemObjects.SDK"))
		// if let won't help here because namespace and RODL namespace can be non-NULL empty strings
		if (length(self.namespace) > 0) && (length(self.rodl.Namespace) > 0) && (self.namespace != self.rodl.Namespace) {
			unit.Imports.Add(CGImport(self.rodl.Namespace))
		}
	}

	override func getPlatformSpecificNamespace(_ reference: RodlUse) -> String! {
		if length(reference.Includes?.NetModule) > 0 {
			return reference.Includes.NetModule;
		} else {
			return "";
		}
	}

	override func generateSingletonPattern(_ serverAccess: CGClassTypeDefinition) {
		let serverAccessType = serverAccess.Name.AsTypeReferenceExpression()

		let field = CGFieldDefinition("_instance", serverAccess.Name.AsTypeReference().NullableNotUnwrapped)
		serverAccess.Members.Add(field)
		field.Static = true

		let fieldAccess = CGFieldAccessExpression(serverAccessType, "_instance")

		let property = CGPropertyDefinition("Instance", serverAccess.Name.AsTypeReference().NotNullable)
		serverAccess.Members.Add(property)
		property.Static = true
		property.Visibility = .Public

		let ifInstantiated = CGIfThenElseStatement(CGAssignedExpression(fieldAccess, inverted: true), CGAssignmentStatement(fieldAccess, CGNewInstanceExpression(serverAccess.Name.AsTypeReference())))
		let propertyGetter = List<CGStatement>()
		propertyGetter.Add(ifInstantiated)
		propertyGetter.Add(CGUnaryOperatorExpression(fieldAccess, .ForceUnwrapNullable).AsReturnStatement())
		property.GetStatements = propertyGetter
	}

	override func generateBasics(_ serverAccess: CGClassTypeDefinition) {
		let field = CGFieldDefinition("_serverUrl", "System.String".AsTypeReference().NotNullable)
		serverAccess.Members.Add(field)

		let addressProperty = CGPropertyDefinition("ServerUrl", "System.String".AsTypeReference().NotNullable)
		serverAccess.Members.Add(addressProperty)
		addressProperty.Visibility = .Public

		let propertyGetter = List<CGStatement>()
		propertyGetter.Add(CGUnaryOperatorExpression(CGFieldAccessExpression(CGSelfExpression.`Self`, "_serverUrl"), .ForceUnwrapNullable).AsReturnStatement())
		addressProperty.GetStatements = propertyGetter

		let ctor = CGConstructorDefinition()
		serverAccess.Members.Add(ctor)
		ctor.Visibility = .Public

		ctor.Statements = List<CGStatement>()

		if let serverAddress = self.serverAddress {
			ctor.Statements.Add(CGAssignmentStatement(CGFieldAccessExpression(CGSelfExpression.`Self`, "_serverUrl"), self.serverAddress!.AsLiteralExpression()))
		} else {
			ctor.Statements.Add(CGAssignmentStatement(CGFieldAccessExpression(CGSelfExpression.`Self`, "_serverUrl"), "http://yourserver.example.com:8099/bin".AsLiteralExpression()))
		}
	}

	override func generateLoginPattern(_ serverAccess: CGClassTypeDefinition) {
		// Not implemented
	}

	override func generateService(_ serverAccess: CGClassTypeDefinition, service: RodlService) {
		generateService(serverAccess, serviceName: service.Name, isAsync: false)
		generateService(serverAccess, serviceName: service.Name, isAsync: true)
	}

	private func generateService(_ serverAccess: CGClassTypeDefinition, serviceName: String, isAsync: Boolean) {
		var propertyName: String
		var proxyInterfaceType: CGTypeReference
		var proxyClassType: CGTypeReference
		if (isAsync) {
			propertyName = serviceName + "Async"
			proxyInterfaceType = ("I" + serviceName + "_Async").AsTypeReference()
			proxyClassType = ("Co" + serviceName + "Async").AsTypeReference()
		} else {
			propertyName = serviceName
			proxyInterfaceType = ("I" + serviceName).AsTypeReference()
			proxyClassType = ("Co" + serviceName).AsTypeReference()
		}

		let property = CGPropertyDefinition(propertyName, proxyInterfaceType.NotNullable)
		serverAccess.Members.Add(property)
		property.Visibility = .Public

		let propertyGetter = List<CGStatement>()
		let create = CGMethodCallExpression(CGTypeReferenceExpression(proxyClassType), "Create", [ CGPropertyAccessExpression(CGSelfExpression.`Self`, "ServerUrl").AsCallParameter("url") ])
		propertyGetter.Add(CGUnaryOperatorExpression(create, .ForceUnwrapNullable).AsReturnStatement()) // workaround, while CodeDom-based CG cant emit non-nullable Co* methods
		property.GetStatements = propertyGetter
	}
}

public class JavaServerAccessCodeGen : ServerAccessCodeGen {
	override func getPlatformSpecificNamespace(_ reference: RodlUse) -> String! {
		if length(reference.Includes?.JavaModule) > 0 {
			return reference.Includes.JavaModule;
		} else {
			return "";
		}
	}
	override func generateSingletonPattern(_ serverAccess: CGClassTypeDefinition) {
	}
	override func generateBasics(_ serverAccess: CGClassTypeDefinition) {
	}
	override func generateService(_ serverAccess: CGClassTypeDefinition, service: RodlService) {
	}
	override func generateLoginPattern(_ serverAccess: CGClassTypeDefinition) {
	}

	func generateFiles(_ generator: CGCodeGenerator) -> Dictionary<String,String> {
		let result = Dictionary<String,String>()
		//var lnamespace := iif(String.IsNullOrEmpty(aTargetNamespace), library.Namespace,aTargetNamespace);
		let unit = generateCodeUnit()
		for k in unit.Types {
			result.Add(Path.ChangeExtension(k.Name, generator.defaultFileExtension), generator.GenerateUnitForSingleType(k, unit: unit))
		}
		return result
	}
}

public class DelphiServerAccessCodeGen : ServerAccessCodeGen {

	var lunit: CGCodeUnit!;
	var ch_name: String!;
	var mes_name: String!;
	var server_Address: String!;
	var serverAccessName1: String!;
	var serverAccessName2: String!;
	let string_type = CGNamedTypeReference("String", isClassType:false)
	private var dfm: StringBuilder = StringBuilder();

	override func getPlatformSpecificNamespace(_ reference: RodlUse) -> String! {
		if length(reference.Includes?.DelphiModule) > 0 {
			return reference.Includes.DelphiModule;
		} else {
			return "";
		}
	}

	func generateInclude() {
		lunit.Directives.Add("{$I RemObjects.inc}".AsCompilerDirective());
	}

	func generateImplementationInclude() {
		lunit.ImplementationDirectives.Add("{$IFDEF DELPHIXE2}".AsCompilerDirective());
		lunit.ImplementationDirectives.Add("  {%CLASSGROUP 'System.Classes.TPersistent'}".AsCompilerDirective());
		lunit.ImplementationDirectives.Add("{$ENDIF}".AsCompilerDirective());
		lunit.ImplementationDirectives.Add("{$R *.dfm}".AsCompilerDirective());
	}

	func generatePragma(_ value: String) {
		//empty
	}

	func generateImport(_ aName: String, aExt: String, aNamespace: String, aGeneratePragma: Boolean)-> CGImport{
		if String.IsNullOrEmpty(aNamespace) {
			return CGImport(CGNamedTypeReference(aName))
		}else{
			return CGImport("{$IFDEF DELPHIXE2UP}"+aNamespace+"."+aName+"{$ELSE}"+aName+"{$ENDIF}");
		}
	}

	override func generatUsedRodlImports(_ unit: CGCodeUnit) {
		for uses in rodl.Uses.Items {
			let platformNamespace = self.getPlatformSpecificNamespace(uses);
			if length(platformNamespace) > 0 {
				unit.Imports.Add(generateImport(platformNamespace+"_Intf", aExt:  "hpp", aNamespace:  "", aGeneratePragma: true))
			 } else {
				unit.Imports.Add(generateImport(uses.Name+"_Intf", aExt:  "h", aNamespace:  "", aGeneratePragma: true))
			}
		}
	}

	override func generateStandardImports(_ unit: CGCodeUnit) {
		self.lunit = unit; // store unit for later usage;
		unit.FileName = rodl.Name+"_ServerAccess";
		if unit.Namespace == nil {
			var ns = rodl.Name;
			if let ls = rodl.Namespace {
				ns = ls;
			}
			unit.Namespace = CGNamespaceReference(ns);
		}
		generateInclude()
		generateImplementationInclude()
		generatePragma(rodl.Name + "_Intf")

		// add some std units like SysUtils, Classes, etc
		unit.Imports.Add(generateImport("SysUtils", aExt: "hpp", aNamespace:"System", aGeneratePragma: false));
		unit.Imports.Add(generateImport("Classes", aExt: "hpp", aNamespace:"System", aGeneratePragma: false));
		unit.Imports.Add(generateImport("uROComponent", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
		unit.Imports.Add(generateImport("uROMessage", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
		unit.Imports.Add(generateImport("uROBaseConnection", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
		unit.Imports.Add(generateImport("uROTransportChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));

		// generate message & channel
		ch_name = "TROIndyHTTPChannel";
		mes_name = "TROBinMessage";

		if let serverAddress = self.serverAddress {
			server_Address = self.serverAddress!;
			let sa = self.serverAddress!.ToLower();
			if sa.EndsWith("/bin") {
				lunit.Imports.Add(generateImport("uROBinMessage", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				mes_name = "TROBinMessage";
			}
			else if sa.EndsWith("/soap") {
				lunit.Imports.Add(generateImport("uROSOAPMessage", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				mes_name = "TROSOAPMessage";
			}
			else if sa.EndsWith("/post") {
				lunit.Imports.Add(generateImport("uROPostMessage", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				mes_name = "TROPostMessage";
			}
			else if sa.EndsWith("/xmlrpc") {
				lunit.Imports.Add(generateImport("uROXmlRpcMessage", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				mes_name = "TROXmlRpcMessage";
			}
			if sa.StartsWith("http://") || sa.StartsWith("https://") {
				lunit.Imports.Add(generateImport("uROBaseHTTPClient", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				lunit.Imports.Add(generateImport("uROIndyHTTPChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				ch_name = "TROIndyHTTPChannel";
			}
			else if sa.StartsWith("tcp://") {
				lunit.Imports.Add(generateImport("uROIndyTCPChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				ch_name = "TROIndyTCPChannel";
			}
			else if sa.StartsWith("superhttp://") {
				lunit.Imports.Add(generateImport("uROBaseActiveEventChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				lunit.Imports.Add(generateImport("uROBaseSuperChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				lunit.Imports.Add(generateImport("uROBaseSuperHttpChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				lunit.Imports.Add(generateImport("uROIndySuperHttpChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				ch_name = "TROIndySuperHTTPChannel";
			}
			else if sa.StartsWith("supertcp://") {
				lunit.Imports.Add(generateImport("uROBaseActiveEventChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				lunit.Imports.Add(generateImport("uROBaseSuperChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				lunit.Imports.Add(generateImport("uROBaseSuperTCPChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				lunit.Imports.Add(generateImport("uROSuperTCPChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
				ch_name = "TROSuperTCPChannel";
			}
		} else {
			server_Address = "http://yourserver.example.com:8099/bin";
			lunit.Imports.Add(generateImport("uROBinMessage", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
			lunit.Imports.Add(generateImport("uROBaseHTTPClient", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
			lunit.Imports.Add(generateImport("uROIndyHTTPChannel", aExt: "hpp", aNamespace:"", aGeneratePragma: true));
		}
		unit.Imports.Add(generateImport(rodl.Name+"_Intf", aExt: "h", aNamespace:"" , aGeneratePragma: false));
	}

	override func generateSingletonPattern(_ serverAccess: CGClassTypeDefinition) {
		serverAccessName1 = serverAccess.Name+"_"+rodl.Name;
		serverAccessName2 = "T" + serverAccessName1;
		let serverAccessType = serverAccessName2.AsTypeReference()

		let const = CGFieldDefinition("SERVER_URL");
		const.Constant = true;
		const.Initializer = server_Address.AsLiteralExpression();
		lunit.Globals.Add(const.AsGlobal());

		let fld = CGFieldDefinition("fServerAccess", serverAccessType);
		fld.Visibility = CGMemberVisibilityKind.Private;
		lunit.Globals.Add(fld.AsGlobal());

		let fServerAccess = CGLocalVariableAccessExpression("fServerAccess");

		let meth = CGMethodDefinition("ServerAccess");
		meth.ReturnType = serverAccessType;
		meth.CallingConvention = CGCallingConventionKind.Register;
		meth.Visibility = CGMemberVisibilityKind.Public;
		meth.Statements.Add(CGIfThenElseStatement(CGAssignedExpression(fServerAccess, inverted: true),
												  CGAssignmentStatement(fServerAccess,
																		 CGNewInstanceExpression(serverAccessType,[CGNilExpression.Nil.AsCallParameter()]))));
		meth.Statements.Add(CGReturnStatement(fServerAccess));
		lunit.Globals.Add(meth.AsGlobal());

		let initblock = List<CGStatement>();
		//initblock.Add(CGAssignmentStatement(fServerAccess, CGNilExpression.Nil));
		lunit.Initialization = initblock;
		let finalblock = List<CGStatement>();
		finalblock.Add(CGDestroyInstanceExpression(fServerAccess));
		lunit.Finalization = finalblock;
	}

	override func generateBasics(_ serverAccess: CGClassTypeDefinition) {
		serverAccess.Name = serverAccessName2;
		serverAccess.Visibility = CGTypeVisibilityKind.Public;
		serverAccess.Ancestors.Add("TDataModule".AsTypeReference())

		dfm.AppendLine("object " + serverAccessName1 + ": " + serverAccessName2)
		dfm.AppendLine("  OldCreateOrder = False")
		dfm.AppendLine("  OnCreate = DataModuleCreate")
		dfm.AppendLine("  Height = 150")
		dfm.AppendLine("  Width = 215")

		#region Message
		let lmes = CGFieldDefinition("Message",mes_name.AsTypeReference());
		lmes.Visibility = .Published;
		serverAccess.Members.Add(lmes);
		dfm.AppendLine("  object Message: " + mes_name)
		dfm.AppendLine("    Envelopes = <>")
		dfm.Append    ("    DefaultNamespaces = '")
		if let ns = lunit.Namespace {
			dfm.Append(ns.Name)
		}
		for uses in rodl.Uses.Items {
			dfm.Append(";");
			let platformNamespace = self.getPlatformSpecificNamespace(uses);
			if length(platformNamespace) > 0 {
				dfm.Append(platformNamespace)
			} else {
				dfm.Append(uses.Name)
			}
		}
		dfm.AppendLine("'")
		dfm.AppendLine("    Left = 40")
		dfm.AppendLine("    Top = 24")
		dfm.AppendLine("  end")
		#endregion

		#region Channel
		let ch = CGFieldDefinition("Channel",ch_name.AsTypeReference());
		ch.Visibility = .Published;
		serverAccess.Members.Add(ch);
		dfm.AppendLine("  object Channel: " + ch_name)
		dfm.AppendLine("    DispatchOptions = []")
		if hasLoginService() {
			dfm.AppendLine("    OnLoginNeeded = ChannelLoginNeeded")
		}
		dfm.AppendLine("    ServerLocators = <>")
		dfm.AppendLine("    TargetUrl = '" + server_Address + "'")
		dfm.AppendLine("    Left = 40")
		dfm.AppendLine("    Top = 80")
		dfm.AppendLine("  end")
		#endregion
		dfm.AppendLine("end")

		#region DataModuleCreate
		let ctor = CGMethodDefinition("DataModuleCreate");
		ctor.Parameters.Add(CGParameterDefinition("Sender", "TObject".AsTypeReference()));
		ctor.Visibility = .Published
		ctor.CallingConvention = .Register
		ctor.Statements = List<CGStatement>()
		let fServerUrl = CGFieldAccessExpression(CGSelfExpression.`Self`, "fServerUrl")
		fServerUrl.CallSiteKind = .Reference;
		ctor.Statements.Add(CGAssignmentStatement(fServerUrl, "SERVER_URL".AsNamedIdentifierExpression()))
		var ch1 = CGFieldAccessExpression(CGSelfExpression.`Self`,"Channel");
		ch1.CallSiteKind = CGCallSiteKind.Reference;
		var TargetUrl = CGFieldAccessExpression(ch1,"TargetUrl");
		TargetUrl.CallSiteKind = CGCallSiteKind.Reference;
		ctor.Statements.Add(CGAssignmentStatement(TargetUrl, fServerUrl))
		serverAccess.Members.Add(ctor)
		#endregion

		#region fServerUrl
		let field = CGFieldDefinition("fServerUrl", string_type)
		field.Visibility = .Private;
		serverAccess.Members.Add(field);
		#endregion

		#region ServerUrl
		let addressProperty = CGPropertyDefinition("ServerUrl", string_type)
		addressProperty.Visibility = .Public
		let propertyGetter = List<CGStatement>()
		let serverurl = CGFieldAccessExpression(CGSelfExpression.`Self`, "fServerUrl")
		serverurl.CallSiteKind = .Reference;
		propertyGetter.Add(serverurl.AsReturnStatement())
		addressProperty.GetStatements = propertyGetter
		serverAccess.Members.Add(addressProperty)
		#endregion

	}

	override func generateLoginPattern(_ serverAccess: CGClassTypeDefinition) {
		var needsLoginMethod = CGMethodDefinition("ChannelLoginNeeded");
		needsLoginMethod.Visibility = .Published;
		needsLoginMethod.CallingConvention = .Register
		needsLoginMethod.Parameters.Add(CGParameterDefinition("Sender", "TROTransportChannel".AsTypeReference()));
		needsLoginMethod.Parameters.Add(CGParameterDefinition("anException", "Exception".AsTypeReference()));
		var aParam = CGParameterDefinition("aRetry", CGPredefinedTypeReference(.Boolean));
		aParam.Modifier = .Var;
		needsLoginMethod.Parameters.Add(aParam);
		needsLoginMethod.Statements.Add(CGCommentStatement("Implement authentication here by calling LoginService.needsLoginMethod"))
		needsLoginMethod.Statements.Add(CGAssignmentStatement("aRetry".AsNamedIdentifierExpression(), CGBooleanLiteralExpression.False));
		serverAccess.Members.Add(needsLoginMethod);
	}

	override func generateService(_ serverAccess: CGClassTypeDefinition, service: RodlService) {
		generateService(serverAccess, serviceName: service.Name, suffix: "")
		generateService(serverAccess, serviceName: service.Name, suffix: "_Async")
		generateService(serverAccess, serviceName: service.Name, suffix: "_AsyncEx")
	}

	/*fileprivate*/internal func generateInterfaceType(_ aName: String) -> CGTypeReference{
		return aName.AsTypeReference()
	}


	/*fileprivate*/internal func generateService(_ serverAccess: CGClassTypeDefinition, serviceName: String, suffix: String) {
		var propertyName: String
		var proxyInterfaceType: CGTypeReference
		let pa = CGPropertyAccessExpression(CGSelfExpression.`Self`, "ServerUrl")

		propertyName = serviceName+suffix
		proxyInterfaceType = generateInterfaceType("I" + serviceName+suffix)

		let property = CGPropertyDefinition(propertyName, proxyInterfaceType.NotNullable)
		serverAccess.Members.Add(property)
		property.Visibility = .Public
		var proxyClassType = ("Co" + serviceName+suffix).AsNamedIdentifierExpression()
		let propertyGetter = List<CGStatement>()
		pa.CallSiteKind = .Reference;
		var ch = CGFieldAccessExpression(CGSelfExpression.`Self`,"Channel");
		ch.CallSiteKind = CGCallSiteKind.Reference;
		var mes = CGFieldAccessExpression(CGSelfExpression.`Self`,"Message");
		mes.CallSiteKind = CGCallSiteKind.Reference;
		let mc = CGMethodCallExpression(proxyClassType,"Create", [mes.AsCallParameter(), ch.AsCallParameter()]);
		mc.CallSiteKind = .Static
		propertyGetter.Add(mc.AsReturnStatement())
		property.GetStatements = propertyGetter
	}

	public func generateDFM() -> String    {
		return dfm.ToString();
	}
}

public class CPlusPlusBuilderServerAccessCodeGen : DelphiServerAccessCodeGen {

	override func generateBasics(_ serverAccess: CGClassTypeDefinition) {
		super.generateBasics(serverAccess);
		var ctor = CGConstructorDefinition();
		ctor.Parameters.Add(CGParameterDefinition("Owner","TComponent".AsTypeReference()));
		ctor.Virtuality = CGMemberVirtualityKind.Virtual;
		ctor.Visibility = CGMemberVisibilityKind.Public;
		ctor.CallingConvention = CGCallingConventionKind.Register;
		serverAccess.Members.Add(ctor);
	}

	override func generateService(_ serverAccess: CGClassTypeDefinition, serviceName: String, suffix: String) {
		var propertyName: String
		var proxyInterfaceType: CGTypeReference
		let pa = CGPropertyAccessExpression(CGSelfExpression.`Self`, "ServerUrl")

		propertyName = serviceName+suffix
		proxyInterfaceType = generateInterfaceType("I" + serviceName+suffix)

		let property = CGPropertyDefinition(propertyName, proxyInterfaceType.NotNullable)
		serverAccess.Members.Add(property)
		property.Visibility = .Public
		var proxyClassType = ("Co" + serviceName+suffix).AsNamedIdentifierExpression()
		let propertyGetter = List<CGStatement>()
		pa.CallSiteKind = .Reference;
		var ch = CGFieldAccessExpression(CGSelfExpression.`Self`,"Channel");
		ch.CallSiteKind = CGCallSiteKind.Reference;
		var ch1 = CGMethodCallExpression(ch, "operator _di_IROTransportChannel");
		ch1.CallSiteKind = .Reference;
		var mes = CGFieldAccessExpression(CGSelfExpression.`Self`,"Message");
		mes.CallSiteKind = CGCallSiteKind.Reference;
		var mes1 = CGMethodCallExpression(mes, "operator _di_IROMessage");
		mes1.CallSiteKind = CGCallSiteKind.Reference;
		let mc = CGMethodCallExpression(proxyClassType,"Create", [mes1.AsCallParameter(), ch1.AsCallParameter()]);
		mc.CallSiteKind = .Static
		propertyGetter.Add(mc.AsReturnStatement())
		property.GetStatements = propertyGetter
	}



	override func generateInterfaceType(_ aName: String) -> CGTypeReference {
		return CGNamedTypeReference("_di_"+aName, isClassType:false)
	}

	override func generateInclude() {
		// empty
	}

	override func generateImplementationInclude() {
		  lunit.ImplementationDirectives.Add(CGCompilerDirective("#pragma package(smart_init)"));
		  lunit.ImplementationDirectives.Add(CGCompilerDirective("#pragma classgroup \"System.Classes.TPersistent\""));
		  lunit.ImplementationDirectives.Add(CGCompilerDirective("#pragma resource \"*.dfm\""));
	}
	override func generatePragma(_ value: String) {
		lunit.ImplementationDirectives.Add(CGCompilerDirective("#pragma link \""+value+"\""));
	}

	override func generateImport(_ aName: String, aExt: String, aNamespace: String, aGeneratePragma: Boolean)-> CGImport{
		if aGeneratePragma {
			var lname = aName;
			if !String.IsNullOrEmpty(aNamespace) {
				lname = aNamespace + "." + lname;
			}
			generatePragma(lname);
		}

		let lns = aName+"."+aExt;
		if aExt == "hpp" {
			if String.IsNullOrEmpty(aNamespace) {
				return CGImport(lns)
			}
			else {
				return CGImport(CGNamedTypeReference(aNamespace + "." + lns))
			}
		}else{
			return CGImport(CGNamespaceReference(iif(String.IsNullOrEmpty(aNamespace), "",aNamespace+".")+lns))
		}
	}

}