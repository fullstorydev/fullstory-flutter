// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "fullstory_flutter",
  platforms: [.iOS("13.0")],
  products: [
    // Dart resolves the capture bridge through DynamicLibrary.process().
    // A dynamic product keeps the bridge's C API exported without requiring
    // host-app strip settings that SwiftPM packages cannot configure.
    .library(
      name: "fullstory-flutter",
      type: .dynamic,
      targets: ["fullstory_flutter"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/fullstorydev/fullstory-swift-package-ios.git",
      // The Flutter capture bridge is released and tested in lockstep with
      // the native SDK. Update this exact pin and the podspec together.
      exact: "1.72.1"
    ),
  ],
  targets: [
    .binaryTarget(name: "shared_flutter", path: "shared_flutter.xcframework"),
    .target(
      name: "fullstory_flutter",
      dependencies: [
        "shared_flutter",
        .product(name: "FullStory", package: "fullstory-swift-package-ios"),
      ],
      resources: [.process("Resources")]
    ),
  ]
)
