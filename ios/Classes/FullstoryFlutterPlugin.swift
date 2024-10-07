import Flutter
import UIKit
import FullStory

public class FullstoryFlutterPlugin: NSObject, FlutterPlugin, FSDelegate {
    var channel: FlutterMethodChannel

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
        // todo: delete this & other print() calls here
        print("FullStory method call received:", call.method, call.arguments ?? "")
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
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
            case 0, 1:
                levelValue = FSLOG_DEBUG
            case 2:
                levelValue = FSLOG_INFO
            case 3:
                levelValue = FSLOG_WARNING
            case 4:
                levelValue = FSLOG_ERROR
            case 5:
                levelValue = FSLOG_ASSERT
            default:
                result(FlutterError(code: "INVALID_ARGUMENTS",
                                    message: "Unexpected log level, expected value 0-5, got \(level)",
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // FSDelegate methods to receive status events from Fullstory
    public func fullstoryDidStartSession(_ sessionUrl: String) {
        print("Fullstory did start session with URL " + sessionUrl)
        self.channel.invokeMethod("onSession", arguments: sessionUrl)
    }
    public func fullstoryDidStopSession() {
        print("Fullstory has stopped session")
        self.channel.invokeMethod("onStop", arguments:nil)
    }
    public func fullstoryDidTerminateWithError(_ error: Error) {
        print("Fullstory did terminate with error: " + error.localizedDescription)
        self.channel.invokeMethod("onError", arguments: error)
    }
}
