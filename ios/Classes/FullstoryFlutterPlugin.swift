import Flutter
import FullStory
import shared_flutter
import UIKit

@objc class FlutterCaptureResult: NSObject {
    @objc public var viewData: NSData
    @objc public var viewId: NSNumber
    @objc public var canvases: NSData
    @objc public var strings: [NSString]
    @objc public var error: NSString?

    public init(viewData: NSData, viewId: NSNumber, canvases: NSData, strings: [NSString], error: NSString?) {
        self.viewData = viewData
        self.viewId = viewId
        self.canvases = canvases
        self.strings = strings
        self.error = error
        super.init()
    }
}

@objc class FlutterDelegate: NSObject {
    var plugin: FullstoryFlutterPlugin
    public init(plugin: FullstoryFlutterPlugin) {
        self.plugin = plugin
        super.init()
    }

    @objc public func captureFlutterView(_ viewId: UInt64, scanMode: Int, consented: Bool, onResult: @escaping (FlutterCaptureResult) -> Void) {
        plugin.scanUi(scanMode: Int32(scanMode), consent: consented) { (viewData, canvases, strings, error) in
            let result = FlutterCaptureResult(viewData: viewData, viewId: NSNumber(value: viewId), canvases: canvases, strings: strings as [NSString], error: error as NSString?)
            onResult(result)
        }
    }
}

public class FullstoryFlutterPlugin: NSObject, FlutterPlugin, FSDelegate {
    var channel: FlutterMethodChannel
    private var pages: [Int: FullStory.FSPage] = [:]
    private var nextPageID: Int = 0

