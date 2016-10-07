import RemObjects.SDK.CodeGen4
import Sugar

public class CGHelpers {

	public static func CodeGeneratorForLanguage(_ language: String) -> CGCodeGenerator? {
		switch language {
			case "oxygene", "pas":
				return CGOxygeneCodeGenerator(style: .Standard, quoteStyle: .SmartDouble)
			case "hydrogene", "cs", "c#", "csharp":
				return CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Hydrogene)
			case "standard-c#", "vc#":
				return CGCSharpCodeGenerator(dialect: CGCSharpCodeGeneratorDialect.Standard)
			case "silver", "swift":
				return CGSwiftCodeGenerator(dialect: CGSwiftCodeGeneratorDialect.Silver)
			case "standard-swift":
				return CGSwiftCodeGenerator(dialect: CGSwiftCodeGeneratorDialect.Standard)
			case "delphi":
				return CGDelphiCodeGenerator()
			case "java":
				return CGJavaCodeGenerator()
			case "javascript", "js":
				return CGJavaScriptCodeGenerator()
			default:
				return nil
		}
	}

	public static func FileExtensionForLanguage(_ language: String) -> String? {
		switch language.ToLower() {
			case "objc", "obj-c", "objectivec", "objective-c": return "m"
			case "swift", "silver": return "swift"
			case "pas", "oxygene", "delphi": return "pas"
			case "cs", "csharp", "c#","vc#","visual c#", "hydrogene": return "cs"
			case "vb", "vbnet", "vb.net", "visual basic", "visual basic.net": return "vb"
			case "java": return "java"
			case "js", "javascript": return "js"
			case "cpp", "c++","c++builder","bcb": return "cpp"
			default: return nil
		}
	}

}
