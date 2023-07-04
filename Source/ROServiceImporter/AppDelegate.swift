import AppKit

@NSApplicationMain @IBObject class AppDelegate : INSApplicationDelegate {

	var mainWindowController: MainWindowController?

	@objc public func applicationDidFinishLaunching(_ notification: NSNotification!) {

		if let basePath = NSBundle.mainBundle.pathForResource("DataAbstract", ofType:"RODL") {
			//NSLog("basePath: %@", basePath)
			RodlCodeGen.KnownRODLPaths["dataabstract.rodl"] = basePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent("DataAbstract.RODL")
			RodlCodeGen.KnownRODLPaths["dataabstract4.rodl"] = basePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent("DataAbstract.RODL")
			RodlCodeGen.KnownRODLPaths["dataabstract-simple.rodl"] = basePath.stringByDeletingLastPathComponent.stringByAppendingPathComponent("DataAbstract-Simple.RODL")
		}
		mainWindowController = MainWindowController()
		mainWindowController?.showWindow(nil)
	}

}