    init(channel: FlutterMethodChannel) {
        self.channel = channel;
        super.init()
        FS.delegate = self;
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fullstory_flutter", binaryMessenger: registrar.messenger())
        let instance = FullstoryFlutterPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // print("Fullstory method call received:", call.method, call.arguments ?? "")
        switch call.method {
        case "fsVersion":
            result(FS.fsVersion())
        case "shutdown":
            FS.shutdown()
            result(nil)
        case "restart":
            FS.restart()
            result(nil)
        case "log":
            guard let args = call.arguments as? [String: Any],
                  let level = args["level"] as? UInt8,
                  let message = args["message"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Invalid arguments for log, expected {level: Uint8, message: String}, got \(String(describing: call.arguments))",
                                    details: nil))
                return
            }
            var levelValue: FSEventLogLevel;
            switch level {
            case 0:
                levelValue = FSLOG_DEBUG
            case 1:
                levelValue = FSLOG_INFO
            case 2:
                levelValue = FSLOG_WARNING
            case 3:
                levelValue = FSLOG_ERROR
            default:
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Unexpected log level, expected value 0-3, got \(level)",
                                    details: nil))
                return
            }
            FS.log(with: levelValue, message: message)
            result(nil)
        case "resetIdleTimer":
            FS.resetIdleTimer()
            result(nil)
        case "event":
            guard let args = call.arguments as? [String: Any],
                  let eventName = args["name"] as? String,
                  let properties = args["properties"] as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Invalid arguments for event: expected name and properties, got \(String(describing: call.arguments))",
                                    details: nil))
                return
            }

            print("FS.event:", eventName, properties);
            FS.event(eventName, properties: properties)
            result(nil)
        case "consent":
            guard let consented = call.arguments as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Invalid argument for consent. Expected Bool, got \(String(describing: call.arguments))",
                                    details: nil))
                return
            }
            FS.consent(consented)
            result(nil)
        case "identify":
            // todo: consider handling null or false uid as FS.anonymize()
            guard let args = call.arguments as? [String: Any],
                  let uid = args["uid"] as? String,
                  let userVars = args["userVars"] as? [String: Any]? else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Invalid arguments for identify: expected string uid and optional map userVars, got \(String(describing: call.arguments))",
                                    details: nil))
                return
            }
            if (userVars != nil) {
                FS.identify(uid, userVars: userVars!)
            } else {
                FS.identify(uid)
            }

            result(nil)
        case "anonymize":
            FS.anonymize()
            result(nil)
        case "setUserVars":
            guard let userVars = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Invalid argument for setUserVars",
                                    details: "Expected Map<String, Any>, got \(String(describing: call.arguments))"))
                return
            }
            FS.setUserVars(userVars)
            result(nil)
        case "getCurrentSession":
            result(FS.currentSession)
        case "getCurrentSessionURL":
            guard let now = call.arguments as? Bool else {
                result(FS.currentSessionURL)
                return
            }
            result(FS.currentSessionURL(now))
        case "page":
            if let args = call.arguments as? [String: Any],
               let pageName = args["pageName"] as? String,
               let properties = args["properties"] as? [String: Any] {
                let page = FS.page(withName: pageName, properties: properties)
                let pageId = self.nextPageID
                self.nextPageID += 1
                self.pages[pageId] = page
                result(pageId)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Page name and properties are required", details: nil))
            }
        case "startPage":
            if let args = call.arguments as? [String: Any],
               let pageId = args["pageId"] as? Int,
               let propertyUpdates = args["propertyUpdates"] as? [String: Any] {
                if let page = self.pages[pageId] {
                    page.start(withPropertyUpdates: propertyUpdates)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_PAGE", message: "No active page found with the given ID", details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Page ID and propertyUpdates are required", details: nil))
            }
        case "endPage":
            if let pageId = call.arguments as? Int,
               let page = self.pages[pageId] {
                page.end()
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_PAGE", message: "No active page found with the given ID", details: nil))
            }
        case "updatePageProperties":
            if let args = call.arguments as? [String: Any],
               let pageId = args["pageId"] as? Int,
               let properties = args["properties"] as? [String: Any],
               let page = self.pages[pageId] {
                page.updateProperties(properties)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_PAGE", message: "No active page found with the given ID", details: nil))
            }
        case "releasePage":
            if let pageId = call.arguments as? Int {
                self.pages.removeValue(forKey: pageId)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_PAGE", message: "No active page found with the given ID", details: nil))
            }
        case "captureEvent":
            if let args = call.arguments as? [String: Any] {
                if let FS = NSClassFromString("FS") {
                    let sel = NSSelectorFromString("__flutterEvent:")
                    if let clazz = FS as AnyObject as? NSObjectProtocol {
                        if clazz.responds(to: sel) {
                            let obj = clazz.perform(sel, with: args)
                            if(obj != nil) {
                                result(nil)
                                return
                            } else {
                                result(FlutterError(code: "INVALID_FULLSTORY", message: "Unexpected return value for flutter event", details: String(describing: obj)))
                                return
                            }
                        }
                    }
                }
                result(FlutterError(code: "INVALID_FULLSTORY", message: "Unable to find Flutter APIs in Fullstory iOS SDK. Try updating the FullStory pod.", details: nil))
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument for flutterEvent", details: "Expected Map<String, Any>, got \(String(describing: call.arguments))"))
            }
        case "register":
        guard let args = call.arguments as? [String: Any],
            let canvasDefinition = args["canvasDefinition"] as? FlutterStandardTypedData
            else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "Invalid arguments for register: expected canvasDefinition, got \(String(describing: call.arguments))",
                            details: nil))
            return
        }
        let sel = NSSelectorFromString("__registerFlutter:withCanvas:")
        guard let FS = NSClassFromString("FS"),
            let clazz = FS as AnyObject as? NSObjectProtocol,
            clazz.responds(to: sel) else {
                result(FlutterError(code: "INVALID_FULLSTORY", message: "Unable to find Flutter APIs in Fullstory iOS SDK. Try updating the FullStory pod.", details: nil))
                return
        }

        let delegate = FlutterDelegate(plugin: self)
        clazz.perform(sel, with: delegate, with: canvasDefinition.data)
        result(nil)
        case "fetchSessionData":
        if let FS = NSClassFromString("FS") {
            let sel = NSSelectorFromString("__fetchSessionData")
            if let clazz = FS as AnyObject as? NSObjectProtocol {
                if clazz.responds(to: sel) {
                    let obj = clazz.perform(sel)
                    if let rules = obj?.takeUnretainedValue() as? NSData {
                        result(rules)
                        return
                    } else {
                        result(FlutterError(code: "INVALID_FULLSTORY", message: "Unexpected return value for session data", details: String(describing: obj)))
                        return
                    }
                }
            }
        }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func scanUi(scanMode: Int32, consent: Bool, onResult: @escaping (NSData, NSData, [String], String?) -> Void) {
        channel.invokeMethod("scanUi", arguments: ["mode": scanMode, "consent": consent], result: { (response) in
            if let dict = response as? [String: Any] {
                if let error = dict["error"] as? String, !error.isEmpty {
                    // note: there is no way to send and error and capture data, it's one or the other
                    onResult(NSData(), NSData(), [], error)
                    return
                }
                if let views = dict["views"] as? FlutterStandardTypedData,
                    let canvases = dict["canvases"] as? FlutterStandardTypedData,
                    let strings = dict["strings"] as? [String] {
                    onResult(views.data as NSData, canvases.data as NSData, strings, nil)
                }
            } else {
                onResult(NSData(), NSData(), [], "Empty scan response")
            }
        })
    }

    /// This is a hack to keep the compiler from tree-shaking flutter-only libs.
    public func doNotTreeShakeFsEncoder() {
        dont_shake_me()
    }

    // FSDelegate methods to receive status events from Fullstory
    public func fullstoryDidStartSession(_ sessionUrl: String) {
        //print("Fullstory did start session with URL " + sessionUrl)
        self.channel.invokeMethod("onSession", arguments: sessionUrl)
    }

    // omitting these for now since they don't align perfectly with the Android version
    // public func fullstoryDidStopSession() {
    //     print("Fullstory has stopped session")
    //     self.channel.invokeMethod("onStop", arguments:nil)
    // }
    // public func fullstoryDidTerminateWithError(_ error: Error) {
    //     print("Fullstory did terminate with error: " + error.localizedDescription)
    //     self.channel.invokeMethod("onError", arguments: error)
    // }
}
