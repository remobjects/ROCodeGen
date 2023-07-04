import Foundation
import AppKit

@objc public class RodlDocument : NSDocument {

	public override func makeWindowControllers() {
		addWindowController(RodlDocumentWindowController(document: self));
	}

	public private(set) var loaded = false
	public var loadedCallback: ((NSError?) -> ())? {
		didSet {
			if loaded, let loadedCallback = self.loadedCallback {
				loadedCallback(nil)
			}
		}
	}

	public var rodlUrl: NSURL?
	public var rodlLibrary: RodlLibrary?
	public var error: Object?

	public override func readFromData(_ data: NSData, ofType type: NSString, error: inout NSError!) -> Bool {

		switch type {
			case "remoteRODL":
				fallthrough
			case "RODL":
				loadRodl(data: data)
				return true
			case "WSDL":
				loadWsdl(data: data)
				return true
			default:
				return false
		}
	}

	public override func readFromURL(_ url: NSURL, ofType typeName: String, error: inout NSError!) -> Bool {
		rodlUrl = url
		return loadRodl(url: url)
	}

	public override func readFromFile(_ file: NSString, ofType typeName: String) -> Bool {
		rodlUrl = NSURL.fileURLWithPath(file)
		if let rodlUrl = rodlUrl {
			return loadRodl(url:rodlUrl)
		}
		return false
	}

	func loadRodl(data: NSData) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			if let xml = XmlDocument.TryFromBinary(data) {
				self.loadRodl(xml: xml)
			}
		}
	}

	func loadRodl(url: Url) -> Bool {
		rodlUrl = url;
		//NSLog("downloading xml from %@", url);
		if url.Scheme == "file" {
			loadRodl(data: NSData.dataWithContentsOfURL(url))
			return true;
		}
		Http.ExecuteRequestAsXml(HttpRequest(url, HttpRequestMode.Get)) { response in
			if response.Success {
				if let xml = response.Content {
					//NSLog("xml %@", xml)
					self.loadRodl(xml: xml)
				}
			} else {
				NSLog("Error retrieving RODL file from %@: %@", url, response.Exception.Message)
				self.error = "Error reading RODL file from \(url): \(response.Exception.Message)"
				if let loadedCallback = self.loadedCallback {
					dispatch_async(dispatch_get_main_queue()) {
						loadedCallback(nil)
					}
				}
			}
		}
		return true
	}

	func loadRodl(xml: XmlDocument) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			do {
				if xml.Root?.LocalName == "Library" {
					self.rodlLibrary = RodlLibrary(xml.Root)
					if let rodlUrl =self.rodlUrl?, rodlUrl.isFileURL {
						self.rodlLibrary?.Filename = rodlUrl.path
					}
					self.loaded = true
					if let loadedCallback = self.loadedCallback {
						dispatch_async(dispatch_get_main_queue()) {
							loadedCallback(nil)
						}
					}
				} else if xml.Root?.LocalName == "RemoteRodl" {
					self.rodlLibrary = RodlLibrary()
					NSLog("loadRemoteRodlData")
					self.rodlLibrary!.LoadRemoteRodlFromXmlNode(xml.Root)
					// LoadRemoteRodlFromXmlNode will set rodlLibrary?.Filename
					self.loaded = true
					if let loadedCallback = self.loadedCallback {
						dispatch_async(dispatch_get_main_queue()) {
							loadedCallback(nil)
						}
					}
				}
			} catch {
				NSLog("Error reading RODL file: %@", error)
				self.error = "Error reading RODL file: \(error)"
				if let loadedCallback = self.loadedCallback {
					dispatch_async(dispatch_get_main_queue()) {
						loadedCallback(nil)
					}
				}
			}
		}
	}

	func loadWsdl(data: NSData) {
	}

	func saveTempRodl() -> String? {
		if let rodlLibrary = rodlLibrary {
			var filename = NSTemporaryDirectory().stringByAppendingPathComponent("\(NSUUID.UUID.UUIDString).rodl");
			rodlLibrary.SaveToFile(filename)
			return filename
		}
		return nil
	}


}