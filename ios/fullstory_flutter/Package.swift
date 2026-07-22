// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "fullstory_flutter",
  platforms: [.iOS("13.0")],
  products: [
    .library(name: "fullstory-flutter", targets: ["fullstory_flutter"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/fullstorydev/fullstory-swift-package-ios.git",
      // Keep this version in sync with the FullStory dependency in
      // ../fullstory_flutter.podspec.
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
