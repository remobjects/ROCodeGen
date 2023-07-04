import AppKit

@IBObject public class MainWindowController : NSWindowController {

	init() {
		super.init(windowNibName: "MainWindowController")
	}

	public override func windowDidLoad() {
		super.windowDidLoad()
	}

	@IBOutlet var serverUrlField: NSTextField!
	@IBOutlet var goButton: NSButton!

	@IBAction func go(_ sender: AnyObject?) {
		if let url = Url.TryUrlWithString(serverUrlField.stringValue) {
			NSDocumentController.sharedDocumentController.openDocumentWithContentsOfURL(url, display: true) { document, documentWasAlreadyOpen, error in }
		}
	}

	@IBAction func browse(_ sender: AnyObject?) {
		NSDocumentController.sharedDocumentController.openDocument(nil);
	}

}