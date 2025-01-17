import Flutter
import UIKit
import FullStory

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
        // print("FullStory method call received:", call.method, call.arguments ?? "")
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
            //  case "consent":
            //    // todo: handle param
            //    FS.consent()
            //    result(nil)
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
               let pageVars = args["pageVars"] as? [String: Any] {
                let page = FS.page(withName: pageName, properties: pageVars)
                let pageId = self.nextPageID
                self.nextPageID += 1
                self.pages[pageId] = page
                result(pageId)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Page name and pageVars are required", details: nil))
            }
        case "startPage":
            if let pageId = call.arguments as? Int,
               let page = self.pages[pageId] {
                page.start()
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_PAGE", message: "No active page found with the given ID", details: nil))
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
        default:
            result(FlutterMethodNotImplemented)
        }
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
