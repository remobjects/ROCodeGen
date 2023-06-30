import AppKit

@objc public class RodlDocumentController : NSDocumentController {

	public override func typeForContentsOfURL(_ url: NSURL, inout error outError: NSError!) -> NSString! {
		return "RODL"
	}

	public override func openUntitledDocumentAndDisplay(_ displayDocument: Bool, error outError: inout NSError!) -> id<NSDocument!>! {
		NSLog("openUntitledDocumentAndDisplay")
		return nil
	}
}