import Flutter
import UIKit
import FullStory

public class FullstoryFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fullstory_flutter", binaryMessenger: registrar.messenger())
    let instance = FullstoryFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      print("FullStory method call received", call)
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
              let level = args["level"] as? FSEventLogLevel,
              let message = args["message"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Invalid arguments for event",
                                details: nil))
            return
        }
        FS.log(with: level, message: message)
        result(nil)
    case "resetIdleTimer":
      FS.resetIdleTimer()
     result(nil)
    case "event":
          guard let args = call.arguments as? [String: Any],
                let eventName = args["eventName"] as? String,
                let properties = args["properties"] as? [String: Any] else {
              result(FlutterError(code: "INVALID_ARGUMENTS",
                                  message: "Invalid arguments for event",
                                  details: nil))
              return
          }

          FS.event(eventName, properties: properties)
          result(nil)
  //  case "consent":
  //    // todo: handle param
  //    FS.consent()
  //    result(nil)
  //  case "identity":
  //    FS.identity()
  //    result(nil)
   case "anonymize":
     FS.anonymize()
     result(nil)
  //  case "setUserVars":
  //    FS.setUserVars()
  //    result(nil)
  //  case "getCurrentSession":
  //   // todo: handle `now` param
  //    result(FS.getCurrentSession())
  //  case "getCurrentSessionURL":
  //    result(FS.getCurrentSessionURL())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
