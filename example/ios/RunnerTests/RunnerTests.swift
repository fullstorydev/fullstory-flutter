import Flutter
import UIKit
import XCTest


@testable import fullstory_flutter

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testGetFsVersion() {
    let channel = MockMethodChannel()
    let plugin = FullstoryFlutterPlugin(channel: channel)
      
    let call = FlutterMethodCall(methodName: "fsVersion", arguments: [])
    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertEqual(result as! String, "1.54.0")
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
}

class MockMethodChannel: FlutterMethodChannel {
    var didCallMethod: String?
    
    override func invokeMethod(_ method: String, arguments: Any?, result: FlutterResult?) {
        didCallMethod = method
    }
}
