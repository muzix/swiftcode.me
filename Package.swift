// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SwiftcodeMe",
    products: [
        .executable(
            name: "SwiftcodeMe",
            targets: ["SwiftcodeMe"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "SwiftcodeMe",
            dependencies: ["Publish"]
        )
    ]
)