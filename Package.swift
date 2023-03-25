// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SwiftcodeMe",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "SwiftcodeMe",
            targets: ["SwiftcodeMe"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.9.0"),
        .package(name: "SplashPublishPlugin", url: "https://github.com/johnsundell/splashpublishplugin", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "SwiftcodeMe",
            dependencies: ["Publish", "SplashPublishPlugin"]
        )
    ]
)
